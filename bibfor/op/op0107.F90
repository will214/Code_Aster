subroutine op0107()
    implicit none
!     ------------------------------------------------------------------
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
!    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
! ======================================================================
!     OPERATEUR   POST_ELEM
!     ------------------------------------------------------------------
!
#include "jeveux.h"
#include "asterc/getfac.h"
#include "asterc/getres.h"
#include "asterfort/chpve2.h"
#include "asterfort/getvid.h"
#include "asterfort/getvr8.h"
#include "asterfort/getvtx.h"
#include "asterfort/infmaj.h"
#include "asterfort/jedema.h"
#include "asterfort/jemarq.h"
#include "asterfort/jeveuo.h"
#include "asterfort/medomp.h"
#include "asterfort/peaire.h"
#include "asterfort/pecage.h"
#include "asterfort/pecapo.h"
#include "asterfort/pechli.h"
#include "asterfort/peecin.h"
#include "asterfort/peeint.h"
#include "asterfort/peepot.h"
#include "asterfort/peingl.h"
#include "asterfort/pemain.h"
#include "asterfort/pemima.h"
#include "asterfort/penorm.h"
#include "asterfort/peritr.h"
#include "asterfort/pevolu.h"
#include "asterfort/peweib.h"
#include "asterfort/pewext.h"
#include "asterfort/rsexch.h"
#include "asterfort/rsutnu.h"
#include "asterfort/titre.h"
#include "asterfort/utmess.h"
!
    integer :: nh, iret, jordr, n1, n2, nbocc, nbordr, nc, np, nr, ier
    real(kind=8) :: prec
    character(len=8) :: k8b, modele, carele, deform, resuco, crit
    character(len=16) :: concep, nomcmd
    character(len=19) :: resu, knum, tabtyp(3)
    character(len=24) :: mate, chdef
!
!     ------------------------------------------------------------------
!
    call jemarq()
!
    call getres(resu, concep, nomcmd)
    call getvid(' ', 'RESULTAT', scal=resuco, nbret=nr)
!
    if (nr .eq. 0) resuco = ' '
!
    call infmaj()
!
    call getfac('TRAV_EXT', nbocc)
    if (nbocc .ne. 0) then
        call pewext(resu)
    endif
!
    call getfac('CHAR_LIMITE', nbocc)
    if (nbocc .ne. 0) then
        call medomp(resuco, modele, mate)
        call pechli(resu, modele, mate)
    endif
!
    call getfac('AIRE_INTERNE', nbocc)
    if (nbocc .ne. 0) then
        call medomp(resuco, modele)
        call peaire(resu, modele, nbocc)
    endif
!
    call getfac('MASS_INER', nbocc)
    if (nbocc .ne. 0) then
        call medomp(resuco, modele, mate, carele, nh)
        chdef = ' '
        call getvtx(' ', 'GEOMETRIE', scal=deform, nbret=n1)
        if (deform .eq. 'DEFORMEE') then
            call getvid(' ', 'CHAM_GD', scal=chdef, nbret=n2)
            if (n2 .eq. 0) then
                tabtyp(1)='NOEU#DEPL_R'
                tabtyp(2)='NOEU#TEMP_R'
                tabtyp(3)='ELEM#ENER_R'
                knum = '&&OP0107.NUME_ORDRE'
                call getvid(' ', 'RESULTAT', scal=resuco, nbret=nr)
                call getvr8(' ', 'PRECISION', scal=prec, nbret=np)
                call getvtx(' ', 'CRITERE', scal=crit, nbret=nc)
                call rsutnu(resuco, ' ', 0, knum, nbordr,&
                            prec, crit, iret)
                if (nbordr .ne. 1) then
                    call utmess('F', 'POSTELEM_10')
                endif
                if (iret .ne. 0) goto 999
                call jeveuo(knum, 'L', jordr)
                call rsexch('F', resuco, 'DEPL', zi(jordr), chdef,&
                            iret)
                call chpve2(chdef, 3, tabtyp, ier)
            endif
        endif
        call pemain(resu, modele, mate, carele, nh,&
                    nbocc, chdef)
!
    endif
!
    call getfac('ENER_POT', nbocc)
    if (nbocc .ne. 0) then
        call medomp(resuco, modele, mate, carele, nh)
        call peepot(resu, modele, mate, carele, nh,&
                    nbocc)
!
    endif
!
    call getfac('ENER_CIN', nbocc)
    if (nbocc .ne. 0) then
        call medomp(resuco, modele, mate, carele, nh)
        call peecin(resu, modele, mate, carele, nh,&
                    nbocc)
!
    endif
!
    call getfac('INTEGRALE', nbocc)
    if (nbocc .ne. 0) then
        call medomp(resuco, modele)
        call peeint(resu, modele, nbocc)
    endif
!
    call getfac('NORME', nbocc)
    if (nbocc .ne. 0) then
!         --- ON RECUPERE LE MODELE
        call getvid('NORME', 'CHAM_GD', iocc=1, scal=chdef, nbret=n1)
        if (n1 .ne. 0) then
            call getvid('NORME', 'MODELE', iocc=1, scal=modele, nbret=n2)
        else
            call getvid('NORME', 'RESULTAT', iocc=1, scal=resuco, nbret=nr)
            call medomp(resuco, modele)
        endif
        call penorm(resu, modele)
    endif
!
    call getfac('VOLUMOGRAMME', nbocc)
    if (nbocc .ne. 0) then
        call medomp(resuco, modele, carele=carele)
        call pevolu(resu, modele, carele, nbocc)
    endif
!
    call getfac('MINMAX', nbocc)
    if (nbocc .ne. 0) then
        call getvid('MINMAX', 'CHAM_GD', iocc=1, scal=chdef, nbret=n1)
        if (n1 .ne. 0) then
            call getvid('MINMAX', 'MODELE', iocc=1, scal=modele, nbret=n2)
        else
            call getvid('MINMAX', 'RESULTAT', iocc=1, scal=resuco, nbret=nr)
            call medomp(resuco, modele)
        endif
        call pemima(n1, chdef, resu, modele, nbocc)
    endif
!
    call getfac('WEIBULL', nbocc)
    if (nbocc .ne. 0) then
        call medomp(resuco, modele, mate, carele, nh)
        call peweib(resu, modele, mate, carele, k8b,&
                    nh, nbocc, 0, nomcmd)
    endif
!
    call getfac('RICE_TRACEY', nbocc)
    if (nbocc .ne. 0) then
        call medomp(resuco, modele, carele=carele, nh=nh)
        call peritr(resu, modele, carele, nh, nbocc)
    endif
!
    call getfac('CARA_GEOM', nbocc)
    if (nbocc .ne. 0) then
        call medomp(resuco, modele)
        call pecage(resu, modele, nbocc)
    endif
!
    call getfac('CARA_POUTRE', nbocc)
    if (nbocc .ne. 0) then
        call medomp(resuco, modele, carele=carele, nh=nh)
        call pecapo(resu, modele, carele, nh)
    endif
!
    call getfac('INDIC_ENER', nbocc)
    if (nbocc .ne. 0) then
        call medomp(resuco, modele, mate, carele, nh)
        call peingl(resu, modele, mate, carele, nh,&
                    nbocc, 'INDIC_ENER')
    endif
!
    call getfac('INDIC_SEUIL', nbocc)
    if (nbocc .ne. 0) then
        call medomp(resuco, modele, mate, carele, nh)
        call peingl(resu, modele, mate, carele, nh,&
                    nbocc, 'INDIC_SEUIL')
    endif
!
    call getfac('ENER_ELAS', nbocc)
    if (nbocc .ne. 0) then
        call medomp(resuco, modele, mate, carele, nh)
        call peingl(resu, modele, mate, carele, nh,&
                    nbocc, 'ENER_ELAS')
    endif
!
    call getfac('ENER_ELTR', nbocc)
    if (nbocc .ne. 0) then
        call medomp(resuco, modele, mate, carele, nh)
        call peingl(resu, modele, mate, carele, nh,&
                    nbocc, 'ENER_ELTR')
    endif

!
    call getfac('ENER_TOTALE', nbocc)
    if (nbocc .ne. 0) then
        call medomp(resuco, modele, mate, carele, nh)
        call peingl(resu, modele, mate, carele, nh,&
                    nbocc, 'ENER_TOTALE')
    endif
!
    call getfac('ENER_DISS', nbocc)
    if (nbocc .ne. 0) then
        call medomp(resuco, modele, mate, carele, nh)
        call peingl(resu, modele, mate, carele, nh,&
                    nbocc, 'ENER_DISS')
    endif
!
999  continue
    call titre()
!
    call jedema()
!
end subroutine
