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

import xmpp.MUC;
import xmpp.muc.Decline;
import xmpp.muc.Destroy;
import xmpp.muc.Item;
import xmpp.muc.Status;
import xmpp.muc.Invite;

class MUCUser {
	
	public static var XMLNS(default,null) : String = xmpp.MUC.XMLNS+"#user";
	
	public var decline : Decline;
	public var destroy : Destroy;
	public var invite : Invite;
	public var item : Item;
	public var password : String;
	public var status : Status;
	
	public function new() {}
	
	public function toXml() : Xml {
		var x = IQ.createQueryXml( XMLNS, 'x' );
		if( invite != null ) x.addChild( invite.toXml() );
		if( decline != null ) x.addChild( decline.toXml() );
		if( item != null ) x.addChild( item.toXml() );
		if( password != null ) x.addChild( XMLUtil.createElement( "password", password ) );
		if( status != null ) x.addChild( status.toXml() );
		if( destroy != null ) x.addChild( destroy.toXml() );
		return x;
	}
	
	public static function parse( x : Xml ) : xmpp.MUCUser {
		var p = new MUCUser();
		for( e in x.elements() ) {
			switch( e.nodeName ) {
				case "item" :
					p.item = Item.parse( e );	
				case "status" :
					p.status = Status.parse( e );
				}
		}
		return p;
	}
	
}
