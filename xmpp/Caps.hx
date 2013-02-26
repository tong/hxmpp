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

import jabber.util.Base64;
import jabber.util.SHA1;
using xmpp.XMLUtil;

/**
	XEP-0085: Entity Capabilities: http://xmpp.org/extensions/xep-0115.html
*/
class Caps {
	
	public static var XMLNS(default,null) : String = xmpp.Packet.PROTOCOL+"/caps";
	
	/**
		The hashing algorithm used to generate the verification string, fe: sha-1.
	*/
	public var hash : String;
	
	/**
		A URI that uniquely identifies a software application, typically a URL at the website
		of the project or company that produces the software
	*/
	public var node : String;
	
	/**
		A string that is used to verify the identity and supported features of the entity
	*/
	public var ver : String;
	
	/**
		A set of nametokens specifying additional feature bundles.
		This attribute is deprecated!
	*/
	public var ext : String;
	
	public function new( hash : String, node : String, ver : String, ?ext : String ) {
		this.hash = hash;
		this.node = node;
		this.ver = ver;
		this.ext = ext;
	}
	
	public function toXml() : Xml {
		var x = Xml.createElement( "c" );
		x.ns( XMLNS );
		x.set( "hash", hash );
		x.set( "node", node );
		x.set( "ver", ver );
		if( ext != null ) x.set( "ext", ext );
		return x;
	}
	
	/**
	*/
	public static function parse( x : Xml ) : xmpp.Caps {
		return new Caps( x.get( "hash" ), x.get( "node" ), x.get( "ver" ), x.get( "ext" ) );
	}
	
	/**
		Returns true if the given xmpp packet has a caps property
	*/
	public static function has( p : xmpp.Packet ) : Bool {
		if( p.properties.length == 0 )
			return false;
		for( pr in p.properties ) {
			var x = pr;
			if( x.get( "xmlns" ) == XMLNS ) {
				//trace("CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC");
				return true;
			}
		}
		return false;
	}
	
	/**
		Extracts the caps information from given presence packet
	*/
	//TODO
	//public static function ofPacket( p : xmpp.Packet ) : xmpp.Caps {
	public static function fromPresence( p : xmpp.Packet ) : xmpp.Caps {
		for( p in p.properties )
			if( p.nodeName == "c" && p.get( "xmlns" ) == XMLNS )
				return parse( p );
		return null;
	}
	
	/**
		http://xmpp.org/extensions/xep-0115.html#ver
	*/
	public static function createVerfificationString( identities : Iterable<xmpp.disco.Identity>, features : Iterable<String>,
													  ?dataform : xmpp.DataForm ) : String {
		var b = new StringBuf();
		// sort/add identities
		var _i = Lambda.array( identities );
		_i.sort( sortIdentities );
		for( i in _i ) {
			b.add( i.category );
			b.add( "/" );
			b.add( i.type );
			b.add( "/" );
			// lang ??????
			b.add( i.name );
			b.add( "<" );
		}
		
		// sort/add features
		var _f = Lambda.array( features );
		_f.sort( sortString );
		b.add( _f.join( "<" ) );
		b.add( "<" );
		
		// sort/add dataform
		if( dataform != null ) {
			//TODO xmpp.X FORM_TYPE
			dataform.fields.sort( sortDataFormFields );
			for( f in dataform.fields ) {
				b.add( f.variable );
				b.add( "<" );
				for( v in f.values ) {
					b.add( v );
					b.add( "<" );
				}
			}
		}
		return Base64.encode( SHA1.encode( b.toString() ) );
	}
	
	static function sortIdentities( a : xmpp.disco.Identity, b : xmpp.disco.Identity ) : Int {
		return if( a.category > b.category ) 1;
		else if( a.category < b.category ) -1;
		else {
			if( a.type > b.type ) 1;
			else if( a.type < b.type ) -1;
			else {
				//TODO lang ?
				0;
			}
		}
	}

	static function sortDataFormFields( a : xmpp.dataform.Field, b : xmpp.dataform.Field ) {
		return ( a.variable == b.variable ) ? 0 : ( a.variable > b.variable ) ? 1 : -1;
	}
	
	static function sortString( a : String, b : String ) : Int {
		return ( a == b ) ? 0 : ( a > b ) ? 1 : -1;
	}
	
}
