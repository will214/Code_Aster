subroutine medom2(modele, mate, cara, kcha, ncha,&
                  ctyp, result, nuord, nbordr, base,&
                  npass, ligrel)
    implicit none
#include "asterc/getexm.h"
#include "asterc/indik8.h"
#include "asterfort/assert.h"
#include "asterfort/exlim1.h"
#include "asterfort/exlima.h"
#include "asterfort/gnomsd.h"
#include "asterfort/jedema.h"
#include "asterfort/jedetr.h"
#include "asterfort/jemarq.h"
#include "asterfort/jeveuo.h"
#include "asterfort/jeveut.h"
#include "asterfort/medom1.h"
#include "asterfort/utmamo.h"
#include "asterfort/wkvect.h"
    integer :: ncha, nuord
    character(len=1) :: base
    character(len=4) :: ctyp
    character(len=8) :: modele, cara, result
    character(len=24) :: mate
    character(len=19) :: kcha
! ----------------------------------------------------------------------
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
!     CHAPEAU DE LA ROUTINE MEDOM1
!     ON DETERMINE LE BON LIGREL DANS LE CAS OU ON PASSE POUR LA
!     PREMIERE FOIS
!
! ----------------------------------------------------------------------
!
! OUT    : MODELE : NOM DU MODELE
! OUT    : MATE   : CHAMP MATERIAU
! OUT    : CARA   : NOM DU CHAMP DE CARACTERISTIQUES
! IN     : KCHA   : NOM JEVEUX POUR STOCKER LES CHARGES
! OUT    : NCHA   : NOMBRE DE CHARGES
! OUT    : CTYP   : TYPE DE CHARGE
! IN     : RESULT : NOM DE LA SD RESULTAT
! IN     : NUORD  : NUMERO D'ORDRE
! IN     : BASE   : 'G' OU 'V' POUR LA CREATION DU LIGREL
! IN/OUT : NPASS  : NOMBRE DE PASSAGE DANS LA ROUTINE
! OUT    : LIGREL : NOM DU LIGREL
!
! ----------------------------------------------------------------------
!
#include "jeveux.h"
!
    integer :: nbmxba
    parameter (nbmxba=2)
!
    integer :: nbordr, npass, nbligr, i, kmod, nbmaal
    integer :: iligrs, imodls, ibases,  n1, n2, n3
!
    character(len=1) :: baslig
    character(len=24) :: ligrel, ligr1, noojb
    integer, pointer :: liste_mailles(:) => null()
!
! ----------------------------------------------------------------------
!
! PERSISTANCE PAR RAPPORT A OP0058
    save nbligr, iligrs, imodls, ibases
!
    call jemarq()
!
!     RECUPERATION DU MODELE, CARA, CHARGES A PARTIR DU RESULTAT ET DU
!     NUMERO ORDRE
    call medom1(modele, mate, cara, kcha, ncha,&
                ctyp, result, nuord)
!
!     RECUPERATION DU LIGREL DU MODELE
!
!     POUR LE PREMIER PASSAGE ON INITIALISE LES TABLEAUX SAUVES
    if (npass .eq. 0) then
        npass=npass+1
        nbligr=0
        call jedetr('&&MEDOM2.LIGRS    ')
        call jedetr('&&MEDOM2.MODELS   ')
        call jedetr('&&MEDOM2.BASES    ')
        call wkvect('&&MEDOM2.LIGRS    ', 'V V K24', nbordr*nbmxba, iligrs)
        call wkvect('&&MEDOM2.MODELS   ', 'V V K8', nbordr*nbmxba, imodls)
        call wkvect('&&MEDOM2.BASES    ', 'V V K8', nbordr*nbmxba, ibases)
        call jeveut('&&MEDOM2.LIGRS    ', 'L', iligrs)
        call jeveut('&&MEDOM2.MODELS   ', 'L', imodls)
        call jeveut('&&MEDOM2.BASES    ', 'L', ibases)
    endif
!
!     ON REGARDE SI LE MODELE A DEJA ETE RENCONTRE
    kmod=indik8(zk8(imodls-1),modele,1,nbligr+1)
    baslig=' '
    do 10,i = 1,nbligr
    if (zk8(imodls-1+i) .eq. modele) then
        kmod=1
        baslig=zk8(ibases-1+i)(1:1)
    endif
    10 end do
!
!     SI OUI, ON REGARDE SI LE LIGREL A ETE CREE SUR LA MEME BASE
!     QUE LA BASE DEMANDEE
    if ((kmod.gt.0) .and. (baslig.eq.base)) then
!
!     SI OUI ALORS ON LE REPREND
        ligrel=zk24(iligrs-1+nbligr)
!
!     SI NON ON CREE UN NOUVEAU LIGREL
    else
        n1 = getexm(' ','GROUP_MA')
        n2 = getexm(' ','MAILLE')
        n3 = getexm(' ','TOUT')
        if (n1+n2+n3 .ne. 0) then
            call exlima(' ', 0, base, modele, ligr1)
        else
            call utmamo(modele, nbmaal, '&&MEDOM2.LISTE_MAILLES')
            call jeveuo('&&MEDOM2.LISTE_MAILLES', 'L', vi=liste_mailles)
            noojb='12345678.LIGR000000.LIEL'
            call gnomsd(result, noojb, 14, 19)
            ligr1=noojb(1:19)
            ASSERT(ligr1.ne.' ')
            call exlim1(liste_mailles, nbmaal, modele, base, ligr1)
            call jedetr('&&MEDOM2.LISTE_MAILLES')
        endif
        nbligr=nbligr+1
        zk24(iligrs-1+nbligr)=ligr1
        zk8( imodls-1+nbligr)=modele
        zk8( ibases-1+nbligr)=base
        ligrel=ligr1
    endif
!
    call jedema()
end subroutine
