!
! COPYRIGHT (C) 1991 - 2013  EDF R&D                WWW.CODE-ASTER.ORG
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
    subroutine nmxmat(modelz, mate, carele, compor, carcri,&
                      sddisc, sddyna, fonact, numins, iterat,&
                      valinc, solalg, lischa, comref, defico,&
                      resoco, solveu, numedd, numfix, sdstat,&
                      sdtime, nbmatr, ltypma, loptme, loptma,&
                      lcalme, lassme, lcfint, meelem, measse,&
                      veelem, ldccvg, codere)
        character(len=*) :: modelz
        character(len=*) :: mate
        character(len=24) :: carele
        character(len=24) :: compor
        character(len=24) :: carcri
        character(len=19) :: sddisc
        character(len=19) :: sddyna
        integer :: fonact(*)
        integer :: numins
        integer :: iterat
        character(len=19) :: valinc(*)
        character(len=19) :: solalg(*)
        character(len=19) :: lischa
        character(len=24) :: comref
        character(len=24) :: defico
        character(len=24) :: resoco
        character(len=19) :: solveu
        character(len=24) :: numedd
        character(len=24) :: numfix
        character(len=24) :: sdstat
        character(len=24) :: sdtime
        integer :: nbmatr
        character(len=6) :: ltypma(20)
        character(len=16) :: loptme(20)
        character(len=16) :: loptma(20)
        logical(kind=1) :: lcalme(20)
        logical(kind=1) :: lassme(20)
        logical(kind=1) :: lcfint
        character(len=19) :: meelem(*)
        character(len=19) :: measse(*)
        character(len=19) :: veelem(*)
        integer :: ldccvg
        character(len=24) :: codere
    end subroutine nmxmat
end interface
