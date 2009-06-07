package xmpp.file;

class ByteStream {
	
	public static var XMLNS = xmpp.NS.PROTOCOL+"/bytestreams";
	
	public var sid : String;
	public var mode : String; //ByteStreamMode;
	public var streamhosts : Array<ByteStreamHost>;
	public var streamhost_used : String;
	public var activate : String;
	
	public function new( ?sid : String, ?mode : String = "tcp", ?streamhosts : Array<ByteStreamHost> ) {
		this.sid = sid;
		this.mode = mode;
		this.streamhosts = ( streamhosts != null ) ? streamhosts : new Array();
	}
	
	public function toXml() : Xml {
		var x = xmpp.IQ.createQueryXml( XMLNS );
		if( sid != null ) x.set( "sid", sid );
		if( mode != null ) x.set( "mode", mode );
		for( sh in streamhosts )
			x.addChild( sh.toXml() );
		if( streamhost_used != null ) {
			var e = Xml.createElement( "streamhost-used" );
			e.set( "jid", streamhost_used );
			x.addChild( e );
		}
		if( activate != null ) {
			var e = Xml.createElement( "activate" );
			e.set( "jid", activate );
			x.addChild( e );
		}
//		x.addChild( Xml.parse('<fast xmlns="http://affinix.com/jabber/stream"/>') );
		return x;
	}
	
	public static function parse( x : Xml ) : ByteStream {
		var b = new ByteStream();
		b.sid = x.get( "sid" );
		for( e in x.elements() ) {
			switch( e.nodeName ) {
			case "streamhost" : b.streamhosts.push( ByteStreamHost.parse( e ) );
			case "streamhost-used" :
				b.streamhost_used = e.get( "jid" );
				break;
			}
		}
		// TODO.....
		//..........
		return b;
	}
	
}
