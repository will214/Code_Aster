      SUBROUTINE POEFGC(NOMTE,KLC,E,XNU,RHO,ALPHAT,EFFO)
      IMPLICIT REAL*8 (A-H,O-Z)
      CHARACTER*(*) NOMTE
      REAL*8 KLC(12,12),E,XNU,RHO,ALPHAT
      COMPLEX*16 EFFO(*)
C     ------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 08/03/2004   AUTEUR REZETTE C.REZETTE 
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
C TOLE CRP_6
C
C     CALCUL DU VECTEUR ELEMENTAIRE EFFORT GENERALISE COMPLEXE,
C     POUR LES ELEMENTS DE POUTRE D'EULER ET DE TIMOSHENKO.
C     ------------------------------------------------------------------
C     ----- DEBUT COMMUNS NORMALISES  JEVEUX  --------------------------
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

      REAL*8 PGL(3,3),PGL1(3,3),PGL2(3,3),MLV(78),MLC(12,12)
      REAL*8 ULR(12),UGR(12),ULI(12),UGI(12)
      REAL*8 FLR(12),FLI(12),FER(12),FEI(12)
      REAL*8 ACCER(12),ACCEI(12),FE(12)
C     ------------------------------------------------------------------
      ZERO = 0.D0
      DEUX = 2.D0
      NNO = 2
      NC = 6
      NNOC = 1
      NCC = 6
C     ------------------------------------------------------------------

C     --- RECUPERATION DES CARACTERISTIQUES GENERALES DES SECTIONS ---

      CALL JEVECH('PCAGNPO','L',LSECT)
      LSECT = LSECT - 1
      LSECT2 = LSECT + 11
      ITYPE = NINT(ZR(LSECT+23))
      A = ZR(LSECT+1)
      A2 = ZR(LSECT2+1)

C     --- RECUPERATION DES COORDONNEES DES NOEUDS ---
      CALL JEVECH('PGEOMER','L',LX)
      LX = LX - 1
      XL = SQRT((ZR(LX+4)-ZR(LX+1))**2+ (ZR(LX+5)-ZR(LX+2))**2+
     &     (ZR(LX+6)-ZR(LX+3))**2)
      IF (ITYPE.EQ.10) THEN
        CALL JEVECH('PCAARPO','L',LRCOU)
        RAD = ZR(LRCOU)
        ANGARC = ZR(LRCOU+1)
        ANGS2 = ASIN(XL/ (DEUX*RAD))
        XL = RAD*ANGS2*DEUX
      END IF

C     --- MATRICE DE ROTATION PGL

      CALL JEVECH('PCAORIE','L',LORIEN)
      IF (ITYPE.EQ.10) THEN
        CALL MATRO2(ZR(LORIEN),ANGARC,ANGS2,PGL1,PGL2)
      ELSE
        CALL MATROT(ZR(LORIEN),PGL)
      END IF

C      --- VECTEUR DEPLACEMENT GLOBAL

      CALL JEVECH('PDEPLAC','L',JDEPL)
      DO 10 I = 1,12
        UGR(I) = DBLE(ZC(JDEPL+I-1))
        UGI(I) = DIMAG(ZC(JDEPL+I-1))
   10 CONTINUE

C      --- VECTEUR DEPLACEMENT LOCAL  UL = PGL * UG

      IF (ITYPE.EQ.10) THEN
        CALL UTPVGL(NNOC,NCC,PGL1,UGR,ULR)
        CALL UTPVGL(NNOC,NCC,PGL1,UGI,ULI)
        CALL UTPVGL(NNOC,NCC,PGL2,UGR(7),ULR(7))
        CALL UTPVGL(NNOC,NCC,PGL2,UGI(7),ULI(7))
      ELSE
        CALL UTPVGL(NNO,NC,PGL,UGR,ULR)
        CALL UTPVGL(NNO,NC,PGL,UGI,ULI)
      END IF

C     --- VECTEUR EFFORT       LOCAL  FL = KLC * UL

      CALL PMAVEC('ZERO',12,KLC,ULR,FLR)
      CALL PMAVEC('ZERO',12,KLC,ULI,FLI)

C     --- TENIR COMPTE DES EFFORTS DUS A LA DILATATION ---

      IF (ALPHAT.NE.ZERO) THEN
        DO 20 I = 1,12
          UGR(I) = ZERO
          UGI(I) = ZERO
   20   CONTINUE
C         - CALCUL DU DEPLACEMENT LOCAL INDUIT PAR L'ELEVATION DE TEMP.
C           TEMPERATURE DE REFERENCE
        CALL JEVECH('PTEREF','L',LTREF)

C           TEMPERATURE EFFECTIVE
        CALL JEVECH('PTEMPER','L',LTEMP)

        TEMP = ZR(LTEMP) - ZR(LTREF)

        IF (TEMP.NE.ZERO) THEN
          F = ALPHAT*TEMP
          IF (ITYPE.NE.10) THEN
            UGR(1) = -F*XL
            UGI(1) = -F*XL
            UGR(7) = -UGR(1)
            UGI(7) = -UGI(1)
          ELSE
            ALONG = 2.D0*RAD*F*SIN(ANGS2)
            UGR(1) = -ALONG*COS(ANGS2)
            UGI(1) = -ALONG*COS(ANGS2)
            UGR(2) = ALONG*SIN(ANGS2)
            UGI(2) = ALONG*SIN(ANGS2)
            UGR(7) = -UGR(1)
            UGI(7) = -UGI(1)
            UGR(8) = UGR(2)
            UGI(8) = UGI(2)
          END IF

C              --- CALCUL DES FORCES INDUITES ---
          DO 40 I = 1,6
            DO 30 J = 1,6
              FLR(I) = FLR(I) - KLC(I,J)*UGR(J)
              FLI(I) = FLI(I) - KLC(I,J)*UGI(J)
              FLR(I+6) = FLR(I+6) - KLC(I+6,J+6)*UGR(J+6)
              FLI(I+6) = FLI(I+6) - KLC(I+6,J+6)*UGI(J+6)
   30       CONTINUE
   40     CONTINUE
        END IF
      END IF

C     --- TENIR COMPTE DES EFFORTS REPARTIS/PESANTEUR ---

      CALL PTFORP(ITYPE,'CHAR_MECA_PESA_R',NOMTE,A,A2,XL,RAD,ANGS2,0,
     &            NNO,NC,PGL,PGL1,PGL2,FER,FEI)
      DO 50 I = 1,12
        FLR(I) = FLR(I) - FER(I)
        FLI(I) = FLI(I) - FEI(I)
   50 CONTINUE

      CALL PTFORP(ITYPE,'CHAR_MECA_FR1D1D',NOMTE,A,A2,XL,RAD,ANGS2,0,
     &            NNO,NC,PGL,PGL1,PGL2,FER,FEI)
      DO 60 I = 1,12
        FLR(I) = FLR(I) - FER(I)
        FLI(I) = FLI(I) - FEI(I)
   60 CONTINUE

      CALL PTFORP(ITYPE,'CHAR_MECA_FF1D1D',NOMTE,A,A2,XL,RAD,ANGS2,0,
     &            NNO,NC,PGL,PGL1,PGL2,FER,FEI)
      DO 70 I = 1,12
        FLR(I) = FLR(I) - FER(I)
        FLI(I) = FLI(I) - FEI(I)
   70 CONTINUE

      CALL PTFOCP(ITYPE,'CHAR_MECA_FC1D1D',NOMTE,XL,RAD,ANGS2,
     &            NNO,NC,PGL,PGL1,PGL2,FER,FEI)
      DO 80 I = 1,12
        FLR(I) = FLR(I) - FER(I)
        FLI(I) = FLI(I) - FEI(I)
   80 CONTINUE

C      --- FORCE DYNAMIQUE ---

      IF (RHO.NE.ZERO) THEN
        KANL = 2
        CALL JEVECH('PSUROPT','L',LOPT)
        IF (ZK24(LOPT).EQ.'MASS_MECA_DIAG') KANL = 0
        IF (ZK24(LOPT).EQ.'MASS_MECA     ') KANL = 1
        IF (KANL.EQ.2) GO TO 110
        CALL POMASS(NOMTE,E,XNU,RHO,KANL,MLV)
        CALL VECMA(MLV,78,MLC,12)
        CALL JEVECH('PCHDYNC','L',LDYNA)
        DO 90 I = 1,12
          ACCER(I) = DBLE(ZC(LDYNA+I-1))
          ACCEI(I) = DIMAG(ZC(LDYNA+I-1))
   90   CONTINUE
        IF (ITYPE.EQ.10) THEN
          CALL UTPVGL(NNOC,NCC,PGL1,ACCER,UGR)
          CALL UTPVGL(NNOC,NCC,PGL2,ACCER(7),UGR(7))
          CALL UTPVGL(NNOC,NCC,PGL1,ACCEI,UGI)
          CALL UTPVGL(NNOC,NCC,PGL2,ACCEI(7),UGI(7))
        ELSE
          CALL UTPVGL(NNO,NC,PGL,ACCER,UGR)
          CALL UTPVGL(NNO,NC,PGL,ACCEI,UGI)
        END IF
        CALL PMAVEC('ZERO',12,MLC,UGR,FER)
        CALL PMAVEC('ZERO',12,MLC,UGI,FEI)
        DO 100 I = 1,12
          FLR(I) = FLR(I) + FER(I)
          FLI(I) = FLI(I) + FEI(I)
  100   CONTINUE
      END IF
  110 CONTINUE

C     --- ARCHIVAGE ---

      DO 120 I = 1,12
        EFFO(I) = DCMPLX(FLR(I),FLI(I))
  120 CONTINUE

      END
