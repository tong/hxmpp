package tls.utils.crypto.symmetric;

extern class PKCS5 implements IPad {
	function new(?p0 : UInt) : Void;
	function pad(p0 : flash.utils.ByteArray) : Void;
	function setBlockSize(p0 : UInt) : Void;
	function unpad(p0 : flash.utils.ByteArray) : Void;
}
