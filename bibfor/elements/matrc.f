      SUBROUTINE MATRC(NNO,KCIS,MATC,VECTT)
C ======================================================================
C            CONFIGURATION MANAGEMENT OF EDF VERSION
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
C MODIF ELEMENTS  DATE 29/08/2005   AUTEUR A3BHHAE H.ANDRIAMBOLOLONA 

      IMPLICIT NONE
      INTEGER NNO
      REAL*8 KCIS,MATC(5,5),VECTT(3,3)

C --------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ---------------------
      INTEGER ZI
      COMMON /IVARJE/ZI(1)
      REAL*8 ZR
      COMMON /RVARJE/ZR(1)
      COMPLEX*16 ZC
      COMMON /CVARJE/ZC(1)
      LOGICAL ZL
      COMMON /LVARJE/ZL(1)
      CHARACTER*8 ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C --------- FIN  DECLARATIONS  NORMALISEES  JEVEUX ---------------------

      REAL*8 VALRES(5),VALPAR
      CHARACTER*2 CODRET(5),DERIVE
      CHARACTER*8 NOMRES(5),NOMPAR
      CHARACTER*10 PHENOM
      CHARACTER*24 OPTION
      REAL*8 YOUNG,NU,NULT,NUTL,ALPHA,R8DGRD,BETA,DX,DY,DZ,PS,R8PREM
      REAL*8 PASSAG(3,3),PAS2(2,2),NORM,DORTH(3,3),WORK(3,3),D(3,3)
      REAL*8 DCIS(2,2),C,S,D2(2,2),TPG1,T,TINF,TSUP,EL,ET,GLT,GTN,DELTA
      REAL*8 PJDX,PJDY,PJDZ
      INTEGER I,J,JMATE,NBV,ITEMP,NBPAR,IBID,IER,IADZI,IAZK24,JCOQU

      DERIVE = '  '
      CALL TECAEL(IADZI,IAZK24)
      OPTION = ZK24(IAZK24-1+3+NNO+2)

      DO 20 I = 1,5
        DO 10 J = 1,5
          MATC(I,J) = 0.D0
   10   CONTINUE
   20 CONTINUE

      CALL JEVECH('PMATERC','L',JMATE)

      CALL DXTEMA(NNO,NBPAR,NOMPAR,VALPAR)

      CALL RCCOMA(ZI(JMATE),'ELAS',PHENOM,CODRET)

      IF (PHENOM.EQ.'ELAS') THEN
        NBV = 2
        NOMRES(1) = 'E'
        NOMRES(2) = 'NU'

C        ------ MATERIAU ISOTROPE --------------------------------------

        IF (OPTION(11:14).EQ.'SENS') THEN

          CALL JEVECH('PMATSEN','L',JMATE)
          CALL RCVALA(ZI(JMATE),' ',PHENOM,NBPAR,NOMPAR,VALPAR,NBV,
     &            NOMRES,VALRES,CODRET,'FM')
          YOUNG = VALRES(1)
          NU = VALRES(2)

C A CE NIVEAU : LA PROCEDURE HABITUELLE DE CALCUL DE SENSIBILITE DONNE :
C   SI : DERIVATION PAR RAPPORT A YOUNG ALORS : YOUNG = 1 ET NU = 0
C   SI : DERIVATION PAR RAPPORT A NU ALORS : YOUNG = 0 ET NU = 1
C ICI, LA FORMULATION DE LA DERIVEE EST PLUS COMPLEXE

          CALL JEVECH('PMATERC','L',JMATE)
          CALL RCVALA(ZI(JMATE),' ',PHENOM,NBPAR,NOMPAR,VALPAR,NBV,
     &            NOMRES,VALRES,CODRET,'FM')
          IF(ABS(NU).LT.R8PREM()) THEN
            DERIVE = 'E'
            NU = VALRES(2)
          ELSE IF(ABS(YOUNG).LT.R8PREM()) THEN
            DERIVE = 'NU'
            YOUNG = VALRES(1)
            NU = VALRES(2)
C ET REFORMULATION DES TERMES DE LA MATRICE (VOIR PLUS BAS)
          END IF
        ELSE

          CALL RCVALA(ZI(JMATE),' ',PHENOM,NBPAR,NOMPAR,VALPAR,NBV,
     &              NOMRES,VALRES,CODRET,'FM')

C ------ MATERIAU ISOTROPE

          YOUNG = VALRES(1)
          NU = VALRES(2)

C POUR LES MATRICES ELEMENTAIRES SENSIBILITE (CALC_MATR_ELEM)
C SANS PASSAGE PAR VECHDE : AFFECTATION FICTIVE DE YOUNG ET NU
C LE CALCUL EFFECTIF DU SECOND MEMBRE SE FERA PAR APPEL A VECHDE
          IF(ABS(NU).LT.R8PREM() .AND. ABS(YOUNG-1.D0).LT.R8PREM())THEN
            DERIVE = 'E'
            YOUNG = 1.D0
            NU = 1.D-1
          ELSEIF(ABS(YOUNG).LT.R8PREM() .AND.
     &              ABS(NU-1.D0).LT.R8PREM())THEN
            DERIVE = 'NU'
            YOUNG = 1.D0
            NU = 1.D-1
          ENDIF

        ENDIF

C ------ CONSTRUCTION DE LA MATRICE DE COMPORTEMENT MATC : (5,5)

        MATC(1,1) = YOUNG/ (1.D0-NU*NU)
        MATC(1,2) = MATC(1,1)*NU
        MATC(2,1) = MATC(1,2)
        MATC(2,2) = MATC(1,1)
        MATC(3,3) = YOUNG/2.D0/ (1.D0+NU)
        MATC(4,4) = MATC(3,3)*KCIS
        MATC(5,5) = MATC(4,4)
        IF(DERIVE(1:2).EQ.'NU') THEN
          MATC(1,1) = YOUNG*2.D0*NU/(1.D0-NU*NU)/(1.D0-NU*NU)
          MATC(1,2) = YOUNG*(1.D0+NU*NU)/(1.D0-NU*NU)/(1.D0-NU*NU)
          MATC(2,1) = MATC(1,2)
          MATC(2,2) = MATC(1,1)
          MATC(3,3) = -YOUNG/2.D0/(1.D0+NU)/(1.D0+NU)
          MATC(4,4) = MATC(3,3)*KCIS
          MATC(5,5) = MATC(4,4)
        ENDIF

      ELSE IF (PHENOM.EQ.'ELAS_ORTH') THEN

        NOMRES(1) = 'E_L'
        NOMRES(2) = 'E_T'
        NOMRES(3) = 'NU_LT'
        NOMRES(4) = 'G_LT'
        NOMRES(5) = 'G_TN'
        NBV = 5

C ----   INTERPOLATION DES COEFFICIENTS EN FONCTION DE LA TEMPERATURE
C ----   ET DU TEMPS
C        -----------
        CALL RCVALA(ZI(JMATE),' ',PHENOM,NBPAR,NOMPAR,VALPAR,NBV,NOMRES,
     &              VALRES,CODRET,'FM')

        EL = VALRES(1)
        ET = VALRES(2)
        NULT = VALRES(3)
        GLT  = VALRES(4)
        GTN  = VALRES(5)
        NUTL  = ET*NULT/EL
        DELTA = 1.D0 - NULT*NUTL
        DORTH(1,1) = EL/DELTA
        DORTH(1,2) = NULT*ET/DELTA
        DORTH(1,3) = 0.D0
        DORTH(2,2) = ET/DELTA
        DORTH(2,1) = DORTH(1,2)
        DORTH(2,3) = 0.D0
        DORTH(3,1) = 0.D0
        DORTH(3,2) = 0.D0
        DORTH(3,3) = GLT

C ---   DETERMINATION DES MATRICE DE PASSAGE DES REPERES INTRINSEQUES
C ---   AUX NOEUDS ET AUX POINTS D'INTEGRATION DE L'ELEMENT
C ---   AU REPERE UTILISATEUR :

C ---   RECUPERATION DES ANGLES DETERMINANT LE REPERE UTILISATEUR
C ---   PAR RAPPORT AU REPERE GLOBAL :

        CALL JEVECH('PCACOQU','L',JCOQU)

        ALPHA = ZR(JCOQU+1)*R8DGRD()
        BETA = ZR(JCOQU+2)*R8DGRD()

C COMPOSANTES DE V VECTEUR UNITAIRE UTILISATEUR DANS LE REPERE GLOBAL

        DX = COS(BETA)*COS(ALPHA)
        DY = COS(BETA)*SIN(ALPHA)
        DZ = SIN(BETA)
        NORM = SQRT(DX*DX+DY*DY+DZ*DZ)
        DX = DX/NORM
        DY = DY/NORM
        DZ = DZ/NORM


C ---   DETERMINATION DE LA PROJECTION DU VECTEUR X DU REPERE
C ---   UTILISATEUR SUR LE FEUILLET TANGENT A LA COQUE AU POINT
C ---   D'INTEGRATION COURANT :
C       PS = V.N

        PS = DX*VECTT(3,1) + DY*VECTT(3,2) + DZ*VECTT(3,3)
        PJDX = DX - PS*VECTT(3,1)
        PJDY = DY - PS*VECTT(3,2)
        PJDZ = DZ - PS*VECTT(3,3)
        NORM = SQRT(PJDX*PJDX+PJDY*PJDY+PJDZ*PJDZ)
        IF (NORM.LE.R8PREM()) THEN
          CALL UTMESS('F','MATRC','L''AXE DE REFERENCE EST NORMAL A'//
     &                ' UN ELEMENT DE PLAQUE - CALCUL OPTION'//
     &                ' IMPOSSIBLE - ORIENTER CES MAILLES')
        END IF

        PJDX = PJDX/NORM
        PJDY = PJDY/NORM
        PJDZ = PJDZ/NORM

        C = PJDX*VECTT(1,1) + PJDY*VECTT(1,2) + PJDZ*VECTT(1,3)
        S = PJDX*VECTT(2,1) + PJDY*VECTT(2,2) + PJDZ*VECTT(2,3)

C ----   TENSEUR D'ELASTICITE DANS LE REPERE INTRINSEQUE :
C ----   D_GLOB = PASSAG_T * D_ORTH * PASSAG

        DO 40 I = 1,3
          DO 30 J = 1,3
            PASSAG(I,J) = 0.D0
   30     CONTINUE
   40   CONTINUE
        PASSAG(1,1) = C*C
        PASSAG(2,2) = C*C
        PASSAG(1,2) = S*S
        PASSAG(2,1) = S*S
        PASSAG(1,3) = C*S
        PASSAG(3,1) = -2.D0*C*S
        PASSAG(2,3) = -C*S
        PASSAG(3,2) = 2.D0*C*S
        PASSAG(3,3) = C*C - S*S
        CALL UTBTAB('ZERO',3,3,DORTH,PASSAG,WORK,D)

        DO 60 I = 1,3
          DO 50 J = 1,3
            MATC(I,J) = D(I,J)
   50     CONTINUE
   60   CONTINUE

        DCIS(1,1) = GLT
        DCIS(1,2) = 0.D0
        DCIS(2,1) = 0.D0
        DCIS(2,2) = GTN
        PAS2(1,1) = C
        PAS2(2,2) = C
        PAS2(1,2) = S
        PAS2(2,1) = -S

        CALL UTBTAB('ZERO',2,2,DCIS,PAS2,WORK,D2)
        DO 80 I = 1,2
          DO 70 J = 1,2
            MATC(3+I,3+J) = D2(I,J)
   70     CONTINUE
   80   CONTINUE

      ELSE
        CALL UTMESS('F','MATRC','COMPORTEMENT MATERIAU NON ADMIS')
      END IF

      END
