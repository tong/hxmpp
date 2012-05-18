package jabber;

/**
	The info passed to the client aplication for attaching the BOSH connection.
*/
typedef BOSHPrebindInfo = {
	serviceUrl : String,
	jid : String,
	sid : String,
	rid : Int,
	wait : Int,
	hold : Int
}
