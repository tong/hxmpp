package xmpp.io;

import haxe.crypto.Base64;
import haxe.io.Bytes;
import haxe.io.Eof;
import xmpp.Stanza;

@xep(47)
class IBBytestream {

    public static inline var XMLNS = "http://jabber.org/protocol/ibb";

    public final stream : xmpp.Stream;

    public var entity(default,null) : String;
    public var sid(default,null) : String;
    public var blockSize(default,null) : Int;
    public var seq(default,null) : Int;
    public var bufPos(default,null) : Int;

    public function new(stream: xmpp.Stream) {
        this.stream = stream;
    }

    public function open(entity: String, ?sid: String, blockSize=4096, handler: Response<XML>->Void) : IBBytestream {
        this.entity = entity;
        this.sid = sid ?? xmpp.Stream.makeRandomId(8);
        this.blockSize = blockSize;
        stream.set(XML.create('open')
            .set("xmlns", XMLNS)
            .set("sid", this.sid)
            .set("block-size", Std.string(this.blockSize))
            //.set("stanza", "iq")
            ,entity, res -> {
                if(res.ok()) bufPos = seq = 0;
                handler(res);
            });
        return this;
    }

    public function send(bytes:Bytes, handler: (res:Response<XML>)->Void) {
        stream.set(XML.create('data', Base64.encode(bytes))
            .set("xmlns", XMLNS)
            .set("sid", sid)
            .set("seq", Std.string(seq)), entity, res -> {
                if(res.ok()) seq++;
                handler(res);
            });
    }

    public function accept(iq:IQ, ?confirm: Int->xmpp.Stanza.Error) : IBBytestream {
        if(!iq.payload.is(XMLNS) || this.entity != null)
            return null;
        sid = iq.payload.get('sid');
        blockSize = Std.parseInt(iq.payload.get('block-size'));
        if(confirm != null) {
            var err = confirm(blockSize);
            if(err != null) {
                var r = iq.createError({type:cancel, condition:not_acceptable});
                stream.send(r);
                return this;
            }
        }
        bufPos = seq = 0;
        stream.send(iq.createResult());
        return this;
    }


    public function handle(iq:IQ, onData: Bytes->Void, onClose: Void->Void) : IBBytestream {
        if(!iq.payload.is(XMLNS) || iq.payload.get('sid') != this.sid)
            return null;
        switch iq.payload.name {
        case "data":
            var seq = Std.parseInt(iq.payload.get("seq"));
            if(seq != this.seq) {
                trace('out of order ibb sequence',seq, this.seq);
                close();
                onClose();
            } else {
                this.seq++;
                var bytes = Base64.decode(iq.payload.text);
                stream.send(iq.createResult());
                onData(bytes);
            }
        case "close":
            stream.send(iq.createResult());
            onClose();
        }
        return this;
    }

    public function close(?handler: Response<XML>->Void) {
        var _sid = sid;
        var _entity = entity;
        entity = sid = null;
        blockSize = bufPos = seq = 0;
        stream.set(XML.create('close')
            .set("xmlns", XMLNS)
            .set("sid", _sid), _entity, handler);
    }
}

