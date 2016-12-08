; RUN: opt -instcombine -S < %s | FileCheck %s

define i32 @test(i32 %x) {
; CHECK-LABEL: @test
entry:
; CHECK-NOT: icmp
; CHECK: br i1 undef, 
  %cmp = icmp ult i32 %x, 7
  br i1 %cmp, label %merge, label %merge
merge:
; CHECK-LABEL: merge:
; CHECK: ret i32 %x
  ret i32 %x
}

define i32 @test1(i32 %a, i32 %b) {
; CHECK-LABEL: @test1
entry:
  %0 = call { i32, i1 } @llvm.ssub.with.overflow.i32(i32 %a, i32 %b)
  %1 = extractvalue { i32, i1 } %0, 1
  br i1 %1, label %trap, label %cont

trap:
; CHECK-LABEL: trap
  ret i32 -1

cont:
; CHECK-LABEL: cont
  %2 = extractvalue { i32, i1 } %0, 0
  %cmp = icmp eq i32 %2, %a
  br i1 %cmp, label %if.then, label %return

if.then:
; CHECK-LABEL: if.then
; CHECK: ret i32 0
; CHECK-NOT: ret i32 %b
  ret i32 %b

return:
  ret i32 1
}

; Function Attrs: nounwind readnone
declare { i32, i1 } @llvm.ssub.with.overflow.i32(i32, i32) #1
