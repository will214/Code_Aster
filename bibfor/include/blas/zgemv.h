!
! COPYRIGHT (C) 1991 - 2015  EDF R&D                WWW.CODE-ASTER.ORG
!
! THIS PROGRAM IS FREE SOFTWARE; YOU CAN REDISTRIBUTE IT AND/OR MODIFY
! IT UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICENSE AS PUBLISHED BY
! THE FREE SOFTWARE FOUNDATION; EITHER VERSION 2 OF THE LICENSE, OR
! (AT YOUR OPTION) ANY LATER VERSION.
!
! THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT
! WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF
! MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. SEE THE GNU
! GENERAL PUBLIC LICENSE FOR MORE DETAILS.
!
! YOU SHOULD HAVE RECEIVED A COPY OF THE GNU GENERAL PUBLIC LICENSE
! ALONG WITH THIS PROGRAM; IF NOT, WRITE TO EDF R&D CODE_ASTER,
! 1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
!
#include "asterf_types.h"

interface
    subroutine zgemv(trans, m, n, alpha, a,&
                     lda, x, incx, beta, y,&
                     incy)
        integer, intent(in) :: lda
        character(len=1) ,intent(in) :: trans
        integer, intent(in) :: m
        integer, intent(in) :: n
        complex(kind=8) ,intent(in) :: alpha
        complex(kind=8) ,intent(in) :: a(lda, *)
        complex(kind=8) ,intent(in) :: x(*)
        integer, intent(in) :: incx
        complex(kind=8) ,intent(in) :: beta
        complex(kind=8) ,intent(inout) :: y(*)
        integer, intent(in) :: incy
    end subroutine zgemv
end interface
