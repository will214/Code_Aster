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
    subroutine nmnewt(mesh       , model    , numins    , numedd         , numfix   ,&
                      mate       , cara_elem, comref    , ds_constitutive, list_load,&
                      ds_algopara, fonact   , ds_measure, sderro         , ds_print ,&
                      sdnume     , sddyna   , sddisc    , sdcrit         , sdsuiv   ,&
                      sdpilo     , ds_conv  , solveu    , maprec         , matass   ,&
                      ds_inout   , valinc   , solalg    , meelem         , measse   ,&
                      veelem     , veasse   , ds_contact, ds_algorom     , eta      ,&
                      nbiter  )
        use NonLin_Datastructure_type
        use Rom_Datastructure_type
        character(len=8), intent(in) :: mesh
        character(len=24), intent(in) :: model
        integer :: numins
        character(len=24) :: numedd
        character(len=24) :: numfix
        character(len=24), intent(in) :: mate
        character(len=24), intent(in) :: cara_elem
        character(len=24) :: comref
        type(NL_DS_Constitutive), intent(inout) :: ds_constitutive
        character(len=19), intent(in) :: list_load
        type(NL_DS_AlgoPara), intent(in) :: ds_algopara
        integer :: fonact(*)
        type(NL_DS_Measure), intent(inout) :: ds_measure
        character(len=24) :: sderro
        type(NL_DS_Print), intent(inout) :: ds_print
        character(len=19) :: sdnume
        character(len=19) :: sddyna
        character(len=19) :: sddisc
        character(len=19) :: sdcrit
        character(len=24) :: sdsuiv
        character(len=19) :: sdpilo
        type(NL_DS_Conv), intent(inout) :: ds_conv
        character(len=19) :: solveu
        character(len=19) :: maprec
        character(len=19) :: matass
        type(NL_DS_InOut), intent(in) :: ds_inout
        character(len=19) :: valinc(*)
        character(len=19) :: solalg(*)
        character(len=19) :: meelem(*)
        character(len=19) :: measse(*)
        character(len=19) :: veelem(*)
        character(len=19) :: veasse(*)
        type(NL_DS_Contact), intent(inout) :: ds_contact
        type(ROM_DS_AlgoPara), intent(inout) :: ds_algorom
        real(kind=8) :: eta
        integer :: nbiter
    end subroutine nmnewt
end interface
