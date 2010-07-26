      SUBROUTINE JJANAL( CONDLU, NVAL , NVALO , LVAL , CVAL)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF JEVEUX  DATE 26/07/2010   AUTEUR LEFEBVRE J-P.LEFEBVRE 
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
C RESPONSABLE LEFEBVRE J-P.LEFEBVRE
      IMPLICIT REAL*8 (A-H,O-Z)
      CHARACTER *(*)     CONDLU                       , CVAL(*)
      INTEGER                    NVAL , NVALO , LVAL(*)
C
      INTEGER        LONG , I , J , NBSC
C
      DO 20 I = 1 , NVAL
         CVAL (I) = ' '
         LVAL (I) = 0
 20   CONTINUE
      LONG = LEN(CONDLU)
      IF ( LONG .EQ. 0 .AND. NVALO .GT. 0 ) THEN
         CALL U2MESS('F','JEVEUX1_31')
      ENDIF
      NBSC = 0
      I = 1
C
 1    CONTINUE
      IF ( I .GT. LONG ) THEN
         IF ( NBSC .LT. NVALO ) THEN
            CALL U2MESS('F','JEVEUX1_31')
         ELSE
            GOTO 100
         ENDIF
      END IF
      IF( CONDLU(I:I) .EQ. ' ') THEN
         I = I + 1
         GO TO 1
      END IF
      J = I + 1
 2    CONTINUE
      IF( J .GT. LONG) GO TO 3
      IF( CONDLU(J:J) .NE. ' ') THEN
         J = J + 1
         GO TO 2
      END IF
C
 3    CONTINUE
      NBSC = NBSC + 1
      CVAL( NBSC ) = CONDLU(I:J-1)
      LVAL( NBSC ) = J - I
      IF ( NBSC .LT. NVAL .AND. J .LE. LONG) THEN
         I = J + 1
         GO TO 1
      ELSE IF ( NBSC .LT. NVALO   .AND. J. EQ. LONG+1) THEN
         CALL U2MESS('F','JEVEUX1_31')
      END IF
 100  CONTINUE
      DO 10 I = J , LONG
         IF ( CONDLU(I:I) .NE. ' ') THEN
            CALL U2MESS('F','JEVEUX1_32')
         END IF
 10   CONTINUE
C
      END
