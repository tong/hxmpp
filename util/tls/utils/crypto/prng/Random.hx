package tls.utils.crypto.prng;

extern class Random {
	function new(?p0 : Class<Dynamic>) : Void;
	function autoSeed() : Void;
	function dispose() : Void;
	function nextByte() : Int;
	function nextBytes(p0 : flash.utils.ByteArray, p1 : Int) : Void;
	function seed(?p0 : Int) : Void;
	function toString() : String;
}
