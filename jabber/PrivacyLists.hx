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

/**
	<a href="http://xmpp.org/extensions/xep-0016.html">XEP-0016: Privacy Lists</a><br>
	Extension for blocking communication with unknown or undesirable entities.<br>
	Oooold extension, use jabber.ComBlock instead.
*/
class PrivacyLists {
	
	public dynamic function onLists( l : xmpp.PrivacyLists  ) {}
	public dynamic function onInfo( l : xmpp.PrivacyList ) {}
	public dynamic function onUpdate( l : xmpp.PrivacyList ) {}
	public dynamic function onRemoved( l : xmpp.PrivacyList ) {}
	public dynamic function onActivate( l : String ) {}
	public dynamic function onDeactivate() {}
	public dynamic function onDefaultChange( l : String ) {}
	public dynamic function onError( e : jabber.XMPPError ) {}
	
	public var stream(default,null) : jabber.Stream;
	
	
	public function new( stream : Stream ) {
		
		if( !stream.features.add( xmpp.PrivacyLists.XMLNS ) )
			throw "PrivacyLists feature already added";
		this.stream = stream;
		
		stream.addCollector( new jabber.stream.PacketCollector([cast new xmpp.filter.IQFilter(xmpp.PrivacyLists.XMLNS,xmpp.IQType.set)], handleListPush, true ) );
	}
	
	
	public function loadLists() {
		var me = this;
		sendRequest( xmpp.IQType.get, function(r) {
			var l = xmpp.PrivacyLists.parse( r.x.toXml() );
			me.onLists( l );
		} );
	}
	
	public function load( name : String ) {
		var me = this;
		sendRequest( xmpp.IQType.get, function(r) {
			var l = xmpp.PrivacyLists.parse( r.x.toXml() );
			me.onInfo( l.list[0] );
		}, null, null, new xmpp.PrivacyList( name ) );
	}
	
	public function activate( name : String ) {
		var me = this;
		sendRequest( xmpp.IQType.set, function(r) {
			var l = xmpp.PrivacyLists.parse( r.x.toXml() );
			me.onActivate( l.active );
		}, name );
	}
	
	public function deactivate() {
		var me = this;
		sendRequest( xmpp.IQType.set, function(r) {
			me.onDeactivate();
		}, "" );
	}
	
	public function changeDefault( name : String ) {
		//TODO!!!!!!!!!
		var iq = new xmpp.IQ( xmpp.IQType.set );
		var ext = new xmpp.PrivacyLists();
		ext._default = name;
		iq.x = ext;
		var me = this;
		stream.sendIQ( iq, function(r:xmpp.IQ) {
			switch( r.type ) {
				case result :
					me.onDefaultChange( name );
				case error :
					me.onError( new jabber.XMPPError( me, r ) );
				default :
			}
		} );
	}
	
	public function update( list : xmpp.PrivacyList ) {
		_update( list );
	}
	
	public function add( list : xmpp.PrivacyList ) {
		_update( list );
	}
	
	public function remove( name : String ) {
		var me = this;
		sendRequest( xmpp.IQType.set, function(r) {
			var l = xmpp.PrivacyLists.parse( r.x.toXml() );
			me.onRemoved( l.list[0] );
		}, null, null, new xmpp.PrivacyList( name ) );
	}
	
	
	function _update( list : xmpp.PrivacyList ) {
		var me = this;
		sendRequest( xmpp.IQType.set, function(r) {
			var l = xmpp.PrivacyLists.parse( r.x.toXml() );
			me.onUpdate( l.list[0] );
		}, null, null, list );
	}
	
	function sendRequest( iqType : xmpp.IQType, resultHandler : xmpp.IQ->Void,
						  ?active : String, ?_default : String, ?list : xmpp.PrivacyList ) {
		var iq = new xmpp.IQ( iqType );
		var xt = new xmpp.PrivacyLists();
		if( active != null ) xt.active = active;
		else if( _default != null ) xt._default = _default; 
		else if( list != null ) xt.list.push( list );
		iq.x = xt;
		var me = this;
		stream.sendIQ( iq, function(r:xmpp.IQ) {
			switch( r.type ) {
				case result : resultHandler( r );
				case error : me.onError( new jabber.XMPPError( me, r ) );
				default : // #
			}
		} );
	}
	
	function handleListPush( iq : xmpp.IQ ) {
		trace("TODO händleListPush");
	}
	
}
