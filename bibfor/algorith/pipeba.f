        SUBROUTINE PIPEBA(NDIM,MATE,SUP,SUD,VIM,DTAU,COPILO)

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 01/02/2011   AUTEUR MASSIN P.MASSIN 
C ======================================================================
C COPYRIGHT (C) 1991 - 2011  EDF R&D                  WWW.CODE-ASTER.ORG
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
      INTEGER MATE,NDIM
      REAL*8  SUP(NDIM), SUD(NDIM), VIM,DTAU, COPILO(2,3)
      
C-----------------------------------------------------------------------
C
C PILOTAGE PRED_ELAS POUR LES LOIS COHESIVES CZM_LIN_REG ET CZM_EXP_REG
C DE L'ELEMENT DE JOINT (2D ET 3D)  
C
C-----------------------------------------------------------------------

      INTEGER I,J,NRAC,OK(4), NSOL
      REAL*8  P0,P1,P2, RAC(2), ETA(4), A0(4), A1(4), TMP
      REAL*8  LC,K0,KA,KREF,C,VAL(3),ETASOL(4), ETAMIN,XN
      REAL*8  DDOT, R8GAEM
      CHARACTER*2 COD(3)
      CHARACTER*8 NOM(3)

      REAL*8 E(2)
C-----------------------------------------------------------------------


C INITIALISATION

      NOM(1) = 'GC'
      NOM(2) = 'SIGM_C'
      NOM(3) = 'PENA_ADHERENCE'
      CALL RCVALA (MATE,' ','RUPT_FRAG',0,' ',0.D0,3,NOM,VAL,COD,'F ')
      LC   = VAL(1)/VAL(2)
      K0   = VAL(1)/VAL(2)*VAL(3)
      KA   = MAX(VIM,K0)
      KREF = MAX(LC,KA)

      C  = DTAU*KREF + KA

      OK(1) = 0
      OK(2) = 0
      OK(3) = 0
      OK(4) = 0

C    RESOLUTION FEL(ETA) = DTAU
C    OU FEL(ETA) = ( SQRT(P0 + 2 P1 ETA + P2 ETA**2) - KA) / KREF
C    PORTION EN COMPRESSION : FEL = (ABS(SU(2)) - KA ) / KREF
C    ON INCLUT EGALEMENT UN SAFE-GUARD SU_N > -KREF CAR AU-DELA CE SONT
C    DES SOLUTIONS TRES FORTEMENT EN COMPRESSION QUI FONT EXPLOSER LA
C    PENALISATION
C 
      P0=0.D0
      P1=0.D0
      P2=0.D0
      DO 10 I=2,NDIM
        P2 = P2 + SUD(I)*SUD(I)
        P1 = P1 + SUD(I)*SUP(I)
        P0 = P0 + SUP(I)*SUP(I)
10    CONTINUE

C    PAS DE SOLUTION
      IF (P2 .LT. (1.D0/R8GAEM()**0.5D0)) GOTO 1000

C    RECHERCHE DES SOLUTIONS
      CALL ZEROP2(2*P1/P2, (P0-C**2)/P2, RAC, NRAC)
      IF (NRAC.LE.1) GOTO 1000

      XN = SUP(1)+RAC(2)*SUD(1)
      IF (XN.LE.0 .AND. XN.GE.-KREF) THEN
        OK(1)  = 1
        ETA(1) = RAC(2)
        A1(1)  = (P1+P2*ETA(1))/(KREF*C)
        A0(1)  = DTAU-ETA(1)*A1(1)
      END IF

      XN = SUP(1)+RAC(1)*SUD(1)
      IF (XN .LE. 0 .AND. XN.GE.-KREF) THEN
        OK(2)  = 1
        ETA(2) = RAC(1)
        A1(2)  = (P1+P2*ETA(2))/(KREF*C)
        A0(2)  = DTAU-ETA(2)*A1(2)
      END IF

 1000 CONTINUE


C    PORTION EN TRACTION : FEL = (SQR(SU(1)**2 + SU(2)**2) - KA) / KREF

      P2 = DDOT(NDIM,SUD,1,SUD,1)
      P1 = DDOT(NDIM,SUD,1,SUP,1)
      P0 = DDOT(NDIM,SUP,1,SUP,1)

C    PAS DE SOLUTION
      IF (P2 .LT. (1.D0/R8GAEM()**0.5D0)) GOTO 2000

C    RECHERCHE DES SOLUTIONS
      CALL ZEROP2(2*P1/P2, (P0-C**2)/P2, RAC, NRAC)
      IF (NRAC.LE.1) GOTO 2000

      IF (SUP(1)+RAC(2)*SUD(1).GT.0) THEN            
        OK(3)  = 1
        ETA(3) = RAC(2)
        A1(3)  = (P1+P2*ETA(3))/(KREF*C)
        A0(3)  = DTAU-ETA(3)*A1(3)
      END IF

      IF (SUP(1)+RAC(1)*SUD(1).GT. 0) THEN     
        OK(4)  = 1
        ETA(4) = RAC(1)
        A1(4)  = (P1+P2*ETA(4))/(KREF*C)
        A0(4)  = DTAU-ETA(4)*A1(4)      
      END IF

 2000 CONTINUE


C -- CLASSEMENT DES SOLUTIONS

      NSOL = OK(1)+OK(2)+OK(3)+OK(4)
      CALL ASSERT(NSOL.LE.2)

      J = 0
      DO 20 I = 1,4
        IF (OK(I).EQ.1) THEN
          J = J+1
          ETASOL(J)   = ETA(I)
          COPILO(1,J) = A0(I)
          COPILO(2,J) = A1(I)
        END IF
 20   CONTINUE

C    ON RANGE LES SOLUTIONS DANS L'ORDRE CROISSANT (SI NECESSAIRE)
      IF (NSOL.EQ.2) THEN
        IF (ETASOL(2) .LT. ETASOL(1)) THEN
          TMP = ETASOL(2)
          ETASOL(2) = ETASOL(1)
          ETASOL(1) = TMP

          TMP = COPILO(1,1)
          COPILO(1,1) = COPILO(1,2)
          COPILO(1,2) = TMP

          TMP = COPILO(2,1)
          COPILO(2,1) = COPILO(2,2)
          COPILO(2,2) = TMP
        END IF 
      END IF


C    TRAITEMENT EN L'ABSENCE DE SOLUTION
      IF (NSOL .EQ. 0) THEN
C    SI DEPLACEMENT PILOTE NUL ET SAUT EQ INFERIEUR A DTAU
C    ON IGNORE LE POINT POUR LA RESOLUTION GLOBALE       
        IF (P2 .LE. (1.D0/R8GAEM()**0.5D0)
     &      .AND.(SQRT(P0)).LE.DTAU) THEN
          COPILO(1,1) = 0.D0
          COPILO(1,2) = 0.D0      
          COPILO(2,1) = 0.D0
          COPILO(2,2) = 0.D0
C DANS LES AUTRE CAS COURBE TJS SUPERIEURE A DTAU : ON PLANTE          
        ELSE      
          COPILO(1,1) = 1.D0
          COPILO(1,3) = 1.D0 
        ENDIF            
      END IF  
          
      END
