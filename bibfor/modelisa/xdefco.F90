subroutine xdefco(mesh        , model, crack, algo_lagr, nb_dim,&
                  sdline_crack, tabai)
!
implicit none
!
#include "asterf_types.h"
#include "asterfort/assert.h"
#include "asterfort/jeexin.h"
#include "asterfort/xlagsp.h"
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
!
    integer, intent(in) :: nb_dim
    character(len=8), intent(in) :: mesh
    character(len=8), intent(in) :: model
    character(len=8), intent(in)  :: crack
    integer, intent(in) :: algo_lagr
    character(len=14), intent(in) :: sdline_crack
    character(len=19) :: tabai
!
! --------------------------------------------------------------------------------------------------
!
! XFEM - Contact definition
!
! Lagrange multiplier space selection for contact
!
! --------------------------------------------------------------------------------------------------
!
! In  model          : name of model
! In  mesh           : name of mesh
! In  crack          : name of crack 
! In  algo_lagr      : type of Lagrange multiplier space selection
! In  nb_dim         : dimension of space
! In  sdline_crack   : name of datastructure of linear relations for crack
! In/Out tabai       : (table) The 5th cmp of TOPOFAC.AI 
!
! --------------------------------------------------------------------------------------------------
!
    aster_logical :: l_xfem, l_pilo, l_ainter
    integer :: ier
!
! --------------------------------------------------------------------------------------------------
!
    l_xfem = .false.
    l_pilo = .false.
    l_ainter = .true.
    call jeexin(crack//'.MAILFISS.HEAV', ier)
    if (ier .ne. 0) l_xfem=.true.
    call jeexin(crack//'.MAILFISS.CTIP', ier)
    if (ier .ne. 0) l_xfem=.true.
    call jeexin(crack//'.MAILFISS.HECT', ier)
    if (ier .ne. 0) l_xfem=.true.
    ASSERT(l_xfem)
!
    call xlagsp(mesh        , model, crack, algo_lagr, nb_dim,&
                sdline_crack, l_pilo, tabai, l_ainter)

end subroutine
