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

class PubSubEvent {
	
	public static var XMLNS = xmpp.PubSub.XMLNS+"#event";
	
	public var items : xmpp.pubsub.Items;
	public var configuration : { form : xmpp.DataForm, node : String };
	public var delete : String;
	public var purge : String;
	public var subscription : xmpp.pubsub.Subscription;
	
	public function new() {
	}
	
	public function toXml() : Xml {
		var x = Xml.createElement( "event" );
		if( items != null ) {
			x.addChild( items.toXml() );
			return x;
		}
		if( configuration != null ) {
			var e = Xml.createElement( "configuration" );
			if( configuration.node != null ) e.set( "node", configuration.node );
			x.addChild( e );
			return x;
		}
		if( delete != null ) {
			var e = Xml.createElement( "delete" );
			e.set( "node", delete );
			x.addChild( e );
			return x;
		}
		if( purge != null ) {
			var e = Xml.createElement( "purge" );
			e.set( "node", purge );
			x.addChild( e );
			return x;
		}
		if( subscription != null ) {
			x.addChild( subscription.toXml() );
			return x;
		}
		return null;
	}
	
	public inline function toString() : String {
		return toXml().toString();
	}
	
	public static function parse( x : Xml ) : xmpp.PubSubEvent {
		var p = new PubSubEvent();
		for( e in x.elements() ) {
			switch( e.nodeName ) {
			case "items" :
				p.items = xmpp.pubsub.Items.parse( e );
			case "configuration" :
				var _f = e.elementsNamed( "x" ).next();
				p.configuration = { form : ( _f != null ) ? xmpp.DataForm.parse( _f ) : null,
									node : e.get( "node" ) };
			case "delete" :
				p.delete = e.get( "node" );
			case "purge" :
				p.purge = e.get( "node" );
			case "subscription" :
				p.subscription = xmpp.pubsub.Subscription.parse( e );
			}
			//..collections XEP 0248
		}
		return p;
	}
	
}
