// Copyright (c) 2016 Andreas Auernhammer. All rights reserved.
// Use of this source code is governed by a license that can be
// found in the LICENSE file.

// +build amd64, !gccgo, !appengine

#include "textflag.h"

DATA iv0<>+0x00(SB)/4, $0x6a09e667
DATA iv0<>+0x04(SB)/4, $0xbb67ae85
DATA iv0<>+0x08(SB)/4, $0x3c6ef372
DATA iv0<>+0x0c(SB)/4, $0xa54ff53a
GLOBL iv0<>(SB), (NOPTR+RODATA), $16

DATA iv1<>+0x00(SB)/4, $0x510e527f 
DATA iv1<>+0x04(SB)/4, $0x9b05688c
DATA iv1<>+0x08(SB)/4, $0x1f83d9ab
DATA iv1<>+0x0c(SB)/4, $0x5be0cd19
GLOBL iv1<>(SB), (NOPTR+RODATA), $16

#define ROTL_SSE2(n, t, v) \
 	MOVO v, t; \
	PSLLL $n, t; \
	PSRLL $(32-n), v; \
	PXOR t, v

#define ROUND(v0 , v1, v2, v3, m0, m1, m2, m3) \
    PADDD m0, v0; \
    PADDD v1, v0; \
    PXOR v0, v3; \
    ROTL_SSE2(16, X15, v3); \
    PADDD v3, v2; \
    PXOR v2, v1; \
    ROTL_SSE2(20, X15, v1); \
    PADDD m1, v0; \
    PADDD v1, v0; \
    PXOR v0, v3; \
    ROTL_SSE2(24, X15, v3); \
    PADDD v3, v2; \
    PXOR v2, v1; \
    ROTL_SSE2(25, X15, v1); \
    PSHUFL $0x39, X5, X5; \
    PSHUFL $0x4E, X6, X6; \
    PSHUFL $0x93, X7, X7; \
    PADDD m2, v0; \
    PADDD v1, v0; \
    PXOR v0, v3; \
    ROTL_SSE2(16, X15, v3); \
    PADDD v3, v2; \
    PXOR v2, v1; \
    ROTL_SSE2(20, X15, v1); \
    PADDD m3, v0; \
    PADDD v1, v0; \
    PXOR v0, v3; \
    ROTL_SSE2(24, X15, v3); \
    PADDD v3, v2; \
    PXOR v2, v1; \
    ROTL_SSE2(25, X15, v1); \    
    PSHUFL $0x39, X7, X7; \
    PSHUFL $0x4E, X6, X6; \
    PSHUFL $0x93, X5, X5; \

#define PRECOMPUTE(dst, off, src) \
    MOVL 0*4(src), R15; \
	MOVL R15, 0*4+off+0(dst); \
	MOVL R15, 9*4+off+64(dst); \
	MOVL R15, 5*4+off+128(dst); \
	MOVL R15, 14*4+off+192(dst); \
	MOVL R15, 4*4+off+256(dst); \
	MOVL R15, 2*4+off+320(dst); \
	MOVL R15, 8*4+off+384(dst); \
	MOVL R15, 12*4+off+448(dst); \
	MOVL R15, 3*4+off+512(dst); \
	MOVL R15, 15*4+off+576(dst); \
	MOVL 1*4(src), R15; \
	MOVL R15, 4*4+off+0(dst); \
	MOVL R15, 8*4+off+64(dst); \
	MOVL R15, 14*4+off+128(dst); \
	MOVL R15, 5*4+off+192(dst); \
	MOVL R15, 12*4+off+256(dst); \
	MOVL R15, 11*4+off+320(dst); \
	MOVL R15, 1*4+off+384(dst); \
	MOVL R15, 6*4+off+448(dst); \
	MOVL R15, 10*4+off+512(dst); \
	MOVL R15, 3*4+off+576(dst); \
	MOVL 2*4(src), R15; \
	MOVL R15, 1*4+off+0(dst); \
	MOVL R15, 13*4+off+64(dst); \
	MOVL R15, 6*4+off+128(dst); \
	MOVL R15, 8*4+off+192(dst); \
	MOVL R15, 2*4+off+256(dst); \
	MOVL R15, 0*4+off+320(dst); \
	MOVL R15, 14*4+off+384(dst); \
	MOVL R15, 11*4+off+448(dst); \
	MOVL R15, 12*4+off+512(dst); \
	MOVL R15, 4*4+off+576(dst); \
	MOVL 3*4(src), R15; \
	MOVL R15, 5*4+off+0(dst); \
	MOVL R15, 15*4+off+64(dst); \
	MOVL R15, 9*4+off+128(dst); \
	MOVL R15, 1*4+off+192(dst); \
	MOVL R15, 11*4+off+256(dst); \
	MOVL R15, 7*4+off+320(dst); \
	MOVL R15, 13*4+off+384(dst); \
	MOVL R15, 3*4+off+448(dst); \
	MOVL R15, 6*4+off+512(dst); \
	MOVL R15, 10*4+off+576(dst); \
	MOVL 4*4(src), R15; \
	MOVL R15, 2*4+off+0(dst); \
	MOVL R15, 1*4+off+64(dst); \
	MOVL R15, 15*4+off+128(dst); \
	MOVL R15, 10*4+off+192(dst); \
	MOVL R15, 6*4+off+256(dst); \
	MOVL R15, 8*4+off+320(dst); \
	MOVL R15, 3*4+off+384(dst); \
	MOVL R15, 13*4+off+448(dst); \
	MOVL R15, 14*4+off+512(dst); \
	MOVL R15, 5*4+off+576(dst); \
	MOVL 5*4(src), R15; \
	MOVL R15, 6*4+off+0(dst); \
	MOVL R15, 11*4+off+64(dst); \
	MOVL R15, 2*4+off+128(dst); \
	MOVL R15, 9*4+off+192(dst); \
	MOVL R15, 1*4+off+256(dst); \
	MOVL R15, 13*4+off+320(dst); \
	MOVL R15, 4*4+off+384(dst); \
	MOVL R15, 8*4+off+448(dst); \
	MOVL R15, 15*4+off+512(dst); \
	MOVL R15, 7*4+off+576(dst); \
	MOVL 6*4(src), R15; \
	MOVL R15, 3*4+off+0(dst); \
	MOVL R15, 7*4+off+64(dst); \
	MOVL R15, 13*4+off+128(dst); \
	MOVL R15, 12*4+off+192(dst); \
	MOVL R15, 10*4+off+256(dst); \
	MOVL R15, 1*4+off+320(dst); \
	MOVL R15, 9*4+off+384(dst); \
	MOVL R15, 14*4+off+448(dst); \
	MOVL R15, 0*4+off+512(dst); \
	MOVL R15, 6*4+off+576(dst); \
	MOVL 7*4(src), R15; \
	MOVL R15, 7*4+off+0(dst); \
	MOVL R15, 14*4+off+64(dst); \
	MOVL R15, 10*4+off+128(dst); \
	MOVL R15, 0*4+off+192(dst); \
	MOVL R15, 5*4+off+256(dst); \
	MOVL R15, 9*4+off+320(dst); \
	MOVL R15, 12*4+off+384(dst); \
	MOVL R15, 1*4+off+448(dst); \
	MOVL R15, 13*4+off+512(dst); \
	MOVL R15, 2*4+off+576(dst); \
	MOVL 8*4(src), R15; \
	MOVL R15, 8*4+off+0(dst); \
	MOVL R15, 5*4+off+64(dst); \
	MOVL R15, 4*4+off+128(dst); \
	MOVL R15, 15*4+off+192(dst); \
	MOVL R15, 14*4+off+256(dst); \
	MOVL R15, 3*4+off+320(dst); \
	MOVL R15, 11*4+off+384(dst); \
	MOVL R15, 10*4+off+448(dst); \
	MOVL R15, 7*4+off+512(dst); \
	MOVL R15, 1*4+off+576(dst); \
	MOVL 9*4(src), R15; \
	MOVL R15, 12*4+off+0(dst); \
	MOVL R15, 2*4+off+64(dst); \
	MOVL R15, 11*4+off+128(dst); \
	MOVL R15, 4*4+off+192(dst); \
	MOVL R15, 0*4+off+256(dst); \
	MOVL R15, 15*4+off+320(dst); \
	MOVL R15, 10*4+off+384(dst); \
	MOVL R15, 7*4+off+448(dst); \
	MOVL R15, 5*4+off+512(dst); \
	MOVL R15, 9*4+off+576(dst); \
	MOVL 10*4(src), R15; \
	MOVL R15, 9*4+off+0(dst); \
	MOVL R15, 4*4+off+64(dst); \
	MOVL R15, 8*4+off+128(dst); \
	MOVL R15, 13*4+off+192(dst); \
	MOVL R15, 3*4+off+256(dst); \
	MOVL R15, 5*4+off+320(dst); \
	MOVL R15, 7*4+off+384(dst); \
	MOVL R15, 15*4+off+448(dst); \
	MOVL R15, 11*4+off+512(dst); \
	MOVL R15, 0*4+off+576(dst); \
	MOVL 11*4(src), R15; \
	MOVL R15, 13*4+off+0(dst); \
	MOVL R15, 10*4+off+64(dst); \
	MOVL R15, 0*4+off+128(dst); \
	MOVL R15, 3*4+off+192(dst); \
	MOVL R15, 9*4+off+256(dst); \
	MOVL R15, 6*4+off+320(dst); \
	MOVL R15, 15*4+off+384(dst); \
	MOVL R15, 4*4+off+448(dst); \
	MOVL R15, 2*4+off+512(dst); \
	MOVL R15, 12*4+off+576(dst); \
	MOVL 12*4(src), R15; \
	MOVL R15, 10*4+off+0(dst); \
	MOVL R15, 12*4+off+64(dst); \
	MOVL R15, 1*4+off+128(dst); \
	MOVL R15, 6*4+off+192(dst); \
	MOVL R15, 13*4+off+256(dst); \
	MOVL R15, 4*4+off+320(dst); \
	MOVL R15, 0*4+off+384(dst); \
	MOVL R15, 2*4+off+448(dst); \
	MOVL R15, 8*4+off+512(dst); \
	MOVL R15, 14*4+off+576(dst); \
	MOVL 13*4(src), R15; \
	MOVL R15, 14*4+off+0(dst); \
	MOVL R15, 3*4+off+64(dst); \
	MOVL R15, 7*4+off+128(dst); \
	MOVL R15, 2*4+off+192(dst); \
	MOVL R15, 15*4+off+256(dst); \
	MOVL R15, 12*4+off+320(dst); \
	MOVL R15, 6*4+off+384(dst); \
	MOVL R15, 0*4+off+448(dst); \
	MOVL R15, 9*4+off+512(dst); \
	MOVL R15, 11*4+off+576(dst); \
	MOVL 14*4(src), R15; \
	MOVL R15, 11*4+off+0(dst); \
	MOVL R15, 0*4+off+64(dst); \
	MOVL R15, 12*4+off+128(dst); \
	MOVL R15, 7*4+off+192(dst); \
	MOVL R15, 8*4+off+256(dst); \
	MOVL R15, 14*4+off+320(dst); \
	MOVL R15, 2*4+off+384(dst); \
	MOVL R15, 5*4+off+448(dst); \
	MOVL R15, 1*4+off+512(dst); \
	MOVL R15, 13*4+off+576(dst); \
	MOVL 15*4(src), R15; \
	MOVL R15, 15*4+off+0(dst); \
	MOVL R15, 6*4+off+64(dst); \
	MOVL R15, 3*4+off+128(dst); \
	MOVL R15, 11*4+off+192(dst); \
	MOVL R15, 7*4+off+256(dst); \
	MOVL R15, 10*4+off+320(dst); \
	MOVL R15, 5*4+off+384(dst); \
	MOVL R15, 9*4+off+448(dst); \
	MOVL R15, 4*4+off+512(dst); \
	MOVL R15, 8*4+off+576(dst)

//func hashBlocksSSE2(h *[8]uint32, c *[2]uint32, flag uint32, blocks []byte)
TEXT ·hashBlocksSSE2(SB),4,$0-48
    MOVQ h+0(FP), AX
    MOVQ c+8(FP), BX
    MOVL flag+16(FP), DI
    MOVQ blocks_base+24(FP), CX
    MOVQ blocks_len+32(FP), DX

    MOVQ SP, SI
	ANDQ $0xFFFFFFFFFFFFFFF0, SP
	SUBQ $(16+16+640), SP

    MOVQ 0(BX), R9
    MOVQ R9, 0(SP)
    XORQ R9, R9
    MOVQ R9, 8(SP)
    MOVL DI, 8(SP)

    MOVOU 0(AX), X0
    MOVOU 16(AX), X1
    MOVOU iv0<>(SB), X2
    MOVOU iv1<>(SB), X3
loop:
    ADDQ $64, 0(SP)
    MOVO X0, X4
    MOVO X1, X5
    MOVO X2, X6
    MOVO X3, X7

    MOVOU 0(SP), X8
    PXOR X8, X7

    PRECOMPUTE(SP, 16, CX)
    ROUND(X4, X5, X6, X7, 16(SP), 32(SP), 48(SP), 64(SP))
    ROUND(X4, X5, X6, X7, 16+64(SP), 32+64(SP), 48+64(SP), 64+64(SP))
    ROUND(X4, X5, X6, X7, 16+128(SP), 32+128(SP), 48+128(SP), 64+128(SP))
    ROUND(X4, X5, X6, X7, 16+192(SP), 32+192(SP), 48+192(SP), 64+192(SP))
    ROUND(X4, X5, X6, X7, 16+256(SP), 32+256(SP), 48+256(SP), 64+256(SP))
    ROUND(X4, X5, X6, X7, 16+320(SP), 32+320(SP), 48+320(SP), 64+320(SP))
    ROUND(X4, X5, X6, X7, 16+384(SP), 32+384(SP), 48+384(SP), 64+384(SP))
    ROUND(X4, X5, X6, X7, 16+448(SP), 32+448(SP), 48+448(SP), 64+448(SP))
    ROUND(X4, X5, X6, X7, 16+512(SP), 32+512(SP), 48+512(SP), 64+512(SP))
    ROUND(X4, X5, X6, X7, 16+576(SP), 32+576(SP), 48+576(SP), 64+576(SP))
    
    PXOR X4, X0
    PXOR X5, X1
    PXOR X6, X0
    PXOR X7, X1

    LEAQ 64(CX), CX
    SUBQ $64, DX 
    JNE loop

    MOVQ 0(SP), R9
    MOVQ R9, 0(BX)

    MOVOU X0, 0(AX)
    MOVOU X1, 16(AX)

    MOVQ SI, SP
    RET
