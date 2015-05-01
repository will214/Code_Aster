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
interface
    subroutine mdptem(nbmode, masgen, pulsat, nbchoc, dplmod,&
                      parcho, noecho, dt, dts, dtu,&
                      dtmax, dtmin, tinit, tfin, nbpas,&
                      info, ier, lisins)
        integer :: nbchoc
        integer :: nbmode
        real(kind=8) :: masgen(*)
        real(kind=8) :: pulsat(*)
        real(kind=8) :: dplmod(nbchoc, nbmode, *)
        real(kind=8) :: parcho(nbchoc, *)
        character(len=8) :: noecho(nbchoc, *)
        real(kind=8) :: dt
        real(kind=8) :: dts
        real(kind=8) :: dtu
        real(kind=8) :: dtmax
        real(kind=8) :: dtmin
        real(kind=8) :: tinit
        real(kind=8) :: tfin
        integer :: nbpas
        integer :: info
        integer :: ier
        character(len=24) :: lisins
    end subroutine mdptem
end interface
