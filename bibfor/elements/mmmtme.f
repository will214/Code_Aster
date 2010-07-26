      SUBROUTINE MMMTME(PHASE ,NDIM  ,NNE   ,NNM   ,NORM  ,
     &                  MPROJN,MPROJT,HPG   ,FFE   ,FFM   ,
     &                  JACOBI,COEFCP,COEFCR,COEFFP,COEFFF,
     &                  RESE  ,NRESE ,LAMBDA,COEFFS,JEU   ,
     &                  ASPERI,KAPPAN,KAPPAV,DELTAT,BETA  ,
     &                  GAMMA ,CWEAR ,DISSIP,DLAGRC,DELUSU,
     &                  MATRME)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 27/07/2010   AUTEUR DESOZA T.DESOZA 
C ======================================================================
C COPYRIGHT (C) 1991 - 2009  EDF R&D                  WWW.CODE-ASTER.ORG
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
C RESPONSABLE ABBAS M.ABBAS
C TOLE CRP_21
C
      IMPLICIT NONE
      CHARACTER*4  PHASE
      INTEGER      NDIM,NNE,NNM
      REAL*8       NORM(3)
      REAL*8       MPROJN(3,3),MPROJT(3,3)
      REAL*8       FFE(9),FFM(9)
      REAL*8       HPG,JACOBI
      REAL*8       RESE(3),NRESE
      REAL*8       COEFCP,COEFCR
      REAL*8       COEFFP,COEFFS
      REAL*8       LAMBDA,COEFFF
      REAL*8       JEU
      REAL*8       KAPPAN,KAPPAV,ASPERI
      REAL*8       BETA,GAMMA,DELTAT
      REAL*8       DLAGRC,DELUSU(3),DISSIP,CWEAR
      REAL*8       MATRME(27,27)
C
C ----------------------------------------------------------------------
C
C ROUTINE CONTACT (METHODE CONTINUE - UTILITAIRE)
C
C CALCUL DE LA MATRICE DEPL_MAIT/DEPL_ESCL
C
C ----------------------------------------------------------------------
C
C
C IN  PHASE  : PHASE DE CALCUL
C              'GLIS' - CONTACT GLISSANT
C              'STAC' - TERME DE STABILISATION DU CONTACT
C              'STAF' - TERME DE STABILISATION DU FROTTEMENT
C              'COMP' - COMPLIANCE
C              'USUR' - USURE
C              'PCON' - PENALISATION - CONTACT
C              'PADH' - PENALISATION - FROTTEMENT ADHERENT
C              'PGLI' - PENALISATION - FROTTEMENT GLISSANT
C IN  NDIM   : DIMENSION DU PROBLEME
C IN  NNE    : NOMBRE DE NOEUDS DE LA MAILLE ESCLAVE
C IN  NNM    : NOMBRE DE NOEUDS DE LA MAILLE MAITRE
C IN  NORM   : NORMALE AU POINT DE CONTACT
C IN  MPROJN : MATRICE DE PROJECTION NORMALE
C IN  MPROJT : MATRICE DE PROJECTION TANGENTE
C IN  HPG    : POIDS DU POINT INTEGRATION DU POINT DE CONTACT
C IN  FFE    : FONCTIONS DE FORMES DEPL. ESCL.
C IN  FFM    : FONCTIONS DE FORMES DEPL. MAIT.
C IN  JACOBI : JACOBIEN DE LA MAILLE AU POINT DE CONTACT
C IN  COEFCP : COEF_PENA_CONT
C IN  COEFCR : COEF_REGU_CONT
C IN  COEFFS : COEF_STAB_FROT
C IN  LAMBDA : VALEUR DU MULT. DE CONTACT (SEUIL DE TRESCA)
C IN  RESE   : SEMI-MULTIPLICATEUR GTK DE FROTTEMENT
C               GTK = LAMBDAF + COEFFR*VITESSE
C IN  NRESE  : NORME DU SEMI-MULTIPLICATEUR GTK DE FROTTEMENT
C IN  COEFFF : COEFFICIENT DE FROTTEMENT DE COULOMB
C IN  COEFFP : COEF_PENA_FROT
C IN  JEU    : VALEUR DU JEU
C IN  ASPERI : PARAMATRE A DU MODELE DE COMPLIANCE
C IN  KAPPAN : COEFFICIENT KN DU MODELE DE COMPLIANCE
C IN  KAPPAV : COEFFICIENT KV DU MODELE DE COMPLIANCE
C IN  DELTAT : INCREMENT DE TEMPS
C IN  BETA   : COEFFICIENT SCHEMA DE NEWMARK
C IN  GAMMA  : COEFFICIENT SCHEMA DE NEWMARK
C IN  CWEAR  : COEFFICIENT D'USURE (KWEAR/HWEAR)
C IN  DLAGRC : LAGR_C DEPDEL DU POINT DE CONTACT (USURE UNILATERALE)
C IN  DELUSU : SAUT TGT DE L'INCREMENT DE DEPLACEMENT [[DELTA_U]]_TAU
C IN  DISSIP : DISSIPATION USURE
C OUT MATRME : MATRICE ELEMENTAIRE DEPL_M/DEPL_E
C
C ----------------------------------------------------------------------
C
      INTEGER   I, J, K,L,II, JJ,IDIM
      REAL*8    G(3,3),E(3,3),D(3,3)
      REAL*8    C1(3),C2(3),C3(3),D1(3),D2(3),D3(3)
C
C ----------------------------------------------------------------------
C
C
C --- INITIALISATIONS
C
      CALL MATINI( 3, 3,0.D0,D     )
      CALL MATINI( 3, 3,0.D0,E     )
      CALL MATINI( 3, 3,0.D0,G     )
      CALL VECINI(3,0.D0,C1)
      CALL VECINI(3,0.D0,C2)
      CALL VECINI(3,0.D0,C3)
      CALL VECINI(3,0.D0,D1)
      CALL VECINI(3,0.D0,D2)
      CALL VECINI(3,0.D0,D3)
C
      DO 3 IDIM = 1,3
        C1(IDIM) = MPROJT(IDIM,1)
        C2(IDIM) = MPROJT(IDIM,2)
        C3(IDIM) = MPROJT(IDIM,3)
3     CONTINUE
C
C --- PARTIE STABILISATION ET PENALISATION DU CONTACT
C
      IF ((PHASE.EQ.'STAC').OR.(PHASE.EQ.'PCON')) THEN
        DO 200 I = 1,NNM
          DO 190 J = 1,NNE
            DO 180 K = 1,NDIM
              DO 170 L = 1,NDIM
                II = NDIM*(I-1)+L
                JJ = NDIM*(J-1)+K
                MATRME(II,JJ) = MATRME(II,JJ) - COEFCP*
     &                          HPG*JACOBI*FFM(I)*MPROJN(L,K)*FFE(J)
  170         CONTINUE
  180       CONTINUE
  190     CONTINUE
  200   CONTINUE
C
C --- PARTIE STABILISATION DU FROTTEMENT ET
C --- PARTIE PENALISATION DU FROTTEMENT ADHERENT
C
      ELSEIF ((PHASE.EQ.'STAF').OR.(PHASE.EQ.'PADH')) THEN
C       --- PRODUIT MATR_PROJ_TANG PAR MATR_PROJ_TANG
        DO 360 I = 1,NDIM
          DO 350 J = 1,NDIM
            DO 340 K = 1,NDIM
              E(I,J) = MPROJT(K,I)*MPROJT(K,J) + E(I,J)
  340       CONTINUE
  350     CONTINUE
  360   CONTINUE
        DO 207 I = 1,NNM
          DO 197 J = 1,NNE
            DO 187 K = 1,NDIM
              DO 177 L = 1,NDIM
                II = NDIM*(I-1)+K
                JJ = NDIM*(J-1)+L
                MATRME(II,JJ) = MATRME(II,JJ) + COEFFP*COEFFF*LAMBDA*
     &                          HPG*JACOBI*FFM(I)*E(L,K)*FFE(J)
  177         CONTINUE
  187       CONTINUE
  197     CONTINUE
  207   CONTINUE
C
C --- PARTIE GLISSANT
C
      ELSEIF (PHASE.EQ.'GLIS') THEN
C       --- VECTEUR PROJ. BOULE SUR PLAN TGT1
        CALL MKKVEC(RESE  ,NRESE ,NDIM  ,C1  ,D1    )
        CALL MKKVEC(RESE  ,NRESE ,NDIM  ,C2  ,D2    )
        CALL MKKVEC(RESE  ,NRESE ,NDIM  ,C3  ,D3    )
C       --- MATRICE [G] = [{D1}{D2}{D3}]
        DO 16 IDIM = 1,3
          G(IDIM,1) = D1(IDIM)
          G(IDIM,2) = D2(IDIM)
          G(IDIM,3) = D3(IDIM)
 16     CONTINUE
C       --- MATRICE [D] = [P]*[G]t
        DO 23 I = 1,NDIM
          DO 24 J = 1,NDIM
            DO 25  K = 1,NDIM
              D(I,J) = G(K,I)*MPROJT(K,J) + D(I,J)
  25        CONTINUE
  24      CONTINUE
  23    CONTINUE
        DO 707 I = 1,NNM
          DO 797 J = 1,NNE
            DO 787 K = 1,NDIM
              DO 777 L = 1,NDIM
                II = NDIM*(I-1)+L
                JJ = NDIM*(J-1)+K
                MATRME(II,JJ) = MATRME(II,JJ) + COEFFS*COEFFF*LAMBDA*
     &                          HPG*JACOBI*FFM(I)*D(L,K)*FFE(J)
  777         CONTINUE
  787       CONTINUE
  797     CONTINUE
  707   CONTINUE
C
C --- PENALISATION - PARTIE GLISSANT
C
      ELSEIF (PHASE.EQ.'PGLI') THEN
C       --- VECTEUR PROJ. BOULE SUR PLAN TGT1
        CALL MKKVEC(RESE  ,NRESE ,NDIM  ,C1  ,D1    )
        CALL MKKVEC(RESE  ,NRESE ,NDIM  ,C2  ,D2    )
        CALL MKKVEC(RESE  ,NRESE ,NDIM  ,C3  ,D3    )
C       --- MATRICE [G] = [{D1}{D2}{D3}]
        DO 416 IDIM = 1,3
          G(IDIM,1) = D1(IDIM)
          G(IDIM,2) = D2(IDIM)
          G(IDIM,3) = D3(IDIM)
 416    CONTINUE
C       --- MATRICE [D] = [P]*[G]t
        DO 423 I = 1,NDIM
          DO 424 J = 1,NDIM
            DO 425  K = 1,NDIM
              D(I,J) = G(K,I)*MPROJT(K,J) + D(I,J)
 425        CONTINUE
 424      CONTINUE
 423    CONTINUE
        DO 407 I = 1,NNM
          DO 497 J = 1,NNE
            DO 487 K = 1,NDIM
              DO 477 L = 1,NDIM
                II = NDIM*(I-1)+L
                JJ = NDIM*(J-1)+K
                MATRME(II,JJ) = MATRME(II,JJ) + COEFFP*COEFFF*LAMBDA*
     &                          HPG*JACOBI*FFM(I)*D(L,K)*FFE(J)
  477         CONTINUE
  487       CONTINUE
  497     CONTINUE
  407   CONTINUE
C
C --- PARTIE COMPLIANCE
C
      ELSEIF (PHASE.EQ.'COMP') THEN
         DO 161 I = 1,NNM
          DO 151 J = 1,NNE
            DO 141 K = 1,NDIM
              DO 131 L = 1,NDIM
                II = NDIM*(I-1)+L
                JJ = NDIM*(J-1)+K
                MATRME(II,JJ) = MATRME(II,JJ) +
     &                          (KAPPAN*2*(JEU-ASPERI)-
     &                           KAPPAV*(GAMMA/(BETA*DELTAT)))*
     &                          HPG*JACOBI*FFM(I)*MPROJN(L,K)*FFE(J)
  131         CONTINUE
  141       CONTINUE
  151     CONTINUE
  161   CONTINUE
C
C --- PARTIE USURE
C
      ELSEIF (PHASE.EQ.'USUR') THEN
         DO 162 I = 1,NNM
          DO 152 J = 1,NNE
            DO 142 K = 1,NDIM
              DO 132 L = 1,NDIM
                II = NDIM*(I-1)+L
                JJ = NDIM*(J-1)+K
                MATRME(II,JJ) = MATRME(II,JJ) + COEFCR*
     &                          (HPG*FFM(I)*FFE(J)*JACOBI*NORM(K))*
     &                          (CWEAR/DISSIP)*DELUSU(L)*DLAGRC
  132         CONTINUE
  142       CONTINUE
  152     CONTINUE
  162   CONTINUE
C
      ELSE
        CALL ASSERT(.FALSE.)

      ENDIF



C
      END
