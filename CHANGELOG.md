## 1.0.0

### Breaking

* No more `jabber` package, everything is in `xmpp`
* Stanzas are abstract types over `xmpp.XML` (which wraps `Xml`): `xmpp.Stanza`, `xmpp.Message`, `xmpp.Presence`, `xmpp.IQ`
* `xmpp.Jid` (renamed from `JID`) is an abstract over `String`; `==` compares normalized jids
* Pluggable stream transport: the stream reads and writes strings (`recv`, `recvBytes`, `output`), the socket is up to the application
* Requests return a typed `xmpp.Response<T>` (`Result(payload)` or `Error(error)`) instead of packet collectors and filters
* Extensions are static extension modules (e.g. `using xmpp.Ping`), no listener classes
* SASL mechanisms moved to the [sasl](https://lib.haxe.org/p/sasl/) library (dependency)
* Removed the flash and air targets
* License changed from LGPL to MIT

### Core

* Client streams (`xmpp.client.Stream`): STARTTLS (`xmpp.StartTLS`, cpp, hl, neko, python, nodejs, lua), SASL (`SCRAM-SHA-256`, `SCRAM-SHA-1`, `PLAIN`, or any `sasl.Mechanism`) and resource binding (`xmpp.client.Authentication`)
* Server components (`xmpp.component.Stream`, [XEP-0114](https://xmpp.org/extensions/xep-0114.html))
* WebSocket framing ([RFC 7395](https://www.rfc-editor.org/rfc/rfc7395), `Stream.framing`, `xmpp.net.WebSocket`), `see-other-uri` redirects are reported to `Stream.onRedirect`
* BOSH sessions (`xmpp.net.BOSH`, [XEP-0124](https://xmpp.org/extensions/xep-0124.html), [XEP-0206](https://xmpp.org/extensions/xep-0206.html)): holding and polling, acknowledgements, recovery of lost requests, key sequences, `see-other-uri`
* TLS certificates are verified against the XMPP domain (not on lua)
* Stream errors are reported to `Stream.onError`, received ones as well as ones sent by the stream (`not-well-formed`, `policy-violation`); `Stream.open` tells whether the stream is open
* Malformed input never throws from `recv`: the stream answers with a `not-well-formed` stream error and closes
* Limit of buffered received data (`Stream.maxBufferSize`, default 1 MiB), exceeded data closes the stream with `policy-violation`
* Received data is scanned incrementally, large stanzas arriving in many chunks are not rescanned
* `Stream.end` is idempotent; `Stream.onEnd` is called once the peer closed the stream, also if its close arrived together with a stream error
* Responses are only accepted from the entity a request was sent to
* Iq requests are served per namespace with `Stream.features`, unhandled requests are answered with `service-unavailable`
* Presence with an invalid type is ignored instead of being taken as available
* `Stream.serverFeatures` keeps the last stream features, `Stream.jid` the bound address
* Roster (`xmpp.client.Roster`): versioning, subscription management, push handling
* In-band registration (`xmpp.client.Account`): registration forms, password change, unregistration
* Incremental `sha-1` and `sha-256` digests (`xmpp.Digest`), secure random data (`xmpp.Random`), UUIDs (`xmpp.Uuid`)
* XMPP URIs ([RFC 5122](https://www.rfc-editor.org/rfc/rfc5122), `xmpp.URI`)
* XML pretty printer for logging (`xmpp.xml.Printer`)

### Extensions

* New: Ad-Hoc Commands (XEP-0050), Result Set Management (XEP-0059), Out of Band Data (XEP-0066), User Avatar (XEP-0084),
  vCard-Based Avatars (XEP-0153), User Nickname (XEP-0172), Message Delivery Receipts (XEP-0184), Stream Management (XEP-0198),
  External Service Discovery (XEP-0215), Message Carbons (XEP-0280), Last Message Correction (XEP-0308),
  Message Archive Management (XEP-0313), File Information Sharing (XEP-0329), Client State Indication (XEP-0352),
  Jingle Message Initiation (XEP-0353), Unique and Stable Stanza IDs (XEP-0359), HTTP File Upload (XEP-0363),
  OMEMO (XEP-0384, the XML of version 0.3, without the cryptography), Message Styling (XEP-0393), PEP Native Bookmarks (XEP-0402),
  Occupant Identifiers (XEP-0421), Message Retraction (XEP-0424), Moderated Message Retraction (XEP-0425),
  Fallback Indication (XEP-0428), Message Reactions (XEP-0444), Message Replies (XEP-0461)
* Jingle (XEP-0166) rewritten: file transfer (XEP-0234) of any size with hashes and file requests,
  SOCKS5 (XEP-0260) and in-band bytestreams (XEP-0261) transports, RTP sessions (XEP-0167) with ICE-UDP, DTLS and grouping,
  converted from and to SDP
* Rewritten: Data Forms (XEP-0004), Last Activity (XEP-0012), Service Discovery (XEP-0030), Multi-User Chat (XEP-0045),
  In-Band Bytestreams (XEP-0047), Private XML Storage (XEP-0049), vcard-temp (XEP-0054), Publish-Subscribe (XEP-0060),
  SOCKS5 Bytestreams (XEP-0065, as Jingle transport), In-Band Registration (XEP-0077), Chat State Notifications (XEP-0085),
  Software Version (XEP-0092), JID Escaping (XEP-0106), Entity Capabilities (XEP-0115), Personal Eventing (XEP-0163) with
  User Mood, Activity, Tune and Location, Blocking Command (XEP-0191), Ping (XEP-0199), Entity Time (XEP-0202),
  Delayed Delivery (XEP-0203), Attention (XEP-0224), Bits of Binary (XEP-0231)
* Removed: Privacy Lists (XEP-0016), Jabber Search (XEP-0055), XHTML-IM (XEP-0071), SI File Transfer (XEP-0095, XEP-0096),
  Non-SASL Authentication (XEP-0078), Bookmarks (XEP-0048, replaced by XEP-0402), Stanza Headers (XEP-0131),
  Stream Compression (XEP-0138), the Jingle RTMP/RTMFP transports, Linked Process Protocol, GMail notifications,
  Haxe remoting over XMPP, standalone SOCKS5 bytestreams (SOCKS5 is available as Jingle transport)
