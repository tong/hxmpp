package xmpp.client;

import haxe.crypto.Base64;
import haxe.io.Bytes;
import sasl.Mechanism;
import xmpp.Response;

/**
	SASL (Simple Authentication and Security Layer) client authentication.

	- [RFC3920-SASL](https://xmpp.org/rfcs/rfc3920.html#sasl)
	- [RFC3920-BIND](https://xmpp.org/rfcs/rfc3920.html#bind)
	- [RFC2222](https://datatracker.ietf.org/doc/html/rfc2222)
**/
class Authentication {
	public static inline var XMLNS = 'urn:ietf:params:xml:ns:xmpp-sasl';
	public static inline var XMLNS_BIND = 'urn:ietf:params:xml:ns:xmpp-bind';
	public static inline var XMLNS_SESSION = 'urn:ietf:params:xml:ns:xmpp-session';

	/**
		1. Authenticate a client account using SASL
		2. Binds the resource to the connection
		3. Establishs a session with the server, if required by the server
	**/
	public static function authenticate(stream:Stream, node:String, resource:String, ?password:String, mechanism:Mechanism,
			callback:(?error:xmpp.Stanza.Error) -> Void, ?streamStart:(XML->Void)->Void) {
		saslAuthentication(stream, node, password, mechanism, (?e, features) -> {
			if (e != null)
				callback(e)
			else {
				bindResource(stream, resource, (?e, r) -> {
					if (e != null)
						callback(e)
					else if (isSessionRequired(features))
						initSesssion(stream, callback);
					else
						callback();
				});
			}
		}, streamStart);
	}

	/**
		Returns `true` if the stream features require session establishment.

		Session establishment was removed in [RFC 6121](https://xmpp.org/rfcs/rfc6121.html#session);
		servers supporting it for backwards compatibility mark it as `<optional/>`.
	**/
	public static function isSessionRequired(features:Null<XML>):Bool {
		if (features == null)
			return false;
		for (e in features.elements)
			if (e.name == 'session' && e.is(XMLNS_SESSION))
				return e.elements.named('optional').length == 0;
		return false;
	}

	/**
		Authenticate a client account.

		Fails if the mechanism rejects a server challenge (the exchange is aborted)
		or the server can not prove its identity on success (e.g. SCRAM server signature).
	**/
	public static function saslAuthentication(stream:Stream, node:String, ?password:String, mechanism:Mechanism,
			callback:(?error:xmpp.Stanza.Error, features:XML) -> Void, ?streamStart:(XML->Void)->Void) {
		var _input = stream.input;
		function _callback(?e, features) {
			stream.input = _input;
			callback(e, features);
		}
		// Set if the client aborted the exchange; reported once the server confirmed with <failure/>
		var abortError:xmpp.Stanza.Error = null;
		stream.input = str -> {
			final xml = XML.parse(str).firstElement;
			switch xml.name {
				case 'challenge':
					final res = try mechanism.createChallengeResponse(xml.text) catch (e:sasl.Error) {
						abortError = new xmpp.Stanza.Error(auth, not_authorized, e.message);
						stream.send(XML.create('abort').set('xmlns', XMLNS));
						return;
					}
					final response = XML.create('response').set('xmlns', XMLNS);
					if (res != null)
						response.text = Base64.encode(Bytes.ofString(res));
					stream.send(response);
				case 'success':
					if (!mechanism.verifySuccess(xml.text)) {
						// The server failed to prove its identity, do not proceed
						_callback(new xmpp.Stanza.Error(auth, not_authorized, 'server failed to prove its identity'), null);
						return;
					}
					if (streamStart == null)
						streamStart = stream.start;
					streamStart(features -> {
						_callback(null, features);
					});
				case 'failure':
					_callback(abortError ?? parseError(xml, auth), null);
				case 'stream:error':
					_callback(parseError(xml, cancel), null);
				default:
					_callback(new xmpp.Stanza.Error(cancel, undefined_condition, 'unexpected sasl response: ${xml.name}'), null);
			}
		}
		final text = mechanism.createAuthenticationText(node, stream.domain, password);
		final auth = XML.create('auth').set('xmlns', XMLNS).set('mechanism', mechanism.name);
		if (text != null)
			auth.text = Base64.encode(Bytes.ofString(text), true);
		stream.send(auth);
	}

	static function parseError(xml:XML, type:xmpp.Stanza.ErrorType):xmpp.Stanza.Error {
		var text:String = null;
		var condition:xmpp.Stanza.ErrorCondition = undefined_condition;
		for (e in xml.elements) {
			switch e.name {
				case "text":
					text = e.text;
				default:
					condition = e.name;
			}
		}
		return new xmpp.Stanza.Error(type, condition, text);
	}

	/**
		Bind the resource to the connection.

		If `resource` is `null` the server generates one.
	**/
	public static function bindResource(stream:Stream, ?resource:String, callback:(?error:xmpp.Stanza.Error, resource:String) -> Void) {
		final xml = XML.create('bind').set('xmlns', XMLNS_BIND);
		if (resource != null)
			xml.append(XML.create('resource', resource));
		stream.set(xml, (res:Response<XML>) -> {
			switch res {
				case Error(e): callback(e, null);
				case Result(payload):
					final e = (payload == null) ? null : payload.firstElement;
					switch e?.name {
						case 'jid':
							stream.jid = e.text;
							callback(null, Jid.parseResource(stream.jid));
						case 'resource':
							callback(null, e.text);
						default:
							callback(new xmpp.Stanza.Error(cancel, undefined_condition, 'invalid bind response'), null);
					}
			}
		});
	}

	/**
		Establish a session with the server.
	**/
	public static function initSesssion(stream:Stream, callback:(?error:xmpp.Stanza.Error) -> Void) {
		stream.set(XML.create('session').set('xmlns', XMLNS_SESSION), res -> {
			callback(switch res {
				case Error(e): e;
				case _: null;
			});
		});
	}
}
