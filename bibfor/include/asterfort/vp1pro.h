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
    subroutine vp1pro(optiom, lraide, lmasse, ldynam, neq,&
                      nfreq, nfreqb, tolv, nitv, iexcl,&
                      fcorig, vec, resufi, resufr, resufk,&
                      nbrssa, nbpari, nbparr, nbpark, typres,&
                      optiof, solveu)
        integer :: nbpark
        integer :: nbparr
        integer :: nbpari
        integer :: nfreqb
        integer :: neq
        character(len=*) :: optiom
        integer :: lraide
        integer :: lmasse
        integer :: ldynam
        integer :: nfreq
        real(kind=8) :: tolv
        integer :: nitv
        integer :: iexcl(*)
        real(kind=8) :: fcorig
        real(kind=8) :: vec(neq, *)
        integer :: resufi(nfreqb, nbpari)
        real(kind=8) :: resufr(nfreqb, nbparr)
        character(len=*) :: resufk(nfreqb, nbpark)
        integer :: nbrssa
        character(len=16) :: typres
        character(len=16) :: optiof
        character(len=19) :: solveu
    end subroutine vp1pro
end interface
