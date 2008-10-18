package xmpp;

import xmpp.MUC;
import xmpp.muc.Decline;
import xmpp.muc.Destroy;
import xmpp.muc.Item;
import xmpp.muc.Status;
import xmpp.muc.Invite;


class MUCUser {
	
	public static var XMLNS = xmpp.MUC.XMLNS+"#user";
	
	public var decline : Decline;
	public var destroy : Destroy;
	public var invite : Invite;
	public var item : Item;
	public var password : String;
	public var status : Status;
	
	
	public function new() {}
	
	
	public function toXml() : Xml {
		var x = Xml.createElement( "x" );
		x.set( "xmlns", XMLNS );
		if( invite != null ) x.addChild( invite.toXml() );
		if( decline != null ) x.addChild( decline.toXml() );
		if( item != null ) x.addChild( item.toXml() );
		if( password != null ) x.addChild( util.XmlUtil.createElement( "password", password ) );
		if( status != null ) x.addChild( status.toXml() );
		if( destroy != null ) x.addChild( destroy.toXml() );
		return x;
	}
	
	public inline function toString() : String {
		return toXml().toString();
	}
	
	
	public static function parse( x : Xml ) : xmpp.MUCUser {
		var ext = new xmpp.MUCUser();
		for( e in x.elements() ) {
			if( e.nodeName != "x" || e.get( "xmlns" ) != XMLNS ) continue;
			for( ee in e.elements() ) {
				switch( ee.nodeName ) {
					//
					case "item" : ext.item = Item.parse( ee );
					case "status" : ext.status = Status.parse( ee );
				}
			}
		}
		return ext;
	}
	
}
