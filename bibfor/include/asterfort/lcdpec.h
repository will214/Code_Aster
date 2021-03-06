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
    subroutine lcdpec(vind, nbcomm, nmat, ndt, cpmono,&
                      materf, iter, nvi, itmax, toler,&
                      pgl, nfs, nsg, toutms, hsr,&
                      dt, dy, yd, vinf, tampon,&
                      sigf, df, nr, mod,&
                      codret)
        integer :: nsg
        integer :: nfs
        integer :: nmat
        real(kind=8) :: vind(*)
        integer :: nbcomm(nmat, 3)
        integer :: ndt
        character(len=24) :: cpmono(5*nmat+1)
        real(kind=8) :: materf(nmat*2)
        integer :: iter
        integer :: nvi
        integer :: itmax
        real(kind=8) :: toler
        real(kind=8) :: pgl(3, 3)
        real(kind=8) :: toutms(nfs, nsg, 6)
        real(kind=8) :: hsr(nsg, nsg)
        real(kind=8) :: dt
        real(kind=8) :: dy(*)
        real(kind=8) :: yd(*)
        real(kind=8) :: vinf(*)
        real(kind=8) :: tampon(*)
        real(kind=8) :: sigf(6)
        real(kind=8) :: df(3, 3)
        integer :: nr
        character(len=8) :: mod
        integer :: codret
    end subroutine lcdpec
end interface
