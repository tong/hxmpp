package xmpp;

using StringTools;

@:structInit private class URIType {
    public var jid : String;
    public var action : String;
    public var account : String;//TODO
    public var params : Map<String,String>;
}

/**
    XMPP Uniform Resource Identifiers (URIs).

    https://xmpp.org/rfcs/rfc5122.html
**/
@:forward
abstract URI(URIType) from URIType to URIType {

    public inline function clone() : URI {
        return {
            jid: this.jid,
            action: this.action,
            account: this.account,
            params: [for(k=>v in this.params) k=>v]
        }
    }

    public function equalsTo(uri:URI) : Bool {
        if(this.jid != uri.jid
            || this.action != uri.action
            || this.account != uri.account
            || Lambda.count(this.params) != Lambda.count(uri.params))
            return false;
        for(a=>b in this.params)
            if(uri.params.get(a) != b)
                return false;
        return true;
    }

    @:to public function toString() {
        var s = 'xmpp:';
        if(this.account != null) s += '//${this.account}/';
        if(this.jid != null) s += this.jid;
        if(this.action != null) {
            s += '?'+this.action;
            if(this.params != null)
                for(k=>v in this.params) s += ';$k=${v.urlEncode()}';
        }
        return s;
    }

    @:op(A==B) public static inline function equals(self:URI, that:URI) : Bool
		return self.equalsTo(that);

    @:from public static inline function fromString(s:String):URI
        return parse(s);

    /**
        Parses `xmpp:[//account/]jid[?action[;key=value]*]`, returns `null` if invalid.
    **/
    public static function parse(str:String) : URI {
        if(str == null || !str.startsWith('xmpp:'))
            return null;
        var rest = str.substr(5);
        var account : String = null;
        if(rest.startsWith('//')) {
            rest = rest.substr(2);
            final slash = rest.indexOf('/');
            account = (slash == -1) ? rest : rest.substr(0, slash);
            rest = (slash == -1) ? '' : rest.substr(slash + 1);
        }
        final hash = rest.indexOf('#');
        if(hash != -1)
            rest = rest.substr(0, hash);
        final r : URI = {
            jid: null,
            action: null,
            account: (account == null) ? null : account.urlDecode(),
            params: [],
        };
        final i = rest.indexOf('?');
        final path = (i == -1) ? rest : rest.substr(0, i);
        if(path.length > 0)
            r.jid = path.urlDecode();
        if(i != -1) {
            final params = rest.substr(i + 1).split(';');
            r.action = params.shift();
            for(p in params) {
                final j = p.indexOf('=');
                if(j == -1)
                    r.params.set(p.urlDecode(), '');
                else
                    r.params.set(p.substr(0, j).urlDecode(), p.substr(j + 1).urlDecode());
            }
        }
        return r;
    }
}
