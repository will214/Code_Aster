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
    subroutine irgme2(numold, ima, connex, nbord2, tabd,&
                      tabl, tabv, partie, jtype, nbno,&
                      listno, nbcmp, ifi, iadmax)
        integer :: numold(*)
        integer :: ima
        character(len=24) :: connex
        integer :: nbord2
        integer :: tabd(*)
        integer :: tabl(*)
        integer :: tabv(*)
        character(len=*) :: partie
        integer :: jtype
        integer :: nbno
        integer :: listno(*)
        integer :: nbcmp
        integer :: ifi
        integer :: iadmax
    end subroutine irgme2
end interface
