package tls.utils.crypto.symmetric;

extern interface ICipher {
	function decrypt(p0 : flash.utils.ByteArray) : Void;
	function dispose() : Void;
	function encrypt(p0 : flash.utils.ByteArray) : Void;
	function getBlockSize() : UInt;
	function toString() : String;
}
