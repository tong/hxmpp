
import haxe.Timer;
import haxe.Template;

#if macro
import sys.FileSystem;
import haxe.macro.Context;
#end


class Run {

	static function main() {
		
		var r = new haxe.unit.TestRunner();
		
		r.add( new TestBase64() );
		r.add( new TestJID() );
		r.add( new TestMD5() );
		r.add( new TestMUCUtil() );
		r.add( new TestSHA1() );

		r.add( new TestXMLUtil() );

		r.add( new TestXMPPAuth() );
		r.add( new TestXMPPBind() );
		r.add( new TestXMPPBlockList() );
		r.add( new TestXMPPBOB() );
		r.add( new TestXMPPBookmark() );
		r.add( new TestXMPPChatState() );
		r.add( new TestXMPPCompression() );
		r.add( new TestXMPPDataForm() );
		r.add( new TestXMPPDateTime() );
		r.add( new TestXMPPDelayedDelivery() );
		r.add( new TestXMPPDisco() );
		r.add( new TestXMPPEntityCapabilities() );
		r.add( new TestXMPPEntityTime() );
		r.add( new TestXMPPError() );
		r.add( new TestXMPPFile() );
		r.add( new TestXMPPIBByteStream() );
		r.add( new TestXMPPIQPacket() );
		r.add( new TestXMPPJingle() );
		r.add( new TestXMPPLastActivity() );
		r.add( new TestXMPPMessagePacket() );
		r.add( new TestXMPPMUC() );
		r.add( new TestXMPPPacketFilters() );
		r.add( new TestXMPPPersonalEvent() );
		r.add( new TestXMPPPresencePacket() );
		r.add( new TestXMPPPrivacyLists() );
		r.add( new TestXMPPPrivateStorage() );
		r.add( new TestXMPPPubSub() );
		r.add( new TestXMPPRegister() );
		r.add( new TestXMPPRoster() );
		r.add( new TestXMPPSASL() );
		r.add( new TestXMPPSHIM() );
		r.add( new TestXMPPSoftwareVersion() );
		r.add( new TestXMPPStream() );
		r.add( new TestXMPPStreamError() );
		r.add( new TestXMPPUserSearch() );
		r.add( new TestXMPPVCard() );
		r.add( new TestXMPPVCardTemp() );
		r.add( new TestXMPPXHTML() );
		
		var ts = Timer.stamp();
		r.run();
		var stime = Std.string( (Timer.stamp()-ts)*1000 );
		var i = stime.indexOf( "." );
		if( i != -1 ) stime = stime.substr( 0, i );
		var time = Std.parseInt( stime );
		trace(time);
	}

	#if macro

	static function prepareBuild() {
		if( !FileSystem.exists( 'build' ) ) FileSystem.createDirectory( 'build' );
	}

	#end
	
}
