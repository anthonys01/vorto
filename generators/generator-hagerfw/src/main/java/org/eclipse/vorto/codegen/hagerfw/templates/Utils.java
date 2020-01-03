package org.eclipse.vorto.codegen.hagerfw.templates;

import org.eclipse.vorto.core.api.model.datatype.*;
import org.eclipse.vorto.core.api.model.informationmodel.InformationModel;
import org.eclipse.vorto.plugin.generator.utils.javatemplates.ValueMapper;

import java.util.*;

public class Utils {

    private static final Map<String, String> primitiveToObject;

    static {
        Map<String, String> aMap = new HashMap<>();
        aMap.put("boolean", "Boolean");
        aMap.put("byte", "Byte");
        aMap.put("char", "Character");
        aMap.put("double", "Double");
        aMap.put("float", "Float");
        aMap.put("int", "Integer");
        aMap.put("long", "Long");
        aMap.put("short", "Short");
        primitiveToObject = Collections.unmodifiableMap(aMap);
    }


    public static String getJavaOSGiBundleBasePath(InformationModel context) {
        return getBasePath(context)+"/src/" + getJavaPackage(context);
    }

    public static String getJavaPackageBasePath(InformationModel context) {
       return getJavaOSGiBundleBasePath(context) + "/src/main/java/com/hg/osgi/vorto/" + context.getName().toLowerCase();
    }

    public static String getJavaPackage(InformationModel context) {
        return "com.hg.osgi.vorto." + context.getName().toLowerCase();
    }

    public static String getBasePath(InformationModel context) {
        return "/" + context.getName().toLowerCase();
    }

    public static Set<Property> getPropertySet(Entity entity) {
        Set<Property> pptSet = new HashSet<>();
        Set<String> pptNameSet = new HashSet<>();
        for (Property property : entity.getProperties()) {
            if (!pptNameSet.contains(property.getName())){
                pptSet.add(property);
                pptNameSet.add(property.getName());
            }
        }
        return pptSet;
    }

    public static String getPropertyTypeName(Property property, String dataTypeNamespace) {
        PropertyType propertyType = property.getType();
        if (propertyType instanceof PrimitivePropertyType) {
            String typeName = ValueMapper.mapSimpleDatatype(((PrimitivePropertyType)propertyType).getType());
            return primitiveToObject.getOrDefault(typeName, typeName);
        } else if (propertyType instanceof  ObjectPropertyType) {
            ObjectPropertyType object = (ObjectPropertyType) propertyType;
            return dataTypeNamespace + object.getType().getName();
        }
        return null;
    }

    public static String toUpperCaseWithUnderscore(String input) {
        if(input == null) {
            throw new IllegalArgumentException();
        }

        StringBuilder sb = new StringBuilder();
        for(int i = 0; i < input.length(); i++) {
            char c = input.charAt(i);
            if(Character.isUpperCase(c)) {
                if(i > 0) {
                    sb.append('_');
                }
                sb.append(c);
            } else {
                sb.append(Character.toUpperCase(c));
            }
        }

        return sb.toString();
    }
}
