subroutine nmcrdd(meshz          , modelz   , ds_inout , cara_elemz, matez    ,&
                  ds_constitutive, disp_curr, strx_curr, varc_curr , varc_refe,&
                  time           , sd_suiv)
!
use NonLin_Datastructure_type
!
implicit none
!
#include "asterc/getfac.h"
#include "asterfort/assert.h"
#include "asterfort/nmcrdn.h"
#include "asterfort/nmextr.h"
!
! ======================================================================
! COPYRIGHT (C) 1991 - 2016  EDF R&D                  WWW.CODE-ASTER.ORG
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
    character(len=*), intent(in) :: meshz
    character(len=*), intent(in) :: modelz
    type(NL_DS_InOut), intent(in) :: ds_inout
    character(len=*), intent(in) :: cara_elemz
    character(len=*), intent(in) :: matez
    type(NL_DS_Constitutive), intent(in) :: ds_constitutive
    character(len=*), intent(in) :: disp_curr
    character(len=*), intent(in) :: strx_curr
    character(len=*), intent(in) :: varc_curr
    character(len=*), intent(in) :: varc_refe
    real(kind=8),  intent(in) :: time
    character(len=24), intent(out) :: sd_suiv
!
! --------------------------------------------------------------------------------------------------
!
! MECA_NON_LINE - Init
!
! Create dof monitor datastructure
!
! --------------------------------------------------------------------------------------------------
!
! In  mesh             : name of mesh
! In  model            : name of model
! In  result           : name of results datastructure
! In  sddisc           : datastructure for discretization
! In  cara_elem        : name of datastructure for elementary parameters (CARTE)
! In  mate             : name of material characteristics (field)
! In  ds_constitutive  : datastructure for constitutive laws management
! In  disp_curr        : current displacements
! In  varc_curr        : command variable for current time
! In  varc_refe        : command variable for reference
! In  time             : current time
! In  strx_curr        : fibers information for current time
! In  ds_inout         : datastructure for input/output management
! Out sd_suiv          : datastructure for dof monitor parameters
!
! --------------------------------------------------------------------------------------------------
!
    integer :: nb_dof_monitor, nb_keyw_fact
    character(len=16) :: keyw_fact
    character(len=14) :: sdextr_suiv
!
! --------------------------------------------------------------------------------------------------
!
    nb_dof_monitor  = 0
    sd_suiv         = '&&NMCRDD.OBSV'
    keyw_fact       = 'SUIVI_DDL'
    call getfac(keyw_fact, nb_keyw_fact)
    ASSERT(nb_keyw_fact.le.99)
!
! - Read datas for extraction
!
    sdextr_suiv = sd_suiv(1:14)
    call nmextr(meshz       , modelz        , sdextr_suiv, ds_inout , keyw_fact,&
                nb_keyw_fact, nb_dof_monitor,&
                cara_elemz  , matez         , ds_constitutive, disp_curr, strx_curr,&
                varc_curr   , varc_refe     , time       )
!
! - Read name of columns
!
    if (nb_keyw_fact .ne. 0) then
        call nmcrdn(sd_suiv, keyw_fact, nb_dof_monitor, nb_keyw_fact)
    endif
!
end subroutine
