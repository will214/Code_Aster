      SUBROUTINE TE0567(OPTION,NOMTE)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 30/03/2004   AUTEUR CIBHHLV L.VIVAN 
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
      IMPLICIT REAL*8 (A-H,O-Z)
      CHARACTER*16 OPTION,NOMTE
C ......................................................................
C    - FONCTION REALISEE:  CALCUL DES VECTEURS ELEMENTAIRES EN 3D
C                      OPTION : 'CHAR_ALPH_ZAC  '
C    - ARGUMENTS:
C        DONNEES:      OPTION       -->  OPTION DE CALCUL
C                      NOMTE        -->  NOM DU TYPE ELEMENT
C ......................................................................

      PARAMETER (NBRES=10)
      CHARACTER*16 PHENOM
      CHARACTER*8 NOMRES(NBRES),NOMPAR(2)
      CHARACTER*2 CODRET(NBRES)
      REAL*8 VALRES(NBRES),VALPAR(2),ZERO
      REAL*8 DFDX(27),DFDY(27),DFDZ(27),POIDS,EXX,EYY
      REAL*8 A11,A22,A33,A12,A13,A23,C1,EYZ,EXZ,EXY,EZZ
      REAL*8 G12,E,NU,NUCH,ECH
      INTEGER JGANO,NNO,KP,NPG,I,IVECTU
      INTEGER IPOIDS,IVF,IDFDE,IGEOM,IMATE,IALPHA

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

      DATA ZERO/0.D0/

      CALL ELREF4(' ','RIGI',NDIM,NNO,NNOS,NPG,IPOIDS,IVF,IDFDE,JGANO)

      CALL JEVECH('PGEOMER','L',IGEOM)
      CALL JEVECH('PMATERC','L',IMATE)
      CALL RCCOMA(ZI(IMATE),'ELAS',PHENOM,CODRET)

      CALL JEVECH('PALPHAR','L',IALPHA)
      CALL TECACH('ONN','PTEMPER',1,ITEMPE,IRET)
      NBPAR = 1
      NOMPAR(1) = 'TEMP'

      NOMRES(1) = 'E'
      NOMRES(2) = 'NU'
      NOMRES(3) = 'D_SIGM_EPSI'
      NOMRES(4) = 'SY'

      CALL JEVECH('PVECTUR','E',IVECTU)

      DO 40 KP = 1,NPG

        IT = (KP-1)*NNO
        IDPG = (KP-1)*6
        CALL DFDM3D ( NNO, KP, IPOIDS, IDFDE,
     &                ZR(IGEOM), DFDX, DFDY, DFDZ, POIDS )
        TPG = ZERO
        EXX = ZR(IALPHA+IDPG)
        EYY = ZR(IALPHA+IDPG+1)
        EZZ = ZR(IALPHA+IDPG+2)
        EXY = ZR(IALPHA+IDPG+3)
        EXZ = ZR(IALPHA+IDPG+4)
        EYZ = ZR(IALPHA+IDPG+5)

        DO 20 I = 1,NNO
          TPG = TPG + ZR(ITEMPE+I-1)*ZR(IVF+IT+I-1)
   20   CONTINUE

        IF (ITEMPE.NE.0) VALPAR(1) = TPG

        CALL RCVALA(ZI(IMATE),PHENOM,NBPAR,NOMPAR,VALPAR,2,NOMRES,
     &              VALRES,CODRET,'FM')

        CALL RCVALA(ZI(IMATE),'ECRO_LINE',NBPAR,NOMPAR,VALPAR,2,
     &              NOMRES(3),VALRES(3),CODRET,'FM')

C  CONSTANTES ELASTIQUES MODIFIEES

        E = VALRES(1)
        NU = VALRES(2)
        DSDE = VALRES(3)
        C = 2.D0/3.D0* (E*DSDE)/ (E-DSDE)
        ECH = 3.D0*C*E/ (2.D0*E+3.D0*C)
        NUCH = (3.D0*C*NU+E)/ (2.D0*E+3.D0*C)
        E = ECH
        NU = NUCH

        C1 = E/ (1.D0+NU)
        A11 = C1* (1.D0-NU)/ (1.D0-2.D0*NU)
        A12 = C1*NU/ (1.D0-2.D0*NU)
        A13 = A12
        A22 = A11
        A23 = A12
        A33 = A11
        G12 = C1/2.D0

        DO 30 I = 1,NNO
          ZR(IVECTU+3*I-3) = ZR(IVECTU+3*I-3) +
     &                       POIDS* ((A11*EXX+A12*EYY+A13*EZZ)*DFDX(I)+
     &                       2*G12*EXY*DFDY(I)+2*G12*EXZ*DFDZ(I))
          ZR(IVECTU+3*I-2) = ZR(IVECTU+3*I-2) +
     &                       POIDS* ((A12*EXX+A22*EYY+A23*EZZ)*DFDY(I)+
     &                       2*G12*EXY*DFDX(I)+2*G12*EYZ*DFDZ(I))
          ZR(IVECTU+3*I-1) = ZR(IVECTU+3*I-1) +
     &                       POIDS* ((A13*EXX+A23*EYY+A33*EZZ)*DFDZ(I)+
     &                       2*G12*EXZ*DFDX(I)+2*G12*EYZ*DFDY(I))
   30   CONTINUE

   40 CONTINUE
      END
