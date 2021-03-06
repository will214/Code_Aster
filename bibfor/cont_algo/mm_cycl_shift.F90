subroutine mm_cycl_shift(cycl_long_acti, cycl_ecod, cycl_long)
!
implicit none
!
#include "asterfort/iscode.h"
#include "asterfort/isdeco.h"
!
! ======================================================================
! COPYRIGHT (C) 1991 - 2015  EDF R&D                  WWW.CODE-ASTER.ORG
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
!   1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
! ======================================================================
! person_in_charge: mickael.abbas at edf.fr
!
    integer, intent(in) :: cycl_long_acti
    integer, intent(inout) :: cycl_ecod
    integer, intent(inout) :: cycl_long
!
! --------------------------------------------------------------------------------------------------
!
! Contact - Solve - Cycling
!
! Shift detection (index greater than cycling length)
!
! --------------------------------------------------------------------------------------------------
!
! In  cycl_long_acti   : length of cycling to detect
! IO  cycl_ecod        : coded integer for cycling
! IO  cycl_long        : cycling length
!
! --------------------------------------------------------------------------------------------------
!
    integer :: statut(30)
    integer :: cycl_index
    integer :: cycl_ecodi(1)
!
! --------------------------------------------------------------------------------------------------
!
    cycl_ecodi(1) = cycl_ecod
    call isdeco(cycl_ecodi(1), statut, 30)
    do cycl_index = 1, cycl_long_acti-1
        statut(cycl_index) = statut(cycl_index+1)
    end do
    call iscode(statut, cycl_ecodi(1), 30)
    cycl_long = cycl_long_acti - 1
    cycl_ecod = cycl_ecodi(1)

end subroutine
