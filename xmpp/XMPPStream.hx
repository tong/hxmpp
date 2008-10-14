package xmpp;

import util.XmlUtil;


//TODO rename to Stream, check with php. (?)
class XMPPStream {
	
	public static var XMLNS_STREAM 		= "http://etherx.jabber.org/streams";
	public static var XMLNS_CLIENT 		= "jabber:client";
	public static var XMLNS_SERVER 		= "jabber:client";
	public static var XMLNS_COMPONENT 	= "jabber:component:accept";
	
	
//	public static function getStreamType( s : String )  {
//	}
	
	
	/**
	*/
	public static function createOpenStream( xmlns : String, to : String,
											 ?version : String, ?lang : String, ?xmlHeader : Bool = true ) : String {
		var buf = new StringBuf();
		buf.add( '<stream:stream xmlns="' );
		buf.add( xmlns );
		buf.add( '" xmlns:stream="http://etherx.jabber.org/streams" to="' );
		buf.add( to );
		buf.add( '"' );
		if( version != null ) {
			buf.add( ' version="' );
			buf.add( version );
			buf.add( '"' );
		}
		if( lang != null ) {
			buf.add( ' xml:lang="' );
			buf.add( lang );
			buf.add( '"' );
		}
		buf.add( '>' );
		return if( xmlHeader ) XmlUtil.XML_HEADER + buf.toString();
		else buf.toString();
	}
	
	
	/**
		Reflects the elememts of the xml into the packet.
		Use with care!
	*/
	public static function reflectPacketNodes<T>( x : Xml, p : T ) : T {
		for( e in x.elements() ) {
			var v : String = null;
			try { v = e.firstChild().nodeValue; } catch( e : Dynamic ) {};
			if( v != null ) {
				Reflect.setField( p, e.nodeName, v );
			}
		}
		return p;
	}
	
}
