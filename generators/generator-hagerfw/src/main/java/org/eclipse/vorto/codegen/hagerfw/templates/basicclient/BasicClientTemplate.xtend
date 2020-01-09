package org.eclipse.vorto.codegen.hagerfw.templates.basicclient

import org.eclipse.vorto.codegen.hagerfw.templates.Utils
import org.eclipse.vorto.core.api.model.informationmodel.InformationModel
import org.eclipse.vorto.plugin.generator.InvocationContext
import org.eclipse.vorto.plugin.generator.utils.IFileTemplate
import org.eclipse.vorto.plugin.generator.utils.javatemplates.ValueMapper

class BasicClientTemplate implements IFileTemplate<InformationModel> {

    override getFileName(InformationModel context) {
        '''BasicClient.java'''
    }

    override getPath(InformationModel context) {
        '''«Utils.getJavaPackageBasePath(context)»/client'''
    }

    override getContent(InformationModel element, InvocationContext context) {
        '''
		package «Utils.getJavaPackage(element)».client;

		import com.prosyst.mbs.services.fim.FunctionalItemEventConstants;
		import com.prosyst.mbs.services.fim.util.FunctionalItemEvent;
		import org.osgi.framework.BundleContext;
		import org.osgi.framework.ServiceRegistration;
		import org.osgi.service.component.annotations.*;
		import org.osgi.service.event.Event;
		import org.osgi.service.event.EventConstants;
		import org.osgi.service.event.EventHandler;
		«FOR fbProperty : element.properties»
		import «Utils.getJavaPackage(element)».model.I«fbProperty.type.name»FI;
		«ENDFOR»

		import java.util.*;
		«var dtNamespace = Utils.getJavaPackage(element) + ".model.datatypes."»

		@Component(immediate = true, service = {})
		public class BasicClient implements EventHandler {

		    private ServiceRegistration registration;
		    «FOR fbProperty : element.properties»

		    private I«fbProperty.type.name»FI «fbProperty.name»;

		    @Reference
		    public void set«fbProperty.name.toFirstUpper»(I«fbProperty.type.name»FI «fbProperty.name») {
		        this.«fbProperty.name» = «fbProperty.name»;
		    }
		    «ENDFOR»

		    @Override
		    public void handleEvent(Event event) {
		        FunctionalItemEvent fiEvent = new FunctionalItemEvent(event);

		        «FOR fbProperty : element.properties»
		        if ("«fbProperty.type.name»FI".equals(fiEvent.getUID())) {
		            switch (fiEvent.getPropertyChangedName()) {
		            «FOR property : fbProperty.type.functionblock.status.properties»
		                case "«property.name»":
		                    // your code here
		                    break;
		            «ENDFOR»
		            «FOR property : fbProperty.type.functionblock.configuration.properties»
		                case "«property.name»":
		                    // your code here
		                    break;
		            «ENDFOR»
		                default:
		                    // your code here
		            }
		        }
		        «ENDFOR»
		    }

		    @Activate
		    public void activate(BundleContext bc) {
		        Dictionary<String, Object> dict = new Hashtable<>();
		        dict.put(EventConstants.EVENT_TOPIC, FunctionalItemEventConstants.TOPIC_PROPERTY_CHANGED);

		        registration = bc.registerService(EventHandler.class, this, dict);
		    }

		    @Deactivate
		    public void deactivate() {
		        if (registration != null) {
		            registration.unregister();
		            registration = null;
		        }
		    }
		}
        '''
    }
}