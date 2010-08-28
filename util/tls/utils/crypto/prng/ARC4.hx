package tls.utils.crypto.prng;

extern class ARC4 implements IPRNG, implements tls.utils.crypto.symmetric.ICipher {
	function new(?p0 : flash.utils.ByteArray) : Void;
	function decrypt(p0 : flash.utils.ByteArray) : Void;
	function dispose() : Void;
	function encrypt(p0 : flash.utils.ByteArray) : Void;
	function getBlockSize() : UInt;
	function getPoolSize() : UInt;
	function init(p0 : flash.utils.ByteArray) : Void;
	function next() : UInt;
	function toString() : String;
}
