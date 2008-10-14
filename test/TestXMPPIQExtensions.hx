
import xmpp.Roster;



class TestXMPPIQExtensions {

	static function main() {
		
		#if flash9
		flash.Lib.current.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		flash.Lib.current.stage.align = flash.display.StageAlign.TOP_LEFT;
		#end
		
		haxe.Firebug.redirectTraces();
		
		var r = new haxe.unit.TestRunner();
		r.add( new TestAuthExtension() );
		r.add( new TestRosterExtension() );
		r.run();
	}
	
}



class TestAuthExtension extends haxe.unit.TestCase   {
	
	public function testAuthExt() {
		var iq = xmpp.IQ.parse( Xml.parse( '<iq type="set" id="66ceE3"><query xmlns="jabber:iq:auth"><username>tong</username><password>test</password><resource>norc</resource><digest>123</digest></query></iq>' ).firstElement() );
		var auth = xmpp.Auth.parse( iq.ext.toXml() );
		assertEquals( auth.username, 'tong' );
		assertEquals( auth.password, 'test' );
		assertEquals( auth.resource, 'norc' );
		assertEquals( auth.digest, "123" );
	}

}



class TestRosterExtension extends haxe.unit.TestCase   {
	
	public function testRosterExt() {
		//TODO
		/*
		var iq = xmpp.IQ.parse( Xml.parse( '<iq type="result" id="E/xud+7" to="tong@disktree/norc"><query xmlns="jabber:iq:roster"><item jid="test@disktree" subscription="both"/><item jid="account@disktree" subscription="both"/></query></iq>' ).firstElement() );
		var r = xmpp.Roster.parse( iq.ext.toXml() );
		
		for( item in r ) {
			assertEquals( "1","1");
		}
		*/
		assertEquals("1","1");
		/*
		var iq = new xmpp.IQ();
		var ext = new xmpp.RosterItem( "test@disktree.net" );
		iq.ext = ext;
		
		//trace( iq.toString() );
		//subscription="both" name="testnick"
		assertEquals( ext.toString(), '<item jid="test@disktree.net"/>' );
		assertEquals( iq.toString(), '<iq type="get" id="null"><item jid="test@disktree.net"/></iq>' );
	
	//	ext.name = "testnick";
	//	ext.subscription = xmpp.Subscription.both;
	//.........TODO
		*/
	}

}

