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
! aslint: disable=W1504
#include "asterf_types.h"
!
interface
    subroutine mmalgo(ds_contact, l_loop_cont   , l_frot_zone   ,  &
                  l_glis_init   , type_adap   , zone_index    , i_cont_poin , &
                   indi_cont_eval, indi_frot_eval, dist_cont_curr, &
                   pres_cont_curr, dist_frot_curr, pres_frot_curr, &
                  v_sdcont_cychis, v_sdcont_cyccoe, v_sdcont_cyceta, indi_cont_curr,&
                  indi_frot_curr, ctcsta        , mmcvca               )
        use NonLin_Datastructure_type
        type(NL_DS_Contact), intent(in) :: ds_contact
        aster_logical, intent(in) :: l_loop_cont
        aster_logical, intent(in) :: l_frot_zone
        aster_logical, intent(in) :: l_glis_init
        integer, intent(in) :: type_adap
        integer, intent(in) :: i_cont_poin
        integer, intent(in) :: zone_index
        integer, intent(inout) :: indi_cont_eval
        integer, intent(inout) :: indi_frot_eval
        real(kind=8), intent(inout) :: dist_cont_curr
        real(kind=8), intent(inout) :: pres_cont_curr
        real(kind=8), intent(inout) :: dist_frot_curr(3)
        real(kind=8), intent(in) :: pres_frot_curr(3)
        real(kind=8), pointer, intent(in) :: v_sdcont_cychis(:)
        real(kind=8), pointer, intent(in) :: v_sdcont_cyccoe(:)
        integer, pointer, intent(in) :: v_sdcont_cyceta(:)
        integer, intent(out) :: indi_cont_curr
        integer, intent(out) :: indi_frot_curr
        integer, intent(out) :: ctcsta
        aster_logical, intent(out) :: mmcvca
    end subroutine mmalgo
end interface
