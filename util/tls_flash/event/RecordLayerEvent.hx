package tls.event;

extern class RecordLayerEvent extends flash.events.Event {
	var data : flash.utils.ByteArray;
	var error : flash.Error;
	function new(p0 : String, p1 : flash.utils.ByteArray) : Void;
	static var ON_ERROR : String;
	static var ON_HANDSHAKE_FINISHED : String;
	static var ON_PROCESSED_RECIEVED_DATA : String;
	static var ON_PROCESSED_SEND_DATA : String;
}
