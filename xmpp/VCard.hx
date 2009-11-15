/*
 *	This file is part of HXMPP.
 *	Copyright (c)2009 http://www.disktree.net
 *	
 *	HXMPP is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Lesser General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  HXMPP is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 *	See the GNU Lesser General Public License for more details.
 *
 *  You should have received a copy of the GNU Lesser General Public License
 *  along with HXMPP. If not, see <http://www.gnu.org/licenses/>.
*/
package xmpp;

import util.XmlUtil;
import xmpp.vcard.Address;
import xmpp.vcard.EMail;
import xmpp.vcard.Label;
import xmpp.vcard.Name;
import xmpp.vcard.Org;
import xmpp.vcard.Photo;
import xmpp.vcard.Tel;
import xmpp.vcard.Geo;

/**
	<a href="http://www.xmpp.org/extensions/xep-0054.html">XEP-0054: vcard-temp</a><br/>
	Partial implemented!
*/
class VCard {
	
	public static inline var NODENAME = "vCard";
	public static inline var XMLNS = "vcard-temp";
	public static inline var PRODID = "-//HandGen//NONSGML vGen v1.0//EN";
	public static inline var VERSION = "2.0";
	
	public var fn 			: String;
	public var n 			: Name;
	public var nickname 	: String;
	public var photo 		: Photo;
	public var birthday 	: String;
	public var addresses 	: Array<Address>;
	public var label 		: Label;
	public var line 		: String;
	public var tels			: Array<Tel>;
	public var email 		: EMail;
	//public var userid 		: String;
	public var jid 			: String;
	public var mailer 		: String;
	public var tz 			: String;
	public var geo 			: Geo<Float>;
	public var title 		: String;
	public var role 		: String;
	public var logo 		: Photo;
	//public var agent :
	public var org 			: Org;
	//public var categories
	public var note 		: String;
	public var prodid 		: String;
	//public var rev : String;
	//public var sortString : String;
	//public var sound : Sound;
	//public var phonetic : String;
	//public var uid : String;
	public var url 			: String;
	public var desc 		: String;
	//public var class : _Class;
	//public var key : Key;
	
	public function new() {
		addresses = new Array();
		tels = new Array();
	}
	
	/*
	public function injectData( src : Xml ) {
	}
	*/
	
	public function toXml() : Xml {
		var x = Xml.createElement( NODENAME );
		x.set( "xmlns", XMLNS );
		if( fn != null ) x.addChild( XmlUtil.createElement( "FN", fn ) );
		if( n != null ) x.addChild( createTypedefXml( "N", n ) );
		if( nickname != null ) x.addChild( XmlUtil.createElement( "NICKNAME", nickname ) );
		if( photo != null )  x.addChild( createTypedefXml( "PHOTO", photo ) );
		if( birthday != null ) x.addChild( XmlUtil.createElement( "BDAY", birthday ) );
		for( address in addresses )
			x.addChild( createTypedefXml( "ADR", address ) );
		if( label != null )  x.addChild( createTypedefXml( "LABEL", label ) );
		if( line != null ) x.addChild( XmlUtil.createElement( "LINE", line ) );
		if( tels != null ) {
			for( tel in tels ) {
				x.addChild( createTypedefXml( "TEL", tel ) );
			}
		}
		if( email != null ) x.addChild( createTypedefXml( "EMAIL", email ) );
		if( jid != null ) x.addChild( XmlUtil.createElement( "JABBERID", jid ) );
		if( mailer != null ) x.addChild( XmlUtil.createElement( "MAILER", mailer ) );
		if( tz != null ) x.addChild( XmlUtil.createElement( "TZ", tz ) );
		if( geo != null ) x.addChild( createTypedefXml( "GEO", geo ) );
		if( title != null ) x.addChild( XmlUtil.createElement( "TITLE", title ) );
		if( role != null ) x.addChild( XmlUtil.createElement( "ROLE", role ) );
		if( logo != null ) x.addChild( createTypedefXml( "LOGO", logo ) );
		if( org != null ) x.addChild( createTypedefXml( "ORG", org ) );
		if( note != null ) x.addChild( XmlUtil.createElement( "NOTE", note ) );
		if( prodid != null ) x.addChild( XmlUtil.createElement( "PRODID", prodid ) );
		if( url != null ) x.addChild( XmlUtil.createElement( "URL", url ) );
		if( desc != null ) x.addChild( XmlUtil.createElement( "DESC", desc ) );
		return x;
	}
	
	public inline function toString() : String {
		return toXml().toString();
	}
	
	/*
	function addFieldXml( n : String, x : Xml ) {
		var v = Reflect.field( this, n );
		if( v != null ) x.addChild( XmlUtil.createElement( n.toUpperCase(), v ) );
	}
	*/
	
	function createTypedefXml<T>( name : String, e : T ) : Xml {
		var x = Xml.createElement( name );
		for( f in Reflect.fields( e ) ) {
			var v = Reflect.field( e, f );
			if( v != null ) {
				x.addChild( XmlUtil.createElement( f.toUpperCase(), v ) );
			}
		}
		return x;	
	}
	
	public static function parse( x : Xml ) : xmpp.VCard  {
		var vc = new xmpp.VCard();
		for( node in x.elements() ) {
			switch( node.nodeName ) {
			case "FN" : vc.fn = node.firstChild().nodeValue;
			case "N" : reflectTypedef( vc.n = untyped {}, node );
			case "NICKNAME", "NN" : vc.nickname = node.firstChild().nodeValue;
			case "PHOTO" : reflectTypedef( vc.photo = untyped {}, node ); //vc.photo = parsePhoto( node );
			case "BDAY" : vc.birthday = node.firstChild().nodeValue;
			case "ADR" :
				var adr : Dynamic = {};
				reflectTypedef( adr, node );
				vc.addresses.push( adr );
			case "LABEL" :
				//TODO
			case "LINE" : vc.line = node.firstChild().nodeValue;
			//TODO
			case "TEL" :
				var tel : Dynamic = {};
				reflectTypedef( tel, node );
				vc.tels.push( tel );
			//TODO
			case "EMAIL" :
				reflectTypedef( untyped vc.email, node );
			case "JABBERID" :  vc.jid = node.firstChild().nodeValue;
			case "MAILER" :  vc.mailer = node.firstChild().nodeValue;
			case "TZ" :  vc.tz = node.firstChild().nodeValue;
			case "GEO" : reflectTypedef( vc.geo = untyped {}, node );
			case "TITLE" : vc.title = node.firstChild().nodeValue;
			case "ROLE" : vc.role = node.firstChild().nodeValue;
			case "LOGO" : //vc.logo = parsePhoto( node );
			//case "AGENT" :
			case "ORG" : reflectTypedef( vc.org = untyped {}, node );
			case "NOTE" : vc.note = node.firstChild().nodeValue;
			case "PRODID" : vc.prodid = node.firstChild().nodeValue;
			case "URL" : vc.url = node.firstChild().nodeValue;
			case "DESC" : vc.desc = node.firstChild().nodeValue;
			}
		}
		return vc;
	}
	
	static function reflectTypedef<T>( e : T, x : Xml ) : T {
		for( n in x.elements() ) {
			var v : String = null;
			try v = n.firstChild().nodeValue catch( e : Dynamic ) {}
			if( v != null ) {
				Reflect.setField( e, n.nodeName.toLowerCase(), v );
			}
		}
		return e;
	}
	
}
