package org.eclipse.vorto.codegen.hagerfw;

import org.eclipse.vorto.codegen.hagerfw.templates.model.JavaModelClassTemplate;
import org.eclipse.vorto.codegen.hagerfw.templates.model.JavaEnumGeneratorTask;
import org.eclipse.vorto.codegen.hagerfw.templates.model.FunctionblockTemplate;
import org.eclipse.vorto.codegen.hagerfw.templates.connector.InformationModelTemplate;
import org.eclipse.vorto.codegen.hagerfw.templates.connector.CloudConnectionHelperTemplate;
import org.eclipse.vorto.codegen.hagerfw.templates.connector.InformationModelConfigTemplate;
import org.eclipse.vorto.codegen.hagerfw.templates.pom.RootPomFileTemplate;
import org.eclipse.vorto.codegen.hagerfw.templates.pom.SrcPomFileTemplate;
import org.eclipse.vorto.codegen.hagerfw.templates.pom.ModulePomFileTemplate;
import org.eclipse.vorto.codegen.hagerfw.templates.fi.FIModelImplTemplate;
import org.eclipse.vorto.codegen.hagerfw.templates.fi.FIModelInterfaceTemplate;
import org.eclipse.vorto.codegen.hagerfw.templates.basicclient.BasicClientTemplate;
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
        ChainedCodeGeneratorTask<InformationModel> generator = new ChainedCodeGeneratorTask<>();
        generator.addTask(new GeneratorTaskFromFileTemplate<>(new RootPomFileTemplate()));
        generator.addTask(new GeneratorTaskFromFileTemplate<>(new SrcPomFileTemplate()));
        generator.addTask(new GeneratorTaskFromFileTemplate<>(new ModulePomFileTemplate()));
        generator.addTask(new GeneratorTaskFromFileTemplate<>(new InformationModelTemplate()));
        generator.addTask(new GeneratorTaskFromFileTemplate<>(new InformationModelConfigTemplate()));
        generator.addTask(new GeneratorTaskFromFileTemplate<>(new CloudConnectionHelperTemplate()));

        generator.addTask(new GeneratorTaskFromFileTemplate<>(new BasicClientTemplate()));

        generator.generate(model, context, outputter);

        for (FunctionblockProperty fbProperty : model.getProperties()) {
            new GeneratorTaskFromFileTemplate<>(new FunctionblockTemplate(model))
                    .generate(fbProperty.getType(), context, outputter);
            new GeneratorTaskFromFileTemplate<>(new FIModelInterfaceTemplate(model))
                    .generate(fbProperty.getType(), context, outputter);
            new GeneratorTaskFromFileTemplate<>(new FIModelImplTemplate(model))
                    .generate(fbProperty.getType(), context, outputter);

            FunctionBlock fb = fbProperty.getType().getFunctionblock();

            for (Entity entity : org.eclipse.vorto.plugin.utils.Utils.getReferencedEntities(fb)) {
                new GeneratorTaskFromFileTemplate<>(new JavaModelClassTemplate(model))
                    .generate(entity, context, outputter);
            }
            for (Enum en : org.eclipse.vorto.plugin.utils.Utils.getReferencedEnums(fb)) {
                generateForEnum(model, en, outputter);
            }
        }

        return outputter;
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
