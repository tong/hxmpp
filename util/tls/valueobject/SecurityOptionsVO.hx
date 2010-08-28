package tls.valueobject;

extern class SecurityOptionsVO {
	var cipher : Int;
	var compression : Int;
	var securityType : Int;
	function new(p0 : Int, p1 : Int, p2 : Int) : Void;
	function getCipherBytes() : flash.utils.ByteArray;
	function getCipherExportable() : Bool;
	function getCipherExtendedSize() : Int;
	function getCipherHashSize() : Int;
	function getCipherIVSize() : Int;
	function getCipherKeySize() : Int;
	function getCipherMacHashSize() : Int;
	function getCompressionBytes() : flash.utils.ByteArray;
	function setCipher(p0 : flash.utils.ByteArray) : Void;
	function setCompression(p0 : flash.utils.ByteArray) : Void;
	static var CIPHER_ALGORITHM_RSA_WITH_DES_CBC_SHA : Int;
	static var CIPHER_ALGORITHUM_NONE : Int;
	static var COMPRESSION_NONE : Int;
	static var SECURITY_TYPE_SSL3 : Int;
	static var SECURITY_TYPE_TLS : Int;
	static function getDefaultOptions(?p0 : Int) : SecurityOptionsVO;
}
