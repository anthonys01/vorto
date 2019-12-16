package org.eclipse.vorto.codegen.hagerfw.templates;

import org.eclipse.vorto.core.api.model.informationmodel.InformationModel;

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
}
