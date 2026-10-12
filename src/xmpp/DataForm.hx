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
	var boolean;

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

/**
	Option of a `list-single` or `list-multi` field.
**/
typedef FieldOption = {
	/** Human-readable name of the option **/
	var ?label:String;

	/** Value of the option **/
	var value:String;
}

/**
	Field of a data form.
**/
typedef Field = {
	/** Human-readable name of the field **/
	var ?label:String;

	/** Field type, `text-single` if not set (see `DataForm.fieldType`) **/
	var ?type:FieldType;

	/** Unique identifier of the field (`var` attribute); required for all types except `fixed` **/
	var ?variable:String;

	/** Options of `list-single` and `list-multi` fields **/
	var ?options:Array<FieldOption>;

	/** Natural-language description of the field **/
	var ?desc:String;

	/** Values; only `list-multi`, `jid-multi`, `text-multi` and `hidden` fields may have more than one **/
	var ?values:Array<String>;

	/** Flags the field as required in order for the form to be considered valid **/
	var ?required:Bool;
}

@:structInit private class TDataForm {
	public var type:FormType;
	public var title:String;
	public var instructions:Array<String>;
	public var fields:Array<Field>;
	public var reported:Array<Field>;
	public var items:Array<Array<Field>>;

	public function new(type:FormType, ?title:String, ?instructions:Array<String>, ?fields:Array<Field>, ?reported:Array<Field>,
			?items:Array<Array<Field>>) {
		this.type = type;
		this.title = title;
		this.instructions = instructions ?? [];
		this.fields = fields ?? [];
		this.reported = reported ?? [];
		this.items = items ?? [];
	}
}

/**
	Data forms that can be used in workflows such as service configuration as well as for application-specific data description and reporting.

	Typical use: receive a form, read it with `getValue`/`getBool`, and answer with `createSubmit` or `createCancel`.

	[XEP-0004: Data Forms](https://xmpp.org/extensions/xep-0004.html)
**/
@:forward
abstract DataForm(TDataForm) from TDataForm to TDataForm {
	public static inline var XMLNS = "jabber:x:data";

	/** Name of the hidden field identifying the kind of form ([XEP-0068](https://xmpp.org/extensions/xep-0068.html)) **/
	public static inline var FORM_TYPE = "FORM_TYPE";

	public inline function new(type:FormType, ?title:String, ?instructions:Array<String>, ?fields:Array<Field>, ?reported:Array<Field>,
			?items:Array<Array<Field>>)
		this = new TDataForm(type, title, instructions, fields, reported, items);

	/**
		Value of the hidden `FORM_TYPE` field, or `null`.
	**/
	public var formType(get, never):Null<String>;

	inline function get_formType():Null<String>
		return getValue(FORM_TYPE);

	/**
		Returns the field with given `variable` (`var` attribute), or `null`.
	**/
	public function getField(variable:String):Null<Field> {
		for (f in this.fields)
			if (f.variable == variable)
				return f;
		return null;
	}

	/**
		Returns the values of the field with given `variable`, empty if there is no such field.
	**/
	public function getValues(variable:String):Array<String> {
		final f = getField(variable);
		return (f == null || f.values == null) ? [] : f.values;
	}

	/**
		Returns the first value of the field with given `variable`, or `null`.
	**/
	public inline function getValue(variable:String):Null<String>
		return getValues(variable)[0];

	/**
		Returns the boolean value of the field with given `variable` (`1`/`true` or `0`/`false`),
		`false` for a boolean field without value, `null` if there is no such field or the value is no boolean.
	**/
	public function getBool(variable:String):Null<Bool> {
		final f = getField(variable);
		if (f == null)
			return null;
		return switch getValue(variable) {
			case "1", "true": true;
			case "0", "false": false;
			case null: (f.type == boolean) ? false : null;
			case _: null;
		}
	}

	/**
		Creates a form of type `submit` answering this form.

		Contains the `FORM_TYPE` field, the fields given in `values`, and required fields not in `values` with their current values.
	**/
	public function createSubmit(?values:Map<String, Array<String>>):DataForm {
		final fields = new Array<Field>();
		final added = new Map<String, Bool>();
		for (f in this.fields) {
			if (f.variable == null || f.type == fixed)
				continue;
			final v = (values == null) ? null : values.get(f.variable);
			if (v != null || f.variable == FORM_TYPE || f.required == true) {
				fields.push({variable: f.variable, values: v ?? f.values ?? []});
				added.set(f.variable, true);
			}
		}
		if (values != null)
			for (k => v in values)
				if (!added.exists(k))
					fields.push({variable: k, values: v});
		return new DataForm(submit, null, null, fields);
	}

	/**
		Creates a form of type `cancel` to decline this form.
	**/
	public static inline function createCancel():DataForm
		return new DataForm(cancel);

	/**
		Returns the type of `field`: `text-single` if the type is not set or unknown.
	**/
	public static function fieldType(field:Field):FieldType {
		return switch field.type {
			case boolean, fixed, hidden, jid_multi, jid_single, list_multi, list_single, text_multi, text_private, text_single: field.type;
			case _: text_single;
		}
	}

	@:to public function toXML():XML {
		function fieldToXML(f:Field):XML {
			final c = XML.create("field");
			if (f.variable != null)
				c.set("var", f.variable);
			if (f.label != null)
				c.set("label", f.label);
			if (f.type != null)
				c.set("type", f.type);
			if (f.desc != null)
				c.append(XML.create("desc", f.desc));
			if (f.required == true)
				c.append(XML.create("required"));
			if (f.values != null)
				for (v in f.values)
					c.append(XML.create("value", v));
			if (f.options != null)
				for (o in f.options) {
					final e = XML.create("option");
					if (o.label != null)
						e.set("label", o.label);
					e.append(XML.create("value", o.value));
					c.append(e);
				}
			return c;
		}
		final xml = XML.create("x").set("xmlns", XMLNS).set("type", this.type);
		if (this.title != null)
			xml.append(XML.create("title", this.title));
		for (i in this.instructions)
			xml.append(XML.create("instructions", i));
		for (f in this.fields)
			xml.append(fieldToXML(f));
		if (this.reported.length > 0) {
			final e = XML.create("reported");
			for (f in this.reported)
				e.append(fieldToXML(f));
			xml.append(e);
		}
		for (item in this.items) {
			final e = XML.create("item");
			for (f in item)
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
				options: [],
				values: []
			};
			for (e in e.elements) {
				switch e.name {
					case "desc":
						f.desc = e.text;
					case "required":
						f.required = true;
					case "value":
						f.values.push(e.text ?? "");
					case "option":
						final value = e.elements.named("value")[0];
						f.options.push({
							label: e["label"],
							value: (value == null) ? null : value.text
						});
				}
			}
			return f;
		}
		final form = new DataForm(xml.get("type"));
		for (e in xml.elements) {
			switch e.name {
				case "title":
					form.title = e.text;
				case "instructions":
					form.instructions.push(e.text ?? "");
				case "field":
					form.fields.push(parseField(e));
				case "reported":
					for (f in e.elements)
						form.reported.push(parseField(f));
				case "item":
					form.items.push([for (f in e.elements) parseField(f)]);
			}
		}
		return form;
	}
}
