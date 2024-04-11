package xmpp;

/**
	Communicate information about the last activity associated with an XMPP entity.

	[XEP-0012: Last Activiy](https://xmpp.org/extensions/xep-0012.html)
**/
@xep(12)
class LastActivity {
	public static inline var XMLNS = "jabber:iq:last";

	public static inline function getLastActivity(stream:Stream, ?jid:String, handler:Response<XML>->Void)
		stream.get(XMLNS, jid ?? stream.domain, handler);
}
