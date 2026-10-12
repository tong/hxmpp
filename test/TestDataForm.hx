import utest.Assert.*;
import xmpp.DataForm;
import xmpp.XML;

class TestDataForm extends utest.Test {
	static final TEST_FORM = new DataForm(result, "MyTitle", ["MyInstructions"], [
		{
			label: "Some",
			type: list_single,
			options: [{label: "Option Label", value: "abc"}]
		}
	]);

	function test_construct() {
		function test(form:DataForm) {
			equals(result, form.type);
			equals("MyTitle", form.title);
			equals("MyInstructions", form.instructions[0]);
			equals(1, form.fields.length);
			equals("Some", form.fields[0].label);
			equals(list_single, form.fields[0].type);
			equals(1, form.fields[0].options.length);
			equals("abc", form.fields[0].options[0].value);
			equals("Option Label", form.fields[0].options[0].label);
			equals(0, form.items.length);
		}

		test(new DataForm(result, "MyTitle", ["MyInstructions"], [
			{
				label: "Some",
				type: list_single,
				options: [{label: "Option Label", value: "abc"}]
			}
		]));

		test({
			type: result,
			title: "MyTitle",
			instructions: ["MyInstructions"],
			fields: [
				{
					label: "Some",
					type: list_single,
					options: [{label: "Option Label", value: "abc"}]
				}
			],
			items: []
		});
	}

	function test_toXML() {
		var xml = TEST_FORM.toXML();
		equals(DataForm.XMLNS, xml.get("xmlns"));
		equals("result", xml.get("type"));
		for (e in xml.elements) {
			switch e.name {
				case "title":
					equals("MyTitle", e.text);
				case "instructions":
					equals("MyInstructions", e.text);
			}
		}
		equals(1, xml.elements.named("field").length);
		equals("Some", xml.elements.named("field")[0].get("label"));
		equals(list_single, xml.elements.named("field")[0].get("type"));
		equals(1, xml.elements.named("field")[0].elements.named("option").length);
		equals("Option Label", xml.elements.named("field")[0].elements.named("option")[0].get("label"));
		equals("abc", xml.elements.named("field")[0].elements.named("option")[0].firstElement.text);
		equals(0, xml.elements.named("items").length);
	}

	function test_parse_form() {
		// https://xmpp.org/extensions/xep-0004.html#protocol-results (example 2, shortened)
		final form:DataForm = XML.fromString('<x xmlns="jabber:x:data" type="form">
			<title>Bot Configuration</title>
			<instructions>Fill out this form to configure your new bot!</instructions>
			<field type="hidden" var="FORM_TYPE"><value>jabber:bot</value></field>
			<field type="text-single" label="The name of your bot" var="botname"><desc>Choose a name</desc><required/></field>
			<field type="list-multi" label="What features will the bot support?" var="features">
				<option label="Contests"><value>contests</value></option>
				<option label="News"><value>news</value></option>
				<value>news</value>
				<value>search</value>
			</field>
			<field type="boolean" var="public"><value>0</value></field>
		</x>');
		equals(FormType.form, form.type);
		equals('Bot Configuration', form.title);
		equals(4, form.fields.length);

		equals('FORM_TYPE', form.fields[0].variable);
		equals('jabber:bot', form.fields[0].values[0]);

		final botname = form.fields[1];
		equals('Choose a name', botname.desc);
		isTrue(botname.required);
		equals(0, botname.values.length);

		final features = form.fields[2];
		equals(list_multi, features.type);
		equals('news,search', features.values.join(','));
		equals(2, features.options.length);
		equals('Contests', features.options[0].label);
		equals('contests', features.options[0].value);

		equals('0', form.fields[3].values[0]);
	}

	function test_parse_items() {
		// https://xmpp.org/extensions/xep-0004.html#protocol-results (example 8)
		final form:DataForm = XML.fromString('<x xmlns="jabber:x:data" type="result">
			<title>Joogle Search: verona</title>
			<reported>
				<field var="name"/>
				<field var="url"/>
			</reported>
			<item>
				<field var="name"><value>Comune di Verona - Benvenuti nel sito ufficiale</value></field>
				<field var="url"><value>http://www.comune.verona.it/</value></field>
			</item>
			<item>
				<field var="name"><value>benvenuto!</value></field>
				<field var="url"><value>http://www.hellasverona.it/</value></field>
			</item>
		</x>');
		equals(2, form.reported.length);
		equals('url', form.reported[1].variable);
		equals(2, form.items.length);
		equals(2, form.items[0].length);
		equals('name', form.items[0][0].variable);
		equals('Comune di Verona - Benvenuti nel sito ufficiale', form.items[0][0].values[0]);
		equals('http://www.hellasverona.it/', form.items[1][1].values[0]);
	}

	function test_roundtrip() {
		final form:DataForm = {
			type: result,
			title: "Results",
			instructions: null,
			fields: [
				{
					variable: "botname",
					type: text_single,
					desc: "Choose a name",
					required: true,
					values: ["hxmpp"]
				}
			],
			reported: [{variable: "name"}],
			items: [[{variable: "name", values: ["a"]}], [{variable: "name", values: ["b"]}]]
		};
		final xml = form.toXML();
		final field = xml.elements.named("field")[0];
		equals("Choose a name", field.elements.named("desc")[0].text);
		isNull(field.get("desc"));
		equals(1, field.elements.named("required").length);
		equals(2, xml.elements.named("item").length);

		final parsed:DataForm = XML.fromString(xml.toString());
		equals("Results", parsed.title);
		equals("Choose a name", parsed.fields[0].desc);
		isTrue(parsed.fields[0].required);
		equals("hxmpp", parsed.fields[0].values[0]);
		equals("name", parsed.reported[0].variable);
		equals(2, parsed.items.length);
		equals("b", parsed.items[1][0].values[0]);
	}

	function test_instructions() {
		final form:DataForm = XML.fromString('<x xmlns="jabber:x:data" type="form"><instructions>one</instructions><instructions>two</instructions></x>');
		equals('one,two', form.instructions.join(','));
		equals(2, form.toXML().elements.named('instructions').length);
		equals(0, new DataForm(FormType.form).instructions.length);
	}

	function test_values() {
		// https://xmpp.org/extensions/xep-0045.html#createroom-reserved (shortened)
		final form:DataForm = XML.fromString('<x xmlns="jabber:x:data" type="form">
			<field var="FORM_TYPE" type="hidden"><value>http://jabber.org/protocol/muc#roomconfig</value></field>
			<field var="muc#roomconfig_roomname" type="text-single" label="Natural-Language Room Name"><value>Room</value></field>
			<field var="muc#roomconfig_persistentroom" type="boolean"><value>1</value></field>
			<field var="muc#roomconfig_publicroom" type="boolean"><value>false</value></field>
			<field var="muc#roomconfig_moderatedroom" type="boolean"/>
			<field var="muc#roomconfig_roomadmins" type="jid-multi"><value>wiccarocks@shakespeare.lit</value><value>hecate@shakespeare.lit</value></field>
			<field var="muc#roomconfig_roomsecret" type="text-private"><required/></field>
			<field type="fixed"><value>Section</value></field>
			<field var="custom" type="x-unknown"/>
		</x>');
		equals('http://jabber.org/protocol/muc#roomconfig', form.formType);
		equals('Room', form.getValue('muc#roomconfig_roomname'));
		equals(2, form.getValues('muc#roomconfig_roomadmins').length);
		equals(0, form.getValues('nope').length);
		isNull(form.getValue('nope'));
		isNull(form.getField('nope'));
		isTrue(form.getBool('muc#roomconfig_persistentroom'));
		isFalse(form.getBool('muc#roomconfig_publicroom'));
		isFalse(form.getBool('muc#roomconfig_moderatedroom'));
		isNull(form.getBool('muc#roomconfig_roomname'));
		isNull(form.getBool('nope'));

		equals(jid_multi, DataForm.fieldType(form.getField('muc#roomconfig_roomadmins')));
		equals(text_single, DataForm.fieldType(form.getField('custom')));
		equals(text_single, DataForm.fieldType({variable: 'x'}));

		final submit = form.createSubmit(['muc#roomconfig_roomname' => ['New Room'], 'extra' => ['x']]);
		equals(FormType.submit, submit.type);
		equals('FORM_TYPE,muc#roomconfig_roomname,muc#roomconfig_roomsecret,extra', [for (f in submit.fields) f.variable].join(','));
		equals('http://jabber.org/protocol/muc#roomconfig', submit.formType);
		equals('New Room', submit.getValue('muc#roomconfig_roomname'));
		final xml = submit.toXML();
		equals('submit', xml.get('type'));
		for (f in xml.elements.named('field')) {
			isFalse(f.has('label'));
			isFalse(f.has('type'));
		}

		equals('cancel', DataForm.createCancel().toXML().get('type'));
		equals(0, DataForm.createCancel().toXML().elements.length);
	}

	function test_reported_constructor() {
		final form = new DataForm(result, null, null, null, [{variable: 'name'}], [[{variable: 'name', values: ['a']}]]);
		equals(1, form.reported.length);
		equals(1, form.items.length);
	}
}
