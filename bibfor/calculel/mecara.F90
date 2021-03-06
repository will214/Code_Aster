subroutine mecara(cara_elem, chcara)
!
    implicit none
#include "asterf_types.h"
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
!    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
! ======================================================================
!
    character(len=*), intent(in) :: cara_elem
    character(len=*), intent(inout) :: chcara(18)
!
! --------------------------------------------------------------------------------------------------
!
! Preparing <CARTE> field for elementary characteristics
!
! --------------------------------------------------------------------------------------------------
!
! In  cara_elem   : name of elementary characteristics (field)
! IO  chcara      : name of <CARTE> field for elementary characteristics
!
! --------------------------------------------------------------------------------------------------
!
    integer :: ii
!
! --------------------------------------------------------------------------------------------------
!
    do ii = 1, 18
        chcara(ii) = ' '
    end do
!
    if (cara_elem(1:8) .ne. ' ') then
        chcara(1) = cara_elem(1:8)//'.CARORIEN'
        chcara(2) = cara_elem(1:8)//'.CARDISCK'
        chcara(3) = cara_elem(1:8)//'.CARDISCM'
        chcara(4) = cara_elem(1:8)//'.CARDISCA'
        chcara(5) = cara_elem(1:8)//'.CARGEOPO'
        chcara(6) = cara_elem(1:8)//'.CARGENPO'
        chcara(7) = cara_elem(1:8)//'.CARCOQUE'
        chcara(8) = cara_elem(1:8)//'.CARSECTI'
        chcara(9) = cara_elem(1:8)//'.CARARCPO'
        chcara(10)= cara_elem(1:8)//'.CARCABLE'
        chcara(11)= cara_elem(1:8)//'.CARGENBA'
        chcara(12)= cara_elem(1:8)//'.CARMASSI'
        chcara(13)= cara_elem(1:8)//'.CARPOUFL'
        chcara(14)= cara_elem(1:8)//'.CVENTCXF'
        chcara(15)= cara_elem(1:8)//'.CARDINFO'
        chcara(16)= cara_elem(1:8)//'.CANBSP'
        chcara(17)= cara_elem(1:8)//'.CAFIBR'
    endif
!
end subroutine
