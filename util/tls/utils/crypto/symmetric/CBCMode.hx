package tls.utils.crypto.symmetric;

extern class CBCMode extends IVMode, implements ICipher {
	function new(p0 : ISymmetricKey, ?p1 : IPad, ?p2 : flash.utils.ByteArray) : Void;
	function decrypt(p0 : flash.utils.ByteArray) : Void;
	function encrypt(p0 : flash.utils.ByteArray) : Void;
	function toString() : String;
}
