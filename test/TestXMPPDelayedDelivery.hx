
class TestXMPPDelayedDelivery extends TestCase {
	
	public function testParse() {
		
		var m = xmpp.Message.parse( Xml.parse( "
<message from='romeo@montague.net/orchard' to='juliet@capulet.com' type='chat'>
	<body>O blessed, blessed night! I am afeard. Being in night, all this is but a dream, Too flattering-sweet to be substantial.</body>
	<delay xmlns='urn:xmpp:delay' from='capulet.com' stamp='2002-09-10T23:08:25Z'>Offline Storage</delay>
</message>" ).firstElement() );
		var delay = xmpp.Delayed.fromPacket( m );
		eq( delay.from, 'capulet.com' );
		eq( delay.stamp, '2002-09-10T23:08:25Z' );
		eq( delay.description, 'Offline Storage' );
		
		var p = xmpp.Presence.parse( Xml.parse( "
<presence from='juliet@capulet.com/balcony' to='romeo@montague.net'>
	<status>anon!</status>
	<show>xa</show>
	<priority>1</priority>
	<delay xmlns='urn:xmpp:delay' from='juliet@capulet.com/balcony' stamp='2002-09-10T23:41:07Z'/>
</presence>" ).firstElement() );
		var delay = xmpp.Delayed.fromPacket( p );
		eq( delay.from, 'juliet@capulet.com/balcony' );
		eq( delay.stamp, '2002-09-10T23:41:07Z' );
		eq( delay.description, null );
	}
	
	public function testBuild() {
		var d = new xmpp.Delayed( "jid@domain.com", "1969-07-20T21:56:15-05:00" );
		var xml = d.toXml();
		eq( "jid@domain.com", xml.get( "from" ) );
		eq( "1969-07-20T21:56:15-05:00", xml.get( "stamp" ) );
		eq( null, xml.get( "description" ) );
		d = new xmpp.Delayed( "jid@domain.com", "1969-07-20T21:56:15-05:00", "mydescription" );
		xml = d.toXml();
		eq( "mydescription", xml.get( "description" ) );
	}
	
}
