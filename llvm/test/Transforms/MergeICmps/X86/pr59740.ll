; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -passes=mergeicmps -verify-dom-info -S -mtriple=x86_64-unknown-unknown | FileCheck %s

%struct.S = type { i8, i8, i8, i8 }
%struct1.S = type { ptr, ptr, ptr, i8 }

define noundef i1 @full_sequent_ne(ptr nocapture readonly align 1 dereferenceable(4) %s0, ptr nocapture readonly align 1 dereferenceable(4) %s1) {
; CHECK-LABEL: @full_sequent_ne(
; CHECK-NEXT:  "bb0+bb1+bb2+bb3":
; CHECK-NEXT:    [[MEMCMP:%.*]] = call i32 @memcmp(ptr [[S0:%.*]], ptr [[S1:%.*]], i64 4)
; CHECK-NEXT:    [[TMP0:%.*]] = icmp ne i32 [[MEMCMP]], 0
; CHECK-NEXT:    br label [[BB4:%.*]]
; CHECK:       bb4:
; CHECK-NEXT:    ret i1 [[TMP0]]
;
bb0:
  %v0 = load i8, ptr %s0, align 1
  %v1 = load i8, ptr %s1, align 1
  %cmp0 = icmp eq i8 %v0, %v1
  br i1 %cmp0, label %bb1, label %bb4

bb1:                                              ; preds = %bb0
  %s2 = getelementptr inbounds %struct.S, ptr %s0, i64 0, i32 1
  %v2 = load i8, ptr %s2, align 1
  %s3 = getelementptr inbounds %struct.S, ptr %s1, i64 0, i32 1
  %v3 = load i8, ptr %s3, align 1
  %cmp1 = icmp eq i8 %v2, %v3
  br i1 %cmp1, label %bb2, label %bb4

bb2:                                             ; preds = %bb1
  %s4 = getelementptr inbounds %struct.S, ptr %s0, i64 0, i32 2
  %v4 = load i8, ptr %s4, align 1
  %s5 = getelementptr inbounds %struct.S, ptr %s1, i64 0, i32 2
  %v5 = load i8, ptr %s5, align 1
  %cmp2 = icmp eq i8 %v4, %v5
  br i1 %cmp2, label %bb3, label %bb4

bb3:                                               ; preds = %bb2
  %s6 = getelementptr inbounds %struct.S, ptr %s0, i64 0, i32 3
  %v6 = load i8, ptr %s6, align 1
  %s7 = getelementptr inbounds %struct.S, ptr %s1, i64 0, i32 3
  %v7 = load i8, ptr %s7, align 1
  %cmp3 = icmp ne i8 %v6, %v7
  br label %bb4

bb4:                                               ; preds = %bb0, %bb1, %bb2, %bb3
  %cmp = phi i1 [ true, %bb0 ], [ true, %bb1 ], [ true, %bb2 ], [ %cmp3, %bb3 ]
  ret i1 %cmp
}

; Negative test: Incorrect const value in PHI node
define noundef i1 @cmp_ne_incorrect_const(ptr nocapture readonly align 1 dereferenceable(4) %s0, ptr nocapture readonly align 1 dereferenceable(4) %s1) {
; CHECK-LABEL: @cmp_ne_incorrect_const(
; CHECK-NEXT:  bb0:
; CHECK-NEXT:    [[V0:%.*]] = load i8, ptr [[S0:%.*]], align 1
; CHECK-NEXT:    [[V1:%.*]] = load i8, ptr [[S1:%.*]], align 1
; CHECK-NEXT:    [[CMP0:%.*]] = icmp eq i8 [[V0]], [[V1]]
; CHECK-NEXT:    br i1 [[CMP0]], label [[BB1:%.*]], label [[BB2:%.*]]
; CHECK:       bb1:
; CHECK-NEXT:    [[S6:%.*]] = getelementptr inbounds [[STRUCT_S:%.*]], ptr [[S0]], i64 0, i32 1
; CHECK-NEXT:    [[V6:%.*]] = load i8, ptr [[S6]], align 1
; CHECK-NEXT:    [[S7:%.*]] = getelementptr inbounds [[STRUCT_S]], ptr [[S1]], i64 0, i32 1
; CHECK-NEXT:    [[V7:%.*]] = load i8, ptr [[S7]], align 1
; CHECK-NEXT:    [[CMP3:%.*]] = icmp ne i8 [[V6]], [[V7]]
; CHECK-NEXT:    br label [[BB2]]
; CHECK:       bb2:
; CHECK-NEXT:    [[CMP:%.*]] = phi i1 [ false, [[BB0:%.*]] ], [ [[CMP3]], [[BB1]] ]
; CHECK-NEXT:    ret i1 [[CMP]]
;
bb0:
  %v0 = load i8, ptr %s0, align 1
  %v1 = load i8, ptr %s1, align 1
  %cmp0 = icmp eq i8 %v0, %v1
  br i1 %cmp0, label %bb1, label %bb2

bb1:                                               ; preds = %bb0
  %s6 = getelementptr inbounds %struct.S, ptr %s0, i64 0, i32 1
  %v6 = load i8, ptr %s6, align 1
  %s7 = getelementptr inbounds %struct.S, ptr %s1, i64 0, i32 1
  %v7 = load i8, ptr %s7, align 1
  %cmp3 = icmp ne i8 %v6, %v7
  br label %bb2

bb2:                                               ; preds = %bb0, %bb1
  %cmp = phi i1 [ false, %bb0 ], [ %cmp3, %bb1 ]
  ret i1 %cmp
}

define noundef i1 @partial_sequent_eq() {
; CHECK-LABEL: @partial_sequent_eq(
; CHECK-NEXT:  bb01:
; CHECK-NEXT:    [[VARS0:%.*]] = alloca [[STRUCT1_S:%.*]], align 8
; CHECK-NEXT:    [[VARS1:%.*]] = alloca [[STRUCT1_S]], align 8
; CHECK-NEXT:    [[TMP0:%.*]] = load ptr, ptr [[VARS0]], align 8
; CHECK-NEXT:    [[TMP1:%.*]] = load ptr, ptr [[VARS0]], align 8
; CHECK-NEXT:    [[TMP2:%.*]] = icmp eq ptr [[TMP0]], [[TMP1]]
; CHECK-NEXT:    br i1 [[TMP2]], label %"bb1+bb2", label [[BB3:%.*]]
; CHECK:       "bb1+bb2":
; CHECK-NEXT:    [[TMP3:%.*]] = getelementptr inbounds [[STRUCT1_S]], ptr [[VARS0]], i64 0, i32 2
; CHECK-NEXT:    [[TMP4:%.*]] = getelementptr inbounds [[STRUCT1_S]], ptr [[VARS1]], i64 0, i32 2
; CHECK-NEXT:    [[MEMCMP:%.*]] = call i32 @memcmp(ptr [[TMP3]], ptr [[TMP4]], i64 9)
; CHECK-NEXT:    [[TMP5:%.*]] = icmp eq i32 [[MEMCMP]], 0
; CHECK-NEXT:    br label [[BB3]]
; CHECK:       bb3:
; CHECK-NEXT:    [[CMP:%.*]] = phi i1 [ [[TMP5]], %"bb1+bb2" ], [ false, [[BB01:%.*]] ]
; CHECK-NEXT:    ret i1 [[CMP]]
;
bb0:
  %VarS0 = alloca %struct1.S, align 8
  %VarS1 = alloca %struct1.S, align 8
  %v0 = load ptr, ptr %VarS0, align 8
  %v1 = load ptr, ptr %VarS0, align 8
  %cmp0 = icmp eq ptr %v0, %v1
  br i1 %cmp0, label %bb1, label %bb3

bb1:                                              ; preds = %bb0
  %s2 = getelementptr inbounds %struct1.S, ptr %VarS0, i64 0, i32 2
  %v2 = load ptr, ptr %s2, align 8
  %s3 = getelementptr inbounds %struct1.S, ptr %VarS1, i64 0, i32 2
  %v3 = load ptr, ptr %s3, align 8
  %cmp1 = icmp eq ptr %v2, %v3
  br i1 %cmp1, label %bb2, label %bb3

bb2:                                               ; preds = %bb2
  %s6 = getelementptr inbounds %struct1.S, ptr %VarS0, i64 0, i32 3
  %v6 = load i8, ptr %s6, align 1
  %s7 = getelementptr inbounds %struct1.S, ptr %VarS1, i64 0, i32 3
  %v7 = load i8, ptr %s7, align 1
  %cmp3 = icmp eq i8 %v6, %v7
  br label %bb3

bb3:                                               ; preds = %bb0, %bb1, %bb2
  %cmp = phi i1 [ false, %bb0 ], [ false, %bb1 ], [ %cmp3, %bb2 ]
  ret i1 %cmp
}

define noundef i1 @partial_sequent_ne() {
; CHECK-LABEL: @partial_sequent_ne(
; CHECK-NEXT:  bb01:
; CHECK-NEXT:    [[VARS0:%.*]] = alloca [[STRUCT1_S:%.*]], align 8
; CHECK-NEXT:    [[VARS1:%.*]] = alloca [[STRUCT1_S]], align 8
; CHECK-NEXT:    [[TMP0:%.*]] = load ptr, ptr [[VARS0]], align 8
; CHECK-NEXT:    [[TMP1:%.*]] = load ptr, ptr [[VARS0]], align 8
; CHECK-NEXT:    [[TMP2:%.*]] = icmp eq ptr [[TMP0]], [[TMP1]]
; CHECK-NEXT:    br i1 [[TMP2]], label %"bb1+bb2", label [[BB3:%.*]]
; CHECK:       "bb1+bb2":
; CHECK-NEXT:    [[TMP3:%.*]] = getelementptr inbounds [[STRUCT1_S]], ptr [[VARS0]], i64 0, i32 2
; CHECK-NEXT:    [[TMP4:%.*]] = getelementptr inbounds [[STRUCT1_S]], ptr [[VARS1]], i64 0, i32 2
; CHECK-NEXT:    [[MEMCMP:%.*]] = call i32 @memcmp(ptr [[TMP3]], ptr [[TMP4]], i64 9)
; CHECK-NEXT:    [[TMP5:%.*]] = icmp ne i32 [[MEMCMP]], 0
; CHECK-NEXT:    br label [[BB3]]
; CHECK:       bb3:
; CHECK-NEXT:    [[CMP:%.*]] = phi i1 [ [[TMP5]], %"bb1+bb2" ], [ false, [[BB01:%.*]] ]
; CHECK-NEXT:    ret i1 [[CMP]]
;
bb0:
  %VarS0 = alloca %struct1.S, align 8
  %VarS1 = alloca %struct1.S, align 8
  %v0 = load ptr, ptr %VarS0, align 8
  %v1 = load ptr, ptr %VarS0, align 8
  %cmp0 = icmp eq ptr %v0, %v1
  br i1 %cmp0, label %bb1, label %bb3

bb1:                                              ; preds = %bb0
  %s2 = getelementptr inbounds %struct1.S, ptr %VarS0, i64 0, i32 2
  %v2 = load ptr, ptr %s2, align 8
  %s3 = getelementptr inbounds %struct1.S, ptr %VarS1, i64 0, i32 2
  %v3 = load ptr, ptr %s3, align 8
  %cmp1 = icmp eq ptr %v2, %v3
  br i1 %cmp1, label %bb2, label %bb3

bb2:                                               ; preds = %bb2
  %s6 = getelementptr inbounds %struct1.S, ptr %VarS0, i64 0, i32 3
  %v6 = load i8, ptr %s6, align 1
  %s7 = getelementptr inbounds %struct1.S, ptr %VarS1, i64 0, i32 3
  %v7 = load i8, ptr %s7, align 1
  %cmp3 = icmp ne i8 %v6, %v7
  br label %bb3

bb3:                                               ; preds = %bb0, %bb1, %bb2
  %cmp = phi i1 [ true, %bb0 ], [ true, %bb1 ], [ %cmp3, %bb2 ]
  ret i1 %cmp
}
