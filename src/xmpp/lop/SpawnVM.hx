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
package xmpp.lop;

using xmpp.XMLUtil;

class SpawnVM {
	
	public var species : String;
	public var id : String;
	public var password : String;
	
	public function new( species : String, ?id : String, ?password : String ) {
		this.species = species;
		this.id = id;
		this.password = password;
	}
	
	public function toXml() : Xml {
		var x = Xml.createElement( "spawn_vm" );
		x.ns( xmpp.LOP.XMLNS );
		if( species != null ) x.set( "vm_species", species );
		if( id != null ) x.set( "vm_id", id );
		if( password != null ) x.set( "farm_password", password );
		return x;
	}
	
	public static function parse( x : Xml ) : SpawnVM {
		return new SpawnVM( x.get( "vm_species" ), x.get( "vm_id" ), x.get( "farm_password" ) );
	}
	
}
