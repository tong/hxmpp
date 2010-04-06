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
package xmpp.pep;

/**
	Abstract base for personal event classes.
	The implementing class HAS TO HAVE a static XMLNS field (required by the jabber.PersonalEventListener)!
*/
class Event {
	
	public var nodeName(default,null) : String;
	public var xmlns(default,null) : String;
	
	function new( nodeName : String, xmlns : String ) {
		this.nodeName = nodeName;
		this.xmlns = xmlns;
	}
	
	/**
		Returns the (subclass) namespace.
	*/
	public function getNode() : String {
		return xmlns;
	}
	
	/**
		Returns a empty XML node for disabling the personal event.
	*/
	public function empty() : Xml {
		var x = Xml.createElement( nodeName );
		x.set( "xmlns", xmlns );
		return x;
	}
	
	public function toXml() : Xml {
		return throw "Abstract error";
	}
	
	/*
	public static function emptyXml() : Xml {
		return null;
	}
	*/
	
	/*
	public static function fromMessage( m : xmpp.Message ) : xmpp.pep.Event {
		////////
	}
	*/
	
}
