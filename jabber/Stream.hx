package jabber;

import jabber.core.TPacketCollector;
import jabber.core.TPacketInterceptor;
import jabber.core.PacketTimeout;


typedef Server = {
	//var domain : String;
	var features(default,null) : Hash<Xml>;
}


/*
typedef StreamFeature = {
	var streamFeatureName(default,null) : String;
}
*/

//TODO Hash map
class StreamFeatures {
	
	var list : List<String>; // TODO var features : Hash<StreamFeature>;
	
	public function new() {
		list = new List();
	}
	
	public function iterator() {
		return list.iterator();
	}
	
	public function add( f : String ) : Bool {
		if( Lambda.has( list, f ) ) return false;
		list.add( f );
		return true;
	}
}


/**
*/
interface Stream {
	
	dynamic function onOpen() : Void;
	dynamic function onClose() : Void;
	dynamic function onError( ?e : Dynamic ) : Void;
	
	/** */
	var status : StreamStatus;
	
	/** */
	var cnx(default,setConnection) : StreamConnection;
	
	/** */
	var features(default,null) : StreamFeatures;
	
	/** */
	var server(default,null) : Server;
	
	/** */
	var jid(default,null) : jabber.JID;
	
	/** */
	function nextID() : String;
	
	function open() : Bool {}
	
	/** */
	function sendIQ( iq : xmpp.IQ,
					 ?handler : xmpp.IQ->Void,
					 ?permanent : Bool,
					 ?timeout : PacketTimeout,
					 ?block : Bool ) : { iq : xmpp.IQ, collector : TPacketCollector };
	
	
	/** Sends XMPP packet */
	function sendPacket<T>( p : xmpp.Packet, ?intercept : Bool = true ) : T;
	
	/** Sends raw data */
	function sendData( d : String ) : Bool;
	
	function addCollector( c : TPacketCollector ) : Bool;
	function addCollectors( iter : Iterable<TPacketCollector> ) : Bool;
	function removeCollector( c : TPacketCollector ) : Bool;
	function clearCollectors() : Void;
	function addInterceptor(i : TPacketInterceptor ) : Bool;
	function addInterceptors( iter : Iterable<TPacketInterceptor> ) : Bool;
	function removeInterceptor( i : TPacketInterceptor ) : Bool;
	function clearInterceptors() : Void;
	
}
