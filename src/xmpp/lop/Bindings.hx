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

class Bindings extends List<Binding> {

	public var vm_id : String;

	public function new( vm_id : String ) {
		super();
		this.vm_id = vm_id;
	}

	public function toXml() : Xml {
		var x = Xml.createElement( "manage_bindings" );
		x.ns( xmpp.LOP.XMLNS );
		x.set( "vm_id", vm_id );
		for( b in iterator() ) {
			var e = Xml.createElement( "binding" );
			e.set( "name", b.name );
			if( b.value != null )  e.set( "value", b.value );
			if( b.datatype != null )  e.set( "datatype", b.datatype );
			x.addChild( e );
		}
		return x;
	}

	public static function parse( x : Xml ) : xmpp.lop.Bindings {
		var b = new Bindings( x.get( "vm_id" ) );
		for( e in x.elementsNamed( "binding" ) )
			b.add( { name : e.get( "name" ),
					 value : e.get( "value" ),
					 datatype : e.get( "datatype" ) } );
		return b;
	}

}
