package xmpp;

import Xml;

@:noDoc
private abstract Text(String) from String to String {

	@:to public inline function toFloat() : Float
		return Std.parseFloat( this );

	@:to public inline function toInt() : Int
		return Std.parseInt( this );

	@:to function toBool() : Bool
		return switch this {
			case '','0','false','null': false;
			case '1','true': true;
			case _: throw 'invalid boolean value: '+this;
		}
}
/* 
abstract ElementAccess(Xml) {

	public inline function new( xml : Xml ) this = xml;

	@:arrayAccess public inline function elementsNamed( s : String ) : NodeIterator
		return this.elementsNamed(s);
}
 */
 
 @:noDoc
@:forward(hasNext)
private abstract NodeIterator(Iterator<XML>) from Iterator<XML> to Iterator<XML> {

    public inline function next() : XML return this.next();

    @:arrayAccess public function get( i : Int ) : XML {
        var j = 0;
        while( j <= i ) {
            if( !this.hasNext() )
                return null;
            var n = next();
            if( j++ == i )
                return n;
        }
        return null;
	}

   @:arrayAccess public function named( name : String ) : Array<XML> {
        var e = new Array<XML>();
        while( this.hasNext() ) {
            var c = next();
            if( c.type == Element && c.name == name ) e.push( c );
        }
        return e;
    }

    public function count() : Int {
        var i = 0;
        while( next() != null ) i++;
        return i;
    }

	/*
	function doFilter( f : XML->Bool ) : NodeIterator {
		return [for(e in this) if(f(e))e].iterator();
	}

	function doFind( f : XML->Bool ) : XML {
		for( e in this ) if( f(e) ) return e;
		return null;
	}

	macro public static function where( ethis : ExprOf<xmpp.XML.NodeIterator>, cond : ExprOf<Bool> ) {
		var f = macro function( element : XML ) return $cond;
		var e = macro xmpp.XML.NodeIterator.doFilter( $ethis, $f );
		return e;
	}

	macro public static function find( ethis : ExprOf<xmpp.XML.NodeIterator>, cond : ExprOf<Bool> ) {
        var f = macro function(element:XML) return $cond;
        var e = macro xmpp.XML.NodeIterator.doFind( $ethis, $f );
        return e;
    }
	*/
}

@:access(Xml)
@:forward(attributes)
abstract XML(Xml) from Xml to Xml {

    public var parent(get,never) : XML;
	inline function get_parent() return this.parent;

    public var type(get,never) : XmlType;
	inline function get_type() : XmlType return this.nodeType;

    public var name(get,never) : String;
	inline function get_name() : String return this.nodeName;
    
	public var firstElement(get,never) : XML;
	inline function get_firstElement() : XML return this.firstElement();

    public var text(get,set) : Text;
	function get_text() : Text return switch type {
		case XmlType.Element:
			var c = this.firstChild();
			if( c == null ) null else c.nodeValue;
		default: null;
	}
    function set_text(v:Text) : Text {
        switch type {
		case XmlType.Element:
			var c = this.firstChild();
			if( c != null ) c.nodeValue = v;
			else this.addChild( Xml.createPCData(v) ); //TODO really
		default:
        }
        return v;
	}

    public var elements(get,set) : NodeIterator;
	inline function get_elements() : NodeIterator return this.elements();
	inline function set_elements( elements : NodeIterator ) : NodeIterator {
        this.children = [];
        for( e in elements ) this.addChild( e );
        return this.elements();
    }

	//public var element(get,never) : ElementAccess;
	//function get_element() : ElementAccess return new ElementAccess( this );

    @:noDoc inline function new( x : Xml ) this = x;

    @:arrayAccess public inline function get( att : String ) : String
        return this.get( att );

    @:arrayAccess public inline function set( att : String, ?val : String ) : XML {
        this.set( att, val );
        return this;
    }

    //public inline function is( xmlns : String ) : Bool
    //   return get( 'xmlns' ) == xmlns;

    public inline function has( att : String ) : Bool
    	return this.exists( att );

    //public inline function unset( att : String )
    //	this.remove( att );

	public inline function xmlns() : String
        return this.get( 'xmlns' );

    //@:op(A+=B)
    public inline function append( e : XML ) : XML {
		this.addChild( e );
		return this;
	}

    public inline function addChild( x : XML )
        this.addChild( x );

    public inline function removeChild( x : XML ) : Bool
        return this.removeChild( x );

    public inline function insert( x: XML , pos = 0 ) : XML {
        this.insertChild( x, pos );
        return this;
    }

    @:arrayAccess public inline function getChild( i : Int ) : XML
        return this.children[i];

    /*
    public inline function append( parent : XML ) {
        parent.addChild( this );
    }

    public inline function remove() : XML {
        if( parent != null ) this.parent.removeChild( this );
        return this;
    }
    */

    @:to public inline function toString() : String
		return this.toString();
	
    //public static function create( name : String, ?text : String, ?attributes : Map<String,String>, ?children : Array<XML> ) : XML {
    public static function create( name : String, ?text : String ) : XML {
        var x : XML = Xml.createElement( name );
        if( text != null ) x.append( Xml.createPCData( text ) );
        return x;
    }

    @:from public static inline function fromXml( x : Xml ) : XML {
        return switch x.nodeType {
        case Document: x.firstElement();
        case _: x;
        }
    }

    @:from public static inline function parse( s : String ) : XML {
		return fromXml( Xml.parse( s ).firstElement() );
	}

	macro public static function markup( mu ) : ExprOf<xmpp.XML> {
		return switch mu.expr {
      	case EMeta( { name: ":markup" }, { expr: EConst(CString(s)) } ):
      		macro XML.parse( $v{s} );
      	case _:
        	throw new haxe.macro.Expr.Error( "not an xml literal", mu.pos );
    	}
	}

}
