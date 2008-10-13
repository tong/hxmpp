package jabber.core;


/**
*/
interface IPacketCollector {
	
	/**
	*/
	var filters : Array<xmpp.PacketFilter>;
	
	/**
		Methods to which collected packets get delivered.
	*/
	var handlers : Array<xmpp.Packet->Void>;
	
	/**
		Indicates if the the collector should get removed from the streams after successful collecting.
	*/
	var permanent : Bool;
	
	/**
		Blocks the remaining stream collectors.
	*/
	var block : Bool;
	
	/**
	*/
	var timeout(default,setTimeout) : PacketTimeout;
	
	/**
		Returns [true] if the given xmpp packet passes through all filters.
	*/
	function accept( packet : xmpp.Packet ) : Bool;
	
	/**
		Delivers the xmpp packet to registerd handlers.
	*/
	function deliver( packet : xmpp.Packet ) : Void;
	
}
