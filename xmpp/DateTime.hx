package xmpp;

/**
	<a href="http://xmpp.org/extensions/xep-0082.html">XMPP Date and Time Profiles</a>
*/
class DateTime {
	
	/**
		UTC date expression.
		TODO expression may contain minor missing checks in the offset part.
	*/
	public static var ereg_date = ~/^([0-9][0-9][0-9][0-9])-([0-9][0-9])-([0-9][0-9])(T[0-9][0-9]:[0-9][0-9]:[0-9][0-9](\.[0-9][0-9][0-9])?(Z$)?(-[0-9][0-9]:[0-9][0-9])?)?$/;
	
	/**
		UTC time expression.
	*/
	public static var ereg_time = ~/^([0-9][0-9]):([0-9][0-9]):([0-9][0-9])(\.[0-9][0-9][0-9]Z?)?$/;
	
	/**
	*/
	public static function isValidDate( t : String ) : Bool {
		return ereg_date.match( t );
	}
	
	public static function isValidTime( t : String ) : Bool {
		return ereg_time.match( t );
	}
	
	/**
		Formats a (regular) date string to a XMPP compatible UTC date string (CCYY-MM-DDThh:mm:ss[.sss]TZD)<br>
		For example: 2008-11-01 18:45:47 gets 2008-11-01T18:45:47Z<br>
		Optionally a timezone offset could be attached.<br>
	*/
	public static function format( t : String, ?offset : Null<Int> ) : String {
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

}
