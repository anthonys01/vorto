package org.eclipse.vorto.codegen.hagerfw.templates.model;

import org.eclipse.vorto.codegen.hagerfw.templates.Utils;
import org.eclipse.vorto.core.api.model.datatype.Enum;
import org.eclipse.vorto.core.api.model.informationmodel.InformationModel;
import org.eclipse.vorto.plugin.generator.utils.AbstractTemplateGeneratorTask;
import org.eclipse.vorto.plugin.generator.utils.ITemplate;
import org.eclipse.vorto.plugin.generator.utils.javatemplates.JavaEnumTemplate;

public class JavaEnumGeneratorTask extends AbstractTemplateGeneratorTask<Enum> {

    private String javaFileExtension = ".java";
    private InformationModel infomodel;

    public JavaEnumGeneratorTask(InformationModel infomodel) {
        this.infomodel = infomodel;
    }

    @Override
    public String getFileName(Enum entity) {
        return entity.getName() + javaFileExtension;
    }

    @Override
    public String getPath(Enum entity) {
        return Utils.getJavaPackageBasePath(this.infomodel) + "/model/datatypes";
    }

    @Override
    public ITemplate<Enum> getTemplate() {
        return new JavaEnumTemplate(Utils.getJavaPackage(this.infomodel) + ".model.datatypes");
    }
}
