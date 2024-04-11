package xmpp;

enum abstract FormType(String) from String to String {
	/**
		The form-submitting entity has cancelled submission of data to the form-processing entity.
	**/
	var cancel;

	/**
		The form-processing entity is asking the form-submitting entity to complete a form.
	**/
	var form;

	/**
		The form-processing entity is returning data (e.g., search results) to the form-submitting entity,
		or the data is a generic data set.
	**/
	var result;

	/**
		The form-submitting entity is submitting data to the form-processing entity.
		The submission MAY include fields that were not provided in the empty form,
		but the form-processing entity MUST ignore any fields that it does not understand.
	**/
	var submit;
}

enum abstract FieldType(String) from String to String {
	/**
		The field enables an entity to gather or provide an either-or choice between two options.
		The default value is `false`.
	**/
	var boolean; // TODO java throws error

	/**
		The field is intended for data description (e.g., human-readable text such as "section" headers) rather than data gathering or provision.
		The `<value/>` child SHOULD NOT contain newlines (the `\n` and `\r` characters);
		instead an application SHOULD generate multiple fixed fields, each with one `<value/>` child.
	**/
	var fixed;

	/**
		The field is not shown to the form-submitting entity, but instead is returned with the form.
		The form-submitting entity SHOULD NOT modify the value of a hidden field,
		but MAY do so if such behavior is defined for the "using protocol".
	**/
	var hidden;

	/**
		The field enables an entity to gather or provide multiple Jabber IDs.
		Each provided JID SHOULD be unique (as determined by comparison that includes application of the Nodeprep, Nameprep, and Resourceprep profiles of Stringprep as specified in XMPP Core),
		and duplicate JIDs MUST be ignored.
	**/
	var jid_multi = "jid-multi";

	/**
		The field enables an entity to gather or provide a single Jabber ID.
	**/
	var jid_single = "jid-single";

	/**
		The field enables an entity to gather or provide one or more options from among many.
		A form-submitting entity chooses one or more items from among the options presented by the form-processing entity and MUST NOT insert new options.
		The form-submitting entity MUST NOT modify the order of items as received from the form-processing entity, since the order of items MAY be significant.
	**/
	var list_multi = "list-multi";

	/**
		The field enables an entity to gather or provide one option from among many.
		A form-submitting entity chooses one item from among the options presented by the form-processing entity and MUST NOT insert new options.
	**/
	var list_single = "list-single";

	/**
		The field enables an entity to gather or provide multiple lines of text.
	**/
	var text_multi = "text-multi";

	/**
		The field enables an entity to gather or provide a single line or word of text,
		which shall be obscured in an interface (e.g., with multiple instances of the asterisk character).
	**/
	var text_private = "text-private";

	/**
		The field enables an entity to gather or provide a single line or word of text, which may be shown in an interface.
		This field type is the default and MUST be assumed if a form-submitting entity receives a field type it does not understand.
	**/
	var text_single = "text-single";
}

private typedef FieldOption = {
	var ?label:String;
	var value:String;
}

typedef Field = {
	/** **/
	var ?label:String;

	/** **/
	var ?type:FieldType;

	/** **/
	@:native('var') var ?variable:String;

	/** **/
	var ?options:Array<FieldOption>;

	/** Provides a natural-language description of the field. **/
	var ?desc:String;

	/** **/
	var ?values:Array<String>;

	/** Flags the field as required in order for the form to be considered valid. **/
	var ?required:Bool;
}

@:structInit private class TDataForm {
	public var type:FormType;
	public var title:String;
	public var instructions:String;
	public var fields:Array<Field>;
	public var reported:Array<Field>;
	public var items:Array<Array<Field>>;

	public function new(type:FormType, ?title:String, ?instructions:String, ?fields:Array<Field>, ?reported:Array<Field>, ?items:Array<Array<Field>>) {
		this.type = type;
		this.title = title;
		this.instructions = instructions;
		this.fields = fields ?? [];
		this.reported = reported ?? [];
		this.items = items ?? [];
	}
}

/**
	Data forms that can be used in workflows such as service configuration as well as for application-specific data description and reporting.

	[XEP-0004: Data Forms](https://xmpp.org/extensions/xep-0004.html)
**/
@:forward
abstract DataForm(TDataForm) from TDataForm to TDataForm {
	public static inline var XMLNS = "jabber:x:data";

	public inline function new(type:FormType, ?title:String, ?instructions:String, ?fields:Array<Field>, ?items:Array<Array<Field>>)
		this = new TDataForm(type, title, instructions, fields, items);

	@:to public function toXML():XML {
		function fieldToXML(f:Field):XML {
			final c = XML.create("field");
			if (f.variable != null)
				c.set("var", f.variable);
			if (f.label != null)
				c.set("label", f.label);
			if (f.type != null)
				c.set("type", f.type);
			if (f.options != null)
				for (o in f.options) {
					var e = XML.create("option");
					if (o.label != null)
						e.set("label", o.label);
					e.append(XML.create("value", o.value));
					c.append(e);
				}
			if (f.desc != null)
				c.set("desc", f.desc);
			if (f.values != null)
				for (v in f.values)
					c.append(XML.create("value", v));
			return c;
		}
		final xml = XML.create("x").set("xmlns", XMLNS).set("type", this.type);
		if (this.title != null)
			xml.append(XML.create("title", this.title));
		if (this.instructions != null)
			xml.append(XML.create("instructions", this.instructions));
		for (f in this.fields)
			xml.append(fieldToXML(f));
		if (this.reported.length > 0) {
			final e = XML.create("reported");
			for (f in this.reported)
				e.append(fieldToXML(f));
			xml.append(e);
		}
		return xml;
	}

	@:from public static function fromXML(xml:XML):DataForm {
		function parseField(e:XML):Field {
			final f:Field = {
				type: e["type"],
				label: e["label"],
				variable: e["var"],
				options: []
			};
			for (e in e.elements) {
				switch e.name {
					case "desc":
						f.desc = e.text;
					case "option":
						f.options.push({
							label: e["label"],
							value: e.firstElement.text
						});
					case "required":
						f.required = true;
				}
			}
			return f;
		}
		final form = new DataForm(xml.get("type"));
		for (e in xml.elements) {
			switch e.name {
				case "title":
					form.title = e.text;
				case "field":
					form.fields.push(parseField(e));
				case "item":
					for (e in e.elements)
						form.items.push([for (e in e.elements) parseField(e)]);
				case "instructions":
					form.instructions = e.text;
				case "reported":
					for (e in e.elements)
						form.reported.push(parseField(e));
			}
		}
		return form;
	}
}
