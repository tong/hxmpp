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

import xmpp.PacketFilter;
import xmpp.filter.PacketIDFilter;

/**
	List of packet filters of a packet colelctor.
*/
class FilterList {
	
	var f_id : Array<xmpp.PacketFilter>;
	var f : Array<xmpp.PacketFilter>;
	
	public function new() {
		clear();
	}
	
	public function iterator() : Iterator<PacketFilter> {
		return f_id.concat( f ).iterator();
	}
	
	public function addIDFilter( _f : PacketIDFilter ) {
		f_id.push( _f );
	}
	
	public function addFilter( _f : PacketFilter ) {
		f.push( _f );
	}
	
	public function push( _f : PacketFilter ) {
		( Std.is( _f, PacketIDFilter ) ) ? f_id.push( _f ) : f.push( _f );
	}
	
	public function unshift( _f : PacketFilter ) {
		( Std.is( _f, PacketIDFilter ) ) ? f_id.unshift( _f ) : f.unshift( _f );
	}
	
	public function remove( _f : PacketFilter ) : Bool {
		if( f_id.remove( _f ) || f.remove( _f ) ) return true;
		return false;
	}
	
	public function clear( ) {
		f_id = new Array<PacketFilter>();
		f = new Array<PacketFilter>();
	}
	
	/*
	public function destroy( ) {
		for( f in f_id ) { f = null; }
		for( f in f ) { f = null; }
		clear();
	}
	*/
	
}
