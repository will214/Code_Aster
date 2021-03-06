subroutine veri_noe(mailla, dmax_cable, lnuma, liproj,&
                                  nbmaok, x3dca, iproj,noe, numail)
    implicit none
!-----------------------------------------------------------------------
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
!-----------------------------------------------------------------------
!  DESCRIPTION : 
!  -----------   
!       DEFI_CABLE_BP/RELA_CINE/CABLE-COQUE
!       ANALYSE LA LISTE DES NOEUDS CANDIDATS A UNE PROJECTION DU 
!       NOEUD DE CABLE
!
!       POUR QUE LA PROJECTION SOIT POSSIBLE IL FAUT QUE LE NOEUD 
!       SUFFISAMMENT PROCHE
!
!       IPROJ : 0 SI PROJECTION AUTORISE SUR UN SEGMENT
!              -1 SINON
!       OUT : NOE, NUMERO DU NOEUD
!-------------------   DECLARATION DES VARIABLES   ---------------------
!
!
#include "jeveux.h"
#include "asterfort/assert.h"
#include "asterfort/as_deallocate.h"
#include "asterfort/as_allocate.h"
#include "asterfort/canorm.h"
#include "asterfort/jedema.h"
#include "asterfort/jemarq.h"
#include "asterfort/jeveuo.h"
#include "asterfort/jexatr.h"
#include "asterfort/projtq.h"
#include "blas/daxpy.h"
#include "blas/dcopy.h"
!
! ARGUMENTS
! ---------
    character(len=8) :: mailla
    real(kind=8) :: x3dca(3), dmax_cable
    integer :: iproj, lnuma(*), liproj(*), nbmaok, noe, numail
!
! VARIABLES LOCALES
! -----------------
    integer :: imail, j, jconx1, jcoor, jconx2, nbcnx, inoma
    integer :: jtyma, ntyma, itria, inoeu, icote, iproj2, i, cxma(9), jnoeu, knoeu
    real(kind=8) :: d1, d2
    character(len=24) :: conxma, coorno, tymama
    real(kind=8) :: xyzma(3, 9), normal(3), excent, xbar(3), x3dp(3), prec, quart
    parameter (prec=5.d-2, quart=0.25d0)
!
!
!-------------------   DEBUT DU CODE EXECUTABLE    ---------------------
!
!
    call jemarq()
    
    j=0
    iproj = -1
    noe = 0
    numail = 0
    
    conxma = mailla//'.CONNEX'
    call jeveuo(conxma, 'L', jconx1)
    coorno = mailla//'.COORDO    .VALE'
    call jeveuo(coorno, 'L', jcoor)
    tymama = mailla//'.TYPMAIL'
    call jeveuo(tymama, 'L', jtyma)
    call jeveuo(jexatr(mailla//'.CONNEX', 'LONCUM'), 'L', jconx2)
    
!   tstbar est très sévère sur les cas limites
!   en cas d'echec on regarde si on est suffisamment près du noeud pour
!   accepter la projection sur ce noeud.
!   on fixe la longeur limite au min entre 1/4 de la taille de la maille
!   et un 1/1000eme de la longueur du cable (dmax_cable)

    do imail = 1, nbmaok
        if (liproj(imail).eq.30)then
            numail = lnuma(imail)
!       
            nbcnx = zi(jconx2+numail)-zi(jconx2-1+numail)
            
            do inoma = 1, nbcnx
                noe = zi(jconx1-1+zi(jconx2+numail-1)+inoma-1)
                cxma(inoma) = noe
                xyzma(1,inoma) = zr(jcoor+3*(noe-1) )
                xyzma(2,inoma) = zr(jcoor+3*(noe-1)+1)
                xyzma(3,inoma) = zr(jcoor+3*(noe-1)+2)
            enddo
    !
            ntyma = zi(jtyma+numail-1)
            call canorm(xyzma, normal, 3, ntyma, 1)
    !
            excent = normal(1)*(x3dca(1)-xyzma(1,1)) + normal(2)*( x3dca(2)-xyzma(2,1)) &
                             + normal(3)*(x3dca(3)-xyzma(3,1))
            call dcopy(3, x3dca, 1, x3dp, 1)  
            call daxpy(3, -excent, normal, 1, x3dp, 1)
    !
            call projtq(nbcnx, xyzma, 1, x3dp, abs(excent), &
                        itria, inoeu, icote, xbar, iproj2)  
            ASSERT(iproj2 .eq.30)
            do i =1,3
                if(abs(1.d0-xbar(i)).le. quart)then
                    if (itria.eq.1)then
                        jnoeu = inoeu+1
                        if (jnoeu.eq.3) jnoeu = 1
                        knoeu = inoeu-1
                        if (knoeu.eq.0) knoeu = 3
                    else
                        jnoeu = inoeu+1
                        if (jnoeu.eq.5) jnoeu = 1
                        if (jnoeu.eq.2) jnoeu = 3
                        knoeu = inoeu-1
                        if (knoeu.eq.0) knoeu = 4
                        if (knoeu.eq.2) knoeu = 1
                    endif
                    d1 = sqrt((xyzma(1,jnoeu)-xyzma(1,inoeu))**2&
                        +(xyzma(2,jnoeu)-xyzma(2,inoeu))**2&
                        +(xyzma(3,jnoeu)-xyzma(3,inoeu))**2)
                    d2 = sqrt((xyzma(1,knoeu)-xyzma(1,inoeu))**2&
                        +(xyzma(2,knoeu)-xyzma(2,inoeu))**2&
                        +(xyzma(3,knoeu)-xyzma(3,inoeu))**2)
                    d1 = max(d1, d2)
                    if (d1*abs(1.d0-xbar(i)) .le. prec*dmax_cable)then
                        noe = cxma(inoeu)
                        iproj = 0
                        goto 30
                    endif
                endif
            enddo
        endif
    enddo
30  continue
!
    call jedema()
!
end subroutine
