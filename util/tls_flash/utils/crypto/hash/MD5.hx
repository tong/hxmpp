package tls.utils.crypto.hash;

extern class MD5 implements IHash {
	function new() : Void;
	function getHashSize() : UInt;
	function getInputSize() : UInt;
	function hash(p0 : flash.utils.ByteArray) : flash.utils.ByteArray;
	function toString() : String;
	static var HASH_SIZE : Int;
}
