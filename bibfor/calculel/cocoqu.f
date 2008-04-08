      SUBROUTINE COCOQU(NUMA  ,CONNEX,LONCUM,COORD ,TYPEPA,
     &                  EPAIS ,NORMAL,DIME  ,CNOEUD)
C
C RESPONSABLE MEUNIER S.MEUNIER
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF CALCULEL  DATE 08/04/2008   AUTEUR MEUNIER S.MEUNIER 
C ======================================================================
C COPYRIGHT (C) 1991 - 2007  EDF R&D                  WWW.CODE-ASTER.ORG
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
C   1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================
C
      IMPLICIT NONE
      INTEGER     NUMA,CONNEX(*),LONCUM(*)
      INTEGER     DIME
      REAL*8      COORD(3,*)
      REAL*8      EPAIS
      REAL*8      CNOEUD(DIME,*)
      REAL*8      NORMAL(DIME,*)
      CHARACTER*8 TYPEPA
C
C ----------------------------------------------------------------------
C
C CONSTRUCTION DE BOITES ENGLOBANTES POUR UN GROUPE DE MAILLES
C
C RETOURNE LES COORDONNEES DES NOEUDS DE LA MAILLE POUR LES ELEMENTS
C COQUES EN LES EXTRUDANT EN 3D AVEC UEN EPAISSEUR
C
C ----------------------------------------------------------------------
C
C
C IN  NUMA   : NUMERO ABSOLU DE LA MAILLE DANS LE MAILLAGE
C IN  CONNEX : CONNEXITE DES MAILLES
C IN  LONCUM : LONGUEUR CUMULEE DE CONNEX
C IN  TYPEPA : MANIERE DE PRENDRE EN COMPTE L'EPAISSEUR DE LA COQUE
C              'CONSTANT' EPAISSEUR CONSTANTE SUR TOUS LES NOEUDS
C                         DONNEE PAR EPAIS
C              'VARIABLE' EPAISSEUR DONNEE PAR UNE NORMALE A CHAQUE ND
C                         DONNEE PAR NORMAL
C IN  EPAIS  : POUR EPAISSEUR DE LA COQUE
C IN  NORMAL : COORDONNEES DES NORMALES (CF LISNOR)
C IN  DIME   : DIMENSION DE L'ESPACE
C IN  COORD  : COORDONNEES DES NOEUDS
C OUT CNOEUD : COORD DES NOEUDS (X1, [Y1, Z1], X2, ...)
C
C ----------------------------------------------------------------------
C
      REAL*8  R,H
      INTEGER NOECOQ(2,9),INO,IDIM,K1,K2,NUNO,JDEC,NBNO
C
C ----------------------------------------------------------------------
C
      JDEC   = LONCUM(NUMA)
      NBNO   = LONCUM(NUMA+1) - JDEC
C
      CALL NOCOQU(DIME,NBNO,NOECOQ)
C
      DO 20 INO = 1, NBNO
        NUNO = CONNEX(JDEC-1+INO)
        K1   = NOECOQ(1,INO)
        K2   = NOECOQ(2,INO)
        DO 21 IDIM = 1, DIME
          R = COORD(IDIM,NUNO)
          IF (TYPEPA.EQ.'CONSTANT') THEN
            H = EPAIS
          ELSEIF (TYPEPA.EQ.'VARIABLE') THEN
            H = NORMAL(IDIM,NUNO)
          ELSE
            CALL ASSERT(.FALSE.)
          ENDIF
          CNOEUD(IDIM,K1) = R - H
          CNOEUD(IDIM,K2) = R + H
 21     CONTINUE
 20   CONTINUE
C
      END
