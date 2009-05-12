        SUBROUTINE LCPRSN(N,X,Y,P)
        IMPLICIT NONE
        INTEGER N
        REAL*8  X(N),Y(N),P
C       ----------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF UTILIFOR  DATE 12/05/2009   AUTEUR MEUNIER S.MEUNIER 
C ======================================================================
C COPYRIGHT (C) 1991 - 2001  EDF R&D                  WWW.CODE-ASTER.ORG
C THIS PROGRAM IS FREE SOFTWARE; YOU CAN REDISTRIBUTE IT AND/OR MODIFY
C IT UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICENSE AS PUBLISHED BY
C THE FREE SOFTWARE FOUNDATION; EITHER VERSION 2 OF THE LICENSE, OR
C (AT YOUR OPTION) ANY LATER VERSION.
C
C THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT
C WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF
C MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. SEE THE GNU
C GENERAL PUBLIC LICENSE FOR MORE DETAILS.
C
C YOU SHOULD HAVE RECEIVED A COPY OF THE GNU GENERAL PUBLIC LICENSE
C ALONG WITH THIS PROGRAM; IF NOT, WRITE TO EDF R&D CODE_ASTER,
C    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================
C ----------------------------------------------------------------------
C
C LOI DE COMPORTEMENT - PRODUIT SCALAIRE DE 2 VECTEURS - VERSION NORMALE
C *      *              **      *                                *
C
C ----------------------------------------------------------------------
C
C IN  N    : DIMENSION DES VECTEURS X ET Y
C IN  X    : VECTEUR X
C IN  Y    : VECTEUR Y
C OUT P    : PRODUIT SCALAIRE DE X ET Y
C
C ----------------------------------------------------------------------
C
        INTEGER      I
C
        P = 0.D0
        DO 1 I = 1 , N
          P = P + X(I)*Y(I)
 1      CONTINUE
        END
