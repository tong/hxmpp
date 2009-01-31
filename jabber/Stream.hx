package jabber;

import jabber.core.TPacketCollector;
import jabber.core.TPacketInterceptor;
//import jabber.core.PacketCollector;
//import xmpp.filter.PacketIDFilter;
import jabber.core.PacketTimeout;
//import util.XmlUtil;


typedef Server = {
	//var domain : String;
	var features(default,null) : Hash<Xml>;
}


interface Stream {
	
	dynamic function onOpen<T>( s : T ) : Void;
	dynamic function onClose<T>( s : T ) : Void;
	dynamic function onError<T>( s : T, ?m : Dynamic ) : Void;
	
	/** */
	var status : StreamStatus;
	
	/** */
	var features(default,null) : Array<String>;
	
	/** */
	function nextID() : String;
	
	/** */
	function sendIQ( iq : xmpp.IQ,
					 ?handler : xmpp.IQ->Void,
					 ?permanent : Bool,
					 ?timeout : PacketTimeout,
					 ?block : Bool ) : { iq : xmpp.IQ, collector : TPacketCollector };
	
	/** Sends xmpp packet */
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
