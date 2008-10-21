package jabber;

import jabber.core.StreamBase;
import jabber.core.PacketCollector;

// TODO


typedef CompressionMethod = {
	var name : String;
	function compress( data : String ) : String;
	function uncompress( data : String ) : String;
}


/**
	<a href="http://www.xmpp.org/extensions/xep-0138.html">XEP-0138: Stream Compression</a>
*/
class StreamCompression {
	
	public static var XMLNS = 'http://jabber.org/protocol/compress';
	
	public var stream(default,null) : StreamBase;
	public var method(default,null) : CompressionMethod;

	
	public function new( stream : StreamBase ) {
		this.stream = stream;
	}
	
	
	/**
	*/
	public function request( method : CompressionMethod ) {
		this.method = method;
		//TODO add attibute filter
		stream.collectors.add( new PacketCollector( [ cast new xmpp.filter.PacketNameFilter( ~/compressed/ ) ], compressionInitSuccessHandler, false ) );
		//stream.collectors.add( new PacketCollector( [ cast new xmpp.filter.PacketNameFilter( "failure" ) ], compressionInitFailedHandler, false ) );
		stream.sendData( '<compress xmlns="'+XMLNS+'"><method>'+method.name+'</method></compress>' );
	}
	
	/**
	*/
	public function interceptData( d : String ) : String {
		return method.compress( d );
	}
	
	/**
	*/
	public function filterData( d : String ) : String {
		return method.uncompress( d );
	}
	
	
	function compressionInitSuccessHandler( p ) {
		stream.connection.interceptors.push( this );
		stream.connection.filters.push( this );
		stream.status = jabber.StreamStatus.closed;
		stream.version = null;
		stream.open();
	}
	
}
