/*
 * Copyright (c) 2012, disktree.net
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
package jabber.jingle.io;

import webrtc.RTCPeerConnection;

/**
*/
@:require(js) class WebRTCSDPOutput extends WebRTCSDPTransport {
	
	public function new() {
		super();
	}
	
	public override function connect() {
		super.connect();
		connection.createOffer(function(r:RTCSessionDescription){
			trace("OK OFFER CREATED "+r );
			__onConnect();
		});
	}
	
		/*
	override function signalingCallback( s : String ) {
		SDP
{
   "messageType" : "OFFER",
   "offererSessionId" : "MCVth81fPiyXVEsIrOyQC2qQN6z6AKIr",
   "sdp" : "v=0\r\no=- 0 0 IN IP4 127.0.0.1\r\ns=\r\nc=IN IP4 0.0.0.0\r\nt=0 0\r\nm=audio 1 RTP/AVPF 103 104 0 8 106 105 13 126\r\na=candidate:1 2 udp 1 192.168.0.110 36980 typ host name rtcp network_name eth0 username xt+yRxJLRI7P8lLi password y1G2wSpbS6OYV/M6 generation 0\r\na=candidate:1 1 udp 1 192.168.0.110 36658 typ host name rtp network_name eth0 username iAYsIXwIKU5tZrmS password ipdaLsVo6UD0Y11e generation 0\r\na=candidate:1 2 udp 0.9 84.113.243.149 51754 typ srflx name rtcp network_name eth0 username cANnMywYmdGOa8w2 password zFgIUZ+fB/KIgQCY generation 0\r\na=candidate:1 1 udp 0.9 84.113.243.149 54387 typ srflx name rtp network_name eth0 username Ze3jopneY4dS3x1+ password UynLIDrd4IhoU8vF generation 0\r\na=mid:audio\r\na=rtcp-mux\r\na=crypto:0 AES_CM_128_HMAC_SHA1_32 inline:wcq+5SXIpXLoRLw15hCHsL4K4ymQvrisxmm8up1G \r\na=crypto:1 AES_CM_128_HMAC_SHA1_80 inline:m9BHzoNHKbPx+rYiFF2A/eaN0q28eOpDnXexzsxC \r\na=rtpmap:103 ISAC/16000\r\na=rtpmap:104 ISAC/32000\r\na=rtpmap:0 PCMU/8000\r\na=rtpmap:8 PCMA/8000\r\na=rtpmap:106 CN/32000\r\na=rtpmap:105 CN/16000\r\na=rtpmap:13 CN/8000\r\na=rtpmap:126 telephone-event/8000\r\nm=video 1 RTP/AVPF 100 101 102\r\na=candidate:1 2 udp 1 192.168.0.110 50607 typ host name video_rtcp network_name eth0 username UO+Dq/TPl21SirQV password YNjuV8iSK4ZrKaRq generation 0\r\na=candidate:1 1 udp 1 192.168.0.110 40620 typ host name video_rtp network_name eth0 username PB3f+Q7GsX3kgORT password bJibVoYCKOYk1VoG generation 0\r\na=candidate:1 2 udp 0.9 84.113.243.149 53454 typ srflx name video_rtcp network_name eth0 username 0NjvYjeF5WEalNs2 password YkYiCaYBLJqjVcmY generation 0\r\na=candidate:1 1 udp 0.9 84.113.243.149 46983 typ srflx name video_rtp network_name eth0 username sEk9vTv1+ECCJW4j password cxg7lligwSmw2oxk generation 0\r\na=mid:video\r\na=rtcp-mux\r\na=crypto:0 AES_CM_128_HMAC_SHA1_80 inline:OOyNbASPxu9rCOjlRp7m0MqPYBmNH9btmbNyCJAl \r\na=rtpmap:100 VP8/0\r\na=rtpmap:101 red/0\r\na=rtpmap:102 ulpfec/0\r\n",
   "seq" : 1,
   "tieBreaker" : 3156754776
}
		sdp = s;
		__onConnect();
	}
		*/
	
}
