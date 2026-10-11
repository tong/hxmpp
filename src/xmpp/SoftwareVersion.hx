package xmpp;

import xmpp.IQ;

typedef TSoftwareVersion = {
    ?name : String,
    ?version : String,
    ?os : String,
}

/**
    [XEP-0092: Software Version](https://xmpp.org/extensions/xep-0092.html)
**/
@xep(92)
class SoftwareVersion {

    public static inline var XMLNS = "jabber:iq:version";

    /**
        Request software version information from entity.
    **/
    public static inline function getSoftwareVersion(stream: Stream, ?jid: String, handler: Response<XML>->Void) : IQ
        return stream.get(XMLNS, jid ?? stream.domain, handler);

    /**
        Send software information
    **/
    public static inline function replySoftwareVersion(stream:Stream, iq:IQ, info:TSoftwareVersion) : IQ {
        var xml = Payload.create(XMLNS)
            .append(XML.create("name", info.name))
            .append(XML.create("version", info.version))
            .append(XML.create("os", info.os));
        // var xml = XML.create('query').set('xmlns', XMLNS)
        //     .append(XML.create("name", info.name))
        //     .append(XML.create("version", info.version))
        //     .append(XML.create("os", info.os));
        var r = iq.createResult(xml);
        // var r = xmpp.IQ.createResult(iq, IQ.Payload.create(XMLNS,[
        //     XML.create("name", info.name),
        //     XML.create("version", info.version),
        //     XML.create("os", info.os)
        // ]));
        // if(info.name != null) r.payload.append(XML.create("name", info.name));
        // if(info.version != null) r.payload.append(XML.create("version", info.version));
        // if(info.os != null) r.payload.append(XML.create("os", info.os));
        stream.send(r);
        return r;
    }

}
