package xmpp.iq;



class VCard /*implements IPacketExtension*/ {
	
	public static inline var NODENAME 	= "vCard";
	public static inline var XMLNS 		= "vcard-temp";
	public static inline var PRODID 	= "-//HandGen//NONSGML vGen v1.0//EN";
	public static inline var VERSION 	= "2.0";
	
	
	public var fullName 		: String;
	public var nickName 		: String;
	public var firstName 		: String;
    public var lastName 		: String;
    public var middleName 		: String;
    public var title	 		: String;
    public var emailHome 		: String;
    public var emailWork 		: String;
    public var url 				: String;
    public var organization 	: String;
    public var organizationUnit : String;
    public var avatar 			: String;
//..


	public function new() {
	}
	
	
	public function toXml() : Xml {
		var xml = Xml.createElement( NODENAME );
		xml.set( "xmlns", XMLNS );
		if( fullName != null ) xml.addChild( xmpp.Packet.createXmlElement( "FN", fullName ) );
		//if( nickName != null ) xml.addChild( xmpp.Packet.createXmlElement( "NN", nickName ) );
		
		//............
		return xml;
	}
	
	public function toString() : String {
		return toXml().toString();
	}
	
	
	public static function parse( src : Xml ) : VCard  {
		
		var vc = new VCard();
		
		// TODO check
		
		var f = new haxe.xml.Fast( src );
		if( f.hasNode.FN ) vc.fullName = f.node.FN.innerData;
		if( f.hasNode.NICKNAME ) vc.fullName = f.node.NICKNAME.innerData;
		//...................
	
		return vc;
	}
}
