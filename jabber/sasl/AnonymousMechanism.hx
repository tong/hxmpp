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
	XEP-0175: Best Practices for Use of SASL ANONYMOUS: http://xmpp.org/extensions/xep-0175.html
*/
class AnonymousMechanism {
	
	public static inline var NAME = 'ANONYMOUS';
	
	public var id(default,null) : String;
	
	/**
		Some servers may send a challenge to gather more information such as email address.
		Return any string value.
	*/
	public var challengeResponse : String;
	
	public function new( challengeResponse = "any" ) {
		this.id = NAME;
		this.challengeResponse = challengeResponse;
	}
	
	@:keep
	public function createAuthenticationText( user : String, host : String, pass : String, resource : String ) : String {
		return null; // Nothing to send in the <auth> body
	}
	
	@:keep
	public function createChallengeResponse( c : String ) : String {
		return challengeResponse; // Not required
	}
	
}
