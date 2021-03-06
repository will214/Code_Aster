subroutine cjssmi(mater, sig, vin, seuili)
    implicit none
!       ================================================================
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
!       CJS        :  SEUIL DU MECANISME ISOTROPE   FI = - I1/3 + Q
!
!       ----------------------------------------------------------------
!       IN  SIG    :  CONTRAINTE
!       IN  VIN    :  VARIABLES INTERNES = ( Q, R, X, ETAT)
!       OUT SEUILI :  SEUIL  ELASTICITE DU MECANISME ISOTROPE
!       ----------------------------------------------------------------
    integer :: ndt, ndi, i
    real(kind=8) :: mater(14, 2), qiso, i1, sig(6), vin(*), seuili, trois
!
    common /tdim/   ndt , ndi
!
    data       trois  /3.d0/
!
!       ----------------------------------------------------------------
!
!
    qiso = vin(1)
    i1=0.d0
    do 10 i = 1, ndi
        i1 = i1 + sig(i)
10  continue
!
    seuili = - (i1+mater(13,2))/trois + qiso
!
end subroutine
