package org.eclipse.vorto.codegen.hagerfw.templates.connector

import org.eclipse.vorto.codegen.hagerfw.templates.Utils
import org.eclipse.vorto.core.api.model.informationmodel.InformationModel
import org.eclipse.vorto.plugin.generator.InvocationContext
import org.eclipse.vorto.plugin.generator.utils.IFileTemplate

class CloudConnectionHelperTemplate implements IFileTemplate<InformationModel> {

    override getFileName(InformationModel context) {
        '''CloudConnectionHelper.java'''
    }

    override getPath(InformationModel context) {
        '''«Utils.getJavaPackageBasePath(context)»'''
    }

    override getContent(InformationModel element, InvocationContext context) {
        '''
package «Utils.getJavaPackage(element)»;

import com.hg.osgi.fwk.cloud.cloudservice.api.constants.CloudConnectionStatusConstants;
import com.hg.osgi.fwk.cloud.cloudservice.api.constants.CloudEventsConstants;
import com.hg.osgi.fwk.cloud.cloudservice.api.exceptions.CloudConnectionException;
import com.hg.osgi.fwk.cloud.cloudservice.api.interfaces.*;
import com.hg.osgi.fwk.cloud.cloudservice.api.messages.PropertyMessage;
import com.hg.osgi.fwk.cloud.cloudservice.api.messages.TelemetryMessage;
import com.hg.osgi.fwk.cloud.cloudservice.api.serviceadmin.CloudConnectionManager;
import com.hg.osgi.fwk.cloud.cloudservice.azureiot.constants.AzureConnectionConstants;
import org.osgi.framework.BundleContext;
import org.osgi.framework.Filter;
import org.osgi.framework.InvalidSyntaxException;
import org.osgi.util.tracker.ServiceTracker;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.*;

/**
 * Internal helper to manage the cloud connection
 */
public class CloudConnectionHelper {

    private final Logger logger = LoggerFactory.getLogger(this.getClass());

    // cloud manager
    private CloudConnectionManager cloudManager;

    // bundle context
    private BundleContext bundleContext;

    // tracker of the cloud connection service, to manage the MQTT connection state
    private ServiceTracker<CloudConnection, CloudConnection> connectionTracker;

    // tracker of the cloud telemetry publisher service, that can send messages to the cloud
    private ServiceTracker<CloudTelemetryPublisher, CloudTelemetryPublisher> telemetryPublisherTracker;

    // tracker of the cloud property publisher service, that can send reported properties to the cloud
    private ServiceTracker<CloudPropertyPublisher, CloudPropertyPublisher> propertyPublisherTracker;

    // tracker of the cloud msg subscriber service, to receive C2D messages
    private ServiceTracker<CloudMessageSubscriber, CloudMessageSubscriber> c2dSubscriberTracker;

    // tracker of the cloud property subscriber service, that can monitor updates on properties from the cloud
    private ServiceTracker<CloudPropertySubscriber, CloudPropertySubscriber> propertySubscriberTracker;

    // tracker of the cloud operation subscriber service, that can monitor method calls from the cloud
    private ServiceTracker<CloudOperationSubscriber, CloudOperationSubscriber> operationSubscriberTracker;

    // connection properties
    private String iotHubAddress = null;
    private String deviceId = null;
    private String certPath = null;
    private String keyPath = null;

    // message callback to automatically subscribe at startup
    private CloudMessageCallback messageCallback;

    // operation callbacks to automatically subscribe at startup
    private Map<String, CloudOperationCallback> operationCallbackMap;

    // properties to automatically subscribe at startup
    private Set<String> properties;

    /**
     * Getter
     * @return deviceId
     */
    public String getDeviceId() {
        return deviceId;
    }

    /**
     * Constructor
     *
     * @param cloudManager manager service to create a connection
     * @param bc Bundle Context
     * @param messageCallback message callback instance to register when connecting
     * @param operationCallbacks operation callback instances to register when connecting
     * @param properties set of desired properties to register when connecting
     */
    public CloudConnectionHelper(CloudConnectionManager cloudManager,
                                 BundleContext bc,
                                 CloudMessageCallback messageCallback,
                                 Map<String, CloudOperationCallback> operationCallbacks,
                                 Set<String> properties) {
        this.cloudManager = cloudManager;
        this.bundleContext = bc;
        this.messageCallback = messageCallback;
        this.operationCallbackMap = operationCallbacks;
        this.properties = properties;
    }

    /**
     * verify that every property is not null
     *
     * @return true if all the properties have a value
     */
    private boolean isConfigCorrect() {
        return !isArgsIncorrect(iotHubAddress, deviceId, certPath, keyPath);
    }

    /**
     * tests if given arguments are null or empty
     * @param args arguments to test
     * @return true if one of the args is null or empty
     */
    private static boolean isArgsIncorrect(String... args) {
        for (String arg : args) {
            if (arg == null || "".equals(arg)) {
                return true;
            }
        }
        return false;
    }

    /**
     * Update the configuration.
     * When the configuration is changed, the previous cloud services are destroyed
     * by an automatic call to {@link #deleteConnection()}.
     * You shall then call {@link #createConnection()} manually to create the cloud connection with the new config.
     *
     * If the given properties are invalid, nothing is done.
     *
     */
    public void setConfig(String newIotHubAddress, String newDeviceId, String newCertPath, String newKeyPath) {
        // the new config is valid and different from the old one
        if (!isArgsIncorrect(newIotHubAddress, newDeviceId, newCertPath, newKeyPath)
                && !(newIotHubAddress.equals(iotHubAddress) && newDeviceId.equals(deviceId)
                && newCertPath.equals(certPath)&& newKeyPath.equals(keyPath))) {

            logger.debug("[CloudConnectionHelper][setConfig]> new config detected, changing the properties values");
            deleteConnection();

            iotHubAddress = newIotHubAddress;
            deviceId = newDeviceId;
            certPath = newCertPath;
            keyPath = newKeyPath;
        }
        logger.debug("[CloudConnectionHelper][setConfig]> Finished setConfig");
    }

    /**
     * Create a filter for the service tracker of given service
     *
     * @param className the name of the service class
     * @return the filter instance
     * @throws InvalidSyntaxException when given filter is incorrect
     */
    private Filter getServiceFilter(String className) throws InvalidSyntaxException {
        return bundleContext.createFilter(
                String.format("(&(objectClass=%s)(%s=%s))",
                        className, CloudEventsConstants.DEVICE_ID_PROPERTY, deviceId));
    }

    /**
     * init the service trackers
     *
     * @throws InvalidSyntaxException when an incorrect filter was given to the tracker
     */
    private void initTrackers() throws InvalidSyntaxException {
        Filter connectionFilter = getServiceFilter(CloudConnection.class.getName());
        Filter telemetryPublisherFilter = getServiceFilter(CloudTelemetryPublisher.class.getName());
        Filter c2dSubscriberFilter = getServiceFilter(CloudMessageSubscriber.class.getName());
        Filter propertyPublisherFilter = getServiceFilter(CloudPropertyPublisher.class.getName());
        Filter propertySubscriberFilter = getServiceFilter(CloudPropertySubscriber.class.getName());
        Filter operationSubscriberFilter = getServiceFilter(CloudOperationSubscriber.class.getName());
        connectionTracker =  new ServiceTracker<>(bundleContext, connectionFilter, null);
        telemetryPublisherTracker =  new ServiceTracker<>(bundleContext, telemetryPublisherFilter, null);
        c2dSubscriberTracker =  new ServiceTracker<>(bundleContext, c2dSubscriberFilter, null);
        propertyPublisherTracker = new ServiceTracker<>(bundleContext, propertyPublisherFilter, null);
        propertySubscriberTracker = new ServiceTracker<>(bundleContext, propertySubscriberFilter, null);
        operationSubscriberTracker = new ServiceTracker<>(bundleContext, operationSubscriberFilter, null);
        logger.debug("[CloudConnectionHelper][initTrackers]> Service trackers initialized with following filters : {}, {}, {}, {}, {}, {}",
                connectionFilter, telemetryPublisherFilter, c2dSubscriberFilter,
                propertyPublisherFilter, propertySubscriberFilter, operationSubscriberFilter);
    }

    /**
     * Open the trackers and wait a bit for a service to arrive.
     * This method supposes that the trackers are not null.
     *
     * @throws IllegalArgumentException if a tracker is null
     */
    private void openTrackers() {
        if (connectionTracker == null || telemetryPublisherTracker == null || c2dSubscriberTracker == null
        || propertyPublisherTracker == null || propertySubscriberTracker == null || operationSubscriberTracker == null) {
            throw new IllegalArgumentException("Opening null trackers");
        }

        connectionTracker.open();
        telemetryPublisherTracker.open();
        c2dSubscriberTracker.open();
        propertyPublisherTracker.open();
        propertySubscriberTracker.open();
        operationSubscriberTracker.open();
        logger.debug("[CloudConnectionHelper][openTrackers]> Service trackers opened");
    }

    /**
     * closes the running trackers
     */
    public void closeTrackers() {
        if (connectionTracker != null) {
            connectionTracker.close();
            connectionTracker = null;
        }
        if (telemetryPublisherTracker != null) {
            telemetryPublisherTracker.close();
            telemetryPublisherTracker = null;
        }
        if (c2dSubscriberTracker != null) {
            c2dSubscriberTracker.close();
            c2dSubscriberTracker = null;
        }
        if (propertyPublisherTracker != null) {
            propertyPublisherTracker.close();
            propertyPublisherTracker = null;
        }
        if (propertySubscriberTracker != null) {
            propertySubscriberTracker.close();
            propertySubscriberTracker = null;
        }
        if (operationSubscriberTracker != null) {
            operationSubscriberTracker.close();
            operationSubscriberTracker = null;
        }
        logger.debug("[CloudConnectionHelper][closeTrackers]> Service trackers closed");
    }

    /**
     * The state of the trackers monitoring the cloud services
     * @return true if a cloud connection service is tracked
     */
    public boolean isConnectionReady() {
        return connectionTracker != null && connectionTracker.getTrackingCount() > 0;
    }

    /**
     * format the properties for cloud service compatibility
     * @return the map of properties
     */
    private Map<String, Object> getFormattedConfig() {
        Map<String, Object> cloudProperties = new HashMap<>();

        cloudProperties.put(AzureConnectionConstants.PROTOCOL_PROPERTY, AzureConnectionConstants.MQTT);
        cloudProperties.put(AzureConnectionConstants.DEVICE_ID_PROPERTY, deviceId);
        cloudProperties.put(AzureConnectionConstants.IOT_HUB_ADDRESS_PROPERTY, iotHubAddress);
        cloudProperties.put(AzureConnectionConstants.CERTIFICATE_PATH_PROPERTY, certPath);
        cloudProperties.put(AzureConnectionConstants.PRIVATE_KEY_PATH_PROPERTY, keyPath);
        cloudProperties.put(AzureConnectionConstants.AUTOCONNECT_PROPERTY, false);
        cloudProperties.put(AzureConnectionConstants.CLOUD_MESSAGE_BUFFER_NAME_PROPERTY, "SimpleFIFOBuffer");
        cloudProperties.put(CloudEventsConstants.PROVIDER_PROPERTY, AzureConnectionConstants.AZURE_PROVIDER_NAME);

        return cloudProperties;
    }

    /**
     * Create a connection service with the cloud manager if we have a config.
     *
     * @throws CloudConnectionException if there was no configuration or an error occurred when trying to instantiate the service
     */
    public void createConnection() throws CloudConnectionException {
        if (!isConfigCorrect()) {
            throw new CloudConnectionException(
                    String.format(
                            "A property is missing in the following : iotHubAddress = %s," +
                                    " deviceId = %s, certPath = %s, keyPath = %s", iotHubAddress, deviceId, certPath, keyPath));
        }
        cloudManager.createCloudService(getFormattedConfig());

        try {
            initTrackers();
        } catch (InvalidSyntaxException e) {
            logger.error("[CloudConnectionHelper][createConnection]> Failed to instantiate the trackers.", e);
            throw new CloudConnectionException(String.format("Failed to instantiate the service trackers for deviceId %s", deviceId));
        }
        openTrackers();
        logger.info("[CloudConnectionHelper][createConnection]> " +
                        "Cloud service for device {} at address {} was successfully created.",
                deviceId, iotHubAddress);
    }

    /**
     * delete the running instance of cloud connection and stop the trackers
     */
    public void deleteConnection() {
        if (!isConfigCorrect()) {
            // nothing to delete
            logger.debug("[CloudConnectionHelper][deleteConnection]> Incorrect config, nothing to delete");
            return;
        }

        boolean deleted = cloudManager.deleteCloudService(getFormattedConfig());
        if (deleted) {
            closeTrackers();
            logger.info("[CloudConnectionHelper][deleteConnection]> Cloud service for device {} was successfully deleted", deviceId);
        } else {
            logger.error("[CloudConnectionHelper][deleteConnection]> Cloud service was not deleted.");
        }
    }

    /**
     * Returns the service connection state.
     *
     * @return connection state from {@link CloudConnectionStatusConstants}
     */
    public int getConnectionState() {
        if (connectionTracker == null) {
            return CloudConnectionStatusConstants.DISCONNECTED;
        }
        CloudConnection connection = connectionTracker.getService();
        if (connection == null) {
            return CloudConnectionStatusConstants.DISCONNECTED;
        }
        return connection.connectionState();
    }

    /**
     * Send the given message to the cloud
     *
     * @param message message to send
     * @param attributes message attributes
     * @return the message ID, or -1 if the message could not be sent
     */
    public int sendMessage(Object message, Map<String, String> attributes) {
        if (telemetryPublisherTracker == null) {
            return -1;
        }
        CloudTelemetryPublisher publisher = telemetryPublisherTracker.getService();
        if (publisher == null) {
            return -1;
        }

        TelemetryMessage msg = new TelemetryMessage(attributes, message);
        msg.setMID(UUID.randomUUID().hashCode());
        publisher.sendTelemetry(msg);

        logger.debug("[CloudConnectionHelper][sendMessage]> Message with UID {} " +
                "was forwarded to the cloud publisher service for {} to {}.", msg.getMID(), deviceId, iotHubAddress);

        return msg.getMID();
    }

    /**
     * Send reported properties to the cloud
     *
     * @param properties map of all the properties to send
     * @return the message ID if the properties were sent
     */
    public int sendProperty(Map<String, Object> properties) {
        if (propertyPublisherTracker == null || properties == null || properties.isEmpty()) {
            return -1;
        }

        CloudPropertyPublisher publisher = propertyPublisherTracker.getService();
        if (publisher == null) {
            return -1;
        }

        PropertyMessage props = new PropertyMessage(properties);
        props.setMID(UUID.randomUUID().hashCode());

        publisher.sendProperty(props);

        logger.debug("[CloudConnectionHelper][sendProperty]> Property message with UID {} " +
                "was forwarded to the cloud publisher service for {} to {}.", props.getMID(), deviceId, iotHubAddress);

        return props.getMID();
    }

    /**
     * Specify a new message callback to automatically register when connecting.
     * This method does not register the callback, you need to manually call {@link #subscribeToC2D()}
     * or reconnect to the cloud.
     *
     * @param messageCallback the new message callback
     */
    public void setMessageCallback(CloudMessageCallback messageCallback) {
        this.messageCallback = messageCallback;
    }

    /**
     * Subscribe the given callback as cloud message callback
     */
    public void subscribeToC2D() {
        if (c2dSubscriberTracker == null || messageCallback == null) {
            return;
        }
        CloudMessageSubscriber subscriber = c2dSubscriberTracker.getService();
        if (subscriber == null) {
            return;
        }

        subscriber.subscribeToMessages(messageCallback.getUUID());
        logger.debug("[CloudConnectionHelper][subscribeToC2D]> Callback {} was registered as cloud message callback",
                messageCallback.getUUID());
    }

    /**
     * Subscribe the operation callbacks
     */
    public void subscribeToOperations() {
        if (operationSubscriberTracker == null || operationCallbackMap == null || operationCallbackMap.isEmpty()) {
            return;
        }
        CloudOperationSubscriber subscriber = operationSubscriberTracker.getService();
        if (subscriber == null) {
            return;
        }

        for (Map.Entry<String, CloudOperationCallback> op : operationCallbackMap.entrySet()) {
            subscriber.subscribeToOperation(op.getKey(), op.getValue().getUUID());
            logger.debug(
                    "[CloudConnectionHelper][subscribeToOperations]> Callback {} was registered as cloud operation callback for method {}",
                    op.getValue().getUUID(), op.getKey());
        }
    }

    /**
     * Subscribe to desired properties
     */
    public void subscribeToProperties() {
        if (propertySubscriberTracker == null || properties == null || properties.isEmpty()) {
            return;
        }

        CloudPropertySubscriber subscriber = propertySubscriberTracker.getService();
        if (subscriber == null) {
            return;
        }

        subscriber.subscribeToProperty(new LinkedList<>(properties));
    }

    /**
     * Connect to the cloud
     *
     * @throws CloudConnectionException could not connect
     */
    public void connect() throws CloudConnectionException {
        if (connectionTracker == null) {
            throw new CloudConnectionException("No connection tracker, could not connect");
        }
        CloudConnection connection = connectionTracker.getService();
        if (connection == null){
            throw new CloudConnectionException("No connection service, could not connect");
        }

        // manually establish the connection
        connection.close();
        connection.connect();
        subscribeToC2D();
        subscribeToOperations();
        subscribeToProperties();
    }

    /**
     * disconnect from the cloud
     */
    public void disconnect() {
        if (connectionTracker == null) {
            // nothing to do
            return;
        }
        CloudConnection connection = connectionTracker.getService();
        if (connection == null){
            // nothing to do
            return;
        }
        connection.disconnect();
        logger.debug("[CloudConnectionHelper][disconnect]> disconnected from cloud");
    }
}
'''
    }

}