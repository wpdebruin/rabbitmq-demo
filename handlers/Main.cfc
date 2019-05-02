component extends="coldbox.system.EventHandler"{

	property name = "logger" 		inject = "logBox:logger:{this}";
	property name = "RabbitMQ" 	inject = "coldbox:setting:RabbitMQ"; 
	property name= "myScheduler" inject = "CfConcurrentScheduler";

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

			//we also have to declare a consumer
			// we use polling, and we schedule it with cfconcurrent
			myScheduler.setLoggingEnabled(true);
			myScheduler.start();
			//scheduler added, now add a recurring task every 2 seconds
			myScheduler.scheduleWithFixedDelay(
				"RabbitMQPollingConsumerTask",
				getInstance("RabbitMQPollingConsumer"),
				0, 2,	myScheduler.getObjectFactory().SECONDS
			)
			logger.info("RabbitMQ pull scheduler activated")

			// rabbit pull met createDynamicProxy still has to be tested
//			application.Channel = application.RabbitMQConnection.createChannel();
//			application.channel.queueDeclare(RabbitMQ.EventsQueue, javaCast( "boolean", true ), javaCast( "boolean", false ), javaCast( "boolean", false ), javaCast( "null", "" ));
			// bind queue to exchange
//			application.channel.queueBind(RabbitMQ.EventsQueue, RabbitMQ.Exchange, RabbitMQ.BindKey);
			//consumer = new models.RabbitConsumer(application.channel);
//			consumerTask = createDynamicProxy(new models.RabbitConsumer(application.channel),[ "com.rabbitmq.client.Consumer" ]);	
			// Consume Stream API
//			consumerTag = application.channel.basicConsume( "cfdemo-responses", javaCast( "boolean", false ), consumerTask );
		}
	}
	private function createByteArray(string){
		var objString = createObject("Java", "java.lang.String").init(JavaCast("string", string));
		return objString.getBytes();
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