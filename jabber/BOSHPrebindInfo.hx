package jabber;

/**
	The info passed to the client aplication for attaching the BOSH connection.
*/
typedef BOSHPrebindInfo = {
	
	/**
		The URI of the HTTP/BOSH service
	*/
	var serviceUrl : String;
	
	/**
		The full JID prebound 
	*/
	var jid : String;
	
	/**
		The SID of the BOSH prebound session
	*/
	var sid : String;
	
	/**
		The RID of the BOSH prebound session
	*/
	var rid : Int;
	
	/**
		The 'wait' value of the BOSH session
	*/
	var wait : Int;
	
	/**
		The 'hold' value of the BOSH session
	*/
	var hold : Int;
}
