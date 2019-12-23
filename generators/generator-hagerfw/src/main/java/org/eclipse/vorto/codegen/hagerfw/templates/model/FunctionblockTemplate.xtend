package org.eclipse.vorto.codegen.hagerfw.templates.model

import org.eclipse.vorto.codegen.hagerfw.templates.Utils
import org.eclipse.vorto.core.api.model.datatype.Property
import org.eclipse.vorto.core.api.model.functionblock.FunctionblockModel
import org.eclipse.vorto.core.api.model.informationmodel.InformationModel
import org.eclipse.vorto.plugin.generator.InvocationContext
import org.eclipse.vorto.plugin.generator.utils.IFileTemplate
import org.eclipse.vorto.plugin.generator.utils.javatemplates.JavaClassFieldGetterTemplate
import org.eclipse.vorto.plugin.generator.utils.javatemplates.JavaClassFieldSetterTemplate
import org.eclipse.vorto.plugin.generator.utils.javatemplates.JavaClassFieldTemplate
import org.eclipse.vorto.plugin.generator.utils.javatemplates.JavaClassMethodParameterTemplate
import org.eclipse.vorto.plugin.generator.utils.javatemplates.JavaClassMethodTemplate

class FunctionblockTemplate implements IFileTemplate<FunctionblockModel> {
    InformationModel informationModelContext;

    JavaClassFieldTemplate propertyTemplate;
    JavaClassFieldSetterTemplate propertySetterTemplate;
    JavaClassFieldGetterTemplate propertyGetterTemplate;
    JavaClassMethodParameterTemplate methodParameterTemplate;
    JavaClassMethodTemplate methodTemplate;

    new(InformationModel context) {
        this.informationModelContext = context;

        this.propertyTemplate = new JavaClassFieldTemplate() {
            protected override addFieldAnnotations(Property property) {
                '''
                @com.google.gson.annotations.SerializedName("«property.name»")
			'''
            }

            protected override getNamespaceOfDatatype() {
                '''«Utils.getJavaPackage(informationModelContext)».model.datatypes.'''
            }
        };
        this.propertySetterTemplate = new JavaClassFieldSetterTemplate("set") {
            protected override getNamespaceOfDatatype() {
                '''«Utils.getJavaPackage(informationModelContext)».model.datatypes.'''
            }
        };
        this.propertyGetterTemplate = new JavaClassFieldGetterTemplate("get") {
            protected override getNamespaceOfDatatype() {
                '''«Utils.getJavaPackage(informationModelContext)».model.datatypes.'''
            }
        };

        this.methodParameterTemplate = new JavaClassMethodParameterTemplate();

        this.methodTemplate = new JavaClassMethodTemplate(this.methodParameterTemplate);
    }

    override getFileName(FunctionblockModel model) {
        return model.getName()+".java"
    }

    override getPath(FunctionblockModel model) {
        '''«Utils.getJavaPackageBasePath(informationModelContext)»/model'''
    }


    override getContent(FunctionblockModel model,InvocationContext context) {
        '''
		package «Utils.getJavaPackage(informationModelContext)».model;

		import java.util.HashMap;
		import java.util.Map;

		public class «model.getName» {
		    «var fb = model.functionblock»
		    «IF fb.status !== null»

		    /** Status properties */

		    «FOR property : model.functionblock.status.properties»
		    	«propertyTemplate.getContent(property,context)»
		    «ENDFOR»
		    «ENDIF»
		    «IF fb.configuration !== null»

		    /** Configuration properties */

		    «FOR property : model.functionblock.configuration.properties»
		    	«propertyTemplate.getContent(property,context)»
		    «ENDFOR»
		    «ENDIF»

		    «IF fb.status !== null»
		    	«FOR property : model.functionblock.status.properties»
		    		«propertySetterTemplate.getContent(property,context)»
		    		«propertyGetterTemplate.getContent(property,context)»
		    	«ENDFOR»
		    «ENDIF»
		    «IF fb.configuration !== null»
		    	«FOR property : model.functionblock.configuration.properties»
		    		«propertySetterTemplate.getContent(property,context)»
		    		«propertyGetterTemplate.getContent(property,context)»
		    	«ENDFOR»
		    «ENDIF»

		    «FOR operation : model.functionblock.operations»
		    	«methodTemplate.getContent(operation,context)»
		    «ENDFOR»

		    public Map<String, Object> getStatusProperties() {
		        Map<String, Object> status = new HashMap<>();
		        «IF fb.status !== null»
		        	«FOR property : model.functionblock.status.properties»
		        		status.put("«property.name»", this.«property.name»);
		        	«ENDFOR»
		        «ENDIF»
		    	return status;
		    }
		    public Map<String, Object> getConfigurationProperties() {
		        Map<String, Object> configuration = new HashMap<>();
		        «IF fb.configuration !== null»
		        	«FOR property : model.functionblock.configuration.properties»
		        		configuration.put("«property.name»", this.«property.name»);
		        	«ENDFOR»
		        «ENDIF»
		        return configuration;
		    }
		}
		'''
    }
}