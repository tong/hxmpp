import utest.Assert.*;
import xmpp.Response;
import xmpp.XML;
import xmpp.client.Account;

class TestAccount extends utest.Test {
	var stream:xmpp.client.Stream;
	var sent:Array<String>;

	function setup() {
		sent = [];
		stream = new xmpp.client.Stream('shakespeare.lit');
		stream.output = str -> sent.push(str);
		stream.start(features -> {});
		stream.recv("<stream:stream xmlns='jabber:client' xmlns:stream='http://etherx.jabber.org/streams' id='abc' from='shakespeare.lit' version='1.0'><stream:features><register xmlns='http://jabber.org/features/iq-register'/></stream:features>");
	}

	function lastSent():XML
		return XML.fromString(sent[sent.length - 1]);

	function test_is_offered() {
		isTrue(Account.isOffered(XML.fromString("<stream:features xmlns:stream='http://etherx.jabber.org/streams'><register xmlns='http://jabber.org/features/iq-register'/></stream:features>")));
		isFalse(Account.isOffered(XML.fromString("<stream:features xmlns:stream='http://etherx.jabber.org/streams'/>")));
		isFalse(Account.isOffered(null));
	}

	function test_fields() {
		// https://xmpp.org/extensions/xep-0077.html#usecases-register
		var response:Response<XML> = null;
		final iq = Account.requestRegistrationFields(stream, r -> response = r);
		equals('get', lastSent().get('type'));
		isNull(lastSent().get('to'));
		stream.recv('<iq type="result" id="${iq.id}"><query xmlns="jabber:iq:register"><instructions>\n Choose a username and password for use with this service.\n Please also provide your email address.\n </instructions><username/><password/><email/></query></iq>');
		final f = Account.parseFields(response.payload);
		isFalse(f.registered);
		isTrue(StringTools.startsWith(f.instructions, 'Choose a username'));
		equals('username,password,email', f.fields.join(','));
		isNull(f.form);

		final f = Account.parseFields(XML.fromString('<query xmlns="jabber:iq:register"><registered/><username>juliet</username><password>R0m30</password><email>juliet@capulet.com</email></query>'));
		isTrue(f.registered);
		equals('juliet', f.values.get('username'));

		final f = Account.parseFields(XML.fromString('<query xmlns="jabber:iq:register"><instructions>Use the enclosed form</instructions><x xmlns="jabber:x:data" type="form"><field type="hidden" var="FORM_TYPE"><value>jabber:iq:register</value></field><field type="text-single" label="Given Name" var="first"><required/></field></x></query>'));
		equals('jabber:iq:register', f.form.formType);
		equals(0, f.fields.length);
	}

	function test_register() {
		Account.register(stream, ['username' => 'bill', 'password' => 'Calliope', 'email' => 'bard@shakespeare.lit'], r -> {});
		final query = lastSent().firstElement;
		equals('set', lastSent().get('type'));
		equals('email,password,username', [for (e in query.elements) e.name].join(','));
		equals('bill', query.elements.named('username')[0].text);

		Account.register(stream, ['username' => 'bill'], 'irc.shakespeare.lit', r -> {});
		equals('irc.shakespeare.lit', lastSent().get('to'));

		final form = new xmpp.DataForm(form, null, null, [{variable: 'FORM_TYPE', type: hidden, values: ['jabber:iq:register']}, {variable: 'first', required: true}]);
		Account.submitForm(stream, form.createSubmit(['first' => ['Juliet']]), r -> {});
		final x = lastSent().firstElement.firstElement;
		equals('x', x.name);
		equals('submit', x.get('type'));
	}

	function test_unregister_form_in_error() {
		// https://xmpp.org/extensions/xep-0077.html#usecases-cancel
		var response:Response<XML> = null;
		final iq = Account.unregister(stream, r -> response = r);
		equals('remove', lastSent().firstElement.firstElement.name);
		stream.recv('<iq type="error" from="shakespeare.lit" id="${iq.id}"><query xmlns="jabber:iq:register"><x xmlns="jabber:x:data" type="form"><title>Cancel Registration</title><field type="hidden" var="FORM_TYPE"><value>jabber:iq:register:cancel</value></field><field type="text-single" label="Username" var="username"><required/></field></x></query><error code="405" type="cancel"><not-allowed xmlns="urn:ietf:params:xml:ns:xmpp-stanzas"/></error></iq>');
		isFalse(response.ok());
		equals('not-allowed', (response.error.condition : String));
		final form = Account.parseFields(response.error.payload).form;
		equals('jabber:iq:register:cancel', form.formType);
	}

	function test_change_password() {
		Account.changePassword(stream, 'bill', 'newpass', r -> {});
		final query = lastSent().firstElement;
		equals('bill', query.elements.named('username')[0].text);
		equals('newpass', query.elements.named('password')[0].text);

		final count = sent.length;
		var response:Response<XML> = null;
		isNull(Account.changePassword(stream, 'bill', '', r -> response = r));
		equals(count, sent.length);
		equals('not-acceptable', (response.error.condition : String));
	}
}
