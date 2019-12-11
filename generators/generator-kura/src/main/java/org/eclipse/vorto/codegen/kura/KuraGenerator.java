package org.eclipse.vorto.codegen.kura;

import org.eclipse.vorto.core.api.model.informationmodel.FunctionblockProperty;
import org.eclipse.vorto.core.api.model.informationmodel.InformationModel;
import org.eclipse.vorto.plugin.generator.*;
import org.eclipse.vorto.plugin.generator.utils.ChainedCodeGeneratorTask;
import org.eclipse.vorto.plugin.generator.utils.GenerationResultZip;
import org.eclipse.vorto.plugin.generator.utils.GeneratorTaskFromFileTemplate;
import org.eclipse.vorto.codegen.kura.templates.BuildPropertiesTemplate;
import org.eclipse.vorto.codegen.kura.templates.DefaultAppTemplate;
import org.eclipse.vorto.codegen.kura.templates.EclipseClasspathTemplate;
import org.eclipse.vorto.codegen.kura.templates.EclipseProjectFileTemplate;
import org.eclipse.vorto.codegen.kura.templates.IDataServiceTemplate;
import org.eclipse.vorto.codegen.kura.templates.KuraCloudDataServiceTemplate;
import org.eclipse.vorto.codegen.kura.templates.ManifestTemplate;
import org.eclipse.vorto.codegen.kura.templates.PomTemplate;
import org.eclipse.vorto.codegen.kura.templates.bluetooth.ConfigurationTemplate;
import org.eclipse.vorto.codegen.kura.templates.bluetooth.DeviceBluetoothFinderTemplate;
import org.eclipse.vorto.codegen.kura.templates.bluetooth.DeviceFilterTemplate;
import org.eclipse.vorto.codegen.kura.templates.bluetooth.DeviceToInformationModelTransformerTemplate;
import org.eclipse.vorto.codegen.kura.templates.bluetooth.InformationModelConsumerTemplate;
import org.eclipse.vorto.codegen.kura.templates.cloud.FunctionblockTemplate;
import org.eclipse.vorto.codegen.kura.templates.cloud.InformationModelTemplate;
import org.eclipse.vorto.codegen.kura.templates.cloud.bosch.BoschDataServiceTemplate;
import org.eclipse.vorto.codegen.kura.templates.cloud.bosch.BoschHubClientTemplate;
import org.eclipse.vorto.codegen.kura.templates.cloud.bosch.BoschHubDataService;
import org.eclipse.vorto.codegen.kura.templates.cloud.bosch.ThingClientFactoryTemplate;
import org.eclipse.vorto.codegen.kura.templates.osgiinf.ComponentXmlTemplate;
import org.eclipse.vorto.codegen.kura.templates.osgiinf.MetatypeTemplate;

public class KuraGenerator implements ICodeGenerator {

    private static final String KEY = "kura";
    private static final String KEY_PROVISION = "provision";
    private static final String KEY_LANGUAGE = "language";

    @Override
    public IGenerationResult generate(InformationModel model, InvocationContext invocationContext) throws GeneratorException {
        GenerationResultZip outputter = new GenerationResultZip(model, KEY);
        ChainedCodeGeneratorTask<InformationModel> generator = new ChainedCodeGeneratorTask<InformationModel>();

        generator.addTask(new GeneratorTaskFromFileTemplate<>(new EclipseClasspathTemplate()));
        generator.addTask(new GeneratorTaskFromFileTemplate<>(new EclipseProjectFileTemplate()));
        generator.addTask(new GeneratorTaskFromFileTemplate<>(new ManifestTemplate()));
        generator.addTask(new GeneratorTaskFromFileTemplate<>(new BuildPropertiesTemplate()));
        generator.addTask(new GeneratorTaskFromFileTemplate<>(new ComponentXmlTemplate()));
        generator.addTask(new GeneratorTaskFromFileTemplate<>(new IDataServiceTemplate()));

        if (invocationContext.getConfigurationProperties().getOrDefault("boschcloud", "false")
                .equalsIgnoreCase("true")) {
            generator.addTask(new GeneratorTaskFromFileTemplate<>(new PomTemplate()));
            generator.addTask(new GeneratorTaskFromFileTemplate<>(new BoschDataServiceTemplate()));
            generator.addTask(new GeneratorTaskFromFileTemplate<>(new ThingClientFactoryTemplate()));
        } else if (invocationContext.getConfigurationProperties().getOrDefault("boschhub", "false")
                .equalsIgnoreCase("true")) {
            generator.addTask(new GeneratorTaskFromFileTemplate<>(new PomTemplate()));
            generator.addTask(new GeneratorTaskFromFileTemplate<>(new BoschHubDataService()));
            generator.addTask(new GeneratorTaskFromFileTemplate<>(new BoschHubClientTemplate()));
        } else {
            generator.addTask(new GeneratorTaskFromFileTemplate<>(new KuraCloudDataServiceTemplate()));
        }

        if (invocationContext.getConfigurationProperties().getOrDefault("bluetooth", "false")
                .equalsIgnoreCase("true")) {
            generator.addTask(new GeneratorTaskFromFileTemplate<>(new MetatypeTemplate()));
            generator.addTask(new GeneratorTaskFromFileTemplate<>(new DeviceBluetoothFinderTemplate()));
            generator.addTask(new GeneratorTaskFromFileTemplate<>(new ConfigurationTemplate()));
            generator.addTask(new GeneratorTaskFromFileTemplate<>(new DeviceFilterTemplate()));
            generator.addTask(new GeneratorTaskFromFileTemplate<>(new DeviceToInformationModelTransformerTemplate()));
            generator.addTask(new GeneratorTaskFromFileTemplate<>(new InformationModelConsumerTemplate()));
        } else {
            generator.addTask(new GeneratorTaskFromFileTemplate<>(new DefaultAppTemplate()));
        }

        generator.addTask(new GeneratorTaskFromFileTemplate<>(new InformationModelTemplate()));
        for (FunctionblockProperty fbProperty : model.getProperties()) {
            new GeneratorTaskFromFileTemplate<>(new FunctionblockTemplate(model)).generate(fbProperty.getType(),
                    invocationContext, outputter);
        }

        generator.generate(model, invocationContext, outputter);

        return outputter;
    }

    @Override
    public GeneratorPluginInfo getMeta() {
	return GeneratorPluginInfo.Builder(KEY)
            .withConfigurationKey(KEY_LANGUAGE,KEY_PROVISION)
            .withName("Eclipse Kura")
            .withVendor("Vorto Community")
            .withDescription("Generates a Kura Gateway application that reads data from the device (e.g. via bluetooth) and sends the data to a IoT Cloud backend.")
            .withDocumentationUrl("https://github.com/eclipse/vorto-examples/tree/master/vorto-generators/generator-boschiotsuite/org.eclipse.vorto.codegen.kura")
            .build();
    }
}
