package xmpp.file;

class ByteStreamHost {
	
	public var jid : String;
	public var host : String;
	public var zeroconf : String;
	public var port : Null<Int>;
	
	public function new( jid : String , host : String, ?port : Null<Int>, ?zeroconf : String ) {
		this.jid = jid;
		this.host = host;
		this.port = port;
		this.zeroconf = zeroconf;
	}
	
	public function toXml() : Xml {
		var x = Xml.createElement( "streamhost" );
		x.set( "jid", jid );
		x.set( "host", host );
		if( port != null ) x.set( "port", Std.string( port ) );
		if( zeroconf != null ) x.set( "zeroconf", zeroconf );
		return x;
	}
	
	public static function parse( x : Xml ) : ByteStreamHost {
		var port = x.get( "port" );
		var b = new ByteStreamHost( x.get( "jid" ), x.get( "host" ), if( port != null ) Std.parseInt( port ) else null, x.get( "zeroconf" ) );
		return b;
	}
	
}

