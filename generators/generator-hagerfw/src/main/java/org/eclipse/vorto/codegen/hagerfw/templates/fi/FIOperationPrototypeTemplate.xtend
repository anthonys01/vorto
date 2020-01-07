package org.eclipse.vorto.codegen.hagerfw.templates.fi

import org.eclipse.vorto.core.api.model.datatype.Entity
import org.eclipse.vorto.core.api.model.datatype.Enum
import org.eclipse.vorto.core.api.model.functionblock.Operation
import org.eclipse.vorto.core.api.model.functionblock.Param
import org.eclipse.vorto.core.api.model.functionblock.ReturnObjectType
import org.eclipse.vorto.core.api.model.functionblock.ReturnPrimitiveType
import org.eclipse.vorto.plugin.generator.InvocationContext
import org.eclipse.vorto.plugin.generator.utils.ITemplate

class FIOperationPrototypeTemplate implements ITemplate<Operation> {

    var ITemplate<Param> parameter

    new(ITemplate<Param> parameter) {
        this.parameter = parameter;
    }

    override getContent(Operation op,InvocationContext invocationContext) {
        '''
            /**
            * «op.description»
			*/
			«IF op.returnType instanceof ReturnObjectType»
				«var objectType = op.returnType as ReturnObjectType»
				public «objectType.returnType.name» «op.name»(«getParameterString(op,invocationContext)»);
			«ELSEIF op.returnType instanceof ReturnPrimitiveType»
				«var primitiveType = op.returnType as ReturnPrimitiveType»
				public «primitiveType.returnType.getName» «op.name»(«getParameterString(op,invocationContext)»);
			«ELSE»
				public void «op.name»(«getParameterString(op,invocationContext)»);
			«ENDIF»
		'''
    }

    def String getParameterString(Operation op,InvocationContext invocationContext) {
        var String result="";
        for (param : op.params) {
            result =  result + ", " + parameter.getContent(param,invocationContext);
        }
        if (result.isNullOrEmpty) {
            return "";
        }
        else {
            return result.substring(2, result.length).replaceAll("\n", "").replaceAll("\r", "");
        }
    }
}