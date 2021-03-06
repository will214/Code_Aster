function inits(os, nos, eta)
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
! UTILISEE SOUS NT POUR L'EVALUATION DE LA FONCTION D'ERREUR
! ERFC  (PROVIENT DE LA BIBLIOTHEQUE SLATEC)
!
!***BEGIN PROLOGUE  INITS
!***PURPOSE  DETERMINE THE NUMBER OF TERMS NEEDED IN AN ORTHOGONAL
!            POLYNOMIAL SERIES SO THAT IT MEETS A SPECIFIED ACCURACY.
!***LIBRARY   SLATEC (FNLIB)
!***CATEGORY  C3A2
!***TYPE      DOUBLE PRECISION (INITS-S, INITDS-D)
!***KEYWORDS  CHEBYSHEV, FNLIB, INITIALIZE, ORTHOGONAL POLYNOMIAL,
!             ORTHOGONAL SERIES, SPECIAL FUNCTIONS
!***AUTHOR  FULLERTON, W., (LANL)
!***DESCRIPTION
!
!  INITIALIZE THE ORTHOGONAL SERIES, REPRESENTED BY THE ARRAY OS, SO
!  THAT INITS IS THE NUMBER OF TERMS NEEDED TO INSURE THE ERROR IS NO
!  LARGER THAN ETA.  ORDINARILY, ETA WILL BE CHOSEN TO BE ONE-TENTH
!  MACHINE PRECISION.
!
!             INPUT ARGUMENTS --
!   OS     DOUBLE PRECISION ARRAY OF NOS COEFFICIENTS IN AN ORTHOGONAL
!          SERIES.
!   NOS    NUMBER OF COEFFICIENTS IN OS.
!   ETA    SINGLE PRECISION SCALAR CONTAINING REQUESTED ACCURACY OF
!          SERIES.
!
!***END PROLOGUE  INITDS
    implicit none
    integer :: inits
#include "asterfort/assert.h"
    real(kind=8) :: os(*)
!***FIRST EXECUTABLE STATEMENT  INITDS
!-----------------------------------------------------------------------
    integer :: i, ii, nos
    real(kind=8) :: err, eta
!-----------------------------------------------------------------------
    ASSERT(nos .ge. 1)
!
    err = 0.d0
    do 10 ii = 1, nos
        i = nos + 1 - ii
        err = err + abs(os(i))
        if (err .gt. eta) goto 20
10  end do
!
20  continue
!     ASSERT SI SERIE DE CHEBYSHEV TROP COURTE POUR LA PRECISION
    ASSERT(i .ne. nos)
    inits = i
!
end function
