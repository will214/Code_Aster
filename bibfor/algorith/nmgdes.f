       SUBROUTINE NMGDES (NDIM,TYPMOD,IMATE,COMPOR,CRIT,
     &                   INSTAM,INSTAP,TM,TP,TREF,HYDRM,HYDRP,
     &                   SECHM,SECHP,TPMXM,TPMXP,DEPST,SIGM,VIM,
     &                   OPTION,SIGP,VIP,DSIDEP)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 06/04/2004   AUTEUR JOUMANA J.EL-GHARIB 
C ======================================================================
C COPYRIGHT (C) 1991 - 2002  EDF R&D                  WWW.CODE-ASTER.ORG
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
C TOLE CRP_21
C
      IMPLICIT NONE
      INTEGER            NDIM,IMATE
      CHARACTER*8        TYPMOD(*)
      CHARACTER*16       COMPOR(3),OPTION
      REAL*8             CRIT(3),INSTAM,INSTAP,TM,TP,TREF
      REAL*8             HYDRM , HYDRP , SECHM , SECHP, TPMXM, TPMXP
      REAL*8             DEPST(6)
      REAL*8             SIGM(6),VIM(1),SIGP(6),VIP(1),DSIDEP(6,6)
C ----------------------------------------------------------------------
C     REALISE LA LOI DE BAZANT_FD (LOI DE BAZANT POUR LA LOI DE FLUAGE 
C     DE DESSICATION INTRINSEQUE)
C     ELEMENTS ISOPARAMETRIQUES EN PETITES DEFORMATIONS
C
C IN  NDIM    : DIMENSION DE L'ESPACE
C IN  TYPMOD  : TYPE DE MODELISATION
C IN  IMATE   : ADRESSE DU MATERIAU CODE
C IN  COMPOR  : COMPORTEMENT : RELCOM ET DEFORM
C IN  CRIT    : CRITERES DE CONVERGENCE LOCAUX
C IN  INSTAM  : INSTANT DU CALCUL PRECEDENT
C IN  INSTAP  : INSTANT DU CALCUL
C IN  TM      : TEMPERATURE A L'INSTANT PRECEDENT
C IN  TP      : TEMPERATURE A L'INSTANT DU CALCUL
C IN  HYDRM   : HYDRATATION A L'INSTANT PRECEDENT
C IN  HYDRP   : HYDRATATION A L'INSTANT DU CALCUL
C IN  SECHM   : SECHAGE A L'INSTANT PRECEDENT
C IN  SECHP   : SECHAGE A L'INSTANT DU CALCUL
C IN  TPMXM   : TEMPERATURE MAX ATTEINTE AU COURS DE L'HISTORIQUE DE
C               CHARGEMENT A T (POUR LE COUPLAGE FLUAGE/FISSURATION)
C IN  TPMXP   : TEMPERATURE MAX ATTEINTE AU COURS DE L'HISTORIQUE DE
C               CHARGEMENT A T+DT (POUR LE COUPLAGE FLUAGE/FISSURATION)
C IN  TREF    : TEMPERATURE DE REFERENCE
C IN  DEPST   : INCREMENT DE DEFORMATION
C               SI C_PLAN DEPST(3) EST EN FAIT INCONNU (ICI:0)
C                 =>  ATTENTION LA PLACE DE DEPST(3) EST ALORS UTILISEE.
C IN  SIGM    : CONTRAINTES A L'INSTANT DU CALCUL PRECEDENT
C IN  VIM     : VARIABLES INTERNES A L'INSTANT DU CALCUL PRECEDENT
C IN  OPTION  : OPTION DEMANDEE : RIGI_MECA_TANG , FULL_MECA , RAPH_MECA
C OUT SIGP    : CONTRAINTES A L'INSTANT ACTUEL
C OUT VIP     : VARIABLES INTERNES A L'INSTANT ACTUEL
C OUT DSIDEP  : MATRICE CARREE (INUTILISE POUR RAPH_MECA)
C
C               ATTENTION LES TENSEURS ET MATRICES SONT RANGES DANS
C               L'ORDRE :  XX,YY,ZZ,SQRT(2)*XY,SQRT(2)*XZ,SQRT(2)*YZ
C
C --- DEBUT DECLARATIONS NORMALISEES JEVEUX ----------------------------
C
      CHARACTER*32       JEXNUM , JEXNOM , JEXR8 , JEXATR
      INTEGER            ZI
      COMMON  / IVARJE / ZI(1)
      REAL*8             ZR
      COMMON  / RVARJE / ZR(1)
      COMPLEX*16         ZC
      COMMON  / CVARJE / ZC(1)
      LOGICAL            ZL
      COMMON  / LVARJE / ZL(1)
      CHARACTER*8        ZK8
      CHARACTER*16                ZK16
      CHARACTER*24                          ZK24
      CHARACTER*32                                    ZK32
      CHARACTER*80                                              ZK80
      COMMON  / KVARJE / ZK8(1) , ZK16(1) , ZK24(1) , ZK32(1) , ZK80(1)
C
C --- FIN DECLARATIONS NORMALISEES JEVEUX ------------------------------
C
      REAL*8      VALRES(16)
      REAL*8      E,NU,TROISK,DEUXMU,ALPHAP
      REAL*8      LAMBDA, DH
      REAL*8      TEMP
      REAL*8      KRON(6)
      REAL*8      EM,NUM,TROIKM,DEUMUM,ALPHAM
      REAL*8      DEPSMO, DEPSDV(6),SIGMMO,SIGMDV(6),SIGPMO, SIGPDV(6)
      REAL*8      DEPS(6),DEPS3
      REAL*8      SIGLDV(6), SIGLMO ,SIGMP(6),SIGMPO, SIGMPD(6)
      INTEGER     NDIMSI,IBID
      INTEGER     I,K,L,N
      CHARACTER*2 BL2, FB2, CODRET(16)
      CHARACTER*8 NOMRES(16),MOD
      CHARACTER*8 NOMPAR(3),TYPE
      REAL*8      VALPAM(3),VALPAP(3)
      REAL*8      BENDOM,BENDOP,KDESSM,KDESSP
      REAL*8      HYGRM,HYGRP
      REAL*8      THER
      REAL*8      COEFA, COEFB
      LOGICAL     CPLAN
      DATA        KRON/1.D0,1.D0,1.D0,0.D0,0.D0,0.D0/
C DEB -----------------------------------------------------------------
C
C     -- 1 INITIALISATIONS :
C     ----------------------
C
      BL2 = '  '
      FB2 = 'F '
C
      NDIMSI = 2*NDIM      
C
      DO 100 K=1,NDIMSI
         DO 101 L=1,NDIMSI
            DSIDEP(K,L) = 0.D0
 101     CONTINUE
 100  CONTINUE
C
      IF (.NOT.( COMPOR(1)(1:10) .EQ. 'BAZANT_FD' )) THEN
          CALL UTMESS('F','NMGDES_01',
     &    ' COMPORTEMENT INATTENDU : '//COMPOR(1))
      ENDIF
C
C
C     -- 2 RECUPERATION DES CARACTERISTIQUES
C     ---------------------------------------
      NOMRES(1)='E'
      NOMRES(2)='NU'
      NOMRES(3)='ALPHA'
C
      NOMPAR(1) = 'TEMP'
      NOMPAR(2) = 'HYDR'
      NOMPAR(3) = 'SECH'
      VALPAM(1) = TPMXM
      VALPAM(2) = HYDRM
      VALPAM(3) = SECHM
      VALPAP(1) = TPMXP
      VALPAP(2) = HYDRP
      VALPAP(3) = SECHP
C
      CALL RCVALA ( IMATE,'ELAS',3,NOMPAR,VALPAM,2,
     +                 NOMRES(1),VALRES(1),CODRET(1), FB2 )
      EM  = VALRES(1)
      NUM = VALRES(2)
C
      CALL RCVALA ( IMATE,'ELAS',3,NOMPAR,VALPAM,1,
     +              NOMRES(3),VALRES(3),CODRET(3), BL2 )
      IF ( CODRET(3) .NE. 'OK' ) VALRES(3) = 0.D0
      ALPHAM = VALRES(3)
      DEUMUM = EM/(1.D0+NUM)
      TROIKM = EM/(1.D0-2.D0*NUM)
C    
      CALL RCVALA ( IMATE,'ELAS',3,NOMPAR,VALPAP,2,
     +              NOMRES(1),VALRES(1),CODRET(1), FB2 )
      CALL RCVALA ( IMATE,'ELAS',3,NOMPAR,VALPAP,1,
     +                 NOMRES(3),VALRES(3),CODRET(3), BL2 )
      IF ( CODRET(3) .NE. 'OK' ) VALRES(3) = 0.D0
      ALPHAP = VALRES(3)
      E      = VALRES(1)
      NU     = VALRES(2)
      DEUXMU = E/(1.D0+NU)
      TROISK = E/(1.D0-2.D0*NU)
C
C ------- CARAC. RETRAIT ENDOGENE ET RETRAIT DE DESSICCATION
C
      NOMRES(1)='B_ENDOGE'
      NOMRES(2)='K_DESSIC'
      CALL RCVALA(IMATE,'ELAS',3,NOMPAR,VALPAM,1,
     +            NOMRES(1),VALRES(1),CODRET(1), BL2 )
      IF ( CODRET(1) .NE. 'OK' ) VALRES(1) = 0.D0
      BENDOM = VALRES(1)
C
      CALL RCVALA(IMATE,'ELAS',3,NOMPAR,VALPAP,1,
     +            NOMRES(1),VALRES(1),CODRET(1), BL2 )
      IF ( CODRET(1) .NE. 'OK' ) VALRES(1) = 0.D0
      BENDOP = VALRES(1)
C
      CALL RCVALA(IMATE,'ELAS',3,NOMPAR,VALPAM,1,
     +            NOMRES(2),VALRES(2),CODRET(2), BL2 )
      IF ( CODRET(2) .NE. 'OK' ) VALRES(2) = 0.D0
      KDESSM = VALRES(2)
C
      CALL RCVALA(IMATE,'ELAS',3,NOMPAR,VALPAP,1,
     +            NOMRES(2),VALRES(2),CODRET(2), BL2 )
      IF ( CODRET(2) .NE. 'OK' ) VALRES(2) = 0.D0
      KDESSP = VALRES(2)
C
C  ------- CARACTERISTIQUES FONCTION DE FLUAGE DE DESSICATION
C
      NOMRES(1) = 'LAM_VISC'
         CALL RCVALA(IMATE,'BAZANT_FD',1,NOMPAR,VALPAP,1,
     &               NOMRES(1),VALRES(1),CODRET(1), BL2)
         IF  (CODRET(1) .NE. 'OK')  THEN
             CALL UTMESS ('F','RCVALA_01','IL FAUT DECLARER LAM_VISC
     &                       POUR LE FLUAGE DE DESSICATION INTRINSEQUE')
         ENDIF
         LAMBDA = VALRES(1)
 110  CONTINUE
C
C  -------  HYGROMETRIE H-------------------------
C
      NOMRES(1)='FONC_DESORP'
      CALL RCVALA(IMATE,'ELAS',1,'SECH',SECHM,1,
     &               NOMRES(1),VALRES(1),CODRET(1), FB2)
         IF  (CODRET(1) .NE. 'OK')  THEN
             CALL UTMESS ('F','RCVALA_01','IL FAUT DECLARER FONC_DESORP
     &          SOUS ELAS_FO POUR LE FLUAGE DE DESSICATION INTRINSEQUE  
     &          AVEC SECH COMME PARAMETRE')
         ENDIF
      HYGRM=VALRES(1)
      CALL RCVALA(IMATE,'ELAS',1,'SECH',SECHP,1,
     &               NOMRES(1),VALRES(1),CODRET(1), FB2)
         IF  (CODRET(1) .NE. 'OK')  THEN
             CALL UTMESS ('F','RCVALA_01','IL FAUT DECLARER FONC_DESORP
     &          SOUS ELAS_FO POUR LE FLUAGE DE DESSICATION INTRINSEQUE  
     &          AVEC SECH COMME PARAMETRE')
         ENDIF
      HYGRP=VALRES(1)
C
C--3  CALCUL DE SIGMP(effet de la température),
C   -------------------------------------------
C     SIGLDV et SIGLMO (prédiction élastique)
C   ------------------------------------------
      VIM(1) = HYGRM
      SIGMMO = 0.D0
      DO 113 K =1,3
         SIGMMO = SIGMMO + SIGM(K)
 113  CONTINUE
      SIGMMO = SIGMMO /3.D0
      DO 140 K=1,NDIMSI
         SIGMDV(K) = SIGM(K)- SIGMMO * KRON(K)
         SIGMP(K)=DEUXMU/DEUMUM*SIGMDV(K)+
     &            TROISK/TROIKM*SIGMMO*KRON(K)
140   CONTINUE
      SIGMPO = 0.D0
      DO 116 K =1,3
         SIGMPO = SIGMPO + SIGMP(K)
 116  CONTINUE
      SIGMPO = SIGMPO /3.D0
      DO 127 K=1,NDIMSI
         SIGMPD(K) = SIGMP(K)- SIGMPO * KRON(K)
 127  CONTINUE
C
C
C -------  QUELQUES COEFFICIENTS-------------------------
C
      DH = ABS(HYGRP - HYGRM)
      COEFA = 1.D0 + TROISK*DH*LAMBDA/2.D0
      COEFB = 1.D0 + DEUXMU*DH*LAMBDA/2.D0
C
C -4------ CALCUL DE DEPSMO ET DEPSDV
C
      THER = ALPHAP*(TP-TREF) - ALPHAM*(TM-TREF)
     &     - BENDOP*HYDRP     + BENDOM*HYDRM
     &     + KDESSP*SECHP     - KDESSM*SECHM
      DEPSMO = 0.D0
      DO 111 K=1,3
         DEPS(K)   = DEPST(K)-THER
         DEPS(K+3) = DEPST(K+3)
         DEPSMO = DEPSMO + DEPS(K)
 111  CONTINUE
      DEPSMO = DEPSMO/3.D0
      DO 115 K=1,NDIMSI
         DEPSDV(K)   = DEPS(K) - DEPSMO * KRON(K)
 115  CONTINUE
C
      DO 129 K=1,NDIMSI
         SIGLDV(K)  = SIGMPD(K) + DEUXMU * DEPSDV(K)
 129  CONTINUE
      SIGLMO = SIGMPO +TROISK*DEPSMO
C
C--5-CALCUL DE SIGP
C------------------------
C
      IF ( (OPTION(1:9) .EQ. 'RAPH_MECA') .OR.
     &     (OPTION(1:9) .EQ. 'FULL_MECA')     ) THEN
         DO 117 K = 1,NDIMSI
          SIGPDV(K)=SIGLDV(K)-DEUXMU*DH*LAMBDA/2.D0*SIGMDV(K)
          SIGPDV(K)=SIGPDV(K)/COEFB
 117     CONTINUE
         SIGPMO = SIGLMO-TROISK*DH*LAMBDA/2.D0*SIGMMO
         SIGPMO = SIGPMO/COEFA
         DO 151 K=1,NDIMSI
            SIGP(K)=SIGPDV(K)+SIGPMO*KRON(K)
  151    CONTINUE
C
C--6-CALCUL DE VIP
C------------------------
C
      VIP(1) = VIM(1) + (HYGRP-HYGRM)
      ENDIF
C-- 7 CALCUL DE DSIDEP POUR LA MATRICE TANGENTE
C   -------------------------------------------
      IF ( (OPTION(1:14) .EQ. 'RIGI_MECA_TANG').OR.
     &     (OPTION(1:9)  .EQ. 'FULL_MECA' )        ) THEN
         DO 260 K=1,3
            DO 270 L=1,3
               DSIDEP(K,L) = DSIDEP(K,L)+(TROISK/(3.D0*COEFA))
               DSIDEP(K,L) = DSIDEP(K,L)-DEUXMU/(3.D0*COEFB)
 270        CONTINUE
 260     CONTINUE
         DO 280 K=1,NDIMSI
            DSIDEP(K,K) = DSIDEP(K,K) + DEUXMU/COEFB
 280     CONTINUE
C
      ENDIF
      END
