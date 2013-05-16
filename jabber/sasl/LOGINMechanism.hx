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
	LOGIN SASL Mechanism.
	
	Obsolete clear-text user/password Simple Authentication and Security Layer (SASL) mechanism called the LOGIN mechanism.
	The LOGIN mechanism was intended to be used, in combination with data confidentiality services provided by a lower layer,
	in protocols which lack a simple password authentication command.

	http://tools.ietf.org/id/draft-murchison-sasl-login-00.txt
*/
class LOGINMechanism {
	
	public static inline var NAME = 'LOGIN';
	
	public var id(default,null) : String;

	var password : String;
	var username : String;
	var nChallenges : Int;
	
	public inline function new() { 
		id = NAME;
	}
	
	@:keep
	public function createAuthenticationText( username : String, host : String, password : String, resource : String ) : String {
		this.password = password;
		this.username = username;
		nChallenges = 0;
		return null;
	}
	
	@:keep
	public function createChallengeResponse( c : String ) : String {
		return ( ++nChallenges == 1 ) ? username : password;
	}
	
}
