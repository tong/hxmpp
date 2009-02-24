package jabber.file;

import jabber.core.PacketCollector;
import xmpp.IBB;


/**
	Incoming IBBytestream.
*/
class IBBStream {
	
	public var data(default,null) : String;
	public var blockSize(default,null) : Int;
	public var initiator(default,null) : String;
	public var seq(default,null) : Int;
	
	var listener : IBBListener;
	var coll_data_m : PacketCollector;
	var coll_data_iq : PacketCollector;
	var coll_close : PacketCollector;
	
	
	public function new( l : IBBListener ) {
		this.listener = l;
	}
	
	
	public function handleRequest( iq : xmpp.IQ ) {
		
		var r = xmpp.IBB.parse( iq.ext.toXml() );
		if( r.type == IBBType.open ) {
			
			data = "";
			initiator = iq.from;
			seq = 0;
			
			// collect message data packets
			var f_from : xmpp.PacketFilter = new xmpp.filter.PacketFromFilter( initiator );
			var f_msg : xmpp.PacketFilter = new  xmpp.filter.MessageFilter();
	//TODO	var f_ext : PacketFilter = new xmpp.filter.PacketExtensionFilter();
			coll_data_m = new PacketCollector( [ f_from, f_msg ], handleDataPacket, true );
			listener.stream.addCollector( coll_data_m );
			
			// collect iq data packets
			//TODO
			//coll_data_iq
			
			// collect stream close iq packets
			var f_iq : xmpp.PacketFilter = new xmpp.filter.IQFilter( xmpp.IBB.XMLNS, Type.enumConstructor( IBBType.close ), xmpp.IQType.set );
			coll_close = new PacketCollector( [f_iq], handleStreamClose );
			listener.stream.addCollector( coll_close );
			
			var r = new xmpp.IQ( xmpp.IQType.result, iq.id, iq.from, listener.stream.jid.toString() );
			listener.stream.sendData( r.toString() );
		}
	}
	

	function handleDataPacket( m : xmpp.Packet ) {
		var d = xmpp.IBB.parseData( m );
		if( seq != d.seq ) {
			trace("PACKET LOST");
			//TODO error message
			listener.onError( this );
			return;
		}
		seq++;
		data += d.data;
		//handleData( util.Base64.decode( d.data ) );
		//handleData( d.data );
	}
	
	function handleStreamClose( iq : xmpp.IQ ) {
		//TODO
		//stream.removeCollector();
		listener.onComplete( this );
		//dispose();
	}

}


/*
//?
enum ListeningMode {
	manual;
	acceptAll;
	rejectAll;
}
*/


/**
	Listens/Manages incoming IBB.
	
	<a href="http://xmpp.org/extensions/xep-0047.html">XEP-0047: In-Band Bytestreams (IBB)</a>
*/
class IBBListener {
	
	public dynamic function onRequest( s : IBBStream ) {}
	public dynamic function onComplete( s : IBBStream ) {}
	public dynamic function onError( s : IBBStream ) {}
	
	public var stream(default,null) : jabber.Stream;
	/** Current active IBB streams */
	public var streams(default,null) : Array<IBBStream>;
	
	public function new( stream : jabber.Stream ) {
	
		this.stream = stream;
		
		streams = new Array();
		
		var iqFilter : xmpp.PacketFilter= new xmpp.filter.IQFilter( xmpp.IBB.XMLNS, "open", xmpp.IQType.set );
		stream.addCollector( new jabber.core.PacketCollector( [ iqFilter ], handleRequest, true  ));
	}

	function handleRequest( iq : xmpp.IQ ) {
		switch( iq.type ) {
			case set :
				var ibb = new IBBStream( this );
				streams.push( ibb );
				ibb.handleRequest( iq );
			default : //#
		}
	}
	
}
