
import xmpp.Message;
import xmpp.Presence;
import xmpp.IQ;


class TestXMPPStream {

	static function main() {
		
		#if flash9
		flash.Lib.current.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		flash.Lib.current.stage.align = flash.display.StageAlign.TOP_LEFT;
		#end
		
		haxe.Firebug.redirectTraces();
		
		var r = new haxe.unit.TestRunner();
		r.add( new TestStream() );
		r.run();
	}
	
}


class TestStream extends haxe.unit.TestCase   {
	
	public function testMessageCreate() {
		
		var sx : Xml = null;
		try {
			//sx = Xml.parse('<iq ad="23">est</iq>').firstChild();
			sx = Xml.parse('EBAAAAAAAAAAAAAAAAAAAAABAAAQMCBQIEBAQEBQQDAAAAARECAwAEITESBQZBE1EiFAdhcTIVgZGhQrHBUiPhYnIzQ/BTFheCoiQRAQAAAAAAAAAAAAAAAAAAAAD/2gAMAwEAAhEDEQA/ANTlyORPxoO6gmdB5zg0EnIBSflQIwXXe8zWERFUe7AlD4HoaBYOXEFaDjpGsCvwHU9KBlPvNrCoc2VzwQGsawkuUL5fkM6BzaXlvdwiWFytyIIRwIzBBxBoFqD1B6g9QeWg+Vfic1yoPEt6jLrQNLuS3MMikPIClma6ehAU0EYzf7Ce3ljDwyVrtDQ7yHUEI06s886B/ZT3FxCCWlpQo4IB/l+dAy3cb+bQOt4mySgD+216AuDgnTqKCt+o5X9xEd/tQMA83qo5CcSnUJ9JXMUD61v5Rt4ddl1ndCWRrJJj29QjLu056YOadQFBarC4llg1TBrXhAQ06hkDgevwoHVB7r8KBKO5iknlhavciTWo').firstChild();
		} catch( e : Dynamic ) {
			trace("ERROR: " + e );
		}
		trace(sx.nodeType);
		assertEquals( "45", "45" );
	}
	
}
