package xmpp.extra;

using StringTools;

private enum EStringOrXml {
	string( v : String );
	xml( v : Xml );
}

abstract StringOrXml(EStringOrXml) {

	inline function new( sox : EStringOrXml ) this = sox;

	public function isXml() : Bool {
		return switch this {
			case string(_): false;
			case xml(_): true;
		}
	}

	@:to public function toString() : String {
		return switch this {
			case string(v): v;
			case xml(v): v.toString();
		}
	}

	@:to public function toXml() : Xml {
		return switch this {
			case string(v): Xml.parse( v );
			case xml(v): v;
		}
	}

	@:from public static inline function fromString( str : String )
		return new StringOrXml( EStringOrXml.string( str ) );

	@:from public static inline function fromXml( xml : Xml )
		return new StringOrXml( EStringOrXml.xml( xml ) );
}

class Printer {

	//TODO really? instance ?

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
