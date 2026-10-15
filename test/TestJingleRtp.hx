import utest.Assert.*;
import xmpp.Jingle;
import xmpp.JingleRtp;
import xmpp.XML;

using StringTools;

class TestJingleRtp extends utest.Test {
	/** An offer of GStreamer's webrtcbin: audio and video, bundled **/
	static final OFFER = [
		"v=0",
		"o=- 4894439819509966509 0 IN IP4 0.0.0.0",
		"s=-",
		"t=0 0",
		"a=ice-options:trickle",
		"a=group:BUNDLE audio0 video1",
		"m=audio 9 UDP/TLS/RTP/SAVPF 111",
		"c=IN IP4 0.0.0.0",
		"a=setup:actpass",
		"a=ice-ufrag:zVhfGb2+LlX8ryrgnyvz6gayKIp2qwED",
		"a=ice-pwd:HMpcw7R15a/JemH82tpPtE7QTWJAqAL+",
		"a=rtcp-mux",
		"a=sendrecv",
		"a=rtpmap:111 OPUS/48000/2",
		"a=rtcp-fb:111 transport-cc",
		"a=fmtp:111 minptime=10;useinbandfec=1",
		"a=mid:audio0",
		"a=fingerprint:sha-256 C5:59:06:F8:A8:4A:D1:30",
		"m=video 0 UDP/TLS/RTP/SAVPF 96 97",
		"c=IN IP4 0.0.0.0",
		"a=setup:actpass",
		"a=ice-ufrag:zVhfGb2+LlX8ryrgnyvz6gayKIp2qwED",
		"a=ice-pwd:HMpcw7R15a/JemH82tpPtE7QTWJAqAL+",
		"a=bundle-only",
		"a=rtcp-mux",
		"a=sendonly",
		"a=rtpmap:96 VP8/90000",
		"a=rtcp-fb:96 nack pli",
		"a=rtcp-fb:96 ccm fir",
		"a=rtpmap:97 rtx/90000",
		"a=fmtp:97 apt=96",
		"a=extmap:3 http://www.ietf.org/id/draft-holmer-rmcat-transport-wide-cc-extensions-01",
		"a=ssrc-group:FID 2264060184 2264060185",
		"a=ssrc:2264060184 msid:user3048465719@host-57c3fd69 webrtctransceiver1",
		"a=ssrc:2264060184 cname:user3048465719@host-57c3fd69",
		"a=mid:video1",
		"a=fingerprint:sha-256 C5:59:06:F8:A8:4A:D1:30",
		"a=candidate:1 1 UDP 2015363327 192.168.0.11 56938 typ host",
		"a=candidate:2 1 TCP 1015021823 192.168.0.11 9 typ host tcptype active",
		""
	].join("\r\n");

	function test_fromSdp() {
		final offer = JingleRtp.fromSdp(OFFER, true);
		equals(2, offer.contents.length);
		final audio = offer.contents[0];
		equals("audio0", audio.name);
		equals(JingleCreator.initiator, audio.creator);
		equals(JingleSenders.both, audio.senders);
		equals("audio", JingleRtp.media(audio));
		final opus = audio.description.elements.named("payload-type")[0];
		equals("111", opus.get("id"));
		equals("OPUS", opus.get("name"));
		equals("48000", opus.get("clockrate"));
		equals("2", opus.get("channels"));
		final params = opus.elements.named("parameter");
		equals(2, params.length);
		equals("useinbandfec", params[1].get("name"));
		equals("1", params[1].get("value"));
		equals("transport-cc", opus.elements.named("rtcp-fb")[0].get("type"));
		equals(1, audio.description.elements.named("rtcp-mux").length);

		final transport = audio.transport;
		isTrue(transport.is(JingleRtp.XMLNS_ICE_UDP));
		equals("zVhfGb2+LlX8ryrgnyvz6gayKIp2qwED", transport.get("ufrag"));
		equals("HMpcw7R15a/JemH82tpPtE7QTWJAqAL+", transport.get("pwd"));
		final fingerprint = transport.elements.named("fingerprint")[0];
		isTrue(fingerprint.is(JingleRtp.XMLNS_DTLS));
		equals("sha-256", fingerprint.get("hash"));
		equals("actpass", fingerprint.get("setup"));
		equals("C5:59:06:F8:A8:4A:D1:30", fingerprint.text);

		final video = offer.contents[1];
		equals("video1", video.name);
		// sent only by the initiator
		equals(JingleSenders.initiator, video.senders);
		final types = video.description.elements.named("payload-type");
		equals(2, types.length);
		equals("pli", types[0].elements.named("rtcp-fb")[0].get("subtype"));
		equals("apt", types[1].elements.named("parameter")[0].get("name"));
		equals("3", video.description.elements.named("rtp-hdrext")[0].get("id"));
		final group = video.description.elements.named("ssrc-group")[0];
		equals("FID", group.get("semantics"));
		equals(2, group.elements.named("source").length);
		final source = video.description.elements.named("source")[0];
		equals("2264060184", source.get("ssrc"));
		equals("msid", source.elements.named("parameter")[0].get("name"));
		equals("user3048465719@host-57c3fd69 webrtctransceiver1", source.elements.named("parameter")[0].get("value"));
		// only UDP candidates
		final candidates = video.transport.elements.named("candidate");
		equals(1, candidates.length);
		equals("192.168.0.11", candidates[0].get("ip"));

		// the contents are grouped
		equals(1, offer.payload.length);
		final bundle = JingleRtp.group(offer.payload);
		equals("BUNDLE", bundle.get("semantics"));
		equals("audio0 video1", [for (c in bundle.elements.named("content")) c.get("name")].join(" "));
	}

	function test_senders() {
		// sendonly of the responder: the responder sends
		final answer = JingleRtp.fromSdp(OFFER, false);
		equals(JingleSenders.responder, answer.contents[1].senders);
		// and back
		final sdp = JingleRtp.toSdp(answer.contents, false);
		isTrue(sdp.contains("a=mid:video1\r\na=sendonly"));
		// seen by the initiator: it receives only
		isTrue(JingleRtp.toSdp(answer.contents, true).contains("a=mid:video1\r\na=recvonly"));
	}

	function test_roundtrip() {
		final offer = JingleRtp.fromSdp(OFFER, true);
		// through XML, as sent and received
		final contents = [for (c in offer.contents) Jingle.parseContent(XML.fromString(Jingle.createContent(c).toString()))];
		final sdp = JingleRtp.toSdp(contents, JingleRtp.group(offer.payload), true, "42");
		isTrue(sdp.startsWith("v=0\r\no=- 42 2 IN IP4 0.0.0.0\r\n"));
		isTrue(sdp.endsWith("\r\n"));
		isTrue(sdp.contains("a=group:BUNDLE audio0 video1\r\n"));
		isTrue(sdp.contains("m=audio 9 UDP/TLS/RTP/SAVPF 111\r\n"));
		isTrue(sdp.contains("m=video 9 UDP/TLS/RTP/SAVPF 96 97\r\n"));
		isTrue(sdp.contains("a=rtpmap:111 OPUS/48000/2\r\n"));
		isTrue(sdp.contains("a=fmtp:111 minptime=10;useinbandfec=1\r\n"));
		isTrue(sdp.contains("a=rtcp-fb:96 nack pli\r\n"));
		isTrue(sdp.contains("a=fmtp:97 apt=96\r\n"));
		isTrue(sdp.contains("a=fingerprint:sha-256 C5:59:06:F8:A8:4A:D1:30\r\na=setup:actpass\r\n"));
		isTrue(sdp.contains("a=ice-ufrag:zVhfGb2+LlX8ryrgnyvz6gayKIp2qwED\r\n"));
		isTrue(sdp.contains("a=ssrc-group:FID 2264060184 2264060185\r\n"));
		isTrue(sdp.contains("a=ssrc:2264060184 cname:user3048465719@host-57c3fd69\r\n"));
		isTrue(sdp.contains("a=extmap:3 http://www.ietf.org/id/draft-holmer-rmcat-transport-wide-cc-extensions-01\r\n"));
		isTrue(sdp.contains("a=candidate:1 1 UDP 2015363327 192.168.0.11 56938 typ host generation 0\r\n"));
		// converting it again gives the same contents
		final again = JingleRtp.fromSdp(sdp, true);
		equals(Jingle.createContent(offer.contents[0]).toString().length, Jingle.createContent(again.contents[0]).toString().length);
	}

	function test_candidates() {
		final c = JingleRtp.candidateFromSdp("candidate:3 1 udp 1677729535 203.0.113.7 61000 typ srflx raddr 192.168.0.11 rport 56938 generation 1 ufrag x network-id 2");
		equals("3", c.get("foundation"));
		equals("1", c.get("component"));
		equals("udp", c.get("protocol"));
		equals("1677729535", c.get("priority"));
		equals("203.0.113.7", c.get("ip"));
		equals("61000", c.get("port"));
		equals("srflx", c.get("type"));
		equals("192.168.0.11", c.get("rel-addr"));
		equals("56938", c.get("rel-port"));
		equals("1", c.get("generation"));
		equals("2", c.get("network"));
		notNull(c.get("id"));
		equals("candidate:3 1 UDP 1677729535 203.0.113.7 61000 typ srflx raddr 192.168.0.11 rport 56938 generation 1", JingleRtp.candidateToSdp(c));
		// with a=
		notNull(JingleRtp.candidateFromSdp("a=candidate:1 1 UDP 2015363327 192.168.0.11 56938 typ host"));
		// only UDP, valid
		isNull(JingleRtp.candidateFromSdp("candidate:2 1 TCP 1015021823 192.168.0.11 9 typ host tcptype active"));
		isNull(JingleRtp.candidateFromSdp("candidate:1 1 UDP"));
		isNull(JingleRtp.candidateFromSdp("hello"));

		// trickle ICE: a content of transport-info with the credentials of the own content
		final audio = JingleRtp.fromSdp(OFFER, true).contents[0];
		final info = JingleRtp.candidateContent(audio, "candidate:1 1 UDP 2015363327 192.168.0.11 56938 typ host");
		equals("audio0", info.name);
		isNull(info.description);
		equals("zVhfGb2+LlX8ryrgnyvz6gayKIp2qwED", info.transport.get("ufrag"));
		same(["candidate:1 1 UDP 2015363327 192.168.0.11 56938 typ host generation 0"], JingleRtp.candidates(info.transport));
		isNull(JingleRtp.candidateContent(audio, "candidate:2 1 TCP 1015021823 192.168.0.11 9 typ host tcptype active"));
		equals(0, JingleRtp.candidates(null).length);
	}

	function test_media() {
		isNull(JingleRtp.media({creator: initiator, name: "x"}));
		isNull(JingleRtp.media({creator: initiator, name: "x", description: XML.create("description").set("xmlns", "urn:xmpp:jingle:apps:file-transfer:5")}));
		equals(0, JingleRtp.fromSdp("v=0\r\n", true).contents.length);
		isNull(JingleRtp.group([]));
	}
}
