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
		3. Establishs a session with the server
	**/
	public static function authenticate(stream:Stream, node:String, resource:String, ?password:String, mechanism:Mechanism,
			callback:(?error:xmpp.Stanza.Error) -> Void, ?streamStart:(XML->Void)->Void) {
		saslAuthentication(stream, node, resource, password, mechanism, (?e, features) -> {
			if (e != null)
				callback(e)
			else {
				bindResource(stream, resource, (?e, r) -> {
					if (e != null)
						callback(e)
					else {
						initSesssion(stream, callback);
					}
				});
			}
		}, streamStart);
	}

	/**
		Authenticate a client account.
	**/
	public static function saslAuthentication(stream:Stream, node:String, resource:String, ?password:String, mechanism:Mechanism,
			callback:(?error:xmpp.Stanza.Error, features:XML) -> Void, ?streamStart:(XML->Void)->Void) {
		var _input = stream.input;
		function _callback(?e, features) {
			stream.input = _input;
			callback(e, features);
		}
		stream.input = str -> {
			// var xml = try XML.parse(str) catch(e:Dynamic) {
			//     callback(new xmpp.Stanza.Error(null, condition, text));
			//     return;
			// }
			final xml = XML.parse(str).firstElement;
			switch xml.name {
				case 'challenge':
					var res = mechanism.createChallengeResponse(xml.text);
					res = Base64.encode(Bytes.ofString(res));
					stream.send(XML.create('response', res).set('xmlns', XMLNS));
				case 'success':
					if (streamStart == null)
						streamStart = stream.start;
					streamStart(features -> {
						_callback(null, features);
					});
				case 'failure':
					var text:String = null;
					var condition:xmpp.Stanza.ErrorCondition = null;
					for (e in xml.elements) {
						switch e.name {
							case "text": text = e.text;
							default: condition = e.name;
						}
					}
					_callback(new xmpp.Stanza.Error(null, condition, text), null);
			}
		}
		final text = mechanism.createAuthenticationText(node, stream.domain, password);
		final auth = XML.create('auth').set('xmlns', XMLNS).set('mechanism', mechanism.name);
		if (text != null)
			auth.text = Base64.encode(Bytes.ofString(text), true);
		stream.send(auth);
	}

	/**
		Bind the resource to the connection.
	**/
	public static function bindResource(stream:Stream, resource:String, callback:(?error:xmpp.Stanza.Error, resource:String) -> Void) {
		final xml = XML.create('bind').set('xmlns', XMLNS_BIND).append(XML.create('resource', resource));
		stream.set(xml, (res:Response<XML>) -> {
			switch res {
				case Error(e): callback(e, null);
				case Result(payload):
					switch payload.firstElement.name {
						case 'jid':
							callback(null, Jid.parseResource(payload.firstElement.text));
						case 'resource':
							callback(null, payload.firstElement.text);
						default:
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
