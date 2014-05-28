/*
 * Copyright (c) disktree.net
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

/**
	Extension for blocking communication with unknown or undesirable entities.
	Depricated! Use jabber.ComBlock instead.

	XEP-0016: Privacy Lists: http://xmpp.org/extensions/xep-0016.html
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
			throw "privacylists feature already added";
		this.stream = stream;
		stream.collectPacket( [new xmpp.filter.IQFilter(xmpp.PrivacyLists.XMLNS,set)], handleListPush, true );
	}
	
	public function loadLists() {
		sendRequest( get, function(r) {
			var l = xmpp.PrivacyLists.parse( r.x.toXml() );
			onLists( l );
		} );
	}
	
	public function load( name : String ) {
		sendRequest( get, function(r) {
			var l = xmpp.PrivacyLists.parse( r.x.toXml() );
			onInfo( l.lists[0] );
		}, null, null, new xmpp.PrivacyList( name ) );
	}
	
	public function activate( name : String ) {
		sendRequest( set, function(r) {
			var l = xmpp.PrivacyLists.parse( r.x.toXml() );
			onActivate( l.active );
		}, name );
	}
	
	public function deactivate() {
		sendRequest( set, function(r) {
			onDeactivate();
		}, "" );
	}
	
	public function changeDefault( name : String ) {
		var iq = new IQ( set );
		var ext = new xmpp.PrivacyLists();
		ext._default = name;
		iq.x = ext;
		stream.sendIQ( iq, function(r:IQ) {
			switch r.type {
			case result :
				onDefaultChange( name );
			case error :
				onError( new jabber.XMPPError( r ) );
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
		sendRequest( set, function(r) {
			var l = xmpp.PrivacyLists.parse( r.x.toXml() );
			onRemoved( l.lists[0] );
		}, null, null, new xmpp.PrivacyList( name ) );
	}
	
	
	function _update( list : xmpp.PrivacyList ) {
		sendRequest( set, function(r) {
			var l = xmpp.PrivacyLists.parse( r.x.toXml() );
			onUpdate( l.lists[0] );
		}, null, null, list );
	}
	
	function sendRequest( iqType : IQType, resultHandler : IQ->Void,
						  ?active : String, ?_default : String, ?list : xmpp.PrivacyList ) {
		var iq = new IQ( iqType );
		var xt = new xmpp.PrivacyLists();
		if( active != null ) xt.active = active;
		else if( _default != null ) xt._default = _default; 
		else if( list != null ) xt.lists.push( list );
		iq.x = xt;
		stream.sendIQ( iq, function(r:IQ) {
			switch r.type {
				case result : resultHandler( r );
				case error : onError( new jabber.XMPPError( r ) );
				default:
			}
		} );
	}
	
	function handleListPush( iq : IQ ) {
		trace("TODO händleListPush");
	}
	
}
