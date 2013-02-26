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

using xmpp.XMLUtil;

class Jingle {
	
	static inline var _XMLNS = "urn:xmpp:jingle:";
	
	public static var XMLNS = _XMLNS+"1";
	public static var XMLNS_RTP = _XMLNS+"apps:rtp:1";
	public static var XMLNS_RTMP = _XMLNS+"apps:rtmp";
	public static var XMLNS_RTMFP = _XMLNS+"apps:rtmfp";
	public static var XMLNS_FILETRANSFER = _XMLNS+"apps:file-transfer:1";
	public static var XMLNS_S5B = _XMLNS+"transports:s5b:1";
	
	//public static var XMLNS_WEBRTC = "urn:xmpp:jingle:transports:webrtc:1"; // "apps:webrtc"; //TODO
	public static var XMLNS_RTC = XMLNS+"apps:rtc:1";
	
	public var action : xmpp.jingle.Action;
	public var initiator : String;
	public var responder : String;
	public var sid : String;
	public var content : Array<xmpp.jingle.Content>;
	public var reason : { type : xmpp.jingle.Reason, content : Xml };
	public var other : Array<Xml>;
	//public var layout : Layout;
	
	public function new( action : xmpp.jingle.Action, initiator : String, sid : String, ?responder : String ) {
		this.action = action;
		this.initiator = initiator;
		this.sid = sid;
		this.responder = responder;
		content = new Array();
		other = new Array();
	}
	
	public function toXml() : Xml {
		var x = Xml.createElement( "jingle" );
		x.ns( XMLNS );
		x.set( "action", StringTools.replace( Type.enumConstructor( action ), "_", "-" ) );
		x.set( "initiator", initiator );
		if( responder != null ) x.set( "responder", responder );
		x.set( "sid", sid );
		for( c in content ) x.addChild( c.toXml() );
		if( reason != null ) {
			var r = Xml.createElement( "reason" );
			var e = Xml.createElement( Type.enumConstructor( reason.type ) );
			if( reason.content != null ) e.addChild( reason.content );
			r.addChild( e );
			x.addChild( r );
		}
		for( e in other ) x.addChild( e );
		return x;
	}
	
	public static function parse( x : Xml ) : Jingle {
		var j = new xmpp.Jingle( Type.createEnum( xmpp.jingle.Action, StringTools.replace( x.get( "action" ), "-", "_" ) ),
								 x.get( "initiator" ),
								 x.get( "sid" ), 
								 x.get( "responder" ) );
		for( e in x.elements() ) {
			switch( e.nodeName ) {
			case "content" :
				j.content.push( xmpp.jingle.Content.parse( e ) );
			case "reason" :
				j.reason = { type : Type.createEnum( xmpp.jingle.Reason, e.firstChild().nodeName ),
							 content : e.firstChild().firstChild() };
			default :
				j.other.push( e );
			}
		}
		return j;
	}
	
}
