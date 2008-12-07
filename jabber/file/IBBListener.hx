package jabber.file;

import jabber.core.PacketCollector;
import xmpp.IBB;
import xmpp.filter.PacketFilter;

//?
/*
enum ListeningMode {
	manual;
	acceptAll;
	rejectAll;
}
*/


private class IncomingIBBStream {
	
	public var data(default,null) : String;
	public var blockSize(default,null) : Int;
	public var initiator(default,null) : String;
	public var seq(default,null) : Int;
	
	var listener : IBBListener;
	var coll_data_m : PacketCollector;
	var coll_data_iq : PacketCollector;
	var coll_close : PacketCollector;
	
	
	public function new( listener : IBBListener ) {
		this.listener = listener;
	}
	
	
	public function handleRequest( iq : xmpp.IQ ) {
		
		var r = xmpp.IBB.parse( iq.ext.toXml() );
		if( r.type == IBBType.open ) {
			
			data = "";
			initiator = iq.from;
			seq = 0;
			
			// collect message data packets
			var f_from : PacketFilter = new xmpp.filter.PacketFromFilter( initiator );
			var f_msg : PacketFilter = new  xmpp.filter.MessageFilter();
	//TODO	var f_ext : PacketFilter = new xmpp.filter.PacketExtensionFilter();
			coll_data_m = new PacketCollector( [ f_from, f_msg ], handleDataPacket, true );
			listener.stream.collectors.add( coll_data_m );
			
			// collect iq data packets
			//TODO
			//coll_data_iq
			
			// collect stream close iq packets
			var f_iq : PacketFilter = new xmpp.filter.IQFilter( xmpp.IBB.XMLNS, Type.enumConstructor( IBBType.close ), xmpp.IQType.set );
			coll_close = new PacketCollector( [f_iq], handleStreamClose );
			listener.stream.collectors.add( coll_close );
			
			var response = new xmpp.IQ( xmpp.IQType.result, iq.id, iq.from, listener.stream.jid.toString() );
			listener.stream.sendData( response.toString() );
		}
	}
	

	function handleDataPacket( m : xmpp.Packet ) {
		var d = xmpp.IBB.parseData( m );
		if( seq != d.seq ) {
			trace("PACKET LOST");
			//TODO error message
			listener.onError( this );
		}
		seq++;
		handleData( util.Base64.decode( d.data ) );
	}
	
	function handleStreamClose( iq : xmpp.IQ ) {
		//cleanup(); destroy();
		listener.onComplete( this );
	}
	
	function handleData( d : String ) {
		data += d;
	}
	
}


/**
	Listens for incoming IBB requests.
	
	<a href="http://xmpp.org/extensions/xep-0047.html">XEP-0047: In-Band Bytestreams (IBB)</a>
*/
class IBBListener {
	
	public dynamic function onRequest( ibs : IncomingIBBStream ) {}
	public dynamic function onComplete( ibs : IncomingIBBStream ) {}
	public dynamic function onError( ibs : IncomingIBBStream ) {}
	
	public var stream(default,null) : jabber.Stream;
	public var streams(default,null) : Array<IncomingIBBStream>;
	

	public function new( stream : jabber.Stream ) {
	
		this.stream = stream;
		
		streams = new Array();
		
		// listen for incoming ibb requests
		var iqFilter : xmpp.filter.PacketFilter= new xmpp.filter.IQFilter( xmpp.IBB.XMLNS, "open", xmpp.IQType.set );
		stream.collectors.add( new jabber.core.PacketCollector( [ iqFilter ], handleRequest, true  ));
	}


	function handleRequest( iq : xmpp.IQ ) {
		switch( iq.type ) {
			case set :
				var bs = new IncomingIBBStream( this );
				streams.push( bs );
				bs.handleRequest( iq );
				
			default : 
		}
	}
	
}
