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
    subroutine nmresd(fonact, sddyna, ds_measure, solveu,&
                      numedd, instan, maprec    , matass    , cndonn,&
                      cnpilo, cncine, solalg    , rescvg, ds_algorom_)
        use NonLin_Datastructure_type
        use ROM_Datastructure_type        
        integer :: fonact(*)
        character(len=19) :: sddyna
        type(ROM_DS_AlgoPara), optional, intent(in) :: ds_algorom_
        type(NL_DS_Measure), intent(inout) :: ds_measure
        character(len=19) :: solveu
        character(len=24) :: numedd
        real(kind=8) :: instan
        character(len=19) :: maprec
        character(len=19) :: matass
        character(len=19) :: cndonn
        character(len=19) :: cnpilo
        character(len=19) :: cncine
        character(len=19) :: solalg(*)
        integer :: rescvg
    end subroutine nmresd
end interface
