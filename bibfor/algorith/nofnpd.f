      SUBROUTINE NOFNPD(NDIM,NNO1,NNO2,NNO3,NPG,IW,VFF1,VFF2,VFF3,
     &                  IDFF1,VU,VP,VPI,TYPMOD,MATE,COMPOR,GEOMI,NOMTE,
     &                  SIG,DDL,VECT)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 18/03/2013   AUTEUR SFAYOLLE S.FAYOLLE 
C ======================================================================
C COPYRIGHT (C) 1991 - 2013  EDF R&D                  WWW.CODE-ASTER.ORG
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
C RESPONSABLE SFAYOLLE S.FAYOLLE
C TOLE CRS_1404
C TOLE CRP_21
      IMPLICIT NONE

      INTEGER      NDIM,NNO1,NNO2,NNO3,NPG,IW,IDFF1
      INTEGER      MATE
      INTEGER      VU(3,27),VP(27),VPI(3,27)
      REAL*8       GEOMI(NDIM,NNO1)
      REAL*8       VFF1(NNO1,NPG),VFF2(NNO2,NPG),VFF3(NNO3,NPG)
      REAL*8       SIG(2*NDIM+1,NPG),DDL(*),VECT(*)
      CHARACTER*8  TYPMOD(*)
      CHARACTER*16 COMPOR(*),NOMTE
C-----------------------------------------------------------------------
C          CALCUL DES FORCES NODALES POUR LES ELEMENTS
C          INCOMPRESSIBLES POUR LES PETITES DEFORMATIONS
C          3D/D_PLAN/AXIS
C          ROUTINE APPELEE PAR TE0591
C-----------------------------------------------------------------------
C IN  NDIM    : DIMENSION DE L'ESPACE
C IN  NNO1    : NOMBRE DE NOEUDS DE L'ELEMENT LIES AUX DEPLACEMENTS
C IN  NNO2    : NOMBRE DE NOEUDS DE L'ELEMENT LIES AU GONFLEMENT
C IN  NNO3    : NOMBRE DE NOEUDS DE L'ELEMENT LIES A LA PRESSION
C IN  NPG     : NOMBRE DE POINTS DE GAUSS
C IN  IW      : POIDS DES POINTS DE GAUSS
C IN  VFF1    : VALEUR  DES FONCTIONS DE FORME LIES AUX DEPLACEMENTS
C IN  VFF2    : VALEUR  DES FONCTIONS DE FORME LIES AU GONFLEMENT
C IN  VFF3    : VALEUR  DES FONCTIONS DE FORME LIES A LA PRESSION
C IN  IDFF1   : DERIVEE DES FONCTIONS DE FORME ELEMENT DE REFERENCE
C IN  VU      : TABLEAU DES INDICES DES DDL DE DEPLACEMENTS
C IN  VG      : TABLEAU DES INDICES DES DDL DE GONFLEMENT
C IN  VP      : TABLEAU DES INDICES DES DDL DE PRESSION
C IN  GEOMI   : COORDONEES DES NOEUDS
C IN  TYPMOD  : TYPE DE MODELISATION
C IN  MATE    : MATERIAU CODE
C IN  COMPOR  : COMPORTEMENT
C IN  DDL     : DEGRES DE LIBERTE A L'INSTANT PRECEDENT
C IN  SIG     : CONTRAINTES A L'INSTANT PRECEDENT
C OUT VECT    : FORCES INTERNES
C-----------------------------------------------------------------------

      LOGICAL      AXI,GRAND
      INTEGER      NDDL,G
      INTEGER      IA,NA,RA,SA,KK
      INTEGER      IBID
      REAL*8       DEPLM(3*27),R
      REAL*8       PRESM(27),PM,GPM(NDIM),PIM(NDIM)
      REAL*8       GPRESM(3*27)
      REAL*8       DFF1(NNO1,NDIM)
      REAL*8       FM(3,3)
      REAL*8       W 
      REAL*8       RAC2
      REAL*8       DEF(2*NDIM,NNO1,NDIM)
      REAL*8       EPSM(6),SIGMA(6)
      REAL*8       DIVUM
      REAL*8       DDOT,T1,T2
      REAL*8       ALPHA,TREPST
      REAL*8       DSBDEP(2*NDIM,2*NDIM)
      REAL*8       STAB,HK
      CHARACTER*16 OPTION

      PARAMETER    (GRAND = .FALSE.)
C-----------------------------------------------------------------------

C - INITIALISATION
      AXI  = TYPMOD(1).EQ.'AXIS'
      NDDL = NNO1*NDIM + NNO2 + NNO3*NDIM
      RAC2  = SQRT(2.D0)
      OPTION = 'FORC_NODA       '

      CALL UTHK(NOMTE,GEOMI,HK,NDIM,IBID,IBID,IBID,IBID,1,IBID)
      STAB = 1.D-4*HK*HK

      CALL R8INIR(NDDL,0.D0,VECT,1)

C - EXTRACTION DES CHAMPS
      DO 10 NA = 1,NNO1
        DO 11 IA = 1,NDIM
          DEPLM(IA+NDIM*(NA-1)) = DDL(VU(IA,NA))
 11     CONTINUE
 10   CONTINUE

      DO 40 SA = 1,NNO2
        PRESM(SA) = DDL(VP(SA))
 40   CONTINUE

      DO 31 RA = 1,NNO3
        DO 32 IA = 1,NDIM
          GPRESM(IA+NDIM*(RA-1)) = DDL(VPI(IA,RA))
 32     CONTINUE
 31   CONTINUE

C - CALCUL POUR CHAQUE POINT DE GAUSS
      DO 1000 G = 1,NPG

C - CALCUL DES ELEMENTS GEOMETRIQUES
        CALL R8INIR(6, 0.D0, EPSM,1)
        CALL DFDMIP(NDIM,NNO1,AXI,GEOMI,G,IW,VFF1(1,G),IDFF1,R,W,DFF1)
        CALL NMEPSI(NDIM,NNO1,AXI,GRAND,VFF1(1,G),R,DFF1,DEPLM,FM,EPSM)

C - CALCUL DE LA PRESSION
        PM = DDOT(NNO2,VFF2(1,G),1,PRESM,1)

C - CALCUL DU GRADIENT DE PRESSION ET DU GRADIENT DE PRESSION PROJETE
        DO 20 IA = 1,NDIM
          PIM(IA) = DDOT(NNO3,VFF3(1,G),1,GPRESM(IA),NDIM)
          GPM(IA) = DDOT(NNO2,DFF1(1,IA),1,PRESM,1)
 20     CONTINUE

C - CALCUL DES ELEMENTS GEOMETRIQUES
        DIVUM = EPSM(1) + EPSM(2) + EPSM(3)

C - CALCUL DE LA MATRICE B EPS_ij=B_ijkl U_kl
C - DEF (XX,YY,ZZ,2/RAC(2)XY,2/RAC(2)XZ,2/RAC(2)YZ)
        IF (NDIM.EQ.2) THEN
          DO 35 NA=1,NNO1
            DO 45 IA=1,NDIM
             DEF(1,NA,IA)= FM(IA,1)*DFF1(NA,1)
             DEF(2,NA,IA)= FM(IA,2)*DFF1(NA,2)
             DEF(3,NA,IA)= 0.D0
             DEF(4,NA,IA)=(FM(IA,1)*DFF1(NA,2)+FM(IA,2)*DFF1(NA,1))/RAC2
 45         CONTINUE
 35       CONTINUE

C - TERME DE CORRECTION (3,3) AXI QUI PORTE EN FAIT SUR LE DDL 1
          IF (AXI) THEN
            DO 47 NA=1,NNO1
              DEF(3,NA,1) = FM(3,3)*VFF1(NA,G)/R
 47         CONTINUE
          END IF
        ELSE
          DO 36 NA=1,NNO1
            DO 46 IA=1,NDIM
             DEF(1,NA,IA)= FM(IA,1)*DFF1(NA,1)
             DEF(2,NA,IA)= FM(IA,2)*DFF1(NA,2)
             DEF(3,NA,IA)= FM(IA,3)*DFF1(NA,3)
             DEF(4,NA,IA)=(FM(IA,1)*DFF1(NA,2)+FM(IA,2)*DFF1(NA,1))/RAC2
             DEF(5,NA,IA)=(FM(IA,1)*DFF1(NA,3)+FM(IA,3)*DFF1(NA,1))/RAC2
             DEF(6,NA,IA)=(FM(IA,2)*DFF1(NA,3)+FM(IA,3)*DFF1(NA,2))/RAC2
 46         CONTINUE
 36       CONTINUE
        ENDIF

C - CALCUL DES CONTRAINTES MECANIQUES A L'EQUILIBRE
        DO 50 IA = 1,3
          SIGMA(IA) = SIG(IA,G)
 50     CONTINUE
        DO 65 IA = 4,2*NDIM
          SIGMA(IA) = SIG(IA,G)*RAC2
 65     CONTINUE

C - CALCUL DE L'INVERSE DE KAPPA
        CALL TANBUL(OPTION,NDIM,G,MATE,COMPOR,.FALSE.,.FALSE.,ALPHA,
     &              DSBDEP,TREPST)

C - VECTEUR FINT:U
        DO 300 NA = 1,NNO1
          DO 310 IA = 1,NDIM
            KK = VU(IA,NA)
            T1 = DDOT(2*NDIM, SIGMA,1, DEF(1,NA,IA),1)
            VECT(KK) = VECT(KK) + W*T1
 310      CONTINUE
 300    CONTINUE

C - VECTEUR FINT:P
        T2 = (DIVUM-PM*ALPHA)
        DO 370 SA = 1,NNO2
          KK = VP(SA)
          T1 = 0.D0
C - PRODUIT SCALAIRE DE GRAD FONC DE FORME DE P ET GRAD P OU FONC DE PI
          DO 375 IA = 1,NDIM
            T1 = T1 + DFF1(SA,IA)*(GPM(IA)-PIM(IA))
 375      CONTINUE
          T1 = VFF2(SA,G)*T2 - STAB*T1
          VECT(KK) = VECT(KK) + W*T1
 370    CONTINUE

C - VECTEUR FINT:PI
        DO 380 RA = 1,NNO3
          DO 385 IA = 1,NDIM
              KK = VPI(IA,RA)
              T1 = STAB*VFF3(RA,G)*(GPM(IA)-PIM(IA))
              VECT(KK) = VECT(KK) + W*T1
 385      CONTINUE
 380    CONTINUE
 1000 CONTINUE

      END
