package org.eclipse.vorto.codegen.hagerfw.templates;

import org.eclipse.vorto.core.api.model.datatype.Entity;
import org.eclipse.vorto.core.api.model.datatype.Property;
import org.eclipse.vorto.core.api.model.informationmodel.InformationModel;

import java.util.HashSet;
import java.util.Set;

public class Utils {

    public static String getJavaPackageBasePath(InformationModel context) {
        return getBasePath(context)+"/src/com/hg/osgi/fwk/vorto/" + context.getName().toLowerCase();
    }

    public static String getJavaPackage(InformationModel context) {
        return "org.eclipse.vorto.hagerfw." + context.getName().toLowerCase();
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
}
