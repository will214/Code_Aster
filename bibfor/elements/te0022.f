      SUBROUTINE TE0022(OPTION,NOMTE)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 24/07/2012   AUTEUR PELLET J.PELLET 
C ======================================================================
C COPYRIGHT (C) 1991 - 2012  EDF R&D                  WWW.CODE-ASTER.ORG
C THIS PROGRAM IS FREE SOFTWARE; YOU CAN REDISTRIBUTE IT AND/OR MODIFY
C IT UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICENSE AS PUBLISHED BY
C THE FREE SOFTWARE FOUNDATION; EITHER VERSION 2 OF THE LICENSE, OR
C (AT YOUR OPTION) ANY LATER VERSION.

C THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT
C WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF
C MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. SEE THE GNU
C GENERAL PUBLIC LICENSE FOR MORE DETAILS.

C YOU SHOULD HAVE RECEIVED A COPY OF THE GNU GENERAL PUBLIC LICENSE
C ALONG WITH THIS PROGRAM; IF NOT, WRITE TO EDF R&D CODE_ASTER,
C    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================
C.......................................................................

C     BUT: CALCUL DES CONTRAINTES AUX POINTS DE GAUSS
C          ELEMENTS ISOPARAMETRIQUES 3D

C          OPTION : 'SIEF_ELGA'

C     ENTREES  ---> OPTION : OPTION DE CALCUL
C              ---> NOMTE  : NOM DU TYPE ELEMENT
C.......................................................................

      IMPLICIT NONE
      INCLUDE 'jeveux.h'
      CHARACTER*16 NOMTE,OPTION
      REAL*8 SIGMA(162),REPERE(7),INSTAN,NHARM
      REAL*8 BARY(3)
      INTEGER NBSIGM,NDIM,NNO,NNOS,NPG1,IPOIDS,IVF,IDFDE,JGANO
      INTEGER IDIM


C ---- CARACTERISTIQUES DU TYPE D'ELEMENT :
C ---- GEOMETRIE ET INTEGRATION
C      ------------------------
C-----------------------------------------------------------------------
      INTEGER I ,ICONT ,IDEPL ,IGEOM ,IMATE ,NBSIG
      REAL*8 ZERO
C-----------------------------------------------------------------------
      CALL ELREF4(' ','RIGI',NDIM,NNO,NNOS,NPG1,IPOIDS,IVF,IDFDE,JGANO)

C ---- NOMBRE DE CONTRAINTES ASSOCIE A L'ELEMENT
C      -----------------------------------------
      NBSIG = NBSIGM()

C --- INITIALISATIONS :
C     -----------------
      ZERO = 0.0D0
      INSTAN = ZERO
      NHARM = ZERO

      DO 10 I = 1,NBSIG*NPG1
        SIGMA(I) = ZERO
   10 CONTINUE

C ---- RECUPERATION DES COORDONNEES DES CONNECTIVITES
C      ----------------------------------------------
      CALL JEVECH('PGEOMER','L',IGEOM)

C ---- RECUPERATION DU MATERIAU
C      ------------------------
      CALL JEVECH('PMATERC','L',IMATE)

C ---- RECUPERATION  DES DONNEEES RELATIVES AU REPERE D'ORTHOTROPIE
C      ------------------------------------------------------------
C     COORDONNEES DU BARYCENTRE ( POUR LE REPRE CYLINDRIQUE )

      BARY(1) = 0.D0
      BARY(2) = 0.D0
      BARY(3) = 0.D0
      DO 150 I = 1,NNO
        DO 140 IDIM = 1,NDIM
          BARY(IDIM) = BARY(IDIM)+ZR(IGEOM+IDIM+NDIM*(I-1)-1)/NNO
 140    CONTINUE
 150  CONTINUE
      CALL ORTREP(ZI(IMATE),NDIM,BARY,REPERE)

C ---- RECUPERATION DU CHAMP DE DEPLACEMENT SUR L'ELEMENT
C      --------------------------------------------------
      CALL JEVECH('PDEPLAR','L',IDEPL)

      CALL SIGVMC('RIGI',NNO,NDIM,NBSIG,NPG1,IPOIDS,IVF,
     &            IDFDE,ZR(IGEOM),ZR(IDEPL),
     &            INSTAN,REPERE,ZI(IMATE),NHARM,SIGMA)


C ---- RECUPERATION ET AFFECTATION DU VECTEUR EN SORTIE
C ---- AVEC LE VECTEUR DES CONTRAINTES AUX POINTS D'INTEGRATION
C      --------------------------------------------------------
      CALL JEVECH('PCONTRR','E',ICONT)

      DO 40 I = 1,NBSIG*NPG1
        ZR(ICONT+I-1) = SIGMA(I)
   40 CONTINUE

      END
