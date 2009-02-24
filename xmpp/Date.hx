package xmpp;


/**
	<a href="http://xmpp.org/extensions/xep-0082.html">XMPP Date and Time Profiles</a>
*/
class Date {
	
	/**
	*/
	public static function isValid( t : String ) : Bool {
		//TODO !! regexp
		
		//(?<Date>(?<Year>\d{4})-(?<Month>\d{2})-(?<Day>\d{2}))(?:T(?<Time>(?<SimpleTime>(?<Hour>\d{2}):(?<Minute>\d{2})(?::(?<Second>\d{2}))?)?(?:\.(?<FractionalSecond>\d{1,7}))?(?<Offset>-\d{2}\:\d{2})?))?
		
		//var r = ~/\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[1-2][0-9]|3[0-1])T([0-1][0-9]|2[0-3]):([0-5][0-9]):([0-5][0-9])(?:.\d{7})?[+|-](0[0-9]|1[0-2]):(00|15|30|45)/;
		
		/*
		var regexp = "([0-9]{4})(-([0-9]{2})(-([0-9]{2})" +
        "(T([0-9]{2}):([0-9]{2})(:([0-9]{2})(\.([0-9]+))?)?" +
        "(Z|(([-+])([0-9]{2}):([0-9]{2})))?)?)?)?";
    	var d = string.match(new RegExp(regexp));
		*/
		return true;
	}
	
	/**
		Formats a (regular) date string to a xmpp compatible date string (CCYY-MM-DDThh:mm:ss[.sss]TZD)<br>
		For example: 2008-11-01 18:45:47 gets 2008-11-01T18:45:47Z<br>
		Optionally a timezone offset could be attached.<br>
		
		// TODO seconds.
	*/
	public static function format( t : String, ?offset : Null<Int> ) : String {
		if( !isValid( t ) ) return null;
		var k = t.split( " " );
		if( k.length == 1 ) return t;
		var b = new StringBuf();
		b.add( k[0] );
		b.add( "T" );
		b.add( k[1] );
		if( offset == null )
			b.add( "Z" );
		else {
			b.add( "-" );
			b.add( if( offset > 9 ) Std.string( offset ) else ("0"+offset) );
			b.add( ":00" );
		}
		return b.toString();
	}
	
}
