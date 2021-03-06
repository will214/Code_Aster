subroutine xpocmp(elrefp, cns1, ima, n, jconx1,&
                  jconx2, ndim, nfh, nfe, ddlc,&
                  nbcmp, cmp, lmeca, pre1)
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
! person_in_charge: samuel.geniaut at edf.fr
!
! aslint: disable=W1306
    implicit none
!
#include "asterf_types.h"
#include "jeveux.h"
#include "asterfort/assert.h"
#include "asterfort/elelin.h"
#include "asterfort/jedema.h"
#include "asterfort/jemarq.h"
#include "asterfort/jeveuo.h"
    integer :: ndim, nfh, nfe, ima, n, jconx1, jconx2, nbcmp, cmp(*)
    integer :: ddlc
    aster_logical :: lmeca, pre1, press, press1, pref, lagf
    character(len=8) :: elrefp
    character(len=19) :: cns1
!
!   DETERMINER LES COMPOSANTES ACTIVES DU CHAMP DE DEPLACEMENT
!
!   IN
!     CNS1   : CHAMP_NO_S DU DEPLACEMENT EN ENTREE
!     IMA    : NUMERO DE MAILLE COURANTE PARENT
!     N      : NOMBRE DE NOEUDS DE L'ELEMENT PARENT
!     JCONX1 : ADRESSE DE LA CONNECTIVITE DU MAILLAGE SAIN
!     JCONX2 : LONGUEUR CUMULEE DE LA CONNECTIVITE DU MAILLAGE SAIN
!     NDIM   : DIMENSION DU MAILLAGE
!     NBCMP  : NOMBRE DE COMPOSANTES DU CHAMP_NO DE DEPL1
!     LMECA  : VRAI DANS LE CAS MECANIQUE (SINON CAS THERMIQUE)
!
!   OUT
!     NFH    : NOMBRE DE FONCTIONS HEAVISIDE (PAR NOEUD)
!     NFE    : NOMBRE DE FONCTIONS SINGULIÈRES D'ENRICHISSEMENT (1 A 4)
!     CMP    : POSITION DES DDLS DE DEPL X-FEM DANS LE CHAMP_NO DE DEPL1
!
!
    integer :: jcnsl1, i, j, k, ino, icmp, ndc, ipos, nnos, ibid
    aster_logical :: exist(n, nbcmp), contas
    character(len=8) :: nomcmp, k8bid
    character(len=8), pointer :: cnsc(:) => null()
!
!     ------------------------------------------------------------------
!
    call jemarq()
!
!     COMPOSANTES DU CHAMP DE DEPLACEMENT 1
    call jeveuo(cns1//'.CNSC', 'L', vk8=cnsc)
    call jeveuo(cns1//'.CNSL', 'L', jcnsl1)
!
    do 110 j = 1, n
!       INO : NUMÉRO DU NOEUD DANS MALINI
        ino=zi(jconx1-1+zi(jconx2+ima-1)+j-1)
        do 111 icmp = 1, nbcmp
            exist(j,icmp)= zl(jcnsl1-1+(ino-1)*nbcmp + icmp)
111     continue
110 continue
!
!     ON REGARDE LES COMPOSANTES ACTIVES EN CHAQUE NOEUD
    ipos = 0
    ndc = 0
    nfh = 0
    nfe = 0
    ddlc=0
    contas=.true.
    press=.true.
    press1 = .true.
    pref=.true.
    lagf=.true.
    call elelin(1, elrefp, k8bid, ibid, nnos)
!
    do 21 i = 1, nbcmp
        nomcmp = cnsc(i)
!
        if (nomcmp(1:4) .eq. 'LAGS' .or. nomcmp(1:4) .eq. 'LAG2' .or.&
            nomcmp(1:4) .eq. 'LAG3' .or. nomcmp(1:4) .eq. 'LAG4' .or.&
            nomcmp(1:2) .eq. 'D1' .or. nomcmp(1:2) .eq. 'V1' .or.&
            nomcmp(1:2) .eq. 'D2' .or. nomcmp(1:2) .eq. 'V2' .or.&
            nomcmp(1:2) .eq. 'D3' .or. nomcmp(1:2) .eq. 'V3') then
            do 22 k = 1, nnos
                if (.not. exist(k,i)) contas=.false.
 22         continue
            if (contas) goto 1
        endif
!
        if (nomcmp(1:4) .eq. 'PRE1') then
            do 23 k = 1, nnos
                if (.not. exist(k,i)) press=.false.
 23         continue
            if (press) goto 1
        endif
!
        if (nomcmp(1:6).eq.'H1PRE1' .or. nomcmp(1:6).eq.'H2PRE1' .or.&
            nomcmp(1:6).eq.'H3PRE1') then
           do 24 k = 1, nnos
              if (.not.exist(k,i)) press1 = .false.
 24        continue
             if (press1) goto 1
        endif
!
        if (nomcmp(1:7).eq.'PRE_FLU' .or. nomcmp(1:7).eq.'PR2_FLU' .or.&
            nomcmp(1:7).eq.'PR3_FLU') then
           do 25 k = 1, nnos
              if (.not.exist(k,i)) pref = .false.
 25        continue
             if (pref) goto 1
        endif
!
        if (nomcmp(1:6).eq.'LAG_FL' .or. nomcmp(1:6).eq.'LA2_FL' .or.&
            nomcmp(1:6).eq.'LA3_FL') then
           do 26 k = 1, nnos
              if (.not.exist(k,i)) lagf = .false.
 26        continue
             if (lagf) goto 1
        endif
        
        do 29 j = 1, n
            if (.not.exist(j,i)) goto 21
 29     continue
!
  1     continue
!
        if (nomcmp(1:2) .eq. 'DX' .or. nomcmp(1:2) .eq. 'DY' .or.&
            nomcmp(1:2) .eq. 'DZ' .or. nomcmp(1:1) .eq. 'T') then
            ipos = ipos +1
            ndc = ndc +1
            cmp(ipos)=i
        endif
        if (pre1) then
            if (nomcmp(1:4) .eq. 'PRE1') then
                ipos=ipos +1
                cmp(ipos)=i
            endif
        endif
        if (nomcmp(1:1) .eq. 'H'.and.nomcmp(3:3).ne.'P') then
            ipos = ipos +1
            nfh = nfh +1
            cmp(ipos)=i
        endif
        if (pre1) then
           if (nomcmp(1:6).eq.'H1PRE1' .or. nomcmp(1:6).eq.'H2PRE1' .or.&
               nomcmp(1:6).eq.'H3PRE1') then
             ipos = ipos + 1
             cmp(ipos) = i
           endif
        endif
        if (nomcmp(1:2) .eq. 'K1' .or. nomcmp(1:2) .eq. 'K2' .or.&
            nomcmp(1:2) .eq. 'K3') then
            ipos = ipos +1
            nfe = nfe +1
            cmp(ipos)=i
        endif
        if (nomcmp(1:2) .eq. 'E1') then
            ASSERT(.not.lmeca)
            nfe = nfe +1
            ipos = ipos +1
            cmp(ipos)=i
        endif
        if (.not.pre1) then 
           if (nomcmp(1:3) .eq. 'LAG') then
              ipos=ipos+1
              ddlc=ddlc+1
              cmp(ipos)=i
           endif
        endif
        if (pre1) then 
           if (nomcmp(1:7).eq.'PRE_FLU' .or. nomcmp(1:7).eq.'PR2_FLU'&
               .or. nomcmp(1:7).eq.'PR3_FLU') then 
             ipos=ipos+1
             ddlc=ddlc+1
             cmp(ipos)=i
           endif
           if (nomcmp(1:6).eq.'LAG_FL' .or. nomcmp(1:6).eq.'LA2_FL'&
               .or. nomcmp(1:6).eq.'LA3_FL') then 
             ipos=ipos+1
             ddlc=ddlc+1
             cmp(ipos)=i
           endif
           if (nomcmp(1:4).eq.'LAGS' .or. nomcmp(1:4).eq.'LAG2' .or.&
               nomcmp(1:4).eq.'LAG3') then
              ipos=ipos+1
              ddlc=ddlc+1
              cmp(ipos)=i
           endif
           if (nomcmp(1:2).eq.'D1' .or. nomcmp(1:2).eq.'D2' .or. nomcmp(1:2).eq.'D3') then
              ipos=ipos+1
              ddlc=ddlc+1
              cmp(ipos)=i
           endif
           if (nomcmp(1:2).eq.'V1' .or. nomcmp(1:2).eq.'V2' .or. nomcmp(1:2).eq.'V3') then
              ipos=ipos+1
              ddlc=ddlc+1
              cmp(ipos)=i
           endif
        endif    
!
 21 continue
!
    if (lmeca) then
!       CAS DE LA MECANIQUE
        nfe = nfe/ndim
        nfh = nfh/ndim
        ASSERT(ndim.eq.ndc)
    else
!       CAS DE LA THERMIQUE
        ASSERT(ndc.eq.1)
    endif
!
    call jedema()
end subroutine
