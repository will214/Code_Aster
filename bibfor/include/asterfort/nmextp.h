!
! COPYRIGHT (C) 1991 - 2017  EDF R&D                WWW.CODE-ASTER.ORG
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
    subroutine nmextp(keyw_fact, i_keyw_fact, field_type, field_disc, field  ,&
                  field_s  , list_poin  , list_spoi , nb_poin   , nb_spoi,&
                  type_extr_elem)
        character(len=16), intent(in) :: keyw_fact
        integer, intent(in) :: i_keyw_fact
        character(len=19), intent(in) :: field
        character(len=24), intent(in) :: field_type
        character(len=4) , intent(in) :: field_disc
        character(len=24), intent(in) :: field_s
        character(len=8), intent(out) :: type_extr_elem
        character(len=24), intent(in) :: list_poin
        character(len=24), intent(in) :: list_spoi
        integer, intent(out) :: nb_poin
        integer, intent(out) :: nb_spoi
    end subroutine nmextp
end interface
