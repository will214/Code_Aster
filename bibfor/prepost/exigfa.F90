function exigfa(dgf, ngf)
    implicit none
#include "asterf_types.h"
    aster_logical :: exigfa
    integer :: dgf(*), ngf
!     ------------------------------------------------------------------
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
!     INDIQUE L'EXISTENCE DU NUM GROUPE NGF DANS DESCRIPTEUR-GROUPE DGF
!     DGF    = DESCRIPTEUR-GROUPE DE LA FAMILLE (VECTEUR ENTIERS)
!     NGF    = NUMERO DU GROUPE
!     ------------------------------------------------------------------
    integer :: iand
    integer :: iec, reste, code
!
!-----------------------------------------------------------------------
!-----------------------------------------------------------------------
    iec = ( ngf - 1 ) / 30
    reste = ngf - 30 * iec
    code = 2**reste
    iec = iec + 1
    exigfa = iand ( dgf(iec),code ) .eq. code
end function
