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
	<a href="http://xmpp.org/extensions/xep-0082.html">XMPP Date and Time Profiles</a>
*/
class DateTime {
	
	static function __init__() {
		//20091012T21:39:16
		//1969-07-20T21:56:15-05:00
		
		//ereg_date = ~/^([0-9][0-9][0-9][0-9])-?([0-9][0-9])-?([0-9][0-9])T([0-9][0-9]:[0-9][0-9]:[0-9][0-9](\.[0-9][0-9][0-9])?(Z$)?(-[0-9][0-9]:[0-9][0-9])?)?$/;
		
		ereg_date = ~/^([0-9][0-9][0-9][0-9])-?([0-9][0-9])-?([0-9][0-9])T([0-9][0-9]):([0-9][0-9]):([0-9][0-9])/;
		//(\.[0-9][0-9][0-9])?(Z$)?(-[0-9][0-9]:[0-9][0-9])?)?$/;
		
		//ereg_date_old = ~/([0-9][0-9][0-9][0-9])([0-9][0-9])([0-9][0-9])T([0-9][0-9]):([0-9][0-9]):([0-9][0-9])/;
	}
	
	/**
		UTC date expression.
		TODO expression may contain minor missing checks in the offset part.
		//TODO
		CCYY-MM-DDThh:mm:ss[.sss]TZD
	*/								
	public static var ereg_date(default,null) : EReg;
	
	/**
		Deprecated!
		Implementd just for backwards compatibility.
		20091012T21:39:16
	*/
//	public static var ereg_date_old(default,null)  : EReg;
	
	/**
		UTC time expression.
		//TODO
		hh:mm:ss[.sss][TZD]
		
	*/
	public static var ereg_time = ~/^([0-9][0-9]):([0-9][0-9]):([0-9][0-9])(\.[0-9][0-9][0-9]Z?)?$/;
	
	/**
	*/
	public static function isValidDate( t : String ) : Bool {
	//	if( ereg_date_old.match( t ) ) return true;
		return ereg_date.match( t );
	}
	
	/**
	*/
	public static function isValidTime( t : String ) : Bool {
		return ereg_time.match( t );
	}
	
	/**
	*/
	public static inline function current() : String {
		return toUTC( Date.now().toString() );
	}
	
	/**   
		Formats a (regular) date string to a XMPP compatible UTC date string (CCYY-MM-DDThh:mm:ss[.sss]TZD)<br>
		For example: 2008-11-01 18:45:47 gets 2008-11-01T18:45:47Z<br>
		Optionally a timezone offset could be attached.<br>
	*/
	public static function toUTC( t : String, ?offset : Null<Int> ) : String {
		var k = t.split( " " );
		if( k.length == 1 )
			return t;
		var b = new StringBuf();
		b.add( k[0] );
		b.add( "T" );
		b.add( k[1] );
		if( offset == null )
			b.add( "Z" );
		else {
			b.add( "-" );
			if( offset > 9 )
				b.add( Std.string( offset ) );
			else {
				b.add( "0" );
				b.add( Std.string( offset ) );
			}
			b.add( ":00" );
		}
		return b.toString();
	}
	
	/**
		Create a Date object from a UTC datetime string.
	*/
	public static function toDate( t : String ) : Date {
		if( !ereg_date.match( t ) )
			return null;
		var d = new Date( Std.parseInt( ereg_date.matched(1) ),
						  Std.parseInt( ereg_date.matched(2) )-1, //TODO check if neko only ?
						  Std.parseInt( ereg_date.matched(3) ),
						  Std.parseInt( ereg_date.matched(4) ),
						  Std.parseInt( ereg_date.matched(5) ),
						  Std.parseInt( ereg_date.matched(6) ) );
		return d;
	}
	
}
