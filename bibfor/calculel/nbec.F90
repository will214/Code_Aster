function nbec(gd)
    implicit none
    integer :: nbec
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
! person_in_charge: jacques.pellet at edf.fr
!
!     ALTERATION SANS CHANGEMENT POUR TEST PROC MAJCODE!!  (3)
!     RETOURNE LE NOMBRE D ENTIERS CODES POUR UN GRANDEUR DU TYPE :
!     _SIMPLE
!     _ELEMENTAIRE
!
#include "jeveux.h"
#include "asterfort/jedema.h"
#include "asterfort/jemarq.h"
#include "asterfort/jenuno.h"
#include "asterfort/jeveuo.h"
#include "asterfort/jexnum.h"
#include "asterfort/utmess.h"
!
    integer :: gd, code
    character(len=8) :: nomgd, nomgd1, nomgd2
!     INCLUDE($FUNJEV)
!
!     FONCTIONS JEVEUX
!
!
!
    integer :: vali(3)
    character(len=32) :: valk(3)
!
!     EXCLUDE($FUNJEV)
!-----------------------------------------------------------------------
    integer :: iddgd, iddgd1, igd1, igd2
!-----------------------------------------------------------------------
    call jemarq()
    call jeveuo(jexnum('&CATA.GD.DESCRIGD', gd), 'L', iddgd)
    code = zi(iddgd)
    if ((code.eq.1) .or. (code.eq.2)) then
        nbec = zi(iddgd+2)
        goto 10
    else if (code.eq.3) then
        igd1 = zi(iddgd+3)
        if (igd1 .gt. 0) then
            call jeveuo(jexnum('&CATA.GD.DESCRIGD', igd1), 'L', iddgd1)
            nbec = zi(iddgd1+2)
            goto 10
        else
            call jenuno(jexnum('&CATA.GD.DESCRIGD', gd), nomgd)
            valk (1) = 'GRANDEUR LIGNE REFERENCEE PAR'
            valk (2) = nomgd//' NULLE'
            vali (1) = gd
            call utmess('F', 'CALCULEL6_22', nk=2, valk=valk, si=vali(1))
        endif
    else if ((code.eq.4) .or. (code.eq.5)) then
        igd1 = zi(iddgd+3)
        if (igd1 .eq. 0) then
            call jenuno(jexnum('&CATA.GD.DESCRIGD', gd), nomgd)
            valk (1) = 'GRANDEUR LIGNE REFERENCEE PAR'
            valk (2) = nomgd//' NULLE'
            vali (1) = gd
            call utmess('F', 'CALCULEL6_22', nk=2, valk=valk, si=vali(1))
        endif
        igd2 = zi(iddgd+4)
        if (igd2 .eq. 0) then
            call jenuno(jexnum('&CATA.GD.DESCRIGD', gd), nomgd)
            valk (1) = 'GRANDEUR COLONNE REFERENCEE PAR'
            valk (2) = nomgd//' NULLE'
            vali (1) = gd
            call utmess('F', 'CALCULEL6_22', nk=2, valk=valk, si=vali(1))
        endif
        if (igd1 .ne. igd2) then
            call jenuno(jexnum('&CATA.GD.DESCRIGD', gd), nomgd)
            call jenuno(jexnum('&CATA.GD.DESCRIGD', igd1), nomgd1)
            call jenuno(jexnum('&CATA.GD.DESCRIGD', igd2), nomgd2)
            vali (1) = igd1
            vali (2) = igd2
            vali (3) = gd
            valk (1) = nomgd1//' /= '
            valk (2) = nomgd2
            valk (3) = nomgd
            call utmess('F', 'CALCULEL6_25', nk=3, valk=valk, ni=3,&
                        vali=vali)
        endif
        call jeveuo(jexnum('&CATA.GD.DESCRIGD', igd1), 'L', iddgd1)
        nbec = zi(iddgd1+2)
        goto 10
    else
        vali (1) = gd
        vali (2) = code
        call utmess('F', 'CALCULEL6_26', ni=2, vali=vali)
    endif
10  continue
    call jedema()
end function
