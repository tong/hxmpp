package xmpp;

import Xml;

@:forward(get)
abstract XML(Xml) from Xml to Xml {

	@:noCompletion public inline function new( xml : Xml ) this = xml;

	public var type(get,never) : XmlType;
    inline function get_type() : XmlType return this.nodeType;

    public var name(get,never) : String;
    inline function get_name() return this.nodeName;

	public var attrs(get,never) : Iterator<String>;
    inline function get_attrs() return this.attributes();

    public var value(get,never) : String;
    function get_value() : String {
		return switch this.nodeType {
			case Xml.XmlType.Element:
				var c = this.firstChild();
				(c == null) ? null : c.nodeValue;
			default:
				null;
		}
	}

	@:arrayAccess inline function attr( s : String )
		return this.get( s );

	@:arrayAccess inline function setAttr( s : String, v : String )
		return this.set( s, v );

	public inline function ns() : String
		return this.get( 'xmlns' );

	public inline function has( attr : String ) : Bool
		return this.exists( attr );

	public inline function set( id : String, ?val : String ) : XML {
	    this.set( id, val );
	    return this;
	}

	public inline function append( child : XML ) : XML {
		this.addChild( child );
		return this;
	}

	public inline function elements() : Iterator<XML> {
		return this.elements();
	}

	@:access(Xml)
	public inline function elementsNamed( name : String ) : Array<XML> {
		//this.ensureElementType();
		//var ret = [for(c in this.children) if (c.nodeType == Element && c.nodeName == name) c];
		//return ret;
		return [for(c in this.children) if (c.nodeType == Element && c.nodeName == name) c];
	}

	public inline function firstElement() : XML {
		return this.firstElement();
	}

	@:to public inline function toString() : String
		return this.toString();

	#if sys

	public static function readFile( path : String ) : XML {
		return parse( sys.io.File.getContent( path ) );
	}
	#end

	public static function createPCData( str : String ) : XML {
		var xml : XML = Xml.createPCData( str );
		return xml;
	}

	public static function createCData( str : String ) : XML {
		var xml : XML = Xml.createCData( str );
		return xml;
	}

	public static function create( name : String, ?value : String ) : XML {
		var xml : XML = Xml.createElement( name );
		if( value != null ) xml.append( Xml.createPCData( value ) );
		return xml;
	}

	@:from public static inline function parse( str : String ) : XML
        return new XML( Xml.parse( str ).firstElement() );
}
