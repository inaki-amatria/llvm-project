; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --version 4
; RUN: opt < %s -S -passes=loop-unroll,simplifycfg,instcombine -unroll-force-peel-count=3 -verify-dom-info -simplifycfg-require-and-preserve-domtree=1 | FileCheck %s
; RUN: opt < %s -S -passes='require<opt-remark-emit>,loop-unroll,simplifycfg,instcombine' -unroll-force-peel-count=3 -verify-dom-info | FileCheck %s
; RUN: opt < %s -S -passes='require<opt-remark-emit>,loop-unroll<peeling;no-runtime>,simplifycfg,instcombine' -unroll-force-peel-count=3 -verify-dom-info | FileCheck %s

; Basic loop peeling - check that we can peel-off the first 3 loop iterations
; when explicitly requested.
define void @basic(ptr %p, i32 %k) #0 {
; CHECK-LABEL: define void @basic(
; CHECK-SAME: ptr [[P:%.*]], i32 [[K:%.*]]) {
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[CMP3:%.*]] = icmp sgt i32 [[K]], 0
; CHECK-NEXT:    br i1 [[CMP3]], label [[FOR_BODY_PEEL:%.*]], label [[FOR_END:%.*]]
; CHECK:       for.body.peel:
; CHECK-NEXT:    store i32 0, ptr [[P]], align 4
; CHECK-NEXT:    [[CMP_PEEL_NOT:%.*]] = icmp eq i32 [[K]], 1
; CHECK-NEXT:    br i1 [[CMP_PEEL_NOT]], label [[FOR_END]], label [[FOR_BODY_PEEL2:%.*]]
; CHECK:       for.body.peel2:
; CHECK-NEXT:    [[INCDEC_PTR_PEEL:%.*]] = getelementptr inbounds nuw i8, ptr [[P]], i64 4
; CHECK-NEXT:    store i32 1, ptr [[INCDEC_PTR_PEEL]], align 4
; CHECK-NEXT:    [[CMP_PEEL5:%.*]] = icmp sgt i32 [[K]], 2
; CHECK-NEXT:    br i1 [[CMP_PEEL5]], label [[FOR_BODY_PEEL7:%.*]], label [[FOR_END]]
; CHECK:       for.body.peel7:
; CHECK-NEXT:    [[INCDEC_PTR_PEEL3:%.*]] = getelementptr inbounds nuw i8, ptr [[P]], i64 8
; CHECK-NEXT:    [[INCDEC_PTR_PEEL8:%.*]] = getelementptr inbounds nuw i8, ptr [[P]], i64 12
; CHECK-NEXT:    store i32 2, ptr [[INCDEC_PTR_PEEL3]], align 4
; CHECK-NEXT:    [[CMP_PEEL10_NOT:%.*]] = icmp eq i32 [[K]], 3
; CHECK-NEXT:    br i1 [[CMP_PEEL10_NOT]], label [[FOR_END]], label [[FOR_BODY:%.*]]
; CHECK:       for.body:
; CHECK-NEXT:    [[I_05:%.*]] = phi i32 [ [[INC:%.*]], [[FOR_BODY]] ], [ 3, [[FOR_BODY_PEEL7]] ]
; CHECK-NEXT:    [[P_ADDR_04:%.*]] = phi ptr [ [[INCDEC_PTR:%.*]], [[FOR_BODY]] ], [ [[INCDEC_PTR_PEEL8]], [[FOR_BODY_PEEL7]] ]
; CHECK-NEXT:    [[INCDEC_PTR]] = getelementptr inbounds nuw i8, ptr [[P_ADDR_04]], i64 4
; CHECK-NEXT:    store i32 [[I_05]], ptr [[P_ADDR_04]], align 4
; CHECK-NEXT:    [[INC]] = add nuw nsw i32 [[I_05]], 1
; CHECK-NEXT:    [[CMP:%.*]] = icmp slt i32 [[INC]], [[K]]
; CHECK-NEXT:    br i1 [[CMP]], label [[FOR_BODY]], label [[FOR_END]], !llvm.loop [[LOOP0:![0-9]+]]
; CHECK:       for.end:
; CHECK-NEXT:    ret void
;
entry:
  %cmp3 = icmp slt i32 0, %k
  br i1 %cmp3, label %for.body.lr.ph, label %for.end

for.body.lr.ph:                                   ; preds = %entry
  br label %for.body

for.body:                                         ; preds = %for.body.lr.ph, %for.body
  %i.05 = phi i32 [ 0, %for.body.lr.ph ], [ %inc, %for.body ]
  %p.addr.04 = phi ptr [ %p, %for.body.lr.ph ], [ %incdec.ptr, %for.body ]
  %incdec.ptr = getelementptr inbounds i32, ptr %p.addr.04, i32 1
  store i32 %i.05, ptr %p.addr.04, align 4
  %inc = add nsw i32 %i.05, 1
  %cmp = icmp slt i32 %inc, %k
  br i1 %cmp, label %for.body, label %for.cond.for.end_crit_edge, !llvm.loop !1

for.cond.for.end_crit_edge:                       ; preds = %for.body
  br label %for.end

for.end:                                          ; preds = %for.cond.for.end_crit_edge, %entry
  ret void
}

!1 = distinct !{!1}

; Make sure peeling works correctly when a value defined in a loop is used
; in later code - we need to correctly plumb the phi depending on which
; iteration is actually used.
define i32 @output(ptr %p, i32 %k) #0 {
; CHECK-LABEL: define i32 @output(
; CHECK-SAME: ptr [[P:%.*]], i32 [[K:%.*]]) {
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[CMP3:%.*]] = icmp sgt i32 [[K]], 0
; CHECK-NEXT:    br i1 [[CMP3]], label [[FOR_BODY_PEEL:%.*]], label [[FOR_END:%.*]]
; CHECK:       for.body.peel:
; CHECK-NEXT:    store i32 0, ptr [[P]], align 4
; CHECK-NEXT:    [[CMP_PEEL_NOT:%.*]] = icmp eq i32 [[K]], 1
; CHECK-NEXT:    br i1 [[CMP_PEEL_NOT]], label [[FOR_END]], label [[FOR_BODY_PEEL2:%.*]]
; CHECK:       for.body.peel2:
; CHECK-NEXT:    [[INCDEC_PTR_PEEL:%.*]] = getelementptr inbounds nuw i8, ptr [[P]], i64 4
; CHECK-NEXT:    store i32 1, ptr [[INCDEC_PTR_PEEL]], align 4
; CHECK-NEXT:    [[CMP_PEEL5:%.*]] = icmp sgt i32 [[K]], 2
; CHECK-NEXT:    br i1 [[CMP_PEEL5]], label [[FOR_BODY_PEEL7:%.*]], label [[FOR_END]]
; CHECK:       for.body.peel7:
; CHECK-NEXT:    [[INCDEC_PTR_PEEL3:%.*]] = getelementptr inbounds nuw i8, ptr [[P]], i64 8
; CHECK-NEXT:    [[INCDEC_PTR_PEEL8:%.*]] = getelementptr inbounds nuw i8, ptr [[P]], i64 12
; CHECK-NEXT:    store i32 2, ptr [[INCDEC_PTR_PEEL3]], align 4
; CHECK-NEXT:    [[CMP_PEEL10_NOT:%.*]] = icmp eq i32 [[K]], 3
; CHECK-NEXT:    br i1 [[CMP_PEEL10_NOT]], label [[FOR_END]], label [[FOR_BODY:%.*]]
; CHECK:       for.body:
; CHECK-NEXT:    [[I_05:%.*]] = phi i32 [ [[INC:%.*]], [[FOR_BODY]] ], [ 3, [[FOR_BODY_PEEL7]] ]
; CHECK-NEXT:    [[P_ADDR_04:%.*]] = phi ptr [ [[INCDEC_PTR:%.*]], [[FOR_BODY]] ], [ [[INCDEC_PTR_PEEL8]], [[FOR_BODY_PEEL7]] ]
; CHECK-NEXT:    [[INCDEC_PTR]] = getelementptr inbounds nuw i8, ptr [[P_ADDR_04]], i64 4
; CHECK-NEXT:    store i32 [[I_05]], ptr [[P_ADDR_04]], align 4
; CHECK-NEXT:    [[INC]] = add nuw nsw i32 [[I_05]], 1
; CHECK-NEXT:    [[CMP:%.*]] = icmp slt i32 [[INC]], [[K]]
; CHECK-NEXT:    br i1 [[CMP]], label [[FOR_BODY]], label [[FOR_END]], !llvm.loop [[LOOP3:![0-9]+]]
; CHECK:       for.end:
; CHECK-NEXT:    [[RET:%.*]] = phi i32 [ 0, [[ENTRY:%.*]] ], [ 1, [[FOR_BODY_PEEL]] ], [ 2, [[FOR_BODY_PEEL2]] ], [ 3, [[FOR_BODY_PEEL7]] ], [ [[INC]], [[FOR_BODY]] ]
; CHECK-NEXT:    ret i32 [[RET]]
;
entry:
  %cmp3 = icmp slt i32 0, %k
  br i1 %cmp3, label %for.body.lr.ph, label %for.end

for.body.lr.ph:                                   ; preds = %entry
  br label %for.body

for.body:                                         ; preds = %for.body.lr.ph, %for.body
  %i.05 = phi i32 [ 0, %for.body.lr.ph ], [ %inc, %for.body ]
  %p.addr.04 = phi ptr [ %p, %for.body.lr.ph ], [ %incdec.ptr, %for.body ]
  %incdec.ptr = getelementptr inbounds i32, ptr %p.addr.04, i32 1
  store i32 %i.05, ptr %p.addr.04, align 4
  %inc = add nsw i32 %i.05, 1
  %cmp = icmp slt i32 %inc, %k
  br i1 %cmp, label %for.body, label %for.cond.for.end_crit_edge, !llvm.loop !2

for.cond.for.end_crit_edge:                       ; preds = %for.body
  br label %for.end

for.end:                                          ; preds = %for.cond.for.end_crit_edge, %entry
  %ret = phi i32 [ 0, %entry], [ %inc, %for.cond.for.end_crit_edge ]
  ret i32 %ret
}

!2 = distinct !{!2}
;.
; CHECK: [[LOOP0]] = distinct !{[[LOOP0]], [[META1:![0-9]+]], [[META2:![0-9]+]]}
; CHECK: [[META1]] = !{!"llvm.loop.peeled.count", i32 3}
; CHECK: [[META2]] = !{!"llvm.loop.unroll.disable"}
; CHECK: [[LOOP3]] = distinct !{[[LOOP3]], [[META1]], [[META2]]}
;.
