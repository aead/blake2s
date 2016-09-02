// Copyright (c) 2016 Andreas Auernhammer. All rights reserved.
// Use of this source code is governed by a license that can be
// found in the LICENSE file.

package blake2s

func hashBlocks(h *[8]uint32, c *[2]uint32, flag uint32, blocks []byte) {
	hashBlocksGeneric(h, c, flag, blocks)
}
