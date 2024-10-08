package xmpp;

import Xml;

@:access(Xml)
@:forward(attributes, children, addChild, removeChild)
abstract XML(Xml) from Xml to Xml {
	public var parent(get, never):XML;

	inline function get_parent():XML
		return this.parent;

	/** Node type **/
	public var type(get, never):XmlType;

	inline function get_type():XmlType
		return this.nodeType;

	/** Node name **/
	public var name(get, never):String;

	inline function get_name():String
		return this.nodeName;

	public var firstElement(get, never):XML;

	inline function get_firstElement():XML
		return this.firstElement();

	/** Element namespace **/
	public var ns(get, set):String;

	inline function get_ns():String
		return this.get('xmlns');

	inline function set_ns(ns:String):String {
		this.set('xmlns', ns);
		return ns;
	}

	public var text(get, set):Text;

	function get_text():Text
		return switch type {
			case XmlType.Element:
				final c = this.firstChild();
				if (c == null) null else c.nodeValue;
			default: null;
		}

	function set_text(v:Text):Text {
		switch type {
			case XmlType.Element:
				final c = this.firstChild();
				if (c != null)
					c.nodeValue = v;
				else
					this.addChild(Xml.createPCData(v)); // TODO really
			default:
		}
		return v;
	}

	public var elements(get, never):xmpp.XML.NodeIterator;

	inline function get_elements():xmpp.XML.NodeIterator {
		return cast this.elements();
		// return this.firstChild().elements();
	}

	// inline function set_elements(elements:xmpp.XML.NodeIterator):xmpp.XML.NodeIterator {
	// 	this.children = [for (e in elements) e];
	// // 	//for (e in elements) this.addChild(e);
	// 	return get_elements();
	// }
	// public var first(get,never) : XML;
	// inline function get_first() :
	// public var element(get,never) : ElementAccess;
	// function get_element() : ElementAccess return new ElementAccess( this );

	@:noDoc inline function new(x:Xml)
		this = x;

	// TODO: really?
	// public inline function iterator() : NodeIterator
	//    	return this.elements();

	@:arrayAccess public inline function get(att:String):String
		return this.get(att);

	@:arrayAccess public function set(att:String, ?value:String):XML {
		if (value == null)
			return unset(att);
		this.set(att, value);
		return this;
	}

	public inline function has(att:String):Bool
		return this.exists(att);

	// @:op(A==B)
	public inline function is(xmlns:String):Bool
		return this.get('xmlns') == xmlns;

	public inline function unset(att:String):XML {
		this.remove(att);
		return this;
	}

	public inline function append(e:XML):XML {
		this.addChild(e);
		return this;
	}

	public inline function insert(x:XML, pos = 0):XML {
		this.insertChild(x, pos);
		return this;
	}

	// public inline function addChild(x:XML):Void
	// 	this.addChild(x);
	//
	// public inline function removeChild(x:XML):Bool
	// 	return this.removeChild(x);
	// @:arrayAccess public inline function getChildAt(i:Int):XML
	// 	return this.children[i];

	@:to public inline function toString():String
		return this.toString();

	public static function create(name:String, ?attributes:Map<String, String>, ?text:String):XML {
		var x:XML = Xml.createElement(name);
		if (attributes != null)
			for (k => v in attributes)
				x.set(k, v);
		if (text != null)
			x.append(Xml.createPCData(text));
		return x;
	}

	/*
		@:from public static inline function fromXml(x:Xml):XML {
			return switch x.nodeType {
				//case Document: x.firstElement();
				case Document: x.firstElement();
					// if(@:privateAccess cast(x.elements(), haxe.iterators.ArrayIterator<Dynamic>).array.length == 1) {
					//     return x;
					// }
					return x.firstElement();
				case _: x;
			}
		}
	 */
	@:from public static inline function fromString(str:String):XML {
		var xml = Xml.parse(str);
		// trace(@:privateAccess cast(xml.elements(), haxe.iterators.ArrayIterator<Dynamic>).array.length);
		return new XML(xml.firstElement());
	}

	// @:from
	public static inline function parse(str:String):XML {
		// return fromXml(Xml.parse(s).firstElement());
		// trace(@:privateAccess cast(x.elements(), haxe.iterators.ArrayIterator<Dynamic>).array.length);
		var x:Xml = Xml.parse(str);
		return new XML(x);
	}
	/*
		macro public static function markup(mu):ExprOf<xmpp.XML> {
			return switch mu.expr {
				case EMeta({name: ":markup"}, {expr: EConst(CString(s))}):
					macro XML.parse($v{s});
				case _:
					throw new haxe.macro.Expr.Error("not an xml literal", mu.pos);
			}
		}
	 */
}

@:noDoc
@:forward(next, hasNext)
// private abstract NodeIterator(Iterator<XML>) from Iterator<XML> to Iterator<XML> {
private abstract NodeIterator(haxe.iterators.ArrayIterator<XML>) from haxe.iterators.ArrayIterator<XML> to haxe.iterators.ArrayIterator<XML> {
	public var length(get, never):Int;

	inline function get_length():Int
		return @:privateAccess cast(this, haxe.iterators.ArrayIterator<Dynamic>).array.length;

	// public inline function next():XML
	// 	return this.next();

	/**
		Get nth(i) element.
	**/
	@:arrayAccess public function index(i:Int):XML {
		return @:privateAccess cast(this, haxe.iterators.ArrayIterator<Dynamic>).array[i];
		/*
			var j = 0;
			while (j <= i) {
				if (!this.hasNext())
					return null;
				var n = next();
				if (j++ == i)
					return n;
			}
			return null;
		 */
	}

	/**
		Returns all child elements with given node name.
	**/
	@:arrayAccess public function named(name:String):Array<XML> {
		final e = new Array<XML>();
		while (this.hasNext()) {
			var c = this.next();
			if (c.type == Element && c.name == name)
				e.push(c);
		}
		return e;
	}

	public function first(?f:XML->Bool):XML {
		if (f == null)
			@:privateAccess cast(this, haxe.iterators.ArrayIterator<Dynamic>).array[0];
		for (e in this)
			if (f(e))
				return e;
		return null;
	}

	public function findElement(name:String):XML {
		var c:XML = null;
		while (this.hasNext())
			if ((c = this.next()).name == name)
				return c;
		// while((c = this.next()) != null) if(c.name == name) return c;
		return null;
	}

	public function count():Int {
		// trace('COUNT');
		var i = 0;
		while (this.next() != null)
			i++;
		return i;
		// return @:privateAccess cast(this, haxe.iterators.ArrayIterator<Dynamic>).array.length;
	}

	//   public function hasChild(f: XML->Bool) : Bool {
	// for( e in this ) if( f(e) ) return true;
	//       return false;
	//   }
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

@:noDoc
private abstract Text(String) from String to String {
	@:to public inline function toFloat():Float
		return Std.parseFloat(this);

	@:to public inline function toInt():Int
		return Std.parseInt(this);

	@:from public static inline function fromInt(i:Int):Text
		return Std.string(i);

	@:from public static inline function fromFloat(f:Float):Text
		return Std.string(f);

	// @:to function toBool():Null<Bool>
	// 	return switch this {
	// 		case '', '0', 'false', 'null': false;
	// 		case '1', 'true': true;
	// 		case _: null; //throw 'invalid bool value: $this';
	// 	}
}
