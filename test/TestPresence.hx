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

		for (t in [error, probe, subscribe, subscribed, unavailable, unsubscribe, unsubscribed]) {
			var s:PresenceType = Std.string(t);
			equals(t, s);
			var p:Presence = '<presence type="$t"/>';
			equals(t, p.type);
		}

		var s:PresenceType = '';
		isNull(s);

		var s:PresenceType = 'any';
		isNull(s);
	}

	function test_status() {
		var p:Presence = '<presence><status>My status</status></presence>';
		equals('My status', p.status);
	}

	function test_parse_values() {
		var p:Presence = '<presence><status/></presence>';
		equals('', p.status);

		p = '<presence><show>online</show></presence>';
		isNull(p.show);
		p = '<presence><show>dnd</show></presence>';
		equals(dnd, p.show);

		p = '<presence><priority>999</priority></presence>';
		equals(127, p.priority);
		p = '<presence><priority>-500</priority></presence>';
		equals(-128, p.priority);
		p = '<presence><priority>abc</priority></presence>';
		isNull(p.priority);
	}

	function test_priority_clamped() {
		final p = new Presence(null, null, 500);
		equals(127, p.priority);
		equals('127', p.toXML().elements.named('priority')[0].text);
		p.priority = -1000;
		equals(-128, p.priority);
	}

	function test_status_languages() {
		final p:Presence = '<presence><status xml:lang="de">Weg</status><status>Away</status></presence>';
		equals('Away', p.status);
		equals(1, p.properties.length);
		equals(2, p.toXML().elements.named('status').length);
	}
}
