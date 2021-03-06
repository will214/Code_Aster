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
    subroutine nmobsz(sd_obsv  , tabl_name    , title         , field_type   , field_disc,&
                      type_extr, type_extr_cmp, type_extr_elem, type_sele_cmp, cmp_name  ,&
                      time     , valr,&
                      node_namez,&
                      elem_namez, poin_numez, spoi_numez)
        character(len=19), intent(in) :: sd_obsv
        character(len=19), intent(in) :: tabl_name
        character(len=4), intent(in) :: field_disc
        character(len=24), intent(in) :: field_type
        character(len=16), intent(in) :: title
        character(len=8), intent(in) :: type_extr
        character(len=8), intent(in) :: type_extr_cmp
        character(len=8), intent(in) :: type_extr_elem
        character(len=8), intent(in) :: type_sele_cmp
        character(len=16), intent(in) :: cmp_name
        real(kind=8), intent(in) :: time
        real(kind=8), intent(in) :: valr
        character(len=8), optional, intent(in) :: node_namez
        character(len=8), optional, intent(in) :: elem_namez
        integer, optional, intent(in) :: poin_numez
        integer, optional, intent(in) :: spoi_numez
    end subroutine nmobsz
end interface
