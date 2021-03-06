subroutine dismcr(questi, nomobz, repi, repkz, ierd)
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
    implicit none
    integer :: repi, ierd
    character(len=*) :: questi
    character(len=*) :: nomobz, repkz
!
! --------------------------------------------------------------------------------------------------
!     DISMOI(CARA_ELEM)
!
!     IN:
!       QUESTI : TEXTE PRECISANT LA QUESTION POSEE : NOM_MAILLA NOM_MODELE EXI_AMOR
!       NOMOBZ : NOM D'UN OBJET DE TYPE NUM_DDL
!     OUT:
!       REPI   : REPONSE ( SI ENTIERE )
!       REPKZ  : REPONSE ( SI CHAINE DE CARACTERES )
!       IERD   : CODE RETOUR (0--> OK, 1 --> PB)
!
! --------------------------------------------------------------------------------------------------
!
#include "jeveux.h"
#include "asterfort/dismca.h"
#include "asterfort/jeexin.h"
#include "asterfort/jeveuo.h"
#include "asterfort/zerobj.h"
!
! --------------------------------------------------------------------------------------------------
!
    character(len=32) :: repk
    character(len=8) :: nomob
    integer :: k, ncarte, iexi, jadr
    parameter (ncarte=12)
    character(len=11) :: cartes(ncarte)
    character(len=19) :: cart1
    data cartes/'.CARCOQUE',  '.CARGEOPO',  '.CARARCPO',&
                '.CARCABLE',  '.CARDISCA',  '.CARDISCK',&
                '.CARDISCM',  '.CARGENBA',  '.CARGENPO',&
                '.CARMASSI',  '.CARORIEN',  '.CARPOUFL' /
! --------------------------------------------------------------------------------------------------
!
    repk = ' '
    repi = 0
    ierd = 0
    nomob=nomobz
!
! --------------------------------------------------------------------------------------------------
    if (questi .eq. 'NOM_MAILLA') then
        do k=1,ncarte
            cart1=nomob//cartes(k)
            call dismca(questi, cart1, repi, repk, ierd)
            if (ierd .eq. 0) exit
        enddo
! --------------------------------------------------------------------------------------------------
    else if (questi .eq. 'NOM_MODELE') then
        call jeexin(nomob//'.MODELE', iexi)
        if (iexi .ne. 0) then
            call jeveuo(nomob//'.MODELE', 'L', jadr)
            repk = zk8(jadr)
        else
            ierd = 1
        endif
! --------------------------------------------------------------------------------------------------
    else if (questi.eq.'EXI_AMOR') then
        repk='NON'
        call jeexin(nomob//'.CARDISCA  .VALE', iexi)
        if (iexi .ne. 0) then
            if (.not.zerobj(nomob//'.CARDISCA  .VALE')) repk='OUI'
        endif
! --------------------------------------------------------------------------------------------------
    else
        ierd=1
    endif
!
    repkz=repk
end subroutine
