# HXMPP

[Haxe](https://haxe.org/) [XMPP](https://xmpp.org/) library.

The Extensible Messaging and Presence Protocol is an open technology for real-time communication, which powers a wide range of applications including instant messaging, presence, multi-party chat, voice and video calls, collaboration, lightweight middleware, content syndication, and generalized routing of XML data. The XMPP protocols are free, open, public, and easily understandable.

[![test](https://github.com/tong/hxmpp/actions/workflows/test.yml/badge.svg)](https://github.com/tong/hxmpp/actions/workflows/test.yml) [![haxelib](https://img.shields.io/github/v/tag/tong/hxmpp.svg?colorA=F68712&colorB=141419&label=haxelib&style=flat-square)](http://lib.haxe.org/p/hxmpp/)

## Install

```sh
haxelib git https://github.com/tong/hxmpp
haxelib install sasl
```

Requires Haxe 4.3.7 or later; tested on hl, cpp, jvm, lua, neko, nodejs, php and python.

## Usage

See [example/App.hx](example/App.hx) for a basic client (connect, TLS, login, roster, messages) on sys targets, and [example/App.js.hx](example/App.js.hx) for nodejs.

For WebSocket connections (e.g. browser clients) set `stream.framing = true`, see `xmpp.net.WebSocket`.

External server components ([XEP-0114](https://xmpp.org/extensions/xep-0114.html)) use `xmpp.component.Stream`.

## Specifications

* [RFC 6120](https://xmpp.org/rfcs/rfc6120.html) XMPP Core
* [RFC 6121](https://xmpp.org/rfcs/rfc6121.html) XMPP Instant Messaging and Presence
* [RFC 7622](https://xmpp.org/rfcs/rfc7622.html) XMPP Address Format
* [RFC 5122](https://xmpp.org/rfcs/rfc5122.html) Internationalized Resource Identifiers (IRIs) and Uniform Resource Identifiers (URIs) for XMPP
* [RFC 7395](https://datatracker.ietf.org/doc/rfc7395/) XMPP Subprotocol for WebSocket

### Extensions

| XEP | Name | Module |
|-----|------|--------|
| [XEP-0004](https://xmpp.org/extensions/xep-0004.html) | Data Forms | `xmpp.DataForm` |
| [XEP-0012](https://xmpp.org/extensions/xep-0012.html) | Last Activity | `xmpp.LastActivity` |
| [XEP-0030](https://xmpp.org/extensions/xep-0030.html) | Service Discovery | `xmpp.ServiceDiscovery` |
| [XEP-0045](https://xmpp.org/extensions/xep-0045.html) | Multi-User Chat | `xmpp.Muc` |
| [XEP-0047](https://xmpp.org/extensions/xep-0047.html) | In-Band Bytestreams | `xmpp.Jingle` (`JingleIBB`), `xmpp.IBBytestream` (experimental) |
| [XEP-0049](https://xmpp.org/extensions/xep-0049.html) | Private XML Storage | `xmpp.PrivateStorage` |
| [XEP-0050](https://xmpp.org/extensions/xep-0050.html) | Ad-Hoc Commands | `xmpp.AdHocCommand` |
| [XEP-0054](https://xmpp.org/extensions/xep-0054.html) | vcard-temp | `xmpp.VCard` |
| [XEP-0059](https://xmpp.org/extensions/xep-0059.html) | Result Set Management | `xmpp.ResultSet` |
| [XEP-0060](https://xmpp.org/extensions/xep-0060.html) | Publish-Subscribe | `xmpp.PubSub` |
| [XEP-0065](https://xmpp.org/extensions/xep-0065.html) | SOCKS5 Bytestreams (with Jingle) | `xmpp.Jingle` (`JingleS5B`) |
| [XEP-0066](https://xmpp.org/extensions/xep-0066.html) | Out of Band Data | `xmpp.Oob` |
| [XEP-0077](https://xmpp.org/extensions/xep-0077.html) | In-Band Registration | `xmpp.client.Account` |
| [XEP-0080](https://xmpp.org/extensions/xep-0080.html) | User Location | `xmpp.Pep` |
| [XEP-0085](https://xmpp.org/extensions/xep-0085.html) | Chat State Notifications | `xmpp.ChatState` |
| [XEP-0092](https://xmpp.org/extensions/xep-0092.html) | Software Version | `xmpp.SoftwareVersion` |
| [XEP-0106](https://xmpp.org/extensions/xep-0106.html) | JID Escaping | `xmpp.Jid` |
| [XEP-0107](https://xmpp.org/extensions/xep-0107.html) | User Mood | `xmpp.Pep` |
| [XEP-0108](https://xmpp.org/extensions/xep-0108.html) | User Activity | `xmpp.Pep` |
| [XEP-0114](https://xmpp.org/extensions/xep-0114.html) | Jabber Component Protocol | `xmpp.component.Stream` |
| [XEP-0118](https://xmpp.org/extensions/xep-0118.html) | User Tune | `xmpp.Pep` |
| [XEP-0163](https://xmpp.org/extensions/xep-0163.html) | Personal Eventing Protocol | `xmpp.Pep` |
| [XEP-0166](https://xmpp.org/extensions/xep-0166.html) | Jingle | `xmpp.Jingle` |
| [XEP-0172](https://xmpp.org/extensions/xep-0172.html) | User Nickname | `xmpp.client.Nickname` |
| [XEP-0191](https://xmpp.org/extensions/xep-0191.html) | Blocking Command | `xmpp.Block` |
| [XEP-0198](https://xmpp.org/extensions/xep-0198.html) | Stream Management | `xmpp.StreamManagement` |
| [XEP-0199](https://xmpp.org/extensions/xep-0199.html) | XMPP Ping | `xmpp.Ping` |
| [XEP-0202](https://xmpp.org/extensions/xep-0202.html) | Entity Time | `xmpp.EntityTime` |
| [XEP-0203](https://xmpp.org/extensions/xep-0203.html) | Delayed Delivery | `xmpp.DelayedDelivery` |
| [XEP-0224](https://xmpp.org/extensions/xep-0224.html) | Attention | `xmpp.Attention` |
| [XEP-0231](https://xmpp.org/extensions/xep-0231.html) | Bits of Binary | `xmpp.Bob` |
| [XEP-0234](https://xmpp.org/extensions/xep-0234.html) | Jingle File Transfer (file offers) | `xmpp.Jingle` (`JingleFileTransfer`) |
| [XEP-0260](https://xmpp.org/extensions/xep-0260.html) | Jingle SOCKS5 Bytestreams Transport Method | `xmpp.Jingle` (`JingleS5B`) |
| [XEP-0261](https://xmpp.org/extensions/xep-0261.html) | Jingle In-Band Bytestreams Transport Method | `xmpp.Jingle` (`JingleIBB`) |
| [XEP-0280](https://xmpp.org/extensions/xep-0280.html) | Message Carbons | `xmpp.Carbons` |
| [XEP-0308](https://xmpp.org/extensions/xep-0308.html) | Last Message Correction | `xmpp.LastMessageCorrection` |
| [XEP-0352](https://xmpp.org/extensions/xep-0352.html) | Client State Indication | `xmpp.client.CSI` |
| [XEP-0363](https://xmpp.org/extensions/xep-0363.html) | HTTP File Upload | `xmpp.HttpFileUpload` |

## Tests

```sh
haxelib dev hxmpp .
haxelib git utest https://github.com/haxe-utest/utest
haxe test.hxml                # run on interp
haxe --cwd test build-hl.hxml # build for other targets (test/build-*.hxml)
hl test/bin/unit.hl
```

## License

MIT
