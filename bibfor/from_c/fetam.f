      SUBROUTINE FETAM(OPTMPI,NBSD,IFM,NIV,RANG,NBPROC,ACH24,ACH241,
     &                 ACH242,ARGR1)
C-----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF FROM_C  DATE 07/09/2009   AUTEUR PELLET J.PELLET 
C ======================================================================
C COPYRIGHT (C) 1991 - 2005  EDF R&D                  WWW.CODE-ASTER.ORG
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
C TOLE CRS_200
C TOLE CRS_505
C TOLE CRS_506
C TOLE CRS_507
C-----------------------------------------------------------------------
C    - FONCTION REALISEE:  APPELS MPI POUR FETI
C               PENDANT DE FETSM.F, TOUS DEUX APPELES PAR FETMPI.C
C
C ARGUMENTS D'APPELS
C IN OPTMPI  : OPTION DE LA ROUTINE (CHANGER NBOPT DANS LE SOURCE SI
C               VOUS MODIFIER LE NBRE D'OPTIONS)
C    =1        CREATION OBJET JEVEUX  '&FETI.LISTE.SD.MPI' POUR BOUCLE
C              SUR LES SOUS-DOMAINES PARALLELISEE
C    =2        RANG DU PROCESSUS
C    =3        NOMBRE DE PROCESSEURS
C    =4 OU 5   REDUCTION SUR L'OBJET ACH24 (MPI_INTEGER OU MPI_DOUBLE
C              _PRECISION AVEC SUBTILITE QUANT AU NBRE DE DONNEES)
C    =6        REDUCTION PUIS DIFFUSION SUR L'OBJET ACH24
C    =7        REDUCTION SUR L'OBJET ACH24 EN MPI_DOUBLE_PRECISION
C    =8        COLLECTE SELECTIVE DE L'OBJET ACH24 PAR UN MPI_GATHERV
C    =9        DISTRIBUTION DE L'OBJET ACH24
C    =10       DISTRIBUTION DU REEL ARGR1
C    =71       IDEM QUE 7 PUIS DIFFUSION A TOUS LES PROCS
C IN NBSD    : NOMBRE DE SOUS-DOMAINES SI OPTMI=1
C              TAILLE DU MPI_** SI OPTMPI=4,5,6,7, 71 OU 9
C IN IFM,NIV : NIVEAU D'IMPRESSION (SI NIV.GE.2 IMPRESSION, DOIT ETRE
C              CONTROLE PAR INFOFE(10:10)
C IN  ACH24  : ARGUMENT CH24 POUR OPTMPI=4,5,6,7,71,8 OU 9
C IN  ACH241 : ARGUMENT CH24 POUR OPTMPI=8
C IN  ACH242 : ARGUMENT CH24 POUR OPTMPI=8
C IN  ARGR1  : ARGUMENR REEL POUR OPTMPI=10
C IN/OUT RANG: RANG DU PROCESSUS SI OPTMPI=1,2 OU 8
C IN/OUT NBPROC : RANG DU PROCESSUS SI OPTMPI=1,3 OU 8
C----------------------------------------------------------------------
C RESPONSABLE BOITEAU O.BOITEAU
C CORPS DU PROGRAMME
      IMPLICIT NONE
      INCLUDE 'mpif.h'
C DECLARATION PARAMETRES D'APPELS
      INTEGER      OPTMPI,IFM,NIV,NBSD,NBPROC,RANG
      CHARACTER*24 ACH24,ACH241,ACH242
      REAL*8       ARGR1

C --- DEBUT DECLARATIONS NORMALISEES JEVEUX ----------------------------
      INTEGER*4          ZI4
      COMMON  / I4VAJE / ZI4(1)
      INTEGER ZI
      COMMON /IVARJE/ZI(1)
      REAL*8 ZR
      COMMON /RVARJE/ZR(1)
      COMPLEX*16 ZC
      COMMON /CVARJE/ZC(1)
      CHARACTER*8 ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C --- FIN DECLARATIONS NORMALISEES JEVEUX ------------------------------

C DECLARATION VARIABLES LOCALES
      INTEGER      IAUX1,MOD,DIV,IDD,NBSD1,ILIST,IEXIST,IRED,I,IACH
      INTEGER      IRED2,IAUX2,IAUX3,IAUX4,DECAL,RANG1,IBID,IPROC2
      INTEGER      ILIST1,IMAX,IPROC,NBPRO1,IPROC1,NBSDP0,IACH1,IACH2
      INTEGER      IMON,NBOPT,OPT,VALI(2),LOISEM
      INTEGER*4    NBPRO4,RANG4,NBSD4,IERMPI,NBSD41,LR8,LINT,
     &             LENSER,IERMP2
      CHARACTER*8  K8BID
      CHARACTER*24 NOM1,NOMLOG,NOMLO1,NOMMON
      REAL*8       TEMPS(6)
      LOGICAL      LSTOGI,FIRST
      SAVE         LR8,LINT,FIRST
      DATA         FIRST /.TRUE./

C CORPS DU PROGRAMME
      CALL JEMARQ()
C INITS.
      IF (FIRST) THEN
C POUR LA GESTION DES ERREURS PAR LE DEVELOPPEUR
        CALL MPI_ERRHANDLER_SET(MPI_COMM_WORLD,MPI_ERRORS_RETURN,IERMPI)
        CALL FETMER(IERMPI)
        IF (LOISEM().EQ.8) THEN
          LINT=MPI_INTEGER8
        ELSE
          LINT=MPI_INTEGER
        ENDIF
        LR8 = MPI_DOUBLE_PRECISION
        FIRST= .FALSE.
      ENDIF
      NBSD4=NBSD
C NBRE D'OPTION DE FETAM
      NBOPT=11*2
C POUR LE MONITORING DU PARALLELISME
      IF (NIV.GE.2) THEN
        NOMMON='&FETI.MONITORING.MPI'
        CALL JEEXIN(NOMMON,IEXIST)
        IF (IEXIST.EQ.0) THEN
          CALL WKVECT(NOMMON,'V V R',NBOPT,IMON)
          CALL JERAZO(NOMMON,NBOPT,1)
        ELSE
          CALL JEVEUO(NOMMON,'E',IMON)
        ENDIF
      ENDIF
C RANG DU PROCESSEUR POUR LIMITER LES AFFICHAGES
      IF (NIV.GE.2) THEN
        CALL MPI_COMM_RANK(MPI_COMM_WORLD,RANG4,IERMPI)
        CALL FETMER(IERMPI)
        RANG=RANG4
        IF (RANG.NE.0) NIV=0
      ENDIF

C---------------------------------------------- OPTION = 1
      IF (OPTMPI.EQ.1) THEN
C POUR LE MONITORING DU PARALLELISME
        IF (NIV.GE.2) THEN
          CALL UTTCPU('CPU.FETAM.1','INIT',' ')
          CALL UTTCPU('CPU.FETAM.1','DEBUT',' ')
        ENDIF
        NBSD1=NBSD+1
C OBJET TEMPORAIRE POUR PARALLELISME MPI:
C ZI(ILIST+I)=1 IEME SOUS-DOMAINE CALCULE PAR PROCESSEUR COURANT
C            =0 ELSE
        NOMLOG='&FETI.LISTE.SD.MPI'
        CALL JEEXIN(NOMLOG,IEXIST)
C SI L OBJET NOMLOG EXISTE DEJA : ARRET
        CALL ASSERT(IEXIST.EQ.0)
        CALL WKVECT(NOMLOG,'V V I',NBSD1,ILIST)
C OBJET TEMPORAIRE POUR PARALLELISME MPI:
C ZI(ILIST1+I-1)=NUMERO DU PROCESSEUR QUI LE CONCERNE
        NOMLO1='&FETI.LISTE.SD.MPIB'
        CALL JEEXIN(NOMLO1,IEXIST)
C SI L OBJET NOMLO1 EXISTE DEJA : ARRET
        CALL ASSERT(IEXIST.EQ.0)
        CALL WKVECT(NOMLO1,'V V I',NBSD,ILIST1)

        CALL MPI_COMM_SIZE(MPI_COMM_WORLD,NBPRO4,IERMPI)
        CALL FETMER(IERMPI)
        NBPROC=NBPRO4
        CALL MPI_COMM_RANK(MPI_COMM_WORLD,RANG4,IERMPI)
        CALL FETMER(IERMPI)
        RANG=RANG4
        IF (NBPROC.GT.1) THEN
C ON EST EN PARALLELE, L'UTILISATEUR A PEUT-ETRE EMIS UN SOUHAIT QUANT
C AU NBRE DE SD POUR LE PROCESSEUR MAITRE
          CALL GETVIS(ACH24(1:16),'NB_SD_PROC0',1,1,1,NBSDP0,IBID)
          IF ((NBSD-NBSDP0).LT.(NBPROC-1))
     &      CALL U2MESS('F','APPELMPI_3')
        ELSE
          NBSDP0=0
        ENDIF
C DECOUPAGE DU TRAVAIL PAR PROCESSEUR. POUR FACILITER LE TRAVAIL DES
C ENVOI DE MODES RIGIDES ON PREFERE GROUPER LES SD PAR SOUS-DOMAINES
C D'AUTRE PART, ON SOULAGE D'UN POINT DE VUE MEMOIRE, SI POSSIBLE LE
C PROCESSEUR DE RANG 0 QUI AURA AUSSI A STOCKER GI, GIT*GI ET LES VEC
C TEURS DE REORTHO. DONC, SI NBPROC < NBSD, ON REDISTRIBUE LES SD COMP
C LEMENTAIRES EN COMMENCANT PAR LE PROC 1
C EXEMPLE: 8 SD ET 4 PROC
C PROC 0 : SD1/SD2
C PROC 1 : SD3/SD4
C ...
C EXEMPLE: 9 SD ET 4 PROC
C PROC 0 : SD1/2
C PROC 1 : SD3/SD4/SD5
C PROC 2 : SD6/SD7
C...
C DOMAINE GLOBALE (IDD=0) CONCERNE TOUS LES PROCESSEURS
        ZI(ILIST)=1
        DO 90 IDD=1,NBSD
          ZI(ILIST+IDD)=0
          ZI(ILIST1+IDD-1)=0
   90   CONTINUE
        IF (NBSDP0.EQ.0) THEN
          IAUX1=NBSD/NBPROC
          IAUX4=NBSD-(NBPROC*IAUX1)
          IPROC2=0
        ELSE
C ATTRIBUTIONS DU PROC 0
          DO 92 IDD=1,NBSDP0
            IF (RANG.EQ.0) ZI(ILIST+IDD)=1
            ZI(ILIST1+IDD-1)=0
   92     CONTINUE
C RESTE AUX AUTRES PROC
          IAUX1=(NBSD-NBSDP0)/(NBPROC-1)
          IAUX4=(NBSD-NBSDP0)-((NBPROC-1)*IAUX1)
          IPROC2=1
        ENDIF
        NBPRO1=NBPROC-1
        DO 100 IPROC=IPROC2,NBPRO1
C INDICE RELATIF DU PROCESSEUR A EQUILIBRER
          IPROC1=IPROC-IPROC2
C BORNES DES SDS A LUI ATTRIBUER
          IAUX2=1+NBSDP0+IPROC1*IAUX1
          IAUX3=NBSDP0+(IPROC1+1)*IAUX1
C CALCUL D'UN DECALAGE EVENTUEL DU AU RELIQUAT DE SD
          IF (IAUX4.LT.IPROC1) THEN
            DECAL=IAUX4
          ELSE
            IF (IPROC1.EQ.0) THEN
              DECAL=0
            ELSE
              DECAL=IPROC1-1
              IAUX3=IAUX3+1
            ENDIF
          ENDIF
C ATTRIBUTIONS SD/PROC
          DO 95 IDD=IAUX2,IAUX3
            IF (IPROC.EQ.RANG) ZI(ILIST+DECAL+IDD)=1
            ZI(ILIST1+DECAL+IDD-1)=IPROC
   95     CONTINUE
  100   CONTINUE

C MONITORING
        IF (NIV.GE.2) THEN
          CALL UTTCPU('CPU.FETAM.1','FIN',' ')
          CALL UTTCPR('CPU.FETAM.1',6,TEMPS)
          ZR(IMON+2*(OPTMPI-1))  =ZR(IMON+2*(OPTMPI-1))  +TEMPS(5)
          ZR(IMON+2*(OPTMPI-1)+1)=ZR(IMON+2*(OPTMPI-1)+1)+TEMPS(6)
          CALL UTIMSD(IFM,2,.FALSE.,.TRUE.,NOMLOG(1:19),1,'V')
          CALL UTIMSD(IFM,2,.FALSE.,.TRUE.,NOMLO1(1:19),1,'V')
          WRITE(IFM,*)'<FETI/FETAM> REPARTITION SD/PROC RANG/NBPROC ',
     &                RANG,NBPROC
        ENDIF

C---------------------------------------------- OPTION = 2
      ELSE IF (OPTMPI.EQ.2) THEN
        IF (NIV.GE.2) THEN
          CALL UTTCPU('CPU.FETAM.2','INIT',' ')
          CALL UTTCPU('CPU.FETAM.2','DEBUT',' ')
        ENDIF
C DETERMINATION DU RANG D'UN PROCESSUS (RANG)
        CALL MPI_COMM_RANK(MPI_COMM_WORLD,RANG4,IERMPI)
        CALL FETMER(IERMPI)
        RANG=RANG4
C MONITORING
        IF (NIV.GE.2) THEN
          CALL UTTCPU('CPU.FETAM.2','FIN',' ')
          CALL UTTCPR('CPU.FETAM.2',6,TEMPS)
          ZR(IMON+2*(OPTMPI-1))  =ZR(IMON+2*(OPTMPI-1))  +TEMPS(5)
          ZR(IMON+2*(OPTMPI-1)+1)=ZR(IMON+2*(OPTMPI-1)+1)+TEMPS(6)
          WRITE(IFM,*)'<FETI/FETAM> RANG ',RANG
        ENDIF

C---------------------------------------------- OPTION = 3
      ELSE IF (OPTMPI.EQ.3) THEN
        IF (NIV.GE.2) THEN
          CALL UTTCPU('CPU.FETAM.3','INIT',' ')
          CALL UTTCPU('CPU.FETAM.3','DEBUT',' ')
        ENDIF
C DETERMINATION DU NOMBRE DE PROCESSEURS (NBPROC)
        CALL MPI_COMM_SIZE(MPI_COMM_WORLD,NBPRO4,IERMPI)
        CALL FETMER(IERMPI)
        NBPROC=NBPRO4
C MONITORING
        IF (NIV.GE.2) THEN
          CALL UTTCPU('CPU.FETAM.3','FIN',' ')
          CALL UTTCPR('CPU.FETAM.3',6,TEMPS)
          ZR(IMON+2*(OPTMPI-1))  =ZR(IMON+2*(OPTMPI-1))  +TEMPS(5)
          ZR(IMON+2*(OPTMPI-1)+1)=ZR(IMON+2*(OPTMPI-1)+1)+TEMPS(6)
          WRITE(IFM,*)'<FETI/FETAM> RANG/NBPROC ',RANG,NBPROC
        ENDIF

C---------------------------------------------- OPTION = 4,5,6,7,71
      ELSE IF (((OPTMPI.GE.4).AND.(OPTMPI.LE.7)).OR.
     &          (OPTMPI.EQ.71)) THEN
        IF (NIV.GE.2) THEN
          CALL UTTCPU('CPU.FETAM.4','INIT',' ')
          CALL UTTCPU('CPU.FETAM.4','DEBUT',' ')
        ENDIF
C REDUCTION DU VECTEUR ACH24 POUR LE PROCESSEUR MAITRE
C PAR EXEMPLE, L'OBJET JEVEUX MATR_ASSE.FETH
        CALL JEVEUO(ACH24,'E',IACH)
        CALL GCNCON('.',K8BID)
        NOM1='&&REDUCE'//K8BID
        NBSD1=NBSD-1
        IF ((OPTMPI.EQ.4).OR.(OPTMPI.EQ.6)) THEN
          CALL WKVECT(NOM1,'V V I',NBSD,IRED)
          DO 400 I=0,NBSD1
            ZI(IRED+I)=ZI(IACH+I)
  400     CONTINUE
        ELSE IF ((OPTMPI.EQ.5).OR.(OPTMPI.EQ.7).OR.(OPTMPI.EQ.71)) THEN
          CALL WKVECT(NOM1,'V V R',NBSD,IRED)
          DO 402 I=0,NBSD1
            ZR(IRED+I)=ZR(IACH+I)
  402     CONTINUE
        ENDIF
        IF (OPTMPI.EQ.4) THEN
          CALL MPI_REDUCE(ZI(IRED),ZI(IACH),NBSD4,LINT,MPI_SUM,0,
     &                    MPI_COMM_WORLD,IERMPI)
        ELSE IF (OPTMPI.EQ.5) THEN
C PROFILER POUR LES OBJETS JEVEUX '&FETI.INFO.CPU' QUI NE DOIVENT PAS
C CONTENIR L'INFO REDONDANTE DU PREMIER INDICE (TEMPS CONCERNANT LA MAT
C RICE GLOBALE COMMUNE A TOUS LES PROCESSEURS)
          NBSD41=NBSD4-1
          CALL MPI_REDUCE(ZR(IRED+1),ZR(IACH+1),NBSD41,LR8,MPI_SUM,0,
     &                    MPI_COMM_WORLD,IERMPI)
        ELSE IF (OPTMPI.EQ.6) THEN
          CALL MPI_ALLREDUCE(ZI(IRED),ZI(IACH),NBSD4,LINT,MPI_SUM,
     &                       MPI_COMM_WORLD,IERMPI)
        ELSE IF (OPTMPI.EQ.7) THEN
          CALL MPI_REDUCE(ZR(IRED),ZR(IACH),NBSD4,LR8,MPI_SUM,0,
     &                    MPI_COMM_WORLD,IERMPI)
        ELSE IF (OPTMPI.EQ.71) THEN
          CALL MPI_ALLREDUCE(ZR(IRED),ZR(IACH),NBSD4,LR8,MPI_SUM,
     &                       MPI_COMM_WORLD,IERMPI)
        ENDIF
        CALL FETMER(IERMPI)
        CALL JEDETR(NOM1)

C MONITORING
        IF (NIV.GE.2) THEN
          CALL UTTCPU('CPU.FETAM.4','FIN',' ')
          CALL UTTCPR('CPU.FETAM.4',6,TEMPS)
C GLUTE STUPIDE POUR NE PAS CHANGER LE  EN 11
          IF (OPTMPI.EQ.71) THEN
            OPT=11
          ELSE
            OPT=OPTMPI
          ENDIF
          ZR(IMON+2*(OPT-1))  =ZR(IMON+2*(OPT-1))  +TEMPS(5)
          ZR(IMON+2*(OPT-1)+1)=ZR(IMON+2*(OPT-1)+1)+TEMPS(6)
          IF ((OPTMPI.NE.6).AND.(OPTMPI.NE.71)) THEN
            WRITE(IFM,*)'<FETI/FETAM> RANG/MPI_REDUCE ENTIER',
     &                 RANG,ACH24
          ELSE
            WRITE(IFM,*)'<FETI/FETAM> RANG/MPI_ALLREDUCE REEL',
     &                 RANG,ACH24
          ENDIF
        ENDIF

C---------------------------------------------- OPTION = 8
      ELSE IF (OPTMPI.EQ.8) THEN
        IF (NIV.GE.2) THEN
          CALL UTTCPU('CPU.FETAM.5','INIT',' ')
          CALL UTTCPU('CPU.FETAM.5','DEBUT',' ')
        ENDIF
C COLLECTE SELECTIVE DU VECTEUR ACH24 POUR LE PROCESSEUR MAITRE
        CALL JEVEUO(ACH241,'E',IACH1)
        CALL JEVEUO(ACH242,'E',IACH2)
        CALL JEVEUO(ACH24,'E',IACH)
        IF (NBSD.NE.0) THEN
          CALL GCNCON('.',K8BID)
          NOM1='&&GATHERV'//K8BID
          CALL WKVECT(NOM1,'V V R',NBSD,IRED)
          DO 500 I=1,NBSD
            ZR(IRED+I-1)=ZR(IACH+I-1)
  500     CONTINUE
        ENDIF
        CALL MPI_GATHERV(ZR(IRED),NBSD4,LR8,ZR(IACH),ZI4(IACH1),
     &                   ZI4(IACH2),LR8,0,MPI_COMM_WORLD,IERMPI)
        CALL FETMER(IERMPI)

        IF (NBSD.NE.0) CALL JEDETR(NOM1)
C MONITORING
        IF (NIV.GE.2) THEN
          CALL UTTCPU('CPU.FETAM.5','FIN',' ')
          CALL UTTCPR('CPU.FETAM.5',6,TEMPS)
          ZR(IMON+2*(OPTMPI-1))  =ZR(IMON+2*(OPTMPI-1))  +TEMPS(5)
          ZR(IMON+2*(OPTMPI-1)+1)=ZR(IMON+2*(OPTMPI-1)+1)+TEMPS(6)
          WRITE(IFM,*)'<FETI/FETAM> RANG/MPI_GATHERV ',RANG,ACH24
C          CALL UTIMSD(IFM,2,.TRUE.,.TRUE.,ACH241(1:19),1,'V')
C          CALL UTIMSD(IFM,2,.TRUE.,.TRUE.,ACH242(1:19),1,'V')
        ENDIF

C---------------------------------------------- OPTION = 9
      ELSE IF (OPTMPI.EQ.9) THEN
        IF (NIV.GE.2) THEN

          CALL UTTCPU('CPU.FETAM.6','INIT',' ')
          CALL UTTCPU('CPU.FETAM.6','DEBUT',' ')
        ENDIF
C DISTRIBUTION DU VECTEUR ACH24 PAR LE PROCESSEUR MAITRE A TOUS
C LES AUTRES PROCS
        CALL JEVEUO(ACH24,'E',IACH)
        CALL MPI_BCAST(ZR(IACH),NBSD4,LR8,0,MPI_COMM_WORLD,IERMPI)
        CALL FETMER(IERMPI)

C MONITORING
        IF (NIV.GE.2) THEN
          CALL UTTCPU('CPU.FETAM.6','FIN',' ')
          CALL UTTCPR('CPU.FETAM.6',6,TEMPS)
          ZR(IMON+2*(OPTMPI-1))  =ZR(IMON+2*(OPTMPI-1))  +TEMPS(5)
          ZR(IMON+2*(OPTMPI-1)+1)=ZR(IMON+2*(OPTMPI-1)+1)+TEMPS(6)
          WRITE(IFM,*)'<FETI/FETAM> RANG/MPI_BCAST ',RANG,ACH24
        ENDIF

C---------------------------------------------- OPTION = 10
      ELSE IF (OPTMPI.EQ.10) THEN
        IF (NIV.GE.2) THEN
          CALL UTTCPU('CPU.FETAM.7','INIT',' ')
          CALL UTTCPU('CPU.FETAM.7','DEBUT',' ')
        ENDIF
C DISTRIBUTION DU REEL ARGR1 PAR LE PROCESSEUR MAITRE A TOUS
C LES AUTRES PROCS
        CALL MPI_BCAST(ARGR1,1,LR8,0,MPI_COMM_WORLD,IERMPI)
        CALL FETMER(IERMPI)

C MONITORING
        IF (NIV.GE.2) THEN
          CALL UTTCPU('CPU.FETAM.7','FIN',' ')
          CALL UTTCPR('CPU.FETAM.7',6,TEMPS)
          ZR(IMON+2*(OPTMPI-1))  =ZR(IMON+2*(OPTMPI-1))  +TEMPS(5)
          ZR(IMON+2*(OPTMPI-1)+1)=ZR(IMON+2*(OPTMPI-1)+1)+TEMPS(6)
          WRITE(IFM,*)'<FETI/FETAM> RANG/MPI_BCAST ',RANG,ARGR1
        ENDIF

C---------------------------------------------- OPTION
C <1 OU >10 OU DIFFERENT DE 71
      ELSE
        CALL MPI_COMM_RANK(MPI_COMM_WORLD,RANG4,IERMPI)
        CALL FETMER(IERMPI)
        VALI(1)=RANG4
        VALI(2)=OPTMPI
        CALL U2MESI('F','APPELMPI_4',2,VALI)
      ENDIF
      CALL JEDEMA()
      END
