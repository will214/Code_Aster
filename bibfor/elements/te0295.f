      SUBROUTINE TE0295(OPTION,NOMTE)

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 30/03/2004   AUTEUR CIBHHLV L.VIVAN 
C ======================================================================
C COPYRIGHT (C) 1991 - 2004  EDF R&D                  WWW.CODE-ASTER.ORG
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

      IMPLICIT NONE

C ----------------------------------------------------------------------
C FONCTION REALISEE:  CALCUL DES FACTEURS D'INTENSIT�S DE CONTRAINTES
C                     A PARTIR DE LA FORME BILINEAIRE SYMETRIQUE G ET
C                      DES DEPLACMENTS SINGULIERS EN FOND DE FISSURE

C    - ARGUMENTS:
C        DONNEES:      OPTION       -->  OPTION DE CALCUL
C                      NOMTE        -->  NOM DU TYPE ELEMENT
C.......................................................................
C
      CHARACTER*2  CODRET(3)
      CHARACTER*8  NOMRES(3)
      CHARACTER*16 NOMTE,OPTION,PHENOM, COMPOR(4)
C
      REAL*8   EPSI,DEPI,R8DEPI,R8PREM,PREC
      REAL*8   DFDI(24),F(3,3),EPS(6),FNO(81),E1(3),E2(3),E3(3)
      REAL*8   DUDM(3,3),DFDM(3,3),DTDM(3,3),DER(4),AG(3),VGL(3)
      REAL*8   U1L(3),U2L(3),U3L(3)
      REAL*8   DU1DM(3,3),DU2DM(3,3),DU3DM(3,3)
      REAL*8   DU1DPO(3,2),DU2DPO(3,2),DU3DPO(3,2),P(3,3),INVP(3,3)
      REAL*8   DU1DL(3,3),DU2DL(3,3),DU3DL(3,3),COURB(3,3,3)
      REAL*8   RHO,OM,OMO,RBID,E,NU,ALPHA
      REAL*8   THET,TG,TGDM(3),TTRG,LA,MU, KA
      REAL*8   XG,YG,ZG,A(3)
      REAL*8   PHI,CPHI,C2PHI,CPHI2,SPHI2
      REAL*8   C1,C2,C3,CS, X, Y, Z, W, XLG, YLG, RG, PHIG
      REAL*8   TH,VALRES(3),DEVRES(3)
      REAL*8   CK,COEFF,COEFF3,CFORM,CR1,CR2
      REAL*8   GUV,GUV1,GUV2,GUV3,K1,K2,K3,G,POIDS
      REAL*8   RPIPO,T1PIPO(6),T2PIPO(2),T3PIPO(6)
      REAL*8   TCLA,NORME
      REAL*8   EPSINO(162)
C
      INTEGER  IPOIDS,IVF,IDFDE,NNO,KP,NPG,COMPT,IER, NNOS, IDEPI
      INTEGER  JGANO,IRET,IEPSR,IEPSF,ICOMP,ISIGI,IBALO,ICOUR
      INTEGER  IGEOM,ITHET, IGTHET, IROTA,IPESA,IFIC,IDEPL,ITREF,ITEMP
      INTEGER  IMATE,IFORC,IFORF,ITEMPS,JIN,JVAL,K,I,J,KK,L,NDIM
      INTEGER  SII, SJJ

      LOGICAL  LPIPO, EPSINI, GRAND,PBINV,LCOUR

C---------------- COMMUNS NORMALISES  JEVEUX  --------------------------
      COMMON /IVARJE/ZI(1)
      COMMON /RVARJE/ZR(1)
      COMMON /CVARJE/ZC(1)
      COMMON /LVARJE/ZL(1)
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
      INTEGER ZI
      REAL*8 ZR
      COMPLEX*16 ZC
      LOGICAL ZL
      CHARACTER*8 ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
C------------FIN  COMMUNS NORMALISES  JEVEUX  --------------------------

C DEB ------------------------------------------------------------------

      CALL JEMARQ()
      EPSI = R8PREM()
      DEPI=R8DEPI()
      EPSINI = .FALSE.

      CALL ELREF4(' ','RIGI',NDIM,NNO,NNOS,NPG,IPOIDS,IVF,IDFDE,JGANO)

      CALL JEVECH('PGEOMER','L',IGEOM)
      CALL JEVECH('PDEPLAR','L',IDEPL)
      CALL JEVECH('PTHETAR','L',ITHET)
      CALL JEVECH('PMATERC','L',IMATE)
      CALL JEVECH('PTEMPER','L',ITEMP)
      CALL JEVECH('PTEREF','L',ITREF)
      CALL JEVECH('PCOMPOR','L',ICOMP)
      CALL JEVECH('PBASLOR','L',IBALO)
      CALL JEVECH('PCOURB','L',ICOUR)
      CALL JEVECH('PGTHETA','E',IGTHET)

      G = 0.D0
      K1= 0.D0
      K2= 0.D0
      K3= 0.D0
      COEFF=1.D0
      COEFF3=1.D0

C - PAS DE CALCUL DE G POUR LES ELEMENTS OU LA VALEUR DE THETA EST NULLE
      COMPT = 0
      DO 10 I = 1,NNO
        THET = 0.D0
        DO 11 J = 1,NDIM
          THET = THET + ABS(ZR(ITHET+NDIM*(I-1)+J-1))
 11     CONTINUE
        IF (THET.LT.EPSI) COMPT = COMPT + 1
 10   CONTINUE
      IF (COMPT.EQ.NNO) THEN
        GOTO 9999
      ENDIF


      CALL JEVECH('PFRVOLU','L',IFORC)
      CALL TECACH('ONN','PEPSINR',1,IEPSR,IRET)
      IF (IEPSR.NE.0) EPSINI = .TRUE.

      DO 20 I = 1,4
        COMPOR(I) = ZK16(ICOMP+I-1)
 20   CONTINUE

       IF ((COMPOR(3) (1:5) .EQ. 'GREEN')
     &    .OR. (COMPOR(4) (1:9) .EQ. 'COMP_INCR')) THEN
       CALL UTMESS('F','CALC_K_G','CALC_K_G EST INCOMPATIBLE AVEC
     &       LES COMPORTEMENTS INCREMENTAUX AINSI QUE LA DEFORMATION
     &              GREEN')
       END IF

      CALL TECACH('ONN','PPESANR',1,IPESA,IRET)
      CALL TECACH('ONN','PROTATR',1,IROTA,IRET)
      CALL TECACH('ONN','PSIGINR',1,ISIGI,IRET)
      CALL TECACH('ONN','PDEPINR',1,IDEPI,IRET)

      IF ((ISIGI.NE.0) .AND. EPSINI) THEN
        CALL UTMESS('F','CALC_G','UNE DEFORMATION INITIALE EST '//
     &       'PRESENTE DANS LA CHARGE : INCOMPATIBLE AVEC LA CONTRAINTE'
     &              //' INITIALE SIGMA_INIT')
      END IF

      NOMRES(1) = 'E'
      NOMRES(2) = 'NU'

C - RECUPERATION DES CHARGES ET DEFORMATIONS INITIALES ----------------
C
      IF ((IPESA.NE.0).OR.(IROTA.NE.0)) THEN
        CALL RCCOMA(ZI(IMATE),'ELAS',PHENOM,CODRET)
        CALL RCVALA(ZI(IMATE),PHENOM,1,' ',RBID,1,'RHO',RHO,CODRET,'FM')
        IF (IPESA.NE.0) THEN
          DO 60 I=1,NNO
            DO 61 J=1,NDIM
              KK = NDIM*(I-1)+J
              FNO(KK)=FNO(KK)+RHO*ZR(IPESA)*ZR(IPESA+J)
 61         CONTINUE
 60       CONTINUE
        ENDIF
        IF (IROTA.NE.0) THEN
          OM = ZR(IROTA)
          DO 70 I=1,NNO
            OMO = 0.D0
            DO 71 J=1,NDIM
              OMO = OMO + ZR(IROTA+J)* ZR(IGEOM+NDIM*(I-1)+J-1)
 71        CONTINUE
            DO 72 J=1,NDIM
              KK = NDIM*(I-1)+J
              FNO(KK)=FNO(KK)+RHO*OM*OM*(ZR(IGEOM+KK-1)-OMO*ZR(IROTA+J))
 72         CONTINUE
 70       CONTINUE
        ENDIF
      ENDIF

C-----------------------------------------------------------------------
C     BOUCLE SUR LES POINTS DE GAUSS
      DO 100 KP=1,NPG

        L  = (KP-1)*NNO
        XG = 0.D0
        YG = 0.D0
        ZG = 0.D0
        DO 110 I=1,3
          DO 111 J=1,3
            DUDM(I,J) = 0.D0
            DU1DL(I,J)= 0.D0
            DU2DL(I,J)= 0.D0
            DU3DL(I,J)= 0.D0
            DU1DM(I,J)= 0.D0
            DU2DM(I,J)= 0.D0
            DU3DM(I,J)= 0.D0
            DTDM(I,J) = 0.D0
 111      CONTINUE
 110    CONTINUE

C   CALCUL DES ELEMENTS CINEMATIQUES (MATRICES F ET E) EN UN PT DE GAUSS

        CALL NMGEOM (NDIM,NNO,.FALSE.,.FALSE.,ZR(IGEOM),KP,
     &               IPOIDS,IVF,IDFDE,
     &               ZR(IDEPL),POIDS,DFDI,F,EPS,RBID)

C - CALCULS DES GRADIENTS DE U (DUDM),THETA (DTDM) ET FORCE(DFDM)
C   DE LA TEMPERATURE AUX POINTS DE GAUSS (TG) ET SON GRADIENT (TGDM)
C
        DO 120 I=1,NNO
          DER(1) = DFDI(I)
          DER(2) = DFDI(I+NNO)
          DER(3) = DFDI(I+2*NNO)
          DER(4) = ZR(IVF+L+I-1)

          XG = XG + ZR(IGEOM-1+NDIM*(I-1)+1)*DER(4)
          YG = YG + ZR(IGEOM-1+NDIM*(I-1)+2)*DER(4)
          ZG = ZG + ZR(IGEOM-1+NDIM*(I-1)+3)*DER(4)

          DO 121 J=1,NDIM
            DO 122 K=1,NDIM
              DUDM(J,K) = DUDM(J,K) + ZR(IDEPL+NDIM*(I-1)+J-1)*DER(K)
              DTDM(J,K) = DTDM(J,K) + ZR(ITHET+NDIM*(I-1)+J-1)*DER(K)
122         CONTINUE
121       CONTINUE
120     CONTINUE

C       RECUPEATION DES DONNEES MATERIAUX
        CALL RCVADA (ZI(IMATE),'ELAS',TG,2,NOMRES,VALRES,DEVRES,
     &               CODRET)
        IF (CODRET(3).NE.'OK') THEN
          VALRES(3)= 0.D0
          DEVRES(3)= 0.D0
        ENDIF
        E     = VALRES(1)
        NU    = VALRES(2)

        LA = NU*E/((1.D0+NU)*(1.D0-2.D0*NU))
        MU = E/(2.D0*(1.D0+NU))
C       EN DP
        KA=3.D0-4.D0*NU
        COEFF=E/(1.D0-NU*NU)
        COEFF3=2.D0 * MU
C       EN CP
C       KA=(3.D0-NU)/(1.D0+NU)
C       COEFF=E
C       COEFF3=2.D0 * MU

        C1 = LA + 2.D0 * MU
        C2 = LA
        C3 = MU

C       RECUPERATION DE LA BASE LOCALE ASSOCI�E AU PT KP
C       (A,E1=GRLT,E2=GRLN,E3=E1^E2)
        DO 123 I=1,3
           A(I)  = ZR(IBALO-1+9*(KP-1)+I)
           E1(I) = ZR(IBALO-1+9*(KP-1)+I+3)
           E2(I) = ZR(IBALO-1+9*(KP-1)+I+6)
 123    CONTINUE
C       NORMALISATION DE LA BASE
        CALL NORMEV(E1,NORME)
        CALL NORMEV(E2,NORME)
        CALL PROVEC(E1,E2,E3)

C       CALCUL DE LA MATRICE DE PASSAGE P TQ 'GLOBAL' = P * 'LOCAL'
        DO 124 I=1,3
          P(I,1)=E1(I)
          P(I,2)=E2(I)
          P(I,3)=E3(I)
 124    CONTINUE

C       CALCUL DE L'INVERSE DE LA MATRICE DE PASSAGE : INV=TRANSPOSE(P)
        DO 125 I=1,3
          DO 126 J=1,3
            INVP(I,J)=P(J,I)
 126      CONTINUE
 125    CONTINUE

C       RECUPERATION DU TENSEUR DE COURBURE
        DO 127 I=1,3
          DO 128 J=1,3
            COURB(I,1,J)=ZR(ICOUR-1+3*(I-1)+J)
            COURB(I,2,J)=ZR(ICOUR-1+3*(I+3-1)+J)
            COURB(I,3,J)=ZR(ICOUR-1+3*(I+6-1)+J)

 128      CONTINUE
 127    CONTINUE
C       PRISE EN COMPTE DE LA COURBURE
        LCOUR=.TRUE.

C       COORDONN�ES DE G DANS LA BASE LOCALE
        AG(1)=XG-A(1)
        AG(2)=YG-A(2)
        AG(3)=ZG-A(3)
        CALL PMAVEC('ZERO',3,INVP,AG,VGL)
        XLG=VGL(1)
        YLG=VGL(2)
        IF (ABS(VGL(3)).GT.3.0D-2) THEN
          WRITE(6,*)'ZG :',VGL
          CALL UTMESS('A','TE0295','ZG NON NUL !!')
        ENDIF

C       COORDONN�ES POLAIRES DE G
        RG=SQRT(XLG*XLG+YLG*YLG)
        PHIG=ATAN2(YLG,XLG)

C       SI R EST NUL (POINT DE GAUSS SUR LE FONFIS)
        IF(RG.LT.1.0D-9) THEN
          CALL UTMESS('A','TE0295','POINT DE GAUSS SUR FOND_FISS')
          RG=1.0D-9
        ENDIF

C       COEFFS  DE CALCUL
        CR1=1.D0/(4.D0*MU*SQRT(DEPI*RG))
        CR2=SQRT(RG)/(2.D0*MU*SQRT(DEPI))

C-----------------------------------------------------------------------
C       D�FINITION DU CHAMP SINGULIER AUXILIAIRE U1 ET SA D�RIV�E
C-----------------------------------------------------------------------
C       CHAMP SINGULIER AUXILIAIRE U1 DANS LA BASE LOCALE
        U1L(1)=CR2*COS(PHIG*0.5D0)*(KA-COS(PHIG))
        U1L(2)=CR2*SIN(PHIG*0.5D0)*(KA-COS(PHIG))
        U1L(3)=0.D0

C       MATRICE DES D�RIV�ES DE U1 DANS LA BASE POLAIRE (3X2)
        DU1DPO(1,1)=CR1*(COS(PHIG*0.5D0)*(KA-COS(PHIG)))
        DU1DPO(2,1)=CR1*(SIN(PHIG*0.5D0)*(KA-COS(PHIG)))
        DU1DPO(3,1)=0.D0
        DU1DPO(1,2)=CR2*(-0.5D0*SIN(PHIG*0.5D0)*(KA-COS(PHIG))
     &                                 + COS(PHIG*0.5D0)*SIN(PHIG))
        DU1DPO(2,2)=CR2*(0.5D0*COS(PHIG*0.5D0)*(KA-COS(PHIG))
     &                                 + SIN(PHIG*0.5D0)*SIN(PHIG))
        DU1DPO(3,2)=0.D0

C       MATRICE DES D�RIV�ES DE U1 DANS LA BASE LOCALE (3X3)
        DO 140 I=1,3
          DU1DL(I,1)=COS(PHIG)*DU1DPO(I,1)-SIN(PHIG)/RG*DU1DPO(I,2)
          DU1DL(I,2)=SIN(PHIG)*DU1DPO(I,1)+COS(PHIG)/RG*DU1DPO(I,2)
          DU1DL(I,3)=0.D0
 140    CONTINUE

C       MATRICE DES D�RIV�ES DE U1 DANS LA BASE GLOBALE (3X3)
        DO 141 I=1,NDIM
          DO 142 J=1,NDIM
            DO 143 K=1,NDIM
              DO 144 L=1,NDIM
                DU1DM(I,J)=DU1DM(I,J)+DU1DL(K,L)*INVP(L,J)*INVP(K,I)
 144          CONTINUE
C             PRISE EN COMPTE DE LA BASE MOBILE
              IF (LCOUR) DU1DM(I,J)=DU1DM(I,J)+U1L(K)*COURB(K,I,J)
 143        CONTINUE
 142      CONTINUE
 141    CONTINUE

C-----------------------------------------------------------------------
C       D�FINITION DU CHAMP SINGULIER AUXILIAIRE U2 ET SA D�RIV�E
C-----------------------------------------------------------------------
C       CHAMP SINGULIER AUXILIAIRE U2 DANS LA BASE LOCALE
        U2L(1)=CR2*SIN(PHIG*0.5D0)*(KA+2.D0+COS(PHIG))
        U2L(2)=CR2*(-1.D0)*COS(PHIG*0.5D0)*(KA+2.D0+COS(PHIG))
        U2L(3)=0.D0

C       MATRICE DES D�RIV�ES DE U2 DANS LA BASE POLAIRE (3X2)
        DU2DPO(1,1)=CR1*(SIN(PHIG*0.5D0)*(KA+2.D0+COS(PHIG)))
        DU2DPO(2,1)=CR1*(-COS(PHIG*0.5D0)*(KA-2.D0+COS(PHIG)))
        DU2DPO(3,1)=0.D0
        DU2DPO(1,2)=CR2*(0.5D0*COS(PHIG*0.5D0)*(KA+2.D0+COS(PHIG))
     &                                 - SIN(PHIG*0.5D0)*SIN(PHIG))
        DU2DPO(2,2)=CR2*(0.5D0*SIN(PHIG*0.5D0)*(KA-2.D0+COS(PHIG))
     &                                 + COS(PHIG*0.5D0)*SIN(PHIG))
        DU2DPO(3,2)=0.D0

C       MATRICE DES D�RIV�ES DE U2 DANS LA BASE LOCALE (3X3)
        DO 150 I=1,3
          DU2DL(I,1)=COS(PHIG)*DU2DPO(I,1)-SIN(PHIG)/RG*DU2DPO(I,2)
          DU2DL(I,2)=SIN(PHIG)*DU2DPO(I,1)+COS(PHIG)/RG*DU2DPO(I,2)
          DU2DL(I,3)=0.D0
 150    CONTINUE

C       MATRICE DES D�RIV�ES DE U2 DANS LA BASE GLOBALE (3X3)
        DO 151 I=1,NDIM
          DO 152 J=1,NDIM
            DO 153 K=1,NDIM
              DO 154 L=1,NDIM
                DU2DM(I,J)=DU2DM(I,J)+DU2DL(K,L)*INVP(L,J)*INVP(K,I)
 154          CONTINUE
C             PRISE EN COMPTE DE LA BASE MOBILE
              IF (LCOUR) DU2DM(I,J)=DU2DM(I,J)+U2L(K)*COURB(K,I,J)
 153        CONTINUE
 152      CONTINUE
 151    CONTINUE

C-----------------------------------------------------------------------
C       D�FINITION DU CHAMP SINGULIER AUXILIAIRE U3 ET SA D�RIV�E
C-----------------------------------------------------------------------
C       CHAMP SINGULIER AUXILIAIRE U3 DANS LA BASE LOCALE
        U3L(1)=0.D0
        U3L(2)=0.D0
        U3L(3)=4.D0*CR2*SIN(PHIG*0.5D0)

C       MATRICE DES D�RIV�ES DE U3 DANS LA BASE POLAIRE (3X2)
        DU3DPO(1,1)=0.D0
        DU3DPO(2,1)=0.D0
        DU3DPO(1,2)=0.D0
        DU3DPO(2,2)=0.D0
        DU3DPO(3,1)=4.D0*CR1*SIN(PHIG*0.5D0)
        DU3DPO(3,2)=2.D0*CR2*COS(PHIG*0.5D0)

C       MATRICE DES D�RIV�ES DE U3 DANS LA BASE LOCALE (3X3)
        DO 160 I=1,3
          DU3DL(I,1)=COS(PHIG)*DU3DPO(I,1)-SIN(PHIG)/RG*DU3DPO(I,2)
          DU3DL(I,2)=SIN(PHIG)*DU3DPO(I,1)+COS(PHIG)/RG*DU3DPO(I,2)
          DU3DL(I,3)=0.D0
 160    CONTINUE

C       MATRICE DES D�RIV�ES DE U3 DANS LA BASE GLOBALE (3X3)
        DO 161 I=1,NDIM
          DO 162 J=1,NDIM
            DO 163 K=1,NDIM
              DO 164 L=1,NDIM
                DU3DM(I,J)=DU3DM(I,J)+DU3DL(K,L)*INVP(L,J)*INVP(K,I)
 164          CONTINUE
C             PRISE EN COMPTE DE LA BASE MOBILE
              IF (LCOUR) DU3DM(I,J)=DU3DM(I,J)+U3L(K)*COURB(K,I,J)
 163        CONTINUE
 162      CONTINUE
 161    CONTINUE
C-----------------------------------------------------------------------
C       CALCUL DE G, K1, K2, K2 AU POINT DE GAUSS
C-----------------------------------------------------------------------

        GUV=0.D0
        CALL GBIL3D(DUDM,DUDM,DTDM,POIDS,C1,C2,C3,GUV)
        G=G+GUV

        GUV1=0.D0
        CALL GBIL3D(DUDM,DU1DM,DTDM,POIDS,C1,C2,C3,GUV1)
        K1=K1+GUV1

        GUV2=0.D0
        CALL GBIL3D(DUDM,DU2DM,DTDM,POIDS,C1,C2,C3,GUV2)
        K2=K2+GUV2

        GUV3=0.D0
        CALL GBIL3D(DUDM,DU3DM,DTDM,POIDS,C1,C2,C3,GUV3)
        K3=K3+GUV3

100   CONTINUE

9999  CONTINUE

      K1 = K1 * COEFF
      K2 = K2 * COEFF
      K3 = K3 * COEFF3
C
      ZR(IGTHET)    = G
      ZR(IGTHET+1) = K1
      ZR(IGTHET+2) = K2
      ZR(IGTHET+3) = K3

      CALL JEDEMA()

C FIN ------------------------------------------------------------------
      END
