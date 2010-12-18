package xmpp;

//TODO move to xmpp.Packet or xmpp.Stream

class XMLUtil {
	
	/**
	*/
	public static function createElement( n : String, d : String ) : Xml {
		var x = Xml.createElement( n );
		x.addChild( Xml.createPCData( d ) );
		return x;
	}
	
}
