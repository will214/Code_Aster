      SUBROUTINE TE0300(OPTION,NOMTE)
      IMPLICIT   NONE
      CHARACTER*16 OPTION,NOMTE
C.......................................................................
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 26/01/2004   AUTEUR VABHHTS J.PELLET 
C ======================================================================
C COPYRIGHT (C) 1991 - 2001  EDF R&D                  WWW.CODE-ASTER.ORG
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

C      CALCUL DES COEFFICIENTS DE CONTRAINTES K1 ET K2
C      BORDS ELEMENTS ISOPARAMETRIQUES 2D AVEC CHARGEMENT DE BORD
C      PRESSION-CISAILLEMENT ET FORCE REPARTIE

C      OPTION : 'CALC_K_G'    (CHARGES REELLES)
C               'CALC_K_G_F'  (CHARGES FONCTIONS)

C ENTREES  ---> OPTION : OPTION DE CALCUL
C          ---> NOMTE  : NOM DU TYPE ELEMENT

C VECTEURS DIMENSIONNES POUR  NNO = 3 , NPG = 4
C.......................................................................
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

      INTEGER NNO,NNOS,JGANO,NDIM,NPG,KP,COMPT,I,J,K
      INTEGER IDEPL,IFIC,IFOND,IFORC,IMATE,IPRES,ITHET
      INTEGER ITEMPE,ITREF,IPOIDS,IVF,IDFDK,IGEOM,ITEMPS
      INTEGER IFORF,IPREF,ICODE

      REAL*8 DEPI,R8DEPI,EPS,VALRES(3),DEVRES(3),VALPAR(3)
      REAL*8 TCLA,TCLA1,TCLA2,U1S(2),U2S(2),V1S(2),V2S(2),UX,UY
      REAL*8 VF,DFDE,DXDE,DYDE,DSDE,POIDS,DTHXDE,DTHYDE,THX,THY
      REAL*8 G,K1,K2,FX,FY,PRES,CISA,DIVTHE,TPG,CPHI,CPHI2
      REAL*8 XA,YA,XGA,YGA,XG,YG,RPOL,XNORM,YNORM,NORM,PHI
      REAL*8 CPK,DPK,CK,COEFK,DCOEFK,CCOEFK,CFORM,CR2,SPHI2
      REAL*8 THE,DFXDE,DFYDE,PRESNO,CISANO,FXNO,FYNO,R8PREM
C                                            2*NNO     2*NNO
      REAL*8 PRESG(2),FORCG(2),PRESN(6),FORCN(6)

      CHARACTER*2 CODRET(3)
      CHARACTER*8 NOMRES(3),NOMPAR(3),ELREFE

      LOGICAL FONC
C.......................................................................

      CALL ELREF1(ELREFE)
      CALL JEMARQ()
      EPS = R8PREM()
      DEPI = R8DEPI()


      CALL ELREF4(' ','RIGI',NDIM,NNO,NNOS,NPG,IPOIDS,IVF,IDFDK,JGANO)



      CALL JEVECH('PGEOMER','L',IGEOM)
      CALL JEVECH('PMATERC','L',IMATE)
      CALL JEVECH('PDEPLAR','L',IDEPL)
      CALL JEVECH('PTHETAR','L',ITHET)
      CALL JEVECH('PTEREF','L',ITREF)
      CALL JEVECH('PTEMPER','L',ITEMPE)
      CALL JEVECH('PFISSR','L',IFOND)
      IF (OPTION.EQ.'CALC_K_G_F') THEN
        FONC = .TRUE.
        CALL JEVECH('PFF1D2D','L',IFORF)
        CALL JEVECH('PPRESSF','L',IPREF)
        CALL JEVECH('PTEMPSR','L',ITEMPS)
        NOMPAR(1) = 'X'
        NOMPAR(2) = 'Y'
        NOMPAR(3) = 'INST'
        VALPAR(3) = ZR(ITEMPS)
      ELSE
        FONC = .FALSE.
        CALL JEVECH('PFR1D2D','L',IFORC)
        CALL JEVECH('PPRESSR','L',IPRES)
      END IF
      CALL JEVECH('PGTHETA','E',IFIC)

      NOMRES(1) = 'E'
      NOMRES(2) = 'NU'
      NOMRES(3) = 'ALPHA'
      XA = ZR(IFOND)
      YA = ZR(IFOND+1)
      XNORM = ZR(IFOND+2)
      YNORM = ZR(IFOND+3)
      NORM = SQRT(XNORM*XNORM+YNORM*YNORM)

      TCLA = 0.D0
      TCLA1 = 0.D0
      TCLA2 = 0.D0

C PAS DE CALCUL DE G POUR LES ELEMENTS OU LA VALEUR DE THETA EST NULLE

      COMPT = 0
      DO 10 I = 1,NNO
        THX = ZR(ITHET+2* (I-1))
        THY = ZR(ITHET+2* (I-1)+1)
        IF ((ABS(THX).LT.EPS) .AND. (ABS(THY).LT.EPS)) THEN
          COMPT = COMPT + 1
        END IF
   10 CONTINUE
      IF (COMPT.EQ.NNO) GO TO 110

C - SI CHARGE FONCTION RECUPERATION DES VALEURS AUX PG ET NOEUDS

      IF (FONC) THEN
        DO 40 I = 1,NNO
          DO 20 J = 1,2
            VALPAR(J) = ZR(IGEOM+2* (I-1)+J-1)
   20     CONTINUE
          DO 30 J = 1,2
            CALL FOINTE('FM',ZK8(IPREF+J-1),3,NOMPAR,VALPAR,
     &                  PRESN(2* (I-1)+J),ICODE)
            CALL FOINTE('FM',ZK8(IFORF+J-1),3,NOMPAR,VALPAR,
     &                  FORCN(2* (I-1)+J),ICODE)
   30     CONTINUE
   40   CONTINUE
      END IF

C --- BOUCLE SUR LES POINTS DE GAUSS

      DO 100 KP = 1,NPG
        K = (KP-1)*NNO
        XG = 0.D0
        YG = 0.D0
        DXDE = 0.D0
        DYDE = 0.D0
        UX = 0.D0
        UY = 0.D0
        THX = 0.D0
        DFXDE = 0.D0
        DFYDE = 0.D0
        DTHXDE = 0.D0
        DTHYDE = 0.D0
        DIVTHE = 0.D0
        TPG = 0.D0

        DO 50 I = 1,NNO
          VF = ZR(IVF+K+I-1)
          DFDE = ZR(IDFDK+K+I-1)
          XG = XG + ZR(IGEOM+2* (I-1))*ZR(IVF+K+I-1)
          YG = YG + ZR(IGEOM+2* (I-1)+1)*ZR(IVF+K+I-1)
          TPG = TPG + ZR(ITEMPE+I-1)*ZR(IVF+K+I-1)
          DXDE = DXDE + DFDE*ZR(IGEOM+2* (I-1))
          DYDE = DYDE + DFDE*ZR(IGEOM+2* (I-1)+1)
          UX = UX + VF*ZR(IDEPL+2* (I-1))
          UY = UY + VF*ZR(IDEPL+2* (I-1)+1)
          THX = THX + VF*ZR(ITHET+2* (I-1))
          THY = THY + VF*ZR(ITHET+2* (I-1)+1)
          DTHXDE = DTHXDE + DFDE*ZR(ITHET+2* (I-1))
          DTHYDE = DTHYDE + DFDE*ZR(ITHET+2* (I-1)+1)
   50   CONTINUE

        IF (FONC) THEN
          VALPAR(1) = XG
          VALPAR(2) = YG
          DO 60 J = 1,2
            CALL FOINTE('FM',ZK8(IPREF+J-1),3,NOMPAR,VALPAR,PRESG(J),
     &                  ICODE)
            CALL FOINTE('FM',ZK8(IFORF+J-1),3,NOMPAR,VALPAR,FORCG(J),
     &                  ICODE)
   60     CONTINUE
        ELSE
          PRESG(1) = 0.D0
          PRESG(2) = 0.D0
          FORCG(1) = 0.D0
          FORCG(2) = 0.D0
          DO 80 I = 1,NNO
            DO 70 J = 1,2
              PRESG(J) = PRESG(J) + ZR(IPRES+2* (I-1)+J-1)*ZR(IVF+K+I-1)
              FORCG(J) = FORCG(J) + ZR(IFORC+2* (I-1)+J-1)*ZR(IVF+K+I-1)
   70       CONTINUE
   80     CONTINUE
        END IF

        CALL RCVADA(ZI(IMATE),'ELAS',TPG,3,NOMRES,VALRES,DEVRES,CODRET)
        IF ((CODRET(1).NE.'OK') .OR. (CODRET(2).NE.'OK')) THEN
          CALL UTMESS('F','TE0300','IL FAUT AFFECTER LES ELEMENTS DE '//
     &                ' BORD (E ET NU) POUR LE CALCUL DES FIC')
        END IF
        IF (CODRET(3).NE.'OK') THEN
          VALRES(3) = 0.D0
          DEVRES(3) = 0.D0
        END IF

        DPK = 3.D0 - 4.D0*VALRES(2)
        CPK = (3.D0-VALRES(2))/ (1.D0+VALRES(2))
        CFORM = (1.D0+VALRES(2))/ (SQRT(DEPI)*VALRES(1))
        DCOEFK = VALRES(1)/ (1.D0-VALRES(2)*VALRES(2))
        CCOEFK = VALRES(1)

        IF (NOMTE(3:4).EQ.'DP') THEN
          CK = DPK
          COEFK = DCOEFK
        ELSE
          CK = CPK
          COEFK = CCOEFK
        END IF

        TPG = TPG - ZR(ITREF)

C   INTRODUCTION DES DEPLACEMENTS SINGULIERS ET DE LEURS DERIVEES
C   A        POINT EN FOND DE FISSURE
C   RPOL,PHI COORDONNEES POLAIRES DU POINT DE GAUSS

        XGA = XG - XA
        YGA = YG - YA
        XG = (YNORM*XGA-XNORM*YGA)/NORM
        YG = (XNORM*XGA+YNORM*YGA)/NORM

        RPOL = SQRT(XG*XG+YG*YG)
        PHI = ATAN2(YG,XG)
        CPHI = COS(PHI)
        CPHI2 = COS(0.5D0*PHI)
        SPHI2 = SIN(0.5D0*PHI)
        CR2 = CFORM*SQRT(RPOL)

C    U1 SINGULIER POUR LE CALCUL DE K1

        V1S(1) = CR2* (CK-CPHI)*CPHI2
        V1S(2) = CR2* (CK-CPHI)*SPHI2
        U1S(1) = (YNORM*V1S(1)+XNORM*V1S(2))/NORM
        U1S(2) = (-XNORM*V1S(1)+YNORM*V1S(2))/NORM


C    U2 SINGULIER POUR LE CALCUL DE K2

        V2S(1) = CR2* (2.D0+CK+CPHI)*SPHI2
        V2S(2) = CR2* (2.D0-CK-CPHI)*CPHI2
        U2S(1) = (YNORM*V2S(1)+XNORM*V2S(2))/NORM
        U2S(2) = (-XNORM*V2S(1)+YNORM*V2S(2))/NORM

        DSDE = SQRT(DXDE**2+DYDE**2)

        PRES = PRESG(1)
        CISA = PRESG(2)
        FX = FORCG(1) - (DYDE*PRES-DXDE*CISA)/DSDE
        FY = FORCG(2) + (DXDE*PRES+DYDE*CISA)/DSDE

        IF (FONC) THEN
          DO 90 I = 1,NNO
            DFDE = ZR(IDFDK+K+I-1)
            PRESNO = PRESN(2* (I-1)+1)
            CISANO = PRESN(2* (I-1)+2)
            FXNO = FORCN(2* (I-1)+1) - (DYDE*PRESNO-DXDE*CISANO)/DSDE
            FYNO = FORCN(2* (I-1)+2) + (DXDE*PRESNO+DYDE*CISANO)/DSDE
            DFXDE = DFXDE + DFDE*FXNO
            DFYDE = DFYDE + DFDE*FYNO
   90     CONTINUE
        END IF

        POIDS = ZR(IPOIDS+KP-1)
        THE = (THX*DXDE+THY*DYDE)/DSDE
        DIVTHE = (DTHXDE*DXDE+DTHYDE*DYDE)/DSDE

        TCLA1 = TCLA1 + POIDS* ((DIVTHE*FX+DFXDE*THE)*U1S(1)+
     &          (DIVTHE*FY+DFYDE*THE)*U1S(2))
        TCLA2 = TCLA2 + POIDS* ((DIVTHE*FX+DFXDE*THE)*U2S(1)+
     &          (DIVTHE*FY+DFYDE*THE)*U2S(2))
        TCLA = TCLA + POIDS* ((DIVTHE*FX+DFXDE*THE)*UX+
     &         (DIVTHE*FY+DFYDE*THE)*UY)

  100 CONTINUE

      G = TCLA
      K1 = TCLA1*COEFK/2.D0
      K2 = TCLA2*COEFK/2.D0

      ZR(IFIC) = G
      ZR(IFIC+1) = K1/SQRT(COEFK)
      ZR(IFIC+2) = K2/SQRT(COEFK)
      ZR(IFIC+3) = K1
      ZR(IFIC+4) = K2

  110 CONTINUE
      CALL JEDEMA()
      END
