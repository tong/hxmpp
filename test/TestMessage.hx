
import utest.Assert.*;
import xmpp.Message;

class TestMessage extends utest.Test {

    function test_type() {

		equals( normal, cast('normal', MessageType) );
		equals( error, cast('error', MessageType) );
		equals( chat, cast('chat', MessageType) );
		equals( groupchat, cast('groupchat', MessageType) );
		equals( headline, cast('headline', MessageType) );
		
		var s : MessageType = '';
		isNull( s );
	
		var s : MessageType = 'any';
		isNull( s );
	}

    function test_create() {

        var m = new Message();

        equals( null, m.to );
        equals( null, m.from );
        equals( null, m.id );
        equals( null, m.lang );
        //equals( null, m.error );
        //equals( 0, m.properties.length );

        var m = new Message( 'node@domain.com/resource', 'mybody', 'mysubject' );
        equals( 'node@domain.com/resource', m.to );
        equals( 'mybody', m.body );
        equals( 'mysubject', m.subject );
        equals( 'chat', m.type );
        equals( null, m.thread );

        var xml = m.toXML();
        equals( 'node@domain.com/resource', xml.get( 'to' ) );
        equals( MessageType.chat, xml.get( 'type' ) );
    }

    function test_parse() {

        var xml = Xml.parse( '<message type="chat"><body>mybody</body></message>' ).firstElement();
        var m = Message.fromXML( xml );
        equals( 'chat', m.type );
        equals( 'mybody', m.body );
        equals( 0, m.properties.length );

        var xml = Xml.parse( '
			<message to="romeo@jabber.disktree.net">
				<body>green with envy!</body>
				<html xmlns="http://jabber.org/protocol/xhtml-im">
					<body xmlns="http://www.w3.org/1999/xhtml">
						<p style="font-size:large">
							<em>Wow</em>, I&apos;m <span style="color:green">green</span>
							with <strong>envy</strong>!
						</p>
					</body>
				</html>
			</message>' ).firstElement();
		var m = Message.fromXML( xml );
		equals( null, m.type );
		equals( 'romeo@jabber.disktree.net', m.to );
		equals( 'green with envy!', m.body );
		equals( 1, m.properties.length );
		equals( "html", m.properties[0].name );
    }

}
