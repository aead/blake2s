// Copyright (c) 2016 Andreas Auernhammer. All rights reserved.
// Use of this source code is governed by a license that can be
// found in the LICENSE file.

package blake2s

// the precomputed values for BLAKE2s
// there are 10 16-byte arrays - one for each round
// the entries are calculated from the sigma constants.
var precomputed = [10][16]byte{
	{0, 2, 4, 6, 5, 7, 3, 1, 8, 10, 12, 14, 13, 15, 11, 9},
	{14, 4, 9, 13, 15, 6, 8, 10, 1, 0, 11, 5, 7, 3, 2, 12},
	{11, 12, 5, 15, 2, 13, 0, 8, 10, 3, 7, 9, 1, 4, 6, 14},
	{7, 3, 13, 11, 12, 14, 1, 9, 2, 5, 4, 15, 0, 8, 10, 6},
	{9, 5, 2, 10, 4, 15, 7, 0, 14, 11, 6, 3, 8, 13, 12, 1},
	{2, 6, 0, 8, 11, 3, 10, 12, 4, 7, 15, 1, 14, 9, 5, 13},
	{12, 1, 14, 4, 13, 10, 15, 5, 0, 6, 9, 8, 2, 11, 3, 7},
	{13, 7, 12, 3, 1, 9, 14, 11, 5, 15, 8, 2, 6, 10, 4, 0},
	{6, 14, 11, 0, 3, 8, 9, 15, 12, 13, 1, 10, 4, 5, 7, 2},
	{10, 8, 7, 1, 6, 5, 4, 2, 15, 9, 3, 13, 12, 0, 14, 11},
}

func hashBlocksGeneric(h *[8]uint32, c *[2]uint32, flag uint32, blocks []byte) {
	var m [16]uint32
	c0, c1 := c[0], c[1]

	for i := 0; i < len(blocks); {
		c0 += BlockSize
		if c0 < BlockSize {
			c1++
		}

		v0, v1, v2, v3, v4, v5, v6, v7 := h[0], h[1], h[2], h[3], h[4], h[5], h[6], h[7]
		v8, v9, v10, v11, v12, v13, v14, v15 := iv[0], iv[1], iv[2], iv[3], iv[4], iv[5], iv[6], iv[7]
		v12 ^= c0
		v13 ^= c1
		v14 ^= flag

		for j := range m {
			m[j] = uint32(blocks[i]) | uint32(blocks[i+1])<<8 | uint32(blocks[i+2])<<16 | uint32(blocks[i+3])<<24
			i += 4
		}

		for k := range precomputed {
			s := &(precomputed[k])

			v0 += m[s[0]]
			v0 += v4
			v12 ^= v0
			v12 = v12<<(32-16) | v12>>16
			v8 += v12
			v4 ^= v8
			v4 = v4<<(32-12) | v4>>12
			v1 += m[s[1]]
			v1 += v5
			v13 ^= v1
			v13 = v13<<(32-16) | v13>>16
			v9 += v13
			v5 ^= v9
			v5 = v5<<(32-12) | v5>>12
			v2 += m[s[2]]
			v2 += v6
			v14 ^= v2
			v14 = v14<<(32-16) | v14>>16
			v10 += v14
			v6 ^= v10
			v6 = v6<<(32-12) | v6>>12
			v3 += m[s[3]]
			v3 += v7
			v15 ^= v3
			v15 = v15<<(32-16) | v15>>16
			v11 += v15
			v7 ^= v11
			v7 = v7<<(32-12) | v7>>12

			v0 += m[s[7]]
			v0 += v4
			v12 ^= v0
			v12 = v12<<(32-8) | v12>>8
			v8 += v12
			v4 ^= v8
			v4 = v4<<(32-7) | v4>>7
			v1 += m[s[6]]
			v1 += v5
			v13 ^= v1
			v13 = v13<<(32-8) | v13>>8
			v9 += v13
			v5 ^= v9
			v5 = v5<<(32-7) | v5>>7
			v2 += m[s[4]]
			v2 += v6
			v14 ^= v2
			v14 = v14<<(32-8) | v14>>8
			v10 += v14
			v6 ^= v10
			v6 = v6<<(32-7) | v6>>7
			v3 += m[s[5]]
			v3 += v7
			v15 ^= v3
			v15 = v15<<(32-8) | v15>>8
			v11 += v15
			v7 ^= v11
			v7 = v7<<(32-7) | v7>>7

			v0 += m[s[8]]
			v0 += v5
			v15 ^= v0
			v15 = v15<<(32-16) | v15>>16
			v10 += v15
			v5 ^= v10
			v5 = v5<<(32-12) | v5>>12
			v1 += m[s[9]]
			v1 += v6
			v12 ^= v1
			v12 = v12<<(32-16) | v12>>16
			v11 += v12
			v6 ^= v11
			v6 = v6<<(32-12) | v6>>12
			v2 += m[s[10]]
			v2 += v7
			v13 ^= v2
			v13 = v13<<(32-16) | v13>>16
			v8 += v13
			v7 ^= v8
			v7 = v7<<(32-12) | v7>>12
			v3 += m[s[11]]
			v3 += v4
			v14 ^= v3
			v14 = v14<<(32-16) | v14>>16
			v9 += v14
			v4 ^= v9
			v4 = v4<<(32-12) | v4>>12

			v0 += m[s[15]]
			v0 += v5
			v15 ^= v0
			v15 = v15<<(32-8) | v15>>8
			v10 += v15
			v5 ^= v10
			v5 = v5<<(32-7) | v5>>7
			v1 += m[s[14]]
			v1 += v6
			v12 ^= v1
			v12 = v12<<(32-8) | v12>>8
			v11 += v12
			v6 ^= v11
			v6 = v6<<(32-7) | v6>>7
			v2 += m[s[12]]
			v2 += v7
			v13 ^= v2
			v13 = v13<<(32-8) | v13>>8
			v8 += v13
			v7 ^= v8
			v7 = v7<<(32-7) | v7>>7
			v3 += m[s[13]]
			v3 += v4
			v14 ^= v3
			v14 = v14<<(32-8) | v14>>8
			v9 += v14
			v4 ^= v9
			v4 = v4<<(32-7) | v4>>7
		}

		h[0] ^= v0 ^ v8
		h[1] ^= v1 ^ v9
		h[2] ^= v2 ^ v10
		h[3] ^= v3 ^ v11
		h[4] ^= v4 ^ v12
		h[5] ^= v5 ^ v13
		h[6] ^= v6 ^ v14
		h[7] ^= v7 ^ v15
	}
	c[0], c[1] = c0, c1
}