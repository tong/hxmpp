package tls.utils.crypto.hash;

extern class SHABase implements IHash {
	function new() : Void;
	function getHashSize() : UInt;
	function getInputSize() : UInt;
	function hash(p0 : flash.utils.ByteArray) : flash.utils.ByteArray;
	function toString() : String;
	private function core(p0 : Array<Dynamic>, p1 : UInt) : Array<Dynamic>;
}
