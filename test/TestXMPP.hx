
import TestXMPPPacket;
import TestXMPPIQExtensions;
import TestXMPPPacketFilter;


class TestXMPP {
	
	static function main() {

		#if flash9
		flash.Lib.current.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		flash.Lib.current.stage.align = flash.display.StageAlign.TOP_LEFT;
		#end
		
		var r = new haxe.unit.TestRunner();
		
		///// core packets
		r.add( new TestMessagePacket() );
		r.add( new TestPresencePacket() );
		r.add( new TestIQPacket() );
		
		r.add( new TestErrorExtension() );
		r.add( new TestXMPPDate() );
		r.add( new TestXMPPCompression() );
		
	//	r.add( new TestBindExtension() );
		
		///// iq extension
		r.add( new TestXMPPAuth() );
		r.add( new TestXMPPRegister() );
		r.add( new TestXMPPRoster() );
		r.add( new TestXMPPDisco() );
		r.add( new TestXMPPDataForm() );
		r.add( new TestXMPPDelayedDelivery() );
		r.add( new TestXMPPChatState() );
		r.add( new TestXMPPLastActivity() );
		r.add( new TestXMPPPrivacyLists() );
		r.add( new TestXMPPMood() );
		r.add( new TestXMPPCaps() );
		
	//	r.add( new TestXMPPJingle() );
		r.add( new TestXMPPPubSub() );
		
		r.add( new TestXMPPMUC() );
		
		
		
		///// packet filters
		r.add( new TestXPacketFilters() );
		
		r.run();
	}
	
}
