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

import xmpp.vcard.Address;
import xmpp.vcard.EMail;
//import xmpp.vcard.Label;
import xmpp.vcard.Name;
import xmpp.vcard.Org;
import xmpp.vcard.Photo;
import xmpp.vcard.Tel;
import xmpp.vcard.Geo;

/**
	XEP-0054: vcard-temp: http://www.xmpp.org/extensions/xep-0054.html
	RFC2426: http://tools.ietf.org/html/rfc2426

	Depricated! Replaced by XEP0292 (see xmpp.VCard).
	This is just a subset of RFC2426!
*/
class VCardTemp {
	
	public static var XMLNS(default,null) : String = "vcard-temp";
	public static var PROD_ID(default,null) : String = "-//HandGen//NONSGML vGen v1.0//EN";
	public static var VERSION(default,null) : String = "2.0";
	
	public var fn : String;
	public var n : Name;
	public var nickname : String;
	public var photo : Photo;
	public var birthday : String;
	public var addresses : Array<Address>;
	public var tels	: Array<Tel>;
	public var email : EMail;
	public var jid : String;
	public var tz : String;
	public var geo : Geo<Float>;
	public var title : String;
	public var role : String;
	public var org : Org;
	public var url 	: String;
	public var desc : String;
	
	public function new() {
		addresses = new Array();
		tels = new Array();
	}
	
	public function toXml() : Xml {
		var x = emptyXml();
		addXmlField( "fn", x );
		addXmlField( "n", x );
		addXmlField( "nickname", x );
		if( photo != null ) {
			var p = Xml.createElement( "PHOTO" );
			p.addChild( XMLUtil.createElement( "TYPE", photo.type ) );
			p.addChild( XMLUtil.createElement( "BINVAL", photo.binval ) );
			x.addChild( p );
		}
		for( ad in addresses ) {
			var a = Xml.createElement( "ADR" );
			if( ad.home != null ) 	a.addChild( XMLUtil.createElement( "HOME", ad.home ) );
			if( ad.work != null )   a.addChild( XMLUtil.createElement( "WORK", ad.work ) );
			if( ad.postal != null ) a.addChild( XMLUtil.createElement( "POSTAL", ad.postal ) );
			if( ad.parcel != null ) a.addChild( XMLUtil.createElement( "PARCEL", ad.parcel ) );
			if( ad.pref != null )   a.addChild( XMLUtil.createElement( "PREF", ad.pref ) );
			if( ad.pobox != null )  a.addChild( XMLUtil.createElement( "POBOX", ad.pobox ) );
			if( ad.extadd != null ) a.addChild( XMLUtil.createElement( "EXTADD", ad.extadd ) );
			if( ad.street != null ) a.addChild( XMLUtil.createElement( "STREET", ad.street ) );
			if( ad.locality!=null ) a.addChild( XMLUtil.createElement( "LOCALITY", ad.locality ) );
			if( ad.region != null ) a.addChild( XMLUtil.createElement( "REGION", ad.region ) );
			if( ad.pcode != null )  a.addChild( XMLUtil.createElement( "PCODE", ad.pcode ) );
			if( ad.ctry != null )   a.addChild( XMLUtil.createElement( "CTRY", ad.ctry ) );
			x.addChild( a );
		}
		for( tel in tels ) {
			var t = Xml.createElement( "TEL" );
			if( tel.number != null ) t.addChild( XMLUtil.createElement( "NUMBER", tel.number ) );
			if( tel.home != null )   t.addChild( XMLUtil.createElement( "HOME", tel.home ) );
			if( tel.work != null )   t.addChild( XMLUtil.createElement( "WORK", tel.work ) );
			if( tel.voice != null )  t.addChild( XMLUtil.createElement( "VOICE", tel.voice ) );
			if( tel.fax != null )    t.addChild( XMLUtil.createElement( "FAX", tel.fax ) );
			if( tel.pager != null )  t.addChild( XMLUtil.createElement( "PAGER", tel.pager ) );
			if( tel.msg != null )    t.addChild( XMLUtil.createElement( "MSG", tel.msg ) );
			if( tel.cell != null )   t.addChild( XMLUtil.createElement( "CELL", tel.cell ) );
			if( tel.video != null )  t.addChild( XMLUtil.createElement( "VIDEO", tel.video ) );
			if( tel.bbs != null )    t.addChild( XMLUtil.createElement( "BBS", tel.bbs ) );
			if( tel.modem != null )  t.addChild( XMLUtil.createElement( "MODEM", tel.modem ) );
			if( tel.isdn != null )   t.addChild( XMLUtil.createElement( "ISDN", tel.isdn ) );
			if( tel.pcs != null )    t.addChild( XMLUtil.createElement( "PCS", tel.pcs ) );
			if( tel.pref != null )   t.addChild( XMLUtil.createElement( "PREF", tel.pref ) );
			x.addChild( t );
		}
		if( email != null ) {
			var e = Xml.createElement( "EMAIL" );
			if( email.home != null ) 	 e.addChild( XMLUtil.createElement( "HOME", email.home ) );
			if( email.work != null )     e.addChild( XMLUtil.createElement( "WORK", email.work ) );
			if( email.internet != null ) e.addChild( XMLUtil.createElement( "INTERNET", email.internet ) );
			if( email.pref != null )     e.addChild( XMLUtil.createElement( "PREF", email.pref ) );
			if( email.x400 != null ) 	 e.addChild( XMLUtil.createElement( "X400", email.x400 ) );
			if( email.userid != null )   e.addChild( XMLUtil.createElement( "USERID", email.userid ) );
			x.addChild( e );
		}
		addXmlField( "birthday", x );
		addXmlField( "tz", x );
		if( geo != null ) {
			var g  = Xml.createElement( "GEO" );
			g.addChild( XMLUtil.createElement( "LAT", Std.string( geo.lat ) ) );
			g.addChild( XMLUtil.createElement( "LON", Std.string( geo.lon ) ) );
			x.addChild( g );
		}
		addXmlField( "title", x );
		addXmlField( "role", x );
		if( org != null ) {
			var o = Xml.createElement( "ORG" );
			if( org.orgname != null ) o.addChild( XMLUtil.createElement( "NAME", org.orgname ) );
			if( org.orgunit != null ) o.addChild( XMLUtil.createElement( "UNIT", org.orgunit ) );
			x.addChild( o );
		}
		addXmlField( "url", x );
		addXmlField( "desc", x );
		return x;
	}
	
	function addXmlField( n : String, x : Xml, ?name : String ) {
		var v = Reflect.field( this, n );
		if( v != null )
			x.addChild( XMLUtil.createElement( (name==null) ? n.toUpperCase() : name, v ) );
	}
	
	/**
		Returns true if the given vcard has a photo attached (all xmpp.vcard.Photo).
	*/
	public static function hasPhoto( vc : VCardTemp ) : Bool {
		return vc.photo != null && vc.photo.binval != null && vc.photo.type != null;
	}
	
	//public static function empty() : PacketElement {
	public static function emptyXml() : Xml {
		var x = Xml.createElement( "vCard" );
		XMLUtil.setNamespace( x, XMLNS );
		x.set( "version", VERSION );
		x.set( "prodid", PROD_ID );
		return x;
		
	}
	
	public static function parse( x : Xml ) : VCardTemp  {
		var vc = new xmpp.VCardTemp();
		for( e in x.elements() ) {
			switch( e.nodeName ) {
			case "FN" :
				if( e.firstChild() != null ) vc.fn = e.firstChild().nodeValue;
			case "N" :
				vc.n = cast {};
				for( n in e.elements() ) {
					if( n.firstChild() != null ) {
						var v = n.firstChild().nodeValue;
						if( v != null ) {
							switch( n.nodeName ) {
							case "FAMILY" : vc.n.family = v;
							case "GIVEN"  : vc.n.given = v;
							case "MIDDLE" : vc.n.middle = v;
							case "PREFIX" : vc.n.prefix = v;
							case "SUFFIX" : vc.n.suffix = v;
							}
						}
					}
				}
			case "NICKNAME" :
				if( e.firstChild() != null ) vc.nickname = e.firstChild().nodeValue;
			case "PHOTO" :
				vc.photo = parsePhoto( e );
			case "BDAY","BIRTHDAY" :
				if( e.firstChild() != null ) vc.birthday = e.firstChild().nodeValue;
			case "ADR" :
				var a : Address = untyped {};
				for( n in e.elements() ) {
					if( n.firstChild() != null ) {
						var v = n.firstChild().nodeValue;
						if( v != null ) {
							switch( n.nodeName ) {
							case "HOME" :  a.home = v;
							case "WORK" : a.work = v;
							case "POSTAL" : a.postal = v;
							case "PARCEL" : a.parcel = v;
							//case "DOM/INTL" :
							case "PREF" : a.pref = v;
							case "POBOX" : a.pobox = v;
							case "EXTADD" : a.extadd = v;
							case "STREET" : a.street = v;
							case "LOCALITY" : a.locality = v;
							case "REGION" : a.region = v;
							case "PCODE" : a.pcode = v;
							case "CTRY" : a.ctry = v;
							}
						}
					}
				}				
				vc.addresses.push( a );
			case "TEL" :
				var t : Tel = untyped {};
				for( n in e.elements() ) {
					if( n.firstChild() != null ) {
						var v = n.firstChild().nodeValue;
						if( v != null ) {
							switch( n.nodeName ) {
							case "NUMBER" :  t.number = v;
							case "HOME" :  t.home = v;
							case "WORK" : t.work = v;
							case "VOICE" :  t.voice = v;
							case "FAX" : t.fax = v;
							case "PAGER" :  t.pager = v;
							case "MSG" : t.msg = v;
							case "CELL" : t.cell = v;
							case "VIDEO" : t.video = v;
							case "BBS" : t.bbs = v;
							case "MODEM" : t.modem = v;
							case "ISDN" : t.isdn = v;
							case "PCS" : t.pcs = v;
							case "PREF" : t.pref = v;
							}
						}
					}
				}
				vc.tels.push( t );
			case "EMAIL" :
				//vc.email = untyped {};
				var em : EMail = untyped {};
				for( n in e.elements() ) {
					if( n.firstChild() != null ) {
						var v = n.firstChild().nodeValue;
						if( v != null ) {
							switch( n.nodeName ) {
							case "HOME" :  em.home = v;
							case "WORK" : em.work = v;
							case "INTERNET" : em.internet = v;
							case "PREF" : em.pref = v;
							case "X400" : em.x400 = v;
							case "USERID" : em.userid = v;
							}
						}
					}
				}
				vc.email = em;
			case "JABBERID" :  vc.jid = e.firstChild().nodeValue;
			case "TZ" :  vc.tz = e.firstChild().nodeValue;
			case "GEO" :
				vc.geo = untyped {};
				for( n in e.elements() ) {
					if( n.firstChild() != null ) {
						var v : String = n.firstChild().nodeValue;
						if( v != null ) {
							switch( n.nodeName ) {
							case "LAT" : vc.geo.lat = Std.parseFloat( v );
							case "LON" : vc.geo.lon = Std.parseFloat( v );
							}
						}
					}
				}
			case "TITLE" :
				if( e.firstChild() != null ) vc.title = e.firstChild().nodeValue;
			case "ROLE" :
				if( e.firstChild() != null ) vc.role = e.firstChild().nodeValue;
			case "ORG" :
				vc.org = untyped {};
				for( n in e.elements() ) {
					if( n.firstChild() != null ) {
						var v = n.firstChild().nodeValue;
						if( v != null ) {
							switch( n.nodeName ) {
							case "ORGNAME" :  vc.org.orgname = v;
							case "ORGUNIT" :  vc.org.orgunit = v;
							}
						}
					}
				}
			case "URL" :
				if( e.firstChild() != null ) vc.url = e.firstChild().nodeValue;
			case "DESC" :
				if( e.firstChild() != null )vc.desc = e.firstChild().nodeValue;
			}
		}
		return vc;
	}
	
	static function parsePhoto( x : Xml ) : Photo {
		var p : Photo = untyped {};
		for( e in x.elements() ) {
			if( e.firstChild() != null ) {
				var v = e.firstChild().nodeValue;
				if( v != null ) {
					switch( e.nodeName ) {
					case "TYPE" : p.type = v;
					case "BINVAL" : p.binval = v;
					}
				}
			}
		}
		return p;
	}
	
}
