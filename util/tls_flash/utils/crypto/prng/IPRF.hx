package tls.utils.crypto.prng;

extern interface IPRF {
	function dispose() : Void;
	function nextByte() : Int;
	function nextBytes(p0 : flash.utils.ByteArray, p1 : Int) : Void;
	function toString() : String;
}
