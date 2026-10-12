
import utest.Assert.*;
import xmpp.XML;

class TestRoster {

	public function new() {}

    public function test_query() {

        var query = new xep.Roster.Query();
        equals( null, query.ver );
        equals( 0, query.item.length );

        var query = new xep.Roster.Query("vvv");
        equals( 'vvv', query.ver );
        equals( 0, query.item.length );

        var query = new xep.Roster.Query([new xep.Roster.Item('name@domain')]);
        equals( null, query.ver );
        equals( 1, query.item.length );
        equals( 'name@domain', query.item[0].jid );
        equals( null, query.item[0].ask );
        equals( null, query.item[0].name );
        equals( null, query.item[0].subscription );
        equals( 0, query.item[0].group.length );
    }

	public function test_item() {

        var item = new xep.Roster.Item('name@domain');
        equals( 'name@domain', item.jid );
        equals( null, item.ask );
        equals( null, item.name );
        equals( null, item.subscription );
        equals( 0, item.group.length );
    }

    public function test_parse() {

        var query : xep.Roster.Query = '<query xmlns="jabber:iq:roster">
	<item jid="user@example.com" name="Romeo" subscription="none" ask="subscribe"><group>Friends</group></item>
	<item jid="another@host.net" subscription="both"/>
</query>';

        equals( 2, query.item.length );
        equals( 'user@example.com', query.item[0].jid );
        equals( 'Romeo', query.item[0].name );
        equals( 'none', query.item[0].subscription );
        equals( 'subscribe', query.item[0].ask );
        equals( 1, query.item[0].group.length );

		equals( 'another@host.net', query.item[1].jid );
		equals( null, query.item[1].name );
        equals( 'both', query.item[1].subscription );
		equals( null, query.item[1].ask );
        equals( 0, query.item[1].group.length );

		//TODO
		///// expected "Friends" but it is <group>Friends</group>
		//equals( 'Friends', query.item[0].group[0] );
    }



}
