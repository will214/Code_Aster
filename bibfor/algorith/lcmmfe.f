      SUBROUTINE LCMMFE(TAUS,COEFT,MATERF,IFA,
     &    NMAT,NBCOMM,NECOUL,IS,NBSYS,VIND,DY,RP,ALPHAP,GAMMAP,DT,
     &    DALPHA,DGAMMA,DP,CRIT,SGNS,NFS,NSG,HSR,IRET)
      IMPLICIT NONE
      INTEGER IFA,NMAT,NBCOMM(NMAT,3),IRET
      INTEGER IFL,IS,NBSYS,NUECOU,NFS,NSG
      REAL*8 TAUS,COEFT(NMAT),ALPHAP,DGAMMA,DP,DT
      REAL*8 RP,SGNS,HSR(NSG,NSG),DY(*),VIND(*),MATERF(NMAT),DALPHA
      REAL*8 C,K,N,FTAU,CRIT,A,D
      REAL*8 GAMMAP,R8MIEM,PTIT,CISA2
      CHARACTER*16 NECOUL
C     ----------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 26/03/2012   AUTEUR PROIX J-M.PROIX 
C TOLE CRP_21
C ======================================================================
C COPYRIGHT (C) 1991 - 2012  EDF R&D                  WWW.CODE-ASTER.ORG
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
C RESPONSABLE JMBHH01 J.M.PROIX
C ======================================================================
C  COMPORTEMENT MONOCRISTALLIN : ECOULEMENT (VISCO)PLASTIQUE
C  INTEGRATION DES LOIS MONOCRISTALLINES
C       IN  TAUS    :  SCISSION REDUITE
C           COEFT   :  PARAMETRES MATERIAU
C           IFA     :  NUMERO DE FAMILLE
C           NMAT    :  NOMBRE MAXI DE MATERIAUX
C           NBCOMM  :  NOMBRE DE COEF MATERIAU PAR FAMILLE
C           NECOUL  :  NOM DE LA LOI D'ECOULEMENT
C           RP      :  R(P) FONCTION D'ECROUISSAGE ISTROPE
C           ALPHAP  :  ALPHA A T ACTUEL
C           GAMMAP  :  GAMMA A T ACTUEL
C           DT      :  INTERVALLE DE TEMPS EVENTULLEMENT REDECOUPE
C     OUT:
C           DGAMMA  :  DEF PLAS
C           DALPHA  :  VARIABLE dalpha pour Kocks-Rauch
C           DP      :  DEF PLAS CUMULEE
C           CRIT    :  CRITERE
C           SGNS    :  SIGNE DE GAMMA
C           IRET    :  CODE RETOUR
C ======================================================================


C     DANS VIS : 1 = ALPHA, 2=GAMMA, 3=P

      IFL=NBCOMM(IFA,1)
      NUECOU=NINT(COEFT(IFL))
      IRET=0
      PTIT=R8MIEM()

C-------------------------------------------------------------
C     POUR UN NOUVEAU TYPE D'ECOULEMENT, CREER UN BLOC IF
C------------------------------------------------------------

C      IF (NECOUL.EQ.'MONO_VISC1') THEN
      IF (NUECOU.EQ.1) THEN
          N=COEFT(IFL+1)
          K=COEFT(IFL+2)
          C=COEFT(IFL+3)

          FTAU=TAUS-C*ALPHAP
          IF (ABS(FTAU).LT.PTIT) THEN
             SGNS=1.D0
          ELSE
             SGNS=FTAU/ABS(FTAU)
          ENDIF
          CRIT=ABS(FTAU)-RP
          IF (CRIT.GT.0.D0) THEN
             DP=((CRIT/K)**N)*DT
             DGAMMA=DP*SGNS
          ELSE
             DP=0.D0
             DGAMMA=0.D0
          ENDIF

C      IF (NECOUL.EQ.'MONO_VISC2') THEN
      ELSEIF (NUECOU.EQ.2) THEN
          N=COEFT(IFL+1)
          K=COEFT(IFL+2)
          C=COEFT(IFL+3)
          A=COEFT(IFL+4)
          D=COEFT(IFL+5)

          FTAU=TAUS-C*ALPHAP-A*GAMMAP
          IF (ABS(FTAU).LT.PTIT) THEN
             SGNS=1.D0
          ELSE
             SGNS=FTAU/ABS(FTAU)
          ENDIF

          CRIT=ABS(FTAU)-RP + 0.5D0*D*C*ALPHAP**2
          IF (CRIT.GT.0.D0) THEN
             DP=((CRIT/K)**N)*DT
             DGAMMA=DP*SGNS
          ELSE
             DP=0.D0
             DGAMMA=0.D0
          ENDIF

C      IF (NECOUL.EQ.'KOCKS_RAUCH') THEN
      ELSEIF (NUECOU.EQ.4) THEN
         IF (MATERF(NMAT).EQ.0) THEN
            CISA2 = (MATERF(1)/2.D0/(1.D0+MATERF(2)))**2
         ELSE
            CISA2 = (MATERF(36)/2.D0)**2
         ENDIF
         CALL LCMMKR(TAUS,COEFT,CISA2,IFA,NMAT,NBCOMM,IS,NBSYS,NFS,NSG,
     &      HSR,VIND,DY,DT,DALPHA,DGAMMA,DP,CRIT,SGNS,IRET)
C         CALCUL D'UN RP FICTIF POUR LCMMVX :
C         CELA PERMET D'ESTIMER LE PREMIER POINT DE NON LINEARITE
         RP=COEFT(IFL+3)

C      IF (NECOUL.EQ.'MONO_DD_CFC') THEN
      ELSEIF ((NUECOU.EQ.5).OR.(NUECOU.EQ.6)) THEN
         CALL LCMMDD(TAUS,COEFT,IFA,NMAT,NBCOMM,IS,NBSYS,NFS,NSG,HSR,
     &      VIND,DY,DT,RP,NUECOU,DALPHA,DGAMMA,DP,IRET)
          IF (IRET.GT.0) GOTO 9999
          CRIT=DP
          IF (ABS(TAUS).LE.PTIT) THEN
             SGNS=1.D0
          ELSE
             SGNS=TAUS/ABS(TAUS)
          ENDIF
          
C      IF (NECOUL.EQ.'MONO_DD_CC')OR (NECOUL.EQ.'MONO_DD_CC_IRRA') THEN
      ELSEIF (NUECOU.EQ.7) THEN
         CALL LCDDCC(TAUS,COEFT,IFA,NMAT,NBCOMM,IS,NBSYS,NFS,NSG,HSR,
     &               VIND,DY,DT,RP,NUECOU,DALPHA,DGAMMA,DP,IRET)
          IF (IRET.GT.0) GOTO 9999
          CRIT=DP
          IF (ABS(TAUS).LE.PTIT) THEN
             SGNS=1.D0
          ELSE
             SGNS=TAUS/ABS(TAUS)
          ENDIF
          
          
          
          
       ELSE
          CALL U2MESS('F','COMPOR1_20')
       ENDIF
9999   CONTINUE
      END
