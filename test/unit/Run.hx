
import haxe.Timer;
import haxe.Template;
#if macro
import sys.FileSystem;
import haxe.macro.Context;
#end

class Run {

	#if macro

	static function prepareBuild() {
		if( !FileSystem.exists( 'build' ) ) FileSystem.createDirectory( 'build' );
	}

	#end

	static var TESTS : Array<Class<haxe.unit.TestCase>> = [
		TestBase64,
		TestJID,
		TestMD5,
		TestMUCUtil,
		TestSHA1,
		TestXMLUtil,
		TestXMPPAuth,
		TestXMPPBind,
		TestXMPPBlockList,
		TestXMPPBOB,
		TestXMPPBookmark,
		TestXMPPChatState,
	//TestXMPPCommand,
		TestXMPPCompression,
		TestXMPPDataForm,
		TestXMPPDateTime,
		TestXMPPDelayedDelivery,
		TestXMPPDisco,
		TestXMPPEntityCapabilities,
		TestXMPPEntityTime,
		TestXMPPError,
	TestXMPPEventLog,
//	TestXMPPRealtimeText,
		TestXMPPFile,
		TestXMPPIBByteStream,
		TestXMPPIQPacket,
		TestXMPPJingle,
		TestXMPPLastActivity,
		TestXMPPMessagePacket,
		TestXMPPMUC,
		TestXMPPPacketFilters,
		TestXMPPPersonalEvent,
		TestXMPPPresencePacket,
		TestXMPPPrivacyLists,
		TestXMPPPrivateStorage,
		TestXMPPPubSub,
		TestXMPPRegister,
		TestXMPPRoster,
		TestXMPPSASL,
		TestXMPPSHIM,
		TestXMPPSoftwareVersion,
		TestXMPPStream,
		TestXMPPStreamError,
		TestXMPPUserSearch,
		TestXMPPVCard,
		TestXMPPVCardTemp,
		TestXMPPXHTML
	];

	static function main() {
		
		#if flash
		flash.Lib.current.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		flash.Lib.current.stage.align = flash.display.StageAlign.TOP_LEFT;
		#end

		var r = new haxe.unit.TestRunner();
		for( test in TESTS ) r.add( Type.createInstance( test, [] ) );
		
		var timestamp = Timer.stamp();
		r.run();

		var stime = Std.string( (Timer.stamp()-timestamp)*1000 );
		var i = stime.indexOf( "." );
		if( i != -1 ) stime = stime.substr( 0, i );
		var time = Std.parseInt( stime );
		trace( '$time ms' );
	}
	
}
