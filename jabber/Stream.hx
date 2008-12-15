package jabber;

import jabber.core.IPacketCollector;
import jabber.core.PacketInterceptor;
import jabber.core.PacketTimeout;


/**
	Represents the exchange of xmpp data to and from another jabber entity.
*/
interface Stream {
	
	dynamic function onOpen<T>( s : T ) : Void;
	dynamic function onClose<T>( s : T ) : Void;
	dynamic function onError<T>( s : T, m : Dynamic ) : Void;
	
	/**
	*/
	var jid(default,null) : jabber.JID;
	
	/**
	*/
	var features(default,null) : Array<String>;
	
	/**
		Indicates if the version attribute ("1.0") should be included in the opening xmpp packet.
	*/
	var version : Bool;
	
	/**
		Time value set by the application for syncing.
	*/
	//var time : Float;
	
	/**
	*/
	var status : StreamStatus;
	
	/**
	*/
	var connection(default,setConnection) : StreamConnection;
	
	/**
	*/
	var id(default,null) : String;
	
	/**
	*/
//	var collectors : List<IPacketCollector>;
	function addCollector( c : IPacketCollector ) : Bool;
	function addCollectors( iter : Iterable<IPacketCollector> ) : Bool;
	function removeCollector( c : IPacketCollector ) : Bool;
	function clearCollectors() : Void;
	
	
	/**
	*/
//	var interceptors : List<PacketInterceptor>;
	function addInterceptor( i : PacketInterceptor ) : Bool;
	function addInterceptors( iter : Iterable<PacketInterceptor> ) : Bool;
	function removeInterceptor( i : PacketInterceptor ) : Bool;
	function clearInterceptors() : Void;
	
	/**
	*/
	function open() : Bool;
	
	/**
	*/
	function close( ?disconnect : Bool = false ) : Bool;
	
	/**
	*/
	function sendPacket<T>( p : xmpp.Packet, ?intercept : Bool = false ) : T;
	
	/**
	*/
	function sendData( data : String ) : Bool;
	
	/**
	*/
	function sendIQ( iq : xmpp.IQ,
					 ?handler : xmpp.IQ->Void,
					 ?permanent : Bool,
					 ?timeout : PacketTimeout,
					 ?block : Bool )
	: { iq : xmpp.IQ, collector : IPacketCollector };
	
}
