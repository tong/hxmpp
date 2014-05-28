/*
 * Copyright (c) disktree.net
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

import xmpp.command.Action;
import xmpp.command.Actions;
import xmpp.command.Status;

using xmpp.XMLUtil;

/**
	http://xmpp.org/extensions/xep-0050.html
*/
class AdHocCommand {
	
	public static inline var XMLNS = "http://jabber.org/protocol/commands";
	
	public var node : String;
	public var action : xmpp.command.Action;
	public var status : xmpp.command.Status;
	public var sessionId : String;
	public var actions : Array<Actions>;
	public var child : Xml;
	//public var lang : String;
	//public var notes :
	
	public function new( node : String, ?action : xmpp.command.Action, ?sessionId : String ) {
		this.node = node;
		this.action = action;
		this.sessionId = sessionId;
		actions = new Array();
	}
	
	public function toXml() : Xml {
		var x = Xml.createElement( "command" );
		x.ns( XMLNS );
		x.set( "node", node );
		if( action != null ) x.set( "action", Std.string( action ) );
		if( sessionId != null ) x.set( "sessionid", sessionId );
		if( status != null ) x.set( "status", Std.string( status ) );
		if( actions.length > 0 ) {
			var e = Xml.createElement( "actions" );
			for( a in actions )
				e.addChild( Xml.createElement( Std.string( a ) ) );
			x.addChild( e );
		}
		if( child != null )
			x.addChild( child );
		return x;
	}
	
	public static function parse( x : Xml ) : xmpp.AdHocCommand {
		var c = new AdHocCommand( x.get( "node" ), cast x.get( "action" ), x.get( "sessionid" ) );
		c.status = cast x.get( "status" );
		//TODO parse actions
		c.child = x.firstElement();
		return c;
	}

}
