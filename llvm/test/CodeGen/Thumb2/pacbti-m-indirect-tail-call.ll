; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py UTC_ARGS: --version 5
; RUN: llc %s -o - | FileCheck %s
target datalayout = "e-m:e-p:32:32-Fi8-i64:64-v128:64:128-a:0:32-n32-S64"
target triple = "thumbv8.1m.main-arm-unknown-eabi"

@p = hidden local_unnamed_addr global ptr null, align 4

define hidden i32 @f(i32 %a, i32 %b, i32 %c, i32 %d) local_unnamed_addr #0 {
; CHECK-LABEL: f:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    pac r12, lr, sp
; CHECK-NEXT:    .save {r4, r5, r6, r7, ra_auth_code, lr}
; CHECK-NEXT:    push.w {r4, r5, r6, r7, r12, lr}
; CHECK-NEXT:    mov r7, r3
; CHECK-NEXT:    mov r5, r2
; CHECK-NEXT:    mov r6, r1
; CHECK-NEXT:    bl g
; CHECK-NEXT:    movw r1, :lower16:p
; CHECK-NEXT:    mov r2, r5
; CHECK-NEXT:    movt r1, :upper16:p
; CHECK-NEXT:    mov r3, r7
; CHECK-NEXT:    ldr r4, [r1]
; CHECK-NEXT:    mov r1, r6
; CHECK-NEXT:    blx r4
; CHECK-NEXT:    pop.w {r4, r5, r6, r7, r12, lr}
; CHECK-NEXT:    aut r12, lr, sp
; CHECK-NEXT:    bx lr
entry:
  %call = tail call i32 @g(i32 %a) #0
  %0 = load ptr, ptr @p, align 4
  %call1 = tail call i32 %0(i32 %call, i32 %b, i32 %c, i32 %d) #0
  ret i32 %call1
}

declare dso_local i32 @g(i32) local_unnamed_addr #0

attributes #0 = { nounwind "sign-return-address"="non-leaf"}

!llvm.module.flags = !{!0, !1, !2}

!0 = !{i32 8, !"branch-target-enforcement", i32 0}
!1 = !{i32 8, !"sign-return-address", i32 1}
!2 = !{i32 8, !"sign-return-address-all", i32 0}
