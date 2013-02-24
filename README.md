
![alt text](http://hxmpp.disktree.net/img/hxmpp.png "Haxe XMPP/Jabber library")
===
Haxe XMPP/Jabber library | [Documentation](http://hxmpp.disktree.net/doc/api/ "hxmpp api documentation") | [Examples](https://github.com/tong/hxmpp.examples "hxmpp examples and test projects") | [Test](http://hxmpp.disktree.net/test/ "hxmpp examples and test projects")


### XEPS SUPPORTED
* [XEP-0004 DataForms](http://xmpp.org/extensions/xep-0004.html)
* [XEP-0012 LastActivity](http://xmpp.org/extensions/xep-0004.html)
* [XEP-0016 PrivacyLists](http://xmpp.org/extensions/xep-0004.html)
* [XEP-0030 ServiceDiscovery](http://xmpp.org/extensions/xep-0004.html)
* [XEP-0045 MUChat](http://xmpp.org/extensions/xep-0004.html)
* [XEP-0047 In-Band Bytestreams](http://xmpp.org/extensions/xep-0004.html)
* [XEP-0049 Private XML Storage](http://xmpp.org/extensions/xep-0004.html)
* [XEP-0054 VCardTemp](http://xmpp.org/extensions/xep-0004.html)
* [XEP-0055 Search](http://xmpp.org/extensions/xep-0004.html)
* [XEP-0060 PubSub](http://xmpp.org/extensions/xep-0004.html)
* [XEP-0065 SOCKS5 Bytestreams](http://xmpp.org/extensions/xep-0004.html)
* [XEP-0071 XHTML-IM](http://xmpp.org/extensions/xep-0004.html)
* [XEP-0077 In-Band Registration](http://xmpp.org/extensions/xep-0004.html)
* [XEP-0082 XMPP Date and Time Profiles](http://xmpp.org/extensions/xep-0004.html)
* [XEP-0085 ChatStateNotification](http://xmpp.org/extensions/xep-0004.html)
* [XEP-0092 SoftwareVersion](http://xmpp.org/extensions/xep-0004.html)
* [XEP-0096 SI File Transfer](http://xmpp.org/extensions/xep-0004.html)
* [XEP-0106 JID Escaping](http://xmpp.org/extensions/xep-0004.html)
* [XEP-0114 Jabber Component Protocol](http://xmpp.org/extensions/xep-0004.html)
* [XEP-0115 Entity Capabilities](http://xmpp.org/extensions/xep-0004.html)
* [XEP-0124 BOSH](http://xmpp.org/extensions/xep-0004.html)
* [XEP-0163 PersonalEvent ](http://xmpp.org/extensions/xep-0004.html)
* [XEP-0191 Simple Communications Blocking](http://xmpp.org/extensions/xep-0004.html)
* [XEP-0199 Ping ](http://xmpp.org/extensions/xep-0004.html)
* [XEP-0202 EntityTime](http://xmpp.org/extensions/xep-0004.html)
* [XEP-0203 DelayedDelivery](http://xmpp.org/extensions/xep-0004.html)
* [XEP-0206 BOSH](http://xmpp.org/extensions/xep-0004.html)
* [XEP-0231 Bits of Binary](http://xmpp.org/extensions/xep-0004.html)
* [XEP-0224 Attention](http://xmpp.org/extensions/xep-0004.html)
* [XEP-XXXX Linked Process Protocol](http://xmpp.org/extensions/inbox/lop.html)
* [XEP-XXXX GMail Notifiy](http://code.google.com/apis/talk/jep_extensions/gmail.html)
* [XEP-XXXX Jingle RTMP Transport](http://xmpp.org/extensions/inbox/jingle-rtmp.html)
* XEP-XXXX Jingle RTMFP Transport



### COMPILER FLAGS
* XMPP_DEBUG    Print XMPP transfer (see [jabber.XMPPDebug](http://hxmpp.disktree.net/doc/api/types/jabber/XMPPDebug.html) for options)
* JABBER_DEBUG    Print verbose debug information
* JABBER_COMPONENT    Set to build xmpp server components (use [jabber.component.*](http://hxmpp.disktree.net/doc/api/packages/jabber/component/package.html) instead of [jabber.client.*](http://hxmpp.disktree.net/doc/api/packages/jabber/client/package.html))
* JABBER_FLASHSOCKETBRIDGE  Enables to use a flash socket bridge as stream connection for the javascript target (see [hxmpp/util/flash-socketbridge](https://github.com/tong/hxmpp/tree/master/util/flash-socketbridge))



### BOSH/HTTP
BOSH essentially provides a "drop-in" alternative to a long-lived, bidirectional TCP connection using a request-response mechansim over HTTP.
To use it you have to connect your client to the BOSH adress of your XMPP server.

Apache, for example, doesn’t know about your XMPP server, therefore you have to forward requests using the proxy module.

* Activate [mod_proxy apache module](http://httpd.apache.org/docs/2.2/mod/mod_proxy.html)
```shell
ln -s /etc/apache2/mods-available/proxy.load /etc/apache2/mods-enabled/
```

* Add following line to proxy.load to activate the module
```shell
LoadModule proxy_http_module /usr/lib/apache2/modules/mod_proxy_http.so
```

* Add a directive to your host settings to proxy requests from *http://localhost/httpbind* to *http://localhost:7070/http-bind/* 
```shell                                                                                                                        
<VirtualHost *:80>
    ...
	ProxyRequests Off
	ProxyPass /httpbind http://localhost/http-bind/
    ProxyPassReverse /httpbind http://localhost:7070/http-bind/
...
</VirtualHost>
```

* Restart apache
```shell
service apache2 restart
```

* You can now use this URL to connect to your server
```javascript
var cnx = new jabber.BOSHConnection( "server.org", "127.0.0.1/httpbind/" );
```


### SOURCE
HXMPP is open source and licensed under MIT | https://github.com/tong/hxmpp | git://github.com/tong/hxmpp.git


---

Copyright (c) 2013 disktree.net

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
