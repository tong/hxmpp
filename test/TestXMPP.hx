


class TestXMPP {
	
	static function main() {
		
		#if flash9
		flash.Lib.current.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		flash.Lib.current.stage.align = flash.display.StageAlign.TOP_LEFT;
		#end
		
		var r = new haxe.unit.TestRunner();
		r.add( new TestMessagePacket() );
	//	r.add( new TestPresencePacket() );
	//	r.add( new TestIQPacket() );
	//	r.add( new TestPacketFilter() );
		r.run();
	}
}


class TestMessagePacket extends haxe.unit.TestCase   {
	
	public function testMessage() {
		assertTrue( true );
	}
}
