subroutine cjsqij(s, i1, x, q)
    implicit none
!       ----------------------------------------------------------------
! ======================================================================
! COPYRIGHT (C) 1991 - 2015  EDF R&D                  WWW.CODE-ASTER.ORG
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
!    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
! ======================================================================
!       ----------------------------------------------------------------
!       TENSEUR Q = S - I1 * X
!       IN  N      :  DIMENSION DE S, X, Q
!       IN  S      :  DEVIATEUR
!       IN  I1     :  PREMIER INV.
!       IN  X      :  CENTRE DE LA SURFACE DE CHARGE DEVIATOIRE
!       OUT Q      :  TENSEUR RESULTAT
!       ----------------------------------------------------------------
!
    integer :: ndt, ndi, i
    real(kind=8) :: s(6), i1, x(6), q(6)
!
    common /tdim/   ndt , ndi
    do 1 i = 1, ndt
        q(i) = s(i) - i1*x(i)
 1  continue
!
end subroutine
