package org.eclipse.vorto.codegen.hagerfw;

import org.eclipse.vorto.codegen.hono.java.AppTemplate;
import org.eclipse.vorto.codegen.hono.java.Log4jTemplate;
import org.eclipse.vorto.codegen.hono.java.PomFileTemplate;
import org.eclipse.vorto.codegen.hono.java.model.FunctionblockTemplate;
import org.eclipse.vorto.codegen.hono.java.model.InformationModelTemplate;
import org.eclipse.vorto.codegen.hono.java.model.JavaClassGeneratorTask;
import org.eclipse.vorto.codegen.hono.java.model.JavaEnumGeneratorTask;
import org.eclipse.vorto.codegen.hono.java.service.IDataServiceTemplate;
import org.eclipse.vorto.codegen.hono.java.service.hono.HonoDataService;
import org.eclipse.vorto.codegen.hono.java.service.hono.HonoMqttClientTemplate;
import org.eclipse.vorto.core.api.model.datatype.Entity;
import org.eclipse.vorto.core.api.model.datatype.Enum;
import org.eclipse.vorto.core.api.model.functionblock.FunctionBlock;
import org.eclipse.vorto.core.api.model.informationmodel.FunctionblockProperty;
import org.eclipse.vorto.core.api.model.informationmodel.InformationModel;
import org.eclipse.vorto.plugin.generator.*;
import org.eclipse.vorto.plugin.generator.utils.ChainedCodeGeneratorTask;
import org.eclipse.vorto.plugin.generator.utils.GenerationResultZip;
import org.eclipse.vorto.plugin.generator.utils.GeneratorTaskFromFileTemplate;
import org.eclipse.vorto.plugin.generator.utils.IGeneratedWriter;

/**
 * Vorto Generator class. Base code taken from the Eclipse Hono plugin in this repo
 *
 * @author a.suong
 */
public class HagerFWGenerator implements ICodeGenerator {

    private static final String KEY = "hagerfw";

    @Override
    public IGenerationResult generate(InformationModel model, InvocationContext context) throws GeneratorException {
        GenerationResultZip outputter = new GenerationResultZip(model, KEY);
        ChainedCodeGeneratorTask<InformationModel> generator = new ChainedCodeGeneratorTask<InformationModel>();
        generator.addTask(new GeneratorTaskFromFileTemplate<InformationModel>(new PomFileTemplate()));
        generator.addTask(new GeneratorTaskFromFileTemplate<InformationModel>(new InformationModelTemplate()));

        generator.generate(model, context, outputter);

        for (FunctionblockProperty fbProperty : model.getProperties()) {
            new GeneratorTaskFromFileTemplate<>(new FunctionblockTemplate(model))
                    .generate(fbProperty.getType(), context, outputter);

            FunctionBlock fb = fbProperty.getType().getFunctionblock();

            for (Entity entity : org.eclipse.vorto.plugin.utils.Utils.getReferencedEntities(fb)) {
                generateForEntity(model, entity, outputter);
            }
            for (Enum en : org.eclipse.vorto.plugin.utils.Utils.getReferencedEnums(fb)) {
                generateForEnum(model, en, outputter);
            }
        }

        return outputter;
    }

    private void generateForEntity(InformationModel infomodel, Entity entity,
                                   IGeneratedWriter outputter) {
        new JavaClassGeneratorTask(infomodel).generate(entity, null, outputter);
    }

    private void generateForEnum(InformationModel infomodel, Enum en, IGeneratedWriter outputter) {
        new JavaEnumGeneratorTask(infomodel).generate(en, null, outputter);

    }

    @Override
    public GeneratorPluginInfo getMeta() {
        return GeneratorPluginInfo.Builder(KEY)
                .withName("Hager OSGi Framework")
                .withVendor("Hager")
                .withDescription("Generates a Hager Gateway application that reads data from the device and send it to the cloud")
                .withDocumentationUrl("https://github.com/anhtonys01/vorto/tree/hagerpoc/generators/generator-hagerfw/org.eclipse.vorto.codegen.hagerfw")
                .build();
    }
}
