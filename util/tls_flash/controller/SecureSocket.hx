package tls.controller;

extern class SecureSocket extends flash.events.EventDispatcher {
	var host : String;
	var port : Int;
	var supressSendEvent : Bool;
	function new() : Void;
	function close() : Void;
	function connect(p0 : String, p1 : Int) : Void;
	function isConnected() : Bool;
	function sendByteArray(p0 : flash.utils.ByteArray, ?p1 : UInt, ?p2 : UInt) : Void;
	function sendString(p0 : String) : Void;
	function startSecureSupport(p0 : tls.valueobject.SecurityOptionsVO) : Void;
	function stopSecureSupport() : Void;
}
