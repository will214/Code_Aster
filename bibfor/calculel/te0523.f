      SUBROUTINE TE0523(OPTION,NOMTE)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF CALCULEL  DATE 21/01/2004   AUTEUR CIBHHLV L.VIVAN 
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
C
      IMPLICIT REAL*8 (A-H,O-Z)
C.......................................................................
C     BUT: CALCUL DES MATRICES ELEMENTAIRES EN THERMIQUE
C          CORRESPONDANT AU TERME D'ECHANGE
C          SUR DES FACES D'ELEMENTS ISOPARAMETRIQUES 3D
C             -   PROBLEME  DE  TRANSPORT  -
C
C          OPTION : 'RIGI_THER_COET_R'
C
C     ENTREES  ---> OPTION : OPTION DE CALCUL
C          ---> NOMTE  : NOM DU TYPE ELEMENT
C.......................................................................
C
      CHARACTER*8        ELREFE
      CHARACTER*16       NOMTE,OPTION
      CHARACTER*24       CHVAL,CHCTE
      REAL*8             NX,NY,NZ,SX(9,9),SY(9,9),SZ(9,9),JAC,THETA
      INTEGER            IPOIDS,IVF,IDFDX,IDFDY,IGEOM
      INTEGER            NDIM,NNO,NDI,IPG,NPG1,NPG2,IMATTT,IECH
      INTEGER            IDEC,JDEC,KDEC,LDEC
      INTEGER            NBPG(10),NNOS,JGANO
C
C
C
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
C
      CALL ELREF4(' ','RIGI',NDIM,NNO,NNOS,NPG2,IPOIDS,IVF,IDFDX,JGANO)
      IDFDY  = IDFDX  + 1
C
      NDI = NNO*(NNO+1)/2
C
      CALL JEVECH('PGEOMER','L',IGEOM)
      CALL JEVECH('PCOEFHR','L',IECH)
      CALL JEVECH('PTEMPSR','L',ITEMPS)
      CALL JEVECH('PMATTTR','E',IMATTT)
C
      DO 10 I = 1,NDI
         ZR(IMATTT+I-1) = 0.0D0
10    CONTINUE
C
C    CALCUL DES PRODUITS VECTORIELS OMI X OMJ
C
      DO 1 INO = 1,NNO
        I = IGEOM + 3*(INO-1) -1
          DO 2 JNO = 1,NNO
            J = IGEOM + 3*(JNO-1) -1
              SX(INO,JNO) = ZR(I+2) * ZR(J+3) - ZR(I+3) * ZR(J+2)
              SY(INO,JNO) = ZR(I+3) * ZR(J+1) - ZR(I+1) * ZR(J+3)
              SZ(INO,JNO) = ZR(I+1) * ZR(J+2) - ZR(I+2) * ZR(J+1)
2         CONTINUE
1     CONTINUE
C
C    BOUCLE SUR LES POINTS DE GAUSS
C
      DO 101 IPG=1,NPG2
        KDEC = (IPG-1)*NNO*NDIM
        LDEC = (IPG-1)*NNO
C
        NX = 0.0D0
        NY = 0.0D0
        NZ = 0.0D0
C
C   CALCUL DE LA NORMALE AU POINT DE GAUSS IPG
C
        DO 102 I=1,NNO
        IDEC = (I-1)*NDIM
          DO 102 J=1,NNO
          JDEC = (J-1)*NDIM
C
          NX = NX + ZR(IDFDX+KDEC+IDEC) * ZR(IDFDY+KDEC+JDEC) * SX(I,J)
          NY = NY + ZR(IDFDX+KDEC+IDEC) * ZR(IDFDY+KDEC+JDEC) * SY(I,J)
          NZ = NZ + ZR(IDFDX+KDEC+IDEC) * ZR(IDFDY+KDEC+JDEC) * SZ(I,J)
C
102     CONTINUE
C
C   CALCUL DU JACOBIEN AU POINT DE GAUSS IPG
C
        JAC = SQRT(NX*NX + NY*NY + NZ*NZ)
C
        DO 103 I=1,NNO
CCDIR$ IVDEP
          DO 104 J=1,I
          IJ = (I-1)*I/2 + J
C
          ZR(IMATTT+IJ-1) = ZR(IMATTT+IJ-1) + JAC *
     &    ZR(IPOIDS+IPG-1) * ZR(IECH+IPG-1) *
     &    ZR(IVF+LDEC+I-1) * ZR(IVF+LDEC+J-1)
C
104       CONTINUE
103     CONTINUE
C
101     CONTINUE
      END
