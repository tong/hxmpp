import utest.Assert.*;
import xmpp.Response;
import xmpp.XML;
import xmpp.xml.Printer;

class TestResponse extends utest.Test {
	function test_ok() {
		var r:Response<XML> = Result(XML.fromString("<e></e>"));
		isTrue(r.ok());
		isTrue(r);
		var r:Response<XML> = Error(new xmpp.Stanza.Error(cancel, bad_request));
		isFalse(r.ok());
		isFalse(r);
	}

	function test_empty_result() {
		final r:Response<XML> = Result(null);
		isTrue(r.ok());
		isNull(r.payload);
		isNull(r.xmlns);
		isFalse(r.is('jabber:iq:version'));
		isNull(r.toXML());
	}

	function test_payload_namespace() {
		final r:Response<XML> = Result(XML.fromString('<query xmlns="jabber:iq:version"/>'));
		equals('jabber:iq:version', r.xmlns);
		isTrue(r.is('jabber:iq:version'));
		equals('query', r.toXML().name);
	}

	function test_helpers() {
		final r:Response<XML> = Response.success();
		isTrue(r);
		isNull(r.payload);
		final r:Response<XML> = Response.success(XML.create('x'));
		equals('x', r.payload.name);
		final r:Response<XML> = Response.failure(cancel, item_not_found, 'gone');
		isFalse(r);
		equals(xmpp.Stanza.ErrorCondition.item_not_found, r.error.condition);
		equals(xmpp.Stanza.ErrorType.cancel, r.error.type);
		equals('gone', r.error.text);
		equals('error', r.toXML().name);
		raises(() -> r.sure());
	}
	/*
		function test_payload() {
			var r : Response<XML> = Result('<query xmlns="disktree"></query>');
			equals('<query xmlns="disktree"></query>', r.payload.toString());
			var r : Response<XML> = Error(new xmpp.Stanza.Error(cancel, bad_request));
			isNull(r.payload);
		}
	 */
	/*
		function test_xmlns() {
			var r : Response<XML> = Result('<query xmlns="disktree"></query>');
			equals("disktree", r.xmlns);
			isTrue(r.is('disktree'));
			var r : Response<XML> = Result("<query></query>");
			isNull(r.xmlns);
			isFalse(r.is('disktree'));
			var r : Response<XML> = Error(new xmpp.Stanza.Error(cancel, bad_request));
			isNull(r.xmlns);
			isFalse(r.is('disktree'));
		}
	 */
	/*
		function test_toOption() {
			var xml : XML = '<query xmlns="disktree"></query>';
			var r : Response<XML> = Result(xml);
			var opt : haxe.ds.Option<XML> = r;
			equals(haxe.ds.Option.Some(xml), opt);
		}
	 */
	/*
		function test_toXML() {
			var r : Response<XML> = Result('<query xmlns="disktree"></query>');
			var xml : XML = r;
			equals('<query xmlns="disktree"></query>', xml.toString());
		}
	 */
}
