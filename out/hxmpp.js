$estr = function() { return js.Boot.__string_rec(this,''); }
if(typeof jabber=='undefined') jabber = {}
if(!jabber.stream) jabber.stream = {}
jabber.stream.PacketCollector = function(filters,handler,permanent,timeout,block) { if( filters === $_ ) return; {
	if(block == null) block = false;
	if(permanent == null) permanent = false;
	this.handlers = new Array();
	this.filters = new jabber.stream.FilterList();
	{ var $it0 = filters.iterator();
	while( $it0.hasNext() ) { var f = $it0.next();
	this.filters.push(f);
	}}
	if(handler != null) this.handlers.push(handler);
	this.permanent = permanent;
	this.block = block;
	this.setTimeout(timeout);
}}
jabber.stream.PacketCollector.__name__ = ["jabber","stream","PacketCollector"];
jabber.stream.PacketCollector.prototype.accept = function(p) {
	{ var $it1 = $closure(this.filters,"iterator")();
	while( $it1.hasNext() ) { var f = $it1.next();
	{
		if(!f.accept(p)) return false;
	}
	}}
	if(this.timeout != null) this.timeout.stop();
	return true;
}
jabber.stream.PacketCollector.prototype.block = null;
jabber.stream.PacketCollector.prototype.deliver = function(p) {
	var _g = 0, _g1 = this.handlers;
	while(_g < _g1.length) {
		var h = _g1[_g];
		++_g;
		h(p);
	}
}
jabber.stream.PacketCollector.prototype.filters = null;
jabber.stream.PacketCollector.prototype.handlers = null;
jabber.stream.PacketCollector.prototype.permanent = null;
jabber.stream.PacketCollector.prototype.setTimeout = function(t) {
	if(this.timeout != null) this.timeout.stop();
	this.timeout = null;
	if(t == null || this.permanent) return null;
	this.timeout = t;
	this.timeout.collector = this;
	return this.timeout;
}
jabber.stream.PacketCollector.prototype.timeout = null;
jabber.stream.PacketCollector.prototype.__class__ = jabber.stream.PacketCollector;
if(typeof xmpp=='undefined') xmpp = {}
xmpp.Packet = function(to,from,id,lang) { if( to === $_ ) return; {
	this.to = to;
	this.from = from;
	this.id = id;
	this.lang = lang;
	this.errors = new Array();
	this.properties = new Array();
}}
xmpp.Packet.__name__ = ["xmpp","Packet"];
xmpp.Packet.parse = function(x) {
	return (function($this) {
		var $r;
		switch(x.getNodeName()) {
		case "iq":{
			$r = xmpp.IQ.parse(x);
		}break;
		case "message":{
			$r = xmpp.Message.parse(x);
		}break;
		case "presence":{
			$r = xmpp.Presence.parse(x);
		}break;
		default:{
			$r = new xmpp.PlainPacket(x);
		}break;
		}
		return $r;
	}(this));
}
xmpp.Packet.parseAttributes = function(p,x) {
	p.to = x.get("to");
	p.from = x.get("from");
	p.id = x.get("id");
	p.lang = x.get("xml:lang");
	return p;
}
xmpp.Packet.reflectPacketNodes = function(x,p) {
	{ var $it2 = x.elements();
	while( $it2.hasNext() ) { var e = $it2.next();
	{
		var v = null;
		try {
			v = e.firstChild().getNodeValue();
		}
		catch( $e3 ) {
			{
				var e1 = $e3;
				{
					continue;
				}
			}
		}
		if(v != null) {
			try {
				p[e.getNodeName()] = v;
			}
			catch( $e4 ) {
				{
					var e1 = $e4;
					null;
				}
			}
		}
	}
	}}
	return p;
}
xmpp.Packet.prototype._type = null;
xmpp.Packet.prototype.addAttributes = function(x) {
	if(this.to != null) x.set("to",this.to);
	if(this.from != null) x.set("from",this.from);
	if(this.id != null) x.set("id",this.id);
	if(this.lang != null) x.set("xml:lang",this.lang);
	{
		var _g = 0, _g1 = this.properties;
		while(_g < _g1.length) {
			var p = _g1[_g];
			++_g;
			x.addChild(p);
		}
	}
	{
		var _g = 0, _g1 = this.errors;
		while(_g < _g1.length) {
			var e = _g1[_g];
			++_g;
			x.addChild(e.toXml());
		}
	}
	return x;
}
xmpp.Packet.prototype.errors = null;
xmpp.Packet.prototype.from = null;
xmpp.Packet.prototype.id = null;
xmpp.Packet.prototype.lang = null;
xmpp.Packet.prototype.properties = null;
xmpp.Packet.prototype.to = null;
xmpp.Packet.prototype.toString = function() {
	return this.toXml().toString();
}
xmpp.Packet.prototype.toXml = function() {
	return (function($this) {
		var $r;
		throw "Abstract";
		return $r;
	}(this));
}
xmpp.Packet.prototype.__class__ = xmpp.Packet;
xmpp.Presence = function(show,status,priority,type) { if( show === $_ ) return; {
	xmpp.Packet.apply(this,[]);
	this._type = xmpp.PacketType.presence;
	this.show = show;
	this.setStatus(status);
	this.priority = priority;
	this.type = type;
}}
xmpp.Presence.__name__ = ["xmpp","Presence"];
xmpp.Presence.__super__ = xmpp.Packet;
for(var k in xmpp.Packet.prototype ) xmpp.Presence.prototype[k] = xmpp.Packet.prototype[k];
xmpp.Presence.parse = function(x) {
	var p = new xmpp.Presence(null,x.get("type"));
	xmpp.Packet.parseAttributes(p,x);
	if(x.exists("type")) p.type = Type.createEnum(xmpp.PresenceType,x.get("type"));
	{ var $it5 = x.elements();
	while( $it5.hasNext() ) { var c = $it5.next();
	{
		var fc = c.firstChild();
		switch(c.getNodeName()) {
		case "show":{
			if(fc != null) p.show = Type.createEnum(xmpp.PresenceShow,fc.getNodeValue());
		}break;
		case "status":{
			if(fc != null) p.setStatus(fc.getNodeValue());
		}break;
		case "priority":{
			if(fc != null) p.priority = Std.parseInt(fc.getNodeValue());
		}break;
		default:{
			p.properties.push(c);
		}break;
		}
	}
	}}
	return p;
}
xmpp.Presence.prototype.priority = null;
xmpp.Presence.prototype.setStatus = function(s) {
	return this.status = (((s == null || s == "")?null:((s.length > 1023)?s.substr(0,1023):s)));
}
xmpp.Presence.prototype.show = null;
xmpp.Presence.prototype.status = null;
xmpp.Presence.prototype.toXml = function() {
	var x = xmpp.Packet.prototype.addAttributes.apply(this,[Xml.createElement("presence")]);
	if(this.type != null) x.set("type",Type.enumConstructor(this.type));
	if(this.show != null) x.addChild(util.XmlUtil.createElement("show",Type.enumConstructor(this.show)));
	if(this.status != null) x.addChild(util.XmlUtil.createElement("status",this.status));
	if(this.priority != null) x.addChild(util.XmlUtil.createElement("priority",Std.string(this.priority)));
	return x;
}
xmpp.Presence.prototype.type = null;
xmpp.Presence.prototype.__class__ = xmpp.Presence;
if(!jabber.client) jabber.client = {}
jabber.client.Authentication = function(stream) { if( stream === $_ ) return; {
	this.stream = stream;
}}
jabber.client.Authentication.__name__ = ["jabber","client","Authentication"];
jabber.client.Authentication.prototype.authenticate = function(password,resource) {
	return (function($this) {
		var $r;
		throw "Abstract error";
		return $r;
	}(this));
}
jabber.client.Authentication.prototype.onFail = function(e) {
	null;
}
jabber.client.Authentication.prototype.onSuccess = function() {
	null;
}
jabber.client.Authentication.prototype.resource = null;
jabber.client.Authentication.prototype.stream = null;
jabber.client.Authentication.prototype.__class__ = jabber.client.Authentication;
jabber.client.SASLAuthentication = function(stream,mechanisms) { if( stream === $_ ) return; {
	var x = stream.server.features.get("mechanisms");
	if(x == null) throw "Server does't support SASL";
	if(mechanisms == null || Lambda.count(mechanisms) == 0) throw "No SASL mechanisms given";
	jabber.client.Authentication.apply(this,[stream]);
	this.mechanisms = xmpp.SASL.parseMechanisms(x);
	this.handshake = new net.sasl.Handshake();
	{ var $it6 = mechanisms.iterator();
	while( $it6.hasNext() ) { var m = $it6.next();
	this.handshake.mechanisms.push(m);
	}}
}}
jabber.client.SASLAuthentication.__name__ = ["jabber","client","SASLAuthentication"];
jabber.client.SASLAuthentication.__super__ = jabber.client.Authentication;
for(var k in jabber.client.Authentication.prototype ) jabber.client.SASLAuthentication.prototype[k] = jabber.client.Authentication.prototype[k];
jabber.client.SASLAuthentication.prototype.authenticate = function(password,resource) {
	this.resource = resource;
	if(this.stream.jid != null && resource != null) this.stream.jid.resource = resource;
	if(this.handshake.mechanism == null) {
		{
			var _g = 0, _g1 = this.mechanisms;
			while(_g < _g1.length) {
				var amechs = _g1[_g];
				++_g;
				{
					var _g2 = 0, _g3 = this.handshake.mechanisms;
					while(_g2 < _g3.length) {
						var m = _g3[_g2];
						++_g2;
						if(m.id != amechs) continue;
						this.handshake.mechanism = m;
						break;
					}
				}
				if(this.handshake.mechanism != null) break;
			}
		}
	}
	if(this.handshake.mechanism == null) {
		return false;
	}
	var f = new xmpp.filter.FilterGroup();
	f.add(new xmpp.filter.PacketNameFilter(new EReg("failure","")));
	f.add(new xmpp.filter.PacketNameFilter(new EReg("not-authorized","")));
	f.add(new xmpp.filter.PacketNameFilter(new EReg("aborted","")));
	f.add(new xmpp.filter.PacketNameFilter(new EReg("incorrect-encoding","")));
	f.add(new xmpp.filter.PacketNameFilter(new EReg("invalid-authzid","")));
	f.add(new xmpp.filter.PacketNameFilter(new EReg("invalid-mechanism","")));
	f.add(new xmpp.filter.PacketNameFilter(new EReg("mechanism-too-weak","")));
	f.add(new xmpp.filter.PacketNameFilter(new EReg("temporary-auth-failure","")));
	this.c_fail = new jabber.stream.PacketCollector([f],$closure(this,"handleSASLFailed"));
	this.stream.addCollector(this.c_fail);
	this.c_success = new jabber.stream.PacketCollector([new xmpp.filter.PacketNameFilter(new EReg("success",""))],$closure(this,"handleSASLSuccess"));
	this.stream.addCollector(this.c_success);
	this.c_challenge = new jabber.stream.PacketCollector([new xmpp.filter.PacketNameFilter(new EReg("challenge",""))],$closure(this,"handleSASLChallenge"),true);
	this.stream.addCollector(this.c_challenge);
	var t = this.handshake.mechanism.createAuthenticationText(this.stream.jid.node,this.stream.jid.domain,password);
	if(t != null) t = util.Base64.encode(t);
	return this.stream.sendData(xmpp.SASL.createAuthXml(this.handshake.mechanism.id,t).toString()) != null;
}
jabber.client.SASLAuthentication.prototype.c_challenge = null;
jabber.client.SASLAuthentication.prototype.c_fail = null;
jabber.client.SASLAuthentication.prototype.c_success = null;
jabber.client.SASLAuthentication.prototype.handleBind = function(iq) {
	switch(iq.type) {
	case xmpp.IQType.result:{
		var b = xmpp.Bind.parse(iq.x.toXml());
		var jid = new jabber.JID(b.jid);
		this.stream.jid.node = jid.node;
		this.stream.jid.resource = jid.resource;
		if(this.stream.server.features.exists("session")) {
			var iq1 = new xmpp.IQ(xmpp.IQType.set);
			iq1.x = new xmpp.PlainPacket(Xml.parse("<session xmlns=\"urn:ietf:params:xml:ns:xmpp-session\"/>"));
			this.stream.sendIQ(iq1,$closure(this,"handleSession"));
		}
		else this.onSuccess();
	}break;
	case xmpp.IQType.error:{
		this.onFail(new jabber.XMPPError(this,iq));
	}break;
	}
}
jabber.client.SASLAuthentication.prototype.handleSASLChallenge = function(p) {
	var c = p.toXml().firstChild().getNodeValue();
	var r = util.Base64.encode(this.handshake.getChallengeResponse(c));
	this.stream.sendData(xmpp.SASL.createResponseXml(r).toString());
}
jabber.client.SASLAuthentication.prototype.handleSASLFailed = function(p) {
	this.removeSASLCollectors();
	this.onFail();
}
jabber.client.SASLAuthentication.prototype.handleSASLSuccess = function(p) {
	this.removeSASLCollectors();
	this.onStreamOpenHandler = $closure(this.stream,"onOpen");
	this.stream.onOpen = $closure(this,"handleStreamOpen");
	this.onNegotiated();
	this.stream.open();
}
jabber.client.SASLAuthentication.prototype.handleSession = function(iq) {
	var $e = (iq.type);
	switch( $e[1] ) {
	case 2:
	{
		this.onSuccess();
	}break;
	case 3:
	{
		this.onFail(new jabber.XMPPError(this,iq));
	}break;
	default:{
		null;
	}break;
	}
}
jabber.client.SASLAuthentication.prototype.handleStreamOpen = function() {
	this.stream.onOpen = this.onStreamOpenHandler;
	if(this.stream.server.features.exists("bind")) {
		var iq = new xmpp.IQ(xmpp.IQType.set);
		iq.x = new xmpp.Bind(((this.handshake.mechanism.id == "ANONYMOUS")?null:this.resource));
		this.stream.sendIQ(iq,$closure(this,"handleBind"));
	}
	else {
		this.onSuccess();
	}
}
jabber.client.SASLAuthentication.prototype.handshake = null;
jabber.client.SASLAuthentication.prototype.mechanisms = null;
jabber.client.SASLAuthentication.prototype.onNegotiated = function() {
	null;
}
jabber.client.SASLAuthentication.prototype.onStreamOpenHandler = null;
jabber.client.SASLAuthentication.prototype.removeSASLCollectors = function() {
	this.stream.removeCollector(this.c_challenge);
	this.c_challenge = null;
	this.stream.removeCollector(this.c_fail);
	this.c_fail = null;
	this.stream.removeCollector(this.c_success);
	this.c_success = null;
}
jabber.client.SASLAuthentication.prototype.__class__ = jabber.client.SASLAuthentication;
jabber.stream.Connection = function(host) { if( host === $_ ) return; {
	this.host = host;
	this.connected = false;
}}
jabber.stream.Connection.__name__ = ["jabber","stream","Connection"];
jabber.stream.Connection.prototype.__onConnect = null;
jabber.stream.Connection.prototype.__onData = null;
jabber.stream.Connection.prototype.__onDisconnect = null;
jabber.stream.Connection.prototype.__onError = null;
jabber.stream.Connection.prototype.connect = function() {
	throw "Abstract method";
}
jabber.stream.Connection.prototype.connected = null;
jabber.stream.Connection.prototype.disconnect = function() {
	throw "Abstract method";
}
jabber.stream.Connection.prototype.host = null;
jabber.stream.Connection.prototype.read = function(yes) {
	if(yes == null) yes = true;
	return (function($this) {
		var $r;
		throw "Abstract method";
		return $r;
	}(this));
}
jabber.stream.Connection.prototype.write = function(t) {
	return (function($this) {
		var $r;
		throw "Abstract method";
		return $r;
	}(this));
}
jabber.stream.Connection.prototype.__class__ = jabber.stream.Connection;
if(typeof util=='undefined') util = {}
util.XmlUtil = function() { }
util.XmlUtil.__name__ = ["util","XmlUtil"];
util.XmlUtil.createElement = function(name,data) {
	var x = Xml.createElement(name);
	if(data != null) x.addChild(Xml.createPCData(data));
	return x;
}
util.XmlUtil.removeXmlHeader = function(s) {
	return (s.substr(0,6) == "<?xml "?s.substr(s.indexOf("><") + 1,s.length):s);
}
util.XmlUtil.prototype.__class__ = util.XmlUtil;
jabber.client.VCard = function(stream) { if( stream === $_ ) return; {
	this.stream = stream;
}}
jabber.client.VCard.__name__ = ["jabber","client","VCard"];
jabber.client.VCard.prototype.handleLoad = function(iq) {
	var $e = (iq.type);
	switch( $e[1] ) {
	case 2:
	{
		this.onLoad(iq.from,(iq.x != null?xmpp.VCard.parse(iq.x.toXml()):null));
	}break;
	case 3:
	{
		this.onError(new jabber.XMPPError(this,iq));
	}break;
	default:{
		null;
	}break;
	}
}
jabber.client.VCard.prototype.handleUpdate = function(iq) {
	var $e = (iq.type);
	switch( $e[1] ) {
	case 2:
	{
		this.onUpdate(xmpp.VCard.parse(iq.x.toXml()));
	}break;
	case 3:
	{
		this.onError(new jabber.XMPPError(this,iq));
	}break;
	default:{
		null;
	}break;
	}
}
jabber.client.VCard.prototype.load = function(jid) {
	var iq = new xmpp.IQ(null,null,jid);
	iq.x = new xmpp.VCard();
	this.stream.sendIQ(iq,$closure(this,"handleLoad"));
}
jabber.client.VCard.prototype.onError = function(e) {
	null;
}
jabber.client.VCard.prototype.onLoad = function(node,data) {
	null;
}
jabber.client.VCard.prototype.onUpdate = function(data) {
	null;
}
jabber.client.VCard.prototype.stream = null;
jabber.client.VCard.prototype.update = function(vc) {
	var iq = new xmpp.IQ(xmpp.IQType.set,null,this.stream.jid.domain);
	iq.x = vc;
	this.stream.sendIQ(iq,$closure(this,"handleUpdate"));
}
jabber.client.VCard.prototype.__class__ = jabber.client.VCard;
if(typeof haxe=='undefined') haxe = {}
haxe.Http = function(url) { if( url === $_ ) return; {
	this.url = url;
	this.headers = new Hash();
	this.params = new Hash();
	this.async = true;
}}
haxe.Http.__name__ = ["haxe","Http"];
haxe.Http.requestUrl = function(url) {
	var h = new haxe.Http(url);
	h.async = false;
	var r = null;
	h.onData = function(d) {
		r = d;
	}
	h.onError = function(e) {
		throw e;
	}
	h.request(false);
	return r;
}
haxe.Http.prototype.async = null;
haxe.Http.prototype.headers = null;
haxe.Http.prototype.onData = function(data) {
	null;
}
haxe.Http.prototype.onError = function(msg) {
	null;
}
haxe.Http.prototype.onStatus = function(status) {
	null;
}
haxe.Http.prototype.params = null;
haxe.Http.prototype.postData = null;
haxe.Http.prototype.request = function(post) {
	var me = this;
	var r = new js.XMLHttpRequest();
	var onreadystatechange = function() {
		if(r.readyState != 4) return;
		var s = (function($this) {
			var $r;
			try {
				$r = r.status;
			}
			catch( $e7 ) {
				{
					var e = $e7;
					$r = null;
				}
			}
			return $r;
		}(this));
		if(s == undefined) s = null;
		if(s != null) me.onStatus(s);
		if(s != null && s >= 200 && s < 400) me.onData(r.responseText);
		else switch(s) {
		case null:{
			me.onError("Failed to connect or resolve host");
		}break;
		case 12029:{
			me.onError("Failed to connect to host");
		}break;
		case 12007:{
			me.onError("Unknown host");
		}break;
		default:{
			me.onError("Http Error #" + r.status);
		}break;
		}
	}
	if(this.async) r.onreadystatechange = onreadystatechange;
	var uri = this.postData;
	if(uri != null) post = true;
	else { var $it8 = this.params.keys();
	while( $it8.hasNext() ) { var p = $it8.next();
	{
		if(uri == null) uri = "";
		else uri += "&";
		uri += StringTools.urlDecode(p) + "=" + StringTools.urlEncode(this.params.get(p));
	}
	}}
	try {
		if(post) r.open("POST",this.url,this.async);
		else if(uri != null) {
			var question = this.url.split("?").length <= 1;
			r.open("GET",this.url + ((question?"?":"&")) + uri,this.async);
			uri = null;
		}
		else r.open("GET",this.url,this.async);
	}
	catch( $e9 ) {
		{
			var e = $e9;
			{
				this.onError(e.toString());
				return;
			}
		}
	}
	if(this.headers.get("Content-Type") == null && post && this.postData == null) r.setRequestHeader("Content-Type","application/x-www-form-urlencoded");
	{ var $it10 = this.headers.keys();
	while( $it10.hasNext() ) { var h = $it10.next();
	r.setRequestHeader(h,this.headers.get(h));
	}}
	r.send(uri);
	if(!this.async) onreadystatechange();
}
haxe.Http.prototype.setHeader = function(header,value) {
	this.headers.set(header,value);
}
haxe.Http.prototype.setParameter = function(param,value) {
	this.params.set(param,value);
}
haxe.Http.prototype.setPostData = function(data) {
	this.postData = data;
}
haxe.Http.prototype.url = null;
haxe.Http.prototype.__class__ = haxe.Http;
jabber.client.RosterSubscriptionMode = { __ename__ : ["jabber","client","RosterSubscriptionMode"], __constructs__ : ["acceptAll","rejectAll","manual"] }
jabber.client.RosterSubscriptionMode.acceptAll = function(subscribe) { var $x = ["acceptAll",0,subscribe]; $x.__enum__ = jabber.client.RosterSubscriptionMode; $x.toString = $estr; return $x; }
jabber.client.RosterSubscriptionMode.manual = ["manual",2];
jabber.client.RosterSubscriptionMode.manual.toString = $estr;
jabber.client.RosterSubscriptionMode.manual.__enum__ = jabber.client.RosterSubscriptionMode;
jabber.client.RosterSubscriptionMode.rejectAll = ["rejectAll",1];
jabber.client.RosterSubscriptionMode.rejectAll.toString = $estr;
jabber.client.RosterSubscriptionMode.rejectAll.__enum__ = jabber.client.RosterSubscriptionMode;
jabber.client.Roster = function(stream,subscriptionMode) { if( stream === $_ ) return; {
	this.stream = stream;
	this.subscriptionMode = (subscriptionMode != null?subscriptionMode:jabber.client.Roster.defaultSubscriptionMode);
	this.available = false;
	this.items = new Array();
	this.presence = new jabber.PresenceManager(stream);
	this.resources = new Hash();
	this.presenceMap = new Hash();
	stream.collect([new xmpp.filter.PacketTypeFilter(xmpp.PacketType.presence)],$closure(this,"handleRosterPresence"),true);
	stream.collect([new xmpp.filter.IQFilter("jabber:iq:roster")],$closure(this,"handleRosterIQ"),true);
}}
jabber.client.Roster.__name__ = ["jabber","client","Roster"];
jabber.client.Roster.prototype.addItem = function(jid) {
	if(!this.available || this.hasItem(jid)) return false;
	this.requestItemAdd(jid);
	return true;
}
jabber.client.Roster.prototype.available = null;
jabber.client.Roster.prototype.confirmSubscription = function(jid,allow) {
	if(allow == null) allow = true;
	var p = new xmpp.Presence(null,null,null,((allow)?xmpp.PresenceType.subscribed:xmpp.PresenceType.unsubscribed));
	p.to = jid;
	this.stream.sendData(p.toXml().toString());
}
jabber.client.Roster.prototype.getGroups = function() {
	var r = new Array();
	{
		var _g = 0, _g1 = this.items;
		while(_g < _g1.length) {
			var item = _g1[_g];
			++_g;
			{ var $it11 = item.groups.iterator();
			while( $it11.hasNext() ) { var g = $it11.next();
			{
				var has = false;
				{
					var _g2 = 0;
					while(_g2 < r.length) {
						var a = r[_g2];
						++_g2;
						if(a == g) {
							has = true;
							break;
						}
					}
				}
				if(!has) r.push(g);
			}
			}}
		}
	}
	return r;
}
jabber.client.Roster.prototype.getItem = function(jid) {
	{
		var _g = 0, _g1 = this.items;
		while(_g < _g1.length) {
			var i = _g1[_g];
			++_g;
			if(i.jid == jid) {
				return i;
			}
		}
	}
	return null;
}
jabber.client.Roster.prototype.getPresence = function(jid) {
	return this.presenceMap.get(jid);
}
jabber.client.Roster.prototype.groups = null;
jabber.client.Roster.prototype.handleRosterIQ = function(iq) {
	var $e = (iq.type);
	switch( $e[1] ) {
	case 2:
	{
		var added = new Array();
		var removed = new Array();
		var loaded = xmpp.Roster.parse(iq.x.toXml());
		{ var $it12 = loaded.iterator();
		while( $it12.hasNext() ) { var i = $it12.next();
		{
			var item = this.getItem(i.jid);
			if(i.subscription == xmpp.roster.Subscription.remove) {
				if(item != null) {
					this.items.remove(item);
					removed.push(item);
				}
			}
			else {
				if(item == null) {
					item = i;
					this.items.push(item);
					added.push(item);
				}
				else {
					null;
				}
			}
		}
		}}
		if(!this.available) {
			this.available = true;
			this.onLoad();
		}
		if(added.length > 0) this.onAdd(added);
		if(removed.length > 0) this.onRemove(removed);
	}break;
	case 1:
	{
		var loaded = xmpp.Roster.parse(iq.x.toXml());
		{ var $it13 = loaded.iterator();
		while( $it13.hasNext() ) { var i = $it13.next();
		{
			var item = this.getItem(i.jid);
			if(item != null) {
				item = i;
				this.onUpdate([item]);
			}
			else {
				this.items.push(i);
				this.onAdd([i]);
			}
		}
		}}
	}break;
	case 3:
	{
		null;
	}break;
	default:{
		null;
	}break;
	}
}
jabber.client.Roster.prototype.handleRosterPresence = function(p) {
	var from = jabber.JIDUtil.parseBare(p.from);
	var resource = jabber.JIDUtil.parseResource(p.from);
	if(from == this.stream.jid.getBare()) {
		if(resource == null) return;
		this.resources.set(resource,p);
		this.onResourcePresence(resource,p);
		return;
	}
	var i = this.getItem(from);
	if(p.type != null) {
		var $e = (p.type);
		switch( $e[1] ) {
		case 2:
		{
			var $e = (this.subscriptionMode);
			switch( $e[1] ) {
			case 0:
			var s = $e[2];
			{
				this.confirmSubscription(p.from,true);
				if(s) this.subscribe(p.from);
			}break;
			case 1:
			{
				var r = new xmpp.Presence(null,null,null,xmpp.PresenceType.unsubscribed);
				r.to = p.from;
				this.stream.sendPacket(r);
			}break;
			case 2:
			{
				this.onSubscription(new xmpp.roster.Item(p.from));
			}break;
			}
			return;
		}break;
		case 3:
		{
			this.onSubscribed(i);
		}break;
		case 5:
		{
			this.onUnsubscribed(i);
			return;
		}break;
		default:{
			null;
		}break;
		}
	}
	if(i != null) {
		this.presenceMap.set(from,p);
		this.onPresence(i,p);
	}
}
jabber.client.Roster.prototype.hasItem = function(jid) {
	return (this.getItem(jabber.JIDUtil.parseBare(jid)) != null);
}
jabber.client.Roster.prototype.items = null;
jabber.client.Roster.prototype.load = function() {
	var iq = new xmpp.IQ();
	iq.x = new xmpp.Roster();
	this.stream.sendIQ(iq);
}
jabber.client.Roster.prototype.onAdd = function(items) {
	null;
}
jabber.client.Roster.prototype.onError = function(e) {
	null;
}
jabber.client.Roster.prototype.onLoad = function() {
	null;
}
jabber.client.Roster.prototype.onPresence = function(item,p) {
	null;
}
jabber.client.Roster.prototype.onRemove = function(items) {
	null;
}
jabber.client.Roster.prototype.onResourcePresence = function(resource,p) {
	null;
}
jabber.client.Roster.prototype.onSubscribed = function(item) {
	null;
}
jabber.client.Roster.prototype.onSubscription = function(item) {
	null;
}
jabber.client.Roster.prototype.onUnsubscribed = function(item) {
	null;
}
jabber.client.Roster.prototype.onUpdate = function(items) {
	null;
}
jabber.client.Roster.prototype.presence = null;
jabber.client.Roster.prototype.presenceMap = null;
jabber.client.Roster.prototype.removeItem = function(jid) {
	if(!this.available) return false;
	var i = this.getItem(jid);
	if(i == null) return false;
	var iq = new xmpp.IQ(xmpp.IQType.set);
	iq.x = new xmpp.Roster([new xmpp.roster.Item(jid,xmpp.roster.Subscription.remove)]);
	var _this = this;
	this.stream.sendIQ(iq,function(r) {
		var $e = (r.type);
		switch( $e[1] ) {
		case 2:
		{
			_this.items.remove(i);
			_this.onRemove([i]);
		}break;
		case 3:
		{
			_this.onError(new jabber.XMPPError(_this,r));
		}break;
		default:{
			null;
		}break;
		}
	});
	return true;
}
jabber.client.Roster.prototype.requestItemAdd = function(j) {
	var iq = new xmpp.IQ(xmpp.IQType.set);
	iq.x = new xmpp.Roster([new xmpp.roster.Item(j)]);
	var me = this;
	this.stream.sendIQ(iq,function(r) {
		var $e = (r.type);
		switch( $e[1] ) {
		case 2:
		{
			var item = new xmpp.roster.Item(j);
			me.items.push(item);
			me.onAdd([item]);
		}break;
		case 3:
		{
			null;
		}break;
		default:{
			null;
		}break;
		}
	});
}
jabber.client.Roster.prototype.resources = null;
jabber.client.Roster.prototype.stream = null;
jabber.client.Roster.prototype.subscribe = function(jid) {
	if(!this.available) return false;
	var i = this.getItem(jid);
	if(i == null) {
		var iq = new xmpp.IQ(xmpp.IQType.set);
		iq.x = new xmpp.Roster([new xmpp.roster.Item(jid)]);
		var me = this;
		this.stream.sendIQ(iq,function(r) {
			null;
		});
	}
	else if(i.subscription == xmpp.roster.Subscription.both) {
		return false;
	}
	var p = new xmpp.Presence(null,null,null,xmpp.PresenceType.subscribe);
	p.to = jid;
	return this.stream.sendPacket(p) != null;
}
jabber.client.Roster.prototype.subscriptionMode = null;
jabber.client.Roster.prototype.unsubscribe = function(jid) {
	if(!this.available) return false;
	var i = this.getItem(jid);
	if(i == null) return false;
	if(i.askType != xmpp.roster.AskType.unsubscribe) {
		var p = new xmpp.Presence(null,null,null,xmpp.PresenceType.unsubscribe);
		p.to = jid;
		this.stream.sendPacket(p);
	}
	return true;
}
jabber.client.Roster.prototype.updateItem = function(item) {
	if(!this.available || !this.hasItem(item.jid)) return false;
	var iq = new xmpp.IQ(xmpp.IQType.set);
	iq.x = new xmpp.Roster([item]);
	var _this = this;
	this.stream.sendIQ(iq,function(r) {
		var $e = (r.type);
		switch( $e[1] ) {
		case 2:
		{
			_this.onUpdate([item]);
		}break;
		case 3:
		{
			_this.onError(new jabber.XMPPError(_this,r));
		}break;
		default:{
			null;
		}break;
		}
	});
	return true;
}
jabber.client.Roster.prototype.__class__ = jabber.client.Roster;
List = function(p) { if( p === $_ ) return; {
	this.length = 0;
}}
List.__name__ = ["List"];
List.prototype.add = function(item) {
	var x = [item];
	if(this.h == null) this.h = x;
	else this.q[1] = x;
	this.q = x;
	this.length++;
}
List.prototype.clear = function() {
	this.h = null;
	this.q = null;
	this.length = 0;
}
List.prototype.filter = function(f) {
	var l2 = new List();
	var l = this.h;
	while(l != null) {
		var v = l[0];
		l = l[1];
		if(f(v)) l2.add(v);
	}
	return l2;
}
List.prototype.first = function() {
	return (this.h == null?null:this.h[0]);
}
List.prototype.h = null;
List.prototype.isEmpty = function() {
	return (this.h == null);
}
List.prototype.iterator = function() {
	return { h : this.h, hasNext : function() {
		return (this.h != null);
	}, next : function() {
		if(this.h == null) return null;
		var x = this.h[0];
		this.h = this.h[1];
		return x;
	}}
}
List.prototype.join = function(sep) {
	var s = new StringBuf();
	var first = true;
	var l = this.h;
	while(l != null) {
		if(first) first = false;
		else s.b[s.b.length] = sep;
		s.b[s.b.length] = l[0];
		l = l[1];
	}
	return s.b.join("");
}
List.prototype.last = function() {
	return (this.q == null?null:this.q[0]);
}
List.prototype.length = null;
List.prototype.map = function(f) {
	var b = new List();
	var l = this.h;
	while(l != null) {
		var v = l[0];
		l = l[1];
		b.add(f(v));
	}
	return b;
}
List.prototype.pop = function() {
	if(this.h == null) return null;
	var x = this.h[0];
	this.h = this.h[1];
	if(this.h == null) this.q = null;
	this.length--;
	return x;
}
List.prototype.push = function(item) {
	var x = [item,this.h];
	this.h = x;
	if(this.q == null) this.q = x;
	this.length++;
}
List.prototype.q = null;
List.prototype.remove = function(v) {
	var prev = null;
	var l = this.h;
	while(l != null) {
		if(l[0] == v) {
			if(prev == null) this.h = l[1];
			else prev[1] = l[1];
			if(this.q == l) this.q = prev;
			this.length--;
			return true;
		}
		prev = l;
		l = l[1];
	}
	return false;
}
List.prototype.toString = function() {
	var s = new StringBuf();
	var first = true;
	var l = this.h;
	s.b[s.b.length] = "{";
	while(l != null) {
		if(first) first = false;
		else s.b[s.b.length] = ", ";
		s.b[s.b.length] = Std.string(l[0]);
		l = l[1];
	}
	s.b[s.b.length] = "}";
	return s.b.join("");
}
List.prototype.__class__ = List;
jabber.PresenceManager = function(stream,target) { if( stream === $_ ) return; {
	this.stream = stream;
	this.target = target;
}}
jabber.PresenceManager.__name__ = ["jabber","PresenceManager"];
jabber.PresenceManager.prototype.change = function(show,status,priority,type) {
	return this.set(new xmpp.Presence(show,status,priority,type));
}
jabber.PresenceManager.prototype.last = null;
jabber.PresenceManager.prototype.set = function(p) {
	this.last = (p == null?new xmpp.Presence():p);
	if(this.target != null && this.last.to == null) this.last.to = this.target;
	return this.stream.sendPacket(this.last);
}
jabber.PresenceManager.prototype.stream = null;
jabber.PresenceManager.prototype.target = null;
jabber.PresenceManager.prototype.__class__ = jabber.PresenceManager;
if(!xmpp.filter) xmpp.filter = {}
xmpp.filter.PacketNameFilter = function(reg) { if( reg === $_ ) return; {
	this.reg = reg;
}}
xmpp.filter.PacketNameFilter.__name__ = ["xmpp","filter","PacketNameFilter"];
xmpp.filter.PacketNameFilter.prototype.accept = function(p) {
	return this.reg.match(p.toXml().getNodeName());
}
xmpp.filter.PacketNameFilter.prototype.reg = null;
xmpp.filter.PacketNameFilter.prototype.__class__ = xmpp.filter.PacketNameFilter;
EReg = function(r,opt) { if( r === $_ ) return; {
	opt = opt.split("u").join("");
	this.r = new RegExp(r,opt);
}}
EReg.__name__ = ["EReg"];
EReg.prototype.customReplace = function(s,f) {
	var buf = new StringBuf();
	while(true) {
		if(!this.match(s)) break;
		buf.b[buf.b.length] = this.matchedLeft();
		buf.b[buf.b.length] = f(this);
		s = this.matchedRight();
	}
	buf.b[buf.b.length] = s;
	return buf.b.join("");
}
EReg.prototype.match = function(s) {
	this.r.m = this.r.exec(s);
	this.r.s = s;
	this.r.l = RegExp.leftContext;
	this.r.r = RegExp.rightContext;
	return (this.r.m != null);
}
EReg.prototype.matched = function(n) {
	return (this.r.m != null && n >= 0 && n < this.r.m.length?this.r.m[n]:(function($this) {
		var $r;
		throw "EReg::matched";
		return $r;
	}(this)));
}
EReg.prototype.matchedLeft = function() {
	if(this.r.m == null) throw "No string matched";
	if(this.r.l == null) return this.r.s.substr(0,this.r.m.index);
	return this.r.l;
}
EReg.prototype.matchedPos = function() {
	if(this.r.m == null) throw "No string matched";
	return { pos : this.r.m.index, len : this.r.m[0].length}
}
EReg.prototype.matchedRight = function() {
	if(this.r.m == null) throw "No string matched";
	if(this.r.r == null) {
		var sz = this.r.m.index + this.r.m[0].length;
		return this.r.s.substr(sz,this.r.s.length - sz);
	}
	return this.r.r;
}
EReg.prototype.r = null;
EReg.prototype.replace = function(s,by) {
	return s.replace(this.r,by);
}
EReg.prototype.split = function(s) {
	var d = "#__delim__#";
	return s.replace(this.r,d).split(d);
}
EReg.prototype.__class__ = EReg;
jabber.JIDUtil = function() { }
jabber.JIDUtil.__name__ = ["jabber","JIDUtil"];
jabber.JIDUtil.isValid = function(t) {
	if(!jabber.JIDUtil.EREG.match(t)) return false;
	{
		var _g = 0, _g1 = jabber.JIDUtil.getParts(t);
		while(_g < _g1.length) {
			var p = _g1[_g];
			++_g;
			if(p.length > 1023) return false;
		}
	}
	return true;
}
jabber.JIDUtil.parseNode = function(t) {
	return t.substr(0,t.indexOf("@"));
}
jabber.JIDUtil.parseDomain = function(t) {
	var i1 = t.indexOf("@") + 1;
	var i2 = t.indexOf("/");
	return ((i2 == -1)?t.substr(i1):t.substr(i1,i2 - i1));
}
jabber.JIDUtil.parseResource = function(t) {
	var i = t.indexOf("/");
	return ((i == -1)?null:t.substr(i + 1));
}
jabber.JIDUtil.parseBare = function(t) {
	var i = t.indexOf("/");
	return ((i == -1)?t:t.substr(0,i));
}
jabber.JIDUtil.hasResource = function(t) {
	return t.indexOf("/") != -1;
}
jabber.JIDUtil.getParts = function(jid) {
	var p = [jid.substr(0,jid.indexOf("@")),jabber.JIDUtil.parseDomain(jid)];
	if(jid.indexOf("/") != -1) p.push(jabber.JIDUtil.parseResource(jid));
	return p;
}
jabber.JIDUtil.splitBare = function(jid) {
	var i = jid.indexOf("/");
	return ((i == -1)?[jid]:[jid.substr(0,i),jid.substr(i + 1)]);
}
jabber.JIDUtil.escapeNode = function(n) {
	var b = new StringBuf();
	{
		var _g1 = 0, _g = n.length;
		while(_g1 < _g) {
			var i = _g1++;
			var c = n.charAt(i);
			switch(c) {
			case "\"":{
				b.b[b.b.length] = "\\22";
			}break;
			case "&":{
				b.b[b.b.length] = "\\26";
			}break;
			case "\\":{
				b.b[b.b.length] = "\\27";
			}break;
			case "/":{
				b.b[b.b.length] = "\\2f";
			}break;
			case ":":{
				b.b[b.b.length] = "\\3a";
			}break;
			case "<":{
				b.b[b.b.length] = "\\3c";
			}break;
			case ">":{
				b.b[b.b.length] = "\\3e";
			}break;
			case "@":{
				b.b[b.b.length] = "\\40";
			}break;
			case "\\\\":{
				b.b[b.b.length] = "\\5c";
			}break;
			default:{
				if(c == " ") b.b[b.b.length] = "\\20";
				else b.b[b.b.length] = c;
			}break;
			}
		}
	}
	return b.b.join("");
}
jabber.JIDUtil.unescapeNode = function(n) {
	var l = n.length;
	var b = new StringBuf();
	var i = 0;
	while(i < l) {
		var c = n.charAt(i);
		if(c == "\\" && i + 2 < l) {
			var c2 = n.charAt(i + 1);
			var c3 = n.charAt(i + 2);
			if(c2 == "2") {
				switch(c3) {
				case "0":{
					b.b[b.b.length] = " ";
					i += 3;
				}break;
				case "2":{
					b.b[b.b.length] = "\"";
					i += 3;
				}break;
				case "6":{
					b.b[b.b.length] = "&";
					i += 3;
				}break;
				case "7":{
					b.b[b.b.length] = "\\";
					i += 3;
				}break;
				case "f":{
					b.b[b.b.length] = "/";
					i += 3;
				}break;
				}
			}
			else if(c2 == "3") {
				switch(c3) {
				case "a":{
					b.b[b.b.length] = ":";
					i += 3;
				}break;
				case "c":{
					b.b[b.b.length] = "<";
					i += 3;
				}break;
				case "e":{
					b.b[b.b.length] = ">";
					i += 3;
				}break;
				}
			}
			else if(c2 == "4") {
				if(c3 == "0") {
					b.b[b.b.length] = "@";
					i += 3;
				}
			}
			else if(c2 == "5") {
				if(c3 == "c") {
					b.b[b.b.length] = "\\\\";
					i += 4;
				}
			}
		}
		else {
			b.b[b.b.length] = c;
			i++;
		}
	}
	return b.b.join("");
}
jabber.JIDUtil.prototype.__class__ = jabber.JIDUtil;
xmpp.Bind = function(resource,jid) { if( resource === $_ ) return; {
	this.resource = resource;
	this.jid = jid;
}}
xmpp.Bind.__name__ = ["xmpp","Bind"];
xmpp.Bind.parse = function(x) {
	var b = new xmpp.Bind();
	{ var $it14 = x.elements();
	while( $it14.hasNext() ) { var e = $it14.next();
	{
		switch(e.getNodeName()) {
		case "resource":{
			b.resource = e.firstChild().getNodeValue();
		}break;
		case "jid":{
			b.jid = e.firstChild().getNodeValue();
		}break;
		}
	}
	}}
	return b;
}
xmpp.Bind.prototype.jid = null;
xmpp.Bind.prototype.resource = null;
xmpp.Bind.prototype.toString = function() {
	return this.toXml().toString();
}
xmpp.Bind.prototype.toXml = function() {
	var x = Xml.createElement("bind");
	x.set("xmlns","urn:ietf:params:xml:ns:xmpp-bind");
	if(this.resource != null) x.addChild(util.XmlUtil.createElement("resource",this.resource));
	if(this.jid != null) x.addChild(util.XmlUtil.createElement("jid",this.jid));
	return x;
}
xmpp.Bind.prototype.__class__ = xmpp.Bind;
xmpp.VCard = function(p) { if( p === $_ ) return; {
	this.addresses = new Array();
	this.tels = new Array();
}}
xmpp.VCard.__name__ = ["xmpp","VCard"];
xmpp.VCard.parse = function(x) {
	var vc = new xmpp.VCard();
	{ var $it15 = x.elements();
	while( $it15.hasNext() ) { var node = $it15.next();
	{
		switch(node.getNodeName()) {
		case "FN":{
			vc.fn = node.firstChild().getNodeValue();
		}break;
		case "N":{
			vc.n = { family : null, given : null, middle : null, prefix : null, suffix : null}
			{ var $it16 = node.elements();
			while( $it16.hasNext() ) { var n = $it16.next();
			{
				var value = null;
				try {
					var fc = n.firstChild();
					if(vc != null) value = n.firstChild().getNodeValue();
				}
				catch( $e17 ) {
					{
						var e = $e17;
						null;
					}
				}
				if(value != null) {
					switch(n.getNodeName()) {
					case "FAMILY":{
						vc.n.family = value;
					}break;
					case "GIVEN":{
						vc.n.given = value;
					}break;
					case "MIDDLE":{
						vc.n.middle = value;
					}break;
					case "PREFIX":{
						vc.n.prefix = value;
					}break;
					case "SUFFIX":{
						vc.n.suffix = value;
					}break;
					}
				}
			}
			}}
		}break;
		case "PHOTO":{
			vc.photo = xmpp.VCard.parsePhoto(node);
		}break;
		case "BDAY":{
			vc.birthday = node.firstChild().getNodeValue();
		}break;
		case "ADR":{
			var adr = { }
			{ var $it18 = node.elements();
			while( $it18.hasNext() ) { var n = $it18.next();
			{
				var value = null;
				try {
					value = n.firstChild().getNodeValue();
				}
				catch( $e19 ) {
					{
						var e = $e19;
						null;
					}
				}
				if(value != null) {
					switch(n.getNodeName()) {
					case "HOME":{
						adr.home = value;
					}break;
					case "WORK":{
						adr.work = value;
					}break;
					case "POSTAL":{
						adr.postal = value;
					}break;
					case "PARCEL":{
						adr.parcel = value;
					}break;
					case "PREF":{
						adr.pref = value;
					}break;
					case "POBOX":{
						adr.pobox = value;
					}break;
					case "EXTADD":{
						adr.extadd = value;
					}break;
					case "STREET":{
						adr.street = value;
					}break;
					case "LOCALITY":{
						adr.locality = value;
					}break;
					case "REGION":{
						adr.region = value;
					}break;
					case "PCODE":{
						adr.pcode = value;
					}break;
					case "CTRY":{
						adr.ctry = value;
					}break;
					}
				}
			}
			}}
			vc.addresses.push(adr);
		}break;
		case "LABEL":{
			null;
		}break;
		case "LINE":{
			vc.line = node.firstChild().getNodeValue();
		}break;
		case "TEL":{
			var tel = { }
			{ var $it20 = node.elements();
			while( $it20.hasNext() ) { var n = $it20.next();
			{
				var value = null;
				try {
					value = n.firstChild().getNodeValue();
				}
				catch( $e21 ) {
					{
						var e = $e21;
						null;
					}
				}
				if(value != null) {
					switch(n.getNodeName()) {
					case "NUMBER":{
						tel.number = value;
					}break;
					case "HOME":{
						tel.home = value;
					}break;
					case "WORK":{
						tel.work = value;
					}break;
					case "VOICE":{
						tel.voice = value;
					}break;
					case "FAX":{
						tel.fax = value;
					}break;
					case "PAGER":{
						tel.pager = value;
					}break;
					case "MSG":{
						tel.msg = value;
					}break;
					case "CELL":{
						tel.cell = value;
					}break;
					case "VIDEO":{
						tel.video = value;
					}break;
					case "BBS":{
						tel.bbs = value;
					}break;
					case "MODEM":{
						tel.modem = value;
					}break;
					case "ISDN":{
						tel.isdn = value;
					}break;
					case "PCS":{
						tel.pcs = value;
					}break;
					case "PREF":{
						tel.pref = value;
					}break;
					}
				}
			}
			}}
			vc.tels.push(tel);
		}break;
		case "EMAIL":{
			vc.email = { }
			{ var $it22 = node.elements();
			while( $it22.hasNext() ) { var n = $it22.next();
			{
				var value = null;
				try {
					value = n.firstChild().getNodeValue();
				}
				catch( $e23 ) {
					{
						var e = $e23;
						null;
					}
				}
				if(value != null) {
					switch(n.getNodeName()) {
					case "HOME":{
						vc.email.home = value;
					}break;
					case "WORK":{
						vc.email.work = value;
					}break;
					case "INTERNET":{
						vc.email.internet = value;
					}break;
					case "PREF":{
						vc.email.pref = value;
					}break;
					case "X400":{
						vc.email.x400 = value;
					}break;
					case "USERID":{
						vc.email.userid = value;
					}break;
					}
				}
			}
			}}
		}break;
		case "JABBERID":{
			vc.jid = node.firstChild().getNodeValue();
		}break;
		case "MAILER":{
			vc.mailer = node.firstChild().getNodeValue();
		}break;
		case "TZ":{
			vc.tz = node.firstChild().getNodeValue();
		}break;
		case "GEO":{
			vc.geo = { }
			{ var $it24 = node.elements();
			while( $it24.hasNext() ) { var n = $it24.next();
			{
				var value = null;
				try {
					value = n.firstChild().getNodeValue();
				}
				catch( $e25 ) {
					{
						var e = $e25;
						null;
					}
				}
				if(value == null) throw "Invalid vcard tz";
				switch(n.getNodeName()) {
				case "LAT":{
					vc.geo.lat = Std.parseInt(value);
				}break;
				case "LON":{
					vc.geo.lon = Std.parseInt(value);
				}break;
				}
			}
			}}
		}break;
		case "TITLE":{
			vc.title = node.firstChild().getNodeValue();
		}break;
		case "ROLE":{
			vc.role = node.firstChild().getNodeValue();
		}break;
		case "LOGO":{
			vc.logo = xmpp.VCard.parsePhoto(node);
		}break;
		case "AGENT":{
			null;
		}break;
		case "ORG":{
			vc.org = { }
			{ var $it26 = node.elements();
			while( $it26.hasNext() ) { var n = $it26.next();
			{
				var value = null;
				try {
					value = n.firstChild().getNodeValue();
				}
				catch( $e27 ) {
					{
						var e = $e27;
						null;
					}
				}
				if(value != null) {
					switch(n.getNodeName()) {
					case "ORGNAME":{
						vc.org.orgname = value;
					}break;
					case "ORGUNIT":{
						vc.org.orgunit = value;
					}break;
					}
				}
			}
			}}
		}break;
		case "NOTE":{
			vc.note = node.firstChild().getNodeValue();
		}break;
		case "PRODID":{
			vc.prodid = node.firstChild().getNodeValue();
		}break;
		case "URL":{
			vc.url = node.firstChild().getNodeValue();
		}break;
		case "DESC":{
			vc.desc = node.firstChild().getNodeValue();
		}break;
		}
	}
	}}
	return vc;
}
xmpp.VCard.parsePhoto = function(x) {
	var photo = { }
	{ var $it28 = x.elements();
	while( $it28.hasNext() ) { var n = $it28.next();
	{
		var value = null;
		try {
			value = n.firstChild().getNodeValue();
		}
		catch( $e29 ) {
			{
				var e = $e29;
				null;
			}
		}
		if(value != null) {
			switch(n.getNodeName()) {
			case "TYPE":{
				photo.type = value;
			}break;
			case "BINVAL":{
				photo.binval = value;
			}break;
			}
		}
	}
	}}
	return photo;
}
xmpp.VCard.prototype.addresses = null;
xmpp.VCard.prototype.birthday = null;
xmpp.VCard.prototype.desc = null;
xmpp.VCard.prototype.email = null;
xmpp.VCard.prototype.fn = null;
xmpp.VCard.prototype.geo = null;
xmpp.VCard.prototype.jid = null;
xmpp.VCard.prototype.label = null;
xmpp.VCard.prototype.line = null;
xmpp.VCard.prototype.logo = null;
xmpp.VCard.prototype.mailer = null;
xmpp.VCard.prototype.n = null;
xmpp.VCard.prototype.nickname = null;
xmpp.VCard.prototype.note = null;
xmpp.VCard.prototype.org = null;
xmpp.VCard.prototype.photo = null;
xmpp.VCard.prototype.prodid = null;
xmpp.VCard.prototype.role = null;
xmpp.VCard.prototype.tels = null;
xmpp.VCard.prototype.title = null;
xmpp.VCard.prototype.toString = function() {
	return this.toXml().toString();
}
xmpp.VCard.prototype.toXml = function() {
	var x = Xml.createElement("vCard");
	x.set("xmlns","vcard-temp");
	if(this.fn != null) x.addChild(util.XmlUtil.createElement("FN",this.fn));
	if(this.n != null) {
		var _n = Xml.createElement("N");
		if(this.n.family != null) _n.addChild(util.XmlUtil.createElement("FAMILY",this.n.family));
		if(this.n.given != null) _n.addChild(util.XmlUtil.createElement("GIVEN",this.n.given));
		if(this.n.middle != null) _n.addChild(util.XmlUtil.createElement("MIDDLE",this.n.middle));
		if(this.n.prefix != null) _n.addChild(util.XmlUtil.createElement("PREFIX",this.n.prefix));
		if(this.n.suffix != null) _n.addChild(util.XmlUtil.createElement("SUFFIX",this.n.suffix));
		x.addChild(_n);
	}
	if(this.nickname != null) x.addChild(util.XmlUtil.createElement("NN",this.nickname));
	if(this.photo != null) {
		var p = Xml.createElement("PHOTO");
		p.addChild(util.XmlUtil.createElement("TYPE",this.photo.type));
		p.addChild(util.XmlUtil.createElement("BINVAL",this.photo.binval));
		x.addChild(p);
	}
	if(this.birthday != null) x.addChild(util.XmlUtil.createElement("BDAY",this.birthday));
	{
		var _g = 0, _g1 = this.addresses;
		while(_g < _g1.length) {
			var address = _g1[_g];
			++_g;
			var a = Xml.createElement("ADR");
			if(address.home != null) a.addChild(util.XmlUtil.createElement("HOME",address.home));
			if(address.work != null) a.addChild(util.XmlUtil.createElement("WORK",address.work));
			if(address.postal != null) a.addChild(util.XmlUtil.createElement("POSTAL",address.postal));
			if(address.parcel != null) a.addChild(util.XmlUtil.createElement("PARCEL",address.parcel));
			if(address.pref != null) a.addChild(util.XmlUtil.createElement("PREF",address.pref));
			if(address.pobox != null) a.addChild(util.XmlUtil.createElement("POBOX",address.pobox));
			if(address.extadd != null) a.addChild(util.XmlUtil.createElement("EXTADD",address.extadd));
			if(address.street != null) a.addChild(util.XmlUtil.createElement("STREET",address.street));
			if(address.locality != null) a.addChild(util.XmlUtil.createElement("LOCALITY",address.locality));
			if(address.region != null) a.addChild(util.XmlUtil.createElement("REGION",address.region));
			if(address.pcode != null) a.addChild(util.XmlUtil.createElement("PCODE",address.pcode));
			if(address.ctry != null) a.addChild(util.XmlUtil.createElement("CTRY",address.ctry));
			x.addChild(a);
		}
	}
	if(this.label != null) {
		var l = Xml.createElement("LABEL");
		if(this.label.home != null) l.addChild(util.XmlUtil.createElement("HOME",this.label.home));
		if(this.label.work != null) l.addChild(util.XmlUtil.createElement("HOME",this.label.work));
		if(this.label.postal != null) l.addChild(util.XmlUtil.createElement("HOME",this.label.postal));
		if(this.label.parcel != null) l.addChild(util.XmlUtil.createElement("HOME",this.label.parcel));
		if(this.label.pref != null) l.addChild(util.XmlUtil.createElement("HOME",this.label.pref));
		if(this.label.line != null) l.addChild(util.XmlUtil.createElement("HOME",this.label.line));
		x.addChild(l);
	}
	if(this.line != null) x.addChild(util.XmlUtil.createElement("LINE",this.line));
	{
		var _g = 0, _g1 = this.tels;
		while(_g < _g1.length) {
			var tel = _g1[_g];
			++_g;
			var t = Xml.createElement("TEL");
			if(tel.number != null) t.addChild(util.XmlUtil.createElement("NUMBER",tel.number));
			if(tel.home != null) t.addChild(util.XmlUtil.createElement("HOME",tel.home));
			if(tel.work != null) t.addChild(util.XmlUtil.createElement("WORK",tel.work));
			if(tel.voice != null) t.addChild(util.XmlUtil.createElement("VOICE",tel.voice));
			if(tel.fax != null) t.addChild(util.XmlUtil.createElement("FAX",tel.fax));
			if(tel.pager != null) t.addChild(util.XmlUtil.createElement("PAGER",tel.pager));
			if(tel.msg != null) t.addChild(util.XmlUtil.createElement("MSG",tel.msg));
			if(tel.cell != null) t.addChild(util.XmlUtil.createElement("CELL",tel.cell));
			if(tel.video != null) t.addChild(util.XmlUtil.createElement("VIDEO",tel.video));
			if(tel.bbs != null) t.addChild(util.XmlUtil.createElement("BBS",tel.bbs));
			if(tel.modem != null) t.addChild(util.XmlUtil.createElement("MODEM",tel.modem));
			if(tel.isdn != null) t.addChild(util.XmlUtil.createElement("ISDN",tel.isdn));
			if(tel.pcs != null) t.addChild(util.XmlUtil.createElement("PCS",tel.pcs));
			if(tel.pref != null) t.addChild(util.XmlUtil.createElement("PREF",tel.pref));
			x.addChild(t);
		}
	}
	if(this.email != null) {
		var e = Xml.createElement("EMAIL");
		if(this.email.home != null) e.addChild(util.XmlUtil.createElement("HOME",this.email.home));
		if(this.email.work != null) e.addChild(util.XmlUtil.createElement("WORK",this.email.work));
		if(this.email.internet != null) e.addChild(util.XmlUtil.createElement("INTERNET",this.email.internet));
		if(this.email.pref != null) e.addChild(util.XmlUtil.createElement("PREF",this.email.pref));
		if(this.email.x400 != null) e.addChild(util.XmlUtil.createElement("X400",this.email.x400));
		if(this.email.userid != null) e.addChild(util.XmlUtil.createElement("USERID",this.email.userid));
		x.addChild(e);
	}
	if(this.jid != null) x.addChild(util.XmlUtil.createElement("JABBERID",this.jid));
	if(this.mailer != null) x.addChild(util.XmlUtil.createElement("MAILER",this.mailer));
	if(this.tz != null) x.addChild(util.XmlUtil.createElement("TZ",this.tz));
	if(this.geo != null) {
		var g = Xml.createElement("GEO");
		g.addChild(util.XmlUtil.createElement("LAT",Std.string(this.geo.lat)));
		g.addChild(util.XmlUtil.createElement("LON",Std.string(this.geo.lon)));
		x.addChild(g);
	}
	if(this.title != null) x.addChild(util.XmlUtil.createElement("TITLE",this.title));
	if(this.role != null) x.addChild(util.XmlUtil.createElement("ROLE",this.role));
	if(this.logo != null) {
		var l = Xml.createElement("LOGO");
		l.addChild(util.XmlUtil.createElement("TYPE",this.logo.type));
		l.addChild(util.XmlUtil.createElement("BINVAL",this.logo.binval));
		x.addChild(l);
	}
	if(this.org != null) {
		var o = Xml.createElement("ORG");
		if(this.org.orgname != null) o.addChild(util.XmlUtil.createElement("NAME",this.org.orgname));
		if(this.org.orgunit != null) o.addChild(util.XmlUtil.createElement("UNIT",this.org.orgunit));
		x.addChild(o);
	}
	if(this.note != null) x.addChild(util.XmlUtil.createElement("NOTE",this.note));
	if(this.prodid != null) x.addChild(util.XmlUtil.createElement("PRODID",this.prodid));
	if(this.url != null) x.addChild(util.XmlUtil.createElement("URL",this.url));
	if(this.desc != null) x.addChild(util.XmlUtil.createElement("DESC",this.desc));
	return x;
}
xmpp.VCard.prototype.tz = null;
xmpp.VCard.prototype.url = null;
xmpp.VCard.prototype.__class__ = xmpp.VCard;
xmpp.Error = function(type,code,name,text) { if( type === $_ ) return; {
	this.type = type;
	this.code = code;
	this.name = name;
	this.text = text;
	this.conditions = new Array();
}}
xmpp.Error.__name__ = ["xmpp","Error"];
xmpp.Error.fromPacket = function(p) {
	{ var $it30 = p.toXml().elementsNamed("error");
	while( $it30.hasNext() ) { var e = $it30.next();
	return xmpp.Error.parse(e);
	}}
	return null;
}
xmpp.Error.parse = function(x) {
	var e = new xmpp.Error(null,Std.parseInt(x.get("code")));
	var et = x.get("type");
	if(et != null) e.type = Type.createEnum(xmpp.ErrorType,x.get("type"));
	var _n = x.elements().next();
	if(_n != null) e.name = _n.getNodeName();
	return e;
}
xmpp.Error.prototype.code = null;
xmpp.Error.prototype.conditions = null;
xmpp.Error.prototype.name = null;
xmpp.Error.prototype.text = null;
xmpp.Error.prototype.toString = function() {
	return this.toXml().toString();
}
xmpp.Error.prototype.toXml = function() {
	var x = Xml.createElement("error");
	if(this.type != null) x.set("type",Type.enumConstructor(this.type));
	if(this.code != null) x.set("code",Std.string(this.code));
	if(this.name != null) {
		var n = Xml.createElement(this.name);
		n.set("xmlns",xmpp.Error.XMLNS);
		x.addChild(n);
	}
	if(this.conditions != null) {
		{
			var _g = 0, _g1 = this.conditions;
			while(_g < _g1.length) {
				var c = _g1[_g];
				++_g;
				x.addChild(util.XmlUtil.createElement(c.name,c.xmlns));
			}
		}
	}
	return x;
}
xmpp.Error.prototype.type = null;
xmpp.Error.prototype.__class__ = xmpp.Error;
xmpp.IQ = function(type,id,to,from) { if( type === $_ ) return; {
	xmpp.Packet.apply(this,[to,from,id]);
	this._type = xmpp.PacketType.iq;
	this.type = ((type != null)?type:xmpp.IQType.get);
}}
xmpp.IQ.__name__ = ["xmpp","IQ"];
xmpp.IQ.__super__ = xmpp.Packet;
for(var k in xmpp.Packet.prototype ) xmpp.IQ.prototype[k] = xmpp.Packet.prototype[k];
xmpp.IQ.parse = function(x) {
	var iq = new xmpp.IQ();
	iq.type = Type.createEnum(xmpp.IQType,x.get("type"));
	xmpp.Packet.parseAttributes(iq,x);
	{ var $it31 = x.elements();
	while( $it31.hasNext() ) { var c = $it31.next();
	{
		switch(c.getNodeName()) {
		case "error":{
			iq.errors.push(xmpp.Error.parse(c));
		}break;
		default:{
			iq.properties.push(c);
		}break;
		}
	}
	}}
	if(iq.properties.length > 0) iq.x = new xmpp.PlainPacket(iq.properties[0]);
	return iq;
}
xmpp.IQ.createQueryXml = function(ns) {
	var x = Xml.createElement("query");
	x.set("xmlns",ns);
	return x;
}
xmpp.IQ.createResult = function(iq) {
	return new xmpp.IQ(xmpp.IQType.result,iq.id,iq.from);
}
xmpp.IQ.createErrorResult = function(iq,errors) {
	var r = new xmpp.IQ(xmpp.IQType.error,iq.id,iq.from);
	if(errors != null) r.errors = errors;
	return r;
}
xmpp.IQ.prototype.toXml = function() {
	if(this.type == null) this.type = xmpp.IQType.get;
	var _x = xmpp.Packet.prototype.addAttributes.apply(this,[Xml.createElement("iq")]);
	_x.set("type",Type.enumConstructor(this.type));
	_x.set("id",this.id);
	if(this.x != null) _x.addChild(this.x.toXml());
	return _x;
}
xmpp.IQ.prototype.type = null;
xmpp.IQ.prototype.x = null;
xmpp.IQ.prototype.__class__ = xmpp.IQ;
xmpp.IQType = { __ename__ : ["xmpp","IQType"], __constructs__ : ["get","set","result","error"] }
xmpp.IQType.error = ["error",3];
xmpp.IQType.error.toString = $estr;
xmpp.IQType.error.__enum__ = xmpp.IQType;
xmpp.IQType.get = ["get",0];
xmpp.IQType.get.toString = $estr;
xmpp.IQType.get.__enum__ = xmpp.IQType;
xmpp.IQType.result = ["result",2];
xmpp.IQType.result.toString = $estr;
xmpp.IQType.result.__enum__ = xmpp.IQType;
xmpp.IQType.set = ["set",1];
xmpp.IQType.set.toString = $estr;
xmpp.IQType.set.__enum__ = xmpp.IQType;
haxe.BaseCode = function(base) { if( base === $_ ) return; {
	var len = base.length;
	var nbits = 1;
	while(len > 1 << nbits) nbits++;
	if(nbits > 8 || len != 1 << nbits) throw "BaseCode : base length must be a power of two.";
	this.base = base;
	this.nbits = nbits;
}}
haxe.BaseCode.__name__ = ["haxe","BaseCode"];
haxe.BaseCode.encode = function(s,base) {
	var b = new haxe.BaseCode(haxe.io.Bytes.ofString(base));
	return b.encodeString(s);
}
haxe.BaseCode.decode = function(s,base) {
	var b = new haxe.BaseCode(haxe.io.Bytes.ofString(base));
	return b.decodeString(s);
}
haxe.BaseCode.prototype.base = null;
haxe.BaseCode.prototype.decodeBytes = function(b) {
	var nbits = this.nbits;
	var base = this.base;
	if(this.tbl == null) this.initTable();
	var tbl = this.tbl;
	var size = (b.length * nbits) >> 3;
	var out = haxe.io.Bytes.alloc(size);
	var buf = 0;
	var curbits = 0;
	var pin = 0;
	var pout = 0;
	while(pout < size) {
		while(curbits < 8) {
			curbits += nbits;
			buf <<= nbits;
			var i = tbl[b.b[pin++]];
			if(i == -1) throw "BaseCode : invalid encoded char";
			buf |= i;
		}
		curbits -= 8;
		out.b[pout++] = (((buf >> curbits) & 255) & 255);
	}
	return out;
}
haxe.BaseCode.prototype.decodeString = function(s) {
	return this.decodeBytes(haxe.io.Bytes.ofString(s)).toString();
}
haxe.BaseCode.prototype.encodeBytes = function(b) {
	var nbits = this.nbits;
	var base = this.base;
	var size = Std["int"](b.length * 8 / nbits);
	var out = haxe.io.Bytes.alloc(size + ((((b.length * 8) % nbits == 0)?0:1)));
	var buf = 0;
	var curbits = 0;
	var mask = (1 << nbits) - 1;
	var pin = 0;
	var pout = 0;
	while(pout < size) {
		while(curbits < nbits) {
			curbits += 8;
			buf <<= 8;
			buf |= b.b[pin++];
		}
		curbits -= nbits;
		out.b[pout++] = (base.b[(buf >> curbits) & mask] & 255);
	}
	if(curbits > 0) out.b[pout++] = (base.b[(buf << (nbits - curbits)) & mask] & 255);
	return out;
}
haxe.BaseCode.prototype.encodeString = function(s) {
	return this.encodeBytes(haxe.io.Bytes.ofString(s)).toString();
}
haxe.BaseCode.prototype.initTable = function() {
	var tbl = new Array();
	{
		var _g = 0;
		while(_g < 256) {
			var i = _g++;
			tbl[i] = -1;
		}
	}
	{
		var _g1 = 0, _g = this.base.length;
		while(_g1 < _g) {
			var i = _g1++;
			tbl[this.base.b[i]] = i;
		}
	}
	this.tbl = tbl;
}
haxe.BaseCode.prototype.nbits = null;
haxe.BaseCode.prototype.tbl = null;
haxe.BaseCode.prototype.__class__ = haxe.BaseCode;
Reflect = function() { }
Reflect.__name__ = ["Reflect"];
Reflect.hasField = function(o,field) {
	if(o.hasOwnProperty != null) return o.hasOwnProperty(field);
	var arr = Reflect.fields(o);
	{ var $it32 = arr.iterator();
	while( $it32.hasNext() ) { var t = $it32.next();
	if(t == field) return true;
	}}
	return false;
}
Reflect.field = function(o,field) {
	var v = null;
	try {
		v = o[field];
	}
	catch( $e33 ) {
		{
			var e = $e33;
			null;
		}
	}
	return v;
}
Reflect.setField = function(o,field,value) {
	o[field] = value;
}
Reflect.callMethod = function(o,func,args) {
	return func.apply(o,args);
}
Reflect.fields = function(o) {
	if(o == null) return new Array();
	var a = new Array();
	if(o.hasOwnProperty) {
		
					for(var i in o)
						if( o.hasOwnProperty(i) )
							a.push(i);
				;
	}
	else {
		var t;
		try {
			t = o.__proto__;
		}
		catch( $e34 ) {
			{
				var e = $e34;
				{
					t = null;
				}
			}
		}
		if(t != null) o.__proto__ = null;
		
					for(var i in o)
						if( i != "__proto__" )
							a.push(i);
				;
		if(t != null) o.__proto__ = t;
	}
	return a;
}
Reflect.isFunction = function(f) {
	return typeof(f) == "function" && f.__name__ == null;
}
Reflect.compare = function(a,b) {
	return ((a == b)?0:((((a) > (b))?1:-1)));
}
Reflect.compareMethods = function(f1,f2) {
	if(f1 == f2) return true;
	if(!Reflect.isFunction(f1) || !Reflect.isFunction(f2)) return false;
	return f1.scope == f2.scope && f1.method == f2.method && f1.method != null;
}
Reflect.isObject = function(v) {
	if(v == null) return false;
	var t = typeof(v);
	return (t == "string" || (t == "object" && !v.__enum__) || (t == "function" && v.__name__ != null));
}
Reflect.deleteField = function(o,f) {
	if(!Reflect.hasField(o,f)) return false;
	delete(o[f]);
	return true;
}
Reflect.copy = function(o) {
	var o2 = { }
	{
		var _g = 0, _g1 = Reflect.fields(o);
		while(_g < _g1.length) {
			var f = _g1[_g];
			++_g;
			o2[f] = Reflect.field(o,f);
		}
	}
	return o2;
}
Reflect.makeVarArgs = function(f) {
	return function() {
		var a = new Array();
		{
			var _g1 = 0, _g = arguments.length;
			while(_g1 < _g) {
				var i = _g1++;
				a.push(arguments[i]);
			}
		}
		return f(a);
	}
}
Reflect.prototype.__class__ = Reflect;
xmpp.filter.PacketTypeFilter = function(type) { if( type === $_ ) return; {
	this.type = type;
}}
xmpp.filter.PacketTypeFilter.__name__ = ["xmpp","filter","PacketTypeFilter"];
xmpp.filter.PacketTypeFilter.prototype.accept = function(p) {
	return p._type == this.type;
}
xmpp.filter.PacketTypeFilter.prototype.type = null;
xmpp.filter.PacketTypeFilter.prototype.__class__ = xmpp.filter.PacketTypeFilter;
if(typeof event=='undefined') event = {}
event.Dispatcher = function(p) { if( p === $_ ) return; {
	this.listeners = new Array();
}}
event.Dispatcher.__name__ = ["event","Dispatcher"];
event.Dispatcher.stop = function() {
	throw event._Dispatcher.EventException.StopPropagation;
}
event.Dispatcher.prototype.addHandler = function(f) {
	return this.addListener({ handleEvent : f});
}
event.Dispatcher.prototype.addListener = function(l) {
	this.listeners.push(l);
	return l;
}
event.Dispatcher.prototype.clear = function() {
	this.listeners = new Array();
}
event.Dispatcher.prototype.dispatchEvent = function(e) {
	try {
		{
			var _g = 0, _g1 = this.listeners;
			while(_g < _g1.length) {
				var l = _g1[_g];
				++_g;
				l.handleEvent(e);
			}
		}
		return true;
	}
	catch( $e35 ) {
		if( js.Boot.__instanceof($e35,event._Dispatcher.EventException) ) {
			var e1 = $e35;
			{
				return false;
			}
		} else throw($e35);
	}
}
event.Dispatcher.prototype.listeners = null;
event.Dispatcher.prototype.removeListener = function(l) {
	this.listeners.remove(l);
	return l;
}
event.Dispatcher.prototype.__class__ = event.Dispatcher;
jabber.stream.PacketTimeout = function(handlers,time) { if( handlers === $_ ) return; {
	if(time == null) time = 0;
	event.Dispatcher.apply(this,[]);
	if(handlers != null) {
		{
			var _g = 0;
			while(_g < handlers.length) {
				var h = handlers[_g];
				++_g;
				this.addHandler(h);
			}
		}
	}
	this.setTime(time);
}}
jabber.stream.PacketTimeout.__name__ = ["jabber","stream","PacketTimeout"];
jabber.stream.PacketTimeout.__super__ = event.Dispatcher;
for(var k in event.Dispatcher.prototype ) jabber.stream.PacketTimeout.prototype[k] = event.Dispatcher.prototype[k];
jabber.stream.PacketTimeout.prototype.collector = null;
jabber.stream.PacketTimeout.prototype.forceTimeout = function() {
	this.dispatchEvent(this.collector);
	this.stop();
}
jabber.stream.PacketTimeout.prototype.handleTimeout = function() {
	this.timer.stop();
	this.timer = null;
	this.dispatchEvent(this.collector);
}
jabber.stream.PacketTimeout.prototype.setTime = function(t) {
	if(t == 0) t = jabber.stream.PacketTimeout.defaultTimeout;
	this.time = t;
	if(this.timer != null) {
		this.timer.stop();
		{
			this.timer = new haxe.Timer(this.time);
			this.timer.run = $closure(this,"handleTimeout");
		}
	}
	return this.time;
}
jabber.stream.PacketTimeout.prototype.start = function(t) {
	if(this.timer != null) this.timer.stop();
	if(t != null) this.setTime(t);
	{
		this.timer = new haxe.Timer(this.time);
		this.timer.run = $closure(this,"handleTimeout");
	}
}
jabber.stream.PacketTimeout.prototype.startTimer = function() {
	this.timer = new haxe.Timer(this.time);
	this.timer.run = $closure(this,"handleTimeout");
}
jabber.stream.PacketTimeout.prototype.stop = function() {
	if(this.timer != null) {
		this.timer.stop();
		this.timer = null;
	}
}
jabber.stream.PacketTimeout.prototype.time = null;
jabber.stream.PacketTimeout.prototype.timer = null;
jabber.stream.PacketTimeout.prototype.__class__ = jabber.stream.PacketTimeout;
jabber.Stream = function(cnx) { if( cnx === $_ ) return; {
	this.status = jabber.StreamStatus.closed;
	this.server = { features : new Hash()}
	this.features = new jabber._Stream.StreamFeatures();
	this.version = true;
	this.collectors = new List();
	this.interceptors = new List();
	this.http = false;
	this.numPacketsSent = 0;
	if(cnx != null) this.setConnection(cnx);
}}
jabber.Stream.__name__ = ["jabber","Stream"];
jabber.Stream.prototype.addCollector = function(c) {
	if(Lambda.has(this.collectors,c)) return false;
	this.collectors.add(c);
	if(c.timeout != null) c.timeout.start();
	return true;
}
jabber.Stream.prototype.addInterceptor = function(i) {
	if(Lambda.has(this.interceptors,i)) return false;
	this.interceptors.add(i);
	return true;
}
jabber.Stream.prototype.close = function(disconnect) {
	if(disconnect == null) disconnect = false;
	if(this.status == jabber.StreamStatus.open) {
		if(!this.http) this.sendData("</stream:stream>");
		this.status = jabber.StreamStatus.closed;
	}
	if(disconnect) this.cnx.disconnect();
	this.closeHandler();
}
jabber.Stream.prototype.closeHandler = function() {
	this.id = null;
	this.numPacketsSent = 0;
	this.onClose();
}
jabber.Stream.prototype.cnx = null;
jabber.Stream.prototype.collect = function(filters,handler,permanent) {
	if(permanent == null) permanent = false;
	var c = new jabber.stream.PacketCollector(filters,handler,permanent);
	return (this.addCollector(c)?c:null);
}
jabber.Stream.prototype.collectors = null;
jabber.Stream.prototype.connectHandler = function() {
	null;
}
jabber.Stream.prototype.disconnectHandler = function() {
	null;
}
jabber.Stream.prototype.errorHandler = function(m) {
	this.onClose(m);
}
jabber.Stream.prototype.features = null;
jabber.Stream.prototype.getJIDStr = function() {
	return null;
}
jabber.Stream.prototype.handlePacket = function(p) {
	var collected = false;
	{ var $it36 = this.collectors.iterator();
	while( $it36.hasNext() ) { var c = $it36.next();
	{
		if(c.accept(p)) {
			collected = true;
			c.deliver(p);
			if(!c.permanent) this.collectors.remove(c);
			if(c.block) break;
		}
	}
	}}
	if(!collected) {
		if(p._type == xmpp.PacketType.iq) {
			var q = p;
			if(q.type != xmpp.IQType.error) {
				var r = new xmpp.IQ(xmpp.IQType.error,p.id,p.from,p.to);
				r.errors.push(new xmpp.Error(xmpp.ErrorType.cancel,501,"feature-not-implemented"));
				this.sendData(r.toXml().toString());
			}
		}
	}
	return collected;
}
jabber.Stream.prototype.handleXml = function(x) {
	var ps = new Array();
	{ var $it37 = x.elements();
	while( $it37.hasNext() ) { var e = $it37.next();
	{
		var p = xmpp.Packet.parse(e);
		this.handlePacket(p);
		ps.push(p);
	}
	}}
	return ps;
}
jabber.Stream.prototype.http = null;
jabber.Stream.prototype.id = null;
jabber.Stream.prototype.interceptPacket = function(p) {
	{ var $it38 = this.interceptors.iterator();
	while( $it38.hasNext() ) { var i = $it38.next();
	i.interceptPacket(p);
	}}
	return p;
}
jabber.Stream.prototype.interceptors = null;
jabber.Stream.prototype.jidstr = null;
jabber.Stream.prototype.lang = null;
jabber.Stream.prototype.nextID = function() {
	return util.Base64.random(jabber.Stream.packetIDLength);
}
jabber.Stream.prototype.numPacketsSent = null;
jabber.Stream.prototype.onClose = function(e) {
	null;
}
jabber.Stream.prototype.onOpen = function() {
	null;
}
jabber.Stream.prototype.open = function() {
	if(this.cnx == null) throw "No stream connection set";
	if(this.cnx.connected) this.connectHandler();
	else this.cnx.connect();
	return true;
}
jabber.Stream.prototype.processData = function(buf,bufpos,buflen) {
	if(this.status == jabber.StreamStatus.closed) return -1;
	var t = buf.readString(bufpos,buflen);
	if(StringTools.startsWith(t,"</stream:stream")) {
		this.close(true);
		return -1;
	}
	else if(StringTools.startsWith(t,"</stream:error")) {
		return -1;
	}
	var $e = (this.status);
	switch( $e[1] ) {
	case 0:
	{
		return -1;
	}break;
	case 1:
	{
		return this.processStreamInit(util.XmlUtil.removeXmlHeader(t),buflen);
	}break;
	case 2:
	{
		if(t.charAt(0) != "<" || t.charAt(t.length - 1) != ">") {
			return 0;
		}
		var x = null;
		try {
			x = Xml.parse(t);
		}
		catch( $e39 ) {
			{
				var e = $e39;
				{
					return 0;
				}
			}
		}
		this.handleXml(x);
		return buflen;
	}break;
	}
	return 0;
}
jabber.Stream.prototype.processStreamInit = function(t,buflen) {
	return -1;
}
jabber.Stream.prototype.removeCollector = function(c) {
	if(!this.collectors.remove(c)) return false;
	if(c.timeout != null) c.timeout.stop();
	return true;
}
jabber.Stream.prototype.removeInterceptor = function(i) {
	return this.interceptors.remove(i);
}
jabber.Stream.prototype.sendData = function(t) {
	if(!this.cnx.connected) return null;
	if(!this.cnx.write(t)) return null;
	this.numPacketsSent++;
	return t;
}
jabber.Stream.prototype.sendIQ = function(iq,handler,permanent,timeout,block) {
	if(iq.id == null) iq.id = this.nextID();
	var c = null;
	if(handler != null) {
		c = new jabber.stream.PacketCollector([new xmpp.filter.PacketIDFilter(iq.id)],handler,permanent,timeout,block);
		this.addCollector(c);
	}
	var s = this.sendPacket(iq);
	if(s == null && handler != null) {
		this.collectors.remove(c);
		c = null;
		return null;
	}
	return { iq : s, collector : c}
}
jabber.Stream.prototype.sendMessage = function(to,body,subject,type,thread,from) {
	return this.sendPacket(new xmpp.Message(to,body,subject,type,thread,from));
}
jabber.Stream.prototype.sendPacket = function(p,intercept) {
	if(intercept == null) intercept = true;
	if(!this.cnx.connected) return null;
	if(intercept) this.interceptPacket(p);
	return ((this.sendData(p.toString()) != null)?p:null);
}
jabber.Stream.prototype.sendPresence = function(show,status,priority,type) {
	return this.sendPacket(new xmpp.Presence(show,status,priority,type));
}
jabber.Stream.prototype.server = null;
jabber.Stream.prototype.setConnection = function(c) {
	var $e = (this.status);
	switch( $e[1] ) {
	case 2:
	case 1:
	{
		this.close(true);
		this.setConnection(c);
		this.open();
	}break;
	case 0:
	{
		if(this.cnx != null && this.cnx.connected) this.cnx.disconnect();
		this.cnx = c;
		this.cnx.__onConnect = $closure(this,"connectHandler");
		this.cnx.__onDisconnect = $closure(this,"disconnectHandler");
		this.cnx.__onData = $closure(this,"processData");
		this.cnx.__onError = $closure(this,"errorHandler");
	}break;
	}
	this.http = (Type.getClassName(Type.getClass(this.cnx)) == "jabber.BOSHConnection");
	return this.cnx;
}
jabber.Stream.prototype.status = null;
jabber.Stream.prototype.version = null;
jabber.Stream.prototype.__class__ = jabber.Stream;
jabber.client.Stream = function(jid,cnx,version) { if( jid === $_ ) return; {
	if(version == null) version = true;
	if(jid == null) jid = new jabber.JID(null);
	jabber.Stream.apply(this,[cnx]);
	this.setJID(jid);
	this.version = version;
}}
jabber.client.Stream.__name__ = ["jabber","client","Stream"];
jabber.client.Stream.__super__ = jabber.Stream;
for(var k in jabber.Stream.prototype ) jabber.client.Stream.prototype[k] = jabber.Stream.prototype[k];
jabber.client.Stream.prototype.connectHandler = function() {
	this.status = jabber.StreamStatus.pending;
	if(!this.http) {
		this.sendData(xmpp.Stream.createOpenStream("jabber:client",this.jid.domain,this.version,this.lang));
		this.cnx.read(true);
	}
	else {
		if(this.cnx.connected) this.cnx.connect();
	}
}
jabber.client.Stream.prototype.getJIDStr = function() {
	return this.jid.toString();
}
jabber.client.Stream.prototype.jid = null;
jabber.client.Stream.prototype.parseStreamFeatures = function(x) {
	{ var $it40 = x.elements();
	while( $it40.hasNext() ) { var e = $it40.next();
	this.server.features.set(e.getNodeName(),e);
	}}
}
jabber.client.Stream.prototype.processStreamInit = function(t,buflen) {
	if(this.http) {
		var sx = Xml.parse(t).firstElement();
		var sf = sx.firstElement();
		this.parseStreamFeatures(sf);
		this.status = jabber.StreamStatus.open;
		this.onOpen();
		return buflen;
	}
	else {
		var sei = t.indexOf(">");
		if(sei == -1) {
			return 0;
		}
		if(this.id == null) {
			var s = t.substr(0,sei) + " />";
			var sx = Xml.parse(s).firstElement();
			this.id = sx.get("id");
			if(!this.version) {
				this.status = jabber.StreamStatus.open;
				this.onOpen();
				return buflen;
			}
		}
		if(this.id == null) {
			this.close(true);
			return -1;
		}
		if(!this.version) {
			this.status = jabber.StreamStatus.open;
			this.onOpen();
			return buflen;
		}
	}
	var sfi = t.indexOf("<stream:features>");
	var sf = t.substr(t.indexOf("<stream:features>"));
	if(sfi != -1) {
		try {
			var sfx = Xml.parse(sf).firstElement();
			this.parseStreamFeatures(sfx);
			this.status = jabber.StreamStatus.open;
			this.onOpen();
			return buflen;
		}
		catch( $e41 ) {
			{
				var e = $e41;
				{
					return 0;
				}
			}
		}
	}
	return buflen;
}
jabber.client.Stream.prototype.setJID = function(j) {
	if(this.status != jabber.StreamStatus.closed) throw "Cannot change JID on active stream";
	return this.jid = j;
}
jabber.client.Stream.prototype.__class__ = jabber.client.Stream;
xmpp.PresenceShow = { __ename__ : ["xmpp","PresenceShow"], __constructs__ : ["away","chat","dnd","xa"] }
xmpp.PresenceShow.away = ["away",0];
xmpp.PresenceShow.away.toString = $estr;
xmpp.PresenceShow.away.__enum__ = xmpp.PresenceShow;
xmpp.PresenceShow.chat = ["chat",1];
xmpp.PresenceShow.chat.toString = $estr;
xmpp.PresenceShow.chat.__enum__ = xmpp.PresenceShow;
xmpp.PresenceShow.dnd = ["dnd",2];
xmpp.PresenceShow.dnd.toString = $estr;
xmpp.PresenceShow.dnd.__enum__ = xmpp.PresenceShow;
xmpp.PresenceShow.xa = ["xa",3];
xmpp.PresenceShow.xa.toString = $estr;
xmpp.PresenceShow.xa.__enum__ = xmpp.PresenceShow;
IntIter = function(min,max) { if( min === $_ ) return; {
	this.min = min;
	this.max = max;
}}
IntIter.__name__ = ["IntIter"];
IntIter.prototype.hasNext = function() {
	return this.min < this.max;
}
IntIter.prototype.max = null;
IntIter.prototype.min = null;
IntIter.prototype.next = function() {
	return this.min++;
}
IntIter.prototype.__class__ = IntIter;
xmpp.filter.IQFilter = function(xmlns,nodeName,type) { if( xmlns === $_ ) return; {
	this.xmlns = xmlns;
	this.nodeName = nodeName;
	this.iqType = type;
}}
xmpp.filter.IQFilter.__name__ = ["xmpp","filter","IQFilter"];
xmpp.filter.IQFilter.prototype.accept = function(p) {
	if(p._type != xmpp.PacketType.iq) return false;
	var iq = p;
	if(this.iqType != null && this.iqType != iq.type) return false;
	var x = null;
	if(this.xmlns != null) {
		if(iq.x == null) return false;
		x = iq.x.toXml();
		if(this.xmlns != x.get("xmlns")) return false;
	}
	if(this.nodeName != null) {
		if(iq.x == null) return false;
		if(x == null) x = iq.x.toXml();
		if(this.nodeName != x.getNodeName()) return false;
	}
	return true;
}
xmpp.filter.IQFilter.prototype.iqType = null;
xmpp.filter.IQFilter.prototype.nodeName = null;
xmpp.filter.IQFilter.prototype.xmlns = null;
xmpp.filter.IQFilter.prototype.__class__ = xmpp.filter.IQFilter;
ValueType = { __ename__ : ["ValueType"], __constructs__ : ["TNull","TInt","TFloat","TBool","TObject","TFunction","TClass","TEnum","TUnknown"] }
ValueType.TBool = ["TBool",3];
ValueType.TBool.toString = $estr;
ValueType.TBool.__enum__ = ValueType;
ValueType.TClass = function(c) { var $x = ["TClass",6,c]; $x.__enum__ = ValueType; $x.toString = $estr; return $x; }
ValueType.TEnum = function(e) { var $x = ["TEnum",7,e]; $x.__enum__ = ValueType; $x.toString = $estr; return $x; }
ValueType.TFloat = ["TFloat",2];
ValueType.TFloat.toString = $estr;
ValueType.TFloat.__enum__ = ValueType;
ValueType.TFunction = ["TFunction",5];
ValueType.TFunction.toString = $estr;
ValueType.TFunction.__enum__ = ValueType;
ValueType.TInt = ["TInt",1];
ValueType.TInt.toString = $estr;
ValueType.TInt.__enum__ = ValueType;
ValueType.TNull = ["TNull",0];
ValueType.TNull.toString = $estr;
ValueType.TNull.__enum__ = ValueType;
ValueType.TObject = ["TObject",4];
ValueType.TObject.toString = $estr;
ValueType.TObject.__enum__ = ValueType;
ValueType.TUnknown = ["TUnknown",8];
ValueType.TUnknown.toString = $estr;
ValueType.TUnknown.__enum__ = ValueType;
Type = function() { }
Type.__name__ = ["Type"];
Type.getClass = function(o) {
	if(o == null) return null;
	if(o.__enum__ != null) return null;
	return o.__class__;
}
Type.getEnum = function(o) {
	if(o == null) return null;
	return o.__enum__;
}
Type.getSuperClass = function(c) {
	return c.__super__;
}
Type.getClassName = function(c) {
	if(c == null) return null;
	var a = c.__name__;
	return a.join(".");
}
Type.getEnumName = function(e) {
	var a = e.__ename__;
	return a.join(".");
}
Type.resolveClass = function(name) {
	var cl;
	try {
		cl = eval(name);
	}
	catch( $e42 ) {
		{
			var e = $e42;
			{
				cl = null;
			}
		}
	}
	if(cl == null || cl.__name__ == null) return null;
	return cl;
}
Type.resolveEnum = function(name) {
	var e;
	try {
		e = eval(name);
	}
	catch( $e43 ) {
		{
			var err = $e43;
			{
				e = null;
			}
		}
	}
	if(e == null || e.__ename__ == null) return null;
	return e;
}
Type.createInstance = function(cl,args) {
	if(args.length <= 3) return new cl(args[0],args[1],args[2]);
	if(args.length > 8) throw "Too many arguments";
	return new cl(args[0],args[1],args[2],args[3],args[4],args[5],args[6],args[7]);
}
Type.createEmptyInstance = function(cl) {
	return new cl($_);
}
Type.createEnum = function(e,constr,params) {
	var f = Reflect.field(e,constr);
	if(f == null) throw "No such constructor " + constr;
	if(Reflect.isFunction(f)) {
		if(params == null) throw "Constructor " + constr + " need parameters";
		return f.apply(e,params);
	}
	if(params != null && params.length != 0) throw "Constructor " + constr + " does not need parameters";
	return f;
}
Type.createEnumIndex = function(e,index,params) {
	var c = Type.getEnumConstructs(e)[index];
	if(c == null) throw index + " is not a valid enum constructor index";
	return Type.createEnum(e,c,params);
}
Type.getInstanceFields = function(c) {
	var a = Reflect.fields(c.prototype);
	a.remove("__class__");
	return a;
}
Type.getClassFields = function(c) {
	var a = Reflect.fields(c);
	a.remove("__name__");
	a.remove("__interfaces__");
	a.remove("__super__");
	a.remove("prototype");
	return a;
}
Type.getEnumConstructs = function(e) {
	return e.__constructs__;
}
Type["typeof"] = function(v) {
	switch(typeof(v)) {
	case "boolean":{
		return ValueType.TBool;
	}break;
	case "string":{
		return ValueType.TClass(String);
	}break;
	case "number":{
		if(Math.ceil(v) == v % 2147483648.0) return ValueType.TInt;
		return ValueType.TFloat;
	}break;
	case "object":{
		if(v == null) return ValueType.TNull;
		var e = v.__enum__;
		if(e != null) return ValueType.TEnum(e);
		var c = v.__class__;
		if(c != null) return ValueType.TClass(c);
		return ValueType.TObject;
	}break;
	case "function":{
		if(v.__name__ != null) return ValueType.TObject;
		return ValueType.TFunction;
	}break;
	case "undefined":{
		return ValueType.TNull;
	}break;
	default:{
		return ValueType.TUnknown;
	}break;
	}
}
Type.enumEq = function(a,b) {
	if(a == b) return true;
	try {
		if(a[0] != b[0]) return false;
		{
			var _g1 = 2, _g = a.length;
			while(_g1 < _g) {
				var i = _g1++;
				if(!Type.enumEq(a[i],b[i])) return false;
			}
		}
		var e = a.__enum__;
		if(e != b.__enum__ || e == null) return false;
	}
	catch( $e44 ) {
		{
			var e = $e44;
			{
				return false;
			}
		}
	}
	return true;
}
Type.enumConstructor = function(e) {
	return e[0];
}
Type.enumParameters = function(e) {
	return e.slice(2);
}
Type.enumIndex = function(e) {
	return e[1];
}
Type.prototype.__class__ = Type;
if(typeof js=='undefined') js = {}
js.Boot = function() { }
js.Boot.__name__ = ["js","Boot"];
js.Boot.__unhtml = function(s) {
	return s.split("&").join("&amp;").split("<").join("&lt;").split(">").join("&gt;");
}
js.Boot.__trace = function(v,i) {
	var msg = (i != null?i.fileName + ":" + i.lineNumber + ": ":"");
	msg += js.Boot.__unhtml(js.Boot.__string_rec(v,"")) + "<br/>";
	var d = document.getElementById("haxe:trace");
	if(d == null) alert("No haxe:trace element defined\n" + msg);
	else d.innerHTML += msg;
}
js.Boot.__clear_trace = function() {
	var d = document.getElementById("haxe:trace");
	if(d != null) d.innerHTML = "";
	else null;
}
js.Boot.__closure = function(o,f) {
	var m = o[f];
	if(m == null) return null;
	var f1 = function() {
		return m.apply(o,arguments);
	}
	f1.scope = o;
	f1.method = m;
	return f1;
}
js.Boot.__string_rec = function(o,s) {
	if(o == null) return "null";
	if(s.length >= 5) return "<...>";
	var t = typeof(o);
	if(t == "function" && (o.__name__ != null || o.__ename__ != null)) t = "object";
	switch(t) {
	case "object":{
		if(o instanceof Array) {
			if(o.__enum__ != null) {
				if(o.length == 2) return o[0];
				var str = o[0] + "(";
				s += "\t";
				{
					var _g1 = 2, _g = o.length;
					while(_g1 < _g) {
						var i = _g1++;
						if(i != 2) str += "," + js.Boot.__string_rec(o[i],s);
						else str += js.Boot.__string_rec(o[i],s);
					}
				}
				return str + ")";
			}
			var l = o.length;
			var i;
			var str = "[";
			s += "\t";
			{
				var _g = 0;
				while(_g < l) {
					var i1 = _g++;
					str += ((i1 > 0?",":"")) + js.Boot.__string_rec(o[i1],s);
				}
			}
			str += "]";
			return str;
		}
		var tostr;
		try {
			tostr = o.toString;
		}
		catch( $e45 ) {
			{
				var e = $e45;
				{
					return "???";
				}
			}
		}
		if(tostr != null && tostr != Object.toString) {
			var s2 = o.toString();
			if(s2 != "[object Object]") return s2;
		}
		var k = null;
		var str = "{\n";
		s += "\t";
		var hasp = (o.hasOwnProperty != null);
		for( var k in o ) { ;
		if(hasp && !o.hasOwnProperty(k)) continue;
		if(k == "prototype" || k == "__class__" || k == "__super__" || k == "__interfaces__") continue;
		if(str.length != 2) str += ", \n";
		str += s + k + " : " + js.Boot.__string_rec(o[k],s);
		}
		s = s.substring(1);
		str += "\n" + s + "}";
		return str;
	}break;
	case "function":{
		return "<function>";
	}break;
	case "string":{
		return o;
	}break;
	default:{
		return String(o);
	}break;
	}
}
js.Boot.__interfLoop = function(cc,cl) {
	if(cc == null) return false;
	if(cc == cl) return true;
	var intf = cc.__interfaces__;
	if(intf != null) {
		var _g1 = 0, _g = intf.length;
		while(_g1 < _g) {
			var i = _g1++;
			var i1 = intf[i];
			if(i1 == cl || js.Boot.__interfLoop(i1,cl)) return true;
		}
	}
	return js.Boot.__interfLoop(cc.__super__,cl);
}
js.Boot.__instanceof = function(o,cl) {
	try {
		if(o instanceof cl) {
			if(cl == Array) return (o.__enum__ == null);
			return true;
		}
		if(js.Boot.__interfLoop(o.__class__,cl)) return true;
	}
	catch( $e46 ) {
		{
			var e = $e46;
			{
				if(cl == null) return false;
			}
		}
	}
	switch(cl) {
	case Int:{
		return Math.ceil(o%2147483648.0) === o;
	}break;
	case Float:{
		return typeof(o) == "number";
	}break;
	case Bool:{
		return o === true || o === false;
	}break;
	case String:{
		return typeof(o) == "string";
	}break;
	case Dynamic:{
		return true;
	}break;
	default:{
		if(o == null) return false;
		return o.__enum__ == cl || (cl == Class && o.__name__ != null) || (cl == Enum && o.__ename__ != null);
	}break;
	}
}
js.Boot.__init = function() {
	js.Lib.isIE = (typeof document!='undefined' && document.all != null && typeof window!='undefined' && window.opera == null);
	js.Lib.isOpera = (typeof window!='undefined' && window.opera != null);
	Array.prototype.copy = Array.prototype.slice;
	Array.prototype.insert = function(i,x) {
		this.splice(i,0,x);
	}
	Array.prototype.remove = (Array.prototype.indexOf?function(obj) {
		var idx = this.indexOf(obj);
		if(idx == -1) return false;
		this.splice(idx,1);
		return true;
	}:function(obj) {
		var i = 0;
		var l = this.length;
		while(i < l) {
			if(this[i] == obj) {
				this.splice(i,1);
				return true;
			}
			i++;
		}
		return false;
	});
	Array.prototype.iterator = function() {
		return { cur : 0, arr : this, hasNext : function() {
			return this.cur < this.arr.length;
		}, next : function() {
			return this.arr[this.cur++];
		}}
	}
	var cca = String.prototype.charCodeAt;
	String.prototype.cca = cca;
	String.prototype.charCodeAt = function(i) {
		var x = cca.call(this,i);
		if(isNaN(x)) return null;
		return x;
	}
	var oldsub = String.prototype.substr;
	String.prototype.substr = function(pos,len) {
		if(pos != null && pos != 0 && len != null && len < 0) return "";
		if(len == null) len = this.length;
		if(pos < 0) {
			pos = this.length + pos;
			if(pos < 0) pos = 0;
		}
		else if(len < 0) {
			len = this.length + len - pos;
		}
		return oldsub.apply(this,[pos,len]);
	}
	$closure = js.Boot.__closure;
}
js.Boot.prototype.__class__ = js.Boot;
xmpp.PresenceType = { __ename__ : ["xmpp","PresenceType"], __constructs__ : ["error","probe","subscribe","subscribed","unavailable","unsubscribe","unsubscribed"] }
xmpp.PresenceType.error = ["error",0];
xmpp.PresenceType.error.toString = $estr;
xmpp.PresenceType.error.__enum__ = xmpp.PresenceType;
xmpp.PresenceType.probe = ["probe",1];
xmpp.PresenceType.probe.toString = $estr;
xmpp.PresenceType.probe.__enum__ = xmpp.PresenceType;
xmpp.PresenceType.subscribe = ["subscribe",2];
xmpp.PresenceType.subscribe.toString = $estr;
xmpp.PresenceType.subscribe.__enum__ = xmpp.PresenceType;
xmpp.PresenceType.subscribed = ["subscribed",3];
xmpp.PresenceType.subscribed.toString = $estr;
xmpp.PresenceType.subscribed.__enum__ = xmpp.PresenceType;
xmpp.PresenceType.unavailable = ["unavailable",4];
xmpp.PresenceType.unavailable.toString = $estr;
xmpp.PresenceType.unavailable.__enum__ = xmpp.PresenceType;
xmpp.PresenceType.unsubscribe = ["unsubscribe",5];
xmpp.PresenceType.unsubscribe.toString = $estr;
xmpp.PresenceType.unsubscribe.__enum__ = xmpp.PresenceType;
xmpp.PresenceType.unsubscribed = ["unsubscribed",6];
xmpp.PresenceType.unsubscribed.toString = $estr;
xmpp.PresenceType.unsubscribed.__enum__ = xmpp.PresenceType;
js.JsXml__ = function(p) { if( p === $_ ) return; {
	null;
}}
js.JsXml__.__name__ = ["js","JsXml__"];
js.JsXml__.parse = function(str) {
	var rules = [js.JsXml__.enode,js.JsXml__.epcdata,js.JsXml__.eend,js.JsXml__.ecdata,js.JsXml__.edoctype,js.JsXml__.ecomment,js.JsXml__.eprolog];
	var nrules = rules.length;
	var current = Xml.createDocument();
	var stack = new List();
	while(str.length > 0) {
		var i = 0;
		try {
			while(i < nrules) {
				var r = rules[i];
				if(r.match(str)) {
					switch(i) {
					case 0:{
						var x = Xml.createElement(r.matched(1));
						current.addChild(x);
						str = r.matchedRight();
						while(js.JsXml__.eattribute.match(str)) {
							x.set(js.JsXml__.eattribute.matched(1),js.JsXml__.eattribute.matched(3));
							str = js.JsXml__.eattribute.matchedRight();
						}
						if(!js.JsXml__.eclose.match(str)) {
							i = nrules;
							throw "__break__";
						}
						if(js.JsXml__.eclose.matched(1) == ">") {
							stack.push(current);
							current = x;
						}
						str = js.JsXml__.eclose.matchedRight();
					}break;
					case 1:{
						var x = Xml.createPCData(r.matched(0));
						current.addChild(x);
						str = r.matchedRight();
					}break;
					case 2:{
						if(current._children != null && current._children.length == 0) {
							var e = Xml.createPCData("");
							current.addChild(e);
						}
						else null;
						if(r.matched(1) != current._nodeName || stack.isEmpty()) {
							i = nrules;
							throw "__break__";
						}
						else null;
						current = stack.pop();
						str = r.matchedRight();
					}break;
					case 3:{
						str = r.matchedRight();
						if(!js.JsXml__.ecdata_end.match(str)) throw "End of CDATA section not found";
						var x = Xml.createCData(js.JsXml__.ecdata_end.matchedLeft());
						current.addChild(x);
						str = js.JsXml__.ecdata_end.matchedRight();
					}break;
					case 4:{
						var pos = 0;
						var count = 0;
						var old = str;
						try {
							while(true) {
								if(!js.JsXml__.edoctype_elt.match(str)) throw "End of DOCTYPE section not found";
								var p = js.JsXml__.edoctype_elt.matchedPos();
								pos += p.pos + p.len;
								str = js.JsXml__.edoctype_elt.matchedRight();
								switch(js.JsXml__.edoctype_elt.matched(0)) {
								case "[":{
									count++;
								}break;
								case "]":{
									count--;
									if(count < 0) throw "Invalid ] found in DOCTYPE declaration";
								}break;
								default:{
									if(count == 0) throw "__break__";
								}break;
								}
							}
						} catch( e ) { if( e != "__break__" ) throw e; }
						var x = Xml.createDocType(old.substr(0,pos));
						current.addChild(x);
					}break;
					case 5:{
						if(!js.JsXml__.ecomment_end.match(str)) throw "Unclosed Comment";
						var p = js.JsXml__.ecomment_end.matchedPos();
						var x = Xml.createComment(str.substr(0,p.pos + p.len));
						current.addChild(x);
						str = js.JsXml__.ecomment_end.matchedRight();
					}break;
					case 6:{
						var x = Xml.createProlog(r.matched(0));
						current.addChild(x);
						str = r.matchedRight();
					}break;
					}
					throw "__break__";
				}
				i += 1;
			}
		} catch( e ) { if( e != "__break__" ) throw e; }
		if(i == nrules) {
			if(str.length > 10) throw ("Xml parse error : Unexpected " + str.substr(0,10) + "...");
			else throw ("Xml parse error : Unexpected " + str);
		}
	}
	if(!stack.isEmpty()) throw "Xml parse error : Unclosed " + stack.last().getNodeName();
	return current;
}
js.JsXml__.createElement = function(name) {
	var r = new js.JsXml__();
	r.nodeType = Xml.Element;
	r._children = new Array();
	r._attributes = new Hash();
	r.setNodeName(name);
	return r;
}
js.JsXml__.createPCData = function(data) {
	var r = new js.JsXml__();
	r.nodeType = Xml.PCData;
	r.setNodeValue(data);
	return r;
}
js.JsXml__.createCData = function(data) {
	var r = new js.JsXml__();
	r.nodeType = Xml.CData;
	r.setNodeValue(data);
	return r;
}
js.JsXml__.createComment = function(data) {
	var r = new js.JsXml__();
	r.nodeType = Xml.Comment;
	r.setNodeValue(data);
	return r;
}
js.JsXml__.createDocType = function(data) {
	var r = new js.JsXml__();
	r.nodeType = Xml.DocType;
	r.setNodeValue(data);
	return r;
}
js.JsXml__.createProlog = function(data) {
	var r = new js.JsXml__();
	r.nodeType = Xml.Prolog;
	r.setNodeValue(data);
	return r;
}
js.JsXml__.createDocument = function() {
	var r = new js.JsXml__();
	r.nodeType = Xml.Document;
	r._children = new Array();
	return r;
}
js.JsXml__.prototype._attributes = null;
js.JsXml__.prototype._children = null;
js.JsXml__.prototype._nodeName = null;
js.JsXml__.prototype._nodeValue = null;
js.JsXml__.prototype._parent = null;
js.JsXml__.prototype.addChild = function(x) {
	if(this._children == null) throw "bad nodetype";
	if(x._parent != null) x._parent._children.remove(x);
	x._parent = this;
	this._children.push(x);
}
js.JsXml__.prototype.attributes = function() {
	if(this.nodeType != Xml.Element) throw "bad nodeType";
	return this._attributes.keys();
}
js.JsXml__.prototype.elements = function() {
	if(this._children == null) throw "bad nodetype";
	return { cur : 0, x : this._children, hasNext : function() {
		var k = this.cur;
		var l = this.x.length;
		while(k < l) {
			if(this.x[k].nodeType == Xml.Element) break;
			k += 1;
		}
		this.cur = k;
		return k < l;
	}, next : function() {
		var k = this.cur;
		var l = this.x.length;
		while(k < l) {
			var n = this.x[k];
			k += 1;
			if(n.nodeType == Xml.Element) {
				this.cur = k;
				return n;
			}
		}
		return null;
	}}
}
js.JsXml__.prototype.elementsNamed = function(name) {
	if(this._children == null) throw "bad nodetype";
	return { cur : 0, x : this._children, hasNext : function() {
		var k = this.cur;
		var l = this.x.length;
		while(k < l) {
			var n = this.x[k];
			if(n.nodeType == Xml.Element && n._nodeName == name) break;
			k++;
		}
		this.cur = k;
		return k < l;
	}, next : function() {
		var k = this.cur;
		var l = this.x.length;
		while(k < l) {
			var n = this.x[k];
			k++;
			if(n.nodeType == Xml.Element && n._nodeName == name) {
				this.cur = k;
				return n;
			}
		}
		return null;
	}}
}
js.JsXml__.prototype.exists = function(att) {
	if(this.nodeType != Xml.Element) throw "bad nodeType";
	return this._attributes.exists(att);
}
js.JsXml__.prototype.firstChild = function() {
	if(this._children == null) throw "bad nodetype";
	return this._children[0];
}
js.JsXml__.prototype.firstElement = function() {
	if(this._children == null) throw "bad nodetype";
	var cur = 0;
	var l = this._children.length;
	while(cur < l) {
		var n = this._children[cur];
		if(n.nodeType == Xml.Element) return n;
		cur++;
	}
	return null;
}
js.JsXml__.prototype.get = function(att) {
	if(this.nodeType != Xml.Element) throw "bad nodeType";
	return this._attributes.get(att);
}
js.JsXml__.prototype.getNodeName = function() {
	if(this.nodeType != Xml.Element) throw "bad nodeType";
	return this._nodeName;
}
js.JsXml__.prototype.getNodeValue = function() {
	if(this.nodeType == Xml.Element || this.nodeType == Xml.Document) throw "bad nodeType";
	return this._nodeValue;
}
js.JsXml__.prototype.getParent = function() {
	return this._parent;
}
js.JsXml__.prototype.insertChild = function(x,pos) {
	if(this._children == null) throw "bad nodetype";
	if(x._parent != null) x._parent._children.remove(x);
	x._parent = this;
	this._children.insert(pos,x);
}
js.JsXml__.prototype.iterator = function() {
	if(this._children == null) throw "bad nodetype";
	return { cur : 0, x : this._children, hasNext : function() {
		return this.cur < this.x.length;
	}, next : function() {
		return this.x[this.cur++];
	}}
}
js.JsXml__.prototype.nodeName = null;
js.JsXml__.prototype.nodeType = null;
js.JsXml__.prototype.nodeValue = null;
js.JsXml__.prototype.parent = null;
js.JsXml__.prototype.remove = function(att) {
	if(this.nodeType != Xml.Element) throw "bad nodeType";
	this._attributes.remove(att);
}
js.JsXml__.prototype.removeChild = function(x) {
	if(this._children == null) throw "bad nodetype";
	var b = this._children.remove(x);
	if(b) x._parent = null;
	return b;
}
js.JsXml__.prototype.set = function(att,value) {
	if(this.nodeType != Xml.Element) throw "bad nodeType";
	this._attributes.set(att,value);
}
js.JsXml__.prototype.setNodeName = function(n) {
	if(this.nodeType != Xml.Element) throw "bad nodeType";
	return this._nodeName = n;
}
js.JsXml__.prototype.setNodeValue = function(v) {
	if(this.nodeType == Xml.Element || this.nodeType == Xml.Document) throw "bad nodeType";
	return this._nodeValue = v;
}
js.JsXml__.prototype.toString = function() {
	if(this.nodeType == Xml.PCData) return this._nodeValue;
	if(this.nodeType == Xml.CData) return "<![CDATA[" + this._nodeValue + "]]>";
	if(this.nodeType == Xml.Comment || this.nodeType == Xml.DocType || this.nodeType == Xml.Prolog) return this._nodeValue;
	var s = new StringBuf();
	if(this.nodeType == Xml.Element) {
		s.b[s.b.length] = "<";
		s.b[s.b.length] = this._nodeName;
		{ var $it47 = this._attributes.keys();
		while( $it47.hasNext() ) { var k = $it47.next();
		{
			s.b[s.b.length] = " ";
			s.b[s.b.length] = k;
			s.b[s.b.length] = "=\"";
			s.b[s.b.length] = this._attributes.get(k);
			s.b[s.b.length] = "\"";
		}
		}}
		if(this._children.length == 0) {
			s.b[s.b.length] = "/>";
			return s.b.join("");
		}
		s.b[s.b.length] = ">";
	}
	{ var $it48 = this.iterator();
	while( $it48.hasNext() ) { var x = $it48.next();
	s.b[s.b.length] = x.toString();
	}}
	if(this.nodeType == Xml.Element) {
		s.b[s.b.length] = "</";
		s.b[s.b.length] = this._nodeName;
		s.b[s.b.length] = ">";
	}
	return s.b.join("");
}
js.JsXml__.prototype.__class__ = js.JsXml__;
if(!xmpp.roster) xmpp.roster = {}
xmpp.roster.AskType = { __ename__ : ["xmpp","roster","AskType"], __constructs__ : ["subscribe","unsubscribe"] }
xmpp.roster.AskType.subscribe = ["subscribe",0];
xmpp.roster.AskType.subscribe.toString = $estr;
xmpp.roster.AskType.subscribe.__enum__ = xmpp.roster.AskType;
xmpp.roster.AskType.unsubscribe = ["unsubscribe",1];
xmpp.roster.AskType.unsubscribe.toString = $estr;
xmpp.roster.AskType.unsubscribe.__enum__ = xmpp.roster.AskType;
haxe.Timer = function(time_ms) { if( time_ms === $_ ) return; {
	this.id = haxe.Timer.arr.length;
	haxe.Timer.arr[this.id] = this;
	this.timerId = window.setInterval("haxe.Timer.arr[" + this.id + "].run();",time_ms);
}}
haxe.Timer.__name__ = ["haxe","Timer"];
haxe.Timer.delay = function(f,time_ms) {
	var t = new haxe.Timer(time_ms);
	t.run = function() {
		t.stop();
		f();
	}
	return t;
}
haxe.Timer.stamp = function() {
	return Date.now().getTime() / 1000;
}
haxe.Timer.prototype.id = null;
haxe.Timer.prototype.run = function() {
	null;
}
haxe.Timer.prototype.stop = function() {
	if(this.id == null) return;
	window.clearInterval(this.timerId);
	haxe.Timer.arr[this.id] = null;
	if(this.id > 100 && this.id == haxe.Timer.arr.length - 1) {
		var p = this.id - 1;
		while(p >= 0 && haxe.Timer.arr[p] == null) p--;
		haxe.Timer.arr = haxe.Timer.arr.slice(0,p + 1);
	}
	this.id = null;
}
haxe.Timer.prototype.timerId = null;
haxe.Timer.prototype.__class__ = haxe.Timer;
jabber.stream.FilterList = function(p) { if( p === $_ ) return; {
	this.clear();
}}
jabber.stream.FilterList.__name__ = ["jabber","stream","FilterList"];
jabber.stream.FilterList.prototype.addFilter = function(_f) {
	this.f.push(_f);
}
jabber.stream.FilterList.prototype.addIDFilter = function(_f) {
	this.fid.push(_f);
}
jabber.stream.FilterList.prototype.clear = function() {
	this.fid = new Array();
	this.f = new Array();
}
jabber.stream.FilterList.prototype.f = null;
jabber.stream.FilterList.prototype.fid = null;
jabber.stream.FilterList.prototype.iterator = function() {
	return this.fid.concat(this.f).iterator();
}
jabber.stream.FilterList.prototype.push = function(_f) {
	if(Std["is"](_f,xmpp.filter.PacketIDFilter)) this.fid.push(_f);
	else this.f.push(_f);
}
jabber.stream.FilterList.prototype.remove = function(_f) {
	if(this.fid.remove(_f) || this.f.remove(_f)) return true;
	return false;
}
jabber.stream.FilterList.prototype.unshift = function(_f) {
	if(Std["is"](_f,xmpp.filter.PacketIDFilter)) this.fid.unshift(_f);
	else this.f.unshift(_f);
}
jabber.stream.FilterList.prototype.__class__ = jabber.stream.FilterList;
xmpp.PacketType = { __ename__ : ["xmpp","PacketType"], __constructs__ : ["iq","message","presence","custom"] }
xmpp.PacketType.custom = ["custom",3];
xmpp.PacketType.custom.toString = $estr;
xmpp.PacketType.custom.__enum__ = xmpp.PacketType;
xmpp.PacketType.iq = ["iq",0];
xmpp.PacketType.iq.toString = $estr;
xmpp.PacketType.iq.__enum__ = xmpp.PacketType;
xmpp.PacketType.message = ["message",1];
xmpp.PacketType.message.toString = $estr;
xmpp.PacketType.message.__enum__ = xmpp.PacketType;
xmpp.PacketType.presence = ["presence",2];
xmpp.PacketType.presence.toString = $estr;
xmpp.PacketType.presence.__enum__ = xmpp.PacketType;
jabber.client.NonSASLAuthentication = function(stream,usePlainText) { if( stream === $_ ) return; {
	if(usePlainText == null) usePlainText = false;
	jabber.client.Authentication.apply(this,[stream]);
	this.usePlainText = usePlainText;
	this.username = stream.jid.node;
	this.active = false;
}}
jabber.client.NonSASLAuthentication.__name__ = ["jabber","client","NonSASLAuthentication"];
jabber.client.NonSASLAuthentication.__super__ = jabber.client.Authentication;
for(var k in jabber.client.Authentication.prototype ) jabber.client.NonSASLAuthentication.prototype[k] = jabber.client.Authentication.prototype[k];
jabber.client.NonSASLAuthentication.prototype.active = null;
jabber.client.NonSASLAuthentication.prototype.authenticate = function(password,resource) {
	if(this.active) throw "Authentication in progress";
	this.password = password;
	if(resource != null) {
		this.resource = resource;
		this.stream.jid.resource = resource;
	}
	this.active = true;
	var iq = new xmpp.IQ();
	iq.x = new xmpp.Auth(this.username);
	this.stream.sendIQ(iq,$closure(this,"handleResponse"));
	return true;
}
jabber.client.NonSASLAuthentication.prototype.handleResponse = function(iq) {
	var $e = (iq.type);
	switch( $e[1] ) {
	case 2:
	{
		var hasDigest = (!this.usePlainText && iq.x.toXml().elementsNamed("digest").next() != null);
		var r = new xmpp.IQ(xmpp.IQType.set);
		null;
		r.x = (hasDigest?new xmpp.Auth(this.username,null,crypt.SHA1.encode(this.stream.id + this.password),this.resource):new xmpp.Auth(this.username,this.password,null,this.resource));
		this.stream.sendIQ(r,$closure(this,"handleResult"));
	}break;
	case 3:
	{
		this.onFail(new jabber.XMPPError(this,iq));
	}break;
	default:{
		null;
	}break;
	}
}
jabber.client.NonSASLAuthentication.prototype.handleResult = function(iq) {
	this.active = false;
	var $e = (iq.type);
	switch( $e[1] ) {
	case 2:
	{
		this.onSuccess();
	}break;
	case 3:
	{
		this.onFail(new jabber.XMPPError(this,iq));
	}break;
	default:{
		null;
	}break;
	}
}
jabber.client.NonSASLAuthentication.prototype.password = null;
jabber.client.NonSASLAuthentication.prototype.usePlainText = null;
jabber.client.NonSASLAuthentication.prototype.username = null;
jabber.client.NonSASLAuthentication.prototype.__class__ = jabber.client.NonSASLAuthentication;
xmpp.roster.Subscription = { __ename__ : ["xmpp","roster","Subscription"], __constructs__ : ["none","to","from","both","remove"] }
xmpp.roster.Subscription.both = ["both",3];
xmpp.roster.Subscription.both.toString = $estr;
xmpp.roster.Subscription.both.__enum__ = xmpp.roster.Subscription;
xmpp.roster.Subscription.from = ["from",2];
xmpp.roster.Subscription.from.toString = $estr;
xmpp.roster.Subscription.from.__enum__ = xmpp.roster.Subscription;
xmpp.roster.Subscription.none = ["none",0];
xmpp.roster.Subscription.none.toString = $estr;
xmpp.roster.Subscription.none.__enum__ = xmpp.roster.Subscription;
xmpp.roster.Subscription.remove = ["remove",4];
xmpp.roster.Subscription.remove.toString = $estr;
xmpp.roster.Subscription.remove.__enum__ = xmpp.roster.Subscription;
xmpp.roster.Subscription.to = ["to",1];
xmpp.roster.Subscription.to.toString = $estr;
xmpp.roster.Subscription.to.__enum__ = xmpp.roster.Subscription;
xmpp.Auth = function(username,password,digest,resource) { if( username === $_ ) return; {
	this.username = username;
	this.password = password;
	this.digest = digest;
	this.resource = resource;
}}
xmpp.Auth.__name__ = ["xmpp","Auth"];
xmpp.Auth.parse = function(x) {
	var a = new xmpp.Auth();
	{ var $it49 = x.elements();
	while( $it49.hasNext() ) { var e = $it49.next();
	{
		var v = null;
		try {
			v = e.firstChild().getNodeValue();
		}
		catch( $e50 ) {
			{
				var e1 = $e50;
				null;
			}
		}
		if(v != null) {
			switch(e.getNodeName()) {
			case "username":{
				a.username = v;
			}break;
			case "password":{
				a.password = v;
			}break;
			case "digest":{
				a.digest = v;
			}break;
			case "resource":{
				a.resource = v;
			}break;
			}
		}
	}
	}}
	return a;
}
xmpp.Auth.prototype.digest = null;
xmpp.Auth.prototype.password = null;
xmpp.Auth.prototype.resource = null;
xmpp.Auth.prototype.toString = function() {
	return this.toXml().toString();
}
xmpp.Auth.prototype.toXml = function() {
	var x = xmpp.IQ.createQueryXml("jabber:iq:auth");
	if(this.username != null) x.addChild(util.XmlUtil.createElement("username",this.username));
	if(this.password != null) x.addChild(util.XmlUtil.createElement("password",this.password));
	if(this.digest != null) x.addChild(util.XmlUtil.createElement("digest",this.digest));
	if(this.resource != null) x.addChild(util.XmlUtil.createElement("resource",this.resource));
	return x;
}
xmpp.Auth.prototype.username = null;
xmpp.Auth.prototype.__class__ = xmpp.Auth;
StringBuf = function(p) { if( p === $_ ) return; {
	this.b = new Array();
}}
StringBuf.__name__ = ["StringBuf"];
StringBuf.prototype.add = function(x) {
	this.b[this.b.length] = x;
}
StringBuf.prototype.addChar = function(c) {
	this.b[this.b.length] = String.fromCharCode(c);
}
StringBuf.prototype.addSub = function(s,pos,len) {
	this.b[this.b.length] = s.substr(pos,len);
}
StringBuf.prototype.b = null;
StringBuf.prototype.toString = function() {
	return this.b.join("");
}
StringBuf.prototype.__class__ = StringBuf;
Lambda = function() { }
Lambda.__name__ = ["Lambda"];
Lambda.array = function(it) {
	var a = new Array();
	{ var $it51 = it.iterator();
	while( $it51.hasNext() ) { var i = $it51.next();
	a.push(i);
	}}
	return a;
}
Lambda.list = function(it) {
	var l = new List();
	{ var $it52 = it.iterator();
	while( $it52.hasNext() ) { var i = $it52.next();
	l.add(i);
	}}
	return l;
}
Lambda.map = function(it,f) {
	var l = new List();
	{ var $it53 = it.iterator();
	while( $it53.hasNext() ) { var x = $it53.next();
	l.add(f(x));
	}}
	return l;
}
Lambda.mapi = function(it,f) {
	var l = new List();
	var i = 0;
	{ var $it54 = it.iterator();
	while( $it54.hasNext() ) { var x = $it54.next();
	l.add(f(i++,x));
	}}
	return l;
}
Lambda.has = function(it,elt,cmp) {
	if(cmp == null) {
		{ var $it55 = it.iterator();
		while( $it55.hasNext() ) { var x = $it55.next();
		if(x == elt) return true;
		}}
	}
	else {
		{ var $it56 = it.iterator();
		while( $it56.hasNext() ) { var x = $it56.next();
		if(cmp(x,elt)) return true;
		}}
	}
	return false;
}
Lambda.exists = function(it,f) {
	{ var $it57 = it.iterator();
	while( $it57.hasNext() ) { var x = $it57.next();
	if(f(x)) return true;
	}}
	return false;
}
Lambda.foreach = function(it,f) {
	{ var $it58 = it.iterator();
	while( $it58.hasNext() ) { var x = $it58.next();
	if(!f(x)) return false;
	}}
	return true;
}
Lambda.iter = function(it,f) {
	{ var $it59 = it.iterator();
	while( $it59.hasNext() ) { var x = $it59.next();
	f(x);
	}}
}
Lambda.filter = function(it,f) {
	var l = new List();
	{ var $it60 = it.iterator();
	while( $it60.hasNext() ) { var x = $it60.next();
	if(f(x)) l.add(x);
	}}
	return l;
}
Lambda.fold = function(it,f,first) {
	{ var $it61 = it.iterator();
	while( $it61.hasNext() ) { var x = $it61.next();
	first = f(x,first);
	}}
	return first;
}
Lambda.count = function(it) {
	var n = 0;
	{ var $it62 = it.iterator();
	while( $it62.hasNext() ) { var _ = $it62.next();
	++n;
	}}
	return n;
}
Lambda.empty = function(it) {
	return !it.iterator().hasNext();
}
Lambda.prototype.__class__ = Lambda;
xmpp.filter.FilterGroup = function(filters) { if( filters === $_ ) return; {
	List.apply(this,[]);
	if(filters != null) {
		{ var $it63 = filters.iterator();
		while( $it63.hasNext() ) { var f = $it63.next();
		this.add(f);
		}}
	}
}}
xmpp.filter.FilterGroup.__name__ = ["xmpp","filter","FilterGroup"];
xmpp.filter.FilterGroup.__super__ = List;
for(var k in List.prototype ) xmpp.filter.FilterGroup.prototype[k] = List.prototype[k];
xmpp.filter.FilterGroup.prototype.accept = function(p) {
	{ var $it64 = this.iterator();
	while( $it64.hasNext() ) { var f = $it64.next();
	{
		if(f.accept(p)) return true;
	}
	}}
	return false;
}
xmpp.filter.FilterGroup.prototype.__class__ = xmpp.filter.FilterGroup;
xmpp.SASL = function() { }
xmpp.SASL.__name__ = ["xmpp","SASL"];
xmpp.SASL.createAuthXml = function(mechansim,text) {
	if(mechansim == null) return null;
	var a = util.XmlUtil.createElement("auth",text);
	a.set("xmlns","urn:ietf:params:xml:ns:xmpp-sasl");
	a.set("mechanism",mechansim);
	return a;
}
xmpp.SASL.createResponseXml = function(t) {
	if(t == null) return null;
	var r = util.XmlUtil.createElement("response",t);
	r.set("xmlns","urn:ietf:params:xml:ns:xmpp-sasl");
	return r;
}
xmpp.SASL.parseMechanisms = function(x) {
	var m = new Array();
	{ var $it65 = x.elements();
	while( $it65.hasNext() ) { var e = $it65.next();
	{
		if(e.getNodeName() != "mechanism") continue;
		m.push(e.firstChild().getNodeValue());
	}
	}}
	return m;
}
xmpp.SASL.prototype.__class__ = xmpp.SASL;
jabber.BOSHConnection = function(host,path,hold,wait,secure,maxConcurrentRequests) { if( host === $_ ) return; {
	if(maxConcurrentRequests == null) maxConcurrentRequests = 2;
	if(secure == null) secure = false;
	if(wait == null) wait = 30;
	if(hold == null) hold = 1;
	jabber.stream.Connection.apply(this,[host]);
	this.path = path;
	this.hold = hold;
	this.wait = wait;
	this.secure = secure;
	this.maxConcurrentRequests = maxConcurrentRequests;
	this.initialized = false;
	this.pauseEnabled = false;
	this.pollingEnabled = true;
	this.timeoutOffset = 25;
}}
jabber.BOSHConnection.__name__ = ["jabber","BOSHConnection"];
jabber.BOSHConnection.__super__ = jabber.stream.Connection;
for(var k in jabber.stream.Connection.prototype ) jabber.BOSHConnection.prototype[k] = jabber.stream.Connection.prototype[k];
jabber.BOSHConnection.XMLNS = null;
jabber.BOSHConnection.XMLNS_XMPP = null;
jabber.BOSHConnection.prototype.cleanup = function() {
	this.timeoutTimer.stop();
	this.responseTimer.stop();
	this.connected = this.initialized = false;
	this.sid = null;
	this.requestCount = 0;
	this.requestQueue = null;
	this.responseQueue = null;
}
jabber.BOSHConnection.prototype.connect = function() {
	if(this.initialized && this.connected) {
		this.restart();
	}
	else {
		this.initialized = true;
		this.rid = Std["int"](Math.random() * 10000000);
		this.requestCount = 0;
		this.requestQueue = new Array();
		this.responseQueue = new Array();
		this.responseTimer = new haxe.Timer(1);
		var b = Xml.createElement("body");
		b.set("xml:lang","en");
		b.set("xmlns",jabber.BOSHConnection.XMLNS);
		b.set("xmlns:xmpp",jabber.BOSHConnection.XMLNS_XMPP);
		b.set("xmpp:version","1.0");
		b.set("ver","1.6");
		b.set("hold",Std.string(this.hold));
		b.set("rid",Std.string(this.rid));
		b.set("wait",Std.string(this.wait));
		b.set("to",this.host);
		b.set("secure",Std.string(this.secure));
		this.sendRequests(b);
	}
}
jabber.BOSHConnection.prototype.createRequest = function(t) {
	var x = Xml.createElement("body");
	x.set("xmlns",jabber.BOSHConnection.XMLNS);
	x.set("xml:lang","en");
	x.set("rid",Std.string(++this.rid));
	x.set("sid",this.sid);
	if(t != null) {
		{ var $it66 = t.iterator();
		while( $it66.hasNext() ) { var e = $it66.next();
		{
			x.addChild(Xml.createPCData(e));
		}
		}}
	}
	return x;
}
jabber.BOSHConnection.prototype.disconnect = function() {
	if(this.connected) {
		var r = this.createRequest();
		r.set("type","terminate");
		r.addChild(new xmpp.Presence(null,null,null,xmpp.PresenceType.unavailable).toXml());
		this.sendRequests(r);
		this.cleanup();
	}
}
jabber.BOSHConnection.prototype.getHTTPPath = function() {
	var b = new StringBuf();
	b.b[b.b.length] = "http";
	b.b[b.b.length] = "://";
	b.b[b.b.length] = this.path;
	return b.b.join("");
}
jabber.BOSHConnection.prototype.handleHTTPData = function(t) {
	var x = null;
	try {
		x = Xml.parse(t).firstElement();
	}
	catch( $e67 ) {
		{
			var e = $e67;
			{
				return;
			}
		}
	}
	if(x.get("xmlns") != jabber.BOSHConnection.XMLNS) {
		return;
	}
	this.requestCount--;
	if(this.timeoutTimer != null) {
		this.timeoutTimer.stop();
	}
	if(this.connected) {
		switch(x.get("type")) {
		case "terminate":{
			this.cleanup();
			this.__onDisconnect();
			return;
		}break;
		case "error":{
			return;
		}break;
		}
		var c = x.firstElement();
		if(c == null) {
			if(this.requestCount == 0) this.poll();
			else this.sendQueuedRequests();
			return;
		}
		{ var $it68 = x.elements();
		while( $it68.hasNext() ) { var e = $it68.next();
		{
			this.responseQueue.push(e);
		}
		}}
		this.resetResponseProcessor();
		if(this.requestCount == 0 && !this.sendQueuedRequests()) {
			if(this.responseQueue.length > 0) haxe.Timer.delay($closure(this,"poll"),0);
			else this.poll();
		}
	}
	else {
		if(!this.initialized) return;
		this.sid = x.get("sid");
		if(this.sid == null) {
			this.cleanup();
			this.__onError("Invalid SID");
			return;
		}
		this.wait = Std.parseInt(x.get("wait"));
		var t1 = null;
		t1 = x.get("maxpause");
		if(t1 != null) {
			this.maxPause = Std.parseInt(t1) * 1000;
			this.pauseEnabled = true;
		}
		t1 = null;
		t1 = x.get("requests");
		if(t1 != null) this.maxConcurrentRequests = Std.parseInt(t1);
		t1 = null;
		t1 = x.get("inactivity");
		if(t1 != null) this.inactivity = Std.parseInt(t1);
		this.__onConnect();
		this.connected = true;
		var b = haxe.io.Bytes.ofString(x.toString());
		this.__onData(b,0,b.length);
	}
}
jabber.BOSHConnection.prototype.handleHTTPError = function(e) {
	null;
	this.cleanup();
	this.__onError(e);
}
jabber.BOSHConnection.prototype.handlePauseTimeout = function() {
	this.pauseTimer.stop();
	this.pollingEnabled = true;
	this.poll();
}
jabber.BOSHConnection.prototype.handleTimeout = function() {
	this.timeoutTimer.stop();
	this.cleanup();
	this.__onError("BOSH timeout");
}
jabber.BOSHConnection.prototype.hold = null;
jabber.BOSHConnection.prototype.inactivity = null;
jabber.BOSHConnection.prototype.initialized = null;
jabber.BOSHConnection.prototype.maxConcurrentRequests = null;
jabber.BOSHConnection.prototype.maxPause = null;
jabber.BOSHConnection.prototype.path = null;
jabber.BOSHConnection.prototype.pause = function(secs) {
	if(secs == null) secs = this.inactivity;
	if(!this.pauseEnabled || secs > this.maxPause) return false;
	var r = this.createRequest();
	r.set("pause",Std.string(secs));
	this.sendRequests(r);
	this.pauseTimer = new haxe.Timer(secs * 1000);
	this.pauseTimer.run = $closure(this,"handlePauseTimeout");
	return true;
}
jabber.BOSHConnection.prototype.pauseEnabled = null;
jabber.BOSHConnection.prototype.pauseTimer = null;
jabber.BOSHConnection.prototype.poll = function() {
	if(!this.connected || !this.pollingEnabled || this.requestCount > 0 || this.sendQueuedRequests()) return;
	this.sendRequests(null,true);
}
jabber.BOSHConnection.prototype.pollingEnabled = null;
jabber.BOSHConnection.prototype.processResponse = function() {
	this.responseTimer.stop();
	var x = this.responseQueue.shift();
	var b = haxe.io.Bytes.ofString(x.toString());
	this.__onData(b,0,b.length);
	this.resetResponseProcessor();
}
jabber.BOSHConnection.prototype.requestCount = null;
jabber.BOSHConnection.prototype.requestQueue = null;
jabber.BOSHConnection.prototype.resetResponseProcessor = function() {
	if(this.responseQueue != null && this.responseQueue.length > 0) {
		this.responseTimer.stop();
		this.responseTimer = new haxe.Timer(0);
		this.responseTimer.run = $closure(this,"processResponse");
	}
}
jabber.BOSHConnection.prototype.responseQueue = null;
jabber.BOSHConnection.prototype.responseTimer = null;
jabber.BOSHConnection.prototype.restart = function() {
	var r = this.createRequest();
	r.set("xmpp:restart","true");
	r.set("xmlns:xmpp",jabber.BOSHConnection.XMLNS_XMPP);
	r.set("xmlns",jabber.BOSHConnection.XMLNS);
	r.set("xml:lang","en");
	r.set("to",this.host);
	this.sendRequests(r);
}
jabber.BOSHConnection.prototype.rid = null;
jabber.BOSHConnection.prototype.secure = null;
jabber.BOSHConnection.prototype.sendQueuedRequests = function(t) {
	if(t != null) this.requestQueue.push(t);
	else if(this.requestQueue.length == 0) return false;
	return this.sendRequests(null);
}
jabber.BOSHConnection.prototype.sendRequests = function(t,poll) {
	if(poll == null) poll = false;
	if(this.requestCount >= this.maxConcurrentRequests) {
		return false;
	}
	this.requestCount++;
	if(t == null) {
		if(poll) {
			t = this.createRequest();
		}
		else {
			var i = 0;
			var tmp = new Array();
			while(i++ < 10 && this.requestQueue.length > 0) tmp.push(this.requestQueue.shift());
			t = this.createRequest(tmp);
		}
	}
	var r = new haxe.Http(this.getHTTPPath());
	r.onError = $closure(this,"handleHTTPError");
	r.onData = $closure(this,"handleHTTPData");
	r.setPostData(t.toString());
	r.request(true);
	if(this.timeoutTimer != null) this.timeoutTimer.stop();
	this.timeoutTimer = new haxe.Timer((this.wait * 1000) + (this.timeoutOffset * 1000));
	this.timeoutTimer.run = $closure(this,"handleTimeout");
	return true;
}
jabber.BOSHConnection.prototype.sid = null;
jabber.BOSHConnection.prototype.timeoutOffset = null;
jabber.BOSHConnection.prototype.timeoutTimer = null;
jabber.BOSHConnection.prototype.wait = null;
jabber.BOSHConnection.prototype.write = function(t) {
	this.sendQueuedRequests(t);
	return true;
}
jabber.BOSHConnection.prototype.__class__ = jabber.BOSHConnection;
if(!event._Dispatcher) event._Dispatcher = {}
event._Dispatcher.EventException = { __ename__ : ["event","_Dispatcher","EventException"], __constructs__ : ["StopPropagation"] }
event._Dispatcher.EventException.StopPropagation = ["StopPropagation",0];
event._Dispatcher.EventException.StopPropagation.toString = $estr;
event._Dispatcher.EventException.StopPropagation.__enum__ = event._Dispatcher.EventException;
xmpp.roster.Item = function(jid,subscription,name,askType,groups) { if( jid === $_ ) return; {
	this.jid = jid;
	this.subscription = subscription;
	this.name = name;
	this.askType = askType;
	this.groups = ((groups != null)?groups:new List());
}}
xmpp.roster.Item.__name__ = ["xmpp","roster","Item"];
xmpp.roster.Item.parse = function(x) {
	var i = new xmpp.roster.Item(x.get("jid"));
	i.subscription = Type.createEnum(xmpp.roster.Subscription,x.get("subscription"));
	i.name = x.get("name");
	if(x.exists("ask")) i.askType = Type.createEnum(xmpp.roster.AskType,x.get("ask"));
	{ var $it69 = x.elementsNamed("group");
	while( $it69.hasNext() ) { var g = $it69.next();
	i.groups.add(g.firstChild().getNodeValue());
	}}
	return i;
}
xmpp.roster.Item.prototype.askType = null;
xmpp.roster.Item.prototype.groups = null;
xmpp.roster.Item.prototype.jid = null;
xmpp.roster.Item.prototype.name = null;
xmpp.roster.Item.prototype.subscription = null;
xmpp.roster.Item.prototype.toString = function() {
	return this.toXml().toString();
}
xmpp.roster.Item.prototype.toXml = function() {
	var x = Xml.createElement("item");
	x.set("jid",this.jid);
	if(this.name != null) x.set("name",this.name);
	if(this.subscription != null) x.set("subscription",Type.enumConstructor(this.subscription));
	if(this.askType != null) x.set("ask",Type.enumConstructor(this.askType));
	{ var $it70 = this.groups.iterator();
	while( $it70.hasNext() ) { var group = $it70.next();
	x.addChild(util.XmlUtil.createElement("group",group));
	}}
	return x;
}
xmpp.roster.Item.prototype.__class__ = xmpp.roster.Item;
xmpp.MessageType = { __ename__ : ["xmpp","MessageType"], __constructs__ : ["normal","error","chat","groupchat","headline"] }
xmpp.MessageType.chat = ["chat",2];
xmpp.MessageType.chat.toString = $estr;
xmpp.MessageType.chat.__enum__ = xmpp.MessageType;
xmpp.MessageType.error = ["error",1];
xmpp.MessageType.error.toString = $estr;
xmpp.MessageType.error.__enum__ = xmpp.MessageType;
xmpp.MessageType.groupchat = ["groupchat",3];
xmpp.MessageType.groupchat.toString = $estr;
xmpp.MessageType.groupchat.__enum__ = xmpp.MessageType;
xmpp.MessageType.headline = ["headline",4];
xmpp.MessageType.headline.toString = $estr;
xmpp.MessageType.headline.__enum__ = xmpp.MessageType;
xmpp.MessageType.normal = ["normal",0];
xmpp.MessageType.normal.toString = $estr;
xmpp.MessageType.normal.__enum__ = xmpp.MessageType;
xmpp.Message = function(to,body,subject,type,thread,from) { if( to === $_ ) return; {
	this._type = xmpp.PacketType.message;
	xmpp.Packet.apply(this,[to,from]);
	this.type = (type != null?type:xmpp.MessageType.chat);
	this.body = body;
	this.subject = subject;
	this.thread = thread;
}}
xmpp.Message.__name__ = ["xmpp","Message"];
xmpp.Message.__super__ = xmpp.Packet;
for(var k in xmpp.Packet.prototype ) xmpp.Message.prototype[k] = xmpp.Packet.prototype[k];
xmpp.Message.parse = function(x) {
	var m = new xmpp.Message(null,null,null,(x.exists("type")?Type.createEnum(xmpp.MessageType,x.get("type")):null));
	xmpp.Packet.parseAttributes(m,x);
	{ var $it71 = x.elements();
	while( $it71.hasNext() ) { var c = $it71.next();
	{
		switch(c.getNodeName()) {
		case "subject":{
			m.subject = c.firstChild().getNodeValue();
		}break;
		case "body":{
			m.body = c.firstChild().getNodeValue();
		}break;
		case "thread":{
			m.thread = c.firstChild().getNodeValue();
		}break;
		default:{
			m.properties.push(c);
		}break;
		}
	}
	}}
	return m;
}
xmpp.Message.prototype.body = null;
xmpp.Message.prototype.subject = null;
xmpp.Message.prototype.thread = null;
xmpp.Message.prototype.toXml = function() {
	var x = xmpp.Packet.prototype.addAttributes.apply(this,[Xml.createElement("message")]);
	if(this.type != null) x.set("type",Type.enumConstructor(this.type));
	if(this.subject != null) x.addChild(util.XmlUtil.createElement("subject",this.subject));
	if(this.body != null) x.addChild(util.XmlUtil.createElement("body",this.body));
	if(this.thread != null) x.addChild(util.XmlUtil.createElement("thread",this.thread));
	{
		var _g = 0, _g1 = this.properties;
		while(_g < _g1.length) {
			var p = _g1[_g];
			++_g;
			x.addChild(p);
		}
	}
	return x;
}
xmpp.Message.prototype.type = null;
xmpp.Message.prototype.__class__ = xmpp.Message;
if(!haxe.io) haxe.io = {}
haxe.io.Bytes = function(length,b) { if( length === $_ ) return; {
	this.length = length;
	this.b = b;
}}
haxe.io.Bytes.__name__ = ["haxe","io","Bytes"];
haxe.io.Bytes.alloc = function(length) {
	var a = new Array();
	{
		var _g = 0;
		while(_g < length) {
			var i = _g++;
			a.push(0);
		}
	}
	return new haxe.io.Bytes(length,a);
}
haxe.io.Bytes.ofString = function(s) {
	var a = new Array();
	{
		var _g1 = 0, _g = s.length;
		while(_g1 < _g) {
			var i = _g1++;
			var c = s["cca"](i);
			if(c <= 127) a.push(c);
			else if(c <= 2047) {
				a.push(192 | (c >> 6));
				a.push(128 | (c & 63));
			}
			else if(c <= 65535) {
				a.push(224 | (c >> 12));
				a.push(128 | ((c >> 6) & 63));
				a.push(128 | (c & 63));
			}
			else {
				a.push(240 | (c >> 18));
				a.push(128 | ((c >> 12) & 63));
				a.push(128 | ((c >> 6) & 63));
				a.push(128 | (c & 63));
			}
		}
	}
	return new haxe.io.Bytes(a.length,a);
}
haxe.io.Bytes.ofData = function(b) {
	return new haxe.io.Bytes(b.length,b);
}
haxe.io.Bytes.prototype.b = null;
haxe.io.Bytes.prototype.blit = function(pos,src,srcpos,len) {
	if(pos < 0 || srcpos < 0 || len < 0 || pos + len > this.length || srcpos + len > src.length) throw haxe.io.Error.OutsideBounds;
	var b1 = this.b;
	var b2 = src.b;
	if(b1 == b2 && pos > srcpos) {
		var i = len;
		while(i > 0) {
			i--;
			b1[i + pos] = b2[i + srcpos];
		}
		return;
	}
	{
		var _g = 0;
		while(_g < len) {
			var i = _g++;
			b1[i + pos] = b2[i + srcpos];
		}
	}
}
haxe.io.Bytes.prototype.compare = function(other) {
	var b1 = this.b;
	var b2 = other.b;
	var len = ((this.length < other.length)?this.length:other.length);
	{
		var _g = 0;
		while(_g < len) {
			var i = _g++;
			if(b1[i] != b2[i]) return b1[i] - b2[i];
		}
	}
	return this.length - other.length;
}
haxe.io.Bytes.prototype.get = function(pos) {
	return this.b[pos];
}
haxe.io.Bytes.prototype.getData = function() {
	return this.b;
}
haxe.io.Bytes.prototype.length = null;
haxe.io.Bytes.prototype.readString = function(pos,len) {
	if(pos < 0 || len < 0 || pos + len > this.length) throw haxe.io.Error.OutsideBounds;
	var s = "";
	var b = this.b;
	var fcc = $closure(String,"fromCharCode");
	var i = pos;
	var max = pos + len;
	while(i < max) {
		var c = b[i++];
		if(c < 128) {
			if(c == 0) break;
			s += fcc(c);
		}
		else if(c < 224) s += fcc(((c & 63) << 6) | (b[i++] & 127));
		else if(c < 240) {
			var c2 = b[i++];
			s += fcc((((c & 31) << 12) | ((c2 & 127) << 6)) | (b[i++] & 127));
		}
		else {
			var c2 = b[i++];
			var c3 = b[i++];
			s += fcc(((((c & 15) << 18) | ((c2 & 127) << 12)) | ((c3 << 6) & 127)) | (b[i++] & 127));
		}
	}
	return s;
}
haxe.io.Bytes.prototype.set = function(pos,v) {
	this.b[pos] = (v & 255);
}
haxe.io.Bytes.prototype.sub = function(pos,len) {
	if(pos < 0 || len < 0 || pos + len > this.length) throw haxe.io.Error.OutsideBounds;
	return new haxe.io.Bytes(len,this.b.slice(pos,pos + len));
}
haxe.io.Bytes.prototype.toString = function() {
	return this.readString(0,this.length);
}
haxe.io.Bytes.prototype.__class__ = haxe.io.Bytes;
util.Base64 = function() { }
util.Base64.__name__ = ["util","Base64"];
util.Base64.CHARS = null;
util.Base64.bc = null;
util.Base64.fillNullbits = function(s) {
	while(s.length % 3 != 0) s += "=";
	return s;
}
util.Base64.removeNullbits = function(s) {
	while(s.charAt(s.length - 1) == "=") s = s.substr(0,s.length - 1);
	return s;
}
util.Base64.encode = function(t) {
	return util.Base64.fillNullbits(util.Base64.bc.encodeString(t));
}
util.Base64.decode = function(t) {
	return util.Base64.bc.decodeString(util.Base64.removeNullbits(t));
}
util.Base64.random = function(len) {
	if(len == null) len = 1;
	var b = new StringBuf();
	var bits = 0;
	var bitcount = 0;
	var i = 0;
	while(i < len) {
		bits = Std["int"](Math.random() * util.Base64.CHARS.length);
		b.b[b.b.length] = util.Base64.CHARS.charAt(bits & 63);
		bits >>= 6;
		bitcount -= 6;
		i++;
	}
	return b.b.join("");
}
util.Base64.prototype.__class__ = util.Base64;
xmpp.Roster = function(items) { if( items === $_ ) return; {
	List.apply(this,[]);
	if(items != null) { var $it72 = items.iterator();
	while( $it72.hasNext() ) { var i = $it72.next();
	this.add(i);
	}}
}}
xmpp.Roster.__name__ = ["xmpp","Roster"];
xmpp.Roster.__super__ = List;
for(var k in List.prototype ) xmpp.Roster.prototype[k] = List.prototype[k];
xmpp.Roster.parse = function(x) {
	var r = new xmpp.Roster();
	{ var $it73 = x.elementsNamed("item");
	while( $it73.hasNext() ) { var e = $it73.next();
	r.add(xmpp.roster.Item.parse(e));
	}}
	return r;
}
xmpp.Roster.prototype.toString = function() {
	return this.toXml().toString();
}
xmpp.Roster.prototype.toXml = function() {
	var x = xmpp.IQ.createQueryXml("jabber:iq:roster");
	{ var $it74 = this.iterator();
	while( $it74.hasNext() ) { var i = $it74.next();
	x.addChild(i.toXml());
	}}
	return x;
}
xmpp.Roster.prototype.__class__ = xmpp.Roster;
Hash = function(p) { if( p === $_ ) return; {
	this.h = {}
	if(this.h.__proto__ != null) {
		this.h.__proto__ = null;
		delete(this.h.__proto__);
	}
	else null;
}}
Hash.__name__ = ["Hash"];
Hash.prototype.exists = function(key) {
	try {
		key = "$" + key;
		return this.hasOwnProperty.call(this.h,key);
	}
	catch( $e75 ) {
		{
			var e = $e75;
			{
				
				for(var i in this.h)
					if( i == key ) return true;
			;
				return false;
			}
		}
	}
}
Hash.prototype.get = function(key) {
	return this.h["$" + key];
}
Hash.prototype.h = null;
Hash.prototype.iterator = function() {
	return { ref : this.h, it : this.keys(), hasNext : function() {
		return this.it.hasNext();
	}, next : function() {
		var i = this.it.next();
		return this.ref["$" + i];
	}}
}
Hash.prototype.keys = function() {
	var a = new Array();
	
			for(var i in this.h)
				a.push(i.substr(1));
		;
	return a.iterator();
}
Hash.prototype.remove = function(key) {
	if(!this.exists(key)) return false;
	delete(this.h["$" + key]);
	return true;
}
Hash.prototype.set = function(key,value) {
	this.h["$" + key] = value;
}
Hash.prototype.toString = function() {
	var s = new StringBuf();
	s.b[s.b.length] = "{";
	var it = this.keys();
	{ var $it76 = it;
	while( $it76.hasNext() ) { var i = $it76.next();
	{
		s.b[s.b.length] = i;
		s.b[s.b.length] = " => ";
		s.b[s.b.length] = Std.string(this.get(i));
		if(it.hasNext()) s.b[s.b.length] = ", ";
	}
	}}
	s.b[s.b.length] = "}";
	return s.b.join("");
}
Hash.prototype.__class__ = Hash;
if(!jabber._Stream) jabber._Stream = {}
jabber._Stream.StreamFeatures = function(p) { if( p === $_ ) return; {
	this.l = new List();
}}
jabber._Stream.StreamFeatures.__name__ = ["jabber","_Stream","StreamFeatures"];
jabber._Stream.StreamFeatures.prototype.add = function(f) {
	if(Lambda.has(this.l,f)) return false;
	this.l.add(f);
	return true;
}
jabber._Stream.StreamFeatures.prototype.iterator = function() {
	return this.l.iterator();
}
jabber._Stream.StreamFeatures.prototype.l = null;
jabber._Stream.StreamFeatures.prototype.__class__ = jabber._Stream.StreamFeatures;
jabber.XMPPError = function(dispatcher,p) { if( dispatcher === $_ ) return; {
	var e = p.errors[0];
	if(e == null) throw "Packet has no errors";
	xmpp.Error.apply(this,[e.type,e.code,e.name,e.text]);
	this.dispatcher = dispatcher;
	this.from = p.from;
}}
jabber.XMPPError.__name__ = ["jabber","XMPPError"];
jabber.XMPPError.__super__ = xmpp.Error;
for(var k in xmpp.Error.prototype ) jabber.XMPPError.prototype[k] = xmpp.Error.prototype[k];
jabber.XMPPError.prototype.dispatcher = null;
jabber.XMPPError.prototype.from = null;
jabber.XMPPError.prototype.__class__ = jabber.XMPPError;
Std = function() { }
Std.__name__ = ["Std"];
Std["is"] = function(v,t) {
	return js.Boot.__instanceof(v,t);
}
Std.string = function(s) {
	return js.Boot.__string_rec(s,"");
}
Std["int"] = function(x) {
	if(x < 0) return Math.ceil(x);
	return Math.floor(x);
}
Std.parseInt = function(x) {
	var v = parseInt(x);
	if(Math.isNaN(v)) return null;
	return v;
}
Std.parseFloat = function(x) {
	return parseFloat(x);
}
Std.random = function(x) {
	return Math.floor(Math.random() * x);
}
Std.prototype.__class__ = Std;
if(typeof net=='undefined') net = {}
if(!net.sasl) net.sasl = {}
net.sasl.PlainMechanism = function(p) { if( p === $_ ) return; {
	this.id = net.sasl.PlainMechanism.ID;
}}
net.sasl.PlainMechanism.__name__ = ["net","sasl","PlainMechanism"];
net.sasl.PlainMechanism.ID = null;
net.sasl.PlainMechanism.prototype.createAuthenticationText = function(username,host,password) {
	var b = new StringBuf();
	b.b[b.b.length] = username;
	b.b[b.b.length] = "@";
	b.b[b.b.length] = host;
	b.b[b.b.length] = String.fromCharCode(0);
	b.b[b.b.length] = username;
	b.b[b.b.length] = String.fromCharCode(0);
	b.b[b.b.length] = password;
	return b.b.join("");
}
net.sasl.PlainMechanism.prototype.createChallengeResponse = function(c) {
	return null;
}
net.sasl.PlainMechanism.prototype.id = null;
net.sasl.PlainMechanism.prototype.__class__ = net.sasl.PlainMechanism;
xmpp.filter.PacketIDFilter = function(id) { if( id === $_ ) return; {
	this.id = id;
}}
xmpp.filter.PacketIDFilter.__name__ = ["xmpp","filter","PacketIDFilter"];
xmpp.filter.PacketIDFilter.prototype.accept = function(p) {
	return p.id == this.id;
}
xmpp.filter.PacketIDFilter.prototype.id = null;
xmpp.filter.PacketIDFilter.prototype.__class__ = xmpp.filter.PacketIDFilter;
if(typeof crypt=='undefined') crypt = {}
crypt.SHA1 = function(p) { if( p === $_ ) return; {
	null;
}}
crypt.SHA1.__name__ = ["crypt","SHA1"];
crypt.SHA1.encode = function(t) {
	return new crypt.SHA1().__encode__(t);
}
crypt.SHA1.prototype.__encode__ = function(s) {
	var x = this.str2blks(s);
	var w = new Array();
	var a = 1732584193;
	var b = -271733879;
	var c = -1732584194;
	var d = 271733878;
	var e = -1009589776;
	var i = 0;
	while(i < x.length) {
		var olda = a;
		var oldb = b;
		var oldc = c;
		var oldd = d;
		var olde = e;
		var j = 0;
		while(j < 80) {
			if(j < 16) w[j] = x[i + j];
			else w[j] = this.rol(((w[j - 3] ^ w[j - 8]) ^ w[j - 14]) ^ w[j - 16],1);
			var t = this.add(this.add((a << 5) | (a >>> 27),this.ft(j,b,c,d)),this.add(this.add(e,w[j]),this.kt(j)));
			e = d;
			d = c;
			c = ((b << 30) | (b >>> 2));
			b = a;
			a = t;
			j++;
		}
		a = this.add(a,olda);
		b = this.add(b,oldb);
		c = this.add(c,oldc);
		d = this.add(d,oldd);
		e = this.add(e,olde);
		i += 16;
	}
	return this.hex(a) + this.hex(b) + this.hex(c) + this.hex(d) + this.hex(e);
}
crypt.SHA1.prototype.add = function(x,y) {
	var lsw = (x & 65535) + (y & 65535);
	var msw = (x >> 16) + (y >> 16) + (lsw >> 16);
	return (msw << 16) | (lsw & 65535);
}
crypt.SHA1.prototype.ft = function(t,b,c,d) {
	if(t < 20) return (b & c) | ((~b) & d);
	if(t < 40) return (b ^ c) ^ d;
	if(t < 60) return ((b & c) | (b & d)) | (c & d);
	return (b ^ c) ^ d;
}
crypt.SHA1.prototype.hex = function(n) {
	var s = "";
	var j = 7;
	while(j >= 0) {
		s += "0123456789abcdef".charAt((n >> (j * 4)) & 15);
		j--;
	}
	return s;
}
crypt.SHA1.prototype.kt = function(t) {
	return ((t < 20)?1518500249:((t < 40)?1859775393:((t < 60)?-1894007588:-899497514)));
}
crypt.SHA1.prototype.rol = function(n,c) {
	return (n << c) | (n >>> (32 - c));
}
crypt.SHA1.prototype.str2blks = function(s) {
	var nb = ((s.length + 8) >> 6) + 1;
	var l = nb * 16;
	var bb = new Array();
	var i = 0;
	while(i < l) {
		bb[i] = 0;
		i++;
	}
	i = 0;
	while(i < s.length) {
		bb[i >> 2] |= s.charCodeAt(i) << (24 - (i % 4) * 8);
		i++;
	}
	bb[i >> 2] |= 128 << (24 - (i % 4) * 8);
	bb[nb * 16 - 1] = s.length * 8;
	return bb;
}
crypt.SHA1.prototype.__class__ = crypt.SHA1;
jabber.StreamStatus = { __ename__ : ["jabber","StreamStatus"], __constructs__ : ["closed","pending","open"] }
jabber.StreamStatus.closed = ["closed",0];
jabber.StreamStatus.closed.toString = $estr;
jabber.StreamStatus.closed.__enum__ = jabber.StreamStatus;
jabber.StreamStatus.open = ["open",2];
jabber.StreamStatus.open.toString = $estr;
jabber.StreamStatus.open.__enum__ = jabber.StreamStatus;
jabber.StreamStatus.pending = ["pending",1];
jabber.StreamStatus.pending.toString = $estr;
jabber.StreamStatus.pending.__enum__ = jabber.StreamStatus;
jabber.JID = function(str) { if( str === $_ ) return; {
	if(str != null) {
		if(!jabber.JIDUtil.isValid(str)) throw "Invalid JID: " + str;
		this.node = str.substr(0,str.indexOf("@"));
		this.domain = jabber.JIDUtil.parseDomain(str);
		this.resource = jabber.JIDUtil.parseResource(str);
	}
}}
jabber.JID.__name__ = ["jabber","JID"];
jabber.JID.prototype.bare = null;
jabber.JID.prototype.domain = null;
jabber.JID.prototype.getBare = function() {
	return ((this.node == null || this.domain == null)?null:this.node + "@" + this.domain);
}
jabber.JID.prototype.node = null;
jabber.JID.prototype.resource = null;
jabber.JID.prototype.toString = function() {
	var j = this.getBare();
	if(j == null) return null;
	return ((this.resource == null)?j:j += "/" + this.resource);
}
jabber.JID.prototype.__class__ = jabber.JID;
xmpp.PlainPacket = function(src) { if( src === $_ ) return; {
	xmpp.Packet.apply(this,[]);
	this._type = xmpp.PacketType.custom;
	this.src = src;
}}
xmpp.PlainPacket.__name__ = ["xmpp","PlainPacket"];
xmpp.PlainPacket.__super__ = xmpp.Packet;
for(var k in xmpp.Packet.prototype ) xmpp.PlainPacket.prototype[k] = xmpp.Packet.prototype[k];
xmpp.PlainPacket.prototype.src = null;
xmpp.PlainPacket.prototype.toXml = function() {
	return this.src;
}
xmpp.PlainPacket.prototype.__class__ = xmpp.PlainPacket;
haxe.io.Error = { __ename__ : ["haxe","io","Error"], __constructs__ : ["Blocked","Overflow","OutsideBounds","Custom"] }
haxe.io.Error.Blocked = ["Blocked",0];
haxe.io.Error.Blocked.toString = $estr;
haxe.io.Error.Blocked.__enum__ = haxe.io.Error;
haxe.io.Error.Custom = function(e) { var $x = ["Custom",3,e]; $x.__enum__ = haxe.io.Error; $x.toString = $estr; return $x; }
haxe.io.Error.OutsideBounds = ["OutsideBounds",2];
haxe.io.Error.OutsideBounds.toString = $estr;
haxe.io.Error.OutsideBounds.__enum__ = haxe.io.Error;
haxe.io.Error.Overflow = ["Overflow",1];
haxe.io.Error.Overflow.toString = $estr;
haxe.io.Error.Overflow.__enum__ = haxe.io.Error;
net.sasl.Handshake = function(p) { if( p === $_ ) return; {
	this.mechanisms = new Array();
}}
net.sasl.Handshake.__name__ = ["net","sasl","Handshake"];
net.sasl.Handshake.prototype.getAuthenticationText = function(username,host,password) {
	if(this.mechanism == null) return null;
	return this.mechanism.createAuthenticationText(username,host,password);
}
net.sasl.Handshake.prototype.getChallengeResponse = function(challenge) {
	if(this.mechanism == null) return null;
	return this.mechanism.createChallengeResponse(challenge);
}
net.sasl.Handshake.prototype.mechanism = null;
net.sasl.Handshake.prototype.mechanisms = null;
net.sasl.Handshake.prototype.__class__ = net.sasl.Handshake;
js.Lib = function() { }
js.Lib.__name__ = ["js","Lib"];
js.Lib.isIE = null;
js.Lib.isOpera = null;
js.Lib.document = null;
js.Lib.window = null;
js.Lib.alert = function(v) {
	alert(js.Boot.__string_rec(v,""));
}
js.Lib.eval = function(code) {
	return eval(code);
}
js.Lib.setErrorHandler = function(f) {
	js.Lib.onerror = f;
}
js.Lib.prototype.__class__ = js.Lib;
xmpp.ErrorType = { __ename__ : ["xmpp","ErrorType"], __constructs__ : ["auth","cancel","continue_","modify","wait"] }
xmpp.ErrorType.auth = ["auth",0];
xmpp.ErrorType.auth.toString = $estr;
xmpp.ErrorType.auth.__enum__ = xmpp.ErrorType;
xmpp.ErrorType.cancel = ["cancel",1];
xmpp.ErrorType.cancel.toString = $estr;
xmpp.ErrorType.cancel.__enum__ = xmpp.ErrorType;
xmpp.ErrorType.continue_ = ["continue_",2];
xmpp.ErrorType.continue_.toString = $estr;
xmpp.ErrorType.continue_.__enum__ = xmpp.ErrorType;
xmpp.ErrorType.modify = ["modify",3];
xmpp.ErrorType.modify.toString = $estr;
xmpp.ErrorType.modify.__enum__ = xmpp.ErrorType;
xmpp.ErrorType.wait = ["wait",4];
xmpp.ErrorType.wait.toString = $estr;
xmpp.ErrorType.wait.__enum__ = xmpp.ErrorType;
xmpp.Stream = function() { }
xmpp.Stream.__name__ = ["xmpp","Stream"];
xmpp.Stream.createOpenStream = function(xmlns,to,version,lang,xmlHeader) {
	if(xmlHeader == null) xmlHeader = true;
	var b = new StringBuf();
	b.b[b.b.length] = "<stream:stream xmlns=\"";
	b.b[b.b.length] = xmlns;
	b.b[b.b.length] = "\" xmlns:stream=\"" + "http://etherx.jabber.org/streams" + "\" to=\"";
	b.b[b.b.length] = to;
	b.b[b.b.length] = "\" xmlns:xml=\"http://www.w3.org/XML/1998/namespace\" ";
	if(version) b.b[b.b.length] = "version=\"1.0\" ";
	if(lang != null) {
		b.b[b.b.length] = "xml:lang=\"";
		b.b[b.b.length] = lang;
		b.b[b.b.length] = "\"";
	}
	b.b[b.b.length] = ">";
	return ((xmlHeader)?util.XmlUtil.XML_HEADER + b.b.join(""):b.b.join(""));
}
xmpp.Stream.prototype.__class__ = xmpp.Stream;
StringTools = function() { }
StringTools.__name__ = ["StringTools"];
StringTools.urlEncode = function(s) {
	return encodeURIComponent(s);
}
StringTools.urlDecode = function(s) {
	return decodeURIComponent(s.split("+").join(" "));
}
StringTools.htmlEscape = function(s) {
	return s.split("&").join("&amp;").split("<").join("&lt;").split(">").join("&gt;");
}
StringTools.htmlUnescape = function(s) {
	return s.split("&gt;").join(">").split("&lt;").join("<").split("&amp;").join("&");
}
StringTools.startsWith = function(s,start) {
	return (s.length >= start.length && s.substr(0,start.length) == start);
}
StringTools.endsWith = function(s,end) {
	var elen = end.length;
	var slen = s.length;
	return (slen >= elen && s.substr(slen - elen,elen) == end);
}
StringTools.isSpace = function(s,pos) {
	var c = s.charCodeAt(pos);
	return (c >= 9 && c <= 13) || c == 32;
}
StringTools.ltrim = function(s) {
	var l = s.length;
	var r = 0;
	while(r < l && StringTools.isSpace(s,r)) {
		r++;
	}
	if(r > 0) return s.substr(r,l - r);
	else return s;
}
StringTools.rtrim = function(s) {
	var l = s.length;
	var r = 0;
	while(r < l && StringTools.isSpace(s,l - r - 1)) {
		r++;
	}
	if(r > 0) {
		return s.substr(0,l - r);
	}
	else {
		return s;
	}
}
StringTools.trim = function(s) {
	return StringTools.ltrim(StringTools.rtrim(s));
}
StringTools.rpad = function(s,c,l) {
	var sl = s.length;
	var cl = c.length;
	while(sl < l) {
		if(l - sl < cl) {
			s += c.substr(0,l - sl);
			sl = l;
		}
		else {
			s += c;
			sl += cl;
		}
	}
	return s;
}
StringTools.lpad = function(s,c,l) {
	var ns = "";
	var sl = s.length;
	if(sl >= l) return s;
	var cl = c.length;
	while(sl < l) {
		if(l - sl < cl) {
			ns += c.substr(0,l - sl);
			sl = l;
		}
		else {
			ns += c;
			sl += cl;
		}
	}
	return ns + s;
}
StringTools.replace = function(s,sub,by) {
	return s.split(sub).join(by);
}
StringTools.hex = function(n,digits) {
	var neg = false;
	if(n < 0) {
		neg = true;
		n = -n;
	}
	var s = n.toString(16);
	s = s.toUpperCase();
	if(digits != null) while(s.length < digits) s = "0" + s;
	if(neg) s = "-" + s;
	return s;
}
StringTools.prototype.__class__ = StringTools;
$_ = {}
js.Boot.__res = {}
js.Boot.__init();
{
	js["XMLHttpRequest"] = (window.XMLHttpRequest?XMLHttpRequest:(window.ActiveXObject?function() {
		try {
			return new ActiveXObject("Msxml2.XMLHTTP");
		}
		catch( $e77 ) {
			{
				var e = $e77;
				{
					try {
						return new ActiveXObject("Microsoft.XMLHTTP");
					}
					catch( $e78 ) {
						{
							var e1 = $e78;
							{
								throw "Unable to create XMLHttpRequest object.";
							}
						}
					}
				}
			}
		}
	}:(function($this) {
		var $r;
		throw "Unable to create XMLHttpRequest object.";
		return $r;
	}(this))));
}
{
	Math.NaN = Number["NaN"];
	Math.NEGATIVE_INFINITY = Number["NEGATIVE_INFINITY"];
	Math.POSITIVE_INFINITY = Number["POSITIVE_INFINITY"];
	Math.isFinite = function(i) {
		return isFinite(i);
	}
	Math.isNaN = function(i) {
		return isNaN(i);
	}
	Math.__name__ = ["Math"];
}
{
	Xml = js.JsXml__;
	Xml.__name__ = ["Xml"];
	Xml.Element = "element";
	Xml.PCData = "pcdata";
	Xml.CData = "cdata";
	Xml.Comment = "comment";
	Xml.DocType = "doctype";
	Xml.Prolog = "prolog";
	Xml.Document = "document";
}
{
	jabber.BOSHConnection.XMLNS = "http://jabber.org/protocol/httpbind";
	jabber.BOSHConnection.XMLNS_XMPP = "urn:xmpp:xbosh";
}
{
	util.Base64.CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
	util.Base64.bc = new haxe.BaseCode(haxe.io.Bytes.ofString(util.Base64.CHARS));
}
{
	String.prototype.__class__ = String;
	String.__name__ = ["String"];
	Array.prototype.__class__ = Array;
	Array.__name__ = ["Array"];
	Int = { __name__ : ["Int"]}
	Dynamic = { __name__ : ["Dynamic"]}
	Float = Number;
	Float.__name__ = ["Float"];
	Bool = { __ename__ : ["Bool"]}
	Class = { __name__ : ["Class"]}
	Enum = { }
	Void = { __ename__ : ["Void"]}
}
{
	net.sasl.PlainMechanism.ID = "PLAIN";
}
{
	js.Lib.document = document;
	js.Lib.window = window;
	onerror = function(msg,url,line) {
		var f = js.Lib.onerror;
		if( f == null )
			return false;
		return f(msg,[url+":"+line]);
	}
}
{
	Date.now = function() {
		return new Date();
	}
	Date.fromTime = function(t) {
		var d = new Date();
		d["setTime"](t);
		return d;
	}
	Date.fromString = function(s) {
		switch(s.length) {
		case 8:{
			var k = s.split(":");
			var d = new Date();
			d["setTime"](0);
			d["setUTCHours"](k[0]);
			d["setUTCMinutes"](k[1]);
			d["setUTCSeconds"](k[2]);
			return d;
		}break;
		case 10:{
			var k = s.split("-");
			return new Date(k[0],k[1] - 1,k[2],0,0,0);
		}break;
		case 19:{
			var k = s.split(" ");
			var y = k[0].split("-");
			var t = k[1].split(":");
			return new Date(y[0],y[1] - 1,y[2],t[0],t[1],t[2]);
		}break;
		default:{
			throw "Invalid date format : " + s;
		}break;
		}
	}
	Date.prototype["toString"] = function() {
		var date = this;
		var m = date.getMonth() + 1;
		var d = date.getDate();
		var h = date.getHours();
		var mi = date.getMinutes();
		var s = date.getSeconds();
		return date.getFullYear() + "-" + ((m < 10?"0" + m:"" + m)) + "-" + ((d < 10?"0" + d:"" + d)) + " " + ((h < 10?"0" + h:"" + h)) + ":" + ((mi < 10?"0" + mi:"" + mi)) + ":" + ((s < 10?"0" + s:"" + s));
	}
	Date.prototype.__class__ = Date;
	Date.__name__ = ["Date"];
}
util.XmlUtil.XML_HEADER = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>";
jabber.client.Roster.defaultSubscriptionMode = jabber.client.RosterSubscriptionMode.manual;
jabber.JIDUtil.MAX_PARTSIZE = 1023;
jabber.JIDUtil.EREG = new EReg("[A-Z0-9._%-]+@[A-Z0-9.-]+\\.[A-Z]{3}?(/[A-Z0-9._%-])?","i");
xmpp.Bind.XMLNS = "urn:ietf:params:xml:ns:xmpp-bind";
xmpp.VCard.NODENAME = "vCard";
xmpp.VCard.XMLNS = "vcard-temp";
xmpp.VCard.PRODID = "-//HandGen//NONSGML vGen v1.0//EN";
xmpp.VCard.VERSION = "2.0";
xmpp.Error.XMLNS = "urn:ietf:params:xml:ns:xmpp-stanzas";
jabber.stream.PacketTimeout.defaultTimeout = 5000;
jabber.Stream.packetIDLength = 5;
jabber.client.Stream.PORT_STANDARD = 5222;
jabber.client.Stream.PORT_SECURE_STANDARD = 5223;
jabber.client.Stream.defaultPort = 5222;
js.JsXml__.enode = new EReg("^<([a-zA-Z0-9:_-]+)","");
js.JsXml__.ecdata = new EReg("^<!\\[CDATA\\[","i");
js.JsXml__.edoctype = new EReg("^<!DOCTYPE","i");
js.JsXml__.eend = new EReg("^</([a-zA-Z0-9:_-]+)>","");
js.JsXml__.epcdata = new EReg("^[^<]+","");
js.JsXml__.ecomment = new EReg("^<!--","");
js.JsXml__.eprolog = new EReg("^<\\?[^\\?]+\\?>","");
js.JsXml__.eattribute = new EReg("^\\s*([a-zA-Z0-9:_-]+)\\s*=\\s*([\"'])([^\\2]*?)\\2","");
js.JsXml__.eclose = new EReg("^[ \\r\\n\\t]*(>|(/>))","");
js.JsXml__.ecdata_end = new EReg("\\]\\]>","");
js.JsXml__.edoctype_elt = new EReg("[\\[|\\]>]","");
js.JsXml__.ecomment_end = new EReg("-->","");
haxe.Timer.arr = new Array();
xmpp.Auth.XMLNS = "jabber:iq:auth";
xmpp.SASL.XMLNS = "urn:ietf:params:xml:ns:xmpp-sasl";
jabber.BOSHConnection.BOSH_VERSION = "1.6";
xmpp.Roster.XMLNS = "jabber:iq:roster";
crypt.SHA1.hex_chr = "0123456789abcdef";
jabber.JID.MAX_PART_SIZE = 1023;
js.Lib.onerror = null;
xmpp.Stream.XMLNS_STREAM = "http://etherx.jabber.org/streams";
xmpp.Stream.XMLNS_CLIENT = "jabber:client";
xmpp.Stream.XMLNS_SERVER = "jabber:client";
xmpp.Stream.XMLNS_COMPONENT = "jabber:component:accept";
xmpp.Stream.CLOSE = "</stream:stream>";
xmpp.Stream.ERROR = "</stream:error>";
xmpp.Stream.REGEXP_CLOSE = new EReg("</stream:stream>","");
xmpp.Stream.REGEXP_ERROR = new EReg("</stream:error>","");
