import utest.Assert.*;
import xmpp.Presence;
import xmpp.Presence.Priority;
import xmpp.XML;

class TestPresence extends utest.Test {
	function test_create() {
		var p = new Presence();
		isNull(p.to);
		isNull(p.from);
		isNull(p.type);
		isNull(p.show);
		isNull(p.status);
		isNull(p.priority);

		var str = '<presence></presence>';
		var xml:XML = Xml.parse(str).firstElement();

		var p = Presence.fromString(str);
		isNull(p.to);
		isNull(p.from);
		isNull(p.type);
		isNull(p.show);
		isNull(p.status);
		isNull(p.priority);

		var p = Presence.fromXML(xml);
		isNull(p.to);
		isNull(p.from);
		isNull(p.type);
		isNull(p.show);
		isNull(p.status);
		isNull(p.priority);

		var p:Presence = str;
		isNull(p.to);
		isNull(p.from);
		isNull(p.type);
		isNull(p.show);
		isNull(p.status);
		isNull(p.priority);

		var p:Presence = xml;
		isNull(p.to);
		isNull(p.from);
		isNull(p.type);
		isNull(p.show);
		isNull(p.status);
		isNull(p.priority);
	}

	function test_parse() {
		var p:Presence = '<presence type="subscribe"/>';
		equals(subscribe, p.type);
		equals('<presence type="subscribe"/>', p.toString());

		var p:Presence = '<presence type="subscribe"><show>dnd</show></presence>';
		equals(subscribe, p.type);
		equals(dnd, p.show);
		equals('<presence type="subscribe"><show>dnd</show></presence>', p.toString());

		var p:Presence = '<presence>
				<show>away</show>
				<priority>5</priority>
				<status>my status information</status>
			</presence>';
		isNull(p.to);
		isNull(p.from);
		isNull(p.type);
		equals(away, p.show);
		equals('my status information', p.status);
		equals(5, p.priority);
	}

	function test_toXML() {
		var p:Presence = '<presence>
				<show>away</show>
				<priority>5</priority>
				<status>my status information</status>
			</presence>';
		var xml = p.toXML();
		isNull(xml.get('to'));
		isNull(xml.get('from'));
		isNull(xml.get('type'));
	}

	function test_priority() {
		// isNull( new Presence().priority );
		// equals( 23, new Presence( 23 ).priority );
		// equals( 127, new Presence( 999 ).priority );
		// var p = new Priority(23);
		equals(0, new Priority(0));
		equals(127, new Priority(999));
		equals(-128, new Priority(-999));
	}

	function test_show() {
		equals(chat, cast('chat', Show));
		equals(away, cast('away', Show));
		equals(xa, cast('xa', Show));
		equals(dnd, cast('dnd', Show));

		// var s : Show = "";
		// isNull( s );
		//
		// var s : Show = "any";
		// isNull( s );
	}

	function test_type() {
		equals(error, cast('error', PresenceType));
		equals(probe, cast('probe', PresenceType));
		equals(subscribe, cast('subscribe', PresenceType));
		equals(subscribed, cast('subscribed', PresenceType));
		equals(unavailable, cast('unavailable', PresenceType));
		equals(unsubscribe, cast('unsubscribe', PresenceType));
		equals(unsubscribed, cast('unsubscribed', PresenceType));

		var s:PresenceType = '';
		isNull(s);

		var s:PresenceType = 'any';
		isNull(s);
	}

	function test_status() {
		var p:Presence = '<presence><status>My status</status></presence>';
		equals('My status', p.status);
	}
}
