package tls.valueobject;

extern class HandshakeMessageVO {
	var fragment : flash.utils.ByteArray;
	var type : UInt;
	function new() : Void;
	function getFullLength() : UInt;
	function getLength() : UInt;
	function toBytes() : flash.utils.ByteArray;
	static var TYPE_CERTIFICATE : UInt;
	static var TYPE_CERTIFICATE_REQUEST : UInt;
	static var TYPE_CERTIFICATE_VERIFY : UInt;
	static var TYPE_CLIENT_HELLO : UInt;
	static var TYPE_CLIENT_KEY_EXCHANGE : UInt;
	static var TYPE_FINISHED : UInt;
	static var TYPE_HELLO_REQUEST : UInt;
	static var TYPE_SERVER_HELLO : UInt;
	static var TYPE_SERVER_HELLO_DONE : UInt;
	static var TYPE_SERVER_KEY_EXCHANGE : UInt;
	static function createFromBytes(p0 : flash.utils.ByteArray, ?p1 : Int) : HandshakeMessageVO;
}
