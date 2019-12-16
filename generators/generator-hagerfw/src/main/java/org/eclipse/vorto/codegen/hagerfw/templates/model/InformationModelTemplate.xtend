package org.eclipse.vorto.codegen.hagerfw.templates.model

import org.eclipse.vorto.codegen.hagerfw.templates.Utils
import org.eclipse.vorto.core.api.model.informationmodel.InformationModel
import org.eclipse.vorto.plugin.generator.InvocationContext
import org.eclipse.vorto.plugin.generator.utils.IFileTemplate

class InformationModelTemplate implements IFileTemplate<InformationModel> {

    override getFileName(InformationModel context) {
        '''«context.name».java'''
    }

    override getPath(InformationModel context) {
        '''«Utils.getJavaPackageBasePath(context)»/model'''
    }

    override getContent(InformationModel element, InvocationContext context) {
        '''
        package «Utils.getJavaPackage(element)».model;

public class «element.name» {
	«FOR fbProperty : element.properties»
	private «fbProperty.type.name» «fbProperty.name»;
	«ENDFOR»

	private String resourceId;

	public «element.name»(String resourceId) {
		this.resourceId = resourceId;
	}

	«FOR fbProperty : element.properties»
	public «fbProperty.type.name» get«fbProperty.name.toFirstUpper»() {
		return «fbProperty.name»;
	}

	public void set«fbProperty.name.toFirstUpper»(«fbProperty.type.name» «fbProperty.name») {
		this.«fbProperty.name» = «fbProperty.name»;
	}

	«ENDFOR»
	public void setResourceId(String resourceId) {
		this.resourceId = resourceId;
	}

	public String getResourceId() {
		return resourceId;
	}
}
'''
    }

}