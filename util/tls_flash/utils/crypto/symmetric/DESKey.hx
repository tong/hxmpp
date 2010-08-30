package tls.utils.crypto.symmetric;

extern class DESKey implements ISymmetricKey {
	function new(p0 : flash.utils.ByteArray) : Void;
	function decrypt(p0 : flash.utils.ByteArray, ?p1 : UInt) : Void;
	function dispose() : Void;
	function encrypt(p0 : flash.utils.ByteArray, ?p1 : UInt) : Void;
	function getBlockSize() : UInt;
	function toString() : String;
	private var decKey : Array<Dynamic>;
	private var encKey : Array<Dynamic>;
	private var key : flash.utils.ByteArray;
	private function desFunc(p0 : Array<Dynamic>, p1 : flash.utils.ByteArray, p2 : UInt, p3 : flash.utils.ByteArray, p4 : UInt) : Void;
	private function generateWorkingKey(p0 : Bool, p1 : flash.utils.ByteArray, p2 : UInt) : Array<Dynamic>;
}
