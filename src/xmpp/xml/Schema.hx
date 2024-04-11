package xmpp.xml;

enum AnnotationContent {
	appinfo(v:Appinfo);
	documentation(v:Documentation);
}

typedef Annotation = {
	// @:optional var id : String;
	var content:AnnotationContent;
}

typedef Any = {
	// @:optional var id : String;
	@:optional var namespace:String;
	@:optional var minOccurs:String;
	@:optional var maxOccurs:String;
	@:optional var processContents:String; // strict, lax or skip
}

typedef Appinfo = {
	var source:String;
	var content:String;
}

typedef Attribute = {
	// var default_ : String;
	@:optional var fixed:String;
	@:optional var form:String;
	@:optional var id:String;
	@:optional var name:String;
	@:optional var ref:String;
	@:optional var type:String;
	@:optional var use:String;
	// var scope : String;
	// var valueConstraint : ValueConstraint;
	@:optional var annotation:Annotation;
	@:optional var simpleType:SimpleType;
	@:optional var default_:String;
	// var required : Bool;
}

typedef Choice = {
	@:optional var maxOccurs:String;
	@:optional var minOccurs:String;
	var elements:Array<Element>;
}

typedef ComplexContent = {
	@:optional var id:String;
	@:optional var mixed:String;
	// var extension : Extension;
}

typedef ComplexType = {
	@:optional var name:String;
	// ...
	// @:optional var abstract : Bool;
	// @:optional var contentType : Bool;
	// ..
	@:optional var annotations:Array<Annotation>;
	@:optional var simpleContent:SimpleContent;
	@:optional var complexContent:ComplexContent;
	@:optional var sequence:Sequence;
	@:optional var attribute:Array<Attribute>;
	@:optional var choice:Choice;
}

typedef Documentation = {
	var source:String;
	var lang:String;
	var content:String;
}

typedef Element = {
	@:optional var id:String;
	var name:String;
	var type:String;
	@:optional var ref:String;
	@:optional var substitutionGroup:String;
	@:optional var default_:String;
	@:optional var fixed:String;
	@:optional var form:String;
	@:optional var maxOccurs:String; // TODO Int
	@:optional var minOccurs:String; // TODO Int
	@:optional var nillable:String;
	@:optional var abstract_:String;
	@:optional var block:String;
	@:optional var final_:String;
	// @:optional var use : String;
	@:optional var simpleType:SimpleType;
	@:optional var complexType:ComplexType;
	// var scope : String;
}

typedef Enumeration = {
	var value:String;
}

typedef Example = {
	var count:Int;
	var size:Int;
	// var content : (all | any*)
}

typedef Extension = {
	var base:String;
	var attribute:Array<Attribute>;
}

typedef MaxLength = {
	// TODO @:optional var id : ;
	@:optional var fixed:Bool;
	@:optional var value:Int;
}

typedef MinLength = MaxLength;

typedef Notation = {
	// @:optional var id : String;
	var name:String;
	var public_:String;
	@:optional var system:String;
}

typedef Restriction = {
	// @:optional var id : String;
	var base:String;
	var attribute:Array<Attribute>;
	var enumeration:Array<Enumeration>;
	@:optional var minLength:MinLength; // Int;
	@:optional var maxLength:MaxLength; // Int;
}

typedef Sequence = {
	// @:optional var id : String;
	@:optional var maxOccurs:String;
	@:optional var minOccurs:String;
	var elements:Array<Element>;
	var any:Array<Any>;
	var choice:Array<Choice>;
}

typedef SimpleContent = {
	// @:optional var id : String;
	// var annotation : Annotation;
	@:optional var restriction:Restriction;
	@:optional var extension:Extension;
}

typedef SimpleType = {
	// @:optional var id : String;
	var name:String;
	var restriction:Array<Restriction>;
	// list
	// union
}

typedef Unique = {
	@:optional var id:String;
	var name:String;
	var content:{
		?annotation:Annotation
	};
}

class Schema {
	public var targetNamespace:String;
	public var xmlns:String;
	public var elementFormDefault:String;

	public var xmlns_xml:String;

	public var annotation:Annotation;
	public var elements:Array<Element>;
	public var simpleType:Array<SimpleType>;
	public var complexType:Array<ComplexType>;

	public function new(targetNamespace:String, xmlns:String, ?elementFormDefault:String) {
		this.targetNamespace = targetNamespace;
		this.xmlns = xmlns;
		this.elementFormDefault = elementFormDefault;
		elements = [];
		simpleType = [];
		complexType = [];
	}

	public function toXML():XML {
		var xml = XML.create('xs:schema');
		for (e in elements) {
			var c = XML.create('xs:element');
			c.set('name', e.name);
			if (e.complexType != null) {}
			xml.append(c);
		}
		// TODO
		return xml;
	}

	public static function parse(xml:XML):Schema {
		var schema = new Schema(xml['targetNamespace'], xml['xmlns'], xml['elementFormDefault']);
		schema.xmlns_xml = xml['xmlns:xml']; // TODO
		for (e in xml.elements) {
			switch e.name {
				case 'xs:annotation':
					for (e in e.elements) {
						switch e.name {
							case 'xs:documentation': schema.annotation = parseAnnotation(e);
						}
					}
				case 'xs:complexType':
					schema.complexType.push(parseComplexType(e));
				case 'xs:element':
					schema.elements.push(parseElement(e));
				case 'xs:simpleType':
					schema.simpleType.push(parseSimpleType(e));
			}
		}
		return schema;
	}

	static function parseAnnotation(xml:XML):Annotation {
		return {
			// id: xml['id'],
			content: switch xml.name {
				case 'xs:documentation':
					documentation(parseDocumentation(xml));
				case 'xs:appinfo':
					var e = xml;
					appinfo({
						source: e.get('source'),
						content: e.text
					});
				default: null;
			},
		};
	}

	static function parseAny(xml:XML):Any {
		return {
			// id: xml['id'],
			namespace: xml['namespace'],
			maxOccurs: xml['maxOccurs'],
			minOccurs: xml['minOccurs'],
			processContents: xml['processContents']
		};
	}

	static function parseAttribute(xml:XML):Attribute {
		var attr:Attribute = {
			name: xml['name'],
			ref: xml['ref'],
			type: xml['type'],
			use: xml['use'],
			default_: xml['default'],
		}
		for (e in xml.elements)
			switch e.name {
				case 'xs:simpleType':
					attr.simpleType = parseSimpleType(e);
			}
		return attr;
	}

	static function parseChoice(xml:XML):Choice {
		var choice:Choice = {
			maxOccurs: xml['maxOccurs'],
			minOccurs: xml['minOccurs'],
			elements: []
		};
		for (e in xml.elements)
			switch e.name {
				case 'xs:element':
					choice.elements.push(parseElement(e));
			}
		return choice;
	}

	static function parseComplexContent(xml:XML):ComplexContent {
		var content:ComplexContent = {
			// id: xml['id'],
			mixed: xml['mixed'],
		};
		/*
			for( e in xml.elements ) switch e.name {
				//case 'xs:element': choice.elements.push( parseElement(e) );
			}
		 */
		return content;
	}

	static function parseComplexType(xml:XML):ComplexType {
		var complexType:ComplexType = {
			attribute: [],
			name: xml.get('name')
		};
		for (e in xml.elements) {
			switch e.name {
				case 'xs:annotations':
					complexType.annotations.push(parseAnnotation(e));
				case 'xs:simpleContent':
					complexType.simpleContent = parseSimpleContent(e);
				case 'xs:complexContent':
					complexType.complexContent = parseComplexContent(e);
				case 'xs:sequence':
					complexType.sequence = parseSequence(e);
				case 'xs:attribute':
					complexType.attribute.push(parseAttribute(e));
				case 'xs:choice':
					complexType.choice = parseChoice(e);
			}
		}
		return complexType;
	}

	static function parseDocumentation(xml:XML):Documentation {
		return {
			source: xml['source'],
			lang: xml['lang'],
			content: xml.text
		};
	}

	static function parseElement(xml:XML):Element {
		var element:Element = {
			minOccurs: xml['minOccurs'],
			maxOccurs: xml['maxOccurs'],
			name: xml['name'],
			ref: xml['ref'],
			type: xml['type'],
		};
		for (e in xml.elements) {
			switch e.name {
				case 'xs:simpleType':
					element.simpleType = parseSimpleType(e);
				case 'xs:complexType':
					element.complexType = parseComplexType(e);
			}
		}
		return element;
	}

	static function parseEnumeration(xml:XML):Enumeration {
		var enumeration = {
			value: xml['value'],
		};
		return enumeration;
	}

	static function parseExtension(xml:XML):Extension {
		var extension:Extension = {
			attribute: [],
			base: xml['base']
		};
		for (e in xml.elements)
			switch e.name {
				case 'xs:attribute':
					extension.attribute.push(parseAttribute(e));
			}
		return extension;
	}

	static function parseMaxLength(xml:XML):MaxLength {
		return {
			fixed: xml['fixed'] == 'true',
			value: Std.parseInt(xml['value'])
		};
	}

	static function parseMinLength(xml:XML):MinLength {
		return parseMaxLength(xml);
	}

	static function parseRestriction(xml:XML):Restriction {
		// trace(xml);
		// trace(xml['xs:minLength'] );
		// trace(xml['minLength'], int( xml['minLength'] ) );
		var restriction:Restriction = {
			// id: xml['id'],
			base: xml['base'],
			attribute: [],
			enumeration: [],
		};
		for (e in xml.elements) {
			switch e.name {
				case 'xs:attribute':
					restriction.attribute.push(parseAttribute(e));
				case 'xs:enumeration':
					restriction.enumeration.push(parseEnumeration(e));
				case 'xs:minLength':
					restriction.minLength = parseMinLength(e);
				case 'xs:maxLength':
					restriction.maxLength = parseMaxLength(e);
			}
		}
		return restriction;
	}

	static function parseSequence(xml:XML):Sequence {
		var sequence:Sequence = {
			minOccurs: xml['minOccurs'],
			elements: [],
			any: [],
			choice: []
		};
		for (e in xml.elements)
			switch e.name {
				case 'xs:element':
					sequence.elements.push(parseElement(e));
				case 'xs:any':
					sequence.any.push(parseAny(e));
				case 'xs:choice':
					sequence.choice.push(parseChoice(e));
			}
		return sequence;
	}

	static function parseSimpleContent(xml:XML):SimpleContent {
		var obj:SimpleContent = {};
		for (e in xml.elements) {
			switch e.name {
				case 'xs:extension':
					obj.extension = parseExtension(e);
				case 'xs:restriction':
					obj.restriction = parseRestriction(e);
			}
		}
		return obj;
	}

	static function parseSimpleType(xml:XML):SimpleType {
		var simpleType:SimpleType = {
			name: xml['name'],
			restriction: []
		};
		for (e in xml.elements) {
			switch e.name {
				case 'xs:restriction':
					simpleType.restriction.push(parseRestriction(e));
			}
		}
		return simpleType;
	}

	static inline function int(s:String) {
		return (s == null) ? null : Std.parseInt(s);
	}
}
