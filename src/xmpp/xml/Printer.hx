package xmpp.xml;

using StringTools;

private enum EStringOrXml {
	str( v : String );
	xml( v : Xml );
}

private abstract StringOrXml(EStringOrXml) {

	inline function new( sox : EStringOrXml ) this = sox;

	public function isXml() : Bool return switch this {
		case str(_): false;
		case xml(_): true;
	}

	@:to public function toString() : String return switch this {
		case str(v): v;
		case xml(v): v.toString();
	}

	@:to public function toXml() : Xml return switch this {
		case str(v): Xml.parse( v );
		case xml(v): v;
	}

	@:from public static inline function fromString( str : String )
		return new StringOrXml( EStringOrXml.str( str ) );

	@:from public static inline function fromXml( xml : Xml )
		return new StringOrXml( EStringOrXml.xml( xml ) );
}

class Printer {

	public var pretty : Bool;

    function new( pretty : Bool ) {
		this.pretty = pretty;
    }

	function printString( str : String ) : String {
		if( pretty ) {
			var xml : Xml = null;
			try xml = Xml.parse( str ).firstElement() catch(e:Dynamic) {
				return str;
			}
			return printXml( xml );
		}
		return str;
	}

	function printXml( xml : Xml ) : String {
		return haxe.xml.Printer.print( xml, pretty );
	}

    public static function print( msg : StringOrXml, pretty = true ) : String {
		var printer = new Printer( pretty );
		return (msg.isXml() ? printer.printXml( msg ) : printer.printString( msg ) ).trim();
	}
}
