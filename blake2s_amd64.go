// Copyright (c) 2016 Andreas Auernhammer. All rights reserved.
// Use of this source code is governed by a license that can be
// found in the LICENSE file.

// +build amd64, !gccgo, !appengine

package blake2s

var useSSSE3 = supportSSSE3()

//go:noescape
func supportSSSE3() bool

//go:noescape
func hashBlocksSSE2(h *[8]uint32, c *[2]uint32, flag uint32, blocks []byte)

//go:noescape
func hashBlocksSSSE3(h *[8]uint32, c *[2]uint32, flag uint32, blocks []byte)

func hashBlocks(h *[8]uint32, c *[2]uint32, flag uint32, blocks []byte) {
	if useSSSE3 {
		hashBlocksSSSE3(h, c, flag, blocks)
	} else {
		hashBlocksSSE2(h, c, flag, blocks)
	}
}
