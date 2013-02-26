/*
 * Copyright (c) 2012, disktree.net
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
package xmpp;

class PubSubEvent {
	
	public static var XMLNS(default,null) : String = PubSub.XMLNS+"#event";
	
	public var items : xmpp.pubsub.Items;
	public var configuration : { form : xmpp.DataForm, node : String };
	public var delete : String;
	public var purge : String;
	public var subscription : xmpp.pubsub.Subscription;
	
	public function new() {}
	
	public function toXml() : Xml {
		var x = IQ.createQueryXml( XMLNS, "event" );
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
