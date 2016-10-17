// Copyright (c) 2016 Andreas Auernhammer. All rights reserved.
// Use of this source code is governed by a license that can be
// found in the LICENSE file.

package blake2s

import (
	"bytes"
	"encoding/hex"
	"hash"
	"testing"
)

func fromHex(s string) []byte {
	b, err := hex.DecodeString(s)
	if err != nil {
		panic(err)
	}
	return b
}

var vectors = []struct {
	key, msg, hash []byte
}{
	// Test vectors from https://blake2.net/blake2s-test.txt
	{
		key:  fromHex("000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f"),
		msg:  []byte(""),
		hash: fromHex("48a8997da407876b3d79c0d92325ad3b89cbb754d86ab71aee047ad345fd2c49"),
	},
	{
		key:  fromHex("000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f"),
		msg:  fromHex("00"),
		hash: fromHex("40d15fee7c328830166ac3f918650f807e7e01e177258cdc0a39b11f598066f1"),
	},
	{
		key:  fromHex("000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f"),
		msg:  fromHex("000102030405060708090a"),
		hash: fromHex("e33c4c9bd0cc7e45c80e65c77fa5997fec7002738541509e68a9423891e822a3"),
	},
	{
		key:  fromHex("000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f"),
		msg:  fromHex("000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f"),
		hash: fromHex("c03bc642b20959cbe133a0303e0c1abff3e31ec8e1a328ec8565c36decff5265"),
	},
	{
		key: fromHex("000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f"),
		msg: fromHex("000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f" +
			"202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f40414" +
			"2434445464748494a4b4c4d4e4f505152535455565758595a5b5c5d5e5f6061626364" +
			"65666768696a6b6c6d6e6f707172737475767778797a7b7c7d7e7f808182838485868" +
			"788898a8b8c8d8e8f909192939495969798999a9b9c9d9e9fa0a1a2a3a4a5a6a7a8a9" +
			"aaabacadaeafb0b1b2b3b4b5b6b7b8b9babbbcbdbebfc0c1c2c3c4c5c6c7c8c9cacbc" +
			"ccdcecfd0d1d2d3d4d5d6d7d8d9dadbdcdddedfe0e1e2e3e4e5e6e7e8e9eaebecedee" +
			"eff0f1f2f3f4f5f6f7f8f9fafbfcfdfe"),
		hash: fromHex("3fb735061abc519dfe979e54c1ee5bfad0a9d858b3315bad34bde999efd724dd"),
	},
}

func TestVectors(t *testing.T) {
	for i, v := range vectors {
		h, err := New256(v.key)
		if err != nil {
			t.Fatalf("Test vector %d : %s", i, err)
		}

		h.Write(v.msg)
		sum := h.Sum(nil)
		if !bytes.Equal(sum, v.hash) {
			t.Fatalf("Test vector %d : got: %x expected: %x", i, sum, v.hash)
		}
	}
}

func generateSequence(out []byte, seed uint32) {
	a := 0xDEAD4BAD * seed // prime
	b := uint32(1)

	for i := range out { // fill the buf
		t := a + b
		a = b
		b = t
		out[i] = byte(t >> 24)
	}
}

func computeMAC(msg []byte, hashsize int, key []byte) (sum []byte) {
	var h hash.Hash
	switch hashsize {
	default:
		panic("Unexpected hashsize") // should never happen
	case Size:
		h, _ = New256(key)
	case Size224:
		h, _ = New224(key)
	case Size160:
		h, _ = New160(key)
	case Size128:
		h, _ = New128(key)
	}
	h.Write(msg)
	sum = h.Sum(sum)
	return
}

func computeHash(msg []byte, hashsize int) (sum []byte) {
	switch hashsize {
	case Size:
		hash := Sum256(msg)
		sum = hash[:]
	case Size224:
		hash := Sum224(msg)
		sum = hash[:]
	case Size160:
		hash := Sum160(msg)
		sum = hash[:]
	case Size128:
		hash := Sum128(msg)
		sum = hash[:]
	}
	return
}

// Test function from RFC 7693.
func TestSelf(t *testing.T) {
	var result = [32]byte{
		0x6A, 0x41, 0x1F, 0x08, 0xCE, 0x25, 0xAD, 0xCD,
		0xFB, 0x02, 0xAB, 0xA6, 0x41, 0x45, 0x1C, 0xEC,
		0x53, 0xC5, 0x98, 0xB2, 0x4F, 0x4F, 0xC7, 0x87,
		0xFB, 0xDC, 0x88, 0x79, 0x7F, 0x4C, 0x1D, 0xFE,
	}
	var hashLens = [4]int{16, 20, 28, 32}
	var msgLens = [6]int{0, 3, 64, 65, 255, 1024}

	msg := make([]byte, 1024)
	key := make([]byte, 32)

	h, _ := New256(nil)
	for _, hashsize := range hashLens {
		for _, msgLength := range msgLens {
			generateSequence(msg[:msgLength], uint32(msgLength)) // unkeyed hash

			md := computeHash(msg[:msgLength], hashsize)
			h.Write(md)

			generateSequence(key[:], uint32(hashsize)) // keyed hash
			md = computeMAC(msg[:msgLength], hashsize, key[:hashsize])
			h.Write(md)
		}
	}

	sum := h.Sum(nil)
	if !bytes.Equal(sum, result[:]) {
		t.Errorf("Selftest failed: got: %x expected: %x", sum, result)
	}
}

// Benchmarks

func benchmarkSum(b *testing.B, size int) {
	data := make([]byte, size)
	b.SetBytes(int64(size))
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		Sum256(data)
	}
}

func benchmarkWrite(b *testing.B, size int) {
	data := make([]byte, size)
	h, _ := New256(nil)
	b.SetBytes(int64(size))
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		h.Write(data)
	}
}

func BenchmarkWrite64(b *testing.B) { benchmarkWrite(b, 64) }
func BenchmarkWrite1K(b *testing.B) { benchmarkWrite(b, 1024) }

func BenchmarkSum64(b *testing.B) { benchmarkSum(b, 64) }
func BenchmarkSum1K(b *testing.B) { benchmarkSum(b, 1024) }
