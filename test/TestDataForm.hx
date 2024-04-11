import utest.Assert.*;
import xmpp.DataForm;

class TestDataForm extends utest.Test {
	static final TEST_FORM = new DataForm(result, "MyTitle", "MyInstructions", [
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
			equals("MyInstructions", form.instructions);
			equals(1, form.fields.length);
			equals("Some", form.fields[0].label);
			equals(list_single, form.fields[0].type);
			equals(1, form.fields[0].options.length);
			equals("abc", form.fields[0].options[0].value);
			equals("Option Label", form.fields[0].options[0].label);
			equals(0, form.items.length);
		}

		test(new DataForm(result, "MyTitle", "MyInstructions", [
			{
				label: "Some",
				type: list_single,
				options: [{label: "Option Label", value: "abc"}]
			}
		]));

		test({
			type: result,
			title: "MyTitle",
			instructions: "MyInstructions",
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
}
