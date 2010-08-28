package tls.controller;

extern class RecordLayer extends flash.events.EventDispatcher {
	var enabled : Bool;
	var options : tls.valueobject.SecurityOptionsVO;
	var protocolVersion : tls.valueobject.ProtocolVersionVO;
	var recordState : Int;
	function new(p0 : SecureSocket, p1 : tls.valueobject.SecurityOptionsVO) : Void;
	function changeCipherSuite(p0 : flash.utils.ByteArray) : Void;
	function changeRecordStateToApplicationData() : Void;
	function sendRecordMessage(p0 : UInt, p1 : tls.valueobject.ProtocolVersionVO, ?p2 : flash.utils.ByteArray) : Void;
	function start() : Void;
	function stop() : Void;
	static var RECORD_STATE_APPLICATION_DATA : Int;
	static var RECORD_STATE_HANDSHAKE : Int;
	static var RECORD_STATE_HANDSHAKE_VERIFY : Int;
	static var RECORD_STATE_NULL : Int;
}
