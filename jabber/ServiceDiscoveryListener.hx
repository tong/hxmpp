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
package jabber;

import jabber.stream.PacketCollector;
import xmpp.IQ;
import xmpp.filter.IQFilter;

/**
	<a href="http://www.xmpp.org/extensions/xep-0030.html">XEP 30 - ServiceDiscovery</a><br/>
	Listens/Answers incoming service discovery requests.
*/
class ServiceDiscoveryListener {
	
	public static var defaultIdentity = { type : "pc", name : "HXMPP", category : "client" };
	
	public var stream(default,null) : Stream;
	public var identities : Array<xmpp.disco.Identity>;
	
	/** Custom info request handler relay */
	public var onInfoQuery : IQ->IQ;
	#if JABBER_COMPONENT
	/** Custom items request handler relay */
	public var onItemQuery : IQ->IQ;
	#end
	
	public function new( stream : Stream, ?identities : Array<xmpp.disco.Identity> ) {
		if( !stream.features.add( xmpp.disco.Info.XMLNS )
			#if JABBER_COMPONENT || !stream.features.add( xmpp.disco.Items.XMLNS ) #end )
			throw "ServiceDiscovery listener already added";
		this.stream = stream;
		this.identities = ( identities == null ) ? [defaultIdentity] : identities;
		stream.collect( [cast new IQFilter( xmpp.disco.Info.XMLNS, null, xmpp.IQType.get )], handleInfoQuery, true );
		#if JABBER_COMPONENT
		stream.collect( [cast new IQFilter( xmpp.disco.Items.XMLNS, null, xmpp.IQType.get )], handleItemsQuery, true );
		#end
	}
	
	function handleInfoQuery( iq : IQ ) {
		// TODO just attach the extended info ()
		if( onInfoQuery != null ) { // redirect to custom handler
			var r = onInfoQuery( iq );
			if( r != null ) {
				stream.sendPacket( r );
				return;
			}
		}
		var r = new IQ( xmpp.IQType.result, iq.id, iq.from, stream.jidstr );
		r.x = new xmpp.disco.Info( identities, Lambda.array( stream.features ) );
		stream.sendData( r.toString() );
	}
	
	#if JABBER_COMPONENT
	function handleItemsQuery( iq : IQ ) {
		if( onItemQuery != null ) { // redirect to custom handler
			var r = onItemQuery( iq );
			if( r != null ) {
				stream.sendPacket( r );
				return;
			}
		}
		var s : jabber.component.Stream = cast stream;
		var r = IQ.createResult( iq );
		r.x = s.items;
		s.sendPacket( r );
	}
	#end
	
}
