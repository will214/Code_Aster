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
    subroutine lrmmma(fid, nomamd, nbmail, nbnoma, nbtyp,&
                      typgeo, nomtyp, nnotyp, renumd, nmatyp,&
                      nommai, connex, typmai, prefix, infmed,&
                      modnum, numnoa)
        integer :: fid
        character(len=*) :: nomamd
        integer :: nbmail
        integer :: nbnoma
        integer :: nbtyp
        integer :: typgeo(69)
        character(len=8) :: nomtyp(*)
        integer :: nnotyp(69)
        integer :: renumd(*)
        integer :: nmatyp(69)
        character(len=24) :: nommai
        character(len=24) :: connex
        character(len=24) :: typmai
        character(len=6) :: prefix
        integer :: infmed
        integer :: modnum(69)
        integer :: numnoa(69, *)
    end subroutine lrmmma
end interface
