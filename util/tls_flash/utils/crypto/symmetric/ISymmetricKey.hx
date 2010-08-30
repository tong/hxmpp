package tls.utils.crypto.symmetric;

extern interface ISymmetricKey {
	function decrypt(p0 : flash.utils.ByteArray, ?p1 : UInt) : Void;
	function dispose() : Void;
	function encrypt(p0 : flash.utils.ByteArray, ?p1 : UInt) : Void;
	function getBlockSize() : UInt;
	function toString() : String;
}
