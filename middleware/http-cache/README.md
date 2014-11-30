# HTTP Cache Middleware

Drop the middleware to the Monitor and start using it by making HTTP calls.
If the service responds with HTTP header `Cache-Control: public` and `Last-Modified` and `Etag` the response will be cached.
Then if another call is made to the same URL and `max-age` set by `Cache-Control` did not expired yet the stored response will be used straight without rechecking.
However, if `max-age` expired, the call will be made with `If-None-Match` and `If-Modified-Since` headers. If the response is 304, will send cached response to the client.

## Requirements

* HTTP API sending correct caching headers

## TODO

* flushing the cache
* cache busting when the resource changes (does not return 304 during recheck)

## Development

* api.github.com is good public API with caching

