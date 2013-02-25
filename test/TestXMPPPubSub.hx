
class TestXMPPPubSub extends TestCase {
	
	/*
	public function testBuildPubSub() {
	//TODO
		var ps = new xmpp.PubSub();
		ps.subscribe = { node : "nodename", jid : "myjid@server.net" };
		var x = ps.toXml();
		trace(x);
	}
	*/
	
	public function testParsePubSub() {
		
		// test subscribe
		var x = Xml.parse( "
<pubsub xmlns='http://jabber.org/protocol/pubsub'>
	<subscribe
		node='princely_musings'
        jid='francisco@denmark.lit'/>
</pubsub>" ).firstElement();
		var xt = xmpp.PubSub.parse( x );
		eq( 'princely_musings', xt.subscribe.node );
		eq( 'francisco@denmark.lit', xt.subscribe.jid );
		
		// test unsubscribe
		x = Xml.parse( "
<pubsub xmlns='http://jabber.org/protocol/pubsub'>
	<unsubscribe node='princely_musings' jid='francisco@denmark.lit' subid='ba49252aaa4f5d320c24d3766f0bdcade78c78d3'/>
 </pubsub>" ).firstElement();
		xt = xmpp.PubSub.parse( x );
		eq( "princely_musings", xt.unsubscribe.node );
		eq( "francisco@denmark.lit", xt.unsubscribe.jid );
		eq( "ba49252aaa4f5d320c24d3766f0bdcade78c78d3", xt.unsubscribe.subid );
		
		// test create
		x = Xml.parse( "
<pubsub xmlns='http://jabber.org/protocol/pubsub'>
	<create node='princely_musings'/>
</pubsub>" ).firstElement();
		xt = xmpp.PubSub.parse( x );
		eq( "princely_musings", xt.create );
		
		// test configure
		//TODO
		x = Xml.parse( "
<pubsub xmlns='http://jabber.org/protocol/pubsub'>
	<create node='princely_musings'/>
	<configure>
		<x xmlns='jabber:x:data' type='submit'>
			<field var='FORM_TYPE' type='hidden'>
				<value>http://jabber.org/protocol/pubsub#node_config</value>
			</field>
			<field var='pubsub#access_model'><value>whitelist</value></field>
		</x>
	</configure>
</pubsub>" ).firstElement();
		xt = xmpp.PubSub.parse( x );
		eq( "princely_musings", xt.create );
		eq( xmpp.dataform.FormType.submit, xt.configure.type );
		
		// test subscription
		x = Xml.parse( "
<pubsub xmlns='http://jabber.org/protocol/pubsub'>
	<subscription
        node='princely_musings'
        jid='francisco@denmark.lit'
        subid='ba49252aaa4f5d320c24d3766f0bdcade78c78d3'
        subscription='subscribed'/>
</pubsub>" ).firstElement();
  		xt = xmpp.PubSub.parse( x );
		eq( 'princely_musings', xt.subscription.node );
		eq( 'francisco@denmark.lit', xt.subscription.jid );
		eq( 'ba49252aaa4f5d320c24d3766f0bdcade78c78d3', xt.subscription.subid );
		eq( xmpp.pubsub.SubscriptionState.subscribed, xt.subscription.subscription );
		//TODO subscribe_options (see xsd)
		
		// test subscriptions
		x = Xml.parse( "
<pubsub xmlns='http://jabber.org/protocol/pubsub'>
    <subscriptions>
      <subscription node='node1' jid='francisco@denmark.lit' subscription='subscribed'/>
      <subscription node='node2' jid='francisco@denmark.lit' subscription='subscribed'/>
      <subscription node='node5' jid='francisco@denmark.lit' subscription='unconfigured'/>
      <subscription node='node6' jid='francisco@denmark.lit' subscription='pending'/>
    </subscriptions>
</pubsub>" ).firstElement();
		xt = xmpp.PubSub.parse( x );
		eq( 4, xt.subscriptions.length );
		var subscriptions = Lambda.array( xt.subscriptions );
		eq( "node1", subscriptions[0].node );
		eq( "francisco@denmark.lit", subscriptions[0].jid );
		eq( xmpp.pubsub.SubscriptionState.subscribed, subscriptions[0].subscription );
		eq( "node2", subscriptions[1].node );
		eq( "francisco@denmark.lit", subscriptions[1].jid );
		eq( xmpp.pubsub.SubscriptionState.subscribed, subscriptions[1].subscription );
		eq( "node5", subscriptions[2].node );
		eq( "francisco@denmark.lit", subscriptions[2].jid );
		eq( xmpp.pubsub.SubscriptionState.unconfigured, subscriptions[2].subscription );
		eq( "node6", subscriptions[3].node );
		eq( "francisco@denmark.lit", subscriptions[3].jid );
		eq( xmpp.pubsub.SubscriptionState.pending, subscriptions[3].subscription );
		
		// test retract
		x = Xml.parse( "
<pubsub xmlns='http://jabber.org/protocol/pubsub'>
	<retract node='princely_musings'>
		<item id='ae890ac52d0df67ed7cfdf51b644e901'/>
    </retract>
</pubsub>" ).firstElement();
    	xt = xmpp.PubSub.parse( x );
		eq( "princely_musings", xt.retract.node );
		af( xt.retract.notify );
		var items = Lambda.array( xt.retract );
		eq( "ae890ac52d0df67ed7cfdf51b644e901", items[0].id );
		// TODO eq( "ae890ac52d0df67ed7cfdf51b644e901", xt.retract.item.id );
		
		// test publish
		x = Xml.parse( "
<pubsub xmlns='http://jabber.org/protocol/pubsub'>
	<publish node='princely_musings'>
		<item>
			<entry xmlns='http://www.w3.org/2005/Atom'>
				<title>Soliloquy</title>
				<summary>
To be, or not to be: that is the question:
Whether 'tis nobler in the mind to suffer
The slings and arrows of outrageous fortune,
Or to take arms against a sea of troubles,
And by opposing end them?
				</summary>
				<link rel='alternate' type='text/html' href='http://denmark.lit/2003/12/13/atom03'/>
				<id>tag:denmark.lit,2003:entry-32397</id>
				<published>2003-12-13T18:30:02Z</published>
				<updated>2003-12-13T18:30:02Z</updated>
			</entry>
		</item>
	</publish>
</pubsub>" ).firstElement();
		xt = xmpp.PubSub.parse( x );
		eq( "princely_musings", xt.publish.node );
		eq( 1, Lambda.count( xt.publish ) );
		
		// test affiliation
		x = Xml.parse( "
<pubsub xmlns='http://jabber.org/protocol/pubsub'>
	<affiliations>
		<affiliation node='node1' affiliation='owner'/>
      	<affiliation node='node2' affiliation='publisher'/>
      	<affiliation node='node5' affiliation='outcast'/>
		<affiliation node='node6' affiliation='owner'/>
    </affiliations>
</pubsub>" ).firstElement();
		xt = xmpp.PubSub.parse( x );
		eq( 4, xt.affiliations.length );
		var affiliations = Lambda.array( xt.affiliations );
		eq( "node1", affiliations[0].node );
		eq( xmpp.pubsub.AffiliationState.owner, affiliations[0].affiliation );
		eq( "node2", affiliations[1].node );
		eq( xmpp.pubsub.AffiliationState.publisher, affiliations[1].affiliation );
		eq( "node5", affiliations[2].node );
		eq( xmpp.pubsub.AffiliationState.outcast, affiliations[2].affiliation );
		eq( "node6", affiliations[3].node );
		eq( xmpp.pubsub.AffiliationState.owner, affiliations[3].affiliation );
		
		// test options
		x = Xml.parse( "
<pubsub xmlns='http://jabber.org/protocol/pubsub'>
	<options node='princely_musings' jid='francisco@denmark.lit'>
		<x xmlns='jabber:x:data' type='submit'>
			<field var='FORM_TYPE' type='hidden'>
				<value>http://jabber.org/protocol/pubsub#subscribe_options</value>
			</field>
			<field var='pubsub#expire'><value>2006-03-31T23:59Z</value></field>
		</x>
	</options>
</pubsub>" ).firstElement();
		xt = xmpp.PubSub.parse( x );
		eq( "francisco@denmark.lit", xt.options.jid );
		eq( "princely_musings", xt.options.node );
		eq( null, xt.options.subid );
		eq( xmpp.dataform.FormType.submit, xt.options.form.type );
	}
	
	
	public function testParsePubSubEvent() {
		
		// test items
		var x = Xml.parse( "
<event xmlns='http://jabber.org/protocol/pubsub#event'>
	<items node='princely_musings'>
		<item id='ae890ac52d0df67ed7cfdf51b644e901'>
			<any>data</any>
		</item>
    </items>
</event>" ).firstElement();
		var xt = xmpp.PubSubEvent.parse( x );
		eq( "princely_musings", xt.items.node );
		eq( 1, xt.items.length );
		eq( "ae890ac52d0df67ed7cfdf51b644e901", xt.items.first().id );
		eq( "<any>data</any>", xt.items.first().payload.toString() );
		
		// test configuration
		x = Xml.parse( "
<event xmlns='http://jabber.org/protocol/pubsub#event'>
	<configuration node='princely_musings'/>
</event>" ).firstElement();
		xt = xmpp.PubSubEvent.parse( x );
		eq( "princely_musings", xt.configuration.node );
		eq( null, xt.configuration.form );
		// test configuration(with form)
		x = Xml.parse( "
  <event xmlns='http://jabber.org/protocol/pubsub#event'>
    <configuration node='princely_musings'>
      <x xmlns='jabber:x:data' type='result'>
        <field var='pubsub#title'><value>Princely Musings (Atom)</value></field>
      </x>
    </configuration>
  </event>" ).firstElement();
		xt = xmpp.PubSubEvent.parse( x );
		eq( "princely_musings", xt.configuration.node );
		eq( xmpp.dataform.FormType.result, xt.configuration.form.type );
		
		// test delete
		x = Xml.parse( "
<event xmlns='http://jabber.org/protocol/pubsub#event'>
	<delete node='princely_musings'/>
</event>" ).firstElement();
		xt = xmpp.PubSubEvent.parse( x );
		eq( "princely_musings", xt.delete );
		
		// test purge
		x = Xml.parse( "
<event xmlns='http://jabber.org/protocol/pubsub#event'>
	<purge node='princely_musings'/>
</event>" ).firstElement();
		xt = xmpp.PubSubEvent.parse( x );
		eq( "princely_musings", xt.purge );
		
		// test subscription
		x = Xml.parse( "
<event xmlns='http://jabber.org/protocol/pubsub#event'>
	<subscription node='princely_musings' jid='horatio@denmark.lit' subscription='subscribed'/>
</event>" ).firstElement();
		xt = xmpp.PubSubEvent.parse( x );
		eq( "princely_musings", xt.subscription.node );
		eq( "horatio@denmark.lit", xt.subscription.jid );
		eq( xmpp.pubsub.SubscriptionState.subscribed, xt.subscription.subscription );
	}
	
	
	public function testParsePubSubOwner() {
		
		// test configure
		var x = Xml.parse( "
<pubsub xmlns='http://jabber.org/protocol/pubsub#owner'>
    <configure node='princely_musings'/>
</pubsub>" ).firstElement();
		var xt = xmpp.PubSubOwner.parse( x );
		eq( "princely_musings", xt.configure.node );
		
		// test delete
		x = Xml.parse( "
<event xmlns='http://jabber.org/protocol/pubsub#owner'>
	<delete node='princely_musings'/>
</event>" ).firstElement();
		xt = xmpp.PubSubOwner.parse( x );
		eq( "princely_musings", xt.delete );
		
		// test subscriptions
		x = Xml.parse( "
<pubsub xmlns='http://jabber.org/protocol/pubsub#owner'>
    <subscriptions node='princely_musings'>
      <subscription jid='hamlet@denmark.lit' subscription='subscribed'/>
      <subscription jid='polonius@denmark.lit' subscription='unconfigured'/>
      <subscription jid='bernardo@denmark.lit' subscription='subscribed' subid='123-abc'/>
      <subscription jid='bernardo@denmark.lit' subscription='subscribed' subid='004-yyy'/>
    </subscriptions>
</pubsub>" ).firstElement();
		xt = xmpp.PubSubOwner.parse( x );
		eq( "princely_musings", xt.subscriptions.node );
		
		// test affiliation
		x = Xml.parse( "
<pubsub xmlns='http://jabber.org/protocol/pubsub#owner'>
	<affiliations>
		<affiliation node='node1' affiliation='owner'/>
      	<affiliation node='node2' affiliation='publisher'/>
      	<affiliation node='node5' affiliation='outcast'/>
		<affiliation node='node6' affiliation='owner'/>
    </affiliations>
</pubsub>" ).firstElement();
		xt = xmpp.PubSubOwner.parse( x );
		eq( 4, xt.affiliations.length );
		
		// test default
		x = Xml.parse( "
<pubsub xmlns='http://jabber.org/protocol/pubsub#owner'>
    <default/>
</pubsub>" ).firstElement();
		xt = xmpp.PubSubOwner.parse( x );
		at( xt._default.empty );
		eq( null, xt._default.form );
	}
	
}
