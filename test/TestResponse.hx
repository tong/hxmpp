
import utest.Assert.*;
import xmpp.Response;
import xmpp.XML;
import xmpp.xml.Printer;

class TestResponse extends utest.Test {

    function test_ok() {
        var r : Response<XML> = Result("<e></e>");
        isTrue(r.ok());
        isTrue(r);
        var r : Response<XML> = Error(new xmpp.Stanza.Error(cancel, bad_request));
        isFalse(r.ok());
        isFalse(r);
    }

    function test_payload() {
        var r : Response<XML> = Result('<query xmlns="disktree"></query>');
        equals('<query xmlns="disktree"></query>', r.payload.toString());
        var r : Response<XML> = Error(new xmpp.Stanza.Error(cancel, bad_request));
        isNull(r.payload);
    }
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

    function test_toXML() {
        var r : Response<XML> = Result('<query xmlns="disktree"></query>');
        var xml : XML = r;
        equals('<query xmlns="disktree"></query>', xml.toString());
    }

}
