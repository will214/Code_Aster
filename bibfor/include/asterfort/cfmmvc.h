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
    subroutine cfmmvc(ds_contact   , v_ncomp_jeux, v_ncomp_loca, v_ncomp_enti, v_ncomp_zone,&
                      nt_ncomp_poin)
        use NonLin_Datastructure_type
        type(NL_DS_Contact), intent(in) :: ds_contact
        real(kind=8), pointer, intent(out) :: v_ncomp_jeux(:)
        integer, pointer, intent(out) :: v_ncomp_loca(:)
        character(len=16), pointer, intent(out) :: v_ncomp_enti(:)
        integer, pointer, intent(out) :: v_ncomp_zone(:)
        integer, intent(out) :: nt_ncomp_poin
    end subroutine cfmmvc
end interface
