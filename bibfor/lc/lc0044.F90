subroutine lc0044(fami, kpg, ksp, ndim, imate,&
                  compor, crit, instam, instap, epsm,&
                  deps, sigm, vim, option, angmas,&
                  sigp, vip, typmod, icomp,&
                  nvi, dsidep, codret)
! ======================================================================
! COPYRIGHT (C) 1991 - 2017  EDF R&D                  WWW.CODE-ASTER.ORG
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
!   1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
! ======================================================================
! aslint: disable=W1504,W0104
    implicit none
#include "asterfort/brag00.h"
#include "asterfort/rcvarc.h"
#include "asterfort/rcvalb.h"
    integer :: imate, ndim, kpg, ksp, codret, icomp, nvi, iret
    real(kind=8) :: crit(*), angmas(*)
    real(kind=8) :: instam, instap
    real(kind=8) :: epsm(6), deps(6)
    real(kind=8) :: sigm(6), sigp(6)
    real(kind=8) :: vim(*), vip(*), tm, tp, tref
    real(kind=8) :: dsidep(6, 6)
    character(len=16) :: compor(*), option
    character(len=8) :: typmod(*)
    character(len=*) :: fami
!
    real(kind=8) :: valres(1),alpham,alphap
    real(kind=8) :: epsmc(6),depsc(6)
    character(len=16) :: nomres(1)
    integer :: i,icodre(2)
!
! APPEL DE RCVARC POUR LE CALCUL DE LA TEMPERATURE
!
    call rcvarc('F', 'TEMP', '-', fami, kpg,&
                ksp, tm, iret)
    call rcvarc('F', 'TEMP', '+', fami, kpg,&
                ksp, tp, iret)
    call rcvarc('F', 'TEMP', 'REF', fami, kpg,&
                ksp, tref, iret)
!
! PRISE EN COMPTE DES DEFORMATIONS THERMIQUES
!
    nomres(1)='ALPHA'
    call rcvalb(fami, kpg, ksp, '-', imate,&
                ' ', 'ELAS', 0, ' ', [0.d0],&
                1, nomres, valres, icodre, 2)
    alpham = valres(1)
    call rcvalb(fami, kpg, ksp, '+', imate,&
                ' ', 'ELAS', 0, ' ', [0.d0],&
                1, nomres, valres, icodre, 2)
    alphap = valres(1)
    
    if ((option(1:9) .eq. 'RAPH_MECA') .or. (option(1:9) .eq. 'FULL_MECA')) then
      do 10 i = 1, 3
        depsc(i) = deps(i) - (alphap*(tp-tref)-alpham*(tm-tref))
        epsmc(i) = epsm(i) - alpham*(tm-tref)
        depsc(i+3) = deps(i+3)
        epsmc(i+3) = epsm(i+3)
 10   continue
    else
      do 20 i = 1, 3
        depsc(i) = 0.d0
        depsc(i+3) = 0.d0
        epsmc(i) = epsm(i) - alpham*(tm-tref)
        epsmc(i+3) = epsm(i+3)
 20   continue
    endif
!
! ------------------------------------------------
!
!
    call brag00(fami, kpg, ksp, ndim, typmod,&
                imate, compor, instam, instap, tm,&
                tp, tref, epsmc, depsc, sigm,&
                vim, option, sigp, vip, dsidep)
end subroutine
