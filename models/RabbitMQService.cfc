/**
* I am a new Model Object
*/
component accessors="true"{
	
	// Properties
	property name = "logger" 		inject = "logBox:logger:{this}";
	property name="InterceptorService"	inject="coldbox:interceptorService";
	property name="RabbitMQ" 	inject="coldbox:setting:RabbitMQ"; 
	property name="RabbitMQPropertiesBuilder" inject="RabbitMQPropertiesBuilder";

	/**
	 * Constructor
	 */
	RabbitMQService function init(){
		
		return this;
	}
	
	function archiveEmail( required domainName) {
		_sendCommand("email", "archive", { "domainname" = domainName}, "domain", domainName);			
	}
	function getMailboxSizesForDomain( required domainName) {
		_sendCommand("email", "getMailBoxSizes", { "domainname" = domainName}, "domain", domainName);			
	}

	function enableDNSSec( required domainName) {
		_sendCommand("dnssec", "registerAtXyz", { "domainname" = domainName}, "domain", domainName);			
	}

	private function _sendCommand ( 
			required string Service,
			required string Action,
			required struct RabbitMessage, 
			required string ItemType,
			required string ItemValue,
			required string CorrelationId = createUUID(),
		) 
	{
		Var DELIVERY_PERSISTENT = 2;
		var CONTENT_TYPE = "application/json"; 
		var REQUEST_STATUS_PENDING = 2;
		var Routingkey = "cfdemo." & service & ".cmd";
	
		// try finally, so you are closing the channel when done
		try {
			var Channel = application.RabbitMQConnection.createChannel();
			// Topic exchange, queue and bindings should be present, else the message disappears.
			// this should be configured by the consumer or on the server.
		
			// make properties
			var myHeaders = { 'action' =  arguments.action };
			var props = RabbitMQPropertiesBuilder
				.correlationId( arguments.CorrelationId )
				.contentType( CONTENT_TYPE )
				.deliveryMode( DELIVERY_PERSISTENT )
				.headers(myHeaders)
				.build();
			// convert message to JSON and send to Rabbit Broker
			var myMessage = serializeJSON( { 'params' = arguments.RabbitMessage} );
			channel.basicPublish(RabbitMQ.Exchange, Routingkey, props, createByteArray( myMessage ) );

			// usuallly we log to a table with transactions, so we can update items if a reply is received
			// unique correlationId comes in handy here
			// now we are just using logbox
			logger.info("RabbitMQ message to #routingkey# for #Service# sent", arguments);
			
			var MyLogMessage = { props=props, headers=myHeaders,  message= { 'params' = myMessage } };
			InterceptorService.processState('onRabbitMQMessageSent', myLogMessage);

		} catch ( any e) {
			logger.fatal(e.message,arguments)
		} finally {
			channel.close();
		}

	}

	private function createByteArray(string){
		var objString = createObject("Java", "java.lang.String").init(JavaCast("string", string));
		return objString.getBytes();
	}




}