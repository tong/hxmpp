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

/**
	Standardization of ISO 8601 profiles and their lexical representation.

	XMPP Date and Time Profiles: http://xmpp.org/extensions/xep-0082.html
*/
class DateTime {
	
	/**
		UTC date expression.
		CCYY-MM-DDThh:mm:ss[.sss]TZD
	*/								
	public static var EREG_DATE = ~/^([0-9]{4})-([0-9]{2})-([0-9]{2})(T([0-9]{2}):([0-9]{2}):([0-9]{2})(\.[0-9]{3})?(Z|(-[0-9]{2}:[0-9]{2}))?)?$/;
	
	/**
		UTC time expression.
		hh:mm:ss[.sss][TZD]
	*/
	public static var EREG_TIME = ~/^([0-9]{2}):([0-9]{2}):([0-9]{2})(\.[0-9]{3}Z?)?$/;
	
	public static inline function isValidDate( t : String ) : Bool {
		return EREG_DATE.match( t );
	}
	
	public static inline function isValidTime( t : String ) : Bool {
		return EREG_TIME.match( t );
	}
	
	/**
		Returns the current time as UTC formatted string
	*/
	public static inline function now( ?offset : Int ) : String {
		return fromDate( Date.now(), offset );
	}
	
	/**
		Returns a the given date as UTC formatted string
	*/
	public static inline function fromDate( d : Date, ?offset : Int ) : String {
		return utc( d.toString(), offset );
	}
	
	/**
		Returns a the given date as UTC formatted string
	*/
	public static inline function fromTime( t : Float, ?offset : Int ) : String {
		return utc( Date.fromTime( t ).toString(), offset );
	}
	
	/**
		Create a Date object from a UTC time string

		//TODO this offset thing will fail!
		// TODO 24+ -> 0
		//untested!
	*/
	public static function toDate( utc : String, ?tzo : String ) : Date {
		
		var spd = utc.substr( 0, 10 ).split("-");
		var spt = utc.substr( 11, 8 ).split(":");
		
		var pd = new Array<Int>();
		for( s in spd ) pd.push( getTimeValue(s) );
		var pt = new Array<Int>();
		for( s in spt ) pt.push( getTimeValue(s) );
		
		var hours = pt[0];
		if( tzo != null ) {
			var sign = ( tzo.charAt(0) == "+" ) ? true : false;
			var v = getTimeValue( tzo.substr( 1, 2 ) );
			if( sign ) hours += v;
			else hours -= v;
		}
		
		return new Date( pd[0], pd[1], pd[2]-1, hours, pt[1], pt[2] );
	}
	
	/**   
		Formats a (regular) date string to a XMPP compatible UTC date string (CCYY-MM-DDThh:mm:ss[.sss]TZD)
		For example: 2008-11-01 18:45:47 gets 2008-11-01T18:45:47Z
		Optionally a timezone offset could be attached.
	*/
	public static function utc( t : String, ?offset : Null<Int> ) : String {
		
		var k = t.split( " " );
		if( k.length == 1 )
			return t;
		
		#if (flash||php)
		var b = k[0]+"T"+k[1];
		if( offset == null )
			b += "Z";
		else {
			b += "-";
			if( offset > 9 )
				b += Std.string( offset );
			else {
				b += "0"+Std.string( offset );
			}
			b += ":00";
		}
		return b;
		
		#else
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
		
		#end
	}
	
	/**
		Return the parts of a UTC time string
		//TODO include tzo
	*/
	public static function getParts( utc : String ) : Array<Int> {
		var r = EREG_DATE;
		if( !r.match( utc ) )
			return null;
		var t = r.matched( 4 );
		t = t.substr( 1, t.length-2 );
		var time = t.split( ":" );
		return [ Std.parseInt( r.matched(1) ),
				 Std.parseInt( r.matched(2) ),
				 Std.parseInt( r.matched(3) ),
				 Std.parseInt( time[0] ),
				 Std.parseInt( time[1] ),
				 Std.parseInt( time[2] ) ];
	}
	
	/**
		Returns the given TZO as integer value
	*/
	public static function getTZOValue( tzo : String ) : Int {
		var h = Std.parseInt( tzo.substr( 1, 2 ) );
		//if( tzo.substr( 0, 1 ) == '+' ) h = -h;
		//return h;
		return if( tzo.substr( 0, 1 ) == '+' ) h else -h;
	}
	
	public static function getTimeValue( t : String ) : Int {
		return if( t.length == 1 ) Std.parseInt(t);
		else if( t.charAt(0) == "0" ) Std.parseInt( t.charAt(1) );
		else Std.parseInt( t );
	}
	
}
