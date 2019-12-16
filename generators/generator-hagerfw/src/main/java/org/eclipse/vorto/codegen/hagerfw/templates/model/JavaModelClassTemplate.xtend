package org.eclipse.vorto.codegen.hagerfw.templates.model

import org.eclipse.vorto.codegen.hagerfw.templates.Utils
import org.eclipse.vorto.core.api.model.datatype.Entity
import org.eclipse.vorto.core.api.model.informationmodel.InformationModel
import org.eclipse.vorto.plugin.generator.InvocationContext
import org.eclipse.vorto.plugin.generator.utils.IFileTemplate
import org.eclipse.vorto.plugin.generator.utils.javatemplates.JavaClassFieldGetterTemplate
import org.eclipse.vorto.plugin.generator.utils.javatemplates.JavaClassFieldSetterTemplate
import org.eclipse.vorto.plugin.generator.utils.javatemplates.JavaClassFieldTemplate

class JavaModelClassTemplate implements IFileTemplate<Entity> {

    InformationModel informationModelContext;

    JavaClassFieldTemplate propertyTemplate;
    JavaClassFieldSetterTemplate propertySetterTemplate;
    JavaClassFieldGetterTemplate propertyGetterTemplate;

    new(InformationModel context) {
        this.informationModelContext = context;

        this.propertyTemplate = new JavaClassFieldTemplate();
        this.propertySetterTemplate = new JavaClassFieldSetterTemplate("set");
        this.propertyGetterTemplate = new JavaClassFieldGetterTemplate("get");
    }

    override getFileName(Entity entity) {
        return entity.getName()+".java"
    }

    override getPath(Entity entity) {
        '''«Utils.getJavaPackageBasePath(informationModelContext)»/model/datatypes'''
    }


    override getContent(Entity entity, InvocationContext context) {
        '''
		« var pptSet = Utils.getPropertySet(entity) »
		package «Utils.getJavaPackage(informationModelContext)».model.datatypes;

		import java.util.HashMap;
		import java.util.Map;

		public class «entity.getName» {

		    «FOR property : pptSet»
                «propertyTemplate.getContent(property,context)»
		    «ENDFOR»

		    «FOR property : pptSet»
                «propertySetterTemplate.getContent(property,context)»

                «propertyGetterTemplate.getContent(property,context)»
		    «ENDFOR»
		}
		'''
    }
}