/**
* RabbitSender
*/
component{
	
	property name = "RabbitMQService" 		inject = "RabbitMQService";
	
	/**
	* index
	*/
	function index( event, rc, prc ){
		var domains = [
			"shiftinsert.nl","site4u.nl","ortussolutions.com","intothebox.org","coldbox.org","lekkermelig.nl"
		]

		prc.count = RandRange(3,10,"SHA1PRNG");
		for (var i=1; i<= prc.count; i++)  {
			var thisDomain = domains[randRange(1,domains.len(),"SHA1PRNG")];
			if ( randrange(0,1,"SHA1PRNG")) {
				rabbitMQService.archiveEmail(thisDomain)
			} else {
				rabbitMQService.enableDNSSec(thisDomain)
			}
		}
		event.setView( "RabbitSender/index" );
	}

	/**
	* doSend
	*/
	function doSend( event, rc, prc ){
		event.setView( "RabbitSender/doSend" );
	}
	
}
