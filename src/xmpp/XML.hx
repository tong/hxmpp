package xmpp;

//typedef XML = om.XML;

import Xml;

using om.util.IterableUtil;

abstract XML(Xml) from Xml to Xml {

	public static inline var Element = XmlType.Element;
	public static inline var PCData = XmlType.PCData;
	public static inline var CData = XmlType.CData;
	public static inline var Comment = XmlType.Comment;
	public static inline var DocType = XmlType.DocType;
	public static inline var ProcessingInstruction = XmlType.ProcessingInstruction;
	public static inline var Document = XmlType.Document;

	public var type(get,never) : XmlType;
	inline function get_type() : XmlType return cast this.nodeType;

	//public var name(get,never) : NodeName;
	//function get_name() : NodeName return switch type {
	public var name(get,never) : String;
	function get_name() : String return switch type {
		case Element: this.nodeName;
		default: this.firstChild().nodeName;
	}

	public var text(get,never) : Text;
	function get_text() : Text return switch type {
		case Xml.XmlType.Element:
			var c = this.firstChild();
			(c == null) ? null : c.nodeValue;
		default:
			null;
	}

	//public var attributes(get,never) : AttributeMap;
	//@:access(Xml) inline function get_attributes() : AttributeMap return this.attributeMap;

	public var first(get,never) : XML;
	inline function get_first() : XML return this.firstElement();

	public var element(get,never) : ElementAccess;
	inline function get_element() return new ElementAccess( this );

	public var elements(get,never) : XMLIterator;
	inline function get_elements() : XMLIterator return this.elements();

	public var parent(get,never) : XML;
	inline function get_parent() return this.parent;

	public inline function new( xml : Xml ) this = xml;

	//public inline function get( att : String ) : AttributeValue {
	public inline function get( att : String ) : String {
		return this.get( att );
	}

//	public inline function set( att : String, ?val : AttributeValue ) : XML {
	public inline function set( att : String, ?val : String ) : XML {
		this.set( att, val );
	//	return cast (this,XML);
		return this;
	}

	public inline function getXmlns() : String {
		return get( 'xmlns' );
	}

	public inline function setXmlns( val : String ) : XML {
		return set( 'xmlns', val );
	}

	public inline function has( att : String ) : Bool {
		return this.exists( att );
	}

	public inline function append( e : XML ) : XML {
		this.addChild( e );
		return this;
	}

	public inline function insert( e : XML , pos : Int ) : XML {
		this.insertChild( e, pos );
		return this;
	}

	@:to public inline function toString() : String {
		return this.toString();
	}

	@:to public inline function _toXml() : Xml {
		return this;
	}

	//public static inline function create( name : NodeName, ?content : String ) : XML {
	public static inline function create( name : String, ?content : String ) : XML {
		var xml : XML = Xml.createElement( name );
		return (content != null) ? xml.append( Xml.createPCData( content ) ) : xml;
	}

	@:from public static inline function fromString( str : String ) : XML {
		return new XML( Xml.parse( str ).firstElement() );
	}
}

/*
private abstract NodeName(String) {

	inline function new( s : String ) this = s;

	@:to public function toString() : String {
		return this;
	}

	@:from public static inline function fromString( s : String )
		return new NodeName( s );

	@:commutative @:op(a == b)
	public static inline function equalsString( a : NodeName, b : String ) : Bool
		return equalsName( a, b );

	@:op(a == b)
	public static inline function equalsName( a : NodeName, b : NodeName ) : Bool
		return (a : String) == (b : String);
}
*/

/*
private abstract AttributeValue(String) from String to String {

	public inline function new( s : String ) this = s;

	@:to function toBool() : Bool {
		return switch this {
			case '','0','false','null': false;
			case '1','true': true;
			case _: throw 'invalid boolean attribute: '+this;
		}
	}

	@:to public inline function toInt() : Int
		return Std.parseInt( this );

	@:to public inline function toFloat() : Float
		return Std.parseFloat( this );
}

private abstract AttributeName(String) from String to String {

	inline function new( s : String ) {
		//if( s.length == 0 ) throw 'invalid attribute name: '+s;
		this = s;
	}
}

private abstract AttributeMap(Map<AttributeName,AttributeValue>) from Map<String,String> {

	public var length(get,never) : Int;
	inline function get_length() : Int return this.count();

	public inline function new( m : Map<String,String> ) this = m;
}
*/

private abstract Text(String) from String to String {

	@:to public inline function toInt() : Int
		return Std.parseInt( this );

	@:to public inline function toFloat() : Float
		return Std.parseFloat( this );

	@:to function toBool() : Bool {
		return switch this {
			case '','0','false','null': false;
			case '1','true': true;
			case _: throw 'invalid boolean node value: '+this;
		}
	}
}

private abstract ElementAccess(XML) {

	/*
	public var text(get,set) : Text;
	inline function get_text() : Text return "";
	inline function set_text(s:Text) : Text return "";

	*/
	public inline function new( xml : XML ) this = xml;

	/*
	public function count( ?name : String ) : Int {
		var n = 0;
		if( name == null )
			for( _ in this.elements() ) n++;
		else
			for( _ in this.elementsNamed( name ) ) n++;
		return n;
	}
	*/

	//@:arrayAccess public inline function elementsNamed( name : NodeName ) : XMLIterator {
	@:arrayAccess public inline function elementsNamed( name : String ) : XMLIterator {
		return this._toXml().elementsNamed( name );
	}
}

private abstract XMLIterator(Iterator<XML>) from Iterator<XML> to Iterator<XML> {

	//public var length(get,never) : Int;
	//inline function get_length() : Int return this.count();

	public inline function next() : XML return this.next();

	//@:arrayAccess function elementsNamed( name : String ) {

	@:arrayAccess function get( i : Int ) : XML {
		var n = this.next();
		while( i > 0 ) {
			if( !this.hasNext() )
                return null;
			n = this.next();
		}
		return n;
	}

	public function doFilter( f : XML->Bool ) : XMLIterator {
		return [for(e in this) if(f(e)) e].iterator();
	}

    public function doFind( f : Xml->Bool ) : XML {
		for( e in this ) if( f(e) ) return e;
		return null;
	}

	macro public static function where( ethis : ExprOf<XMLIterator>, cond : ExprOf<Bool> ) {
		var f = macro function( element : XML ) return $cond;
		var e = macro om.XML.XMLIterator.doFilter( $ethis, $f );
		return e;
	}

    macro public static function find( ethis : ExprOf<XMLIterator>, cond : ExprOf<Bool> ) {
        var f = macro function(element:XML) return $cond;
        var e = macro om.XML.XMLIterator.doFind( $ethis, $f );
        return e;
    }
}
