

class TestJabber {
	
	static function main() {
		
		#if flash9
		flash.Lib.current.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		flash.Lib.current.stage.align = flash.display.StageAlign.TOP_LEFT;
		#end
			
		var r = new haxe.unit.TestRunner();
		
		/////
		r.add( new TestJID() );
		
		r.run();
	}
}
