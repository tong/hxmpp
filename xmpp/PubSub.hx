/*
 *	This file is part of HXMPP.
 *	Copyright (c)2009 http://www.disktree.net
 *	
 *	HXMPP is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Lesser General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  HXMPP is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 *	See the GNU Lesser General Public License for more details.
 *
 *  You should have received a copy of the GNU Lesser General Public License
 *  along with HXMPP. If not, see <http://www.gnu.org/licenses/>.
*/
package xmpp;

class PubSub {
	
	public static var XMLNS = xmpp.Namespace.PROTOCOL+"/pubsub";
	
	public var subscribe : { node : String, jid : String };
	public var options : xmpp.pubsub.Options;
	public var affiliations : xmpp.pubsub.Affiliations;
	public var create : String;
	public var configure : xmpp.DataForm;
	public var items : xmpp.pubsub.Items;
	public var publish : xmpp.pubsub.Publish;
	public var retract : xmpp.pubsub.Retract;
	public var subscription : xmpp.pubsub.Subscription;
	public var subscriptions : xmpp.pubsub.Subscriptions;
	//public var default : { node : String, type : NodeType };
	public var unsubscribe : { node : String, jid : String, subid : String };
	
	public function new() {}
	
	public function toXml() : Xml {
		var x = Xml.createElement( "pubsub" );
		x.set( "xmlns", XMLNS );
		var c =	if( subscribe != null ) {
			var e = Xml.createElement( "subscribe" );
			e.set( "jid", subscribe.jid );
			if( subscribe.node != null ) e.set( "node", subscribe.node );
			e;
		} else if( unsubscribe != null ) {
			var e = Xml.createElement( "unsubscribe" );
			e.set( "jid", unsubscribe.jid );
			if( unsubscribe.node != null ) e.set( "node", unsubscribe.node );
			if( unsubscribe.subid != null ) e.set( "subid", unsubscribe.subid );
			e;
		} else if( create != null ) {
			var e = Xml.createElement( "create" );
			e.set( "node", create );
			var conf = Xml.createElement( "configure" );
			if( configure != null ) conf.addChild( configure.toXml() );
			e.addChild( conf );
			e;
		} else if( subscription != null ) {
			subscription.toXml();
		} else if( subscriptions != null ) {
			subscriptions.toXml();
		} else if( publish != null ) {
			publish.toXml();
		} else if( items != null ) {
			items.toXml();
		} else if( retract != null ) {
			retract.toXml();
		} else if( affiliations != null ) {
			affiliations.toXml();
		}
		if( c != null ) x.addChild( c );
		return x;
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
				if( p.create == null ) p.create = "";
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
	
	/*
	public static function fromPacket( p : xmpp.Packet ) : Caps {
	}
	*/
	
}
