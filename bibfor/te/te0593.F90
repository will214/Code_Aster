subroutine te0593(option, nomte)
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
! person_in_charge: sebastien.fayolle at edf.fr
    implicit none
#include "jeveux.h"
#include "asterfort/assert.h"
#include "asterfort/elref2.h"
#include "asterfort/elrefe_info.h"
#include "asterfort/jevech.h"
#include "asterfort/lteatt.h"
#include "asterfort/niinit.h"
#include "asterfort/nirfgd.h"
#include "asterfort/nirfpd.h"
#include "asterfort/terefe.h"
#include "asterfort/utmess.h"
!
    character(len=16) :: option, nomte
! ----------------------------------------------------------------------
! FONCTION REALISEE:  CALCUL DE L'OPTION FORC_REFE POUR LES ELEMENTS
!                     INCOMPRESSIBLES A 3 CHAMPS UGP
!                     EN 3D/D_PLAN/AXI
!
!    - ARGUMENTS:
!        DONNEES:      OPTION       -->  OPTION DE CALCUL
!                      NOMTE        -->  NOM DU TYPE ELEMENT
! ----------------------------------------------------------------------
!
    integer :: ndim, nno1, nno2, nno3, nnos, npg, jgn, ntrou
    integer :: iw, ivf1, ivf2, ivf3, idf1, idf2, idf3
    integer :: vu(3, 27), vg(27), vp(27), vpi(3, 27)
    integer :: igeom, ivectu, icompo
    real(kind=8) :: sigref, epsref
    character(len=8) :: lielrf(10), typmod(2)
! ----------------------------------------------------------------------
!
!
! - FONCTIONS DE FORMES ET POINTS DE GAUSS
    call elref2(nomte, 10, lielrf, ntrou)
    ASSERT(ntrou.ge.3)
    call elrefe_info(elrefe=lielrf(3),fami='RIGI',ndim=ndim,nno=nno3,nnos=nnos,npg=npg,&
                    jpoids=iw,jvf=ivf3,jdfde=idf3,jgano=jgn)
    call elrefe_info(elrefe=lielrf(2),fami='RIGI',ndim=ndim,nno=nno2,nnos=nnos,npg=npg,&
                    jpoids=iw,jvf=ivf2,jdfde=idf2,jgano=jgn)
    call elrefe_info(elrefe=lielrf(1),fami='RIGI',ndim=ndim,nno=nno1,nnos=nnos,npg=npg,&
                    jpoids=iw,jvf=ivf1,jdfde=idf1,jgano=jgn)
!
! - TYPE DE MODELISATION
    if (ndim .eq. 2 .and. lteatt('AXIS','OUI')) then
        typmod(1) = 'AXIS  '
    else if (ndim.eq.2 .and. lteatt('D_PLAN','OUI')) then
        typmod(1) = 'D_PLAN  '
    else if (ndim .eq. 3) then
        typmod(1) = '3D'
    else
        call utmess('F', 'ELEMENTS_34', sk=nomte)
    endif
!
! - ACCES AUX COMPOSANTES DU VECTEUR DDL
    call niinit(nomte, typmod, ndim, nno1, nno2, nno3, 0, vu, vg, vp, vpi)
!
    call jevech('PGEOMER', 'L', igeom)
    call jevech('PVECTUR', 'E', ivectu)
    call jevech('PCOMPOR', 'L', icompo)
    call terefe('SIGM_REFE', 'MECA_INCO', sigref)
    call terefe('EPSI_REFE', 'MECA_INCO', epsref)
!
! - CALCUL DE REFE_FORC_NODA
    if (zk16(icompo+2) (1:6) .eq. 'PETIT ') then
!
        call nirfpd(ndim, nno1, nno2, nno3, npg,&
                    iw, zr(ivf1), zr(ivf2), zr(ivf3), idf1,&
                    vu, vg, vp, typmod, zr(igeom),&
                    sigref, epsref, zr( ivectu))
    else if (zk16(icompo+2) (1:8).eq.'GDEF_LOG') then
!
        call nirfgd(ndim, nno1, nno2, nno3, npg,&
                    iw, zr(ivf1), zr(ivf2), zr(ivf3), idf1,&
                    vu, vg, vp, typmod, zr(igeom),&
                    sigref, epsref, zr( ivectu))
    else if (zk16(icompo+2) (1:10).eq.'SIMO_MIEHE') then
!
        call nirfgd(ndim, nno1, nno2, nno3, npg,&
                    iw, zr(ivf1), zr(ivf2), zr(ivf3), idf1,&
                    vu, vg, vp, typmod, zr(igeom),&
                    sigref, epsref, zr( ivectu))
    else
        call utmess('F', 'ELEMENTS3_16', sk=zk16(icompo+2))
    endif
!
end subroutine
