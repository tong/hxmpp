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
package jabber.client;

import xmpp.IQ;
import xmpp.IQType;

/**
	Abstract base for vcard classes (jabber.client.VCard and jabber.client.VCardTemp)
*/
class VCardBase<T> {
	
	/** VCard loaded callback*/
	public dynamic function onLoad( jid : String, data : T ) {}
	/** Own vcard updated callback */
	public dynamic function onUpdate() {}
	/** */
	public dynamic function onError( e : jabber.XMPPError ) {}
	
	public var stream(default,null) : Stream;
	
	function new( stream : Stream ) {
		this.stream = stream;
	}
	
	/**
		Requests to load the vcard from the given entity or own no jid is given.
	*/
	public function load( ?jid : String  ) {
		#if jabber_debug throw "abstract method"; #end
	}
	
	/**
		Update own vcard.
	*/
	public function update( vc : T ) {
		var iq = new IQ( set, null, stream.jid.domain );
		iq.x = cast vc;
		stream.sendIQ( iq, handleUpdate );
	}
	
	function _load( x : Xml, jid : String ) {
		var iq = new IQ( null, null, jid );
		iq.properties.push( x );
		stream.sendIQ( iq, handleLoad );
	}
	
	function handleLoad( iq : IQ ) {
		switch( iq.type ) {
		case result :
			_handleLoad( iq );
			//onLoad( iq.from, ( iq.x != null ) ? xmpp.VCardTemp.parse( iq.x.toXml() ) : null );
		case error :
			onError( new jabber.XMPPError( iq ) );
		default : //
		}
	}
	
	function _handleLoad( iq : IQ ) {
		#if jabber_debug
		throw "abstract method";
		#end
	}
	
	function handleUpdate( iq : IQ ) {
		switch( iq.type ) {
		case result : onUpdate();
		case error : onError( new jabber.XMPPError( iq ) );
		default : //
		}
	}
	
}
