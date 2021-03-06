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
    subroutine nmext3(mesh          , field    , field_type   , field_s      ,&
                      nb_cmp        , nb_elem  , nb_poin      , nb_spoi      ,&
                      type_extr_elem, type_extr, type_extr_cmp, type_sele_cmp,&
                      list_elem     , list_poin, list_spoi    , list_cmp     ,&
                      work_poin     , work_elem)
        character(len=8), intent(in) :: mesh
        character(len=19), intent(in) :: field
        character(len=24), intent(in) :: field_type
        character(len=24), intent(in) :: field_s
        integer, intent(in) :: nb_cmp
        integer, intent(in) :: nb_elem
        integer, intent(in) :: nb_poin
        integer, intent(in) :: nb_spoi
        character(len=8), intent(in) :: type_extr_elem
        character(len=8), intent(in) :: type_extr
        character(len=8), intent(in) :: type_extr_cmp
        character(len=8), intent(in) :: type_sele_cmp
        character(len=24), intent(in) :: list_elem
        character(len=24), intent(in) :: list_poin
        character(len=24), intent(in) :: list_spoi
        character(len=24), intent(in) :: list_cmp
        character(len=19), intent(in) :: work_poin
        character(len=19), intent(in) :: work_elem
    end subroutine nmext3
end interface
