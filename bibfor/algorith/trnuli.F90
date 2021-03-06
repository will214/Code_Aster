subroutine trnuli(itab, nblig, nbcol, icol, nures)
    implicit none
#include "asterf_types.h"
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
!
!***********************************************************************
!    P. RICHARD     DATE 20/01/92
!-----------------------------------------------------------------------
!  BUT:  < TROUVER NUMERO DE  LIGNE DANS UN TABLEAU >
!
!   A PARTIR DES VALEURS DES COLONNES
!
!-----------------------------------------------------------------------
!
! NOM----- / /:
!
! ITAB     /I/: TABLEAU D'ENTIER
! NBLIG    /I/: NOMBRE DE LIGNES
! NBCOL    /I/: NOMBRE DE COLONNES
! ICOL     /I/: VALEURS DES COLONNES A TROUVER
! NURES    /I/: NUMERO DE LA LIGNE CHERCHEE
!
!
!-----------------------------------------------------------------------
!
    integer :: i, j, nbcol, nblig, nures
    integer :: itab(nblig, nbcol), icol(nbcol)
    aster_logical :: ok
!-----------------------------------------------------------------------
    i=0
    nures=0
!
 10 continue
    i=i+1
!
    ok=.true.
!
    do 20 j = 1, nbcol
        if (itab(i,j) .ne. icol(j)) ok=.false.
 20 end do
!
    if (ok) then
        nures=i
        goto 9999
    else
        if (i .lt. nblig) then
            goto 10
        else
            goto 9999
        endif
    endif
!
!
9999 continue
end subroutine
