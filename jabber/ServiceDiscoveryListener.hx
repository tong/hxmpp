/*
 * Copyright (c) 2012, tong, disktree.net
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

import jabber.stream.PacketCollector;
import xmpp.IQ;
import xmpp.filter.IQFilter;

/**
	Listens/Answers incoming service discovery requests.
	XEP 30 - ServiceDiscovery: http://www.xmpp.org/extensions/xep-0030.html
*/
class ServiceDiscoveryListener {
	
	public static var defaultIdentity = { type : "pc", name : "HXMPP", category : "client" };
	
	public var stream(default,null) : Stream;
	
	/** */ //TODO hmmm here? not in stream?
	public var identities : Array<xmpp.disco.Identity>;
	
	/** Custom info request handler relay */
	public var onInfoQuery : IQ->IQ;
	
	/** Custom items request handler relay */
	public var onItemQuery : IQ->IQ;
	
	public function new( stream : Stream, ?identities : Array<xmpp.disco.Identity> ) {
		
		if( !stream.features.add( xmpp.disco.Info.XMLNS ) || !stream.features.add( xmpp.disco.Items.XMLNS ) )
			throw "service discovery listener already added";
			
		this.stream = stream;
		this.identities = ( identities == null ) ? [defaultIdentity] : identities;
		
		stream.collect( [new IQFilter( xmpp.disco.Info.XMLNS, xmpp.IQType.get )], handleInfoQuery, true );
		stream.collect( [new IQFilter( xmpp.disco.Items.XMLNS, xmpp.IQType.get )], handleItemsQuery, true );
	}
	
	function handleInfoQuery( iq : IQ ) {
		// TODO just >attach< the extended info ()
		if( onInfoQuery != null ) { // redirect to custom handler
			var r = onInfoQuery( iq );
			if( r != null ) {
				stream.sendPacket( r );
				return;
			}
		}
		// TODO
		/*
		var info = xmpp.disco.Info.parse();
		if( info.node != null ) {
			// send error
			return;
		}
		*/
		var r = new IQ( xmpp.IQType.result, iq.id, iq.from, stream.jid.toString() );
		r.x = new xmpp.disco.Info( identities, Lambda.array( stream.features ) );
		stream.sendData( r.toString() );
	}
	
	function handleItemsQuery( iq : IQ ) {
		if( onItemQuery != null ) { // redirect to custom handler
			var r = onItemQuery( iq );
			if( r != null ) {
				stream.sendPacket( r );
				return;
			}
		}
		var r = IQ.createResult( iq );
		#if JABBER_COMPONENT
		var s : jabber.component.Stream = cast stream;
		r.x = s.items;
		#else
		var s = stream;
		#end
		s.sendPacket( r );
	}
}
