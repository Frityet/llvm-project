; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -passes=vector-combine -S -mtriple=x86_64-- -mattr=SSE2 | FileCheck %s --check-prefixes=CHECK,SSE
; RUN: opt < %s -passes=vector-combine -S -mtriple=x86_64-- -mattr=AVX2 | FileCheck %s --check-prefixes=CHECK,AVX

; x86 does not have a cheap v16i8 shuffle until SSSE3 (pshufb)

define <16 x i8> @bitcast_shuf_narrow_element(<4 x i32> %v) {
; SSE-LABEL: @bitcast_shuf_narrow_element(
; SSE-NEXT:    [[SHUF:%.*]] = shufflevector <4 x i32> [[V:%.*]], <4 x i32> poison, <4 x i32> <i32 3, i32 2, i32 1, i32 0>
; SSE-NEXT:    [[R:%.*]] = bitcast <4 x i32> [[SHUF]] to <16 x i8>
; SSE-NEXT:    ret <16 x i8> [[R]]
;
; AVX-LABEL: @bitcast_shuf_narrow_element(
; AVX-NEXT:    [[TMP1:%.*]] = bitcast <4 x i32> [[V:%.*]] to <16 x i8>
; AVX-NEXT:    [[R:%.*]] = shufflevector <16 x i8> [[TMP1]], <16 x i8> poison, <16 x i32> <i32 12, i32 13, i32 14, i32 15, i32 8, i32 9, i32 10, i32 11, i32 4, i32 5, i32 6, i32 7, i32 0, i32 1, i32 2, i32 3>
; AVX-NEXT:    ret <16 x i8> [[R]]
;
  %shuf = shufflevector <4 x i32> %v, <4 x i32> poison, <4 x i32> <i32 3, i32 2, i32 1, i32 0>
  %r = bitcast <4 x i32> %shuf to <16 x i8>
  ret <16 x i8> %r
}

; v4f32 is the same cost as v4i32, so this always works

define <4 x float> @bitcast_shuf_same_size(<4 x i32> %v) {
; CHECK-LABEL: @bitcast_shuf_same_size(
; CHECK-NEXT:    [[TMP1:%.*]] = bitcast <4 x i32> [[V:%.*]] to <4 x float>
; CHECK-NEXT:    [[R:%.*]] = shufflevector <4 x float> [[TMP1]], <4 x float> poison, <4 x i32> <i32 3, i32 2, i32 1, i32 0>
; CHECK-NEXT:    ret <4 x float> [[R]]
;
  %shuf = shufflevector <4 x i32> %v, <4 x i32> poison, <4 x i32> <i32 3, i32 2, i32 1, i32 0>
  %r = bitcast <4 x i32> %shuf to <4 x float>
  ret <4 x float> %r
}

; Length-changing shuffles

define <16 x i8> @bitcast_shuf_narrow_element_subvector(<2 x i32> %v) {
; SSE-LABEL: @bitcast_shuf_narrow_element_subvector(
; SSE-NEXT:    [[SHUF:%.*]] = shufflevector <2 x i32> [[V:%.*]], <2 x i32> poison, <4 x i32> <i32 1, i32 0, i32 1, i32 0>
; SSE-NEXT:    [[R:%.*]] = bitcast <4 x i32> [[SHUF]] to <16 x i8>
; SSE-NEXT:    ret <16 x i8> [[R]]
;
; AVX-LABEL: @bitcast_shuf_narrow_element_subvector(
; AVX-NEXT:    [[TMP1:%.*]] = bitcast <2 x i32> [[V:%.*]] to <8 x i8>
; AVX-NEXT:    [[R:%.*]] = shufflevector <8 x i8> [[TMP1]], <8 x i8> poison, <16 x i32> <i32 4, i32 5, i32 6, i32 7, i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 0, i32 1, i32 2, i32 3>
; AVX-NEXT:    ret <16 x i8> [[R]]
;
  %shuf = shufflevector <2 x i32> %v, <2 x i32> poison, <4 x i32> <i32 1, i32 0, i32 1, i32 0>
  %r = bitcast <4 x i32> %shuf to <16 x i8>
  ret <16 x i8> %r
}

define <16 x i16> @bitcast_shuf_narrow_element_concat_subvectors(<2 x i64> %v) {
; SSE-LABEL: @bitcast_shuf_narrow_element_concat_subvectors(
; SSE-NEXT:    [[SHUF:%.*]] = shufflevector <2 x i64> [[V:%.*]], <2 x i64> poison, <4 x i32> <i32 0, i32 1, i32 0, i32 1>
; SSE-NEXT:    [[R:%.*]] = bitcast <4 x i64> [[SHUF]] to <16 x i16>
; SSE-NEXT:    ret <16 x i16> [[R]]
;
; AVX-LABEL: @bitcast_shuf_narrow_element_concat_subvectors(
; AVX-NEXT:    [[TMP1:%.*]] = bitcast <2 x i64> [[V:%.*]] to <8 x i16>
; AVX-NEXT:    [[R:%.*]] = shufflevector <8 x i16> [[TMP1]], <8 x i16> poison, <16 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
; AVX-NEXT:    ret <16 x i16> [[R]]
;
  %shuf = shufflevector <2 x i64> %v, <2 x i64> poison, <4 x i32> <i32 0, i32 1, i32 0, i32 1>
  %r = bitcast <4 x i64> %shuf to <16 x i16>
  ret <16 x i16> %r
}

define <16 x i8> @bitcast_shuf_extract_subvector(<8 x i32> %v) {
; CHECK-LABEL: @bitcast_shuf_extract_subvector(
; CHECK-NEXT:    [[TMP1:%.*]] = bitcast <8 x i32> [[V:%.*]] to <32 x i8>
; CHECK-NEXT:    [[R:%.*]] = shufflevector <32 x i8> [[TMP1]], <32 x i8> poison, <16 x i32> <i32 16, i32 17, i32 18, i32 19, i32 20, i32 21, i32 22, i32 23, i32 24, i32 25, i32 26, i32 27, i32 28, i32 29, i32 30, i32 31>
; CHECK-NEXT:    ret <16 x i8> [[R]]
;
  %shuf = shufflevector <8 x i32> %v, <8 x i32> poison, <4 x i32> <i32 4, i32 5, i32 6, i32 7>
  %r = bitcast <4 x i32> %shuf to <16 x i8>
  ret <16 x i8> %r
}

; Negative test - must cast to vector type

define i128 @bitcast_shuf_narrow_element_wrong_type(<4 x i32> %v) {
; CHECK-LABEL: @bitcast_shuf_narrow_element_wrong_type(
; CHECK-NEXT:    [[SHUF:%.*]] = shufflevector <4 x i32> [[V:%.*]], <4 x i32> poison, <4 x i32> <i32 3, i32 2, i32 1, i32 0>
; CHECK-NEXT:    [[R:%.*]] = bitcast <4 x i32> [[SHUF]] to i128
; CHECK-NEXT:    ret i128 [[R]]
;
  %shuf = shufflevector <4 x i32> %v, <4 x i32> poison, <4 x i32> <i32 3, i32 2, i32 1, i32 0>
  %r = bitcast <4 x i32> %shuf to i128
  ret i128 %r
}

; Widen shuffle elements

define <4 x i32> @bitcast_shuf_wide_element(<8 x i16> %v) {
; CHECK-LABEL: @bitcast_shuf_wide_element(
; CHECK-NEXT:    [[TMP1:%.*]] = bitcast <8 x i16> [[V:%.*]] to <4 x i32>
; CHECK-NEXT:    [[R:%.*]] = shufflevector <4 x i32> [[TMP1]], <4 x i32> poison, <4 x i32> <i32 0, i32 0, i32 1, i32 1>
; CHECK-NEXT:    ret <4 x i32> [[R]]
;
  %shuf = shufflevector <8 x i16> %v, <8 x i16> poison, <8 x i32> <i32 0, i32 1, i32 0, i32 1, i32 2, i32 3, i32 2, i32 3>
  %r = bitcast <8 x i16> %shuf to <4 x i32>
  ret <4 x i32> %r
}

declare void @use(<4 x i32>)

; Negative test - don't create an extra shuffle

define <16 x i8> @bitcast_shuf_uses(<4 x i32> %v) {
; CHECK-LABEL: @bitcast_shuf_uses(
; CHECK-NEXT:    [[SHUF:%.*]] = shufflevector <4 x i32> [[V:%.*]], <4 x i32> poison, <4 x i32> <i32 3, i32 2, i32 1, i32 0>
; CHECK-NEXT:    call void @use(<4 x i32> [[SHUF]])
; CHECK-NEXT:    [[R:%.*]] = bitcast <4 x i32> [[SHUF]] to <16 x i8>
; CHECK-NEXT:    ret <16 x i8> [[R]]
;
  %shuf = shufflevector <4 x i32> %v, <4 x i32> poison, <4 x i32> <i32 3, i32 2, i32 1, i32 0>
  call void @use(<4 x i32> %shuf)
  %r = bitcast <4 x i32> %shuf to <16 x i8>
  ret <16 x i8> %r
}

define <2 x i64> @PR35454_1(<2 x i64> %v) {
; SSE-LABEL: @PR35454_1(
; SSE-NEXT:    [[BC:%.*]] = bitcast <2 x i64> [[V:%.*]] to <4 x i32>
; SSE-NEXT:    [[PERMIL:%.*]] = shufflevector <4 x i32> [[BC]], <4 x i32> poison, <4 x i32> <i32 3, i32 2, i32 1, i32 0>
; SSE-NEXT:    [[BC1:%.*]] = bitcast <4 x i32> [[PERMIL]] to <16 x i8>
; SSE-NEXT:    [[ADD:%.*]] = shl <16 x i8> [[BC1]], splat (i8 1)
; SSE-NEXT:    [[BC2:%.*]] = bitcast <16 x i8> [[ADD]] to <4 x i32>
; SSE-NEXT:    [[PERMIL1:%.*]] = shufflevector <4 x i32> [[BC2]], <4 x i32> poison, <4 x i32> <i32 3, i32 2, i32 1, i32 0>
; SSE-NEXT:    [[BC3:%.*]] = bitcast <4 x i32> [[PERMIL1]] to <2 x i64>
; SSE-NEXT:    ret <2 x i64> [[BC3]]
;
; AVX-LABEL: @PR35454_1(
; AVX-NEXT:    [[TMP1:%.*]] = bitcast <2 x i64> [[V:%.*]] to <16 x i8>
; AVX-NEXT:    [[BC1:%.*]] = shufflevector <16 x i8> [[TMP1]], <16 x i8> poison, <16 x i32> <i32 12, i32 13, i32 14, i32 15, i32 8, i32 9, i32 10, i32 11, i32 4, i32 5, i32 6, i32 7, i32 0, i32 1, i32 2, i32 3>
; AVX-NEXT:    [[ADD:%.*]] = shl <16 x i8> [[BC1]], splat (i8 1)
; AVX-NEXT:    [[BC2:%.*]] = bitcast <16 x i8> [[ADD]] to <4 x i32>
; AVX-NEXT:    [[PERMIL1:%.*]] = shufflevector <4 x i32> [[BC2]], <4 x i32> poison, <4 x i32> <i32 3, i32 2, i32 1, i32 0>
; AVX-NEXT:    [[BC3:%.*]] = bitcast <4 x i32> [[PERMIL1]] to <2 x i64>
; AVX-NEXT:    ret <2 x i64> [[BC3]]
;
  %bc = bitcast <2 x i64> %v to <4 x i32>
  %permil = shufflevector <4 x i32> %bc, <4 x i32> poison, <4 x i32> <i32 3, i32 2, i32 1, i32 0>
  %bc1 = bitcast <4 x i32> %permil to <16 x i8>
  %add = shl <16 x i8> %bc1, <i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1>
  %bc2 = bitcast <16 x i8> %add to <4 x i32>
  %permil1 = shufflevector <4 x i32> %bc2, <4 x i32> poison, <4 x i32> <i32 3, i32 2, i32 1, i32 0>
  %bc3 = bitcast <4 x i32> %permil1 to <2 x i64>
  ret <2 x i64> %bc3
}

define <2 x i64> @PR35454_2(<2 x i64> %v) {
; SSE-LABEL: @PR35454_2(
; SSE-NEXT:    [[BC:%.*]] = bitcast <2 x i64> [[V:%.*]] to <4 x i32>
; SSE-NEXT:    [[PERMIL:%.*]] = shufflevector <4 x i32> [[BC]], <4 x i32> poison, <4 x i32> <i32 3, i32 2, i32 1, i32 0>
; SSE-NEXT:    [[BC1:%.*]] = bitcast <4 x i32> [[PERMIL]] to <8 x i16>
; SSE-NEXT:    [[ADD:%.*]] = shl <8 x i16> [[BC1]], splat (i16 1)
; SSE-NEXT:    [[BC2:%.*]] = bitcast <8 x i16> [[ADD]] to <4 x i32>
; SSE-NEXT:    [[PERMIL1:%.*]] = shufflevector <4 x i32> [[BC2]], <4 x i32> poison, <4 x i32> <i32 3, i32 2, i32 1, i32 0>
; SSE-NEXT:    [[BC3:%.*]] = bitcast <4 x i32> [[PERMIL1]] to <2 x i64>
; SSE-NEXT:    ret <2 x i64> [[BC3]]
;
; AVX-LABEL: @PR35454_2(
; AVX-NEXT:    [[TMP1:%.*]] = bitcast <2 x i64> [[V:%.*]] to <8 x i16>
; AVX-NEXT:    [[BC1:%.*]] = shufflevector <8 x i16> [[TMP1]], <8 x i16> poison, <8 x i32> <i32 6, i32 7, i32 4, i32 5, i32 2, i32 3, i32 0, i32 1>
; AVX-NEXT:    [[ADD:%.*]] = shl <8 x i16> [[BC1]], splat (i16 1)
; AVX-NEXT:    [[BC2:%.*]] = bitcast <8 x i16> [[ADD]] to <4 x i32>
; AVX-NEXT:    [[PERMIL1:%.*]] = shufflevector <4 x i32> [[BC2]], <4 x i32> poison, <4 x i32> <i32 3, i32 2, i32 1, i32 0>
; AVX-NEXT:    [[BC3:%.*]] = bitcast <4 x i32> [[PERMIL1]] to <2 x i64>
; AVX-NEXT:    ret <2 x i64> [[BC3]]
;
  %bc = bitcast <2 x i64> %v to <4 x i32>
  %permil = shufflevector <4 x i32> %bc, <4 x i32> poison, <4 x i32> <i32 3, i32 2, i32 1, i32 0>
  %bc1 = bitcast <4 x i32> %permil to <8 x i16>
  %add = shl <8 x i16> %bc1, <i16 1, i16 1, i16 1, i16 1, i16 1, i16 1, i16 1, i16 1>
  %bc2 = bitcast <8 x i16> %add to <4 x i32>
  %permil1 = shufflevector <4 x i32> %bc2, <4 x i32> poison, <4 x i32> <i32 3, i32 2, i32 1, i32 0>
  %bc3 = bitcast <4 x i32> %permil1 to <2 x i64>
  ret <2 x i64> %bc3
}
