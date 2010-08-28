package tls.utils.crypto.symmetric.ssl;

extern class SSLPadding implements tls.utils.crypto.symmetric.IPad {
	function new(?p0 : UInt) : Void;
	function pad(p0 : flash.utils.ByteArray) : Void;
	function setBlockSize(p0 : UInt) : Void;
	function unpad(p0 : flash.utils.ByteArray) : Void;
}
