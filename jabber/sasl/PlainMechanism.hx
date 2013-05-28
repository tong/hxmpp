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
package jabber.sasl;

/**
	The PLAIN mechanism should not be used without adequate data security protection
	as this mechanism affords no integrity or confidentiality protections itself.
	
	The PLAIN Simple Authentication and Security Layer (SASL) Mechanism: http://www.ietf.org/rfc/rfc4616.txt
*/
class PlainMechanism {
	
	public static inline var NAME = 'PLAIN';
	
	public var id(default,null) : String;
	
	public function new() { 
		id = NAME;
	}
	
	@:keep
	public inline function createAuthenticationText( username : String, host : String, password : String, resource : String ) : String {
		var b = new StringBuf();
		b.add( String.fromCharCode( 0 ) );
		b.add( username );
		b.add( String.fromCharCode( 0 ) );
		b.add( password );
		return b.toString();
	}
	
	@:keep
	public inline function createChallengeResponse( c : String ) : String {
		return null; // This mechanism will never get a challenge from the server.
	}
	
}
