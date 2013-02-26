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
	Calculates the MD5 hash on a web server instead of locally.
	This allows to create xmpp (web based) clients without including the (hardcoded) account password in the source code.
	
	Example of a remote calculator: https://gist.github.com/2464432
*/
class ExternalMD5Mechanism extends MD5Mechanism {
	
	public static inline var NAME = MD5Mechanism.NAME;
	
	/**
	 * The base URL of the challenge response calculator
	 */
	public var passwordStoreURL : String;
	
	public function new( passwordStoreURL : String, serverType : String = "xmpp" ) {
		super( serverType );
		this.passwordStoreURL = passwordStoreURL;
	}
	
	public override function createChallengeResponse( challenge : String ) : String {
		var c = MD5Calculator.parseChallenge( challenge );
		return haxe.Http.requestUrl( '$passwordStoreURL?host=$host&servertype=$serverType&username=$username&realm=${c.realm}&nonce=${c.nonce}' );
	}
	
}
