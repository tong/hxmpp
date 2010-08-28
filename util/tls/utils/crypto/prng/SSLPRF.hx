package tls.utils.crypto.prng;

extern class SSLPRF implements IPRF {
	function new(p0 : flash.utils.ByteArray, p1 : flash.utils.ByteArray, p2 : flash.utils.ByteArray, p3 : Bool) : Void;
	function dispose() : Void;
	function nextByte() : Int;
	function nextBytes(p0 : flash.utils.ByteArray, p1 : Int) : Void;
	function reset() : Void;
	function toString() : String;
	private function getNextBytes() : flash.utils.ByteArray;
}
