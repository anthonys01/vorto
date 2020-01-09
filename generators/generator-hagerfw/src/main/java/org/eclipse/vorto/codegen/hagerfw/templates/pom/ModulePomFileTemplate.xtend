package org.eclipse.vorto.codegen.hagerfw.templates.pom

import org.eclipse.vorto.codegen.hagerfw.templates.Utils
import org.eclipse.vorto.core.api.model.informationmodel.InformationModel
import org.eclipse.vorto.plugin.generator.InvocationContext
import org.eclipse.vorto.plugin.generator.utils.IFileTemplate

class ModulePomFileTemplate implements IFileTemplate<InformationModel> {

    override getContent(InformationModel model,InvocationContext invocationContext) {
        '''
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <parent>
        <groupId>com.hg.osgi.vorto</groupId>
        <artifactId>src</artifactId>
        <version>0.0.1-SNAPSHOT</version>
    </parent>

    <artifactId>«Utils.getJavaPackage(model)»</artifactId>
    <name>Vorto Generated Model Cloud Connector bundle</name>
    <description>This bundle provides the base code to establish a cloud connection with cloudservice for a given vorto model</description>

    <properties>
        <bundle.exportPackage>
            «Utils.getJavaPackage(model)».model
        </bundle.exportPackage>
    </properties>

    <dependencies>
        <dependency>
            <groupId>com.hg.osgi.fwk</groupId>
            <artifactId>com.hg.osgi.fwk.cloud.cloudservice.api</artifactId>
            <version>1.4.0</version>
        </dependency>
        <dependency>
            <groupId>com.hg.osgi.fwk</groupId>
            <artifactId>com.hg.osgi.fwk.cloud.cloudservice.azureiot.core</artifactId>
            <version>1.4.0</version>
        </dependency>
    </dependencies>
</project>
		'''
    }

    override getFileName(InformationModel context) {
        '''pom.xml'''
    }

    override getPath(InformationModel context) {
        '''«Utils.getJavaOSGiBundleBasePath(context)»'''
    }

}