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

/**
	<a href="http://www.xmpp.org/extensions/xep-0092.html">XEP 0092 - Software Version</a>
*/
class SoftwareVersion {
	
	public static var XMLNS = "jabber:iq:version";
	
	public var name : String;
	public var version : String;
	public var os : String;
	
	public function new( ?name : String, ?version : String, ?os : String ) {
		this.name = name;
		this.version = version;
		this.os = os;
	}
	
	public function toXml() : Xml {
		var x = IQ.createQueryXml( XMLNS );
		if( name != null ) x.addChild( XMLUtil.createElement( "name", name ) );
		if( version != null ) x.addChild( XMLUtil.createElement( "version", version ) );
		if( os != null ) x.addChild( XMLUtil.createElement( "os", os ) );
		return x;
	}
	
	public inline function toString() : String {
		return toXml().toString();
	}
	
	public static function parse( x : Xml ) : xmpp.SoftwareVersion {
		var f = new haxe.xml.Fast( x );
		return new xmpp.SoftwareVersion( f.node.name.innerData,
										 f.node.version.innerData,
										 ( f.hasNode.os ) ? f.node.os.innerData : null );
	}
	
}
