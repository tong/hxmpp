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

	/**
		Character data of the element: all text and CDATA children joined, `null` if there are none.

		Setting it replaces all text and CDATA children; child elements are kept.
	**/
	public var text(get, set):Text;

	function get_text():Text {
		if (type != XmlType.Element)
			return null;
		var buf:StringBuf = null;
		for (c in this) {
			if (c.nodeType == XmlType.PCData || c.nodeType == XmlType.CData) {
				if (buf == null)
					buf = new StringBuf();
				buf.add(c.nodeValue);
			}
		}
		return (buf == null) ? null : buf.toString();
	}

	function set_text(v:Text):Text {
		if (type != XmlType.Element)
			return v;
		for (c in [
			for (c in this) if (c.nodeType == XmlType.PCData || c.nodeType == XmlType.CData) c
		])
			this.removeChild(c);
		if (v != null)
			this.addChild(Xml.createPCData(v));
		return v;
	}

	/**
		Child elements (a new list on each access).
	**/
	public var elements(get, never):Elements;

	inline function get_elements():Elements
		return [for (e in this.elements()) e];

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
	/**
		Parses `str` and returns its root element.
	**/
	@:from public static inline function fromString(str:String):XML
		return new XML(Xml.parse(str).firstElement());

	/**
		Parses `str` and returns the document node containing the parsed nodes.

		Use `fromString` to get the root element.
	**/
	public static inline function parseDocument(str:String):XML
		return new XML(Xml.parse(str));

	/**
		Parses `str` and returns the **document** node.
	**/
	@:deprecated("XML.parse returns the document node: use XML.fromString for the root element, or XML.parseDocument")
	public static inline function parse(str:String):XML
		return parseDocument(str);

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

/**
	List of child elements.
**/
@:forward(length, iterator, map, filter, indexOf, contains)
abstract Elements(Array<XML>) from Array<XML> to Array<XML> {
	/**
		Get the element at index `i`, or `null`.
	**/
	@:arrayAccess public inline function index(i:Int):XML
		return this[i];

	/**
		Returns all elements with given node name.
	**/
	@:arrayAccess public function named(name:String):Array<XML>
		return [for (e in this) if (e.name == name) e];

	/**
		Returns the first element (matching `f` if given), or `null`.
	**/
	public function first(?f:XML->Bool):XML {
		for (e in this)
			if (f == null || f(e))
				return e;
		return null;
	}

	/**
		Returns the first element with given node name, or `null`.
	**/
	public function findElement(name:String):XML
		return first(e -> e.name == name);

	/**
		Number of elements, same as `length`.
	**/
	public inline function count():Int
		return this.length;
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
