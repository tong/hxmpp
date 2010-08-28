package tls.utils.crypto.hash;

extern class SHA1 extends SHABase, implements IHash {
	function new() : Void;
	static var HASH_SIZE : Int;
	static function hashBytes(p0 : flash.utils.ByteArray) : flash.utils.ByteArray;
}
