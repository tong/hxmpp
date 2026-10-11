package xmpp;

import xmpp.IQ;

typedef TEntityTime = {
	/**
		The UTC time according to the responding entity.
		The format MUST conform to the dateTime profile specified in XEP-0082 and MUST be expressed in UTC.
	**/
	utc:String,

	/**
		The entity's numeric time zone offset from UTC.
		The format MUST conform to the Time Zone Definition (TZD) specified in XEP-0082.
	**/
	tzo:String,
}

/**
	Communicate the local time of an entity, including the time in UTC. 

	[XEP-0202: Entity Time](https://xmpp.org/extensions/xep-0202.html)
**/
@xep(202)
class EntityTime {
	public static inline var XMLNS = "urn:xmpp:time";

	public static inline function getEntityTime(stream:Stream, ?jid:String, handler:Response<XML>->Void):IQ {
		return stream.get(Payload.create(XMLNS, "time"), jid ?? stream.domain, handler);
	}
	/*
		public static inline function getEntityTime(stream: Stream, ?jid: String, handler: Response<TEntityTime>->Void) {
			stream.get(Payload.create(XMLNS, "time"), jid ?? stream.domain, (res:Response<XML>) -> {
				switch res {
				case Result(r):
				case Error(e): handler(cast res);
				/*
					handler(Result({
						utc: r.elements["utc"][0],
						tzo: r.elements["tzo"][0]
					}));
					* /
				}

			}); 
				/*
				res -> {
					$type(res);
					trace(res);
				}
				* /
		}
	 */
	// TODO:
	/*
		public static inline function sendEntityTime(stream : Stream, iq : IQ, info: TEntityTime) {
			var r = new IQ();
			r.to = iq.from;
			r.from = null;
			r.id = iq.id;
			r.type = Result;
			r.payload = IQ.Payload.create(XMLNS, [
				XML.create("utc", info.utc),
				XML.create("tzo", info.tzo)
			]);
			// if(info.utc != null) r.payload.append(XML.create("utc", info.utc));
			// if(info.tzo != null) r.payload.append(XML.create("tzo", info.tzo));
			stream.send(r);
		}
	 */
}
