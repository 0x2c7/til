HTTP, Hypertext Transfer Protocol, is designed to become a common language
between web applications. Since first introduce, it has been quickly threaded
and became the most popular protocol in the internet world. In a nutshell, HTTP
is a multimedia courier, which means that it transfer the request from clients
and carries any virtual resource responsed by the provider (servers) on demand.
It is built on top of the TCP/IP, a reliable tranmission protocol. By its
wonderful mechanism, HTTP ensures the reliability and the statefulness of the
data.

## URL and Resources
In HTTP/1.x version, everything is wrapped in a HTTP transaction. Each
transaction includes one request from the client and one response from the
server. Since there are a lot of servers and each server has a lot of resources,
the client must specify which server, and which resource in the server he want
to request via URL (Uniform Resource Locator). This URL can be compared to
physical address in real time. To make clients and servers understand and can
handle, the URLs must follow the following syntax:
```
<scheme>://<user>:<password>@<host>:<port>/<path>;<params>?<query>#<frag>
```
In which:
- `<scheme>`: which protocol the request want to use when communicating with the
  servers. There are plenty of protocol accepted worldwide:
  - `http`: Yup, this is the protocol we are talking about
  - `ftp` (File Transfer Protocol): a legacy but popular protocol used to
    transfer files.
  - `rtsp`: Real time streaming protocol
  There is a huge list of public protocol:
  [https://www.iana.org/assignments/uri-schemes/uri-schemes.xhtml](https://www.iana.org/assignments/uri-schemes/uri-schemes.xhtml). Most of them are experimental or provisional. Besides the public protocol, clients and servers could communicate via a custom protocol that only they know  how to handle.
- `user` and `password`: This part of the URL is mainly used with FTP protocol,
  at the authorization steps. HTTP protocol rarely touches this part.
- `host`: could be a domain name or just a plain IP address. This part is basic
  that I won't talk about it anymore
- `port`: if not provided, the default port number is 80
- `path`: specifies which resources in the server the client want to request.
  Path design is a real art. It can reflect the real file structures of the
  servers, or reflect the whole architect of the system (part of REST methodlogy)
- `params`: nearly outdated and only used in legacy systems. This is an extra
  option for the path. For example:
  `http://google.com/search;type=lucky?query=...`
- `query`: very popular in the world of dynamic web. It allows the clients to
  dynamically request anything on demand. The response will be different based
  on the query. There could be many queries at the same time. Each query is
  separated with `&` character. For example:
  `https://google.com/search?query=hihi&type=haha`
- `frag` (fragment): it is used to identify a part of the page, or the state of
  current page when the page displays multiple parts and the client wants to
  specify a part of them. Usually, the clients keep this fragment without
  sending to the server. They will handle by themself after the response arrive.

That specification is for absolute URL. In real time, people usually use
Relative URL (or sometimes called URL shortcuts), for example:
`./search/advance`, `/cart/show`, etc. The relative URL is resolved and become
absolute URL based on the previous absolute URL or a specific base definition
puts in page header (`<base>` tag).

![Relative URL resolve](./http-definitive-guide/relative-url-resolve.png)

Since the URLs are used everywhere in the internet world, it must have a high
comptiablibity with all existing systems. That's why the URLs are restricted to
use US-ASCII character set only. Even more, only some reserved characters
besides basic alphabet characters are allowed to keeps its format. Other
characters are escape with this syntax: `%<code>`, in which `<code>` is the
hexadecimal number of the ASCII code of the character want to escape. For
example: `http://google.com/?query=toi%20yeu%20doi%20%7E` is the escaped string of
url `http://goole.com?query=toi yeu doi~`. The list of restricted characters is
listed at [https://tools.ietf.org/html/rfc3986#section-2](https://tools.ietf.org/html/rfc3986#section-2)

## HTTP Messages
In a HTTP transation, everything is packed into a message. The clients send
request message to server, the server respones with response message. The
messages are line-oriented, which means that all information in a message is
structure by lines. When the clients / servers handle the message, it will parse
the message line by line. Every message, both request and response includes three
parts: start line, headers and body. Start line is the first line of the
message. It describes the protocol, version, method ... to inform the opposite
how to handle the message. The headers part contains useful information aside of
the main content in boy. The header information is different between request and
kresponse message. The header part could include many lines. Each line must store
one header information only. The syntax of a header: `<name>: <content>`. To
mark the end of headers, the message use a blank line (CRLF). Even when the
message doesn't have header, the blank line must be included. The last part is
body. It could be anything, from plain text, json, image to a top secret
enscripted string.

To view the raw HTTP message transported, I use `netcat` (`brew install netcat`).
By using the netcat interactive command line, I could see the http messages when
I try to connect to kipalog. That's fun that Kipalog response with 500 error
intead of 405 =)).
```
▶ nc kipalog.com 80
GET / HTTP/1.1
Host: www.kipalog.com
Accept: application/json

HTTP/1.1 500 Internal Server Error
Server: nginx
Date: Tue, 27 Sep 2016 03:19:38 GMT
Content-Type: text/html; charset=utf-8
Content-Length: 0
Connection: close
Status: 500 Internal Server Error
X-Request-Id: 4ffaa15a-3e42-4831-bc1e-aa1d5e5d788d
X-Runtime: 0.010137
```
The lines on the top are the HTTP request response I compose:
```
GET / HTTP/1.1
Host: www.kipalog.com
Accept: application/json
```
It has a high readability since it is designed to be read by both machines and
human. The above message means that I want to get the resource at location `/`
(homepage) with HTTP protocol version 1.1 at host `www.kipalog.com` and I only
accept the response with JSON format. This message is sent to the server of
kipalog.com, then the server response with another message:
```
HTTP/1.1 500 Internal Server Error
Server: nginx
Date: Tue, 27 Sep 2016 03:19:38 GMT
Content-Type: text/html; charset=utf-8
Content-Length: 0
Connection: close
Status: 500 Internal Server Error
X-Request-Id: 4ffaa15a-3e42-4831-bc1e-aa1d5e5d788d
X-Runtime: 0.010137
```
In general, it says that `f*ck`, I have a bug when process the above message.
And provide some information about that. In this case, both request and response
messages don't have a body. Let's try another example
```
▶ nc google.com 80
POST / HTTP/1.1
Host: google.com

HTTP/1.0 411 Length Required
Content-Type: text/html; charset=UTF-8
Content-Length: 1564
Date: Tue, 27 Sep 2016 03:29:40 GMT

<!DOCTYPE html>
<html lang=en>
  <meta charset=utf-8>
  <meta name=viewport content="initial-scale=1, minimum-scale=1, width=device-width">
  <title>Error 411 (Length Required)!!1</title>
  <style>
    *{margin:0;padding:0}html,code{font:15px/22px arial,sans-serif}html{background:#fff;color:#222;padding:15px}body{m
argin:7% auto 0;max-width:390px;min-height:180px;padding:30px 0 15px}* > body{background:url(//www.google.com/images/e
rrors/robot.png) 100% 5px no-repeat;padding-right:205px}p{margin:11px 0 22px;overflow:hidden}ins{color:#777;text-decor
ation:none}a img{border:0}@media screen and (max-width:772px){body{background:none;margin-top:0;max-width:none;padding
-right:0}}#logo{background:url(//www.google.com/images/branding/googlelogo/1x/googlelogo_color_150x54dp.png) no-repeat
;margin-left:-5px}@media only screen and (min-resolution:192dpi){#logo{background:url(//www.google.com/images/branding
/googlelogo/2x/googlelogo_color_150x54dp.png) no-repeat 0% 0%/100% 100%;-moz-border-image:url(//www.google.com/images/
branding/googlelogo/2x/googlelogo_color_150x54dp.png) 0}}@media only screen and (-webkit-min-device-pixel-ratio:2){#lo
go{background:url(//www.google.com/images/branding/googlelogo/2x/googlelogo_color_150x54dp.png) no-repeat;-webkit-back
ground-size:100% 100%}}#logo{display:inline-block;height:54px;width:150px}
  </style>
  <a href=//www.google.com/><span id=logo aria-label=Google></span></a>
  <p><b>411.</b> <ins>That’s an error.</ins>
  <p>POST requests require a <code>Content-length</code> header.  <ins>That’s all we know.</ins>
```

By definition, the overall syntax of the request message:
```
<method> <request-URL> <version>
<headers>

<entity-body>
```
And the response message's syntax:
```
<version> <status> <reason-phrase>
<headers>

<entity-body>
```
(continue)
