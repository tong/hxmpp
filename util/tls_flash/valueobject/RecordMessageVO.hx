package tls.valueobject;

extern class RecordMessageVO {
	var contentType : UInt;
	var fragment : flash.utils.ByteArray;
	var version : ProtocolVersionVO;
	function new(?p0 : UInt, ?p1 : ProtocolVersionVO, ?p2 : flash.utils.ByteArray) : Void;
	function getFullLength() : Int;
	function getLength() : Int;
	function toBytes() : flash.utils.ByteArray;
	static var CONTENT_TYPE_ALERT : UInt;
	static var CONTENT_TYPE_APPLICATION_DATA : UInt;
	static var CONTENT_TYPE_CHANGE_CIPHER_SPEC : UInt;
	static var CONTENT_TYPE_HANDSHAKE : UInt;
	static function createFromBytes(p0 : flash.utils.ByteArray, ?p1 : Int) : RecordMessageVO;
}
