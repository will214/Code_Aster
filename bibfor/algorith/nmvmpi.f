      SUBROUTINE NMVMPI(DEPS0,VIM0,SIGM0,LOI346,
     &                  OPTION,MATRIC,CARCRI,SIGP,VIP,DSIDEP)

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 06/04/2004   AUTEUR DURAND C.DURAND 
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
C TOLE CRP_7

      IMPLICIT NONE
      CHARACTER*(*) OPTION
      LOGICAL MATRIC
      REAL*8 SIGM0(4),SIGP(4),VIM0(7),VIP(7),LOI346(*)
      REAL*8 DEPS0(4),DSIDEP(6,6),CARCRI(*)
C
C    - FONCTION REALISEE: COMPORTEMENT VMIS_POUTRE
C      RESOLUTION LOCALE IMPLCIITE POUR UN POINT DE GAUSS
C    - ARGUMENTS IN:
C         DEPS0    : ACCROISSEMENT DE DEFORMATION
C         VIM0     : VARIABLES INTERNES A L'INSTANT PRECEDENT
C         SIGM0    : CONTRAINTES A L'INSTANT PRECEDENT
C         LOI346   : COEFFICIENTS MATERIAU
C         OPTION   : RAPH_MECA, FULL_MECA OU RIGI_MECA_TANG
C         MATRIC   : INDIQUE SI ON DOIT CALCULER HOTA
C         CARCRI   : PARAMETRES UTILISATEUR DE CONVERGENCE
C    - ARGUMENTS OUT:
C         SIGP     : CONTRAINTES A L'INSTANT ACTUEL
C         VIP      : VARIABLES INTERNES A L'INSTANT ACTUEL
C         DSIDEP   : MATRICE DE COMPORTEMENT TANGENT

      LOGICAL DEPASS
      INTEGER I,IRET,NIT,NITMAX,J
      REAL*8 SIGM(4),NITER
      REAL*8 DEPS(4),HOEL(4),VIM(7)
      REAL*8 SIGE(4),MPX
      REAL*8 RC,AY,AZ,RP,NE,MYE,MZE,MXE,PREC
      REAL*8 MATER(28)
      REAL*8 EA,SEUIL,NX,MY,MZ,MX,DP0,F0,NMCRI7,R8MIEM,DP1,DP
      REAL*8 EIY,NP,DNX,DMY,DMZ,DMX,DEPSXP,DQSIYP,DQSIZP,DQSIXP
      REAL*8 EIZ,GJX,AX,DIJ,DJI

      COMMON/RCPOU7/MATER,SIGM,VIM,DEPS,RC,RP,NE,MYE,MZE,MXE,AY,AZ,
     &              NITER,PREC

      EXTERNAL NMCRI7
      MPX   = LOI346(8)
      NP    = LOI346(21)

      AX = 1.D0/MPX/MPX

      EA  = LOI346(25)
      EIY = LOI346(26)
      EIZ = LOI346(27)
      GJX = LOI346(28)

      DO 211 I=1,4
         HOEL(I)=LOI346(24+I)
         DEPS(I)=DEPS0(I)
         SIGM(I)=SIGM0(I)
211   CONTINUE

      DO 209 I=1,7
         VIM(I)=VIM0(I)
209   CONTINUE

      DO 210 I=1,28
         MATER(I)=LOI346(I)
210   CONTINUE

      DO 212 I = 1,4
         SIGE(I) = SIGM(I) + HOEL(I)*DEPS(I)
  212 CONTINUE
      CALL POUCRI(LOI346,SIGE,VIM,RC,RP,SEUIL)
C
C     ON RESTE ELASTIQUE
C
      IF (OPTION.EQ.'RIGI_MECA_TANG') THEN
         DEPASS = .FALSE.
         DO 551 I=1,7
           VIP(I) = VIM(I)
551       CONTINUE
         DO 561 I=1,4
           SIGP(I) = SIGM(I)
561       CONTINUE
         DP=0.D0

      ELSEIF (SEUIL.LE.0.D0) THEN

         DEPASS = .FALSE.
         NX   = SIGE(1)
         MY   = SIGE(2)
         MZ   = SIGE(3)
         MX   = SIGE(4)
         DO 55 I=1,7
           VIP(I) = VIM(I)
55       CONTINUE
         DO 56 I=1,4
           SIGP(I) = SIGE(I)
56       CONTINUE
         DP=0.D0

      ELSE

         DEPASS = .TRUE.
         DP0 = 0.D0
C        EXAMEN DE LA SOLUTION X = 0
         F0 = NMCRI7(DP0)

         IF (ABS(F0).LE.R8MIEM())THEN
            CALL UTMESS('F','POUINP','F(0)=0')
         ELSEIF (F0.GT.0.D0) THEN
            CALL UTMESS('F','POUINP','F(0)>0')
         ELSE

            PREC=CARCRI(3)
            NITER=CARCRI(1)
            NITMAX = INT ( NITER)

            DP1 = SEUIL/EA

            CALL ZEROFC(NMCRI7,DP0,DP1,NITMAX,PREC,DP,IRET,NIT)
            IF (IRET.NE.0) THEN
               CALL NMMESS('F',DP0,DP1,DP,NMCRI7,NIT,NITMAX,IRET)
            ENDIF

            NX=NE*RP/(RP+EA*DP)
            MY=MYE*RP/(RP+EIY*DP*NP*NP*AY)
            MZ=MZE*RP/(RP+EIZ*DP*NP*NP*AZ)
            MX=MXE*RP/(RP+GJX*DP*NP*NP*AX)
            DNX = NX-SIGM(1)
            DMY = MY-SIGM(2)
            DMZ = MZ-SIGM(3)
            DMX = MX-SIGM(4)
            DEPSXP=DEPS(1)-DNX/EA
            DQSIYP=DEPS(2)-DMY/EIY
            DQSIZP=DEPS(3)-DMZ/EIZ
            DQSIXP=DEPS(4)-DMX/GJX

            SIGP(1)=NX
            SIGP(2)=MY
            SIGP(3)=MZ
            SIGP(4)=MX

           VIP(1) = DEPSXP+VIM(1)
           VIP(2) = DQSIYP+VIM(2)
           VIP(3) = DQSIZP+VIM(3)
           VIP(4) = DQSIXP+VIM(4)
           VIP(5) = DP+VIM(5)
           VIP(6) = ABS(DQSIYP)+VIM(6)
           VIP(7) = ABS(DQSIZP)+VIM(7)

         ENDIF
      ENDIF

C     CALCUL DE LA MATRICE TANGENTE ELEMENTAIRE :

      IF ( MATRIC ) THEN
         CALL R8INIR(36,0.D0,DSIDEP,1)
         IF ( DEPASS ) THEN
            CALL NMVMPJ(LOI346,SIGP,VIP,DP,DSIDEP)

CJMP  SYMETRISATION NECESSAIRE

            DO 998 I=1,4
            DO 998 J=1,4
               IF (I.NE.J) THEN
                   DIJ=DSIDEP(I,J)
                   DJI=DSIDEP(J,I)
                   DSIDEP(I,J)=(DIJ+DJI)/2.D0
                   DSIDEP(J,I)=(DIJ+DJI)/2.D0
                ENDIF
998          CONTINUE
         ELSE
            DO 775 I = 1, 4
              DSIDEP(I,I) = HOEL(I)
775         CONTINUE
         ENDIF
      ENDIF
      END
