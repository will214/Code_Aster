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
#include "asterf_types.h"
!
interface
    subroutine gapint(pair_tole     , elem_dime       ,&
                      elem_slav_code, elem_slav_nbnode, elem_slav_coor,&
                      elem_mast_code, elem_mast_nbnode, elem_mast_coor,&
                      nb_poin_inte  , poin_inte       ,&
                      gap_moy       , inte_weight     )
        real(kind=8), intent(in) :: pair_tole
        integer, intent(in) :: elem_dime
        character(len=8), intent(in) :: elem_slav_code
        integer, intent(in) :: elem_slav_nbnode
        real(kind=8), intent(in) :: elem_slav_coor(3,elem_slav_nbnode)
        character(len=8), intent(in) :: elem_mast_code
        integer, intent(in) :: elem_mast_nbnode
        real(kind=8), intent(in) :: elem_mast_coor(3,elem_mast_nbnode)
        integer, intent(in) :: nb_poin_inte
        real(kind=8), intent(in) :: poin_inte(elem_dime-1,nb_poin_inte)
        real(kind=8), intent(out) :: gap_moy
        real(kind=8), intent(out) :: inte_weight
    end subroutine gapint
end interface
