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
! aslint: disable=W1504
!
interface
    subroutine nmflam(option, modele, numedd, numfix     , carele,&
                      ds_constitutive, numins, mate       , comref,&
                      lischa, ds_contact, ds_algopara, fonact,&
                      ds_measure, sddisc, sddyna,&
                      sdpost, valinc, solalg, meelem     , measse,&
                      veelem, sderro)
        use NonLin_Datastructure_type
        character(len=16) :: option
        character(len=24) :: modele
        character(len=24) :: numedd
        character(len=24) :: numfix
        character(len=24) :: carele
        integer :: numins
        character(len=24) :: mate
        character(len=24) :: comref
        character(len=19) :: lischa
        type(NL_DS_Contact), intent(in) :: ds_contact
        type(NL_DS_AlgoPara), intent(in) :: ds_algopara
        integer :: fonact(*)
        type(NL_DS_Constitutive), intent(in) :: ds_constitutive
        type(NL_DS_Measure), intent(inout) :: ds_measure
        character(len=19) :: sddisc
        character(len=19) :: sddyna
        character(len=19) :: sdpost
        character(len=19) :: valinc(*)
        character(len=19) :: solalg(*)
        character(len=19) :: meelem(*)
        character(len=19) :: measse(*)
        character(len=19) :: veelem(*)
        character(len=24) :: sderro
    end subroutine nmflam
end interface
