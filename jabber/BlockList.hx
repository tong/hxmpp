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
	XEP 191 - Simple Communications Blocking: http://xmpp.org/extensions/xep-0191.html
*/
class BlockList {
	
	public dynamic function onLoad( i : Array<String> ) {}
	public dynamic function onBlock( i : Array<String> ) {}
	public dynamic function onUnblock( i : Array<String> ) {}
	public dynamic function onError( e : jabber.XMPPError ) {}
	
	public var stream(default,null) : jabber.Stream;
	
	public function new( stream : jabber.Stream ) {
		this.stream = stream;
	}
	
	/**
		Load list of blocked entities.
	*/
	public function load() {
		var iq = new xmpp.IQ();
		iq.x = new xmpp.BlockList();
		stream.sendIQ( iq, handleLoad );
	}
	
	/**
		Block recieving stanzas from entity.
	*/
	public function block( jids : Array<String> ) {
		var iq = new xmpp.IQ( xmpp.IQType.set );
		iq.x = new xmpp.BlockList( jids );
		stream.sendIQ( iq, handleBlock );
	}
	
	/**
		Unblock recieving stanzas from entity.
	*/
	public function unblock( ?jids : Array<String> ) {
		var iq = new xmpp.IQ( xmpp.IQType.set );
		iq.x = new xmpp.BlockList( jids, true );
		stream.sendIQ( iq, handleUnblock );
	}
	
	function handleLoad( iq : xmpp.IQ ) {
		switch( iq.type ) {
		case result : onLoad( xmpp.BlockList.parse( iq.x.toXml() ).items );
		case error : onError( new jabber.XMPPError( iq ) );
		default : //#
		}
	}
	
	function handleBlock( iq : xmpp.IQ ) {
		switch( iq.type ) {
		case result : onBlock( xmpp.BlockList.parse( iq.x.toXml() ).items );
		case error : onError( new jabber.XMPPError( iq ) );
		default : //#
		}
	}
		
	function handleUnblock( iq : xmpp.IQ ) {
		switch( iq.type ) {
		case result : onUnblock( xmpp.BlockList.parse( iq.x.toXml() ).items );
		case error : onError( new jabber.XMPPError( iq ) );
		default : //#
		}
	}
	
}
