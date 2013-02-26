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
package xmpp;

import xmpp.ErrorPacket;

/**
*/
class StreamError extends ErrorPacket {
	
	public static var XMLNS(default,null) : String = "urn:ietf:params:xml:ns:xmpp-streams";
	
	public function new( condition : String,  ?text : String, ?lang : String, ?app : ApplicationErrorCondition) {
		super( condition, text, lang, app );
	}
	
	public function toXml() : Xml {
		#if flash //TODO
		return _toXml( "stream_error", XMLNS );
		#else
		return _toXml( "stream:error", XMLNS );
		#end
	}
	
	public static function parse( x : Xml ) : StreamError {
		var p = new StreamError( null );
		ErrorPacket.parseInto( p, x, XMLNS );
//		if( p.condition == null )
//			return null;
		return p;
	}
	
}
