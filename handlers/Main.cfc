component extends="coldbox.system.EventHandler"{

	property name = "logger" 		inject = "logBox:logger:{this}";
	property name = "RabbitMQ" 	inject = "coldbox:setting:RabbitMQ"; 

	// Default Action
	function index(event,rc,prc){
		prc.welcomeMessage = "Welcome to ColdBox!";
		event.setView("main/index");
	}

	// Do something
	function doSomething(event,rc,prc){
		relocate( "main.index" );
	}

	/************************************** IMPLICIT ACTIONS *********************************************/

	function onAppInit(event,rc,prc){

		if ( not StructKeyExists( application, "RabbitMQConnection" ) ) {
			var rabbitMQFactory = getInstance("RabbitMQFactory"); 
			rabbitMQFactory.setHost( RabbitMQ.Host );
			rabbitMQFactory.setUserName( RabbitMQ.User );
			rabbitMQFactory.setPassword( RabbitMQ.Password );
			rabbitMQFactory.setVirtualHost( RabbitMQ.VHost );
//			rabbitMQFactory.useSslProtocol(); //always do this in production
			//this is all we need for a rabbitMQ connection
			application.RabbitMQConnection = rabbitMQFactory.newConnection();
			logger.info("rabbitmq connection created");
		}
	}

	function onRequestStart(event,rc,prc){

	}

	function onRequestEnd(event,rc,prc){

	}

	function onSessionStart(event,rc,prc){

	}

	function onSessionEnd(event,rc,prc){
		var sessionScope = event.getValue("sessionReference");
		var applicationScope = event.getValue("applicationReference");
	}

	function onException(event,rc,prc){
		event.setHTTPHeader( statusCode = 500 );
		//Grab Exception From private request collection, placed by ColdBox Exception Handling
		var exception = prc.exception;
		//Place exception handler below:
	}

}