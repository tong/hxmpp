package jabber;

import jabber.JID;
import jabber.util.Base64;
import xmpp.XMLUtil;

/**
	Prebinds an XMPP client account to a BOSH connection.
	Be aware! Uses plain text SASL login!
*/
class BOSHPrebindAccount extends BOSHPrebind {

	public var jid(default,null) : String;
	public var password(default,null) : String;

	public function new( serviceUrl : String, jid : String, password : String,
						 wait : Int = 30, hold : Int = 1 ) {
		super( serviceUrl, wait, hold );
		this.jid = jid;
		this.password = password;
	}
	
	override function createAuthText() : Xml {
		var j = new JID( jid );
		var sasl = new jabber.sasl.PlainMechanism();
		var t = sasl.createAuthenticationText( j.node, j.domain, password, j.resource );
		var x = XMLUtil.createElement( 'auth', Base64.encode( t ) );
		x.set( 'xmlns', 'urn:ietf:params:xml:ns:xmpp-sasl' );
		x.set( 'mechanism', 'PLAIN' );
		return x;
	}

}
