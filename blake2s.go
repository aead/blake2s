// Copyright (c) 2016 Andreas Auernhammer. All rights reserved.
// Use of this source code is governed by a license that can be
// found in the LICENSE file.

// Package blake2s implemnets the BLAKE2s hash algorithm as
// defined in RFC 7693.
package blake2s

import (
	"encoding/binary"
	"errors"
	"hash"
)

const (
	// BlockSize is the blocksize of BLAKE2s in bytes.
	BlockSize = 64
	// Size is the hash size of BLAKE2s-256 in bytes.
	Size = 32
	// Size224 is the hash size of BLAKE2s-224 in bytes.
	Size224 = 28
	// Size160 is the hash size of BLAKE2s-160 in bytes.
	Size160 = 20
	// Size128 is the hash size of BLAKE2s-128 in bytes.
	Size128 = 16
)

var errKeySize = errors.New("invalid key size")

var iv = [8]uint32{
	0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a,
	0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19,
}

// Sum256 returns the BLAKE2s-256 checksum of the data.
func Sum256(data []byte) [Size]byte {
	var sum [Size]byte
	checkSum(&sum, Size, data)
	return sum
}

// Sum224 returns the BLAKE2s-224 checksum of the data.
func Sum224(data []byte) [Size224]byte {
	var sum [Size]byte
	var sum224 [Size224]byte
	checkSum(&sum, Size224, data)
	copy(sum224[:], sum[:Size224])
	return sum224
}

// Sum160 returns the BLAKE2s-160checksum of the data.
func Sum160(data []byte) [Size160]byte {
	var sum [Size]byte
	var sum160 [Size160]byte
	checkSum(&sum, Size160, data)
	copy(sum160[:], sum[:Size160])
	return sum160
}

// Sum128 returns the BLAKE2s-128 checksum of the data.
func Sum128(data []byte) [Size128]byte {
	var sum [Size]byte
	var sum128 [Size128]byte
	checkSum(&sum, Size128, data)
	copy(sum128[:], sum[:Size128])
	return sum128
}

// New256 returns a new hash.Hash computing the BLAKE2s-256 checksum.
// A non-nil key turns the hash into a MAC. The key must between 0 and 32 byte.
func New256(key []byte) (hash.Hash, error) { return newDigest(Size, key) }

// New224 returns a new hash.Hash computing the BLAKE2s-224 checksum.
// A non-nil key turns the hash into a MAC. The key must between 0 and 32 byte.
func New224(key []byte) (hash.Hash, error) { return newDigest(Size224, key) }

// New160 returns a new hash.Hash computing the BLAKE2s-160 checksum.
// A non-nil key turns the hash into a MAC. The key must between 0 and 32 byte.
func New160(key []byte) (hash.Hash, error) { return newDigest(Size160, key) }

// New128 returns a new hash.Hash computing the BLAKE2s-128 checksum.
// A non-nil key turns the hash into a MAC. The key must between 0 and 32 byte.
func New128(key []byte) (hash.Hash, error) { return newDigest(Size128, key) }

func newDigest(hashsize int, key []byte) (*digest, error) {
	if len(key) > Size {
		return nil, errKeySize
	}
	d := &digest{
		size:   hashsize,
		keyLen: len(key),
	}
	copy(d.key[:], key)
	d.Reset()
	return d, nil
}

func checkSum(sum *[Size]byte, hashsize int, data []byte) {
	var (
		h     [8]uint32
		c     [2]uint32
		block [BlockSize]byte
		off   int
	)

	h = iv
	h[0] ^= uint32(hashsize) | (1 << 16) | (1 << 24)

	if length := len(data); length > BlockSize {
		n := length & (^(BlockSize - 1))
		if length == n {
			n -= BlockSize
		}
		hashBlocks(&h, &c, 0, data[:n])
		data = data[n:]
	}
	off += copy(block[:], data)

	dif := uint32(BlockSize - off)
	if c[0] < dif {
		c[1]--
	}
	c[0] -= dif

	hashBlocks(&h, &c, 0xFFFFFFFF, block[:])

	for i, v := range h[:(hashsize+3)/4] {
		binary.LittleEndian.PutUint32(sum[4*i:], v)
	}
}

type digest struct {
	h     [8]uint32
	c     [2]uint32
	size  int
	block [BlockSize]byte
	off   int

	key    [BlockSize]byte
	keyLen int
}

func (d *digest) BlockSize() int { return BlockSize }

func (d *digest) Size() int { return d.size }

func (d *digest) Reset() {
	d.h = iv
	d.h[0] ^= uint32(d.size) | (uint32(d.keyLen) << 8) | (1 << 16) | (1 << 24)
	d.off, d.c[0], d.c[1] = 0, 0, 0
	if d.keyLen > 0 {
		d.block = d.key
		d.off = BlockSize
	}
}

func (d *digest) Write(p []byte) (n int, err error) {
	n = len(p)

	if d.off > 0 {
		dif := BlockSize - d.off
		if n > dif {
			copy(d.block[d.off:], p[:dif])
			hashBlocks(&d.h, &d.c, 0, d.block[:])
			d.off = 0
			p = p[dif:]
		} else {
			d.off += copy(d.block[d.off:], p)
			return
		}
	}

	if length := len(p); length > BlockSize {
		nn := length & (^(BlockSize - 1))
		if length == nn {
			nn -= BlockSize
		}
		hashBlocks(&d.h, &d.c, 0, p[:nn])
		p = p[nn:]
	}

	if len(p) > 0 {
		d.off += copy(d.block[:], p)
	}

	return
}

func (d *digest) Sum(b []byte) []byte {
	var block [BlockSize]byte
	h := d.h
	c := d.c

	copy(block[:], d.block[:d.off])
	dif := uint32(BlockSize - d.off)
	if c[0] < dif {
		c[1]--
	}
	c[0] -= dif

	hashBlocks(&h, &c, 0xFFFFFFFF, block[:])

	var sum [Size]byte
	for i, v := range h[:(d.size+3)/4] {
		binary.LittleEndian.PutUint32(sum[4*i:], v)
	}

	return append(b, sum[:d.size]...)
}
