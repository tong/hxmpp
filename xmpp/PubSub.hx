package xmpp;


class PubSub {
	
	public static var XMLNS = xmpp.NS.PROTOCOL+"/pubsub";
	
	public var subscribe : { node : String, jid : String };
	public var unsubscribe : { node : String, jid : String, subid : String };
	public var create : String;
	public var configure : xmpp.DataForm;
	public var subscription : xmpp.pubsub.Subscription;
	public var subscriptions : xmpp.pubsub.Subscriptions;
	public var items : xmpp.pubsub.Items;
	public var publish : xmpp.pubsub.Publish;
	public var retract : xmpp.pubsub.Retract;
	public var affiliations : xmpp.pubsub.Affiliations;
	public var options : xmpp.pubsub.Options;
	
	public function new() {}
	
	public function toXml() : Xml {
		var x = Xml.createElement( "pubsub" );
		x.set( "xmlns", XMLNS );
		if( subscribe != null ) {
			var e = Xml.createElement( "subscribe" );
			e.set( "jid", subscribe.jid );
			if( subscribe.node != null ) e.set( "node", subscribe.node );
			x.addChild( e );
			return x;
		}
		if( unsubscribe != null ) {
			var e = Xml.createElement( "unsubscribe" );
			e.set( "jid", unsubscribe.jid );
			if( unsubscribe.node != null ) e.set( "node", unsubscribe.node );
			if( unsubscribe.subid != null ) e.set( "subid", unsubscribe.subid );
			x.addChild( e );
			return x;
		}
		if( create != null ) {
			var e = Xml.createElement( "create" );
			e.set( "node", create );
			x.addChild( e );
			var c = Xml.createElement( "configure" );
			if( configure != null )
				c.addChild( configure.toXml() );
			e.addChild( c );
			return x;
		}
		if( subscriptions != null ) {
			x.addChild( subscriptions.toXml() );
			return x;
		}
		if( publish != null ) {
			x.addChild( publish.toXml() );
			return x;
		}
		if( items != null ) {
			x.addChild( items.toXml() );
			return x;
		}
		if( retract != null ) {
			x.addChild( retract.toXml() );
			return x;
		}
		if( affiliations != null ) {
			x.addChild( affiliations.toXml() );
			return x;
		}
		return null;
	}
	
	public static function parse( x : Xml ) : xmpp.PubSub {
		var p = new xmpp.PubSub();
		for( e in x.elements() ) {
			switch( e.nodeName ) {
			case "subscribe" :
				p.subscribe = { node : e.get( "node" ), jid : e.get( "jid" ) };
			case "unsubscribe" :
				p.unsubscribe = { node : e.get( "node" ), jid : e.get( "jid" ), subid : e.get( "subid" )  };
			case "create" :
				p.create = e.get( "node" );
			case "configure" :
				p.configure = xmpp.DataForm.parse( e.firstElement() );
			case "subscription" :
				p.subscription = xmpp.pubsub.Subscription.parse( e );
			case "subscriptions" :
				p.subscriptions = xmpp.pubsub.Subscriptions.parse( e );
			case "items" :
				p.items = xmpp.pubsub.Items.parse( e );
			case "retract" :
				p.retract = xmpp.pubsub.Retract.parse( e );
			case "publish" :
				p.publish = xmpp.pubsub.Publish.parse( e );
			case "affiliations" :
				p.affiliations = xmpp.pubsub.Affiliations.parse( e );
			case "options" :
				p.options = xmpp.pubsub.Options.parse( e );
			}
		}
		return p;
	}
	
}
