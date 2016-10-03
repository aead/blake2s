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

DATA rol16<>+0x00(SB)/8, $0x0504070601000302
DATA rol16<>+0x08(SB)/8, $0x0D0C0F0E09080B0A
GLOBL rol16<>(SB), (NOPTR+RODATA), $16

DATA rol8<>+0x00(SB)/8, $0x0407060500030201
DATA rol8<>+0x08(SB)/8, $0x0C0F0E0D080B0A09
GLOBL rol8<>(SB), (NOPTR+RODATA), $16

DATA counter<>+0x00(SB)/8, $0x40
DATA counter<>+0x08(SB)/8, $0x0
GLOBL counter<>(SB), (NOPTR+RODATA), $16

#define ROTL_SSE2(n, t, v) \
	MOVO  v, t;       \
	PSLLL $n, t;      \
	PSRLL $(32-n), v; \
	PXOR  t, v

#define ROTL_SSSE3(c, v) \
	PSHUFB c, v

#define ROUND_SSE2(v0, v1, v2, v3, m0, m1, m2, m3, t) \
	PADDD  m0, v0;        \
	PADDD  v1, v0;        \
	PXOR   v0, v3;        \
	ROTL_SSE2(16, t, v3); \
	PADDD  v3, v2;        \
	PXOR   v2, v1;        \
	ROTL_SSE2(20, t, v1); \
	PADDD  m1, v0;        \
	PADDD  v1, v0;        \
	PXOR   v0, v3;        \
	ROTL_SSE2(24, t, v3); \
	PADDD  v3, v2;        \
	PXOR   v2, v1;        \
	ROTL_SSE2(25, t, v1); \
	PSHUFL $0x39, v1, v1; \
	PSHUFL $0x4E, v2, v2; \
	PSHUFL $0x93, v3, v3; \
	PADDD  m2, v0;        \
	PADDD  v1, v0;        \
	PXOR   v0, v3;        \
	ROTL_SSE2(16, t, v3); \
	PADDD  v3, v2;        \
	PXOR   v2, v1;        \
	ROTL_SSE2(20, t, v1); \
	PADDD  m3, v0;        \
	PADDD  v1, v0;        \
	PXOR   v0, v3;        \
	ROTL_SSE2(24, t, v3); \
	PADDD  v3, v2;        \
	PXOR   v2, v1;        \
	ROTL_SSE2(25, t, v1); \
	PSHUFL $0x39, v3, v3; \
	PSHUFL $0x4E, v2, v2; \
	PSHUFL $0x93, v1, v1

#define ROUND_SSSE3(v0, v1, v2, v3, m0, m1, m2, m3, t, c16, c8) \
	PADDD  m0, v0;        \
	PADDD  v1, v0;        \
	PXOR   v0, v3;        \
	ROTL_SSSE3(c16, v3);  \
	PADDD  v3, v2;        \
	PXOR   v2, v1;        \
	ROTL_SSE2(20, t, v1); \
	PADDD  m1, v0;        \
	PADDD  v1, v0;        \
	PXOR   v0, v3;        \
	ROTL_SSSE3(c8, v3);   \
	PADDD  v3, v2;        \
	PXOR   v2, v1;        \
	ROTL_SSE2(25, t, v1); \
	PSHUFL $0x39, v1, v1; \
	PSHUFL $0x4E, v2, v2; \
	PSHUFL $0x93, v3, v3; \
	PADDD  m2, v0;        \
	PADDD  v1, v0;        \
	PXOR   v0, v3;        \
	ROTL_SSSE3(c16, v3);  \
	PADDD  v3, v2;        \
	PXOR   v2, v1;        \
	ROTL_SSE2(20, t, v1); \
	PADDD  m3, v0;        \
	PADDD  v1, v0;        \
	PXOR   v0, v3;        \
	ROTL_SSSE3(c8, v3);   \
	PADDD  v3, v2;        \
	PXOR   v2, v1;        \
	ROTL_SSE2(25, t, v1); \
	PSHUFL $0x39, v3, v3; \
	PSHUFL $0x4E, v2, v2; \
	PSHUFL $0x93, v1, v1

#define PRECOMPUTE(dst, off, src, R8, R9, R10, R11, R12, R13, R14, R15) \
	MOVQ 0*4(src), R8;           \
	MOVQ 2*4(src), R9;           \
	MOVQ 4*4(src), R10;          \
	MOVQ 6*4(src), R11;          \
	MOVQ 8*4(src), R12;          \
	MOVQ 10*4(src), R13;         \
	MOVQ 12*4(src), R14;         \
	MOVQ 14*4(src), R15;         \
	                             \
	MOVL R8, 0*4+off+0(dst);     \
	MOVL R8, 9*4+off+64(dst);    \
	MOVL R8, 5*4+off+128(dst);   \
	MOVL R8, 14*4+off+192(dst);  \
	MOVL R8, 4*4+off+256(dst);   \
	MOVL R8, 2*4+off+320(dst);   \
	MOVL R8, 8*4+off+384(dst);   \
	MOVL R8, 12*4+off+448(dst);  \
	MOVL R8, 3*4+off+512(dst);   \
	MOVL R8, 15*4+off+576(dst);  \
	SHRQ $32, R8;                \
	MOVL R8, 4*4+off+0(dst);     \
	MOVL R8, 8*4+off+64(dst);    \
	MOVL R8, 14*4+off+128(dst);  \
	MOVL R8, 5*4+off+192(dst);   \
	MOVL R8, 12*4+off+256(dst);  \
	MOVL R8, 11*4+off+320(dst);  \
	MOVL R8, 1*4+off+384(dst);   \
	MOVL R8, 6*4+off+448(dst);   \
	MOVL R8, 10*4+off+512(dst);  \
	MOVL R8, 3*4+off+576(dst);   \
	                             \
	MOVL R9, 1*4+off+0(dst);     \
	MOVL R9, 13*4+off+64(dst);   \
	MOVL R9, 6*4+off+128(dst);   \
	MOVL R9, 8*4+off+192(dst);   \
	MOVL R9, 2*4+off+256(dst);   \
	MOVL R9, 0*4+off+320(dst);   \
	MOVL R9, 14*4+off+384(dst);  \
	MOVL R9, 11*4+off+448(dst);  \
	MOVL R9, 12*4+off+512(dst);  \
	MOVL R9, 4*4+off+576(dst);   \
	SHRQ $32, R9;                \
	MOVL R9, 5*4+off+0(dst);     \
	MOVL R9, 15*4+off+64(dst);   \
	MOVL R9, 9*4+off+128(dst);   \
	MOVL R9, 1*4+off+192(dst);   \
	MOVL R9, 11*4+off+256(dst);  \
	MOVL R9, 7*4+off+320(dst);   \
	MOVL R9, 13*4+off+384(dst);  \
	MOVL R9, 3*4+off+448(dst);   \
	MOVL R9, 6*4+off+512(dst);   \
	MOVL R9, 10*4+off+576(dst);  \
	                             \
	MOVL R10, 2*4+off+0(dst);    \
	MOVL R10, 1*4+off+64(dst);   \
	MOVL R10, 15*4+off+128(dst); \
	MOVL R10, 10*4+off+192(dst); \
	MOVL R10, 6*4+off+256(dst);  \
	MOVL R10, 8*4+off+320(dst);  \
	MOVL R10, 3*4+off+384(dst);  \
	MOVL R10, 13*4+off+448(dst); \
	MOVL R10, 14*4+off+512(dst); \
	MOVL R10, 5*4+off+576(dst);  \
	SHRQ $32, R10;               \
	MOVL R10, 6*4+off+0(dst);    \
	MOVL R10, 11*4+off+64(dst);  \
	MOVL R10, 2*4+off+128(dst);  \
	MOVL R10, 9*4+off+192(dst);  \
	MOVL R10, 1*4+off+256(dst);  \
	MOVL R10, 13*4+off+320(dst); \
	MOVL R10, 4*4+off+384(dst);  \
	MOVL R10, 8*4+off+448(dst);  \
	MOVL R10, 15*4+off+512(dst); \
	MOVL R10, 7*4+off+576(dst);  \
	                             \
	MOVL R11, 3*4+off+0(dst);    \
	MOVL R11, 7*4+off+64(dst);   \
	MOVL R11, 13*4+off+128(dst); \
	MOVL R11, 12*4+off+192(dst); \
	MOVL R11, 10*4+off+256(dst); \
	MOVL R11, 1*4+off+320(dst);  \
	MOVL R11, 9*4+off+384(dst);  \
	MOVL R11, 14*4+off+448(dst); \
	MOVL R11, 0*4+off+512(dst);  \
	MOVL R11, 6*4+off+576(dst);  \
	SHRQ $32, R11;               \
	MOVL R11, 7*4+off+0(dst);    \
	MOVL R11, 14*4+off+64(dst);  \
	MOVL R11, 10*4+off+128(dst); \
	MOVL R11, 0*4+off+192(dst);  \
	MOVL R11, 5*4+off+256(dst);  \
	MOVL R11, 9*4+off+320(dst);  \
	MOVL R11, 12*4+off+384(dst); \
	MOVL R11, 1*4+off+448(dst);  \
	MOVL R11, 13*4+off+512(dst); \
	MOVL R11, 2*4+off+576(dst);  \
	                             \
	MOVL R12, 8*4+off+0(dst);    \
	MOVL R12, 5*4+off+64(dst);   \
	MOVL R12, 4*4+off+128(dst);  \
	MOVL R12, 15*4+off+192(dst); \
	MOVL R12, 14*4+off+256(dst); \
	MOVL R12, 3*4+off+320(dst);  \
	MOVL R12, 11*4+off+384(dst); \
	MOVL R12, 10*4+off+448(dst); \
	MOVL R12, 7*4+off+512(dst);  \
	MOVL R12, 1*4+off+576(dst);  \
	SHRQ $32, R12;               \
	MOVL R12, 12*4+off+0(dst);   \
	MOVL R12, 2*4+off+64(dst);   \
	MOVL R12, 11*4+off+128(dst); \
	MOVL R12, 4*4+off+192(dst);  \
	MOVL R12, 0*4+off+256(dst);  \
	MOVL R12, 15*4+off+320(dst); \
	MOVL R12, 10*4+off+384(dst); \
	MOVL R12, 7*4+off+448(dst);  \
	MOVL R12, 5*4+off+512(dst);  \
	MOVL R12, 9*4+off+576(dst);  \
	                             \
	MOVL R13, 9*4+off+0(dst);    \
	MOVL R13, 4*4+off+64(dst);   \
	MOVL R13, 8*4+off+128(dst);  \
	MOVL R13, 13*4+off+192(dst); \
	MOVL R13, 3*4+off+256(dst);  \
	MOVL R13, 5*4+off+320(dst);  \
	MOVL R13, 7*4+off+384(dst);  \
	MOVL R13, 15*4+off+448(dst); \
	MOVL R13, 11*4+off+512(dst); \
	MOVL R13, 0*4+off+576(dst);  \
	SHRQ $32, R13;               \
	MOVL R13, 13*4+off+0(dst);   \
	MOVL R13, 10*4+off+64(dst);  \
	MOVL R13, 0*4+off+128(dst);  \
	MOVL R13, 3*4+off+192(dst);  \
	MOVL R13, 9*4+off+256(dst);  \
	MOVL R13, 6*4+off+320(dst);  \
	MOVL R13, 15*4+off+384(dst); \
	MOVL R13, 4*4+off+448(dst);  \
	MOVL R13, 2*4+off+512(dst);  \
	MOVL R13, 12*4+off+576(dst); \
	                             \
	MOVL R14, 10*4+off+0(dst);   \
	MOVL R14, 12*4+off+64(dst);  \
	MOVL R14, 1*4+off+128(dst);  \
	MOVL R14, 6*4+off+192(dst);  \
	MOVL R14, 13*4+off+256(dst); \
	MOVL R14, 4*4+off+320(dst);  \
	MOVL R14, 0*4+off+384(dst);  \
	MOVL R14, 2*4+off+448(dst);  \
	MOVL R14, 8*4+off+512(dst);  \
	MOVL R14, 14*4+off+576(dst); \
	SHRQ $32, R14;               \
	MOVL R14, 14*4+off+0(dst);   \
	MOVL R14, 3*4+off+64(dst);   \
	MOVL R14, 7*4+off+128(dst);  \
	MOVL R14, 2*4+off+192(dst);  \
	MOVL R14, 15*4+off+256(dst); \
	MOVL R14, 12*4+off+320(dst); \
	MOVL R14, 6*4+off+384(dst);  \
	MOVL R14, 0*4+off+448(dst);  \
	MOVL R14, 9*4+off+512(dst);  \
	MOVL R14, 11*4+off+576(dst); \
	                             \
	MOVL R15, 11*4+off+0(dst);   \
	MOVL R15, 0*4+off+64(dst);   \
	MOVL R15, 12*4+off+128(dst); \
	MOVL R15, 7*4+off+192(dst);  \
	MOVL R15, 8*4+off+256(dst);  \
	MOVL R15, 14*4+off+320(dst); \
	MOVL R15, 2*4+off+384(dst);  \
	MOVL R15, 5*4+off+448(dst);  \
	MOVL R15, 1*4+off+512(dst);  \
	MOVL R15, 13*4+off+576(dst); \
	SHRQ $32, R15;               \
	MOVL R15, 15*4+off+0(dst);   \
	MOVL R15, 6*4+off+64(dst);   \
	MOVL R15, 3*4+off+128(dst);  \
	MOVL R15, 11*4+off+192(dst); \
	MOVL R15, 7*4+off+256(dst);  \
	MOVL R15, 10*4+off+320(dst); \
	MOVL R15, 5*4+off+384(dst);  \
	MOVL R15, 9*4+off+448(dst);  \
	MOVL R15, 4*4+off+512(dst);  \
	MOVL R15, 8*4+off+576(dst)

// func hashBlocksSSE2(h *[8]uint32, c *[2]uint32, flag uint32, blocks []byte)
TEXT ·hashBlocksSSE2(SB), 4, $0-48
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
	MOVOU counter<>(SB), X12
	MOVO  0(SP), X13

loop:
	MOVO X0, X4
	MOVO X1, X5
	MOVO X2, X6
	MOVO X3, X7

	PADDQ X12, X13
	PXOR  X13, X7

	PRECOMPUTE(SP, 16, CX, R8, R9, R10, R11, R12, R13, R14, R15)
	ROUND_SSE2(X4, X5, X6, X7, 16(SP), 32(SP), 48(SP), 64(SP), X15)
	ROUND_SSE2(X4, X5, X6, X7, 16+64(SP), 32+64(SP), 48+64(SP), 64+64(SP), X15)
	ROUND_SSE2(X4, X5, X6, X7, 16+128(SP), 32+128(SP), 48+128(SP), 64+128(SP), X15)
	ROUND_SSE2(X4, X5, X6, X7, 16+192(SP), 32+192(SP), 48+192(SP), 64+192(SP), X15)
	ROUND_SSE2(X4, X5, X6, X7, 16+256(SP), 32+256(SP), 48+256(SP), 64+256(SP), X15)
	ROUND_SSE2(X4, X5, X6, X7, 16+320(SP), 32+320(SP), 48+320(SP), 64+320(SP), X15)
	ROUND_SSE2(X4, X5, X6, X7, 16+384(SP), 32+384(SP), 48+384(SP), 64+384(SP), X15)
	ROUND_SSE2(X4, X5, X6, X7, 16+448(SP), 32+448(SP), 48+448(SP), 64+448(SP), X15)
	ROUND_SSE2(X4, X5, X6, X7, 16+512(SP), 32+512(SP), 48+512(SP), 64+512(SP), X15)
	ROUND_SSE2(X4, X5, X6, X7, 16+576(SP), 32+576(SP), 48+576(SP), 64+576(SP), X15)

	PXOR X4, X0
	PXOR X5, X1
	PXOR X6, X0
	PXOR X7, X1

	LEAQ 64(CX), CX
	SUBQ $64, DX
	JNE  loop

	MOVO X13, 0(SP)
	MOVQ 0(SP), R9
	MOVQ R9, 0(BX)

	MOVOU X0, 0(AX)
	MOVOU X1, 16(AX)

	MOVQ SI, SP
	RET

// func hashBlocksSSSE3(h *[8]uint32, c *[2]uint32, flag uint32, blocks []byte)
TEXT ·hashBlocksSSSE3(SB), 4, $0-48
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

	MOVOU rol16<>(SB), X10
	MOVOU rol8<>(SB), X11
	MOVOU counter<>(SB), X12
	MOVO  0(SP), X13

loop:
	MOVO X0, X4
	MOVO X1, X5
	MOVO X2, X6
	MOVO X3, X7

	PADDQ X12, X13
	PXOR  X13, X7

	PRECOMPUTE(SP, 16, CX, R8, R9, R10, R11, R12, R13, R14, R15)
	ROUND_SSSE3(X4, X5, X6, X7, 16(SP), 32(SP), 48(SP), 64(SP), X15, X10, X11)
	ROUND_SSSE3(X4, X5, X6, X7, 16+64(SP), 32+64(SP), 48+64(SP), 64+64(SP), X15, X10, X11)
	ROUND_SSSE3(X4, X5, X6, X7, 16+128(SP), 32+128(SP), 48+128(SP), 64+128(SP), X15, X10, X11)
	ROUND_SSSE3(X4, X5, X6, X7, 16+192(SP), 32+192(SP), 48+192(SP), 64+192(SP), X15, X10, X11)
	ROUND_SSSE3(X4, X5, X6, X7, 16+256(SP), 32+256(SP), 48+256(SP), 64+256(SP), X15, X10, X11)
	ROUND_SSSE3(X4, X5, X6, X7, 16+320(SP), 32+320(SP), 48+320(SP), 64+320(SP), X15, X10, X11)
	ROUND_SSSE3(X4, X5, X6, X7, 16+384(SP), 32+384(SP), 48+384(SP), 64+384(SP), X15, X10, X11)
	ROUND_SSSE3(X4, X5, X6, X7, 16+448(SP), 32+448(SP), 48+448(SP), 64+448(SP), X15, X10, X11)
	ROUND_SSSE3(X4, X5, X6, X7, 16+512(SP), 32+512(SP), 48+512(SP), 64+512(SP), X15, X10, X11)
	ROUND_SSSE3(X4, X5, X6, X7, 16+576(SP), 32+576(SP), 48+576(SP), 64+576(SP), X15, X10, X11)

	PXOR X4, X0
	PXOR X5, X1
	PXOR X6, X0
	PXOR X7, X1

	LEAQ 64(CX), CX
	SUBQ $64, DX
	JNE  loop

	MOVO X13, 0(SP)
	MOVQ 0(SP), R9
	MOVQ R9, 0(BX)

	MOVOU X0, 0(AX)
	MOVOU X1, 16(AX)

	MOVQ SI, SP
	RET

// func supportSSSE3() bool
TEXT ·supportSSSE3(SB), 4, $0-1
	XORL CX, CX
	MOVL $1, AX
	CPUID
	MOVL CX, BX
	ANDL $0x1, BX      // BX != 0 if support SSE3
	CMPL BX, $0
	JE   FALSE
	ANDL $0x200, CX    // CX != 0 if support SSSE3
	CMPL CX, $0
	JE   FALSE
	MOVB $1, ret+0(FP)
	JMP  DONE

FALSE:
	MOVB $0, ret+0(FP)

DONE:
	RET

// func supportSSE2() bool
TEXT ·supportSSE2(SB), 4, $0-1
	XORL DX, DX
	MOVL $1, AX
	CPUID
	XORL AX, AX
	ANDL $(1<<26), DX  // DX != 0 if support SSE2
	SHRL $26, DX
	MOVB DX, ret+0(FP)
	RET
