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
package jabber;

/**
	Listens for incoming pubsub events from a given service.
	XEP-0060: Publish-Subscribe: http://xmpp.org/extensions/xep-0060.html
*/
class PubSubListener {
	
	/** Every(!) full pubsub event message */
	public dynamic function onMessage( m : xmpp.Message ) {}
	///** Just the pubsub event ( message may contain additional information, like delay,.. ! ) */
	//public dynamic function onEvent( service : String, event : xmpp.PubSubEvent ) {}
	
	/** New pubsub item(s) recieved */
	public dynamic function onItems( service : String, items : xmpp.pubsub.Items ) {}
	/** Configuration got changed */
	public dynamic function onConfig( service : String, config : { node : String, form : xmpp.DataForm } ) {}
	/** Node got deleted */
	public dynamic function onDelete( service : String, node : String ) {}
	/** Node got purged */
	public dynamic function onPurge( service : String, node : String ) {}
	/** Subscription action notification */
	public dynamic function onSubscription( service : String, subscription : xmpp.pubsub.Subscription ) {}
	
	public var stream(default,null) : Stream;
	
	var c : PacketCollector;
	
	public function new( stream : Stream, service : String ) {
		this.stream = stream;
		var filters : Array<xmpp.PacketFilter> = [ new xmpp.filter.PacketFromFilter( service ),
							  new xmpp.filter.MessageFilter( xmpp.MessageType.normal ),
						 	  new xmpp.filter.PacketPropertyFilter( xmpp.PubSubEvent.XMLNS, 'event' ) ];
		c = stream.collect( filters, handlePubSubEvent, true );
	}
	
	public function dispose() {
		stream.removeCollector( c );
	}
	
	function handlePubSubEvent( m : xmpp.Message ) {
		onMessage( m ); // fire EVERY event message
		var service = m.from;
		var event : xmpp.PubSubEvent = null;
		for( p in m.properties ) {
			if( p.nodeName == "event" ) {
				event = xmpp.PubSubEvent.parse( p );
				break; //?
			}
		}
		// fire event
		if( event.items != null ) {
			onItems( service, event.items );
		} else if( event.configuration != null ) {
			onConfig( service, event.configuration );
		} else if( event.delete != null ) {
			onDelete( service, event.delete );
		} else if( event.purge != null ) {
			onPurge( service, event.purge );
		} else if( event.subscription != null ) {
			onSubscription( service, event.subscription );
		} 
		//onEvent( service, event );
	}
	
}
