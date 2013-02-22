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

import xmpp.PacketFilter;
import xmpp.filter.PacketIDFilter;

/**
	Default XMPP packet collector implementation.
*/
class PacketCollector {
	
	/** This collectors filters */
	public var filters(default,null) : FilterList;
	
	/** Callbacks to which collected packets get delivered to. */
	public var handlers : Array<xmpp.Packet->Void>;
	
	/** Indicates if the the collector should get removed from the stream after collecting. */
	public var permanent : Bool;
	
	/** Block remaining collectors */
	public var block : Bool; //remove?
	
	public function new( filters : Iterable<PacketFilter>, handler : Dynamic->Void,
						 permanent : Bool = false,
						 block : Bool = false ) {
		handlers = new Array();
		this.filters = new FilterList();
		for( f in filters ) this.filters.push( f );
		if( handler != null ) handlers.push( handler );
		this.permanent = permanent;
		this.block = block;
	}

	/**
		Returns true if the given XMPP packet passes through all filters.
	*/
	public function accept( p : xmpp.Packet ) : Bool {
		for( f in filters )
			if( !f.accept( p ) )
				return false;
		return true;
	}
	
	/**
		Delivers the given packet to all registerd handlers.
	*/
	public function deliver( p : xmpp.Packet ) {
		for( h in handlers ) h( p );
	}

}

private class FilterList {
	
	var fid : Array<PacketFilter>;
	var f : Array<PacketFilter>;
	
	public function new() {
		clear();
	}
	
	public inline function clear( ) {
		fid = new Array<PacketFilter>();
		f = new Array<PacketFilter>();
	}
	
	public inline function iterator() : Iterator<PacketFilter> {
		return fid.concat( f ).iterator();
	}
	
	public inline function addIDFilter( _f : PacketIDFilter ) {
		fid.push( _f );
	}
	
	public inline function addFilter( _f : PacketFilter ) {
		f.push( _f );
	}
	
	public inline function push( _f : PacketFilter ) {
		( Std.is( _f, PacketIDFilter ) ) ? fid.push( _f ) : f.push( _f );
	}
	
	public inline function unshift( _f : PacketFilter ) {
		( Std.is( _f, PacketIDFilter ) ) ? fid.unshift( _f ) : f.unshift( _f );
	}
	
	public inline function remove( _f : PacketFilter ) : Bool {
		if( fid.remove( _f ) || f.remove( _f ) ) return true;
		return false;
	}
	
}
