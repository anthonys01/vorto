package org.eclipse.vorto.codegen.hagerfw.templates.pom

import org.eclipse.vorto.codegen.hagerfw.templates.Utils
import org.eclipse.vorto.core.api.model.informationmodel.InformationModel
import org.eclipse.vorto.plugin.generator.InvocationContext
import org.eclipse.vorto.plugin.generator.utils.IFileTemplate

class RootPomFileTemplate implements IFileTemplate<InformationModel> {

    override getContent(InformationModel model,InvocationContext invocationContext) {
        '''
        <project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
            <modelVersion>4.0.0</modelVersion>

            <parent>
                <groupId>com.hg.osgi.fwk</groupId>
                <artifactId>fw-parent</artifactId>
                <version>3.1.7</version>
            </parent>

            <groupId>com.hg.osgi.vorto</groupId>
			<artifactId>«model.name.toLowerCase»</artifactId>
			<version>0.0.1-SNAPSHOT</version>

			<name>«model.displayname» Hager Cloud Client</name>

			<properties>
                <bundle.category>Vorto</bundle.category>
                <superpoms.version>3.1.7</superpoms.version>
                <com.hg.osgi.fwk.utils.common.version>1.0.5.43590</com.hg.osgi.fwk.utils.common.version>
			</properties>

            <packaging>pom</packaging>

            <dependencyManagement>
                <dependencies>
                    <dependency>
                        <groupId>com.hg.osgi.fwk</groupId>
                        <artifactId>java-common</artifactId>
                        <version>${superpoms.version}</version>
                        <type>pom</type>
                        <scope>import</scope>
                    </dependency>
                    <dependency>
                        <groupId>com.hg.osgi.fwk</groupId>
                        <artifactId>java-test</artifactId>
                        <version>${superpoms.version}</version>
                        <type>pom</type>
                        <scope>import</scope>
                    </dependency>
                    <dependency>
                        <groupId>com.hg.osgi.fwk</groupId>
                        <artifactId>prosyst9-common</artifactId>
                        <version>${superpoms.version}</version>
                        <type>pom</type>
                        <scope>import</scope>
                    </dependency>
                    <dependency>
                        <groupId>com.hg.osgi.fwk</groupId>
                        <artifactId>prosyst9-tee</artifactId>
                        <version>${superpoms.version}</version>
                        <type>pom</type>
                        <scope>import</scope>
                    </dependency>
                </dependencies>
            </dependencyManagement>

            <dependencies>
                <dependency>
                    <groupId>com.prosyst.mbs.fim</groupId>
                    <artifactId>com.prosyst.mbs.fim.api</artifactId>
                </dependency>
                <dependency>
                    <groupId>com.prosyst.mbs.core</groupId>
                    <artifactId>com.prosyst.mbs.core.api</artifactId>
                </dependency>
                <dependency>
                    <groupId>com.prosyst.mbs.osgi</groupId>
                    <artifactId>com.prosyst.mbs.osgi.api</artifactId>
                </dependency>
                <dependency>
                    <groupId>org.slf4j</groupId>
                    <artifactId>slf4j-api</artifactId>
                </dependency>
                <dependency>
                    <groupId>com.prosyst.mbs.external</groupId>
                    <artifactId>com.prosyst.mbs.framework.api</artifactId>
                </dependency>
                <dependency>
                    <groupId>com.prosyst.mbs.external</groupId>
                    <artifactId>osgi.cmpn</artifactId>
                </dependency>
                <dependency>
                    <groupId>com.prosyst.mbs.external</groupId>
                    <artifactId>osgi.core</artifactId>
                </dependency>
                <dependency>
                    <groupId>junit</groupId>
                    <artifactId>junit</artifactId>
                </dependency>
                <dependency>
                    <groupId>org.mockito</groupId>
                    <artifactId>mockito-all</artifactId>
                </dependency>
                <dependency>
                    <groupId>org.powermock</groupId>
                    <artifactId>powermock-module-junit4</artifactId>
                </dependency>
                <dependency>
                    <groupId>org.powermock</groupId>
                    <artifactId>powermock-api-mockito</artifactId>
                </dependency>
                <dependency>
                    <groupId>org.assertj</groupId>
                    <artifactId>assertj-core</artifactId>
                </dependency>
                <dependency>
                    <groupId>org.slf4j</groupId>
                    <artifactId>slf4j-simple</artifactId>
                </dependency>
            </dependencies>

            <modules>
                <module>src</module>
            </modules>
        </project>
		'''
    }

    override getFileName(InformationModel context) {
        '''pom.xml'''
    }

    override getPath(InformationModel context) {
        '''«context.name.toLowerCase»'''
    }

}