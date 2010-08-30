package tls.event;

extern class SecureSocketEvent extends flash.events.Event {
	var rawData : flash.utils.ByteArray;
	var text : String;
	function new(p0 : String, ?p1 : flash.utils.ByteArray) : Void;
	static var ON_BEFORE_PROCESSED_DATA : String;
	static var ON_CLOSE : String;
	static var ON_CONNECT : String;
	static var ON_ERROR : String;
	static var ON_PREPARE_TO_SEND : String;
	static var ON_PROCESSED_DATA : String;
	static var ON_SECURE_CHANNEL_ESTABLISHED : String;
	static var ON_SEND : String;
}
