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
