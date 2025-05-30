! RUN: %flang -E %s 2>&1 | FileCheck %s
! CHECK: if (777 // C comment.eq. 777) then
! CHECK: print *, 'pp031.F no: ', 777 // C comment
*  // C++ comment NOT erased from #define
      integer, parameter :: KWM = 666
#define KWM 777 // C comment
      if (KWM .eq. 777) then
        print *, 'pp031.F FAIL (should not have compiled)'
      else
        print *, 'pp031.F no: ', KWM
      end if
      end
