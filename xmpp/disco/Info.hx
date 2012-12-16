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
package xmpp.disco;

class Info {
	
	public static var XMLNS(default,null) : String = xmpp.Packet.PROTOCOL+'/disco#info';
	
	/***/
	public var identities : Array<Identity>; 
	
	/** List of features/namespaces */
	public var features : Array<String>;
	
	/** Specific node */
	public var node : String;
	
	/** Dataform */
	public var x : Xml;
	
	public function new( ?identities : Array<Identity>, ?features : Array<String>, ?node : String ) {
		this.identities = ( identities == null ) ? new Array() : identities;
		this.features = ( features == null ) ? new Array() : features;
		this.node = node;
	}

	public function toXml() : Xml {
		var x = xmpp.IQ.createQueryXml( XMLNS );
		if( node != null ) x.set( "node", node );
		for( i in identities ) {
			var ix = Xml.createElement( 'identity' );
			if( i.category != null ) ix.set( "category", i.category );
			if( i.name != null ) ix.set( "name", i.name );
			if( i.type != null ) ix.set( "type", i.type );
			x.addChild( ix );
		}
		if( features.length > 0 ) {
			for( f in features ) {
				var fx = Xml.createElement( 'feature' );
				fx.set( "var", f );
				x.addChild( fx );
			}
		}
		if( this.x != null )
			x.addChild( this.x );
		return x;
	}
	
	public static function parse( x : Xml ) : Info {
		var i = new Info( null, null, x.get( "node" ) );
		for( e in x.elements() ) {
			switch( e.nodeName ) {
			case "feature"  : i.features.push( e.get( "var" ) );
			case "identity" : i.identities.push( { category : e.get( "category" ),
												   name : e.get( "name" ),
												   type : e.get( "type" ) } );
			case "x" : i.x = e;
			}
		}
		return i;
	}
	
}
