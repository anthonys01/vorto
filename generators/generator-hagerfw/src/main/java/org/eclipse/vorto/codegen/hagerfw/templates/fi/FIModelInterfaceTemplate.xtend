package org.eclipse.vorto.codegen.hagerfw.templates.fi

import org.eclipse.vorto.codegen.hagerfw.templates.Utils
import org.eclipse.vorto.core.api.model.datatype.Property
import org.eclipse.vorto.core.api.model.functionblock.FunctionblockModel
import org.eclipse.vorto.core.api.model.informationmodel.InformationModel
import org.eclipse.vorto.plugin.generator.InvocationContext
import org.eclipse.vorto.plugin.generator.utils.IFileTemplate
import org.eclipse.vorto.plugin.generator.utils.javatemplates.ValueMapper
import org.eclipse.vorto.plugin.generator.utils.javatemplates.JavaClassMethodParameterTemplate

class FIModelInterfaceTemplate implements IFileTemplate<FunctionblockModel> {

    InformationModel informationModelContext;
    FIPropertyGetterSetterTemplate propertyTemplate;
    JavaClassMethodParameterTemplate methodParameterTemplate;
    FIOperationPrototypeTemplate methodTemplate;

    new(InformationModel context) {
        this.informationModelContext = context;
        this.propertyTemplate = new FIPropertyGetterSetterTemplate() {
            protected override getNamespaceOfDatatype() {
                '''«Utils.getJavaPackage(informationModelContext)».model.datatypes.'''
            }
        };
        this.methodParameterTemplate = new JavaClassMethodParameterTemplate();

        this.methodTemplate = new FIOperationPrototypeTemplate(this.methodParameterTemplate);
    }

    override getFileName(FunctionblockModel model) {
        return "I" + model.getName() + "FI.java"
    }

    override getPath(FunctionblockModel model) {
        '''«Utils.getJavaPackageBasePath(informationModelContext)»/model'''
    }

    override getContent(FunctionblockModel model, InvocationContext context) {
        '''
		package «Utils.getJavaPackage(informationModelContext)».model;

		import «Utils.getJavaPackage(informationModelContext)».model.datatypes.*;
		import com.prosyst.mbs.services.fim.FunctionalItem;
		import com.prosyst.mbs.services.fim.annotations.*;
		import java.util.HashMap;
		import java.util.Map;

		@Item
		@Name("«model.getName» Functional Item")
		@Description("«model.getName» represented as a Functional Item")
		@Version("1.0.0")
		public interface I«model.getName»FI {
		    «var fb = model.functionblock»
		    «IF fb.status !== null»

		    /** Status properties */

		    «FOR property : model.functionblock.status.properties»
		        @Property(access = "RE")
		        String « Utils.toUpperCaseWithUnderscore(property.name) » = "«property.name»";
		    «ENDFOR»
		    «ENDIF»
		    «IF fb.configuration !== null»

		    /** Configuration properties */

		    «FOR property : model.functionblock.configuration.properties»
		        @Property(access = "RWE")
		        String « Utils.toUpperCaseWithUnderscore(property.name) » = "«property.name»";
		    «ENDFOR»
		    «ENDIF»

		    «IF fb.status !== null»
		    	«FOR property : model.functionblock.status.properties»
		    		«propertyTemplate.getContent(property,context)»
		    	«ENDFOR»
		    «ENDIF»
		    «IF fb.configuration !== null»
		    	«FOR property : model.functionblock.configuration.properties»
		    		«propertyTemplate.getContent(property,context)»
		    	«ENDFOR»
		    «ENDIF»

		    «FOR operation : model.functionblock.operations»
		    	@Operation
		    	«methodTemplate.getContent(operation,context)»
		    «ENDFOR»

		    public Map<String, Object> getStatusProperties();

		    public Map<String, Object> getConfigurationProperties();
		}
		'''
    }
}