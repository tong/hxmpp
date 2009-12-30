$estr = function() { return js.Boot.__string_rec(this,''); }
if(typeof jabber=='undefined') jabber = {}
if(!jabber.stream) jabber.stream = {}
jabber.stream.PacketCollector = function(filters,handler,permanent,timeout,block) { if( filters === $_ ) return; {
	$s.push("jabber.stream.PacketCollector::new");
	var $spos = $s.length;
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
	$s.pop();
}}
jabber.stream.PacketCollector.__name__ = ["jabber","stream","PacketCollector"];
jabber.stream.PacketCollector.prototype.accept = function(p) {
	$s.push("jabber.stream.PacketCollector::accept");
	var $spos = $s.length;
	{ var $it1 = $closure(this.filters,"iterator")();
	while( $it1.hasNext() ) { var f = $it1.next();
	{
		if(!f.accept(p)) {
			$s.pop();
			return false;
		}
	}
	}}
	if(this.timeout != null) this.timeout.stop();
	{
		$s.pop();
		return true;
	}
	$s.pop();
}
jabber.stream.PacketCollector.prototype.block = null;
jabber.stream.PacketCollector.prototype.deliver = function(p) {
	$s.push("jabber.stream.PacketCollector::deliver");
	var $spos = $s.length;
	var _g = 0, _g1 = this.handlers;
	while(_g < _g1.length) {
		var h = _g1[_g];
		++_g;
		h(p);
	}
	$s.pop();
}
jabber.stream.PacketCollector.prototype.filters = null;
jabber.stream.PacketCollector.prototype.handlers = null;
jabber.stream.PacketCollector.prototype.permanent = null;
jabber.stream.PacketCollector.prototype.setTimeout = function(t) {
	$s.push("jabber.stream.PacketCollector::setTimeout");
	var $spos = $s.length;
	if(this.timeout != null) this.timeout.stop();
	this.timeout = null;
	if(t == null || this.permanent) {
		$s.pop();
		return null;
	}
	this.timeout = t;
	this.timeout.collector = this;
	{
		var $tmp = this.timeout;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jabber.stream.PacketCollector.prototype.timeout = null;
jabber.stream.PacketCollector.prototype.__class__ = jabber.stream.PacketCollector;
if(typeof xmpp=='undefined') xmpp = {}
xmpp.Packet = function(to,from,id,lang) { if( to === $_ ) return; {
	$s.push("xmpp.Packet::new");
	var $spos = $s.length;
	this.to = to;
	this.from = from;
	this.id = id;
	this.lang = lang;
	this.errors = new Array();
	this.properties = new Array();
	$s.pop();
}}
xmpp.Packet.__name__ = ["xmpp","Packet"];
xmpp.Packet.parse = function(x) {
	$s.push("xmpp.Packet::parse");
	var $spos = $s.length;
	{
		var $tmp = (function($this) {
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
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
xmpp.Packet.parseAttributes = function(p,x) {
	$s.push("xmpp.Packet::parseAttributes");
	var $spos = $s.length;
	p.to = x.get("to");
	p.from = x.get("from");
	p.id = x.get("id");
	p.lang = x.get("xml:lang");
	{
		$s.pop();
		return p;
	}
	$s.pop();
}
xmpp.Packet.reflectPacketNodes = function(x,p) {
	$s.push("xmpp.Packet::reflectPacketNodes");
	var $spos = $s.length;
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
					$e = [];
					while($s.length >= $spos) $e.unshift($s.pop());
					$s.push($e[0]);
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
					{
						$e = [];
						while($s.length >= $spos) $e.unshift($s.pop());
						$s.push($e[0]);
						haxe.Log.trace("Unrecognized packet node " + e1.nodeName,{ fileName : "Packet.hx", lineNumber : 109, className : "xmpp.Packet", methodName : "reflectPacketNodes"});
					}
				}
			}
		}
	}
	}}
	{
		$s.pop();
		return p;
	}
	$s.pop();
}
xmpp.Packet.prototype._type = null;
xmpp.Packet.prototype.addAttributes = function(x) {
	$s.push("xmpp.Packet::addAttributes");
	var $spos = $s.length;
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
	{
		$s.pop();
		return x;
	}
	$s.pop();
}
xmpp.Packet.prototype.errors = null;
xmpp.Packet.prototype.from = null;
xmpp.Packet.prototype.id = null;
xmpp.Packet.prototype.lang = null;
xmpp.Packet.prototype.properties = null;
xmpp.Packet.prototype.to = null;
xmpp.Packet.prototype.toString = function() {
	$s.push("xmpp.Packet::toString");
	var $spos = $s.length;
	{
		var $tmp = this.toXml().toString();
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
xmpp.Packet.prototype.toXml = function() {
	$s.push("xmpp.Packet::toXml");
	var $spos = $s.length;
	{
		var $tmp = (function($this) {
			var $r;
			throw "Abstract";
			return $r;
		}(this));
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
xmpp.Packet.prototype.__class__ = xmpp.Packet;
xmpp.Presence = function(show,status,priority,type) { if( show === $_ ) return; {
	$s.push("xmpp.Presence::new");
	var $spos = $s.length;
	xmpp.Packet.apply(this,[]);
	this._type = xmpp.PacketType.presence;
	this.show = show;
	this.setStatus(status);
	this.priority = priority;
	this.type = type;
	$s.pop();
}}
xmpp.Presence.__name__ = ["xmpp","Presence"];
xmpp.Presence.__super__ = xmpp.Packet;
for(var k in xmpp.Packet.prototype ) xmpp.Presence.prototype[k] = xmpp.Packet.prototype[k];
xmpp.Presence.parse = function(x) {
	$s.push("xmpp.Presence::parse");
	var $spos = $s.length;
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
	{
		$s.pop();
		return p;
	}
	$s.pop();
}
xmpp.Presence.prototype.priority = null;
xmpp.Presence.prototype.setStatus = function(s) {
	$s.push("xmpp.Presence::setStatus");
	var $spos = $s.length;
	{
		var $tmp = this.status = (((s == null || s == "")?null:((s.length > 1023)?s.substr(0,1023):s)));
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
xmpp.Presence.prototype.show = null;
xmpp.Presence.prototype.status = null;
xmpp.Presence.prototype.toXml = function() {
	$s.push("xmpp.Presence::toXml");
	var $spos = $s.length;
	var x = xmpp.Packet.prototype.addAttributes.apply(this,[Xml.createElement("presence")]);
	if(this.type != null) x.set("type",Type.enumConstructor(this.type));
	if(this.show != null) x.addChild(util.XmlUtil.createElement("show",Type.enumConstructor(this.show)));
	if(this.status != null) x.addChild(util.XmlUtil.createElement("status",this.status));
	if(this.priority != null) x.addChild(util.XmlUtil.createElement("priority",Std.string(this.priority)));
	{
		$s.pop();
		return x;
	}
	$s.pop();
}
xmpp.Presence.prototype.type = null;
xmpp.Presence.prototype.__class__ = xmpp.Presence;
if(!jabber.client) jabber.client = {}
jabber.client.Authentication = function(stream) { if( stream === $_ ) return; {
	$s.push("jabber.client.Authentication::new");
	var $spos = $s.length;
	this.stream = stream;
	$s.pop();
}}
jabber.client.Authentication.__name__ = ["jabber","client","Authentication"];
jabber.client.Authentication.prototype.authenticate = function(password,resource) {
	$s.push("jabber.client.Authentication::authenticate");
	var $spos = $s.length;
	{
		var $tmp = (function($this) {
			var $r;
			throw "Abstract error";
			return $r;
		}(this));
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jabber.client.Authentication.prototype.onFail = function(e) {
	$s.push("jabber.client.Authentication::onFail");
	var $spos = $s.length;
	null;
	$s.pop();
}
jabber.client.Authentication.prototype.onSuccess = function() {
	$s.push("jabber.client.Authentication::onSuccess");
	var $spos = $s.length;
	null;
	$s.pop();
}
jabber.client.Authentication.prototype.resource = null;
jabber.client.Authentication.prototype.stream = null;
jabber.client.Authentication.prototype.__class__ = jabber.client.Authentication;
jabber.client.SASLAuthentication = function(stream,mechanisms) { if( stream === $_ ) return; {
	$s.push("jabber.client.SASLAuthentication::new");
	var $spos = $s.length;
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
	$s.pop();
}}
jabber.client.SASLAuthentication.__name__ = ["jabber","client","SASLAuthentication"];
jabber.client.SASLAuthentication.__super__ = jabber.client.Authentication;
for(var k in jabber.client.Authentication.prototype ) jabber.client.SASLAuthentication.prototype[k] = jabber.client.Authentication.prototype[k];
jabber.client.SASLAuthentication.prototype.authenticate = function(password,resource) {
	$s.push("jabber.client.SASLAuthentication::authenticate");
	var $spos = $s.length;
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
		haxe.Log.trace("No matching SASL mechanism found.",{ fileName : "SASLAuthentication.hx", lineNumber : 86, className : "jabber.client.SASLAuthentication", methodName : "authenticate", customParams : ["warn"]});
		{
			$s.pop();
			return false;
		}
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
	{
		var $tmp = this.stream.sendData(xmpp.SASL.createAuthXml(this.handshake.mechanism.id,t).toString()) != null;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jabber.client.SASLAuthentication.prototype.c_challenge = null;
jabber.client.SASLAuthentication.prototype.c_fail = null;
jabber.client.SASLAuthentication.prototype.c_success = null;
jabber.client.SASLAuthentication.prototype.handleBind = function(iq) {
	$s.push("jabber.client.SASLAuthentication::handleBind");
	var $spos = $s.length;
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
	$s.pop();
}
jabber.client.SASLAuthentication.prototype.handleSASLChallenge = function(p) {
	$s.push("jabber.client.SASLAuthentication::handleSASLChallenge");
	var $spos = $s.length;
	var c = p.toXml().firstChild().getNodeValue();
	var r = util.Base64.encode(this.handshake.getChallengeResponse(c));
	this.stream.sendData(xmpp.SASL.createResponseXml(r).toString());
	$s.pop();
}
jabber.client.SASLAuthentication.prototype.handleSASLFailed = function(p) {
	$s.push("jabber.client.SASLAuthentication::handleSASLFailed");
	var $spos = $s.length;
	this.removeSASLCollectors();
	this.onFail();
	$s.pop();
}
jabber.client.SASLAuthentication.prototype.handleSASLSuccess = function(p) {
	$s.push("jabber.client.SASLAuthentication::handleSASLSuccess");
	var $spos = $s.length;
	this.removeSASLCollectors();
	this.onStreamOpenHandler = $closure(this.stream,"onOpen");
	this.stream.onOpen = $closure(this,"handleStreamOpen");
	this.onNegotiated();
	this.stream.open();
	$s.pop();
}
jabber.client.SASLAuthentication.prototype.handleSession = function(iq) {
	$s.push("jabber.client.SASLAuthentication::handleSession");
	var $spos = $s.length;
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
	$s.pop();
}
jabber.client.SASLAuthentication.prototype.handleStreamOpen = function() {
	$s.push("jabber.client.SASLAuthentication::handleStreamOpen");
	var $spos = $s.length;
	this.stream.onOpen = this.onStreamOpenHandler;
	if(this.stream.server.features.exists("bind")) {
		var iq = new xmpp.IQ(xmpp.IQType.set);
		iq.x = new xmpp.Bind(((this.handshake.mechanism.id == "ANONYMOUS")?null:this.resource));
		this.stream.sendIQ(iq,$closure(this,"handleBind"));
	}
	else {
		this.onSuccess();
	}
	$s.pop();
}
jabber.client.SASLAuthentication.prototype.handshake = null;
jabber.client.SASLAuthentication.prototype.mechanisms = null;
jabber.client.SASLAuthentication.prototype.onNegotiated = function() {
	$s.push("jabber.client.SASLAuthentication::onNegotiated");
	var $spos = $s.length;
	null;
	$s.pop();
}
jabber.client.SASLAuthentication.prototype.onStreamOpenHandler = null;
jabber.client.SASLAuthentication.prototype.removeSASLCollectors = function() {
	$s.push("jabber.client.SASLAuthentication::removeSASLCollectors");
	var $spos = $s.length;
	this.stream.removeCollector(this.c_challenge);
	this.c_challenge = null;
	this.stream.removeCollector(this.c_fail);
	this.c_fail = null;
	this.stream.removeCollector(this.c_success);
	this.c_success = null;
	$s.pop();
}
jabber.client.SASLAuthentication.prototype.__class__ = jabber.client.SASLAuthentication;
jabber.stream.Connection = function(host) { if( host === $_ ) return; {
	$s.push("jabber.stream.Connection::new");
	var $spos = $s.length;
	this.host = host;
	this.connected = false;
	$s.pop();
}}
jabber.stream.Connection.__name__ = ["jabber","stream","Connection"];
jabber.stream.Connection.prototype.__onConnect = null;
jabber.stream.Connection.prototype.__onData = null;
jabber.stream.Connection.prototype.__onDisconnect = null;
jabber.stream.Connection.prototype.__onError = null;
jabber.stream.Connection.prototype.connect = function() {
	$s.push("jabber.stream.Connection::connect");
	var $spos = $s.length;
	throw "Abstract method";
	$s.pop();
}
jabber.stream.Connection.prototype.connected = null;
jabber.stream.Connection.prototype.disconnect = function() {
	$s.push("jabber.stream.Connection::disconnect");
	var $spos = $s.length;
	throw "Abstract method";
	$s.pop();
}
jabber.stream.Connection.prototype.host = null;
jabber.stream.Connection.prototype.read = function(yes) {
	$s.push("jabber.stream.Connection::read");
	var $spos = $s.length;
	if(yes == null) yes = true;
	{
		var $tmp = (function($this) {
			var $r;
			throw "Abstract method";
			return $r;
		}(this));
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jabber.stream.Connection.prototype.write = function(t) {
	$s.push("jabber.stream.Connection::write");
	var $spos = $s.length;
	{
		var $tmp = (function($this) {
			var $r;
			throw "Abstract method";
			return $r;
		}(this));
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jabber.stream.Connection.prototype.__class__ = jabber.stream.Connection;
if(typeof util=='undefined') util = {}
util.XmlUtil = function() { }
util.XmlUtil.__name__ = ["util","XmlUtil"];
util.XmlUtil.createElement = function(name,data) {
	$s.push("util.XmlUtil::createElement");
	var $spos = $s.length;
	var x = Xml.createElement(name);
	if(data != null) x.addChild(Xml.createPCData(data));
	{
		$s.pop();
		return x;
	}
	$s.pop();
}
util.XmlUtil.removeXmlHeader = function(s) {
	$s.push("util.XmlUtil::removeXmlHeader");
	var $spos = $s.length;
	{
		var $tmp = (s.substr(0,6) == "<?xml "?s.substr(s.indexOf("><") + 1,s.length):s);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
util.XmlUtil.prototype.__class__ = util.XmlUtil;
jabber.client.VCard = function(stream) { if( stream === $_ ) return; {
	$s.push("jabber.client.VCard::new");
	var $spos = $s.length;
	this.stream = stream;
	$s.pop();
}}
jabber.client.VCard.__name__ = ["jabber","client","VCard"];
jabber.client.VCard.prototype.handleLoad = function(iq) {
	$s.push("jabber.client.VCard::handleLoad");
	var $spos = $s.length;
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
	$s.pop();
}
jabber.client.VCard.prototype.handleUpdate = function(iq) {
	$s.push("jabber.client.VCard::handleUpdate");
	var $spos = $s.length;
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
	$s.pop();
}
jabber.client.VCard.prototype.load = function(jid) {
	$s.push("jabber.client.VCard::load");
	var $spos = $s.length;
	var iq = new xmpp.IQ(null,null,jid);
	iq.x = new xmpp.VCard();
	this.stream.sendIQ(iq,$closure(this,"handleLoad"));
	$s.pop();
}
jabber.client.VCard.prototype.onError = function(e) {
	$s.push("jabber.client.VCard::onError");
	var $spos = $s.length;
	null;
	$s.pop();
}
jabber.client.VCard.prototype.onLoad = function(node,data) {
	$s.push("jabber.client.VCard::onLoad");
	var $spos = $s.length;
	null;
	$s.pop();
}
jabber.client.VCard.prototype.onUpdate = function(data) {
	$s.push("jabber.client.VCard::onUpdate");
	var $spos = $s.length;
	null;
	$s.pop();
}
jabber.client.VCard.prototype.stream = null;
jabber.client.VCard.prototype.update = function(vc) {
	$s.push("jabber.client.VCard::update");
	var $spos = $s.length;
	var iq = new xmpp.IQ(xmpp.IQType.set,null,this.stream.jid.domain);
	iq.x = vc;
	this.stream.sendIQ(iq,$closure(this,"handleUpdate"));
	$s.pop();
}
jabber.client.VCard.prototype.__class__ = jabber.client.VCard;
if(typeof haxe=='undefined') haxe = {}
haxe.Http = function(url) { if( url === $_ ) return; {
	$s.push("haxe.Http::new");
	var $spos = $s.length;
	this.url = url;
	this.headers = new Hash();
	this.params = new Hash();
	this.async = true;
	$s.pop();
}}
haxe.Http.__name__ = ["haxe","Http"];
haxe.Http.requestUrl = function(url) {
	$s.push("haxe.Http::requestUrl");
	var $spos = $s.length;
	var h = new haxe.Http(url);
	h.async = false;
	var r = null;
	h.onData = function(d) {
		$s.push("haxe.Http::requestUrl@621");
		var $spos = $s.length;
		r = d;
		$s.pop();
	}
	h.onError = function(e) {
		$s.push("haxe.Http::requestUrl@624");
		var $spos = $s.length;
		throw e;
		$s.pop();
	}
	h.request(false);
	{
		$s.pop();
		return r;
	}
	$s.pop();
}
haxe.Http.prototype.async = null;
haxe.Http.prototype.headers = null;
haxe.Http.prototype.onData = function(data) {
	$s.push("haxe.Http::onData");
	var $spos = $s.length;
	null;
	$s.pop();
}
haxe.Http.prototype.onError = function(msg) {
	$s.push("haxe.Http::onError");
	var $spos = $s.length;
	null;
	$s.pop();
}
haxe.Http.prototype.onStatus = function(status) {
	$s.push("haxe.Http::onStatus");
	var $spos = $s.length;
	null;
	$s.pop();
}
haxe.Http.prototype.params = null;
haxe.Http.prototype.postData = null;
haxe.Http.prototype.request = function(post) {
	$s.push("haxe.Http::request");
	var $spos = $s.length;
	var me = this;
	var r = new js.XMLHttpRequest();
	var onreadystatechange = function() {
		$s.push("haxe.Http::request@104");
		var $spos = $s.length;
		if(r.readyState != 4) {
			$s.pop();
			return;
		}
		var s = (function($this) {
			var $r;
			try {
				$r = r.status;
			}
			catch( $e7 ) {
				{
					var e = $e7;
					$r = (function($this) {
						var $r;
						$e = [];
						while($s.length >= $spos) $e.unshift($s.pop());
						$s.push($e[0]);
						$r = null;
						return $r;
					}($this));
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
		$s.pop();
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
				$e = [];
				while($s.length >= $spos) $e.unshift($s.pop());
				$s.push($e[0]);
				this.onError(e.toString());
				{
					$s.pop();
					return;
				}
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
	$s.pop();
}
haxe.Http.prototype.setHeader = function(header,value) {
	$s.push("haxe.Http::setHeader");
	var $spos = $s.length;
	this.headers.set(header,value);
	$s.pop();
}
haxe.Http.prototype.setParameter = function(param,value) {
	$s.push("haxe.Http::setParameter");
	var $spos = $s.length;
	this.params.set(param,value);
	$s.pop();
}
haxe.Http.prototype.setPostData = function(data) {
	$s.push("haxe.Http::setPostData");
	var $spos = $s.length;
	this.postData = data;
	$s.pop();
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
	$s.push("jabber.client.Roster::new");
	var $spos = $s.length;
	this.stream = stream;
	this.subscriptionMode = (subscriptionMode != null?subscriptionMode:jabber.client.Roster.defaultSubscriptionMode);
	this.available = false;
	this.items = new Array();
	this.presence = new jabber.PresenceManager(stream);
	this.resources = new Hash();
	this.presenceMap = new Hash();
	stream.collect([new xmpp.filter.PacketTypeFilter(xmpp.PacketType.presence)],$closure(this,"handleRosterPresence"),true);
	stream.collect([new xmpp.filter.IQFilter("jabber:iq:roster")],$closure(this,"handleRosterIQ"),true);
	$s.pop();
}}
jabber.client.Roster.__name__ = ["jabber","client","Roster"];
jabber.client.Roster.prototype.addItem = function(jid) {
	$s.push("jabber.client.Roster::addItem");
	var $spos = $s.length;
	if(!this.available || this.hasItem(jid)) {
		$s.pop();
		return false;
	}
	this.requestItemAdd(jid);
	{
		$s.pop();
		return true;
	}
	$s.pop();
}
jabber.client.Roster.prototype.available = null;
jabber.client.Roster.prototype.confirmSubscription = function(jid,allow) {
	$s.push("jabber.client.Roster::confirmSubscription");
	var $spos = $s.length;
	if(allow == null) allow = true;
	var p = new xmpp.Presence(null,null,null,((allow)?xmpp.PresenceType.subscribed:xmpp.PresenceType.unsubscribed));
	p.to = jid;
	this.stream.sendData(p.toXml().toString());
	$s.pop();
}
jabber.client.Roster.prototype.getGroups = function() {
	$s.push("jabber.client.Roster::getGroups");
	var $spos = $s.length;
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
	{
		$s.pop();
		return r;
	}
	$s.pop();
}
jabber.client.Roster.prototype.getItem = function(jid) {
	$s.push("jabber.client.Roster::getItem");
	var $spos = $s.length;
	{
		var _g = 0, _g1 = this.items;
		while(_g < _g1.length) {
			var i = _g1[_g];
			++_g;
			if(i.jid == jid) {
				{
					$s.pop();
					return i;
				}
			}
		}
	}
	{
		$s.pop();
		return null;
	}
	$s.pop();
}
jabber.client.Roster.prototype.getPresence = function(jid) {
	$s.push("jabber.client.Roster::getPresence");
	var $spos = $s.length;
	{
		var $tmp = this.presenceMap.get(jid);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jabber.client.Roster.prototype.groups = null;
jabber.client.Roster.prototype.handleRosterIQ = function(iq) {
	$s.push("jabber.client.Roster::handleRosterIQ");
	var $spos = $s.length;
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
					haxe.Log.trace("TODO UPDATE ROSTER ITEM",{ fileName : "Roster.hx", lineNumber : 278, className : "jabber.client.Roster", methodName : "handleRosterIQ"});
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
		haxe.Log.trace("ERROR",{ fileName : "Roster.hx", lineNumber : 303, className : "jabber.client.Roster", methodName : "handleRosterIQ"});
	}break;
	default:{
		haxe.Log.trace("??? unhandled",{ fileName : "Roster.hx", lineNumber : 305, className : "jabber.client.Roster", methodName : "handleRosterIQ"});
	}break;
	}
	$s.pop();
}
jabber.client.Roster.prototype.handleRosterPresence = function(p) {
	$s.push("jabber.client.Roster::handleRosterPresence");
	var $spos = $s.length;
	var from = jabber.JIDUtil.parseBare(p.from);
	var resource = jabber.JIDUtil.parseResource(p.from);
	if(from == this.stream.jid.getBare()) {
		if(resource == null) {
			$s.pop();
			return;
		}
		this.resources.set(resource,p);
		this.onResourcePresence(resource,p);
		{
			$s.pop();
			return;
		}
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
			{
				$s.pop();
				return;
			}
		}break;
		case 3:
		{
			this.onSubscribed(i);
		}break;
		case 5:
		{
			this.onUnsubscribed(i);
			{
				$s.pop();
				return;
			}
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
	$s.pop();
}
jabber.client.Roster.prototype.hasItem = function(jid) {
	$s.push("jabber.client.Roster::hasItem");
	var $spos = $s.length;
	{
		var $tmp = (this.getItem(jabber.JIDUtil.parseBare(jid)) != null);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jabber.client.Roster.prototype.items = null;
jabber.client.Roster.prototype.load = function() {
	$s.push("jabber.client.Roster::load");
	var $spos = $s.length;
	var iq = new xmpp.IQ();
	iq.x = new xmpp.Roster();
	this.stream.sendIQ(iq);
	$s.pop();
}
jabber.client.Roster.prototype.onAdd = function(items) {
	$s.push("jabber.client.Roster::onAdd");
	var $spos = $s.length;
	null;
	$s.pop();
}
jabber.client.Roster.prototype.onError = function(e) {
	$s.push("jabber.client.Roster::onError");
	var $spos = $s.length;
	null;
	$s.pop();
}
jabber.client.Roster.prototype.onLoad = function() {
	$s.push("jabber.client.Roster::onLoad");
	var $spos = $s.length;
	null;
	$s.pop();
}
jabber.client.Roster.prototype.onPresence = function(item,p) {
	$s.push("jabber.client.Roster::onPresence");
	var $spos = $s.length;
	null;
	$s.pop();
}
jabber.client.Roster.prototype.onRemove = function(items) {
	$s.push("jabber.client.Roster::onRemove");
	var $spos = $s.length;
	null;
	$s.pop();
}
jabber.client.Roster.prototype.onResourcePresence = function(resource,p) {
	$s.push("jabber.client.Roster::onResourcePresence");
	var $spos = $s.length;
	null;
	$s.pop();
}
jabber.client.Roster.prototype.onSubscribed = function(item) {
	$s.push("jabber.client.Roster::onSubscribed");
	var $spos = $s.length;
	null;
	$s.pop();
}
jabber.client.Roster.prototype.onSubscription = function(item) {
	$s.push("jabber.client.Roster::onSubscription");
	var $spos = $s.length;
	null;
	$s.pop();
}
jabber.client.Roster.prototype.onUnsubscribed = function(item) {
	$s.push("jabber.client.Roster::onUnsubscribed");
	var $spos = $s.length;
	null;
	$s.pop();
}
jabber.client.Roster.prototype.onUpdate = function(items) {
	$s.push("jabber.client.Roster::onUpdate");
	var $spos = $s.length;
	null;
	$s.pop();
}
jabber.client.Roster.prototype.presence = null;
jabber.client.Roster.prototype.presenceMap = null;
jabber.client.Roster.prototype.removeItem = function(jid) {
	$s.push("jabber.client.Roster::removeItem");
	var $spos = $s.length;
	if(!this.available) {
		$s.pop();
		return false;
	}
	var i = this.getItem(jid);
	if(i == null) {
		$s.pop();
		return false;
	}
	var iq = new xmpp.IQ(xmpp.IQType.set);
	iq.x = new xmpp.Roster([new xmpp.roster.Item(jid,xmpp.roster.Subscription.remove)]);
	var _this = this;
	this.stream.sendIQ(iq,function(r) {
		$s.push("jabber.client.Roster::removeItem@125");
		var $spos = $s.length;
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
		$s.pop();
	});
	{
		$s.pop();
		return true;
	}
	$s.pop();
}
jabber.client.Roster.prototype.requestItemAdd = function(j) {
	$s.push("jabber.client.Roster::requestItemAdd");
	var $spos = $s.length;
	var iq = new xmpp.IQ(xmpp.IQType.set);
	iq.x = new xmpp.Roster([new xmpp.roster.Item(j)]);
	var me = this;
	this.stream.sendIQ(iq,function(r) {
		$s.push("jabber.client.Roster::requestItemAdd@313");
		var $spos = $s.length;
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
		$s.pop();
	});
	$s.pop();
}
jabber.client.Roster.prototype.resources = null;
jabber.client.Roster.prototype.stream = null;
jabber.client.Roster.prototype.subscribe = function(jid) {
	$s.push("jabber.client.Roster::subscribe");
	var $spos = $s.length;
	if(!this.available) {
		$s.pop();
		return false;
	}
	var i = this.getItem(jid);
	if(i == null) {
		var iq = new xmpp.IQ(xmpp.IQType.set);
		iq.x = new xmpp.Roster([new xmpp.roster.Item(jid)]);
		var me = this;
		this.stream.sendIQ(iq,function(r) {
			$s.push("jabber.client.Roster::subscribe@160");
			var $spos = $s.length;
			null;
			$s.pop();
		});
	}
	else if(i.subscription == xmpp.roster.Subscription.both) {
		{
			$s.pop();
			return false;
		}
	}
	var p = new xmpp.Presence(null,null,null,xmpp.PresenceType.subscribe);
	p.to = jid;
	{
		var $tmp = this.stream.sendPacket(p) != null;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jabber.client.Roster.prototype.subscriptionMode = null;
jabber.client.Roster.prototype.unsubscribe = function(jid) {
	$s.push("jabber.client.Roster::unsubscribe");
	var $spos = $s.length;
	if(!this.available) {
		$s.pop();
		return false;
	}
	var i = this.getItem(jid);
	if(i == null) {
		$s.pop();
		return false;
	}
	if(i.askType != xmpp.roster.AskType.unsubscribe) {
		var p = new xmpp.Presence(null,null,null,xmpp.PresenceType.unsubscribe);
		p.to = jid;
		this.stream.sendPacket(p);
	}
	{
		$s.pop();
		return true;
	}
	$s.pop();
}
jabber.client.Roster.prototype.updateItem = function(item) {
	$s.push("jabber.client.Roster::updateItem");
	var $spos = $s.length;
	if(!this.available || !this.hasItem(item.jid)) {
		$s.pop();
		return false;
	}
	var iq = new xmpp.IQ(xmpp.IQType.set);
	iq.x = new xmpp.Roster([item]);
	var _this = this;
	this.stream.sendIQ(iq,function(r) {
		$s.push("jabber.client.Roster::updateItem@143");
		var $spos = $s.length;
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
		$s.pop();
	});
	{
		$s.pop();
		return true;
	}
	$s.pop();
}
jabber.client.Roster.prototype.__class__ = jabber.client.Roster;
List = function(p) { if( p === $_ ) return; {
	$s.push("List::new");
	var $spos = $s.length;
	this.length = 0;
	$s.pop();
}}
List.__name__ = ["List"];
List.prototype.add = function(item) {
	$s.push("List::add");
	var $spos = $s.length;
	var x = [item];
	if(this.h == null) this.h = x;
	else this.q[1] = x;
	this.q = x;
	this.length++;
	$s.pop();
}
List.prototype.clear = function() {
	$s.push("List::clear");
	var $spos = $s.length;
	this.h = null;
	this.q = null;
	this.length = 0;
	$s.pop();
}
List.prototype.filter = function(f) {
	$s.push("List::filter");
	var $spos = $s.length;
	var l2 = new List();
	var l = this.h;
	while(l != null) {
		var v = l[0];
		l = l[1];
		if(f(v)) l2.add(v);
	}
	{
		$s.pop();
		return l2;
	}
	$s.pop();
}
List.prototype.first = function() {
	$s.push("List::first");
	var $spos = $s.length;
	{
		var $tmp = (this.h == null?null:this.h[0]);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
List.prototype.h = null;
List.prototype.isEmpty = function() {
	$s.push("List::isEmpty");
	var $spos = $s.length;
	{
		var $tmp = (this.h == null);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
List.prototype.iterator = function() {
	$s.push("List::iterator");
	var $spos = $s.length;
	{
		var $tmp = { h : this.h, hasNext : function() {
			$s.push("List::iterator@196");
			var $spos = $s.length;
			{
				var $tmp = (this.h != null);
				$s.pop();
				return $tmp;
			}
			$s.pop();
		}, next : function() {
			$s.push("List::iterator@199");
			var $spos = $s.length;
			if(this.h == null) {
				$s.pop();
				return null;
			}
			var x = this.h[0];
			this.h = this.h[1];
			{
				$s.pop();
				return x;
			}
			$s.pop();
		}}
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
List.prototype.join = function(sep) {
	$s.push("List::join");
	var $spos = $s.length;
	var s = new StringBuf();
	var first = true;
	var l = this.h;
	while(l != null) {
		if(first) first = false;
		else s.b[s.b.length] = sep;
		s.b[s.b.length] = l[0];
		l = l[1];
	}
	{
		var $tmp = s.b.join("");
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
List.prototype.last = function() {
	$s.push("List::last");
	var $spos = $s.length;
	{
		var $tmp = (this.q == null?null:this.q[0]);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
List.prototype.length = null;
List.prototype.map = function(f) {
	$s.push("List::map");
	var $spos = $s.length;
	var b = new List();
	var l = this.h;
	while(l != null) {
		var v = l[0];
		l = l[1];
		b.add(f(v));
	}
	{
		$s.pop();
		return b;
	}
	$s.pop();
}
List.prototype.pop = function() {
	$s.push("List::pop");
	var $spos = $s.length;
	if(this.h == null) {
		$s.pop();
		return null;
	}
	var x = this.h[0];
	this.h = this.h[1];
	if(this.h == null) this.q = null;
	this.length--;
	{
		$s.pop();
		return x;
	}
	$s.pop();
}
List.prototype.push = function(item) {
	$s.push("List::push");
	var $spos = $s.length;
	var x = [item,this.h];
	this.h = x;
	if(this.q == null) this.q = x;
	this.length++;
	$s.pop();
}
List.prototype.q = null;
List.prototype.remove = function(v) {
	$s.push("List::remove");
	var $spos = $s.length;
	var prev = null;
	var l = this.h;
	while(l != null) {
		if(l[0] == v) {
			if(prev == null) this.h = l[1];
			else prev[1] = l[1];
			if(this.q == l) this.q = prev;
			this.length--;
			{
				$s.pop();
				return true;
			}
		}
		prev = l;
		l = l[1];
	}
	{
		$s.pop();
		return false;
	}
	$s.pop();
}
List.prototype.toString = function() {
	$s.push("List::toString");
	var $spos = $s.length;
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
	{
		var $tmp = s.b.join("");
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
List.prototype.__class__ = List;
haxe.Serializer = function(p) { if( p === $_ ) return; {
	$s.push("haxe.Serializer::new");
	var $spos = $s.length;
	this.buf = new StringBuf();
	this.cache = new Array();
	this.useCache = haxe.Serializer.USE_CACHE;
	this.useEnumIndex = haxe.Serializer.USE_ENUM_INDEX;
	this.shash = new Hash();
	this.scount = 0;
	$s.pop();
}}
haxe.Serializer.__name__ = ["haxe","Serializer"];
haxe.Serializer.run = function(v) {
	$s.push("haxe.Serializer::run");
	var $spos = $s.length;
	var s = new haxe.Serializer();
	s.serialize(v);
	{
		var $tmp = s.toString();
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
haxe.Serializer.prototype.buf = null;
haxe.Serializer.prototype.cache = null;
haxe.Serializer.prototype.scount = null;
haxe.Serializer.prototype.serialize = function(v) {
	$s.push("haxe.Serializer::serialize");
	var $spos = $s.length;
	var $e = (Type["typeof"](v));
	switch( $e[1] ) {
	case 0:
	{
		this.buf.add("n");
	}break;
	case 1:
	{
		if(v == 0) {
			this.buf.add("z");
			{
				$s.pop();
				return;
			}
		}
		this.buf.add("i");
		this.buf.add(v);
	}break;
	case 2:
	{
		if(Math.isNaN(v)) this.buf.add("k");
		else if(!Math.isFinite(v)) this.buf.add((v < 0?"m":"p"));
		else {
			this.buf.add("d");
			this.buf.add(v);
		}
	}break;
	case 3:
	{
		this.buf.add((v?"t":"f"));
	}break;
	case 6:
	var c = $e[2];
	{
		if(c == String) {
			this.serializeString(v);
			{
				$s.pop();
				return;
			}
		}
		if(this.useCache && this.serializeRef(v)) {
			$s.pop();
			return;
		}
		switch(c) {
		case Array:{
			var ucount = 0;
			this.buf.add("a");
			var l = v["length"];
			{
				var _g = 0;
				while(_g < l) {
					var i = _g++;
					if(v[i] == null) ucount++;
					else {
						if(ucount > 0) {
							if(ucount == 1) this.buf.add("n");
							else {
								this.buf.add("u");
								this.buf.add(ucount);
							}
							ucount = 0;
						}
						this.serialize(v[i]);
					}
				}
			}
			if(ucount > 0) {
				if(ucount == 1) this.buf.add("n");
				else {
					this.buf.add("u");
					this.buf.add(ucount);
				}
			}
			this.buf.add("h");
		}break;
		case List:{
			this.buf.add("l");
			var v1 = v;
			{ var $it14 = v1.iterator();
			while( $it14.hasNext() ) { var i = $it14.next();
			this.serialize(i);
			}}
			this.buf.add("h");
		}break;
		case Date:{
			var d = v;
			this.buf.add("v");
			this.buf.add(d.toString());
		}break;
		case Hash:{
			this.buf.add("b");
			var v1 = v;
			{ var $it15 = v1.keys();
			while( $it15.hasNext() ) { var k = $it15.next();
			{
				this.serializeString(k);
				this.serialize(v1.get(k));
			}
			}}
			this.buf.add("h");
		}break;
		case IntHash:{
			this.buf.add("q");
			var v1 = v;
			{ var $it16 = v1.keys();
			while( $it16.hasNext() ) { var k = $it16.next();
			{
				this.buf.add(":");
				this.buf.add(k);
				this.serialize(v1.get(k));
			}
			}}
			this.buf.add("h");
		}break;
		case haxe.io.Bytes:{
			var v1 = v;
			var i = 0;
			var max = v1.length - 2;
			var chars = "";
			var b64 = haxe.Serializer.BASE64;
			while(i < max) {
				var b1 = v1.b[i++];
				var b2 = v1.b[i++];
				var b3 = v1.b[i++];
				chars += b64.charAt(b1 >> 2) + b64.charAt(((b1 << 4) | (b2 >> 4)) & 63) + b64.charAt(((b2 << 2) | (b3 >> 6)) & 63) + b64.charAt(b3 & 63);
			}
			if(i == max) {
				var b1 = v1.b[i++];
				var b2 = v1.b[i++];
				chars += b64.charAt(b1 >> 2) + b64.charAt(((b1 << 4) | (b2 >> 4)) & 63) + b64.charAt((b2 << 2) & 63);
			}
			else if(i == max + 1) {
				var b1 = v1.b[i++];
				chars += b64.charAt(b1 >> 2) + b64.charAt((b1 << 4) & 63);
			}
			this.buf.add("s");
			this.buf.add(chars.length);
			this.buf.add(":");
			this.buf.add(chars);
		}break;
		default:{
			this.cache.pop();
			this.buf.add("c");
			this.serializeString(Type.getClassName(c));
			this.cache.push(v);
			this.serializeFields(v);
		}break;
		}
	}break;
	case 4:
	{
		if(this.useCache && this.serializeRef(v)) {
			$s.pop();
			return;
		}
		this.buf.add("o");
		this.serializeFields(v);
	}break;
	case 7:
	var e = $e[2];
	{
		if(this.useCache && this.serializeRef(v)) {
			$s.pop();
			return;
		}
		this.cache.pop();
		this.buf.add((this.useEnumIndex?"j":"w"));
		this.serializeString(Type.getEnumName(e));
		if(this.useEnumIndex) {
			this.buf.add(":");
			this.buf.add(v[1]);
		}
		else this.serializeString(v[0]);
		this.buf.add(":");
		var l = v["length"];
		this.buf.add(l - 2);
		{
			var _g = 2;
			while(_g < l) {
				var i = _g++;
				this.serialize(v[i]);
			}
		}
		this.cache.push(v);
	}break;
	case 5:
	{
		throw "Cannot serialize function";
	}break;
	default:{
		throw "Cannot serialize " + Std.string(v);
	}break;
	}
	$s.pop();
}
haxe.Serializer.prototype.serializeException = function(e) {
	$s.push("haxe.Serializer::serializeException");
	var $spos = $s.length;
	this.buf.add("x");
	this.serialize(e);
	$s.pop();
}
haxe.Serializer.prototype.serializeFields = function(v) {
	$s.push("haxe.Serializer::serializeFields");
	var $spos = $s.length;
	{
		var _g = 0, _g1 = Reflect.fields(v);
		while(_g < _g1.length) {
			var f = _g1[_g];
			++_g;
			this.serializeString(f);
			this.serialize(Reflect.field(v,f));
		}
	}
	this.buf.add("g");
	$s.pop();
}
haxe.Serializer.prototype.serializeRef = function(v) {
	$s.push("haxe.Serializer::serializeRef");
	var $spos = $s.length;
	var vt = typeof(v);
	{
		var _g1 = 0, _g = this.cache.length;
		while(_g1 < _g) {
			var i = _g1++;
			var ci = this.cache[i];
			if(typeof(ci) == vt && ci == v) {
				this.buf.add("r");
				this.buf.add(i);
				{
					$s.pop();
					return true;
				}
			}
		}
	}
	this.cache.push(v);
	{
		$s.pop();
		return false;
	}
	$s.pop();
}
haxe.Serializer.prototype.serializeString = function(s) {
	$s.push("haxe.Serializer::serializeString");
	var $spos = $s.length;
	var x = this.shash.get(s);
	if(x != null) {
		this.buf.add("R");
		this.buf.add(x);
		{
			$s.pop();
			return;
		}
	}
	this.shash.set(s,this.scount++);
	this.buf.add("y");
	s = StringTools.urlEncode(s);
	this.buf.add(s.length);
	this.buf.add(":");
	this.buf.add(s);
	$s.pop();
}
haxe.Serializer.prototype.shash = null;
haxe.Serializer.prototype.toString = function() {
	$s.push("haxe.Serializer::toString");
	var $spos = $s.length;
	{
		var $tmp = this.buf.b.join("");
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
haxe.Serializer.prototype.useCache = null;
haxe.Serializer.prototype.useEnumIndex = null;
haxe.Serializer.prototype.__class__ = haxe.Serializer;
jabber.PresenceManager = function(stream,target) { if( stream === $_ ) return; {
	$s.push("jabber.PresenceManager::new");
	var $spos = $s.length;
	this.stream = stream;
	this.target = target;
	$s.pop();
}}
jabber.PresenceManager.__name__ = ["jabber","PresenceManager"];
jabber.PresenceManager.prototype.change = function(show,status,priority,type) {
	$s.push("jabber.PresenceManager::change");
	var $spos = $s.length;
	{
		var $tmp = this.set(new xmpp.Presence(show,status,priority,type));
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jabber.PresenceManager.prototype.last = null;
jabber.PresenceManager.prototype.set = function(p) {
	$s.push("jabber.PresenceManager::set");
	var $spos = $s.length;
	this.last = (p == null?new xmpp.Presence():p);
	if(this.target != null && this.last.to == null) this.last.to = this.target;
	{
		var $tmp = this.stream.sendPacket(this.last);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jabber.PresenceManager.prototype.stream = null;
jabber.PresenceManager.prototype.target = null;
jabber.PresenceManager.prototype.__class__ = jabber.PresenceManager;
jabber.XMPPDebug = function() { }
jabber.XMPPDebug.__name__ = ["jabber","XMPPDebug"];
jabber.XMPPDebug.inc = function(t) {
	$s.push("jabber.XMPPDebug::inc");
	var $spos = $s.length;
	jabber.XMPPDebug.printToXMPPConsole(t,false);
	jabber.XMPPDebug.print(t,false,"log");
	$s.pop();
}
jabber.XMPPDebug.out = function(t) {
	$s.push("jabber.XMPPDebug::out");
	var $spos = $s.length;
	jabber.XMPPDebug.printToXMPPConsole(t,true);
	jabber.XMPPDebug.print(t,true,"log");
	$s.pop();
}
jabber.XMPPDebug.printToXMPPConsole = function(t,out) {
	$s.push("jabber.XMPPDebug::printToXMPPConsole");
	var $spos = $s.length;
	var v = haxe.Serializer.run(t);
	try {
		hxmpp.Console.print(v,out);
	}
	catch( $e17 ) {
		{
			var e = $e17;
			{
				$e = [];
				while($s.length >= $spos) $e.unshift($s.pop());
				$s.push($e[0]);
				haxe.Log.trace("HXMPP.console debugging error: " + e,{ fileName : "XMPPDebug.hx", lineNumber : 125, className : "jabber.XMPPDebug", methodName : "printToXMPPConsole", customParams : ["warn"]});
			}
		}
	}
	$s.pop();
}
jabber.XMPPDebug._inc = function(t) {
	$s.push("jabber.XMPPDebug::_inc");
	var $spos = $s.length;
	jabber.XMPPDebug.print(t,false,"log");
	$s.pop();
}
jabber.XMPPDebug._out = function(t) {
	$s.push("jabber.XMPPDebug::_out");
	var $spos = $s.length;
	jabber.XMPPDebug.print(t,true,"log");
	$s.pop();
}
jabber.XMPPDebug.print = function(t,out,level) {
	$s.push("jabber.XMPPDebug::print");
	var $spos = $s.length;
	if(level == null) level = "log";
	jabber.XMPPDebug._print(t,out,level);
	$s.pop();
}
jabber.XMPPDebug.useConsole = null;
jabber.XMPPDebug._print = function(t,out,level) {
	$s.push("jabber.XMPPDebug::_print");
	var $spos = $s.length;
	if(level == null) level = "log";
	if(out == null) out = true;
	var dir = "XMPP-" + (((out)?"O ":"I "));
	if(jabber.XMPPDebug.useConsole) {
		console[level](dir + t);
	}
	else {
		haxe.Log.trace(t,{ className : "", methodName : "", fileName : dir, lineNumber : 0, customParams : []});
	}
	$s.pop();
}
jabber.XMPPDebug.prototype.__class__ = jabber.XMPPDebug;
if(!xmpp.filter) xmpp.filter = {}
xmpp.filter.PacketNameFilter = function(reg) { if( reg === $_ ) return; {
	$s.push("xmpp.filter.PacketNameFilter::new");
	var $spos = $s.length;
	this.reg = reg;
	$s.pop();
}}
xmpp.filter.PacketNameFilter.__name__ = ["xmpp","filter","PacketNameFilter"];
xmpp.filter.PacketNameFilter.prototype.accept = function(p) {
	$s.push("xmpp.filter.PacketNameFilter::accept");
	var $spos = $s.length;
	{
		var $tmp = this.reg.match(p.toXml().getNodeName());
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
xmpp.filter.PacketNameFilter.prototype.reg = null;
xmpp.filter.PacketNameFilter.prototype.__class__ = xmpp.filter.PacketNameFilter;
EReg = function(r,opt) { if( r === $_ ) return; {
	$s.push("EReg::new");
	var $spos = $s.length;
	opt = opt.split("u").join("");
	this.r = new RegExp(r,opt);
	$s.pop();
}}
EReg.__name__ = ["EReg"];
EReg.prototype.customReplace = function(s,f) {
	$s.push("EReg::customReplace");
	var $spos = $s.length;
	var buf = new StringBuf();
	while(true) {
		if(!this.match(s)) break;
		buf.b[buf.b.length] = this.matchedLeft();
		buf.b[buf.b.length] = f(this);
		s = this.matchedRight();
	}
	buf.b[buf.b.length] = s;
	{
		var $tmp = buf.b.join("");
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
EReg.prototype.match = function(s) {
	$s.push("EReg::match");
	var $spos = $s.length;
	this.r.m = this.r.exec(s);
	this.r.s = s;
	this.r.l = RegExp.leftContext;
	this.r.r = RegExp.rightContext;
	{
		var $tmp = (this.r.m != null);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
EReg.prototype.matched = function(n) {
	$s.push("EReg::matched");
	var $spos = $s.length;
	{
		var $tmp = (this.r.m != null && n >= 0 && n < this.r.m.length?this.r.m[n]:(function($this) {
			var $r;
			throw "EReg::matched";
			return $r;
		}(this)));
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
EReg.prototype.matchedLeft = function() {
	$s.push("EReg::matchedLeft");
	var $spos = $s.length;
	if(this.r.m == null) throw "No string matched";
	if(this.r.l == null) {
		var $tmp = this.r.s.substr(0,this.r.m.index);
		$s.pop();
		return $tmp;
	}
	{
		var $tmp = this.r.l;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
EReg.prototype.matchedPos = function() {
	$s.push("EReg::matchedPos");
	var $spos = $s.length;
	if(this.r.m == null) throw "No string matched";
	{
		var $tmp = { pos : this.r.m.index, len : this.r.m[0].length}
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
EReg.prototype.matchedRight = function() {
	$s.push("EReg::matchedRight");
	var $spos = $s.length;
	if(this.r.m == null) throw "No string matched";
	if(this.r.r == null) {
		var sz = this.r.m.index + this.r.m[0].length;
		{
			var $tmp = this.r.s.substr(sz,this.r.s.length - sz);
			$s.pop();
			return $tmp;
		}
	}
	{
		var $tmp = this.r.r;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
EReg.prototype.r = null;
EReg.prototype.replace = function(s,by) {
	$s.push("EReg::replace");
	var $spos = $s.length;
	{
		var $tmp = s.replace(this.r,by);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
EReg.prototype.split = function(s) {
	$s.push("EReg::split");
	var $spos = $s.length;
	var d = "#__delim__#";
	{
		var $tmp = s.replace(this.r,d).split(d);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
EReg.prototype.__class__ = EReg;
jabber.JIDUtil = function() { }
jabber.JIDUtil.__name__ = ["jabber","JIDUtil"];
jabber.JIDUtil.isValid = function(t) {
	$s.push("jabber.JIDUtil::isValid");
	var $spos = $s.length;
	if(!jabber.JIDUtil.EREG.match(t)) {
		$s.pop();
		return false;
	}
	{
		var _g = 0, _g1 = jabber.JIDUtil.getParts(t);
		while(_g < _g1.length) {
			var p = _g1[_g];
			++_g;
			if(p.length > 1023) {
				$s.pop();
				return false;
			}
		}
	}
	{
		$s.pop();
		return true;
	}
	$s.pop();
}
jabber.JIDUtil.parseNode = function(t) {
	$s.push("jabber.JIDUtil::parseNode");
	var $spos = $s.length;
	{
		var $tmp = t.substr(0,t.indexOf("@"));
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jabber.JIDUtil.parseDomain = function(t) {
	$s.push("jabber.JIDUtil::parseDomain");
	var $spos = $s.length;
	var i1 = t.indexOf("@") + 1;
	var i2 = t.indexOf("/");
	{
		var $tmp = ((i2 == -1)?t.substr(i1):t.substr(i1,i2 - i1));
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jabber.JIDUtil.parseResource = function(t) {
	$s.push("jabber.JIDUtil::parseResource");
	var $spos = $s.length;
	var i = t.indexOf("/");
	{
		var $tmp = ((i == -1)?null:t.substr(i + 1));
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jabber.JIDUtil.parseBare = function(t) {
	$s.push("jabber.JIDUtil::parseBare");
	var $spos = $s.length;
	var i = t.indexOf("/");
	{
		var $tmp = ((i == -1)?t:t.substr(0,i));
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jabber.JIDUtil.hasResource = function(t) {
	$s.push("jabber.JIDUtil::hasResource");
	var $spos = $s.length;
	{
		var $tmp = t.indexOf("/") != -1;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jabber.JIDUtil.getParts = function(jid) {
	$s.push("jabber.JIDUtil::getParts");
	var $spos = $s.length;
	var p = [jid.substr(0,jid.indexOf("@")),jabber.JIDUtil.parseDomain(jid)];
	if(jid.indexOf("/") != -1) p.push(jabber.JIDUtil.parseResource(jid));
	{
		$s.pop();
		return p;
	}
	$s.pop();
}
jabber.JIDUtil.splitBare = function(jid) {
	$s.push("jabber.JIDUtil::splitBare");
	var $spos = $s.length;
	var i = jid.indexOf("/");
	{
		var $tmp = ((i == -1)?[jid]:[jid.substr(0,i),jid.substr(i + 1)]);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jabber.JIDUtil.escapeNode = function(n) {
	$s.push("jabber.JIDUtil::escapeNode");
	var $spos = $s.length;
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
	{
		var $tmp = b.b.join("");
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jabber.JIDUtil.unescapeNode = function(n) {
	$s.push("jabber.JIDUtil::unescapeNode");
	var $spos = $s.length;
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
	{
		var $tmp = b.b.join("");
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jabber.JIDUtil.prototype.__class__ = jabber.JIDUtil;
xmpp.Bind = function(resource,jid) { if( resource === $_ ) return; {
	$s.push("xmpp.Bind::new");
	var $spos = $s.length;
	this.resource = resource;
	this.jid = jid;
	$s.pop();
}}
xmpp.Bind.__name__ = ["xmpp","Bind"];
xmpp.Bind.parse = function(x) {
	$s.push("xmpp.Bind::parse");
	var $spos = $s.length;
	var b = new xmpp.Bind();
	{ var $it18 = x.elements();
	while( $it18.hasNext() ) { var e = $it18.next();
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
	{
		$s.pop();
		return b;
	}
	$s.pop();
}
xmpp.Bind.prototype.jid = null;
xmpp.Bind.prototype.resource = null;
xmpp.Bind.prototype.toString = function() {
	$s.push("xmpp.Bind::toString");
	var $spos = $s.length;
	{
		var $tmp = this.toXml().toString();
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
xmpp.Bind.prototype.toXml = function() {
	$s.push("xmpp.Bind::toXml");
	var $spos = $s.length;
	var x = Xml.createElement("bind");
	x.set("xmlns","urn:ietf:params:xml:ns:xmpp-bind");
	if(this.resource != null) x.addChild(util.XmlUtil.createElement("resource",this.resource));
	if(this.jid != null) x.addChild(util.XmlUtil.createElement("jid",this.jid));
	{
		$s.pop();
		return x;
	}
	$s.pop();
}
xmpp.Bind.prototype.__class__ = xmpp.Bind;
xmpp.VCard = function(p) { if( p === $_ ) return; {
	$s.push("xmpp.VCard::new");
	var $spos = $s.length;
	this.addresses = new Array();
	this.tels = new Array();
	$s.pop();
}}
xmpp.VCard.__name__ = ["xmpp","VCard"];
xmpp.VCard.parse = function(x) {
	$s.push("xmpp.VCard::parse");
	var $spos = $s.length;
	var vc = new xmpp.VCard();
	{ var $it19 = x.elements();
	while( $it19.hasNext() ) { var node = $it19.next();
	{
		switch(node.getNodeName()) {
		case "FN":{
			vc.fn = node.firstChild().getNodeValue();
		}break;
		case "N":{
			vc.n = { family : null, given : null, middle : null, prefix : null, suffix : null}
			{ var $it20 = node.elements();
			while( $it20.hasNext() ) { var n = $it20.next();
			{
				var value = null;
				try {
					var fc = n.firstChild();
					if(vc != null) value = n.firstChild().getNodeValue();
				}
				catch( $e21 ) {
					{
						var e = $e21;
						{
							$e = [];
							while($s.length >= $spos) $e.unshift($s.pop());
							$s.push($e[0]);
							null;
						}
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
						{
							$e = [];
							while($s.length >= $spos) $e.unshift($s.pop());
							$s.push($e[0]);
							null;
						}
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
						{
							$e = [];
							while($s.length >= $spos) $e.unshift($s.pop());
							$s.push($e[0]);
							null;
						}
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
						{
							$e = [];
							while($s.length >= $spos) $e.unshift($s.pop());
							$s.push($e[0]);
							null;
						}
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
			{ var $it28 = node.elements();
			while( $it28.hasNext() ) { var n = $it28.next();
			{
				var value = null;
				try {
					value = n.firstChild().getNodeValue();
				}
				catch( $e29 ) {
					{
						var e = $e29;
						{
							$e = [];
							while($s.length >= $spos) $e.unshift($s.pop());
							$s.push($e[0]);
							null;
						}
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
			{ var $it30 = node.elements();
			while( $it30.hasNext() ) { var n = $it30.next();
			{
				var value = null;
				try {
					value = n.firstChild().getNodeValue();
				}
				catch( $e31 ) {
					{
						var e = $e31;
						{
							$e = [];
							while($s.length >= $spos) $e.unshift($s.pop());
							$s.push($e[0]);
							null;
						}
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
	{
		$s.pop();
		return vc;
	}
	$s.pop();
}
xmpp.VCard.parsePhoto = function(x) {
	$s.push("xmpp.VCard::parsePhoto");
	var $spos = $s.length;
	var photo = { }
	{ var $it32 = x.elements();
	while( $it32.hasNext() ) { var n = $it32.next();
	{
		var value = null;
		try {
			value = n.firstChild().getNodeValue();
		}
		catch( $e33 ) {
			{
				var e = $e33;
				{
					$e = [];
					while($s.length >= $spos) $e.unshift($s.pop());
					$s.push($e[0]);
					null;
				}
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
	{
		$s.pop();
		return photo;
	}
	$s.pop();
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
	$s.push("xmpp.VCard::toString");
	var $spos = $s.length;
	{
		var $tmp = this.toXml().toString();
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
xmpp.VCard.prototype.toXml = function() {
	$s.push("xmpp.VCard::toXml");
	var $spos = $s.length;
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
	{
		$s.pop();
		return x;
	}
	$s.pop();
}
xmpp.VCard.prototype.tz = null;
xmpp.VCard.prototype.url = null;
xmpp.VCard.prototype.__class__ = xmpp.VCard;
xmpp.Error = function(type,code,name,text) { if( type === $_ ) return; {
	$s.push("xmpp.Error::new");
	var $spos = $s.length;
	this.type = type;
	this.code = code;
	this.name = name;
	this.text = text;
	this.conditions = new Array();
	$s.pop();
}}
xmpp.Error.__name__ = ["xmpp","Error"];
xmpp.Error.fromPacket = function(p) {
	$s.push("xmpp.Error::fromPacket");
	var $spos = $s.length;
	{ var $it34 = p.toXml().elementsNamed("error");
	while( $it34.hasNext() ) { var e = $it34.next();
	{
		var $tmp = xmpp.Error.parse(e);
		$s.pop();
		return $tmp;
	}
	}}
	{
		$s.pop();
		return null;
	}
	$s.pop();
}
xmpp.Error.parse = function(x) {
	$s.push("xmpp.Error::parse");
	var $spos = $s.length;
	var e = new xmpp.Error(null,Std.parseInt(x.get("code")));
	var et = x.get("type");
	if(et != null) e.type = Type.createEnum(xmpp.ErrorType,x.get("type"));
	var _n = x.elements().next();
	if(_n != null) e.name = _n.getNodeName();
	{
		$s.pop();
		return e;
	}
	$s.pop();
}
xmpp.Error.prototype.code = null;
xmpp.Error.prototype.conditions = null;
xmpp.Error.prototype.name = null;
xmpp.Error.prototype.text = null;
xmpp.Error.prototype.toString = function() {
	$s.push("xmpp.Error::toString");
	var $spos = $s.length;
	{
		var $tmp = this.toXml().toString();
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
xmpp.Error.prototype.toXml = function() {
	$s.push("xmpp.Error::toXml");
	var $spos = $s.length;
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
	{
		$s.pop();
		return x;
	}
	$s.pop();
}
xmpp.Error.prototype.type = null;
xmpp.Error.prototype.__class__ = xmpp.Error;
xmpp.IQ = function(type,id,to,from) { if( type === $_ ) return; {
	$s.push("xmpp.IQ::new");
	var $spos = $s.length;
	xmpp.Packet.apply(this,[to,from,id]);
	this._type = xmpp.PacketType.iq;
	this.type = ((type != null)?type:xmpp.IQType.get);
	$s.pop();
}}
xmpp.IQ.__name__ = ["xmpp","IQ"];
xmpp.IQ.__super__ = xmpp.Packet;
for(var k in xmpp.Packet.prototype ) xmpp.IQ.prototype[k] = xmpp.Packet.prototype[k];
xmpp.IQ.parse = function(x) {
	$s.push("xmpp.IQ::parse");
	var $spos = $s.length;
	var iq = new xmpp.IQ();
	iq.type = Type.createEnum(xmpp.IQType,x.get("type"));
	xmpp.Packet.parseAttributes(iq,x);
	{ var $it35 = x.elements();
	while( $it35.hasNext() ) { var c = $it35.next();
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
	{
		$s.pop();
		return iq;
	}
	$s.pop();
}
xmpp.IQ.createQueryXml = function(ns) {
	$s.push("xmpp.IQ::createQueryXml");
	var $spos = $s.length;
	var x = Xml.createElement("query");
	x.set("xmlns",ns);
	{
		$s.pop();
		return x;
	}
	$s.pop();
}
xmpp.IQ.createResult = function(iq) {
	$s.push("xmpp.IQ::createResult");
	var $spos = $s.length;
	{
		var $tmp = new xmpp.IQ(xmpp.IQType.result,iq.id,iq.from);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
xmpp.IQ.createErrorResult = function(iq,errors) {
	$s.push("xmpp.IQ::createErrorResult");
	var $spos = $s.length;
	var r = new xmpp.IQ(xmpp.IQType.error,iq.id,iq.from);
	if(errors != null) r.errors = errors;
	{
		$s.pop();
		return r;
	}
	$s.pop();
}
xmpp.IQ.prototype.toXml = function() {
	$s.push("xmpp.IQ::toXml");
	var $spos = $s.length;
	if(this.type == null) this.type = xmpp.IQType.get;
	var _x = xmpp.Packet.prototype.addAttributes.apply(this,[Xml.createElement("iq")]);
	_x.set("type",Type.enumConstructor(this.type));
	_x.set("id",this.id);
	if(this.x != null) _x.addChild(this.x.toXml());
	{
		$s.pop();
		return _x;
	}
	$s.pop();
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
	$s.push("haxe.BaseCode::new");
	var $spos = $s.length;
	var len = base.length;
	var nbits = 1;
	while(len > 1 << nbits) nbits++;
	if(nbits > 8 || len != 1 << nbits) throw "BaseCode : base length must be a power of two.";
	this.base = base;
	this.nbits = nbits;
	$s.pop();
}}
haxe.BaseCode.__name__ = ["haxe","BaseCode"];
haxe.BaseCode.encode = function(s,base) {
	$s.push("haxe.BaseCode::encode");
	var $spos = $s.length;
	var b = new haxe.BaseCode(haxe.io.Bytes.ofString(base));
	{
		var $tmp = b.encodeString(s);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
haxe.BaseCode.decode = function(s,base) {
	$s.push("haxe.BaseCode::decode");
	var $spos = $s.length;
	var b = new haxe.BaseCode(haxe.io.Bytes.ofString(base));
	{
		var $tmp = b.decodeString(s);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
haxe.BaseCode.prototype.base = null;
haxe.BaseCode.prototype.decodeBytes = function(b) {
	$s.push("haxe.BaseCode::decodeBytes");
	var $spos = $s.length;
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
	{
		$s.pop();
		return out;
	}
	$s.pop();
}
haxe.BaseCode.prototype.decodeString = function(s) {
	$s.push("haxe.BaseCode::decodeString");
	var $spos = $s.length;
	{
		var $tmp = this.decodeBytes(haxe.io.Bytes.ofString(s)).toString();
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
haxe.BaseCode.prototype.encodeBytes = function(b) {
	$s.push("haxe.BaseCode::encodeBytes");
	var $spos = $s.length;
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
	{
		$s.pop();
		return out;
	}
	$s.pop();
}
haxe.BaseCode.prototype.encodeString = function(s) {
	$s.push("haxe.BaseCode::encodeString");
	var $spos = $s.length;
	{
		var $tmp = this.encodeBytes(haxe.io.Bytes.ofString(s)).toString();
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
haxe.BaseCode.prototype.initTable = function() {
	$s.push("haxe.BaseCode::initTable");
	var $spos = $s.length;
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
	$s.pop();
}
haxe.BaseCode.prototype.nbits = null;
haxe.BaseCode.prototype.tbl = null;
haxe.BaseCode.prototype.__class__ = haxe.BaseCode;
xmpp.filter.PacketTypeFilter = function(type) { if( type === $_ ) return; {
	$s.push("xmpp.filter.PacketTypeFilter::new");
	var $spos = $s.length;
	this.type = type;
	$s.pop();
}}
xmpp.filter.PacketTypeFilter.__name__ = ["xmpp","filter","PacketTypeFilter"];
xmpp.filter.PacketTypeFilter.prototype.accept = function(p) {
	$s.push("xmpp.filter.PacketTypeFilter::accept");
	var $spos = $s.length;
	{
		var $tmp = p._type == this.type;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
xmpp.filter.PacketTypeFilter.prototype.type = null;
xmpp.filter.PacketTypeFilter.prototype.__class__ = xmpp.filter.PacketTypeFilter;
Reflect = function() { }
Reflect.__name__ = ["Reflect"];
Reflect.hasField = function(o,field) {
	$s.push("Reflect::hasField");
	var $spos = $s.length;
	if(o.hasOwnProperty != null) {
		var $tmp = o.hasOwnProperty(field);
		$s.pop();
		return $tmp;
	}
	var arr = Reflect.fields(o);
	{ var $it36 = arr.iterator();
	while( $it36.hasNext() ) { var t = $it36.next();
	if(t == field) {
		$s.pop();
		return true;
	}
	}}
	{
		$s.pop();
		return false;
	}
	$s.pop();
}
Reflect.field = function(o,field) {
	$s.push("Reflect::field");
	var $spos = $s.length;
	var v = null;
	try {
		v = o[field];
	}
	catch( $e37 ) {
		{
			var e = $e37;
			{
				$e = [];
				while($s.length >= $spos) $e.unshift($s.pop());
				$s.push($e[0]);
				null;
			}
		}
	}
	{
		$s.pop();
		return v;
	}
	$s.pop();
}
Reflect.setField = function(o,field,value) {
	$s.push("Reflect::setField");
	var $spos = $s.length;
	o[field] = value;
	$s.pop();
}
Reflect.callMethod = function(o,func,args) {
	$s.push("Reflect::callMethod");
	var $spos = $s.length;
	{
		var $tmp = func.apply(o,args);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
Reflect.fields = function(o) {
	$s.push("Reflect::fields");
	var $spos = $s.length;
	if(o == null) {
		var $tmp = new Array();
		$s.pop();
		return $tmp;
	}
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
		catch( $e38 ) {
			{
				var e = $e38;
				{
					$e = [];
					while($s.length >= $spos) $e.unshift($s.pop());
					$s.push($e[0]);
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
	{
		$s.pop();
		return a;
	}
	$s.pop();
}
Reflect.isFunction = function(f) {
	$s.push("Reflect::isFunction");
	var $spos = $s.length;
	{
		var $tmp = typeof(f) == "function" && f.__name__ == null;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
Reflect.compare = function(a,b) {
	$s.push("Reflect::compare");
	var $spos = $s.length;
	{
		var $tmp = ((a == b)?0:((((a) > (b))?1:-1)));
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
Reflect.compareMethods = function(f1,f2) {
	$s.push("Reflect::compareMethods");
	var $spos = $s.length;
	if(f1 == f2) {
		$s.pop();
		return true;
	}
	if(!Reflect.isFunction(f1) || !Reflect.isFunction(f2)) {
		$s.pop();
		return false;
	}
	{
		var $tmp = f1.scope == f2.scope && f1.method == f2.method && f1.method != null;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
Reflect.isObject = function(v) {
	$s.push("Reflect::isObject");
	var $spos = $s.length;
	if(v == null) {
		$s.pop();
		return false;
	}
	var t = typeof(v);
	{
		var $tmp = (t == "string" || (t == "object" && !v.__enum__) || (t == "function" && v.__name__ != null));
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
Reflect.deleteField = function(o,f) {
	$s.push("Reflect::deleteField");
	var $spos = $s.length;
	if(!Reflect.hasField(o,f)) {
		$s.pop();
		return false;
	}
	delete(o[f]);
	{
		$s.pop();
		return true;
	}
	$s.pop();
}
Reflect.copy = function(o) {
	$s.push("Reflect::copy");
	var $spos = $s.length;
	var o2 = { }
	{
		var _g = 0, _g1 = Reflect.fields(o);
		while(_g < _g1.length) {
			var f = _g1[_g];
			++_g;
			o2[f] = Reflect.field(o,f);
		}
	}
	{
		$s.pop();
		return o2;
	}
	$s.pop();
}
Reflect.makeVarArgs = function(f) {
	$s.push("Reflect::makeVarArgs");
	var $spos = $s.length;
	{
		var $tmp = function() {
			$s.push("Reflect::makeVarArgs@366");
			var $spos = $s.length;
			var a = new Array();
			{
				var _g1 = 0, _g = arguments.length;
				while(_g1 < _g) {
					var i = _g1++;
					a.push(arguments[i]);
				}
			}
			{
				var $tmp = f(a);
				$s.pop();
				return $tmp;
			}
			$s.pop();
		}
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
Reflect.prototype.__class__ = Reflect;
if(typeof event=='undefined') event = {}
event.Dispatcher = function(p) { if( p === $_ ) return; {
	$s.push("event.Dispatcher::new");
	var $spos = $s.length;
	this.listeners = new Array();
	$s.pop();
}}
event.Dispatcher.__name__ = ["event","Dispatcher"];
event.Dispatcher.stop = function() {
	$s.push("event.Dispatcher::stop");
	var $spos = $s.length;
	throw event._Dispatcher.EventException.StopPropagation;
	$s.pop();
}
event.Dispatcher.prototype.addHandler = function(f) {
	$s.push("event.Dispatcher::addHandler");
	var $spos = $s.length;
	{
		var $tmp = this.addListener({ handleEvent : f});
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
event.Dispatcher.prototype.addListener = function(l) {
	$s.push("event.Dispatcher::addListener");
	var $spos = $s.length;
	this.listeners.push(l);
	{
		$s.pop();
		return l;
	}
	$s.pop();
}
event.Dispatcher.prototype.clear = function() {
	$s.push("event.Dispatcher::clear");
	var $spos = $s.length;
	this.listeners = new Array();
	$s.pop();
}
event.Dispatcher.prototype.dispatchEvent = function(e) {
	$s.push("event.Dispatcher::dispatchEvent");
	var $spos = $s.length;
	try {
		{
			var _g = 0, _g1 = this.listeners;
			while(_g < _g1.length) {
				var l = _g1[_g];
				++_g;
				l.handleEvent(e);
			}
		}
		{
			$s.pop();
			return true;
		}
	}
	catch( $e39 ) {
		if( js.Boot.__instanceof($e39,event._Dispatcher.EventException) ) {
			var e1 = $e39;
			{
				$e = [];
				while($s.length >= $spos) $e.unshift($s.pop());
				$s.push($e[0]);
				{
					$s.pop();
					return false;
				}
			}
		} else throw($e39);
	}
	$s.pop();
}
event.Dispatcher.prototype.listeners = null;
event.Dispatcher.prototype.removeListener = function(l) {
	$s.push("event.Dispatcher::removeListener");
	var $spos = $s.length;
	this.listeners.remove(l);
	{
		$s.pop();
		return l;
	}
	$s.pop();
}
event.Dispatcher.prototype.__class__ = event.Dispatcher;
jabber.stream.PacketTimeout = function(handlers,time) { if( handlers === $_ ) return; {
	$s.push("jabber.stream.PacketTimeout::new");
	var $spos = $s.length;
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
	$s.pop();
}}
jabber.stream.PacketTimeout.__name__ = ["jabber","stream","PacketTimeout"];
jabber.stream.PacketTimeout.__super__ = event.Dispatcher;
for(var k in event.Dispatcher.prototype ) jabber.stream.PacketTimeout.prototype[k] = event.Dispatcher.prototype[k];
jabber.stream.PacketTimeout.prototype.collector = null;
jabber.stream.PacketTimeout.prototype.forceTimeout = function() {
	$s.push("jabber.stream.PacketTimeout::forceTimeout");
	var $spos = $s.length;
	this.dispatchEvent(this.collector);
	this.stop();
	$s.pop();
}
jabber.stream.PacketTimeout.prototype.handleTimeout = function() {
	$s.push("jabber.stream.PacketTimeout::handleTimeout");
	var $spos = $s.length;
	this.timer.stop();
	this.timer = null;
	this.dispatchEvent(this.collector);
	$s.pop();
}
jabber.stream.PacketTimeout.prototype.setTime = function(t) {
	$s.push("jabber.stream.PacketTimeout::setTime");
	var $spos = $s.length;
	if(t == 0) t = jabber.stream.PacketTimeout.defaultTimeout;
	this.time = t;
	if(this.timer != null) {
		this.timer.stop();
		{
			this.timer = new haxe.Timer(this.time);
			this.timer.run = $closure(this,"handleTimeout");
		}
	}
	{
		var $tmp = this.time;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jabber.stream.PacketTimeout.prototype.start = function(t) {
	$s.push("jabber.stream.PacketTimeout::start");
	var $spos = $s.length;
	if(this.timer != null) this.timer.stop();
	if(t != null) this.setTime(t);
	{
		this.timer = new haxe.Timer(this.time);
		this.timer.run = $closure(this,"handleTimeout");
	}
	$s.pop();
}
jabber.stream.PacketTimeout.prototype.startTimer = function() {
	$s.push("jabber.stream.PacketTimeout::startTimer");
	var $spos = $s.length;
	this.timer = new haxe.Timer(this.time);
	this.timer.run = $closure(this,"handleTimeout");
	$s.pop();
}
jabber.stream.PacketTimeout.prototype.stop = function() {
	$s.push("jabber.stream.PacketTimeout::stop");
	var $spos = $s.length;
	if(this.timer != null) {
		this.timer.stop();
		this.timer = null;
	}
	$s.pop();
}
jabber.stream.PacketTimeout.prototype.time = null;
jabber.stream.PacketTimeout.prototype.timer = null;
jabber.stream.PacketTimeout.prototype.__class__ = jabber.stream.PacketTimeout;
jabber.Stream = function(cnx) { if( cnx === $_ ) return; {
	$s.push("jabber.Stream::new");
	var $spos = $s.length;
	this.status = jabber.StreamStatus.closed;
	this.server = { features : new Hash()}
	this.features = new jabber._Stream.StreamFeatures();
	this.version = true;
	this.collectors = new List();
	this.interceptors = new List();
	this.http = false;
	this.numPacketsSent = 0;
	if(cnx != null) this.setConnection(cnx);
	$s.pop();
}}
jabber.Stream.__name__ = ["jabber","Stream"];
jabber.Stream.prototype.addCollector = function(c) {
	$s.push("jabber.Stream::addCollector");
	var $spos = $s.length;
	if(Lambda.has(this.collectors,c)) {
		$s.pop();
		return false;
	}
	this.collectors.add(c);
	if(c.timeout != null) c.timeout.start();
	{
		$s.pop();
		return true;
	}
	$s.pop();
}
jabber.Stream.prototype.addInterceptor = function(i) {
	$s.push("jabber.Stream::addInterceptor");
	var $spos = $s.length;
	if(Lambda.has(this.interceptors,i)) {
		$s.pop();
		return false;
	}
	this.interceptors.add(i);
	{
		$s.pop();
		return true;
	}
	$s.pop();
}
jabber.Stream.prototype.close = function(disconnect) {
	$s.push("jabber.Stream::close");
	var $spos = $s.length;
	if(disconnect == null) disconnect = false;
	if(this.status == jabber.StreamStatus.open) {
		if(!this.http) this.sendData("</stream:stream>");
		this.status = jabber.StreamStatus.closed;
	}
	if(disconnect) this.cnx.disconnect();
	this.closeHandler();
	$s.pop();
}
jabber.Stream.prototype.closeHandler = function() {
	$s.push("jabber.Stream::closeHandler");
	var $spos = $s.length;
	this.id = null;
	this.numPacketsSent = 0;
	this.onClose();
	$s.pop();
}
jabber.Stream.prototype.cnx = null;
jabber.Stream.prototype.collect = function(filters,handler,permanent) {
	$s.push("jabber.Stream::collect");
	var $spos = $s.length;
	if(permanent == null) permanent = false;
	var c = new jabber.stream.PacketCollector(filters,handler,permanent);
	{
		var $tmp = (this.addCollector(c)?c:null);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jabber.Stream.prototype.collectors = null;
jabber.Stream.prototype.connectHandler = function() {
	$s.push("jabber.Stream::connectHandler");
	var $spos = $s.length;
	null;
	$s.pop();
}
jabber.Stream.prototype.disconnectHandler = function() {
	$s.push("jabber.Stream::disconnectHandler");
	var $spos = $s.length;
	null;
	$s.pop();
}
jabber.Stream.prototype.errorHandler = function(m) {
	$s.push("jabber.Stream::errorHandler");
	var $spos = $s.length;
	this.onClose(m);
	$s.pop();
}
jabber.Stream.prototype.features = null;
jabber.Stream.prototype.getJIDStr = function() {
	$s.push("jabber.Stream::getJIDStr");
	var $spos = $s.length;
	{
		$s.pop();
		return null;
	}
	$s.pop();
}
jabber.Stream.prototype.handlePacket = function(p) {
	$s.push("jabber.Stream::handlePacket");
	var $spos = $s.length;
	jabber.XMPPDebug.inc(p.toXml().toString());
	var collected = false;
	{ var $it40 = this.collectors.iterator();
	while( $it40.hasNext() ) { var c = $it40.next();
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
		haxe.Log.trace("incoming '" + Type.enumConstructor(p._type) + "' packet not handled ( " + p.from + " -> " + p.to + " )",{ fileName : "Stream.hx", lineNumber : 437, className : "jabber.Stream", methodName : "handlePacket", customParams : ["warn"]});
		if(p._type == xmpp.PacketType.iq) {
			var q = p;
			if(q.type != xmpp.IQType.error) {
				var r = new xmpp.IQ(xmpp.IQType.error,p.id,p.from,p.to);
				r.errors.push(new xmpp.Error(xmpp.ErrorType.cancel,501,"feature-not-implemented"));
				this.sendData(r.toXml().toString());
			}
		}
	}
	{
		$s.pop();
		return collected;
	}
	$s.pop();
}
jabber.Stream.prototype.handleXml = function(x) {
	$s.push("jabber.Stream::handleXml");
	var $spos = $s.length;
	var ps = new Array();
	{ var $it41 = x.elements();
	while( $it41.hasNext() ) { var e = $it41.next();
	{
		var p = xmpp.Packet.parse(e);
		this.handlePacket(p);
		ps.push(p);
	}
	}}
	{
		$s.pop();
		return ps;
	}
	$s.pop();
}
jabber.Stream.prototype.http = null;
jabber.Stream.prototype.id = null;
jabber.Stream.prototype.interceptPacket = function(p) {
	$s.push("jabber.Stream::interceptPacket");
	var $spos = $s.length;
	{ var $it42 = this.interceptors.iterator();
	while( $it42.hasNext() ) { var i = $it42.next();
	i.interceptPacket(p);
	}}
	{
		$s.pop();
		return p;
	}
	$s.pop();
}
jabber.Stream.prototype.interceptors = null;
jabber.Stream.prototype.jidstr = null;
jabber.Stream.prototype.lang = null;
jabber.Stream.prototype.nextID = function() {
	$s.push("jabber.Stream::nextID");
	var $spos = $s.length;
	{
		var $tmp = util.Base64.random(jabber.Stream.packetIDLength) + "_" + this.numPacketsSent;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jabber.Stream.prototype.numPacketsSent = null;
jabber.Stream.prototype.onClose = function(e) {
	$s.push("jabber.Stream::onClose");
	var $spos = $s.length;
	null;
	$s.pop();
}
jabber.Stream.prototype.onOpen = function() {
	$s.push("jabber.Stream::onOpen");
	var $spos = $s.length;
	null;
	$s.pop();
}
jabber.Stream.prototype.open = function() {
	$s.push("jabber.Stream::open");
	var $spos = $s.length;
	if(this.cnx == null) throw "No stream connection set";
	if(this.cnx.connected) this.connectHandler();
	else this.cnx.connect();
	{
		$s.pop();
		return true;
	}
	$s.pop();
}
jabber.Stream.prototype.processData = function(buf,bufpos,buflen) {
	$s.push("jabber.Stream::processData");
	var $spos = $s.length;
	if(this.status == jabber.StreamStatus.closed) {
		$s.pop();
		return -1;
	}
	var t = buf.readString(bufpos,buflen);
	if(StringTools.startsWith(t,"</stream:stream")) {
		this.close(true);
		{
			$s.pop();
			return -1;
		}
	}
	else if(StringTools.startsWith(t,"</stream:error")) {
		{
			$s.pop();
			return -1;
		}
	}
	var $e = (this.status);
	switch( $e[1] ) {
	case 0:
	{
		{
			$s.pop();
			return -1;
		}
	}break;
	case 1:
	{
		{
			var $tmp = this.processStreamInit(util.XmlUtil.removeXmlHeader(t),buflen);
			$s.pop();
			return $tmp;
		}
	}break;
	case 2:
	{
		if(t.charAt(0) != "<" || t.charAt(t.length - 1) != ">") {
			{
				$s.pop();
				return 0;
			}
		}
		var x = null;
		try {
			x = Xml.parse(t);
		}
		catch( $e43 ) {
			{
				var e = $e43;
				{
					$e = [];
					while($s.length >= $spos) $e.unshift($s.pop());
					$s.push($e[0]);
					{
						$s.pop();
						return 0;
					}
				}
			}
		}
		this.handleXml(x);
		{
			$s.pop();
			return buflen;
		}
	}break;
	}
	{
		$s.pop();
		return 0;
	}
	$s.pop();
}
jabber.Stream.prototype.processStreamInit = function(t,buflen) {
	$s.push("jabber.Stream::processStreamInit");
	var $spos = $s.length;
	{
		var $tmp = (function($this) {
			var $r;
			throw "Abstract method";
			return $r;
		}(this));
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jabber.Stream.prototype.removeCollector = function(c) {
	$s.push("jabber.Stream::removeCollector");
	var $spos = $s.length;
	if(!this.collectors.remove(c)) {
		$s.pop();
		return false;
	}
	if(c.timeout != null) c.timeout.stop();
	{
		$s.pop();
		return true;
	}
	$s.pop();
}
jabber.Stream.prototype.removeInterceptor = function(i) {
	$s.push("jabber.Stream::removeInterceptor");
	var $spos = $s.length;
	{
		var $tmp = this.interceptors.remove(i);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jabber.Stream.prototype.sendData = function(t) {
	$s.push("jabber.Stream::sendData");
	var $spos = $s.length;
	if(!this.cnx.connected) {
		$s.pop();
		return null;
	}
	if(!this.cnx.write(t)) {
		$s.pop();
		return null;
	}
	this.numPacketsSent++;
	jabber.XMPPDebug.out(t);
	{
		$s.pop();
		return t;
	}
	$s.pop();
}
jabber.Stream.prototype.sendIQ = function(iq,handler,permanent,timeout,block) {
	$s.push("jabber.Stream::sendIQ");
	var $spos = $s.length;
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
		{
			$s.pop();
			return null;
		}
	}
	{
		var $tmp = { iq : s, collector : c}
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jabber.Stream.prototype.sendMessage = function(to,body,subject,type,thread,from) {
	$s.push("jabber.Stream::sendMessage");
	var $spos = $s.length;
	{
		var $tmp = this.sendPacket(new xmpp.Message(to,body,subject,type,thread,from));
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jabber.Stream.prototype.sendPacket = function(p,intercept) {
	$s.push("jabber.Stream::sendPacket");
	var $spos = $s.length;
	if(intercept == null) intercept = true;
	if(!this.cnx.connected) {
		$s.pop();
		return null;
	}
	if(intercept) this.interceptPacket(p);
	{
		var $tmp = ((this.sendData(p.toString()) != null)?p:null);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jabber.Stream.prototype.sendPresence = function(show,status,priority,type) {
	$s.push("jabber.Stream::sendPresence");
	var $spos = $s.length;
	{
		var $tmp = this.sendPacket(new xmpp.Presence(show,status,priority,type));
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jabber.Stream.prototype.server = null;
jabber.Stream.prototype.setConnection = function(c) {
	$s.push("jabber.Stream::setConnection");
	var $spos = $s.length;
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
	{
		var $tmp = this.cnx;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jabber.Stream.prototype.status = null;
jabber.Stream.prototype.version = null;
jabber.Stream.prototype.__class__ = jabber.Stream;
jabber.client.Stream = function(jid,cnx,version) { if( jid === $_ ) return; {
	$s.push("jabber.client.Stream::new");
	var $spos = $s.length;
	if(version == null) version = true;
	if(jid == null) jid = new jabber.JID(null);
	jabber.Stream.apply(this,[cnx]);
	this.setJID(jid);
	this.version = version;
	$s.pop();
}}
jabber.client.Stream.__name__ = ["jabber","client","Stream"];
jabber.client.Stream.__super__ = jabber.Stream;
for(var k in jabber.Stream.prototype ) jabber.client.Stream.prototype[k] = jabber.Stream.prototype[k];
jabber.client.Stream.prototype.connectHandler = function() {
	$s.push("jabber.client.Stream::connectHandler");
	var $spos = $s.length;
	this.status = jabber.StreamStatus.pending;
	if(!this.http) {
		this.sendData(xmpp.Stream.createOpenStream("jabber:client",this.jid.domain,this.version,this.lang));
		this.cnx.read(true);
	}
	else {
		if(this.cnx.connected) this.cnx.connect();
	}
	$s.pop();
}
jabber.client.Stream.prototype.getJIDStr = function() {
	$s.push("jabber.client.Stream::getJIDStr");
	var $spos = $s.length;
	{
		var $tmp = this.jid.toString();
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jabber.client.Stream.prototype.jid = null;
jabber.client.Stream.prototype.parseStreamFeatures = function(x) {
	$s.push("jabber.client.Stream::parseStreamFeatures");
	var $spos = $s.length;
	{ var $it44 = x.elements();
	while( $it44.hasNext() ) { var e = $it44.next();
	this.server.features.set(e.getNodeName(),e);
	}}
	$s.pop();
}
jabber.client.Stream.prototype.processStreamInit = function(t,buflen) {
	$s.push("jabber.client.Stream::processStreamInit");
	var $spos = $s.length;
	if(this.http) {
		var sx = Xml.parse(t).firstElement();
		var sf = sx.firstElement();
		jabber.XMPPDebug.inc(t);
		this.parseStreamFeatures(sf);
		this.status = jabber.StreamStatus.open;
		this.onOpen();
		{
			$s.pop();
			return buflen;
		}
	}
	else {
		var sei = t.indexOf(">");
		if(sei == -1) {
			{
				$s.pop();
				return 0;
			}
		}
		if(this.id == null) {
			var s = t.substr(0,sei) + " />";
			jabber.XMPPDebug.inc(s);
			var sx = Xml.parse(s).firstElement();
			this.id = sx.get("id");
			if(!this.version) {
				this.status = jabber.StreamStatus.open;
				this.onOpen();
				{
					$s.pop();
					return buflen;
				}
			}
		}
		if(this.id == null) {
			haxe.Log.trace("Invalid XMPP stream, missing ID",{ fileName : "Stream.hx", lineNumber : 87, className : "jabber.client.Stream", methodName : "processStreamInit"});
			this.close(true);
			{
				$s.pop();
				return -1;
			}
		}
		if(!this.version) {
			this.status = jabber.StreamStatus.open;
			this.onOpen();
			{
				$s.pop();
				return buflen;
			}
		}
	}
	var sfi = t.indexOf("<stream:features>");
	var sf = t.substr(t.indexOf("<stream:features>"));
	if(sfi != -1) {
		try {
			var sfx = Xml.parse(sf).firstElement();
			this.parseStreamFeatures(sfx);
			jabber.XMPPDebug.inc(sfx.toString());
			this.status = jabber.StreamStatus.open;
			this.onOpen();
			{
				$s.pop();
				return buflen;
			}
		}
		catch( $e45 ) {
			{
				var e = $e45;
				{
					$e = [];
					while($s.length >= $spos) $e.unshift($s.pop());
					$s.push($e[0]);
					{
						$s.pop();
						return 0;
					}
				}
			}
		}
	}
	{
		$s.pop();
		return buflen;
	}
	$s.pop();
}
jabber.client.Stream.prototype.setJID = function(j) {
	$s.push("jabber.client.Stream::setJID");
	var $spos = $s.length;
	if(this.status != jabber.StreamStatus.closed) throw "Cannot change JID on active stream";
	{
		var $tmp = this.jid = j;
		$s.pop();
		return $tmp;
	}
	$s.pop();
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
	$s.push("IntIter::new");
	var $spos = $s.length;
	this.min = min;
	this.max = max;
	$s.pop();
}}
IntIter.__name__ = ["IntIter"];
IntIter.prototype.hasNext = function() {
	$s.push("IntIter::hasNext");
	var $spos = $s.length;
	{
		var $tmp = this.min < this.max;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
IntIter.prototype.max = null;
IntIter.prototype.min = null;
IntIter.prototype.next = function() {
	$s.push("IntIter::next");
	var $spos = $s.length;
	{
		var $tmp = this.min++;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
IntIter.prototype.__class__ = IntIter;
xmpp.filter.IQFilter = function(xmlns,nodeName,type) { if( xmlns === $_ ) return; {
	$s.push("xmpp.filter.IQFilter::new");
	var $spos = $s.length;
	this.xmlns = xmlns;
	this.nodeName = nodeName;
	this.iqType = type;
	$s.pop();
}}
xmpp.filter.IQFilter.__name__ = ["xmpp","filter","IQFilter"];
xmpp.filter.IQFilter.prototype.accept = function(p) {
	$s.push("xmpp.filter.IQFilter::accept");
	var $spos = $s.length;
	if(p._type != xmpp.PacketType.iq) {
		$s.pop();
		return false;
	}
	var iq = p;
	if(this.iqType != null && this.iqType != iq.type) {
		$s.pop();
		return false;
	}
	var x = null;
	if(this.xmlns != null) {
		if(iq.x == null) {
			$s.pop();
			return false;
		}
		x = iq.x.toXml();
		if(this.xmlns != x.get("xmlns")) {
			$s.pop();
			return false;
		}
	}
	if(this.nodeName != null) {
		if(iq.x == null) {
			$s.pop();
			return false;
		}
		if(x == null) x = iq.x.toXml();
		if(this.nodeName != x.getNodeName()) {
			$s.pop();
			return false;
		}
	}
	{
		$s.pop();
		return true;
	}
	$s.pop();
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
	$s.push("Type::getClass");
	var $spos = $s.length;
	if(o == null) {
		$s.pop();
		return null;
	}
	if(o.__enum__ != null) {
		$s.pop();
		return null;
	}
	{
		var $tmp = o.__class__;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
Type.getEnum = function(o) {
	$s.push("Type::getEnum");
	var $spos = $s.length;
	if(o == null) {
		$s.pop();
		return null;
	}
	{
		var $tmp = o.__enum__;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
Type.getSuperClass = function(c) {
	$s.push("Type::getSuperClass");
	var $spos = $s.length;
	{
		var $tmp = c.__super__;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
Type.getClassName = function(c) {
	$s.push("Type::getClassName");
	var $spos = $s.length;
	if(c == null) {
		$s.pop();
		return null;
	}
	var a = c.__name__;
	{
		var $tmp = a.join(".");
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
Type.getEnumName = function(e) {
	$s.push("Type::getEnumName");
	var $spos = $s.length;
	var a = e.__ename__;
	{
		var $tmp = a.join(".");
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
Type.resolveClass = function(name) {
	$s.push("Type::resolveClass");
	var $spos = $s.length;
	var cl;
	try {
		cl = eval(name);
	}
	catch( $e46 ) {
		{
			var e = $e46;
			{
				$e = [];
				while($s.length >= $spos) $e.unshift($s.pop());
				$s.push($e[0]);
				cl = null;
			}
		}
	}
	if(cl == null || cl.__name__ == null) {
		$s.pop();
		return null;
	}
	{
		$s.pop();
		return cl;
	}
	$s.pop();
}
Type.resolveEnum = function(name) {
	$s.push("Type::resolveEnum");
	var $spos = $s.length;
	var e;
	try {
		e = eval(name);
	}
	catch( $e47 ) {
		{
			var err = $e47;
			{
				$e = [];
				while($s.length >= $spos) $e.unshift($s.pop());
				$s.push($e[0]);
				e = null;
			}
		}
	}
	if(e == null || e.__ename__ == null) {
		$s.pop();
		return null;
	}
	{
		$s.pop();
		return e;
	}
	$s.pop();
}
Type.createInstance = function(cl,args) {
	$s.push("Type::createInstance");
	var $spos = $s.length;
	if(args.length <= 3) {
		var $tmp = new cl(args[0],args[1],args[2]);
		$s.pop();
		return $tmp;
	}
	if(args.length > 8) throw "Too many arguments";
	{
		var $tmp = new cl(args[0],args[1],args[2],args[3],args[4],args[5],args[6],args[7]);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
Type.createEmptyInstance = function(cl) {
	$s.push("Type::createEmptyInstance");
	var $spos = $s.length;
	{
		var $tmp = new cl($_);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
Type.createEnum = function(e,constr,params) {
	$s.push("Type::createEnum");
	var $spos = $s.length;
	var f = Reflect.field(e,constr);
	if(f == null) throw "No such constructor " + constr;
	if(Reflect.isFunction(f)) {
		if(params == null) throw "Constructor " + constr + " need parameters";
		{
			var $tmp = f.apply(e,params);
			$s.pop();
			return $tmp;
		}
	}
	if(params != null && params.length != 0) throw "Constructor " + constr + " does not need parameters";
	{
		$s.pop();
		return f;
	}
	$s.pop();
}
Type.createEnumIndex = function(e,index,params) {
	$s.push("Type::createEnumIndex");
	var $spos = $s.length;
	var c = Type.getEnumConstructs(e)[index];
	if(c == null) throw index + " is not a valid enum constructor index";
	{
		var $tmp = Type.createEnum(e,c,params);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
Type.getInstanceFields = function(c) {
	$s.push("Type::getInstanceFields");
	var $spos = $s.length;
	var a = Reflect.fields(c.prototype);
	a.remove("__class__");
	{
		$s.pop();
		return a;
	}
	$s.pop();
}
Type.getClassFields = function(c) {
	$s.push("Type::getClassFields");
	var $spos = $s.length;
	var a = Reflect.fields(c);
	a.remove("__name__");
	a.remove("__interfaces__");
	a.remove("__super__");
	a.remove("prototype");
	{
		$s.pop();
		return a;
	}
	$s.pop();
}
Type.getEnumConstructs = function(e) {
	$s.push("Type::getEnumConstructs");
	var $spos = $s.length;
	{
		var $tmp = e.__constructs__;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
Type["typeof"] = function(v) {
	$s.push("Type::typeof");
	var $spos = $s.length;
	switch(typeof(v)) {
	case "boolean":{
		{
			var $tmp = ValueType.TBool;
			$s.pop();
			return $tmp;
		}
	}break;
	case "string":{
		{
			var $tmp = ValueType.TClass(String);
			$s.pop();
			return $tmp;
		}
	}break;
	case "number":{
		if(Math.ceil(v) == v % 2147483648.0) {
			var $tmp = ValueType.TInt;
			$s.pop();
			return $tmp;
		}
		{
			var $tmp = ValueType.TFloat;
			$s.pop();
			return $tmp;
		}
	}break;
	case "object":{
		if(v == null) {
			var $tmp = ValueType.TNull;
			$s.pop();
			return $tmp;
		}
		var e = v.__enum__;
		if(e != null) {
			var $tmp = ValueType.TEnum(e);
			$s.pop();
			return $tmp;
		}
		var c = v.__class__;
		if(c != null) {
			var $tmp = ValueType.TClass(c);
			$s.pop();
			return $tmp;
		}
		{
			var $tmp = ValueType.TObject;
			$s.pop();
			return $tmp;
		}
	}break;
	case "function":{
		if(v.__name__ != null) {
			var $tmp = ValueType.TObject;
			$s.pop();
			return $tmp;
		}
		{
			var $tmp = ValueType.TFunction;
			$s.pop();
			return $tmp;
		}
	}break;
	case "undefined":{
		{
			var $tmp = ValueType.TNull;
			$s.pop();
			return $tmp;
		}
	}break;
	default:{
		{
			var $tmp = ValueType.TUnknown;
			$s.pop();
			return $tmp;
		}
	}break;
	}
	$s.pop();
}
Type.enumEq = function(a,b) {
	$s.push("Type::enumEq");
	var $spos = $s.length;
	if(a == b) {
		$s.pop();
		return true;
	}
	try {
		if(a[0] != b[0]) {
			$s.pop();
			return false;
		}
		{
			var _g1 = 2, _g = a.length;
			while(_g1 < _g) {
				var i = _g1++;
				if(!Type.enumEq(a[i],b[i])) {
					$s.pop();
					return false;
				}
			}
		}
		var e = a.__enum__;
		if(e != b.__enum__ || e == null) {
			$s.pop();
			return false;
		}
	}
	catch( $e48 ) {
		{
			var e = $e48;
			{
				$e = [];
				while($s.length >= $spos) $e.unshift($s.pop());
				$s.push($e[0]);
				{
					$s.pop();
					return false;
				}
			}
		}
	}
	{
		$s.pop();
		return true;
	}
	$s.pop();
}
Type.enumConstructor = function(e) {
	$s.push("Type::enumConstructor");
	var $spos = $s.length;
	{
		var $tmp = e[0];
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
Type.enumParameters = function(e) {
	$s.push("Type::enumParameters");
	var $spos = $s.length;
	{
		var $tmp = e.slice(2);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
Type.enumIndex = function(e) {
	$s.push("Type::enumIndex");
	var $spos = $s.length;
	{
		var $tmp = e[1];
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
Type.prototype.__class__ = Type;
if(typeof js=='undefined') js = {}
js.Boot = function() { }
js.Boot.__name__ = ["js","Boot"];
js.Boot.__unhtml = function(s) {
	$s.push("js.Boot::__unhtml");
	var $spos = $s.length;
	{
		var $tmp = s.split("&").join("&amp;").split("<").join("&lt;").split(">").join("&gt;");
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
js.Boot.__trace = function(v,i) {
	$s.push("js.Boot::__trace");
	var $spos = $s.length;
	var msg = (i != null?i.fileName + ":" + i.lineNumber + ": ":"");
	msg += js.Boot.__unhtml(js.Boot.__string_rec(v,"")) + "<br/>";
	var d = document.getElementById("haxe:trace");
	if(d == null) alert("No haxe:trace element defined\n" + msg);
	else d.innerHTML += msg;
	$s.pop();
}
js.Boot.__clear_trace = function() {
	$s.push("js.Boot::__clear_trace");
	var $spos = $s.length;
	var d = document.getElementById("haxe:trace");
	if(d != null) d.innerHTML = "";
	else null;
	$s.pop();
}
js.Boot.__closure = function(o,f) {
	$s.push("js.Boot::__closure");
	var $spos = $s.length;
	var m = o[f];
	if(m == null) {
		$s.pop();
		return null;
	}
	var f1 = function() {
		$s.push("js.Boot::__closure@67");
		var $spos = $s.length;
		{
			var $tmp = m.apply(o,arguments);
			$s.pop();
			return $tmp;
		}
		$s.pop();
	}
	f1.scope = o;
	f1.method = m;
	{
		$s.pop();
		return f1;
	}
	$s.pop();
}
js.Boot.__string_rec = function(o,s) {
	$s.push("js.Boot::__string_rec");
	var $spos = $s.length;
	if(o == null) {
		$s.pop();
		return "null";
	}
	if(s.length >= 5) {
		$s.pop();
		return "<...>";
	}
	var t = typeof(o);
	if(t == "function" && (o.__name__ != null || o.__ename__ != null)) t = "object";
	switch(t) {
	case "object":{
		if(o instanceof Array) {
			if(o.__enum__ != null) {
				if(o.length == 2) {
					var $tmp = o[0];
					$s.pop();
					return $tmp;
				}
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
				{
					var $tmp = str + ")";
					$s.pop();
					return $tmp;
				}
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
			{
				$s.pop();
				return str;
			}
		}
		var tostr;
		try {
			tostr = o.toString;
		}
		catch( $e49 ) {
			{
				var e = $e49;
				{
					$e = [];
					while($s.length >= $spos) $e.unshift($s.pop());
					$s.push($e[0]);
					{
						$s.pop();
						return "???";
					}
				}
			}
		}
		if(tostr != null && tostr != Object.toString) {
			var s2 = o.toString();
			if(s2 != "[object Object]") {
				$s.pop();
				return s2;
			}
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
		{
			$s.pop();
			return str;
		}
	}break;
	case "function":{
		{
			$s.pop();
			return "<function>";
		}
	}break;
	case "string":{
		{
			$s.pop();
			return o;
		}
	}break;
	default:{
		{
			var $tmp = String(o);
			$s.pop();
			return $tmp;
		}
	}break;
	}
	$s.pop();
}
js.Boot.__interfLoop = function(cc,cl) {
	$s.push("js.Boot::__interfLoop");
	var $spos = $s.length;
	if(cc == null) {
		$s.pop();
		return false;
	}
	if(cc == cl) {
		$s.pop();
		return true;
	}
	var intf = cc.__interfaces__;
	if(intf != null) {
		var _g1 = 0, _g = intf.length;
		while(_g1 < _g) {
			var i = _g1++;
			var i1 = intf[i];
			if(i1 == cl || js.Boot.__interfLoop(i1,cl)) {
				$s.pop();
				return true;
			}
		}
	}
	{
		var $tmp = js.Boot.__interfLoop(cc.__super__,cl);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
js.Boot.__instanceof = function(o,cl) {
	$s.push("js.Boot::__instanceof");
	var $spos = $s.length;
	try {
		if(o instanceof cl) {
			if(cl == Array) {
				var $tmp = (o.__enum__ == null);
				$s.pop();
				return $tmp;
			}
			{
				$s.pop();
				return true;
			}
		}
		if(js.Boot.__interfLoop(o.__class__,cl)) {
			$s.pop();
			return true;
		}
	}
	catch( $e50 ) {
		{
			var e = $e50;
			{
				$e = [];
				while($s.length >= $spos) $e.unshift($s.pop());
				$s.push($e[0]);
				if(cl == null) {
					$s.pop();
					return false;
				}
			}
		}
	}
	switch(cl) {
	case Int:{
		{
			var $tmp = Math.ceil(o%2147483648.0) === o;
			$s.pop();
			return $tmp;
		}
	}break;
	case Float:{
		{
			var $tmp = typeof(o) == "number";
			$s.pop();
			return $tmp;
		}
	}break;
	case Bool:{
		{
			var $tmp = o === true || o === false;
			$s.pop();
			return $tmp;
		}
	}break;
	case String:{
		{
			var $tmp = typeof(o) == "string";
			$s.pop();
			return $tmp;
		}
	}break;
	case Dynamic:{
		{
			$s.pop();
			return true;
		}
	}break;
	default:{
		if(o == null) {
			$s.pop();
			return false;
		}
		{
			var $tmp = o.__enum__ == cl || (cl == Class && o.__name__ != null) || (cl == Enum && o.__ename__ != null);
			$s.pop();
			return $tmp;
		}
	}break;
	}
	$s.pop();
}
js.Boot.__init = function() {
	$s.push("js.Boot::__init");
	var $spos = $s.length;
	js.Lib.isIE = (typeof document!='undefined' && document.all != null && typeof window!='undefined' && window.opera == null);
	js.Lib.isOpera = (typeof window!='undefined' && window.opera != null);
	Array.prototype.copy = Array.prototype.slice;
	Array.prototype.insert = function(i,x) {
		$s.push("js.Boot::__init@205");
		var $spos = $s.length;
		this.splice(i,0,x);
		$s.pop();
	}
	Array.prototype.remove = (Array.prototype.indexOf?function(obj) {
		$s.push("js.Boot::__init@208");
		var $spos = $s.length;
		var idx = this.indexOf(obj);
		if(idx == -1) {
			$s.pop();
			return false;
		}
		this.splice(idx,1);
		{
			$s.pop();
			return true;
		}
		$s.pop();
	}:function(obj) {
		$s.push("js.Boot::__init@213");
		var $spos = $s.length;
		var i = 0;
		var l = this.length;
		while(i < l) {
			if(this[i] == obj) {
				this.splice(i,1);
				{
					$s.pop();
					return true;
				}
			}
			i++;
		}
		{
			$s.pop();
			return false;
		}
		$s.pop();
	});
	Array.prototype.iterator = function() {
		$s.push("js.Boot::__init@225");
		var $spos = $s.length;
		{
			var $tmp = { cur : 0, arr : this, hasNext : function() {
				$s.push("js.Boot::__init@225@229");
				var $spos = $s.length;
				{
					var $tmp = this.cur < this.arr.length;
					$s.pop();
					return $tmp;
				}
				$s.pop();
			}, next : function() {
				$s.push("js.Boot::__init@225@232");
				var $spos = $s.length;
				{
					var $tmp = this.arr[this.cur++];
					$s.pop();
					return $tmp;
				}
				$s.pop();
			}}
			$s.pop();
			return $tmp;
		}
		$s.pop();
	}
	var cca = String.prototype.charCodeAt;
	String.prototype.cca = cca;
	String.prototype.charCodeAt = function(i) {
		$s.push("js.Boot::__init@239");
		var $spos = $s.length;
		var x = cca.call(this,i);
		if(isNaN(x)) {
			$s.pop();
			return null;
		}
		{
			$s.pop();
			return x;
		}
		$s.pop();
	}
	var oldsub = String.prototype.substr;
	String.prototype.substr = function(pos,len) {
		$s.push("js.Boot::__init@246");
		var $spos = $s.length;
		if(pos != null && pos != 0 && len != null && len < 0) {
			$s.pop();
			return "";
		}
		if(len == null) len = this.length;
		if(pos < 0) {
			pos = this.length + pos;
			if(pos < 0) pos = 0;
		}
		else if(len < 0) {
			len = this.length + len - pos;
		}
		{
			var $tmp = oldsub.apply(this,[pos,len]);
			$s.pop();
			return $tmp;
		}
		$s.pop();
	}
	$closure = js.Boot.__closure;
	$s.pop();
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
	$s.push("js.JsXml__::new");
	var $spos = $s.length;
	null;
	$s.pop();
}}
js.JsXml__.__name__ = ["js","JsXml__"];
js.JsXml__.parse = function(str) {
	$s.push("js.JsXml__::parse");
	var $spos = $s.length;
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
	{
		$s.pop();
		return current;
	}
	$s.pop();
}
js.JsXml__.createElement = function(name) {
	$s.push("js.JsXml__::createElement");
	var $spos = $s.length;
	var r = new js.JsXml__();
	r.nodeType = Xml.Element;
	r._children = new Array();
	r._attributes = new Hash();
	r.setNodeName(name);
	{
		$s.pop();
		return r;
	}
	$s.pop();
}
js.JsXml__.createPCData = function(data) {
	$s.push("js.JsXml__::createPCData");
	var $spos = $s.length;
	var r = new js.JsXml__();
	r.nodeType = Xml.PCData;
	r.setNodeValue(data);
	{
		$s.pop();
		return r;
	}
	$s.pop();
}
js.JsXml__.createCData = function(data) {
	$s.push("js.JsXml__::createCData");
	var $spos = $s.length;
	var r = new js.JsXml__();
	r.nodeType = Xml.CData;
	r.setNodeValue(data);
	{
		$s.pop();
		return r;
	}
	$s.pop();
}
js.JsXml__.createComment = function(data) {
	$s.push("js.JsXml__::createComment");
	var $spos = $s.length;
	var r = new js.JsXml__();
	r.nodeType = Xml.Comment;
	r.setNodeValue(data);
	{
		$s.pop();
		return r;
	}
	$s.pop();
}
js.JsXml__.createDocType = function(data) {
	$s.push("js.JsXml__::createDocType");
	var $spos = $s.length;
	var r = new js.JsXml__();
	r.nodeType = Xml.DocType;
	r.setNodeValue(data);
	{
		$s.pop();
		return r;
	}
	$s.pop();
}
js.JsXml__.createProlog = function(data) {
	$s.push("js.JsXml__::createProlog");
	var $spos = $s.length;
	var r = new js.JsXml__();
	r.nodeType = Xml.Prolog;
	r.setNodeValue(data);
	{
		$s.pop();
		return r;
	}
	$s.pop();
}
js.JsXml__.createDocument = function() {
	$s.push("js.JsXml__::createDocument");
	var $spos = $s.length;
	var r = new js.JsXml__();
	r.nodeType = Xml.Document;
	r._children = new Array();
	{
		$s.pop();
		return r;
	}
	$s.pop();
}
js.JsXml__.prototype._attributes = null;
js.JsXml__.prototype._children = null;
js.JsXml__.prototype._nodeName = null;
js.JsXml__.prototype._nodeValue = null;
js.JsXml__.prototype._parent = null;
js.JsXml__.prototype.addChild = function(x) {
	$s.push("js.JsXml__::addChild");
	var $spos = $s.length;
	if(this._children == null) throw "bad nodetype";
	if(x._parent != null) x._parent._children.remove(x);
	x._parent = this;
	this._children.push(x);
	$s.pop();
}
js.JsXml__.prototype.attributes = function() {
	$s.push("js.JsXml__::attributes");
	var $spos = $s.length;
	if(this.nodeType != Xml.Element) throw "bad nodeType";
	{
		var $tmp = this._attributes.keys();
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
js.JsXml__.prototype.elements = function() {
	$s.push("js.JsXml__::elements");
	var $spos = $s.length;
	if(this._children == null) throw "bad nodetype";
	{
		var $tmp = { cur : 0, x : this._children, hasNext : function() {
			$s.push("js.JsXml__::elements@285");
			var $spos = $s.length;
			var k = this.cur;
			var l = this.x.length;
			while(k < l) {
				if(this.x[k].nodeType == Xml.Element) break;
				k += 1;
			}
			this.cur = k;
			{
				var $tmp = k < l;
				$s.pop();
				return $tmp;
			}
			$s.pop();
		}, next : function() {
			$s.push("js.JsXml__::elements@296");
			var $spos = $s.length;
			var k = this.cur;
			var l = this.x.length;
			while(k < l) {
				var n = this.x[k];
				k += 1;
				if(n.nodeType == Xml.Element) {
					this.cur = k;
					{
						$s.pop();
						return n;
					}
				}
			}
			{
				$s.pop();
				return null;
			}
			$s.pop();
		}}
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
js.JsXml__.prototype.elementsNamed = function(name) {
	$s.push("js.JsXml__::elementsNamed");
	var $spos = $s.length;
	if(this._children == null) throw "bad nodetype";
	{
		var $tmp = { cur : 0, x : this._children, hasNext : function() {
			$s.push("js.JsXml__::elementsNamed@317");
			var $spos = $s.length;
			var k = this.cur;
			var l = this.x.length;
			while(k < l) {
				var n = this.x[k];
				if(n.nodeType == Xml.Element && n._nodeName == name) break;
				k++;
			}
			this.cur = k;
			{
				var $tmp = k < l;
				$s.pop();
				return $tmp;
			}
			$s.pop();
		}, next : function() {
			$s.push("js.JsXml__::elementsNamed@329");
			var $spos = $s.length;
			var k = this.cur;
			var l = this.x.length;
			while(k < l) {
				var n = this.x[k];
				k++;
				if(n.nodeType == Xml.Element && n._nodeName == name) {
					this.cur = k;
					{
						$s.pop();
						return n;
					}
				}
			}
			{
				$s.pop();
				return null;
			}
			$s.pop();
		}}
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
js.JsXml__.prototype.exists = function(att) {
	$s.push("js.JsXml__::exists");
	var $spos = $s.length;
	if(this.nodeType != Xml.Element) throw "bad nodeType";
	{
		var $tmp = this._attributes.exists(att);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
js.JsXml__.prototype.firstChild = function() {
	$s.push("js.JsXml__::firstChild");
	var $spos = $s.length;
	if(this._children == null) throw "bad nodetype";
	{
		var $tmp = this._children[0];
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
js.JsXml__.prototype.firstElement = function() {
	$s.push("js.JsXml__::firstElement");
	var $spos = $s.length;
	if(this._children == null) throw "bad nodetype";
	var cur = 0;
	var l = this._children.length;
	while(cur < l) {
		var n = this._children[cur];
		if(n.nodeType == Xml.Element) {
			$s.pop();
			return n;
		}
		cur++;
	}
	{
		$s.pop();
		return null;
	}
	$s.pop();
}
js.JsXml__.prototype.get = function(att) {
	$s.push("js.JsXml__::get");
	var $spos = $s.length;
	if(this.nodeType != Xml.Element) throw "bad nodeType";
	{
		var $tmp = this._attributes.get(att);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
js.JsXml__.prototype.getNodeName = function() {
	$s.push("js.JsXml__::getNodeName");
	var $spos = $s.length;
	if(this.nodeType != Xml.Element) throw "bad nodeType";
	{
		var $tmp = this._nodeName;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
js.JsXml__.prototype.getNodeValue = function() {
	$s.push("js.JsXml__::getNodeValue");
	var $spos = $s.length;
	if(this.nodeType == Xml.Element || this.nodeType == Xml.Document) throw "bad nodeType";
	{
		var $tmp = this._nodeValue;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
js.JsXml__.prototype.getParent = function() {
	$s.push("js.JsXml__::getParent");
	var $spos = $s.length;
	{
		var $tmp = this._parent;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
js.JsXml__.prototype.insertChild = function(x,pos) {
	$s.push("js.JsXml__::insertChild");
	var $spos = $s.length;
	if(this._children == null) throw "bad nodetype";
	if(x._parent != null) x._parent._children.remove(x);
	x._parent = this;
	this._children.insert(pos,x);
	$s.pop();
}
js.JsXml__.prototype.iterator = function() {
	$s.push("js.JsXml__::iterator");
	var $spos = $s.length;
	if(this._children == null) throw "bad nodetype";
	{
		var $tmp = { cur : 0, x : this._children, hasNext : function() {
			$s.push("js.JsXml__::iterator@271");
			var $spos = $s.length;
			{
				var $tmp = this.cur < this.x.length;
				$s.pop();
				return $tmp;
			}
			$s.pop();
		}, next : function() {
			$s.push("js.JsXml__::iterator@274");
			var $spos = $s.length;
			{
				var $tmp = this.x[this.cur++];
				$s.pop();
				return $tmp;
			}
			$s.pop();
		}}
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
js.JsXml__.prototype.nodeName = null;
js.JsXml__.prototype.nodeType = null;
js.JsXml__.prototype.nodeValue = null;
js.JsXml__.prototype.parent = null;
js.JsXml__.prototype.remove = function(att) {
	$s.push("js.JsXml__::remove");
	var $spos = $s.length;
	if(this.nodeType != Xml.Element) throw "bad nodeType";
	this._attributes.remove(att);
	$s.pop();
}
js.JsXml__.prototype.removeChild = function(x) {
	$s.push("js.JsXml__::removeChild");
	var $spos = $s.length;
	if(this._children == null) throw "bad nodetype";
	var b = this._children.remove(x);
	if(b) x._parent = null;
	{
		$s.pop();
		return b;
	}
	$s.pop();
}
js.JsXml__.prototype.set = function(att,value) {
	$s.push("js.JsXml__::set");
	var $spos = $s.length;
	if(this.nodeType != Xml.Element) throw "bad nodeType";
	this._attributes.set(att,value);
	$s.pop();
}
js.JsXml__.prototype.setNodeName = function(n) {
	$s.push("js.JsXml__::setNodeName");
	var $spos = $s.length;
	if(this.nodeType != Xml.Element) throw "bad nodeType";
	{
		var $tmp = this._nodeName = n;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
js.JsXml__.prototype.setNodeValue = function(v) {
	$s.push("js.JsXml__::setNodeValue");
	var $spos = $s.length;
	if(this.nodeType == Xml.Element || this.nodeType == Xml.Document) throw "bad nodeType";
	{
		var $tmp = this._nodeValue = v;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
js.JsXml__.prototype.toString = function() {
	$s.push("js.JsXml__::toString");
	var $spos = $s.length;
	if(this.nodeType == Xml.PCData) {
		var $tmp = this._nodeValue;
		$s.pop();
		return $tmp;
	}
	if(this.nodeType == Xml.CData) {
		var $tmp = "<![CDATA[" + this._nodeValue + "]]>";
		$s.pop();
		return $tmp;
	}
	if(this.nodeType == Xml.Comment || this.nodeType == Xml.DocType || this.nodeType == Xml.Prolog) {
		var $tmp = this._nodeValue;
		$s.pop();
		return $tmp;
	}
	var s = new StringBuf();
	if(this.nodeType == Xml.Element) {
		s.b[s.b.length] = "<";
		s.b[s.b.length] = this._nodeName;
		{ var $it51 = this._attributes.keys();
		while( $it51.hasNext() ) { var k = $it51.next();
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
			{
				var $tmp = s.b.join("");
				$s.pop();
				return $tmp;
			}
		}
		s.b[s.b.length] = ">";
	}
	{ var $it52 = this.iterator();
	while( $it52.hasNext() ) { var x = $it52.next();
	s.b[s.b.length] = x.toString();
	}}
	if(this.nodeType == Xml.Element) {
		s.b[s.b.length] = "</";
		s.b[s.b.length] = this._nodeName;
		s.b[s.b.length] = ">";
	}
	{
		var $tmp = s.b.join("");
		$s.pop();
		return $tmp;
	}
	$s.pop();
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
	$s.push("haxe.Timer::new");
	var $spos = $s.length;
	this.id = haxe.Timer.arr.length;
	haxe.Timer.arr[this.id] = this;
	this.timerId = window.setInterval("haxe.Timer.arr[" + this.id + "].run();",time_ms);
	$s.pop();
}}
haxe.Timer.__name__ = ["haxe","Timer"];
haxe.Timer.delay = function(f,time_ms) {
	$s.push("haxe.Timer::delay");
	var $spos = $s.length;
	var t = new haxe.Timer(time_ms);
	t.run = function() {
		$s.push("haxe.Timer::delay@78");
		var $spos = $s.length;
		t.stop();
		f();
		$s.pop();
	}
	{
		$s.pop();
		return t;
	}
	$s.pop();
}
haxe.Timer.stamp = function() {
	$s.push("haxe.Timer::stamp");
	var $spos = $s.length;
	{
		var $tmp = Date.now().getTime() / 1000;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
haxe.Timer.prototype.id = null;
haxe.Timer.prototype.run = function() {
	$s.push("haxe.Timer::run");
	var $spos = $s.length;
	null;
	$s.pop();
}
haxe.Timer.prototype.stop = function() {
	$s.push("haxe.Timer::stop");
	var $spos = $s.length;
	if(this.id == null) {
		$s.pop();
		return;
	}
	window.clearInterval(this.timerId);
	haxe.Timer.arr[this.id] = null;
	if(this.id > 100 && this.id == haxe.Timer.arr.length - 1) {
		var p = this.id - 1;
		while(p >= 0 && haxe.Timer.arr[p] == null) p--;
		haxe.Timer.arr = haxe.Timer.arr.slice(0,p + 1);
	}
	this.id = null;
	$s.pop();
}
haxe.Timer.prototype.timerId = null;
haxe.Timer.prototype.__class__ = haxe.Timer;
jabber.stream.FilterList = function(p) { if( p === $_ ) return; {
	$s.push("jabber.stream.FilterList::new");
	var $spos = $s.length;
	this.clear();
	$s.pop();
}}
jabber.stream.FilterList.__name__ = ["jabber","stream","FilterList"];
jabber.stream.FilterList.prototype.addFilter = function(_f) {
	$s.push("jabber.stream.FilterList::addFilter");
	var $spos = $s.length;
	this.f.push(_f);
	$s.pop();
}
jabber.stream.FilterList.prototype.addIDFilter = function(_f) {
	$s.push("jabber.stream.FilterList::addIDFilter");
	var $spos = $s.length;
	this.fid.push(_f);
	$s.pop();
}
jabber.stream.FilterList.prototype.clear = function() {
	$s.push("jabber.stream.FilterList::clear");
	var $spos = $s.length;
	this.fid = new Array();
	this.f = new Array();
	$s.pop();
}
jabber.stream.FilterList.prototype.f = null;
jabber.stream.FilterList.prototype.fid = null;
jabber.stream.FilterList.prototype.iterator = function() {
	$s.push("jabber.stream.FilterList::iterator");
	var $spos = $s.length;
	{
		var $tmp = this.fid.concat(this.f).iterator();
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jabber.stream.FilterList.prototype.push = function(_f) {
	$s.push("jabber.stream.FilterList::push");
	var $spos = $s.length;
	if(Std["is"](_f,xmpp.filter.PacketIDFilter)) this.fid.push(_f);
	else this.f.push(_f);
	$s.pop();
}
jabber.stream.FilterList.prototype.remove = function(_f) {
	$s.push("jabber.stream.FilterList::remove");
	var $spos = $s.length;
	if(this.fid.remove(_f) || this.f.remove(_f)) {
		$s.pop();
		return true;
	}
	{
		$s.pop();
		return false;
	}
	$s.pop();
}
jabber.stream.FilterList.prototype.unshift = function(_f) {
	$s.push("jabber.stream.FilterList::unshift");
	var $spos = $s.length;
	if(Std["is"](_f,xmpp.filter.PacketIDFilter)) this.fid.unshift(_f);
	else this.f.unshift(_f);
	$s.pop();
}
jabber.stream.FilterList.prototype.__class__ = jabber.stream.FilterList;
IntHash = function(p) { if( p === $_ ) return; {
	$s.push("IntHash::new");
	var $spos = $s.length;
	this.h = {}
	if(this.h.__proto__ != null) {
		this.h.__proto__ = null;
		delete(this.h.__proto__);
	}
	else null;
	$s.pop();
}}
IntHash.__name__ = ["IntHash"];
IntHash.prototype.exists = function(key) {
	$s.push("IntHash::exists");
	var $spos = $s.length;
	{
		var $tmp = this.h[key] != null;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
IntHash.prototype.get = function(key) {
	$s.push("IntHash::get");
	var $spos = $s.length;
	{
		var $tmp = this.h[key];
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
IntHash.prototype.h = null;
IntHash.prototype.iterator = function() {
	$s.push("IntHash::iterator");
	var $spos = $s.length;
	{
		var $tmp = { ref : this.h, it : this.keys(), hasNext : function() {
			$s.push("IntHash::iterator@199");
			var $spos = $s.length;
			{
				var $tmp = this.it.hasNext();
				$s.pop();
				return $tmp;
			}
			$s.pop();
		}, next : function() {
			$s.push("IntHash::iterator@200");
			var $spos = $s.length;
			var i = this.it.next();
			{
				var $tmp = this.ref[i];
				$s.pop();
				return $tmp;
			}
			$s.pop();
		}}
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
IntHash.prototype.keys = function() {
	$s.push("IntHash::keys");
	var $spos = $s.length;
	var a = new Array();
	
			for( x in this.h )
				a.push(x);
		;
	{
		var $tmp = a.iterator();
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
IntHash.prototype.remove = function(key) {
	$s.push("IntHash::remove");
	var $spos = $s.length;
	if(this.h[key] == null) {
		$s.pop();
		return false;
	}
	delete(this.h[key]);
	{
		$s.pop();
		return true;
	}
	$s.pop();
}
IntHash.prototype.set = function(key,value) {
	$s.push("IntHash::set");
	var $spos = $s.length;
	this.h[key] = value;
	$s.pop();
}
IntHash.prototype.toString = function() {
	$s.push("IntHash::toString");
	var $spos = $s.length;
	var s = new StringBuf();
	s.b[s.b.length] = "{";
	var it = this.keys();
	{ var $it53 = it;
	while( $it53.hasNext() ) { var i = $it53.next();
	{
		s.b[s.b.length] = i;
		s.b[s.b.length] = " => ";
		s.b[s.b.length] = Std.string(this.get(i));
		if(it.hasNext()) s.b[s.b.length] = ", ";
	}
	}}
	s.b[s.b.length] = "}";
	{
		var $tmp = s.b.join("");
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
IntHash.prototype.__class__ = IntHash;
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
	$s.push("jabber.client.NonSASLAuthentication::new");
	var $spos = $s.length;
	if(usePlainText == null) usePlainText = false;
	if(stream.http) throw "NonSASL authentication is not supported on HTTP/BOSH connections";
	jabber.client.Authentication.apply(this,[stream]);
	this.usePlainText = usePlainText;
	this.username = stream.jid.node;
	this.active = false;
	$s.pop();
}}
jabber.client.NonSASLAuthentication.__name__ = ["jabber","client","NonSASLAuthentication"];
jabber.client.NonSASLAuthentication.__super__ = jabber.client.Authentication;
for(var k in jabber.client.Authentication.prototype ) jabber.client.NonSASLAuthentication.prototype[k] = jabber.client.Authentication.prototype[k];
jabber.client.NonSASLAuthentication.prototype.active = null;
jabber.client.NonSASLAuthentication.prototype.authenticate = function(password,resource) {
	$s.push("jabber.client.NonSASLAuthentication::authenticate");
	var $spos = $s.length;
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
	{
		$s.pop();
		return true;
	}
	$s.pop();
}
jabber.client.NonSASLAuthentication.prototype.handleResponse = function(iq) {
	$s.push("jabber.client.NonSASLAuthentication::handleResponse");
	var $spos = $s.length;
	var $e = (iq.type);
	switch( $e[1] ) {
	case 2:
	{
		var hasDigest = (!this.usePlainText && iq.x.toXml().elementsNamed("digest").next() != null);
		var r = new xmpp.IQ(xmpp.IQType.set);
		haxe.Log.trace(this.stream.id + " /// " + this.password,{ fileName : "NonSASLAuthentication.hx", lineNumber : 64, className : "jabber.client.NonSASLAuthentication", methodName : "handleResponse"});
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
	$s.pop();
}
jabber.client.NonSASLAuthentication.prototype.handleResult = function(iq) {
	$s.push("jabber.client.NonSASLAuthentication::handleResult");
	var $spos = $s.length;
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
	$s.pop();
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
	$s.push("xmpp.Auth::new");
	var $spos = $s.length;
	this.username = username;
	this.password = password;
	this.digest = digest;
	this.resource = resource;
	$s.pop();
}}
xmpp.Auth.__name__ = ["xmpp","Auth"];
xmpp.Auth.parse = function(x) {
	$s.push("xmpp.Auth::parse");
	var $spos = $s.length;
	var a = new xmpp.Auth();
	{ var $it54 = x.elements();
	while( $it54.hasNext() ) { var e = $it54.next();
	{
		var v = null;
		try {
			v = e.firstChild().getNodeValue();
		}
		catch( $e55 ) {
			{
				var e1 = $e55;
				{
					$e = [];
					while($s.length >= $spos) $e.unshift($s.pop());
					$s.push($e[0]);
					null;
				}
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
	{
		$s.pop();
		return a;
	}
	$s.pop();
}
xmpp.Auth.prototype.digest = null;
xmpp.Auth.prototype.password = null;
xmpp.Auth.prototype.resource = null;
xmpp.Auth.prototype.toString = function() {
	$s.push("xmpp.Auth::toString");
	var $spos = $s.length;
	{
		var $tmp = this.toXml().toString();
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
xmpp.Auth.prototype.toXml = function() {
	$s.push("xmpp.Auth::toXml");
	var $spos = $s.length;
	var x = xmpp.IQ.createQueryXml("jabber:iq:auth");
	if(this.username != null) x.addChild(util.XmlUtil.createElement("username",this.username));
	if(this.password != null) x.addChild(util.XmlUtil.createElement("password",this.password));
	if(this.digest != null) x.addChild(util.XmlUtil.createElement("digest",this.digest));
	if(this.resource != null) x.addChild(util.XmlUtil.createElement("resource",this.resource));
	{
		$s.pop();
		return x;
	}
	$s.pop();
}
xmpp.Auth.prototype.username = null;
xmpp.Auth.prototype.__class__ = xmpp.Auth;
StringBuf = function(p) { if( p === $_ ) return; {
	$s.push("StringBuf::new");
	var $spos = $s.length;
	this.b = new Array();
	$s.pop();
}}
StringBuf.__name__ = ["StringBuf"];
StringBuf.prototype.add = function(x) {
	$s.push("StringBuf::add");
	var $spos = $s.length;
	this.b[this.b.length] = x;
	$s.pop();
}
StringBuf.prototype.addChar = function(c) {
	$s.push("StringBuf::addChar");
	var $spos = $s.length;
	this.b[this.b.length] = String.fromCharCode(c);
	$s.pop();
}
StringBuf.prototype.addSub = function(s,pos,len) {
	$s.push("StringBuf::addSub");
	var $spos = $s.length;
	this.b[this.b.length] = s.substr(pos,len);
	$s.pop();
}
StringBuf.prototype.b = null;
StringBuf.prototype.toString = function() {
	$s.push("StringBuf::toString");
	var $spos = $s.length;
	{
		var $tmp = this.b.join("");
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
StringBuf.prototype.__class__ = StringBuf;
Lambda = function() { }
Lambda.__name__ = ["Lambda"];
Lambda.array = function(it) {
	$s.push("Lambda::array");
	var $spos = $s.length;
	var a = new Array();
	{ var $it56 = it.iterator();
	while( $it56.hasNext() ) { var i = $it56.next();
	a.push(i);
	}}
	{
		$s.pop();
		return a;
	}
	$s.pop();
}
Lambda.list = function(it) {
	$s.push("Lambda::list");
	var $spos = $s.length;
	var l = new List();
	{ var $it57 = it.iterator();
	while( $it57.hasNext() ) { var i = $it57.next();
	l.add(i);
	}}
	{
		$s.pop();
		return l;
	}
	$s.pop();
}
Lambda.map = function(it,f) {
	$s.push("Lambda::map");
	var $spos = $s.length;
	var l = new List();
	{ var $it58 = it.iterator();
	while( $it58.hasNext() ) { var x = $it58.next();
	l.add(f(x));
	}}
	{
		$s.pop();
		return l;
	}
	$s.pop();
}
Lambda.mapi = function(it,f) {
	$s.push("Lambda::mapi");
	var $spos = $s.length;
	var l = new List();
	var i = 0;
	{ var $it59 = it.iterator();
	while( $it59.hasNext() ) { var x = $it59.next();
	l.add(f(i++,x));
	}}
	{
		$s.pop();
		return l;
	}
	$s.pop();
}
Lambda.has = function(it,elt,cmp) {
	$s.push("Lambda::has");
	var $spos = $s.length;
	if(cmp == null) {
		{ var $it60 = it.iterator();
		while( $it60.hasNext() ) { var x = $it60.next();
		if(x == elt) {
			$s.pop();
			return true;
		}
		}}
	}
	else {
		{ var $it61 = it.iterator();
		while( $it61.hasNext() ) { var x = $it61.next();
		if(cmp(x,elt)) {
			$s.pop();
			return true;
		}
		}}
	}
	{
		$s.pop();
		return false;
	}
	$s.pop();
}
Lambda.exists = function(it,f) {
	$s.push("Lambda::exists");
	var $spos = $s.length;
	{ var $it62 = it.iterator();
	while( $it62.hasNext() ) { var x = $it62.next();
	if(f(x)) {
		$s.pop();
		return true;
	}
	}}
	{
		$s.pop();
		return false;
	}
	$s.pop();
}
Lambda.foreach = function(it,f) {
	$s.push("Lambda::foreach");
	var $spos = $s.length;
	{ var $it63 = it.iterator();
	while( $it63.hasNext() ) { var x = $it63.next();
	if(!f(x)) {
		$s.pop();
		return false;
	}
	}}
	{
		$s.pop();
		return true;
	}
	$s.pop();
}
Lambda.iter = function(it,f) {
	$s.push("Lambda::iter");
	var $spos = $s.length;
	{ var $it64 = it.iterator();
	while( $it64.hasNext() ) { var x = $it64.next();
	f(x);
	}}
	$s.pop();
}
Lambda.filter = function(it,f) {
	$s.push("Lambda::filter");
	var $spos = $s.length;
	var l = new List();
	{ var $it65 = it.iterator();
	while( $it65.hasNext() ) { var x = $it65.next();
	if(f(x)) l.add(x);
	}}
	{
		$s.pop();
		return l;
	}
	$s.pop();
}
Lambda.fold = function(it,f,first) {
	$s.push("Lambda::fold");
	var $spos = $s.length;
	{ var $it66 = it.iterator();
	while( $it66.hasNext() ) { var x = $it66.next();
	first = f(x,first);
	}}
	{
		$s.pop();
		return first;
	}
	$s.pop();
}
Lambda.count = function(it) {
	$s.push("Lambda::count");
	var $spos = $s.length;
	var n = 0;
	{ var $it67 = it.iterator();
	while( $it67.hasNext() ) { var _ = $it67.next();
	++n;
	}}
	{
		$s.pop();
		return n;
	}
	$s.pop();
}
Lambda.empty = function(it) {
	$s.push("Lambda::empty");
	var $spos = $s.length;
	{
		var $tmp = !it.iterator().hasNext();
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
Lambda.prototype.__class__ = Lambda;
xmpp.filter.FilterGroup = function(filters) { if( filters === $_ ) return; {
	$s.push("xmpp.filter.FilterGroup::new");
	var $spos = $s.length;
	List.apply(this,[]);
	if(filters != null) {
		{ var $it68 = filters.iterator();
		while( $it68.hasNext() ) { var f = $it68.next();
		this.add(f);
		}}
	}
	$s.pop();
}}
xmpp.filter.FilterGroup.__name__ = ["xmpp","filter","FilterGroup"];
xmpp.filter.FilterGroup.__super__ = List;
for(var k in List.prototype ) xmpp.filter.FilterGroup.prototype[k] = List.prototype[k];
xmpp.filter.FilterGroup.prototype.accept = function(p) {
	$s.push("xmpp.filter.FilterGroup::accept");
	var $spos = $s.length;
	{ var $it69 = this.iterator();
	while( $it69.hasNext() ) { var f = $it69.next();
	{
		if(f.accept(p)) {
			$s.pop();
			return true;
		}
	}
	}}
	{
		$s.pop();
		return false;
	}
	$s.pop();
}
xmpp.filter.FilterGroup.prototype.__class__ = xmpp.filter.FilterGroup;
xmpp.SASL = function() { }
xmpp.SASL.__name__ = ["xmpp","SASL"];
xmpp.SASL.createAuthXml = function(mechansim,text) {
	$s.push("xmpp.SASL::createAuthXml");
	var $spos = $s.length;
	if(mechansim == null) {
		$s.pop();
		return null;
	}
	var a = util.XmlUtil.createElement("auth",text);
	a.set("xmlns","urn:ietf:params:xml:ns:xmpp-sasl");
	a.set("mechanism",mechansim);
	{
		$s.pop();
		return a;
	}
	$s.pop();
}
xmpp.SASL.createResponseXml = function(t) {
	$s.push("xmpp.SASL::createResponseXml");
	var $spos = $s.length;
	if(t == null) {
		$s.pop();
		return null;
	}
	var r = util.XmlUtil.createElement("response",t);
	r.set("xmlns","urn:ietf:params:xml:ns:xmpp-sasl");
	{
		$s.pop();
		return r;
	}
	$s.pop();
}
xmpp.SASL.parseMechanisms = function(x) {
	$s.push("xmpp.SASL::parseMechanisms");
	var $spos = $s.length;
	var m = new Array();
	{ var $it70 = x.elements();
	while( $it70.hasNext() ) { var e = $it70.next();
	{
		if(e.getNodeName() != "mechanism") continue;
		m.push(e.firstChild().getNodeValue());
	}
	}}
	{
		$s.pop();
		return m;
	}
	$s.pop();
}
xmpp.SASL.prototype.__class__ = xmpp.SASL;
jabber.BOSHConnection = function(host,path,hold,wait,secure,maxConcurrentRequests) { if( host === $_ ) return; {
	$s.push("jabber.BOSHConnection::new");
	var $spos = $s.length;
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
	$s.pop();
}}
jabber.BOSHConnection.__name__ = ["jabber","BOSHConnection"];
jabber.BOSHConnection.__super__ = jabber.stream.Connection;
for(var k in jabber.stream.Connection.prototype ) jabber.BOSHConnection.prototype[k] = jabber.stream.Connection.prototype[k];
jabber.BOSHConnection.XMLNS = null;
jabber.BOSHConnection.XMLNS_XMPP = null;
jabber.BOSHConnection.prototype.cleanup = function() {
	$s.push("jabber.BOSHConnection::cleanup");
	var $spos = $s.length;
	this.timeoutTimer.stop();
	this.responseTimer.stop();
	this.connected = this.initialized = false;
	this.sid = null;
	this.requestCount = 0;
	this.requestQueue = null;
	this.responseQueue = null;
	$s.pop();
}
jabber.BOSHConnection.prototype.connect = function() {
	$s.push("jabber.BOSHConnection::connect");
	var $spos = $s.length;
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
		jabber.XMPPDebug.out(b.toString());
		this.sendRequests(b);
	}
	$s.pop();
}
jabber.BOSHConnection.prototype.createRequest = function(t) {
	$s.push("jabber.BOSHConnection::createRequest");
	var $spos = $s.length;
	var x = Xml.createElement("body");
	x.set("xmlns",jabber.BOSHConnection.XMLNS);
	x.set("xml:lang","en");
	x.set("rid",Std.string(++this.rid));
	x.set("sid",this.sid);
	if(t != null) {
		{ var $it71 = t.iterator();
		while( $it71.hasNext() ) { var e = $it71.next();
		{
			x.addChild(Xml.createPCData(e));
		}
		}}
	}
	{
		$s.pop();
		return x;
	}
	$s.pop();
}
jabber.BOSHConnection.prototype.disconnect = function() {
	$s.push("jabber.BOSHConnection::disconnect");
	var $spos = $s.length;
	if(this.connected) {
		var r = this.createRequest();
		r.set("type","terminate");
		r.addChild(new xmpp.Presence(null,null,null,xmpp.PresenceType.unavailable).toXml());
		this.sendRequests(r);
		this.cleanup();
	}
	$s.pop();
}
jabber.BOSHConnection.prototype.getHTTPPath = function() {
	$s.push("jabber.BOSHConnection::getHTTPPath");
	var $spos = $s.length;
	var b = new StringBuf();
	b.b[b.b.length] = "http";
	b.b[b.b.length] = "://";
	b.b[b.b.length] = this.path;
	{
		var $tmp = b.b.join("");
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jabber.BOSHConnection.prototype.handleHTTPData = function(t) {
	$s.push("jabber.BOSHConnection::handleHTTPData");
	var $spos = $s.length;
	var x = null;
	try {
		x = Xml.parse(t).firstElement();
	}
	catch( $e72 ) {
		{
			var e = $e72;
			{
				$e = [];
				while($s.length >= $spos) $e.unshift($s.pop());
				$s.push($e[0]);
				haxe.Log.trace("Invalid XML",{ fileName : "BOSHConnection.hx", lineNumber : 266, className : "jabber.BOSHConnection", methodName : "handleHTTPData"});
				{
					$s.pop();
					return;
				}
			}
		}
	}
	if(x.get("xmlns") != jabber.BOSHConnection.XMLNS) {
		haxe.Log.trace("Invalid BOSH body",{ fileName : "BOSHConnection.hx", lineNumber : 270, className : "jabber.BOSHConnection", methodName : "handleHTTPData"});
		{
			$s.pop();
			return;
		}
	}
	this.requestCount--;
	if(this.timeoutTimer != null) {
		this.timeoutTimer.stop();
	}
	if(this.connected) {
		switch(x.get("type")) {
		case "terminate":{
			this.cleanup();
			haxe.Log.trace("BOSH stream terminated by server",{ fileName : "BOSHConnection.hx", lineNumber : 282, className : "jabber.BOSHConnection", methodName : "handleHTTPData", customParams : ["warn"]});
			this.__onDisconnect();
			{
				$s.pop();
				return;
			}
		}break;
		case "error":{
			{
				$s.pop();
				return;
			}
		}break;
		}
		var c = x.firstElement();
		if(c == null) {
			if(this.requestCount == 0) this.poll();
			else this.sendQueuedRequests();
			{
				$s.pop();
				return;
			}
		}
		{ var $it73 = x.elements();
		while( $it73.hasNext() ) { var e = $it73.next();
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
		if(!this.initialized) {
			$s.pop();
			return;
		}
		this.sid = x.get("sid");
		if(this.sid == null) {
			this.cleanup();
			this.__onError("Invalid SID");
			{
				$s.pop();
				return;
			}
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
	$s.pop();
}
jabber.BOSHConnection.prototype.handleHTTPError = function(e) {
	$s.push("jabber.BOSHConnection::handleHTTPError");
	var $spos = $s.length;
	haxe.Log.trace("handleHTTPError " + e,{ fileName : "BOSHConnection.hx", lineNumber : 256, className : "jabber.BOSHConnection", methodName : "handleHTTPError"});
	this.cleanup();
	this.__onError(e);
	$s.pop();
}
jabber.BOSHConnection.prototype.handlePauseTimeout = function() {
	$s.push("jabber.BOSHConnection::handlePauseTimeout");
	var $spos = $s.length;
	this.pauseTimer.stop();
	this.pollingEnabled = true;
	this.poll();
	$s.pop();
}
jabber.BOSHConnection.prototype.handleTimeout = function() {
	$s.push("jabber.BOSHConnection::handleTimeout");
	var $spos = $s.length;
	this.timeoutTimer.stop();
	this.cleanup();
	this.__onError("BOSH timeout");
	$s.pop();
}
jabber.BOSHConnection.prototype.hold = null;
jabber.BOSHConnection.prototype.inactivity = null;
jabber.BOSHConnection.prototype.initialized = null;
jabber.BOSHConnection.prototype.maxConcurrentRequests = null;
jabber.BOSHConnection.prototype.maxPause = null;
jabber.BOSHConnection.prototype.path = null;
jabber.BOSHConnection.prototype.pause = function(secs) {
	$s.push("jabber.BOSHConnection::pause");
	var $spos = $s.length;
	haxe.Log.trace("Pausing BOSH session for " + secs + " seconds",{ fileName : "BOSHConnection.hx", lineNumber : 160, className : "jabber.BOSHConnection", methodName : "pause"});
	if(secs == null) secs = this.inactivity;
	if(!this.pauseEnabled || secs > this.maxPause) {
		$s.pop();
		return false;
	}
	var r = this.createRequest();
	r.set("pause",Std.string(secs));
	this.sendRequests(r);
	this.pauseTimer = new haxe.Timer(secs * 1000);
	this.pauseTimer.run = $closure(this,"handlePauseTimeout");
	{
		$s.pop();
		return true;
	}
	$s.pop();
}
jabber.BOSHConnection.prototype.pauseEnabled = null;
jabber.BOSHConnection.prototype.pauseTimer = null;
jabber.BOSHConnection.prototype.poll = function() {
	$s.push("jabber.BOSHConnection::poll");
	var $spos = $s.length;
	if(!this.connected || !this.pollingEnabled || this.requestCount > 0 || this.sendQueuedRequests()) {
		$s.pop();
		return;
	}
	this.sendRequests(null,true);
	$s.pop();
}
jabber.BOSHConnection.prototype.pollingEnabled = null;
jabber.BOSHConnection.prototype.processResponse = function() {
	$s.push("jabber.BOSHConnection::processResponse");
	var $spos = $s.length;
	this.responseTimer.stop();
	var x = this.responseQueue.shift();
	var b = haxe.io.Bytes.ofString(x.toString());
	this.__onData(b,0,b.length);
	this.resetResponseProcessor();
	$s.pop();
}
jabber.BOSHConnection.prototype.requestCount = null;
jabber.BOSHConnection.prototype.requestQueue = null;
jabber.BOSHConnection.prototype.resetResponseProcessor = function() {
	$s.push("jabber.BOSHConnection::resetResponseProcessor");
	var $spos = $s.length;
	if(this.responseQueue != null && this.responseQueue.length > 0) {
		this.responseTimer.stop();
		this.responseTimer = new haxe.Timer(0);
		this.responseTimer.run = $closure(this,"processResponse");
	}
	$s.pop();
}
jabber.BOSHConnection.prototype.responseQueue = null;
jabber.BOSHConnection.prototype.responseTimer = null;
jabber.BOSHConnection.prototype.restart = function() {
	$s.push("jabber.BOSHConnection::restart");
	var $spos = $s.length;
	var r = this.createRequest();
	r.set("xmpp:restart","true");
	r.set("xmlns:xmpp",jabber.BOSHConnection.XMLNS_XMPP);
	r.set("xmlns",jabber.BOSHConnection.XMLNS);
	r.set("xml:lang","en");
	r.set("to",this.host);
	jabber.XMPPDebug.out(r.toString());
	this.sendRequests(r);
	$s.pop();
}
jabber.BOSHConnection.prototype.rid = null;
jabber.BOSHConnection.prototype.secure = null;
jabber.BOSHConnection.prototype.sendQueuedRequests = function(t) {
	$s.push("jabber.BOSHConnection::sendQueuedRequests");
	var $spos = $s.length;
	if(t != null) this.requestQueue.push(t);
	else if(this.requestQueue.length == 0) {
		$s.pop();
		return false;
	}
	{
		var $tmp = this.sendRequests(null);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jabber.BOSHConnection.prototype.sendRequests = function(t,poll) {
	$s.push("jabber.BOSHConnection::sendRequests");
	var $spos = $s.length;
	if(poll == null) poll = false;
	if(this.requestCount >= this.maxConcurrentRequests) {
		haxe.Log.trace("max concurrent request limit reached (" + this.requestCount + "," + this.maxConcurrentRequests + ")",{ fileName : "BOSHConnection.hx", lineNumber : 198, className : "jabber.BOSHConnection", methodName : "sendRequests", customParams : ["info"]});
		{
			$s.pop();
			return false;
		}
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
	{
		$s.pop();
		return true;
	}
	$s.pop();
}
jabber.BOSHConnection.prototype.sid = null;
jabber.BOSHConnection.prototype.timeoutOffset = null;
jabber.BOSHConnection.prototype.timeoutTimer = null;
jabber.BOSHConnection.prototype.wait = null;
jabber.BOSHConnection.prototype.write = function(t) {
	$s.push("jabber.BOSHConnection::write");
	var $spos = $s.length;
	this.sendQueuedRequests(t);
	{
		$s.pop();
		return true;
	}
	$s.pop();
}
jabber.BOSHConnection.prototype.__class__ = jabber.BOSHConnection;
if(!event._Dispatcher) event._Dispatcher = {}
event._Dispatcher.EventException = { __ename__ : ["event","_Dispatcher","EventException"], __constructs__ : ["StopPropagation"] }
event._Dispatcher.EventException.StopPropagation = ["StopPropagation",0];
event._Dispatcher.EventException.StopPropagation.toString = $estr;
event._Dispatcher.EventException.StopPropagation.__enum__ = event._Dispatcher.EventException;
xmpp.roster.Item = function(jid,subscription,name,askType,groups) { if( jid === $_ ) return; {
	$s.push("xmpp.roster.Item::new");
	var $spos = $s.length;
	this.jid = jid;
	this.subscription = subscription;
	this.name = name;
	this.askType = askType;
	this.groups = ((groups != null)?groups:new List());
	$s.pop();
}}
xmpp.roster.Item.__name__ = ["xmpp","roster","Item"];
xmpp.roster.Item.parse = function(x) {
	$s.push("xmpp.roster.Item::parse");
	var $spos = $s.length;
	var i = new xmpp.roster.Item(x.get("jid"));
	i.subscription = Type.createEnum(xmpp.roster.Subscription,x.get("subscription"));
	i.name = x.get("name");
	if(x.exists("ask")) i.askType = Type.createEnum(xmpp.roster.AskType,x.get("ask"));
	{ var $it74 = x.elementsNamed("group");
	while( $it74.hasNext() ) { var g = $it74.next();
	i.groups.add(g.firstChild().getNodeValue());
	}}
	{
		$s.pop();
		return i;
	}
	$s.pop();
}
xmpp.roster.Item.prototype.askType = null;
xmpp.roster.Item.prototype.groups = null;
xmpp.roster.Item.prototype.jid = null;
xmpp.roster.Item.prototype.name = null;
xmpp.roster.Item.prototype.subscription = null;
xmpp.roster.Item.prototype.toString = function() {
	$s.push("xmpp.roster.Item::toString");
	var $spos = $s.length;
	{
		var $tmp = this.toXml().toString();
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
xmpp.roster.Item.prototype.toXml = function() {
	$s.push("xmpp.roster.Item::toXml");
	var $spos = $s.length;
	var x = Xml.createElement("item");
	x.set("jid",this.jid);
	if(this.name != null) x.set("name",this.name);
	if(this.subscription != null) x.set("subscription",Type.enumConstructor(this.subscription));
	if(this.askType != null) x.set("ask",Type.enumConstructor(this.askType));
	{ var $it75 = this.groups.iterator();
	while( $it75.hasNext() ) { var group = $it75.next();
	x.addChild(util.XmlUtil.createElement("group",group));
	}}
	{
		$s.pop();
		return x;
	}
	$s.pop();
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
	$s.push("xmpp.Message::new");
	var $spos = $s.length;
	this._type = xmpp.PacketType.message;
	xmpp.Packet.apply(this,[to,from]);
	this.type = (type != null?type:xmpp.MessageType.chat);
	this.body = body;
	this.subject = subject;
	this.thread = thread;
	$s.pop();
}}
xmpp.Message.__name__ = ["xmpp","Message"];
xmpp.Message.__super__ = xmpp.Packet;
for(var k in xmpp.Packet.prototype ) xmpp.Message.prototype[k] = xmpp.Packet.prototype[k];
xmpp.Message.parse = function(x) {
	$s.push("xmpp.Message::parse");
	var $spos = $s.length;
	var m = new xmpp.Message(null,null,null,(x.exists("type")?Type.createEnum(xmpp.MessageType,x.get("type")):null));
	xmpp.Packet.parseAttributes(m,x);
	{ var $it76 = x.elements();
	while( $it76.hasNext() ) { var c = $it76.next();
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
	{
		$s.pop();
		return m;
	}
	$s.pop();
}
xmpp.Message.prototype.body = null;
xmpp.Message.prototype.subject = null;
xmpp.Message.prototype.thread = null;
xmpp.Message.prototype.toXml = function() {
	$s.push("xmpp.Message::toXml");
	var $spos = $s.length;
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
	{
		$s.pop();
		return x;
	}
	$s.pop();
}
xmpp.Message.prototype.type = null;
xmpp.Message.prototype.__class__ = xmpp.Message;
if(!haxe.io) haxe.io = {}
haxe.io.Bytes = function(length,b) { if( length === $_ ) return; {
	$s.push("haxe.io.Bytes::new");
	var $spos = $s.length;
	this.length = length;
	this.b = b;
	$s.pop();
}}
haxe.io.Bytes.__name__ = ["haxe","io","Bytes"];
haxe.io.Bytes.alloc = function(length) {
	$s.push("haxe.io.Bytes::alloc");
	var $spos = $s.length;
	var a = new Array();
	{
		var _g = 0;
		while(_g < length) {
			var i = _g++;
			a.push(0);
		}
	}
	{
		var $tmp = new haxe.io.Bytes(length,a);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
haxe.io.Bytes.ofString = function(s) {
	$s.push("haxe.io.Bytes::ofString");
	var $spos = $s.length;
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
	{
		var $tmp = new haxe.io.Bytes(a.length,a);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
haxe.io.Bytes.ofData = function(b) {
	$s.push("haxe.io.Bytes::ofData");
	var $spos = $s.length;
	{
		var $tmp = new haxe.io.Bytes(b.length,b);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
haxe.io.Bytes.prototype.b = null;
haxe.io.Bytes.prototype.blit = function(pos,src,srcpos,len) {
	$s.push("haxe.io.Bytes::blit");
	var $spos = $s.length;
	if(pos < 0 || srcpos < 0 || len < 0 || pos + len > this.length || srcpos + len > src.length) throw haxe.io.Error.OutsideBounds;
	var b1 = this.b;
	var b2 = src.b;
	if(b1 == b2 && pos > srcpos) {
		var i = len;
		while(i > 0) {
			i--;
			b1[i + pos] = b2[i + srcpos];
		}
		{
			$s.pop();
			return;
		}
	}
	{
		var _g = 0;
		while(_g < len) {
			var i = _g++;
			b1[i + pos] = b2[i + srcpos];
		}
	}
	$s.pop();
}
haxe.io.Bytes.prototype.compare = function(other) {
	$s.push("haxe.io.Bytes::compare");
	var $spos = $s.length;
	var b1 = this.b;
	var b2 = other.b;
	var len = ((this.length < other.length)?this.length:other.length);
	{
		var _g = 0;
		while(_g < len) {
			var i = _g++;
			if(b1[i] != b2[i]) {
				var $tmp = b1[i] - b2[i];
				$s.pop();
				return $tmp;
			}
		}
	}
	{
		var $tmp = this.length - other.length;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
haxe.io.Bytes.prototype.get = function(pos) {
	$s.push("haxe.io.Bytes::get");
	var $spos = $s.length;
	{
		var $tmp = this.b[pos];
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
haxe.io.Bytes.prototype.getData = function() {
	$s.push("haxe.io.Bytes::getData");
	var $spos = $s.length;
	{
		var $tmp = this.b;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
haxe.io.Bytes.prototype.length = null;
haxe.io.Bytes.prototype.readString = function(pos,len) {
	$s.push("haxe.io.Bytes::readString");
	var $spos = $s.length;
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
	{
		$s.pop();
		return s;
	}
	$s.pop();
}
haxe.io.Bytes.prototype.set = function(pos,v) {
	$s.push("haxe.io.Bytes::set");
	var $spos = $s.length;
	this.b[pos] = (v & 255);
	$s.pop();
}
haxe.io.Bytes.prototype.sub = function(pos,len) {
	$s.push("haxe.io.Bytes::sub");
	var $spos = $s.length;
	if(pos < 0 || len < 0 || pos + len > this.length) throw haxe.io.Error.OutsideBounds;
	{
		var $tmp = new haxe.io.Bytes(len,this.b.slice(pos,pos + len));
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
haxe.io.Bytes.prototype.toString = function() {
	$s.push("haxe.io.Bytes::toString");
	var $spos = $s.length;
	{
		var $tmp = this.readString(0,this.length);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
haxe.io.Bytes.prototype.__class__ = haxe.io.Bytes;
util.Base64 = function() { }
util.Base64.__name__ = ["util","Base64"];
util.Base64.CHARS = null;
util.Base64.bc = null;
util.Base64.fillNullbits = function(s) {
	$s.push("util.Base64::fillNullbits");
	var $spos = $s.length;
	while(s.length % 3 != 0) s += "=";
	{
		$s.pop();
		return s;
	}
	$s.pop();
}
util.Base64.removeNullbits = function(s) {
	$s.push("util.Base64::removeNullbits");
	var $spos = $s.length;
	while(s.charAt(s.length - 1) == "=") s = s.substr(0,s.length - 1);
	{
		$s.pop();
		return s;
	}
	$s.pop();
}
util.Base64.encode = function(t) {
	$s.push("util.Base64::encode");
	var $spos = $s.length;
	{
		var $tmp = util.Base64.fillNullbits(util.Base64.bc.encodeString(t));
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
util.Base64.decode = function(t) {
	$s.push("util.Base64::decode");
	var $spos = $s.length;
	{
		var $tmp = util.Base64.bc.decodeString(util.Base64.removeNullbits(t));
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
util.Base64.random = function(len) {
	$s.push("util.Base64::random");
	var $spos = $s.length;
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
	{
		var $tmp = b.b.join("");
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
util.Base64.prototype.__class__ = util.Base64;
xmpp.Roster = function(items) { if( items === $_ ) return; {
	$s.push("xmpp.Roster::new");
	var $spos = $s.length;
	List.apply(this,[]);
	if(items != null) { var $it77 = items.iterator();
	while( $it77.hasNext() ) { var i = $it77.next();
	this.add(i);
	}}
	$s.pop();
}}
xmpp.Roster.__name__ = ["xmpp","Roster"];
xmpp.Roster.__super__ = List;
for(var k in List.prototype ) xmpp.Roster.prototype[k] = List.prototype[k];
xmpp.Roster.parse = function(x) {
	$s.push("xmpp.Roster::parse");
	var $spos = $s.length;
	var r = new xmpp.Roster();
	{ var $it78 = x.elementsNamed("item");
	while( $it78.hasNext() ) { var e = $it78.next();
	r.add(xmpp.roster.Item.parse(e));
	}}
	{
		$s.pop();
		return r;
	}
	$s.pop();
}
xmpp.Roster.prototype.toString = function() {
	$s.push("xmpp.Roster::toString");
	var $spos = $s.length;
	{
		var $tmp = this.toXml().toString();
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
xmpp.Roster.prototype.toXml = function() {
	$s.push("xmpp.Roster::toXml");
	var $spos = $s.length;
	var x = xmpp.IQ.createQueryXml("jabber:iq:roster");
	{ var $it79 = this.iterator();
	while( $it79.hasNext() ) { var i = $it79.next();
	x.addChild(i.toXml());
	}}
	{
		$s.pop();
		return x;
	}
	$s.pop();
}
xmpp.Roster.prototype.__class__ = xmpp.Roster;
haxe.Log = function() { }
haxe.Log.__name__ = ["haxe","Log"];
haxe.Log.trace = function(v,infos) {
	$s.push("haxe.Log::trace");
	var $spos = $s.length;
	js.Boot.__trace(v,infos);
	$s.pop();
}
haxe.Log.clear = function() {
	$s.push("haxe.Log::clear");
	var $spos = $s.length;
	js.Boot.__clear_trace();
	$s.pop();
}
haxe.Log.prototype.__class__ = haxe.Log;
Hash = function(p) { if( p === $_ ) return; {
	$s.push("Hash::new");
	var $spos = $s.length;
	this.h = {}
	if(this.h.__proto__ != null) {
		this.h.__proto__ = null;
		delete(this.h.__proto__);
	}
	else null;
	$s.pop();
}}
Hash.__name__ = ["Hash"];
Hash.prototype.exists = function(key) {
	$s.push("Hash::exists");
	var $spos = $s.length;
	try {
		key = "$" + key;
		{
			var $tmp = this.hasOwnProperty.call(this.h,key);
			$s.pop();
			return $tmp;
		}
	}
	catch( $e80 ) {
		{
			var e = $e80;
			{
				$e = [];
				while($s.length >= $spos) $e.unshift($s.pop());
				$s.push($e[0]);
				
				for(var i in this.h)
					if( i == key ) return true;
			;
				{
					$s.pop();
					return false;
				}
			}
		}
	}
	$s.pop();
}
Hash.prototype.get = function(key) {
	$s.push("Hash::get");
	var $spos = $s.length;
	{
		var $tmp = this.h["$" + key];
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
Hash.prototype.h = null;
Hash.prototype.iterator = function() {
	$s.push("Hash::iterator");
	var $spos = $s.length;
	{
		var $tmp = { ref : this.h, it : this.keys(), hasNext : function() {
			$s.push("Hash::iterator@214");
			var $spos = $s.length;
			{
				var $tmp = this.it.hasNext();
				$s.pop();
				return $tmp;
			}
			$s.pop();
		}, next : function() {
			$s.push("Hash::iterator@215");
			var $spos = $s.length;
			var i = this.it.next();
			{
				var $tmp = this.ref["$" + i];
				$s.pop();
				return $tmp;
			}
			$s.pop();
		}}
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
Hash.prototype.keys = function() {
	$s.push("Hash::keys");
	var $spos = $s.length;
	var a = new Array();
	
			for(var i in this.h)
				a.push(i.substr(1));
		;
	{
		var $tmp = a.iterator();
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
Hash.prototype.remove = function(key) {
	$s.push("Hash::remove");
	var $spos = $s.length;
	if(!this.exists(key)) {
		$s.pop();
		return false;
	}
	delete(this.h["$" + key]);
	{
		$s.pop();
		return true;
	}
	$s.pop();
}
Hash.prototype.set = function(key,value) {
	$s.push("Hash::set");
	var $spos = $s.length;
	this.h["$" + key] = value;
	$s.pop();
}
Hash.prototype.toString = function() {
	$s.push("Hash::toString");
	var $spos = $s.length;
	var s = new StringBuf();
	s.b[s.b.length] = "{";
	var it = this.keys();
	{ var $it81 = it;
	while( $it81.hasNext() ) { var i = $it81.next();
	{
		s.b[s.b.length] = i;
		s.b[s.b.length] = " => ";
		s.b[s.b.length] = Std.string(this.get(i));
		if(it.hasNext()) s.b[s.b.length] = ", ";
	}
	}}
	s.b[s.b.length] = "}";
	{
		var $tmp = s.b.join("");
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
Hash.prototype.__class__ = Hash;
if(!jabber._Stream) jabber._Stream = {}
jabber._Stream.StreamFeatures = function(p) { if( p === $_ ) return; {
	$s.push("jabber._Stream.StreamFeatures::new");
	var $spos = $s.length;
	this.l = new List();
	$s.pop();
}}
jabber._Stream.StreamFeatures.__name__ = ["jabber","_Stream","StreamFeatures"];
jabber._Stream.StreamFeatures.prototype.add = function(f) {
	$s.push("jabber._Stream.StreamFeatures::add");
	var $spos = $s.length;
	if(Lambda.has(this.l,f)) {
		$s.pop();
		return false;
	}
	this.l.add(f);
	{
		$s.pop();
		return true;
	}
	$s.pop();
}
jabber._Stream.StreamFeatures.prototype.iterator = function() {
	$s.push("jabber._Stream.StreamFeatures::iterator");
	var $spos = $s.length;
	{
		var $tmp = this.l.iterator();
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jabber._Stream.StreamFeatures.prototype.l = null;
jabber._Stream.StreamFeatures.prototype.__class__ = jabber._Stream.StreamFeatures;
jabber.XMPPError = function(dispatcher,p) { if( dispatcher === $_ ) return; {
	$s.push("jabber.XMPPError::new");
	var $spos = $s.length;
	var e = p.errors[0];
	if(e == null) throw "Packet has no errors";
	xmpp.Error.apply(this,[e.type,e.code,e.name,e.text]);
	this.dispatcher = dispatcher;
	this.from = p.from;
	$s.pop();
}}
jabber.XMPPError.__name__ = ["jabber","XMPPError"];
jabber.XMPPError.__super__ = xmpp.Error;
for(var k in xmpp.Error.prototype ) jabber.XMPPError.prototype[k] = xmpp.Error.prototype[k];
jabber.XMPPError.prototype.dispatcher = null;
jabber.XMPPError.prototype.from = null;
jabber.XMPPError.prototype.toString = function() {
	$s.push("jabber.XMPPError::toString");
	var $spos = $s.length;
	{
		var $tmp = "XMPPError( " + this.from + ", " + this.name + ", " + this.code + ", " + this.text + " )";
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jabber.XMPPError.prototype.__class__ = jabber.XMPPError;
Std = function() { }
Std.__name__ = ["Std"];
Std["is"] = function(v,t) {
	$s.push("Std::is");
	var $spos = $s.length;
	{
		var $tmp = js.Boot.__instanceof(v,t);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
Std.string = function(s) {
	$s.push("Std::string");
	var $spos = $s.length;
	{
		var $tmp = js.Boot.__string_rec(s,"");
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
Std["int"] = function(x) {
	$s.push("Std::int");
	var $spos = $s.length;
	if(x < 0) {
		var $tmp = Math.ceil(x);
		$s.pop();
		return $tmp;
	}
	{
		var $tmp = Math.floor(x);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
Std.parseInt = function(x) {
	$s.push("Std::parseInt");
	var $spos = $s.length;
	var v = parseInt(x);
	if(Math.isNaN(v)) {
		$s.pop();
		return null;
	}
	{
		$s.pop();
		return v;
	}
	$s.pop();
}
Std.parseFloat = function(x) {
	$s.push("Std::parseFloat");
	var $spos = $s.length;
	{
		var $tmp = parseFloat(x);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
Std.random = function(x) {
	$s.push("Std::random");
	var $spos = $s.length;
	{
		var $tmp = Math.floor(Math.random() * x);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
Std.prototype.__class__ = Std;
if(typeof net=='undefined') net = {}
if(!net.sasl) net.sasl = {}
net.sasl.PlainMechanism = function(p) { if( p === $_ ) return; {
	$s.push("net.sasl.PlainMechanism::new");
	var $spos = $s.length;
	this.id = net.sasl.PlainMechanism.ID;
	$s.pop();
}}
net.sasl.PlainMechanism.__name__ = ["net","sasl","PlainMechanism"];
net.sasl.PlainMechanism.ID = null;
net.sasl.PlainMechanism.prototype.createAuthenticationText = function(username,host,password) {
	$s.push("net.sasl.PlainMechanism::createAuthenticationText");
	var $spos = $s.length;
	var b = new StringBuf();
	b.b[b.b.length] = username;
	b.b[b.b.length] = "@";
	b.b[b.b.length] = host;
	b.b[b.b.length] = String.fromCharCode(0);
	b.b[b.b.length] = username;
	b.b[b.b.length] = String.fromCharCode(0);
	b.b[b.b.length] = password;
	{
		var $tmp = b.b.join("");
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
net.sasl.PlainMechanism.prototype.createChallengeResponse = function(c) {
	$s.push("net.sasl.PlainMechanism::createChallengeResponse");
	var $spos = $s.length;
	{
		$s.pop();
		return null;
	}
	$s.pop();
}
net.sasl.PlainMechanism.prototype.id = null;
net.sasl.PlainMechanism.prototype.__class__ = net.sasl.PlainMechanism;
xmpp.filter.PacketIDFilter = function(id) { if( id === $_ ) return; {
	$s.push("xmpp.filter.PacketIDFilter::new");
	var $spos = $s.length;
	this.id = id;
	$s.pop();
}}
xmpp.filter.PacketIDFilter.__name__ = ["xmpp","filter","PacketIDFilter"];
xmpp.filter.PacketIDFilter.prototype.accept = function(p) {
	$s.push("xmpp.filter.PacketIDFilter::accept");
	var $spos = $s.length;
	{
		var $tmp = p.id == this.id;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
xmpp.filter.PacketIDFilter.prototype.id = null;
xmpp.filter.PacketIDFilter.prototype.__class__ = xmpp.filter.PacketIDFilter;
if(typeof crypt=='undefined') crypt = {}
crypt.SHA1 = function(p) { if( p === $_ ) return; {
	$s.push("crypt.SHA1::new");
	var $spos = $s.length;
	null;
	$s.pop();
}}
crypt.SHA1.__name__ = ["crypt","SHA1"];
crypt.SHA1.encode = function(t) {
	$s.push("crypt.SHA1::encode");
	var $spos = $s.length;
	{
		var $tmp = new crypt.SHA1().__encode__(t);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
crypt.SHA1.prototype.__encode__ = function(s) {
	$s.push("crypt.SHA1::__encode__");
	var $spos = $s.length;
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
	{
		var $tmp = this.hex(a) + this.hex(b) + this.hex(c) + this.hex(d) + this.hex(e);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
crypt.SHA1.prototype.add = function(x,y) {
	$s.push("crypt.SHA1::add");
	var $spos = $s.length;
	var lsw = (x & 65535) + (y & 65535);
	var msw = (x >> 16) + (y >> 16) + (lsw >> 16);
	{
		var $tmp = (msw << 16) | (lsw & 65535);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
crypt.SHA1.prototype.ft = function(t,b,c,d) {
	$s.push("crypt.SHA1::ft");
	var $spos = $s.length;
	if(t < 20) {
		var $tmp = (b & c) | ((~b) & d);
		$s.pop();
		return $tmp;
	}
	if(t < 40) {
		var $tmp = (b ^ c) ^ d;
		$s.pop();
		return $tmp;
	}
	if(t < 60) {
		var $tmp = ((b & c) | (b & d)) | (c & d);
		$s.pop();
		return $tmp;
	}
	{
		var $tmp = (b ^ c) ^ d;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
crypt.SHA1.prototype.hex = function(n) {
	$s.push("crypt.SHA1::hex");
	var $spos = $s.length;
	var s = "";
	var j = 7;
	while(j >= 0) {
		s += "0123456789abcdef".charAt((n >> (j * 4)) & 15);
		j--;
	}
	{
		$s.pop();
		return s;
	}
	$s.pop();
}
crypt.SHA1.prototype.kt = function(t) {
	$s.push("crypt.SHA1::kt");
	var $spos = $s.length;
	{
		var $tmp = ((t < 20)?1518500249:((t < 40)?1859775393:((t < 60)?-1894007588:-899497514)));
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
crypt.SHA1.prototype.rol = function(n,c) {
	$s.push("crypt.SHA1::rol");
	var $spos = $s.length;
	{
		var $tmp = (n << c) | (n >>> (32 - c));
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
crypt.SHA1.prototype.str2blks = function(s) {
	$s.push("crypt.SHA1::str2blks");
	var $spos = $s.length;
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
	{
		$s.pop();
		return bb;
	}
	$s.pop();
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
	$s.push("jabber.JID::new");
	var $spos = $s.length;
	if(str != null) {
		if(!jabber.JIDUtil.isValid(str)) throw "Invalid JID: " + str;
		this.node = str.substr(0,str.indexOf("@"));
		this.domain = jabber.JIDUtil.parseDomain(str);
		this.resource = jabber.JIDUtil.parseResource(str);
	}
	$s.pop();
}}
jabber.JID.__name__ = ["jabber","JID"];
jabber.JID.prototype.bare = null;
jabber.JID.prototype.domain = null;
jabber.JID.prototype.getBare = function() {
	$s.push("jabber.JID::getBare");
	var $spos = $s.length;
	{
		var $tmp = ((this.node == null || this.domain == null)?null:this.node + "@" + this.domain);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jabber.JID.prototype.node = null;
jabber.JID.prototype.resource = null;
jabber.JID.prototype.toString = function() {
	$s.push("jabber.JID::toString");
	var $spos = $s.length;
	var j = this.getBare();
	if(j == null) {
		$s.pop();
		return null;
	}
	{
		var $tmp = ((this.resource == null)?j:j += "/" + this.resource);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
jabber.JID.prototype.__class__ = jabber.JID;
xmpp.PlainPacket = function(src) { if( src === $_ ) return; {
	$s.push("xmpp.PlainPacket::new");
	var $spos = $s.length;
	xmpp.Packet.apply(this,[]);
	this._type = xmpp.PacketType.custom;
	this.src = src;
	$s.pop();
}}
xmpp.PlainPacket.__name__ = ["xmpp","PlainPacket"];
xmpp.PlainPacket.__super__ = xmpp.Packet;
for(var k in xmpp.Packet.prototype ) xmpp.PlainPacket.prototype[k] = xmpp.Packet.prototype[k];
xmpp.PlainPacket.prototype.src = null;
xmpp.PlainPacket.prototype.toXml = function() {
	$s.push("xmpp.PlainPacket::toXml");
	var $spos = $s.length;
	{
		var $tmp = this.src;
		$s.pop();
		return $tmp;
	}
	$s.pop();
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
	$s.push("net.sasl.Handshake::new");
	var $spos = $s.length;
	this.mechanisms = new Array();
	$s.pop();
}}
net.sasl.Handshake.__name__ = ["net","sasl","Handshake"];
net.sasl.Handshake.prototype.getAuthenticationText = function(username,host,password) {
	$s.push("net.sasl.Handshake::getAuthenticationText");
	var $spos = $s.length;
	if(this.mechanism == null) {
		$s.pop();
		return null;
	}
	{
		var $tmp = this.mechanism.createAuthenticationText(username,host,password);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
net.sasl.Handshake.prototype.getChallengeResponse = function(challenge) {
	$s.push("net.sasl.Handshake::getChallengeResponse");
	var $spos = $s.length;
	if(this.mechanism == null) {
		$s.pop();
		return null;
	}
	{
		var $tmp = this.mechanism.createChallengeResponse(challenge);
		$s.pop();
		return $tmp;
	}
	$s.pop();
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
	$s.push("js.Lib::alert");
	var $spos = $s.length;
	alert(js.Boot.__string_rec(v,""));
	$s.pop();
}
js.Lib.eval = function(code) {
	$s.push("js.Lib::eval");
	var $spos = $s.length;
	{
		var $tmp = eval(code);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
js.Lib.setErrorHandler = function(f) {
	$s.push("js.Lib::setErrorHandler");
	var $spos = $s.length;
	js.Lib.onerror = f;
	$s.pop();
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
	$s.push("xmpp.Stream::createOpenStream");
	var $spos = $s.length;
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
	{
		var $tmp = ((xmlHeader)?util.XmlUtil.XML_HEADER + b.b.join(""):b.b.join(""));
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
xmpp.Stream.prototype.__class__ = xmpp.Stream;
StringTools = function() { }
StringTools.__name__ = ["StringTools"];
StringTools.urlEncode = function(s) {
	$s.push("StringTools::urlEncode");
	var $spos = $s.length;
	{
		var $tmp = encodeURIComponent(s);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
StringTools.urlDecode = function(s) {
	$s.push("StringTools::urlDecode");
	var $spos = $s.length;
	{
		var $tmp = decodeURIComponent(s.split("+").join(" "));
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
StringTools.htmlEscape = function(s) {
	$s.push("StringTools::htmlEscape");
	var $spos = $s.length;
	{
		var $tmp = s.split("&").join("&amp;").split("<").join("&lt;").split(">").join("&gt;");
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
StringTools.htmlUnescape = function(s) {
	$s.push("StringTools::htmlUnescape");
	var $spos = $s.length;
	{
		var $tmp = s.split("&gt;").join(">").split("&lt;").join("<").split("&amp;").join("&");
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
StringTools.startsWith = function(s,start) {
	$s.push("StringTools::startsWith");
	var $spos = $s.length;
	{
		var $tmp = (s.length >= start.length && s.substr(0,start.length) == start);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
StringTools.endsWith = function(s,end) {
	$s.push("StringTools::endsWith");
	var $spos = $s.length;
	var elen = end.length;
	var slen = s.length;
	{
		var $tmp = (slen >= elen && s.substr(slen - elen,elen) == end);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
StringTools.isSpace = function(s,pos) {
	$s.push("StringTools::isSpace");
	var $spos = $s.length;
	var c = s.charCodeAt(pos);
	{
		var $tmp = (c >= 9 && c <= 13) || c == 32;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
StringTools.ltrim = function(s) {
	$s.push("StringTools::ltrim");
	var $spos = $s.length;
	var l = s.length;
	var r = 0;
	while(r < l && StringTools.isSpace(s,r)) {
		r++;
	}
	if(r > 0) {
		var $tmp = s.substr(r,l - r);
		$s.pop();
		return $tmp;
	}
	else {
		$s.pop();
		return s;
	}
	$s.pop();
}
StringTools.rtrim = function(s) {
	$s.push("StringTools::rtrim");
	var $spos = $s.length;
	var l = s.length;
	var r = 0;
	while(r < l && StringTools.isSpace(s,l - r - 1)) {
		r++;
	}
	if(r > 0) {
		{
			var $tmp = s.substr(0,l - r);
			$s.pop();
			return $tmp;
		}
	}
	else {
		{
			$s.pop();
			return s;
		}
	}
	$s.pop();
}
StringTools.trim = function(s) {
	$s.push("StringTools::trim");
	var $spos = $s.length;
	{
		var $tmp = StringTools.ltrim(StringTools.rtrim(s));
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
StringTools.rpad = function(s,c,l) {
	$s.push("StringTools::rpad");
	var $spos = $s.length;
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
	{
		$s.pop();
		return s;
	}
	$s.pop();
}
StringTools.lpad = function(s,c,l) {
	$s.push("StringTools::lpad");
	var $spos = $s.length;
	var ns = "";
	var sl = s.length;
	if(sl >= l) {
		$s.pop();
		return s;
	}
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
	{
		var $tmp = ns + s;
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
StringTools.replace = function(s,sub,by) {
	$s.push("StringTools::replace");
	var $spos = $s.length;
	{
		var $tmp = s.split(sub).join(by);
		$s.pop();
		return $tmp;
	}
	$s.pop();
}
StringTools.hex = function(n,digits) {
	$s.push("StringTools::hex");
	var $spos = $s.length;
	var neg = false;
	if(n < 0) {
		neg = true;
		n = -n;
	}
	var s = n.toString(16);
	s = s.toUpperCase();
	if(digits != null) while(s.length < digits) s = "0" + s;
	if(neg) s = "-" + s;
	{
		$s.pop();
		return s;
	}
	$s.pop();
}
StringTools.prototype.__class__ = StringTools;
$_ = {}
js.Boot.__res = {}
$s = [];
$e = [];
js.Boot.__init();
{
	try {
		jabber.XMPPDebug.useConsole = console != null && console.error != null;
	}
	catch( $e82 ) {
		{
			var e = $e82;
			{
				jabber.XMPPDebug.useConsole = false;
			}
		}
	}
}
{
	js["XMLHttpRequest"] = (window.XMLHttpRequest?XMLHttpRequest:(window.ActiveXObject?function() {
		$s.push("StringTools::hex");
		var $spos = $s.length;
		try {
			{
				var $tmp = new ActiveXObject("Msxml2.XMLHTTP");
				$s.pop();
				return $tmp;
			}
		}
		catch( $e83 ) {
			{
				var e = $e83;
				{
					$e = [];
					while($s.length >= $spos) $e.unshift($s.pop());
					$s.push($e[0]);
					try {
						{
							var $tmp = new ActiveXObject("Microsoft.XMLHTTP");
							$s.pop();
							return $tmp;
						}
					}
					catch( $e84 ) {
						{
							var e1 = $e84;
							{
								$e = [];
								while($s.length >= $spos) $e.unshift($s.pop());
								$s.push($e[0]);
								throw "Unable to create XMLHttpRequest object.";
							}
						}
					}
				}
			}
		}
		$s.pop();
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
		$s.push("StringTools::hex");
		var $spos = $s.length;
		{
			var $tmp = isFinite(i);
			$s.pop();
			return $tmp;
		}
		$s.pop();
	}
	Math.isNaN = function(i) {
		$s.push("StringTools::hex");
		var $spos = $s.length;
		{
			var $tmp = isNaN(i);
			$s.pop();
			return $tmp;
		}
		$s.pop();
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
		var stack = $s.copy();
		var f = js.Lib.onerror;
		$s.splice(0,$s.length);
		if( f == null ) {
			var i = stack.length;
			var s = "";
			while( --i >= 0 )
				s += "Called from "+stack[i]+"\n";
			alert(msg+"\n\n"+s);
			return false;
		}
		return f(msg,stack);
	}
}
{
	Date.now = function() {
		$s.push("StringTools::hex");
		var $spos = $s.length;
		{
			var $tmp = new Date();
			$s.pop();
			return $tmp;
		}
		$s.pop();
	}
	Date.fromTime = function(t) {
		$s.push("StringTools::hex");
		var $spos = $s.length;
		var d = new Date();
		d["setTime"](t);
		{
			$s.pop();
			return d;
		}
		$s.pop();
	}
	Date.fromString = function(s) {
		$s.push("StringTools::hex");
		var $spos = $s.length;
		switch(s.length) {
		case 8:{
			var k = s.split(":");
			var d = new Date();
			d["setTime"](0);
			d["setUTCHours"](k[0]);
			d["setUTCMinutes"](k[1]);
			d["setUTCSeconds"](k[2]);
			{
				$s.pop();
				return d;
			}
		}break;
		case 10:{
			var k = s.split("-");
			{
				var $tmp = new Date(k[0],k[1] - 1,k[2],0,0,0);
				$s.pop();
				return $tmp;
			}
		}break;
		case 19:{
			var k = s.split(" ");
			var y = k[0].split("-");
			var t = k[1].split(":");
			{
				var $tmp = new Date(y[0],y[1] - 1,y[2],t[0],t[1],t[2]);
				$s.pop();
				return $tmp;
			}
		}break;
		default:{
			throw "Invalid date format : " + s;
		}break;
		}
		$s.pop();
	}
	Date.prototype["toString"] = function() {
		$s.push("StringTools::hex");
		var $spos = $s.length;
		var date = this;
		var m = date.getMonth() + 1;
		var d = date.getDate();
		var h = date.getHours();
		var mi = date.getMinutes();
		var s = date.getSeconds();
		{
			var $tmp = date.getFullYear() + "-" + ((m < 10?"0" + m:"" + m)) + "-" + ((d < 10?"0" + d:"" + d)) + " " + ((h < 10?"0" + h:"" + h)) + ":" + ((mi < 10?"0" + mi:"" + mi)) + ":" + ((s < 10?"0" + s:"" + s));
			$s.pop();
			return $tmp;
		}
		$s.pop();
	}
	Date.prototype.__class__ = Date;
	Date.__name__ = ["Date"];
}
util.XmlUtil.XML_HEADER = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>";
jabber.client.Roster.defaultSubscriptionMode = jabber.client.RosterSubscriptionMode.manual;
haxe.Serializer.USE_CACHE = false;
haxe.Serializer.USE_ENUM_INDEX = false;
haxe.Serializer.BASE64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789%:";
jabber.JIDUtil.MAX_PARTSIZE = 1023;
jabber.JIDUtil.EREG = new EReg("[A-Z0-9._%-]+@[A-Z0-9.-]+(\\.[A-Z]{3}?)?(/[A-Z0-9._%-])?","i");
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
