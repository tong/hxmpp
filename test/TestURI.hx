import utest.Assert.*;
import xmpp.URI;

class TestURI extends utest.Test {

     function test_parse() {

        var str = "xmpp:example.com";
        var uri = URI.parse(str);
        equals("example.com", uri.jid);
        isNull(uri.action);
        equals(0, Lambda.count(uri.params));

        str = "xmpp://guest@example.com";
        uri = URI.parse(str);
        equals("guest@example.com", uri.jid);
        isNull(uri.action);
        equals(0, Lambda.count(uri.params));

        str = "xmpp:user@example.com?message;body=hi";
        uri = URI.parse(str);
        equals("user@example.com", uri.jid);
        equals("message", uri.action);
        equals("hi", uri.params.get("body"));
        equals(1, Lambda.count(uri.params));

        //xmpp:romeo@montague.net?roster
        //xmpp:example-node@example.com?message;subject=Hello%20World
        //xmpp:romeo@montague.net?message;subject=Test%20Message;body=Here%27s%20a%20test%20message
    }

    function test_message_action() {

        var str = "xmpp:romeo@montague.net?message";
        var uri = URI.parse(str);
        equals("romeo@montague.net", uri.jid);
        equals("message", uri.action);

        str = "xmpp:romeo@montague.net?message;subject=Test%20Message;body=Here%27s%20a%20test%20message";
        uri = URI.parse(str);
        equals("romeo@montague.net", uri.jid);
        equals("message", uri.action);
        equals(2, Lambda.count(uri.params));
    }

    function test_equals() {
        var a = URI.parse("xmpp:romeo@montague.net?roster");
        var b = URI.parse("xmpp:romeo@montague.net?roster");
        isTrue(a.equalsTo(b));
        isTrue(a == b);
    } 

    function test_clone() {
        var a = URI.parse("xmpp:romeo@montague.net?roster");
        var b = a.clone();
        isTrue(a.equalsTo(b));
        isTrue(a == b);
    } 

    function test_muc() {
        var uri = URI.parse("xmpp:prosody@conference.prosody.im?join");
        equals("prosody@conference.prosody.im", uri.jid);
        equals("prosody", uri.account);
        equals("join", uri.action);
        //xmpp:prosody@conference.prosody.im?join
    }
}
