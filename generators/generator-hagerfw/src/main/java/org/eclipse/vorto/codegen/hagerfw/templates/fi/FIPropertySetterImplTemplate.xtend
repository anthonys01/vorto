package org.eclipse.vorto.codegen.hagerfw.templates.fi

import org.eclipse.vorto.codegen.hagerfw.templates.Utils
import org.eclipse.vorto.core.api.model.datatype.Entity
import org.eclipse.vorto.core.api.model.datatype.Enum
import org.eclipse.vorto.core.api.model.datatype.ObjectPropertyType
import org.eclipse.vorto.core.api.model.datatype.PrimitivePropertyType
import org.eclipse.vorto.core.api.model.datatype.PrimitiveType
import org.eclipse.vorto.core.api.model.datatype.Property
import org.eclipse.vorto.plugin.generator.InvocationContext
import org.eclipse.vorto.plugin.generator.utils.ITemplate
import org.eclipse.vorto.plugin.generator.utils.javatemplates.ValueMapper

class FIPropertySetterImplTemplate implements ITemplate<Property> {

    override getContent(Property property, InvocationContext invocationContext) {
        '''
«IF property.type instanceof PrimitivePropertyType»
    void set«ValueMapper.normalize(property.name.toFirstUpper)»(«ValueMapper.mapSimpleDatatype((property.type as PrimitivePropertyType).type as PrimitiveType)» «ValueMapper.normalize(property.name)») {
        propertyChanged(« Utils.toUpperCaseWithUnderscore(property.name) », «ValueMapper.normalize(property.name)», this.«ValueMapper.normalize(property.name)», true);
        this.«ValueMapper.normalize(property.name)» = «ValueMapper.normalize(property.name)»;
    }
«ELSEIF property.type instanceof ObjectPropertyType»
    «var ObjectPropertyType object = property.type as ObjectPropertyType»
    «IF object.type instanceof Entity»
        void set«ValueMapper.normalize(property.name.toFirstUpper)»(«namespaceOfDatatype»«(object.type as Entity).name.toFirstUpper» «ValueMapper.normalize(property.name)») {
            propertyChanged(« Utils.toUpperCaseWithUnderscore(property.name) », «ValueMapper.normalize(property.name)», this.«ValueMapper.normalize(property.name)», true);
            this.«ValueMapper.normalize(property.name)» = «ValueMapper.normalize(property.name)»;
        }
    «ELSEIF object.type instanceof Enum»
        void set«ValueMapper.normalize(property.name.toFirstUpper)»(«namespaceOfDatatype»«(object.type as Enum).name.toFirstUpper» «ValueMapper.normalize(property.name)») {
            propertyChanged(« Utils.toUpperCaseWithUnderscore(property.name) », «ValueMapper.normalize(property.name)», this.«ValueMapper.normalize(property.name)», true);
            this.«ValueMapper.normalize(property.name)» = «ValueMapper.normalize(property.name)»;
        }
    «ENDIF»
«ENDIF»
        '''
    }

    protected def getNamespaceOfDatatype() {
        ''''''
    }
}