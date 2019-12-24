package org.eclipse.vorto.codegen.hagerfw.templates.connector

import org.eclipse.vorto.codegen.hagerfw.templates.Utils
import org.eclipse.vorto.core.api.model.informationmodel.InformationModel
import org.eclipse.vorto.plugin.generator.InvocationContext
import org.eclipse.vorto.plugin.generator.utils.IFileTemplate

class InformationModelConfigTemplate implements IFileTemplate<InformationModel> {

    override getFileName(InformationModel context) {
        '''«context.name»AppConfig.java'''
    }

    override getPath(InformationModel context) {
        '''«Utils.getJavaPackageBasePath(context)»'''
    }

    override getContent(InformationModel element, InvocationContext context) {
        '''
package «Utils.getJavaPackage(element)»;

import org.osgi.service.metatype.annotations.AttributeDefinition;
import org.osgi.service.metatype.annotations.ObjectClassDefinition;

@ObjectClassDefinition(name = "«element.name»AppConfig", pid = "«Utils.getJavaPackage(element)»",
        description = "Configuration object used to configure the IoT Hub connection for «element.name»")
public @interface «element.name»AppConfig {

    @AttributeDefinition(name = "iotHubAddress", description = "IoT Hub Address")
    String iotHubAddress();

    @AttributeDefinition(name = "deviceId", description = "Device ID in the IoT Hub")
    String deviceId();

    @AttributeDefinition(name = "certPath", description = "Path to the certificate file of the device")
    String certPath();

    @AttributeDefinition(name = "keyPath", description = "Path to the private key file corresponding to the certificate")
    String keyPath();
}
'''
    }

}