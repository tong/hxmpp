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
package jabber.jingle;

//TODO
//import jabber.jingle.io.Transport;
import jabber.io.Transport;

/**
	Abstract base for jingle session listeners.

	T:Transport The kind of transport this class uses
	R:SessionResponder<T> The kind of responder this class generates

*/
class SessionListener<T:Transport,R:SessionResponder<T>> {
	
	public var stream(default,null) : jabber.Stream;
	
	/** The handler/callback a responder get passed to */
	public var handler(default,setHandler) : R->Void;
	
	/** The namespace of this jingle implementation */
	public var xmlns(default,null) : String;
	
	var c : PacketCollector;
	
	function new( stream : jabber.Stream, handler : R->Void, xmlns : String ) {
		if( !stream.features.add( xmlns ) )
			throw "jingle listener already added ["+xmlns+"]";
		this.stream = stream;
		this.handler = handler;
		this.xmlns = xmlns;
	}
	
	public function dispose() {
		stream.features.remove( xmlns );
		setHandler( null );
	}
	
	function setHandler( h : R->Void ) : R->Void {
		if( h == null ) {
			if( c != null ) {
				stream.removeCollector( c );
				c = null;
			}
		} else if( c == null )
			c = stream.collect( [new xmpp.filter.JingleFilter( xmlns )], handleRequest, true );
		return handler = h;
	}
	
	function handleRequest( iq : xmpp.IQ ) {
		if( handler == null )
			return;
		var r = createResponder();
		if( r.handleRequest( iq ) ) {
			handler( r );
		}
	}
	
	function createResponder() : R { // override me
		#if jabber_debug
		return throw 'abstract method';
		#else
		return null;
		#end
	}
	
}
