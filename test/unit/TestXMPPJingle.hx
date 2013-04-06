
class TestXMPPJingle extends haxe.unit.TestCase {
	
	public function testParse() {
		
		var x = Xml.parse( "<jingle xmlns='urn:xmpp:jingle:1'
									action='session-initiate'
									initiator='romeo@montague.lit/orchard'
									sid='a73sjjvkla37jfea'>
	<content creator='initiator' name='this-is-a-stub'>
		<description xmlns='urn:xmpp:jingle:apps:stub:0'/>
		<transport xmlns='urn:xmpp:jingle:transports:stub:0'/>
	</content>
</jingle>" ).firstElement();
  		var j = xmpp.Jingle.parse( x );
  		
		assertEquals( 'romeo@montague.lit/orchard', j.initiator );
		assertEquals( xmpp.jingle.Action.session_initiate, j.action );
		assertEquals( 'a73sjjvkla37jfea', j.sid );
		var content = j.content[0];
		assertEquals( xmpp.jingle.Creator.initiator, content.creator );
		assertEquals( 'this-is-a-stub', content.name );
		//TODO
//		assertEquals( 'urn:xmpp:jingle:transports:stub:0', content.transport.xmlns );
  		/*
		*/
		/*
		assertEquals( 'urn:xmpp:jingle:apps:stub:0', content.description.xmlns );
		*/
	}
	
	/*
	public function testParseRTMP() {
var x = Xml.parse( "<jingle xmlns='urn:xmpp:jingle:1'
									action='session-initiate' 
									initiator='romeo@montague.net/orchard' 
									sid='a73sjjvkla37jfea'>
	<content creator='romeo@montague.net' name='this-is-the-audio-content'>
		<transport xmlns='urn:xmpp:jingle:apps:rtmp'>
			<candidate name='Red5' 
					   url='rtmp://red5.jivesoftware.org/jingle' 
	                   generation='0' 
	                   stream='romeoaudiovideo23456'/>
			<candidate name='Red5HTTPTunnel' 
	                   url='rtmpt://red5.jivesoftware.org:9090/jingle' 
	                   generation='0' 
	                   stream='romeoaudiovideo23456'/>
			<candidate name='Red5Secure' 
	                   url='rtmpts://red5.jivesoftware.org:9091/jingle' 
	                   generation='0' 
	                   stream='romeoaudiovideo23456'/>
		  </transport>
	</content>
</jingle>" ).firstElement();
	  	var j = xmpp.Jingle.parse( x );
		assertEquals( xmpp.jingle.Action.session_initiate, j.action );
		assertEquals( "romeo@montague.net/orchard", j.initiator );
		assertEquals( "a73sjjvkla37jfea", j.sid );
		var content = j.content[0];
		assertEquals( "romeo@montague.net", content.creator );
		assertEquals( "this-is-the-audio-content", content.name );
		assertEquals( xmpp.jingle.RTMP.XMLNS, content.transport.xmlns);
		assertEquals( 3, content.transport.elements.length );
		assertEquals( "Red5", content.transport.elements[0].get("name") );
	}
*/
	/*
	public function testBuild() {
		var j = new xmpp.Jingle();
	}
	*/
	
}
