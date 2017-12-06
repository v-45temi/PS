This script checks the receive connectors settings and compare them to the defaults.
The default settings are the following:

"TransportRole","Name","Authmechanism","Bindings","Permissiongroups","RemoteIPranges","Enabled"
"HubTransport","Default ","Tls, Integrated, BasicAuth, BasicAuthRequireTLS, ExchangeServer","0.0.0.0:2525,[::]:2525","ExchangeUsers, ExchangeServers, ExchangeLegacyServers","::-ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff,0.0.0.0-255.255.255.255","True"
"HubTransport","Client Proxy ","Tls, Integrated, BasicAuth, BasicAuthRequireTLS, ExchangeServer","[::]:465,0.0.0.0:465","ExchangeUsers, ExchangeServers","::-ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff,0.0.0.0-255.255.255.255","True"
"FrontendTransport","Default Frontend ","Tls, Integrated, BasicAuth, BasicAuthRequireTLS, ExchangeServer","[::]:25,0.0.0.0:25","AnonymousUsers, ExchangeServers, ExchangeLegacyServers","::-ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff,0.0.0.0-255.255.255.255","True"
"FrontendTransport","Outbound Proxy Frontend ","Tls, Integrated, BasicAuth, BasicAuthRequireTLS, ExchangeServer","[::]:717,0.0.0.0:717","ExchangeServers","::-ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff,0.0.0.0-255.255.255.255","True"
"FrontendTransport","Client Frontend ","Tls, Integrated, BasicAuth, BasicAuthRequireTLS","[::]:587,0.0.0.0:587","AnonymousUsers, ExchangeUsers","::-ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff,0.0.0.0-255.255.255.255","True"
    
 Execution of this script is on your own risk. Please read the code before you run it.
 
 
