package xmpp;

import xmpp.Jingle;

using StringTools;

/**
	A media section of a session description: the `m=` line and its attributes (without `a=`).
**/
private typedef SdpMedia = {
	var kind:String;
	var port:String;
	var protocol:String;
	var formats:Array<String>;
	var attributes:Array<String>;
}

/**
	Audio and video sessions (calls) with Jingle RTP, as WebRTC uses them: the session descriptions (SDP) of a
	WebRTC implementation are converted to Jingle contents and back.

	Each media (audio, video) is a content: an RTP `description` (codecs, RTCP feedback, header extensions, sources)
	and an ICE-UDP `transport` (credentials, candidates, DTLS fingerprint). The contents of one connection are grouped
	(`BUNDLE`, a `<group/>` next to the contents). Candidates are exchanged while connecting (trickle ICE) with
	`transport-info`, see `candidateContent` and `candidates`.

		// caller: the offer of WebRTC
		final offer = JingleRtp.fromSdp(sdp, true);
		final session = jingle.createSession(peer);
		session.onAccept = contents -> webrtc.setRemoteDescription(JingleRtp.toSdp(contents, JingleRtp.group(session.payload), false));
		session.initiate(offer.contents, offer.payload);

		// callee
		jingle.onSessionInitiate = session -> {
			webrtc.setRemoteDescription(JingleRtp.toSdp(session.contents, JingleRtp.group(session.payload), true));
			final answer = JingleRtp.fromSdp(answerSdp, false);
			session.accept(answer.contents, answer.payload);
		}

	[XEP-0167: Jingle RTP Sessions](https://xmpp.org/extensions/xep-0167.html)
	[XEP-0176: Jingle ICE-UDP Transport Method](https://xmpp.org/extensions/xep-0176.html)
	[XEP-0320: Use of DTLS-SRTP in Jingle Sessions](https://xmpp.org/extensions/xep-0320.html)
	[XEP-0338: Jingle Grouping Framework](https://xmpp.org/extensions/xep-0338.html)
	[XEP-0293: Jingle RTP Feedback Negotiation](https://xmpp.org/extensions/xep-0293.html)
	[XEP-0294: Jingle RTP Header Extensions Negotiation](https://xmpp.org/extensions/xep-0294.html)
	[XEP-0339: Source-Specific Media Attributes in Jingle](https://xmpp.org/extensions/xep-0339.html)
**/
@xep(167)
class JingleRtp {
	public static inline var XMLNS = "urn:xmpp:jingle:apps:rtp:1";
	public static inline var XMLNS_AUDIO = "urn:xmpp:jingle:apps:rtp:audio";
	public static inline var XMLNS_VIDEO = "urn:xmpp:jingle:apps:rtp:video";

	/** Namespace of the `session-info` of calls, e.g. `<ringing/>`, `<mute name="…"/>` **/
	public static inline var XMLNS_INFO = "urn:xmpp:jingle:apps:rtp:info:1";

	public static inline var XMLNS_ICE_UDP = "urn:xmpp:jingle:transports:ice-udp:1";
	public static inline var XMLNS_DTLS = "urn:xmpp:jingle:apps:dtls:0";
	public static inline var XMLNS_GROUPING = "urn:xmpp:jingle:apps:grouping:0";
	public static inline var XMLNS_RTCP_FB = "urn:xmpp:jingle:apps:rtp:rtcp-fb:0";
	public static inline var XMLNS_HDREXT = "urn:xmpp:jingle:apps:rtp:rtp-hdrext:0";
	public static inline var XMLNS_SSMA = "urn:xmpp:jingle:apps:rtp:ssma:0";

	/** Features to advertise for audio calls **/
	public static final FEATURES_AUDIO = [XMLNS, XMLNS_AUDIO, XMLNS_ICE_UDP, XMLNS_DTLS];

	/** Features to advertise for audio and video calls **/
	public static final FEATURES = FEATURES_AUDIO.concat([XMLNS_VIDEO]);

	/**
		Converts a session description (an offer or answer) to contents, and the other elements of the request or
		acceptance (`payload`: the group of the contents).
		`initiator`: the description is of the initiator of the session (for the direction of the media).
	**/
	public static function fromSdp(sdp:String, initiator:Bool):{contents:Array<JingleContent>, payload:Array<XML>} {
		final parsed = parseSdp(sdp);
		final contents = [
			for (m in parsed.media)
				{
					creator: JingleCreator.initiator,
					name: value(m.attributes, "mid") ?? m.kind,
					senders: senders(direction(m.attributes) ?? direction(parsed.session) ?? "sendrecv", initiator),
					description: createDescription(m),
					transport: createTransport(m, parsed.session)
				}
		];
		final payload = [];
		final bundle = value(parsed.session, "group");
		if (bundle != null) {
			final parts = bundle.split(" ");
			final group = XML.create("group").set("xmlns", XMLNS_GROUPING).set("semantics", parts.shift());
			for (name in parts)
				if (name.length > 0)
					group.append(XML.create("content").set("name", name));
			payload.push(group);
		}
		return {contents: contents, payload: payload};
	}

	/**
		Converts contents (with RTP descriptions and ICE-UDP transports) and their group to a session description.
		`initiator`: the contents are of the initiator of the session.
	**/
	public static function toSdp(contents:Array<JingleContent>, ?group:XML, initiator:Bool, ?sessionId:String):String {
		final lines = ["v=0", 'o=- ${sessionId ?? "0"} 2 IN IP4 0.0.0.0', "s=-", "t=0 0"];
		if (group != null)
			lines.push('a=group:${group.get("semantics") ?? "BUNDLE"} ' + [for (c in group.elements.named("content")) c.get("name")].join(" "));
		for (c in contents) {
			final d = c.description;
			final t = c.transport;
			if (d == null || !d.is(XMLNS))
				continue;
			final types = d.elements.named("payload-type");
			lines.push('m=${d.get("media")} 9 UDP/TLS/RTP/SAVPF ' + [for (p in types) p.get("id")].join(" "));
			lines.push("c=IN IP4 0.0.0.0");
			if (t != null) {
				lines.push('a=ice-ufrag:${t.get("ufrag")}');
				lines.push('a=ice-pwd:${t.get("pwd")}');
				for (f in t.elements.named("fingerprint"))
					if (f.is(XMLNS_DTLS)) {
						lines.push('a=fingerprint:${f.get("hash")} ${f.text}');
						lines.push('a=setup:${f.get("setup") ?? "actpass"}');
					}
			}
			lines.push('a=mid:${c.name}');
			lines.push('a=${sdpDirection(c.senders ?? both, initiator)}');
			if (d.elements.named("rtcp-mux").length > 0)
				lines.push("a=rtcp-mux");
			for (p in types) {
				final id = p.get("id");
				lines.push('a=rtpmap:$id ${p.get("name")}/${p.get("clockrate")}'
					+ (p.has("channels") && p.get("channels") != "1" ? '/${p.get("channels")}' : ''));
				final params = [
					for (e in p.elements.named("parameter"))
						((e.get("name") ?? "").length > 0)
					?'${e.get("name")}=${e.get("value")}':e.get
					("value")
				];
				if (params.length > 0)
					lines.push('a=fmtp:$id ${params.join(";")}');
				for (fb in p.elements.named("rtcp-fb"))
					lines.push('a=rtcp-fb:$id ${fb.get("type")}' + (fb.has("subtype") ? ' ${fb.get("subtype")}' : ''));
				if (p.has("ptime"))
					lines.push('a=ptime:${p.get("ptime")}');
			}
			for (fb in d.elements.named("rtcp-fb"))
				lines.push('a=rtcp-fb:* ${fb.get("type")}' + (fb.has("subtype") ? ' ${fb.get("subtype")}' : ''));
			for (e in d.elements.named("rtp-hdrext"))
				lines.push('a=extmap:${e.get("id")} ${e.get("uri")}');
			if (d.elements.named("extmap-allow-mixed").length > 0)
				lines.push("a=extmap-allow-mixed");
			for (g in d.elements.named("ssrc-group"))
				lines.push('a=ssrc-group:${g.get("semantics")} ' + [for (s in g.elements.named("source")) s.get("ssrc")].join(" "));
			for (s in d.elements.named("source"))
				for (p in s.elements.named("parameter"))
					lines.push('a=ssrc:${s.get("ssrc")} ${p.get("name")}' + (p.has("value") ? ':${p.get("value")}' : ''));
			if (t != null)
				for (e in t.elements.named("candidate"))
					lines.push("a=" + candidateToSdp(e));
		}
		return lines.join("\r\n") + "\r\n";
	}

	/** The `<group/>` of contents in the payload of a session (`JingleSession.payload`), `null` if there is none **/
	public static function group(payload:Array<XML>):Null<XML> {
		for (e in payload)
			if (e.name == "group" && e.is(XMLNS_GROUPING))
				return e;
		return null;
	}

	/** The media of a content (`audio`, `video`), `null` if it is no RTP session **/
	public static function media(content:JingleContent):Null<String>
		return (content.description != null && content.description.is(XMLNS)) ? content.description.get("media") : null;

	/**
		A content for `transport-info` with an ICE candidate of the own content `content` (an SDP `candidate:` line),
		`null` for other than UDP candidates.
	**/
	public static function candidateContent(content:JingleContent, candidate:String):Null<JingleContent> {
		final c = candidateFromSdp(candidate);
		if (c == null || content.transport == null)
			return null;
		return {
			creator: content.creator,
			name: content.name,
			transport: XML.create("transport")
				.set("xmlns", XMLNS_ICE_UDP)
				.set("ufrag", content.transport.get("ufrag"))
				.set("pwd", content.transport.get("pwd"))
				.append(c)};
	}

	/** The ICE candidates of an ICE-UDP transport (e.g. of `transport-info`), as SDP `candidate:` lines **/
	public static function candidates(transport:Null<XML>):Array<String>
		return (transport == null || !transport.is(XMLNS_ICE_UDP)) ? [] : [for (c in transport.elements.named("candidate")) candidateToSdp(c)];

	/**
		Converts an SDP candidate (`candidate:1 1 UDP 2015363327 192.168.0.11 56938 typ host`, with or without `a=`)
		to a `<candidate/>`; `null` if it is invalid or not UDP.
	**/
	public static function candidateFromSdp(line:String):Null<XML> {
		line = line.trim();
		if (line.startsWith("a="))
			line = line.substr(2);
		if (!line.startsWith("candidate:"))
			return null;
		final f = line.substr("candidate:".length).split(" ").filter(s -> s.length > 0);
		if (f.length < 8 || f[2].toLowerCase() != "udp" || f[6] != "typ")
			return null;
		final x = XML.create("candidate")
			.set("foundation", f[0])
			.set("component", f[1])
			.set("protocol", "udp")
			.set("priority", f[3])
			.set("ip", f[4])
			.set("port", f[5])
			.set("type", f[7])
			.set("generation", "0")
			.set("network", "0")
			.set("id", xmpp.Stream.makeRandomId());
		var i = 8;
		while (i + 1 < f.length) {
			switch f[i] {
				case "raddr":
					x.set("rel-addr", f[i + 1]);
				case "rport":
					x.set("rel-port", f[i + 1]);
				case "generation":
					x.set("generation", f[i + 1]);
				case "network-id":
					x.set("network", f[i + 1]);
				case _:
			}
			i += 2;
		}
		return x;
	}

	/** Converts a `<candidate/>` to an SDP candidate (without `a=`) **/
	public static function candidateToSdp(c:XML):String {
		var s = 'candidate:${c.get("foundation")} ${c.get("component")} ${(c.get("protocol") ?? "udp").toUpperCase()} ${c.get("priority")} ${c.get("ip")} ${c.get("port")} typ ${c.get("type")}';
		if (c.has("rel-addr"))
			s += ' raddr ${c.get("rel-addr")} rport ${c.get("rel-port")}';
		return s + ' generation ${c.get("generation") ?? "0"}';
	}

	static function createDescription(m:SdpMedia):XML {
		final d = XML.create("description").set("xmlns", XMLNS).set("media", m.kind);
		final ptime = value(m.attributes, "ptime");
		final maxptime = value(m.attributes, "maxptime");
		for (id in m.formats) {
			final rtpmap = valueOf(m.attributes, "rtpmap", id);
			if (rtpmap == null)
				continue;
			final parts = rtpmap.split("/");
			final p = XML.create("payload-type")
				.set("id", id)
				.set("name", parts[0])
				.set("clockrate", parts[1])
				.set("channels", parts[2])
				.set("ptime", ptime)
				.set("maxptime", maxptime);
			final fmtp = valueOf(m.attributes, "fmtp", id);
			if (fmtp != null)
				for (param in fmtp.split(";")) {
					param = param.trim();
					final i = param.indexOf("=");
					p.append((i == -1) ? XML.create("parameter")
						.set("value", param) : XML.create("parameter").set("name", param.substr(0, i).trim()).set("value", param.substr(i + 1).trim()));
				}
			for (fb in valuesOf(m.attributes, "rtcp-fb", id))
				p.append(feedback(fb));
			d.append(p);
		}
		for (fb in valuesOf(m.attributes, "rtcp-fb", "*"))
			d.append(feedback(fb));
		for (ext in values(m.attributes, "extmap")) {
			final parts = ext.split(" ");
			d.append(XML.create("rtp-hdrext")
				.set("xmlns", XMLNS_HDREXT)
				.set("id", parts[0].split("/")[0])
				.set("uri", parts[1]));
		}
		if (m.attributes.contains("extmap-allow-mixed"))
			d.append(XML.create("extmap-allow-mixed").set("xmlns", XMLNS_HDREXT));
		if (m.attributes.contains("rtcp-mux"))
			d.append(XML.create("rtcp-mux"));
		for (g in values(m.attributes, "ssrc-group")) {
			final parts = g.split(" ");
			final group = XML.create("ssrc-group").set("xmlns", XMLNS_SSMA).set("semantics", parts.shift());
			for (ssrc in parts)
				group.append(XML.create("source").set("ssrc", ssrc));
			d.append(group);
		}
		final sources = new Map<String, XML>();
		for (s in values(m.attributes, "ssrc")) {
			final i = s.indexOf(" ");
			final ssrc = (i == -1) ? s : s.substr(0, i);
			var source = sources.get(ssrc);
			if (source == null) {
				sources.set(ssrc, source = XML.create("source").set("xmlns", XMLNS_SSMA).set("ssrc", ssrc));
				d.append(source);
			}
			if (i != -1) {
				final attr = s.substr(i + 1);
				final j = attr.indexOf(":");
				source.append(XML.create("parameter").set("name", (j == -1) ? attr : attr.substr(0, j)).set("value", (j == -1) ? null : attr.substr(j + 1)));
			}
		}
		return d;
	}

	static function feedback(fb:String):XML {
		final parts = fb.split(" ");
		return XML.create("rtcp-fb").set("xmlns", XMLNS_RTCP_FB).set("type", parts[0]).set("subtype", parts[1]);
	}

	static function createTransport(m:SdpMedia, session:Array<String>):XML {
		final t = XML.create("transport")
			.set("xmlns", XMLNS_ICE_UDP)
			.set("ufrag", value(m.attributes, "ice-ufrag") ?? value(session, "ice-ufrag"))
			.set("pwd", value(m.attributes, "ice-pwd") ?? value(session, "ice-pwd"));
		final fingerprint = value(m.attributes, "fingerprint") ?? value(session, "fingerprint");
		if (fingerprint != null) {
			final i = fingerprint.indexOf(" ");
			t.append(XML.create("fingerprint", null, fingerprint.substr(i + 1))
				.set("xmlns", XMLNS_DTLS)
				.set("hash", fingerprint.substr(0, i))
				.set("setup", value(m.attributes, "setup") ?? value(session, "setup") ?? "actpass"));
		}
		for (c in values(m.attributes, "candidate")) {
			final x = candidateFromSdp('candidate:$c');
			if (x != null)
				t.append(x);
		}
		return t;
	}

	/** The `senders` of a content with the SDP direction of the initiator or responder **/
	static function senders(direction:String, initiator:Bool):JingleSenders
		return switch direction {
			case "sendonly": initiator ? JingleSenders.initiator : JingleSenders.responder;
			case "recvonly": initiator ? JingleSenders.responder : JingleSenders.initiator;
			case "inactive": none;
			case _: both;
		}

	/** The SDP direction of the initiator or responder for `senders` **/
	static function sdpDirection(senders:JingleSenders, initiator:Bool):String
		return switch senders {
			case JingleSenders.initiator: initiator ? "sendonly" : "recvonly";
			case JingleSenders.responder: initiator ? "recvonly" : "sendonly";
			case none: "inactive";
			case _: "sendrecv";
		}

	static function direction(attributes:Array<String>):Null<String> {
		for (a in attributes)
			if (a == "sendrecv" || a == "sendonly" || a == "recvonly" || a == "inactive")
				return a;
		return null;
	}

	static function parseSdp(sdp:String):{session:Array<String>, media:Array<SdpMedia>} {
		final session = new Array<String>();
		final media = new Array<SdpMedia>();
		for (line in sdp.split("\n")) {
			line = line.trim();
			if (line.startsWith("m=")) {
				final f = line.substr(2).split(" ");
				media.push({
					kind: f[0],
					port: f[1],
					protocol: f[2],
					formats: f.slice(3),
					attributes: []
				});
			} else if (line.startsWith("a="))
				(media.length > 0 ? media[media.length - 1].attributes : session).push(line.substr(2));
		}
		return {session: session, media: media};
	}

	/** The values of the attributes `name` (`name:value`) **/
	static function values(attributes:Array<String>, name:String):Array<String>
		return [for (a in attributes) if (a.startsWith('$name:')) a.substr(name.length + 1)];

	static function value(attributes:Array<String>, name:String):Null<String>
		return values(attributes, name)[0];

	/** The values of the attributes `name` for format `id` (`name:id value`) **/
	static function valuesOf(attributes:Array<String>, name:String, id:String):Array<String>
		return [
			for (v in values(attributes, name)) if (v.startsWith('$id ')) v.substr(id.length + 1)
		];

	static function valueOf(attributes:Array<String>, name:String, id:String):Null<String>
		return valuesOf(attributes, name, id)[0];
}
