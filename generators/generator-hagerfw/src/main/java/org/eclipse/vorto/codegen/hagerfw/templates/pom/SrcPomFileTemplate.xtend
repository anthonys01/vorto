package org.eclipse.vorto.codegen.hagerfw.templates.pom

import org.eclipse.vorto.codegen.hagerfw.templates.Utils
import org.eclipse.vorto.core.api.model.informationmodel.InformationModel
import org.eclipse.vorto.plugin.generator.InvocationContext
import org.eclipse.vorto.plugin.generator.utils.IFileTemplate

class SrcPomFileTemplate implements IFileTemplate<InformationModel> {

    override getContent(InformationModel model,InvocationContext invocationContext) {
        '''
        <project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
            <modelVersion>4.0.0</modelVersion>

            <parent>
                <groupId>com.hg.osgi.vorto</groupId>
                <artifactId>«model.name.toLowerCase»</artifactId>
                <version>0.0.1-SNAPSHOT</version>
            </parent>

			<artifactId>src</artifactId>
            <packaging>pom</packaging>

            <modules>
                <module>«Utils.getJavaPackage(model)»</module>
            </modules>
        </project>
		'''
    }

    override getFileName(InformationModel context) {
        '''pom.xml'''
    }

    override getPath(InformationModel context) {
        '''«context.name.toLowerCase»/src'''
    }

}