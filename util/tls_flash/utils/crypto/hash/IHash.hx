package tls.utils.crypto.hash;

extern interface IHash {
	function getHashSize() : UInt;
	function getInputSize() : UInt;
	function hash(p0 : flash.utils.ByteArray) : flash.utils.ByteArray;
	function toString() : String;
}
