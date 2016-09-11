!
! COPYRIGHT (C) 1991 - 2016  EDF R&D                WWW.CODE-ASTER.ORG
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
interface
    subroutine lc0037(fami, kpg, ksp, ndim, imate,&
                      compor, mult_comp, carcri, instam, instap,&
                      neps, epsm, deps, sigm, vim, option,&
                      angmas, sigp, vip, tm, tp,&
                      tref, tampon, typmod, icomp,&
                      nvi, dsidep, codret)
        real(kind=8) :: tampon(*)
        real(kind=8) :: tm, tp, tref
        integer :: imate, ndim, kpg, ksp, codret, icomp, nvi, neps
        real(kind=8) :: carcri(*), angmas(*), instam, instap
        real(kind=8) :: epsm(neps), deps(neps), sigm(6), sigp(6), vim(*), vip(*)
        real(kind=8) :: dsidep(6, 6)
        character(len=16) :: compor(*), option
        character(len=16), intent(in) :: mult_comp
        character(len=8) :: typmod(*)
        character(len=*) :: fami
    end subroutine lc0037
end interface
