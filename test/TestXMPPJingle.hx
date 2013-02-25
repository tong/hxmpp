
class TestXMPPJingle extends TestCase   {
	
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
  		
		eq( 'romeo@montague.lit/orchard', j.initiator );
		eq( xmpp.jingle.Action.session_initiate, j.action );
		eq( 'a73sjjvkla37jfea', j.sid );
		var content = j.content[0];
		eq( xmpp.jingle.Creator.initiator, content.creator );
		eq( 'this-is-a-stub', content.name );
		//TODO
//		eq( 'urn:xmpp:jingle:transports:stub:0', content.transport.xmlns );
  		/*
		*/
		/*
		eq( 'urn:xmpp:jingle:apps:stub:0', content.description.xmlns );
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
		eq( xmpp.jingle.Action.session_initiate, j.action );
		eq( "romeo@montague.net/orchard", j.initiator );
		eq( "a73sjjvkla37jfea", j.sid );
		var content = j.content[0];
		eq( "romeo@montague.net", content.creator );
		eq( "this-is-the-audio-content", content.name );
		eq( xmpp.jingle.RTMP.XMLNS, content.transport.xmlns);
		eq( 3, content.transport.elements.length );
		eq( "Red5", content.transport.elements[0].get("name") );
	}
*/
	/*
	public function testBuild() {
		var j = new xmpp.Jingle();
	}
	*/
	
}
