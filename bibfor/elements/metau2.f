      SUBROUTINE METAU2(OPTION,NOMTE)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 30/03/2004   AUTEUR CIBHHLV L.VIVAN 
C ======================================================================
C COPYRIGHT (C) 1991 - 2003  EDF R&D                  WWW.CODE-ASTER.ORG
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
C ======================================================================

C     BUT: CALCUL DES VECTEURS ELEMENTAIRES EN MECANIQUE
C          ELEMENTS ISOPARAMETRIQUES 3D METALLURGIQUES

C          OPTION : 'CHAR_MECA_TEMP_Z  '

C     ENTREES  ---> OPTION : OPTION DE CALCUL
C          ---> NOMTE  : NOM DU TYPE ELEMENT
C.......................................................................

      IMPLICIT REAL*8 (A-H,O-Z)
      PARAMETER (NBRES=6)
      CHARACTER*8 NOMRES(NBRES)
      CHARACTER*2 CODRET(NBRES)
      CHARACTER*16 NOMTE,OPTION
      REAL*8   VALRES(NBRES)
      REAL*8   COEF1,COEF2,EPSTH
      REAL*8   DFDX(27),DFDY(27),DFDZ(27),TPG,COEF,POIDS,NZ
      INTEGER  IPOIDS,IVF,IDFDE,IGEOM,IMATE
      INTEGER  JGANO,NNO,KP,NPG1,I,IVECTU,ITEMPE,JTAB(7)

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


      CALL ELREF4(' ','RIGI',NDIM,NNO,NNOS,NPG1,IPOIDS,IVF,IDFDE,JGANO)

      CALL JEVECH('PGEOMER','L',IGEOM)
      CALL JEVECH('PMATERC','L',IMATE)
      MATER = ZI(IMATE)

      NOMRES(1) = 'E'
      NOMRES(2) = 'NU'
      NOMRES(3) = 'F_ALPHA'
      NOMRES(4) = 'C_ALPHA'
      NOMRES(5) = 'PHASE_REFE'
      NOMRES(6) = 'EPSF_EPSC_TREF'


      CALL JEVECH('PTEREF','L',ITREF)
      CALL JEVECH('PTEMPER','L',ITEMPE)
      CALL JEVECH('PPHASRR','L',IPHASE)
      CALL JEVECH('PVECTUR','E',IVECTU)

C     INFORMATION DU NOMBRE DE PHASE
      CALL TECACH('OON','PPHASRR',7,JTAB,IRET)
      NZ = JTAB(6)


      DO 40 KP = 1,NPG1
        L = (KP-1)*NNO
        CALL DFDM3D ( NNO, KP, IPOIDS, IDFDE,
     &                ZR(IGEOM), DFDX, DFDY, DFDZ, POIDS )
        TPG = 0.D0

        DO 20 I = 1,NNO
          TPG = TPG + ZR(ITEMPE+I-1)*ZR(IVF+L+I-1)
   20   CONTINUE
        TTRG = TPG - ZR(ITREF)
        CALL RCVALA(MATER,'ELAS_META',1,'TEMP',TPG,6,NOMRES,VALRES,
     &              CODRET,'FM')
        COEF = VALRES(1)/ (1.D0-2.D0*VALRES(2))
        IF (NZ.EQ.7) THEN
          ZALPHA = ZR(IPHASE+7*KP-7) + ZR(IPHASE+7*KP-6) +
     &             ZR(IPHASE+7*KP-5) + ZR(IPHASE+7*KP-4)
        ELSE IF (NZ.EQ.3) THEN
          ZALPHA = ZR(IPHASE+3*KP-3) + ZR(IPHASE+3*KP-2)
        END IF

        COEF1 = (1.D0-ZALPHA)* (VALRES(4)*TTRG- (1-VALRES(5))*VALRES(6))
        COEF2 = ZALPHA* (VALRES(3)*TTRG+VALRES(5)*VALRES(6))
        EPSTH = COEF1 + COEF2
        POIDS = POIDS*COEF*EPSTH

        DO 30 I = 1,NNO
          ZR(IVECTU+3*I-3) = ZR(IVECTU+3*I-3) + POIDS*DFDX(I)
          ZR(IVECTU+3*I-2) = ZR(IVECTU+3*I-2) + POIDS*DFDY(I)
          ZR(IVECTU+3*I-1) = ZR(IVECTU+3*I-1) + POIDS*DFDZ(I)
   30   CONTINUE
   40 CONTINUE

   50 CONTINUE

      END
