[![Godoc Reference](https://godoc.org/github.com/aead/blake2s?status.svg)](https://godoc.org/github.com/aead/blake2s)

## Deprecated

This BLAKE2s implementation was submited to the golang x/crypto repo.
I recommend to use the offical [x/crypto/blake2s](https://godoc.org/golang.org/x/crypto/blake2s) package.

## The BLAKE2s hash algorithm

BLAKE2s is a fast cryptographic hash function described in [RFC 7963](https://tools.ietf.org/html/rfc7693).
BLAKE2s can be directly keyed, making it functionally equivalent to a Message Authentication Code (MAC).

### Installation

Install in your GOPATH: `go get -u github.com/aead/blake2s`