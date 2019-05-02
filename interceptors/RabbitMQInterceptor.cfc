/**
* I am a new interceptor
*/
component{
	
	property name = "logger" 			inject="logBox:logger:{this}";

	void function configure(){
	
	}
	
	void function onRabbitMQMessageReceived( event, interceptData, buffer, rc, prc ){
		logger.info("Interceptor: RabbitMQ message received #interceptData.props.correlationID#", interceptData) 
		
		// we can store sent messages in a database, using correlationID as key
	}


	void function onRabbitMQMessageSent( event, interceptData, buffer, rc, prc ){
		logger.info("Interceptor: RabbitMQ message sent #interceptData.props.correlationID#", interceptData)

		// for further processing we can check if received message is indeed a response to a previous command
		// by checking correlation id.

		//if this matches we can process the reply
				// by reannouncing an interception based on routingkey, so all services are handled in their own interceptor
				
				// OR just handle everything here.

	}



	
}

