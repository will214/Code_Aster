subroutine irmano(noma, nbma, numai, nbnos, numnos)
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
    implicit none
!
#include "jeveux.h"
#include "asterfort/dismoi.h"
#include "asterfort/jedema.h"
#include "asterfort/jedetr.h"
#include "asterfort/jemarq.h"
#include "asterfort/jeveuo.h"
#include "asterfort/jexatr.h"
#include "asterfort/wkvect.h"
#include "asterfort/as_deallocate.h"
#include "asterfort/as_allocate.h"
!
    character(len=*) :: noma
    integer :: nbma, numai(*), nbnos, numnos(*)
! ----------------------------------------------------------------------
!     BUT :   TROUVER LA LISTE DES NUMEROS DE NOEUDS SOMMETS D'UNE LISTE
!             DE MAILLES
!     ENTREES:
!        NOMA   : NOM DU MAILLAGE
!        NBMA   : NOMBRE DE MAILLES DE LA LISTE
!        NUMAI  : NUMEROS DES MAILLES DE LA LISTE
!     SORTIES:
!        NBNOS  : NOMBRE DE NOEUDS SOMMETS
!        NUMNOS : NUMEROS DES NOEUDS SOMMETS (UN NOEUD APPARAIT UNE
!                               SEULE FOIS )
! ----------------------------------------------------------------------
!     ------------------------------------------------------------------
    integer :: nnoe
    character(len=8) :: nomma
!
!
!-----------------------------------------------------------------------
    integer :: ima, imai, ino, inoe, ipoin
    integer ::  jpoin, nbnoe, num
    integer, pointer :: vnumnos(:) => null()
    integer, pointer :: connex(:) => null()
!-----------------------------------------------------------------------
    call jemarq()
    nomma=noma
    nbnos= 0
!  --- RECHERCHE DU NOMBRE DE NOEUDS DU MAILLAGE ---
!-DEL CALL JELIRA(NOMMA//'.NOMNOE','NOMMAX',NBNOE,' ')
    call dismoi('NB_NO_MAILLA', nomma, 'MAILLAGE', repi=nbnoe)
    AS_ALLOCATE(vi=vnumnos, size=nbnoe)
!     --- INITIALISATION DU TABLEAU DE TRAVAIL &&IRMANO.NUMNOS ----
    do ino = 1, nbnoe
        vnumnos(ino) = 0
    end do
!     --- RECHERCHE DES NOEUDS SOMMETS ----
    call jeveuo(nomma//'.CONNEX', 'L', vi=connex)
    call jeveuo(jexatr(nomma//'.CONNEX', 'LONCUM'), 'L', jpoin)
    do ima = 1, nbma
        imai=numai(ima)
        ipoin= zi(jpoin-1+imai)
        nnoe = zi(jpoin-1+imai+1)-ipoin
        do inoe = 1, nnoe
            num=connex(ipoin-1+inoe)
            vnumnos(num) =1
        end do
    end do
!  --- STOCKAGE DES NOEUDS PRESENTS SUR LA LISTE DES MAILLES---
    do inoe = 1, nbnoe
        if (vnumnos(inoe) .eq. 1) then
            nbnos=nbnos+1
            numnos(nbnos)=inoe
        endif
    end do
!
    AS_DEALLOCATE(vi=vnumnos)
    call jedema()
end subroutine
