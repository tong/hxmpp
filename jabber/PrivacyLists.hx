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
		stream.collect( 
			[new xmpp.filter.IQFilter(xmpp.PrivacyLists.XMLNS,xmpp.IQType.set)],
			handleListPush,
			true );
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
			me.onInfo( l.lists[0] );
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
				me.onError( new jabber.XMPPError( r ) );
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
			me.onRemoved( l.lists[0] );
		}, null, null, new xmpp.PrivacyList( name ) );
	}
	
	
	function _update( list : xmpp.PrivacyList ) {
		var me = this;
		sendRequest( xmpp.IQType.set, function(r) {
			var l = xmpp.PrivacyLists.parse( r.x.toXml() );
			me.onUpdate( l.lists[0] );
		}, null, null, list );
	}
	
	function sendRequest( iqType : xmpp.IQType, resultHandler : xmpp.IQ->Void,
						  ?active : String, ?_default : String, ?list : xmpp.PrivacyList ) {
		var iq = new xmpp.IQ( iqType );
		var xt = new xmpp.PrivacyLists();
		if( active != null ) xt.active = active;
		else if( _default != null ) xt._default = _default; 
		else if( list != null ) xt.lists.push( list );
		iq.x = xt;
		var me = this;
		stream.sendIQ( iq, function(r:xmpp.IQ) {
			switch( r.type ) {
				case result : resultHandler( r );
				case error : me.onError( new jabber.XMPPError( r ) );
				default : // #
			}
		} );
	}
	
	function handleListPush( iq : xmpp.IQ ) {
		trace("TODO händleListPush");
	}
	
}
