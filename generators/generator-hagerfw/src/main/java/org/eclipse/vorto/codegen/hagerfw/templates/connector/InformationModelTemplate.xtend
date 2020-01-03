package org.eclipse.vorto.codegen.hagerfw.templates.connector

import org.eclipse.vorto.codegen.hagerfw.templates.Utils
import org.eclipse.vorto.core.api.model.informationmodel.InformationModel
import org.eclipse.vorto.plugin.generator.InvocationContext
import org.eclipse.vorto.plugin.generator.utils.IFileTemplate
import org.eclipse.vorto.plugin.generator.utils.javatemplates.ValueMapper

class InformationModelTemplate implements IFileTemplate<InformationModel> {

    override getFileName(InformationModel context) {
        '''«context.name»App.java'''
    }

    override getPath(InformationModel context) {
        '''«Utils.getJavaPackageBasePath(context)»'''
    }

    override getContent(InformationModel element, InvocationContext context) {
        '''
package «Utils.getJavaPackage(element)»;

import com.google.gson.Gson;
import com.hg.osgi.fwk.cloud.cloudservice.api.constants.CloudEventsConstants;
import com.hg.osgi.fwk.cloud.cloudservice.api.constants.CloudOperationStatusConstants;
import com.hg.osgi.fwk.cloud.cloudservice.api.exceptions.CloudConnectionException;
import com.hg.osgi.fwk.cloud.cloudservice.api.interfaces.CloudOperationCallback;
import com.hg.osgi.fwk.cloud.cloudservice.api.messages.AbstractCloudMessage;
import com.hg.osgi.fwk.cloud.cloudservice.api.messages.OperationStatusMessage;
import com.hg.osgi.fwk.cloud.cloudservice.api.serviceadmin.CloudConnectionManager;
import org.osgi.framework.BundleContext;
import org.osgi.framework.ServiceRegistration;
import org.osgi.service.component.annotations.*;
import org.osgi.service.event.Event;
import org.osgi.service.event.EventConstants;
import org.osgi.service.event.EventHandler;
import org.osgi.service.metatype.annotations.Designate;
«FOR fbProperty : element.properties»
import «Utils.getJavaPackage(element)».model.«fbProperty.type.name»;
«ENDFOR»

import java.util.*;
«var dtNamespace = Utils.getJavaPackage(element) + ".model.datatypes."»

@Component(immediate = true, configurationPolicy = ConfigurationPolicy.REQUIRE)
@Designate(ocd = CloudConnectionConfig.class)
public class «element.name»App implements EventHandler, CloudOperationCallback {

    private final UUID uuid = UUID.randomUUID();

    private CloudConnectionManager cloudManager;
    private CloudConnectionHelper cloudHelper;

    private ServiceRegistration registration;

	«FOR fbProperty : element.properties»
	private «fbProperty.type.name» «fbProperty.name» = new «fbProperty.type.name»();
	«ENDFOR»

    @Reference
    public void setCloudManager(CloudConnectionManager cloudManager) {
        this.cloudManager = cloudManager;
    }

    @Activate
    public void activate(BundleContext context, «element.name»AppConfig config) throws CloudConnectionException {
        if (config == null) {
            return;
        }

        // register OSGi services (event handler and cloud operation callback)
        Dictionary<String, Object> dict = new Hashtable<>();
        dict.put(EventConstants.EVENT_TOPIC, CloudEventsConstants.PROPERTY_UPDATE_EVENT);
        registration = context.registerService(
                new String[]{EventHandler.class.getName(), CloudOperationCallback.class.getName()},
                this, dict);

        // create cloud helper
        Map<String, CloudOperationCallback> callbackMap = new HashMap<>();
        // function blocks operations
        «FOR fbProperty : element.properties»
            «FOR operation : fbProperty.type.functionblock.operations»
            callbackMap.put("«operation.name»", this);
            «ENDFOR»
        «ENDFOR»

        Set<String> configs = new HashSet<>();
        «FOR fbProperty : element.properties»
        configs.addAll(«fbProperty.name».getConfigurationProperties().keySet());
        «ENDFOR»
        cloudHelper = new CloudConnectionHelper(cloudManager, context, null, callbackMap, configs);

        update(context, config);
    }

    @Modified
    public void update(BundleContext context, «element.name»AppConfig config) throws CloudConnectionException {
        if (config == null) {
            return;
        }

        // set config
        cloudHelper.setConfig(config.iotHubAddress(), config.deviceId(), config.certPath(), config.keyPath());

        // establish the connection to the cloud
        cloudHelper.createConnection();
        cloudHelper.connect();

        // send status
        «FOR fbProperty : element.properties»
        cloudHelper.sendProperty(«fbProperty.name».getStatusProperties());
        «ENDFOR»
    }

    @Deactivate
    public void deactivate() {
        if (registration != null) {
            registration.unregister();
            registration = null;
        }
    }

    @Override
    public UUID getUUID() {
        return uuid;
    }

    @Override
    public AbstractCloudMessage handleOperationCall(String operationName, String payload) {
        if (operationName == null) {
            return new OperationStatusMessage("null", CloudOperationStatusConstants.METHOD_NOT_DEFINED, null);
        }

        Gson gson = new Gson();
        Object resultPayload = null;
        switch (operationName) {
            «FOR fbProperty : element.properties»
                «FOR operation : fbProperty.type.functionblock.operations»
                case "«operation.name»":
                    // call your method here
                    break;
                «ENDFOR»
            «ENDFOR»
            default:
                return new OperationStatusMessage(operationName, CloudOperationStatusConstants.METHOD_NOT_DEFINED, null);
        }

        return new OperationStatusMessage(operationName, CloudOperationStatusConstants.METHOD_SUCCESS, resultPayload);
    }

    @Override
    public void handleEvent(Event event) {
        // property update event
        String propertyName = (String) event.getProperty(CloudEventsConstants.PROPERTY_NAME_PROPERTY);
        Object propertyValue = event.getProperty(CloudEventsConstants.NEW_VALUE_PROPERTY);
        Gson gson = new Gson();

        // receive configuration
        switch (propertyName) {
            «FOR fbProperty : element.properties»
                «FOR property : fbProperty.type.functionblock.configuration.properties»
                case "«property.name»":
                    «fbProperty.name».set«property.name.toFirstUpper»(gson.fromJson(propertyValue.toString(), «Utils.getPropertyTypeName(property,dtNamespace)».class));
                    break;
                «ENDFOR»
            «ENDFOR»
            default:
                break;
        }
    }

    «FOR fbProperty : element.properties»
        «FOR event : fbProperty.type.functionblock.events»
        public void «event.name»Event() {
            Gson gson = new Gson();

            «FOR property : event.properties»
            «Utils.getPropertyTypeName(property,dtNamespace)» «property.name» = null;
            «ENDFOR»

            // your code here

            Map<String, Object> event = new HashMap<>();
            «FOR property : event.properties»
            event.put("«property.name»", «property.name»);
            «ENDFOR»

            cloudHelper.sendMessage(gson.toJson(event), null);
        }
        «ENDFOR»
    «ENDFOR»
}
'''
    }

}