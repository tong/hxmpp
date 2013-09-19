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
package xmpp.pubsub;

class Affiliation {
	
	public var node : String;
	public var affiliation : AffiliationState;
	
	public function new( node : String, affiliation : AffiliationState ) {
		this.node = node;
		this.affiliation = affiliation;
	}
	
	public function toXml() : Xml {
		var x = Xml.createElement( "affiliation" );
		x.set( "node", node );
		x.set( "affiliation", Type.enumConstructor( affiliation ) );
		return x;
	}
	
	public static function parse( x : Xml) : Affiliation {
		return new Affiliation( x.get( "node" ), Type.createEnum( AffiliationState, x.get( "affiliation" ) ) );
	}
	
}
