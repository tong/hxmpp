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

import xmpp.IQ;
import xmpp.IQType;
import xmpp.disco.Info;
import xmpp.disco.Items;

/**
	Manages discovery of services from XMPP entities.
	Two kinds of information can be discovered:
		The identity and capabilities of an entity, including the protocols and features it supports.
		The items associated with an entity, such as the list of rooms hosted at a multi-user chat service.

	XEP 30 - ServiceDiscovery: http://www.xmpp.org/extensions/xep-0030.html
*/
class ServiceDiscovery {
	
	public dynamic function onInfo( jid : String, info : Info ) {}
	public dynamic function onItems( jid : String, items : Items ) {}
	public dynamic function onError( e : XMPPError ) {}
	
	public var stream(default,null) : jabber.Stream;
	
	public function new( stream : jabber.Stream ) {
		this.stream = stream;
	}
	
	/**
		Query entity for information.
	*/
	public function info( ?jid : String, ?node : String ) {
		#if !jabber_component
		if( jid == null )
			jid = stream.jid.domain;
		#end
		var r = new IQ( IQType.get, null, jid );
		r.x = new Info( null, null, node );
		stream.sendIQ( r, handleInfo );
	}
	
	/**
		Query entity for items.
	*/
	public function items( ?jid : String, ?node : String ) {
		#if !jabber_component
		if( jid == null )
			jid = stream.jid.domain;
		#end
		var r = new IQ( IQType.get, null, jid );
		r.x = new Items( node );
		stream.sendIQ( r, handleItems );
	}
	
	function handleInfo( iq : IQ ) {
		switch( iq.type ) {
		case result :
			onInfo( iq.from, Info.parse( iq.x.toXml() ) );
		case error :
			//trace("TODO");
			//trace( iq.errors[0] );
			onError( new XMPPError( iq ) );
			/* 
			trace("TODO error","error");
			trace(iq,"error");
			//TODO wtf .. this error packet thing handling is such a shit !
			if( iq.errors[0] != null ) {
				onError( new XMPPError( iq ) );
			} else {
				onError( null );
			}
			trace("-------------------------------------------------");
			*/
			
		default :
		}
	}
	
	function handleItems( iq : IQ ) {
		switch( iq.type ) {
		case result :
			onItems( iq.from, Items.parse( iq.x.toXml() ) );
		case error :
			//TODO wtf .. this error packet thing handling is such a shit !
			if( iq.errors[0] != null ) {
				onError( new XMPPError( iq ) );
			}
		default:
		}
	}
	
}
