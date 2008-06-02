package jabber;


interface IPacketCollector {
	
	/**
	*/
	var filters : Array<Dynamic>;
	
	/**
		Methods to which collected packets get delivered.
	*/
	var handlers : Array<xmpp.Packet->Void>;
	
	/**
		Indicates if the the collector should get removed from the streams
		collectors on successful collecting.
	*/
	var permanent : Bool;
	
	/**
		Blocks the remaining stream collectors.
	*/
	var block : Bool;
	
	//var timeout
	
	/**
	*/
	//var timeoutHandlers : List<IPacketCollector->Void>;
	
	/**
		Returns [true] if the given xmpp packet passes through all filters.
	*/
	function accept( packet : xmpp.Packet ) : Bool;
	
	/**
		Delivers the xmpp packet to registerd handlers.
	*/
	function deliver( packet : xmpp.Packet ) : Void;
	
	/**
	*/
	var timeout : PacketTimeout;
}
