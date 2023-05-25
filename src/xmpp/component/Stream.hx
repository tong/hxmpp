package xmpp.component;

import haxe.crypto.Sha1;

/**
	[XEP-0114: Jabber Component Protocol](https://xmpp.org/extensions/xep-0114.html)
**/
class Stream extends xmpp.Stream {

	public static inline var PORT = 5275;

	/** Server (accept) component namespace **/
	public static inline var XMLNS = 'jabber:component:accept';

	/** Component name **/
	public var name(default,null) : String;

	public function new(name: String, domain: String, ?xmlns:String, ?lang: String) {
		super(xmlns ?? XMLNS, domain, lang);
		this.name = name;
	}

	public function start(secret:String, callback:(?error:xmpp.Stanza.Error)->Void) {
		reset();
		input = (str:String) -> {
			final header = xmpp.Stream.readHeader( str );
			id = header.id;
			send(XML.create('handshake', Sha1.encode(id+secret)));
			input = (str) -> {
				final xml = Xml.parse(str);
                final nodeName = xml.firstChild().nodeName;
				switch nodeName {
				case 'handshake':
					ready = true;
					input = handleString;
					callback();
				default:
					switch nodeName {
					case 'stream:error':
					    ready = false;
						//TODO
					    trace(xml);
						var error = xmpp.Stanza.Error.fromXML(xml);
						//trace(error.condition);
						callback( error );
					}
				}
			}
		}
		output(xmpp.Stream.createHeader(XMLNS, '$name.$domain', null, lang));
	}
}
