
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
		
	//	r.add( new TestBindExtension() );
		
		///// iq extension
		r.add( new TestAuthExtension() );
		r.add( new TestRegisterExtension() );
		r.add( new TestRosterExtension() );
		r.add( new TestDiscoExtension() );
		r.add( new TestDataFormExtension() );
		r.add( new TestDelayedDeliveryExtension() );
		r.add( new TestChatStateExtension() );
		r.add( new TestLastActivityExtension() );
		
		///// packet filters
		r.add( new TestXPacketFilters() );
		
		r.run();
	}
	
}
