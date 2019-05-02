/**
* PollingConsumer
*/
component singleton accessors="true"{
	
	// Properties
	property name="RabbitMQ" 	inject="coldbox:setting:RabbitMQ"; 
	property name="InterceptorService"	inject="coldbox:interceptorService";
	property name = "logger" 			inject="logBox:logger:{this}";

	/**
	 * Constructor
	 */
	RabbitMQPollingConsumer function init(){
		return this;
	}

	function run() {
		try {
			var Channel = application.RabbitMQConnection.createChannel();
			// create a topic exchange if it is not there yet
			channel.exchangeDeclare( RabbitMQ.Exchange, "topic", javaCast( "boolean", true ));
			//declare the queue
			channel.queueDeclare(RabbitMQ.EventsQueue, javaCast( "boolean", true ), javaCast( "boolean", false ), javaCast( "boolean", false ), javaCast( "null", "" ));
			// create binding
			channel.queueBind(RabbitMQ.EventsQueue, RabbitMQ.Exchange, RabbitMQ.BindKey);
			
			// retrieve messages
			var Response = channel.basicGet( RabbitMQ.EventsQueue, javaCast( "boolean", false ) );
			logger.info("checking #RabbitMQ.EventsQueue# queue");
			while ( !isNull(response) ) {
				try {
					var myMessage = {
						CorrelationId = response.getProps().getCorrelationId(),
						props = response.getProps(), 
						Headers = response.getProps().getHeaders(),
						Body = tostring( response.getBody() ),
						RoutingKey = response.getEnvelope().getRoutingKey()
					}
					logger.info( "Rabbit Message #myMessage.CorrelationId# processed");
					InterceptorService.processState('onRabbitMQMessageReceived', myMessage);
				} catch (any e) {
						logger.error("failed rabbit message", myMessage);
						logger.error("#e.message# message", e);
				} finally {
						//acknowledge
						Channel.basicAck( response.getEnvelope().getDeliveryTag() , javaCast( "boolean", false ) );	
				}
				// get next one in the loop
				Response = channel.basicGet( RabbitMQ.EventsQueue, javaCast( "boolean", false ) );
			}
		} catch (any e) {
			logger.error("#e.message# message", e);	
			rethrow; //CF9+
		} finally { //CF9+
			channel.close();
		}		
	}
}