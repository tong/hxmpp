package tls.utils.crypto.symmetric;

extern interface IPad {
	function pad(p0 : flash.utils.ByteArray) : Void;
	function setBlockSize(p0 : UInt) : Void;
	function unpad(p0 : flash.utils.ByteArray) : Void;
}
