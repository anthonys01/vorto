package org.eclipse.vorto.codegen.hagerfw.templates.fi

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

class FIModelImplTemplate implements IFileTemplate<FunctionblockModel> {

    InformationModel informationModelContext;

    JavaClassFieldTemplate propertyTemplate;
    JavaClassFieldSetterTemplate propertySetterTemplate;
    JavaClassFieldGetterTemplate propertyGetterTemplate;
    JavaClassMethodParameterTemplate methodParameterTemplate;
    JavaClassMethodTemplate methodTemplate;

    new(InformationModel context) {
        this.informationModelContext = context;

        this.propertyTemplate = new JavaClassFieldTemplate(){
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
        return model.getName()+"FI.java"
    }

    override getPath(FunctionblockModel model) {
        '''«Utils.getJavaPackageBasePath(informationModelContext)»/model'''
    }


    override getContent(FunctionblockModel model,InvocationContext context) {
        '''
		package «Utils.getJavaPackage(informationModelContext)».model;

		import com.prosyst.mbs.services.fim.spi.AbstractFunctionalItem;
		import com.prosyst.mbs.services.fim.spi.FunctionalItemAdminSpi;
		import org.osgi.framework.BundleContext;
		import org.osgi.service.component.annotations.*;
		import «Utils.getJavaPackage(informationModelContext)».model.datatypes.*;
		import java.util.HashMap;
		import java.util.Map;

		@Component(service = {})
		public class «model.getName»FI extends AbstractFunctionalItem implements I«model.getName»FI {

		    private static final String FI_UID = "«model.getName»FI";

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

		    public «model.getName»FI() {
		        super(FI_UID);
		    }

		    /**
		     * bind method for fiAdminSpi
		     * @param fiAdminSpi functional item admin spi
		     */
		    @Reference
		    public void setFiAdminSpi(FunctionalItemAdminSpi fiAdminSpi) {
		        this.fiAdminSpi = fiAdminSpi;
		    }

		    /**
		     * activate method called by the SCR
		     * @param context bundle context
		     */
		    @Activate
		    public void activated(BundleContext context) {
		        this.register(context, fiAdminSpi);
		    }

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

		    @Override
		    public Map<String, Object> getStatusProperties() {
		        Map<String, Object> status = new HashMap<>();
		        «IF fb.status !== null»
		        	«FOR property : model.functionblock.status.properties»
		        		status.put("«property.name»", this.«property.name»);
		        	«ENDFOR»
		        «ENDIF»
		    	return status;
		    }

		    @Override
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