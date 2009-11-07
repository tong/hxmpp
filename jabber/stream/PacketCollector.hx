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
package jabber.stream;

//TODO move into collector class.

private class Filters {
	
	var f_id : Array<xmpp.PacketFilter>;
	var f : Array<xmpp.PacketFilter>;
	
	public function new() {
		clear();
	}
	
	public function iterator() : Iterator<xmpp.PacketFilter> {
		return f_id.concat( f ).iterator();
	}
	
	public function push( _f : xmpp.PacketFilter ) {
		if( Std.is( _f, xmpp.filter.PacketIDFilter ) ) f_id.push( _f );
		else f.push( _f );
	}
	
	public function unshift( _f : xmpp.PacketFilter ) {
		if( Std.is( _f, xmpp.filter.PacketIDFilter ) ) f_id.unshift( _f );
		else f.unshift( _f );
	}
	
	public function remove( _f : xmpp.PacketFilter ) : Bool {
		if( f_id.remove( _f ) ) return true;
		if( f.remove( _f ) ) return true;
		return false;
	}
	
	public function clear( ) {
		f_id = new Array<xmpp.PacketFilter>();
		f = new Array<xmpp.PacketFilter>();
	}
}

/**
*/
class PacketCollector {
	
	/** */
	public var filters(default,null) : Filters; //TODO Array(s) for sorting ?
	/** Callbacks to which collected packets get delivered to. */
	public var handlers : Array<xmpp.Packet->Void>;
	/** Indicates if the the collector should get removed from the streams after collecting. */
	public var permanent : Bool;
	/** Block remaining collectors. */
	public var block : Bool;
	/** */
	public var timeout(default,setTimeout) : PacketTimeout;
	
	public function new( filters : Iterable<xmpp.PacketFilter>, handler : Dynamic->Void,
						 ?permanent : Bool = false, ?timeout : PacketTimeout, ?block : Bool = false ) {
		
		handlers = new Array();
		this.filters = new Filters();
		for( f in filters )
			this.filters.push( f );
		if( handler != null )
			handlers.push( handler );
		this.permanent = permanent;
		this.block = block;
		this.setTimeout( timeout );
	}

	function setTimeout( t : PacketTimeout ) : PacketTimeout {
		if( timeout != null ) timeout.stop();
		timeout = null;
		if( t == null ) return null;
		if( permanent ) return null;
		timeout = t;
		timeout.collector = this;
		return timeout;
	}
	
	/**
		Returns Bool if the XMPP packet passes through all filters.
	*/
	public function accept( p : xmpp.Packet ) : Bool {
		for( f in filters ) {
			if( !f.accept( p ) )
				return false;
		}
		if( timeout != null ) timeout.stop();
		return true;
	}
	
	/**
		Delivers the given packet to all registerd handlers.
	*/
	public function deliver( p : xmpp.Packet ) {
		for( h in handlers ) h( p );
	}

}
