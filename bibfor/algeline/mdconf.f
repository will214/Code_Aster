      SUBROUTINE MDCONF(TYPFLU, BASE, NOMA, NBM, LNOE, NUOR,
     &                  IIMPR, INDIC, VECI1, VECR1, VECR2,
     &                  VECR3, VECR4, VECR5)
      IMPLICIT NONE
C-----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGELINE  DATE 24/07/2012   AUTEUR PELLET J.PELLET 
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
C    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================
C-----------------------------------------------------------------------
C DESCRIPTION : CALCUL DES PARAMETRES DE COUPLAGE FLUIDE-STRUCTURE POUR
C -----------   DIFFERENTES CONFIGURATION
C               REMPLISSAGE DES OBJETS DE TRAVAIL DEPENDANT DU TYPE
C               DE CONFIGURATION
C
C               APPELANTS : FLUST1, FLUST2, MDITMI
C
C  IN : TYPFLU : NOM DU CONCEPT DE TYPE TYPE_FLUI_STRU DEFINISSANT LA
C                CONFIGURATION ETUDIEE
C  IN : BASE   : NOM DU CONCEPT DE TYPE MODE_MECA DEFINISSANT LA BASE
C                MODALE DU SYSTEME AVANT PRISE EN COMPTE DU COUPLAGE
C  IN : NOMA   : NOM DU CONCEPT DE TYPE MAILLAGE
C  IN : NBM    : NOMBRE DE MODES PRIS EN COMPTE POUR LE COUPLAGE
C  IN : LNOE   : NOMBRE DE NOEUDS DU TUBE OU DU MAILLAGE
C  IN : IIMPR  : PARAMETRE D'IMPRESSION (IMPREESION FICHIER
C  OUT: VECI1  : VECTEUR ENTIER VARIABLE SELON LE TYPE DE CONFIGURATION
C  OUT: VECR1  : VECTEUR REEL VARIABLE SELON LE TYPE DE CONFIGURATION
C  OUT: VECR2  : VECTEUR REEL VARIABLE SELON LE TYPE DE CONFIGURATION
C  OUT: VECR3  : VECTEUR REEL VARIABLE SELON LE TYPE DE CONFIGURATION
C  OUT: VECR4  : VECTEUR REEL VARIABLE SELON LE TYPE DE CONFIGURATION
C  OUT: VECR5  : VECTEUR REEL VARIABLE SELON LE TYPE DE CONFIGURATION
C
C-------------------   DECLARATION DES VARIABLES   ---------------------
C
C -------------------------
      INCLUDE 'jeveux.h'
      CHARACTER*24 VALK(4)
C
C ARGUMENTS
C ---------
      CHARACTER*8   TYPFLU, BASE, NOMA
      INTEGER       NBM, LNOE, NUOR(*), IIMPR, INDIC, VECI1(*)
      INTEGER VALI(2)
      REAL*8        VECR1(*), VECR2(*), VECR3(*), VECR4(*), VECR5(*)

C
C VARIABLES LOCALES
C -----------------
      REAL*8        LP
      CHARACTER*1   K1B
      CHARACTER*8   DEPLA(3), CONFIG(4), DEPL, K8B, MAILLA, MODELE,
     &              NOMNO0
      CHARACTER*14  NUMDDL
      CHARACTER*19  CAELEM, MASSE
      CHARACTER*24   DEEQ, FRHOE, FRHOI, FSIC, FSVI, FSVK, FSVR,
     &              MLGNMA, MLGNNO, NOMCHA, PVITE
C
C FONCTIONS EXTERNES
C ------------------
      REAL*8         R8PREM
      REAL*8 VALR(3)
C     EXTERNAL      R8PI, R8PREM
C     EXTERNAL      JEXNOM
C
C DATA
C ----
C-----------------------------------------------------------------------
      INTEGER IAXE ,IBID ,ICOUPL ,IDE ,IDEEQ ,IDEP ,IFSIC
      INTEGER IFSVI ,IFSVK ,IGRAP ,IK ,IMAIL ,IMOD ,IPAS
      INTEGER IPM ,IPV ,IRE ,IRESZO ,IRET ,IRHOE ,IRHOI
      INTEGER IROTA1 ,IROTA2 ,ITRAN1 ,ITRAN2 ,ITYPFL ,IVALE ,IZONE
      INTEGER J ,KREF ,LFSVK ,LFSVR ,LMASG ,LMASSE ,N1
      INTEGER N2 ,NBMA ,NBMANO ,NEQ ,NUMNO0 ,NUMOD ,NUZO
      INTEGER NZEX
      REAL*8 AIRE ,ALONTO ,CM1 ,CM2 ,COCAJ ,COKAJ ,COMAJ
      REAL*8 COMAJ1 ,COMAJ2 ,DIFPHI ,DRYI ,DRZI ,DYI ,DZI
      REAL*8 EP ,PHI1 ,PHI2 ,PHIE ,PROTA ,PTRAN ,RHOF
      REAL*8 TOLR ,VMOY ,VMOYTO ,X1 ,X2
C-----------------------------------------------------------------------
      DATA DEPLA  /'DX      ','DY      ','DZ      '/
      DATA CONFIG /'ASC_CEN ','ASC_EXC ','DES_CEN ','DES_EXC '/
C
C-------------------   DEBUT DU CODE EXECUTABLE    ---------------------
C
      CALL JEMARQ()
      TOLR = R8PREM()
C
C
C --- 1.TYPE DE CONFIGURATION  ---
C ---   TYPE_FLUI_STRU         ---
C
      FSIC = TYPFLU//'           .FSIC'
      CALL JEVEUO(FSIC,'L',IFSIC)
      ITYPFL = ZI(IFSIC)
      ICOUPL = ZI(IFSIC+1)
C
C
C --- 2.CONFIGURATION DE TYPE FAISCEAU DE TUBE SOUS ECOULEMENT  ---
C ---   TRANSVERSE                                              ---
C
      IF(ITYPFL.EQ.1) THEN
C
         FSVK = TYPFLU//'           .FSVK'
         CALL JEVEUO(FSVK,'L',IFSVK)
C
         FSVI = TYPFLU//'           .FSVI'
         CALL JEVEUO(FSVI,'L',IFSVI)
C
C ---    2.1.NOMBRE DE POINTS DE DISCRETISATION --> VARIABLE INDIC ---
C
         INDIC = LNOE
C
C ---    2.2.DIAMETRE EXTERIEUR DU TUBE  ET EPAISSEUR --> VECTEUR VECR4
C ---        (TEST SI SECTION CONSTANTE)                           ---
C
         CAELEM = ZK8(IFSVK)
         CALL RECUDE(CAELEM,PHIE,EP)
         VECR4(1) = PHIE
         VECR4(2) = EP
C
C ---    2.3.ABSCISSE CURVILIGNES DE VITESSE    --> VECTEUR VECR5  ---
C ---        PROFIL DE MASSE VOLUMIQUE          --> VECTEUR VECR2  ---
C
C ---    CONCEPT DE TYPE FONCTION DEFINISSANT LE PROFIL DE MASSE
C ---    VOLUMIQUE DU FLUIDE EXTERNE ET INTERNE
C
         FRHOE = ZK8(IFSVK+3)
         FRHOI = ZK8(IFSVK+2)
         FRHOE = FRHOE(1:19)//'.VALE'
         FRHOI = FRHOI(1:19)//'.VALE'
         CALL JEVEUO(FRHOE,'L',IRHOE)
         CALL JEVEUO(FRHOI,'L',IRHOI)
C
C ---    ABSCISSE CURVILIGNES
C
         DO 10 IK = 1,LNOE
               VECR5(IK) = ZR(IRHOE+IK-1)
               VECR2(IK) = ZR(IRHOE+IK+LNOE-1)
               VECR2(IK+LNOE)=ZR(IRHOI+IK+LNOE-1)
  10     CONTINUE
C
C ---    2.4.CALCUL DES NUMERO DE ZONE     --> VECTEUR VECI1 ---
C ---        CALCUL DU  PROFIL DE VITESSE  --> VECTEUR VECR1 ---
C                                              DE 1 A LNOE
C ---        CALCUL DES VITESSES MOYENNES
C            PAR ZONE                      --> VECTEUR VECR1
C                                              DE (LNOE+1) A (2*LNOE+1)
C ---        CALCUL DE LA VITESSE MOYENNE  --> VECTEUR VECR1(2*LNOE+1)
C
C ---    A PARTIR DES PROFIL DE VITESSE DE CHAQUE ZONE ON CONSTRUIT UN
C ---    PROFIL UNIQUE, AINSI QUE LES VECTEUR IRES (TYPE DE RESEAU) ET
C ---    VMOY (VITESSE MOYENNE PAR ZONE) DE CHAQUE POINT DU TUBE.
C ---    VMOYTO EST LA VITESSE MOYENNE SUR L ENSEMBLE DES ZONES.
C ---    LES PROFILS DE VITESSE NE SONT PAS NORMES.
C
         VMOYTO = 0.D0
         ALONTO = 0.D0
         NZEX = ZI(IFSVI+1)
         CALL WKVECT('&&MDCONF.TEMPO','V V I',2*NZEX+1,IZONE)
         ZI(IZONE-1+1) = NZEX
C
C ---    BOUCLE SUR LES ZONES D EXCITATION DU FLUIDE
C

         DO 60 NUZO = 1,NZEX
            PVITE = ZK8(IFSVK+3+NUZO)
            IRESZO = ZI(IFSVI+1+NUZO)
            PVITE = PVITE(1:19)//'.VALE'
            CALL JEVEUO(PVITE,'L',IPV)
C ---       RECHERCHE DES EXTREMITES DE LA ZONE 'NUZO'
            N1 = -1
            N2 = -1
            DO 20 IK = 1,LNOE
               IF(ZR(IPV+LNOE+IK-1).NE.0.D0) THEN
                  N1 = IK
                  GOTO 21
               ENDIF
  20        CONTINUE
  21        CONTINUE
C
            DO 30 IK = LNOE,1,-1
               IF(ZR(IPV+LNOE+IK-1).NE.0.D0) THEN
                  N2 = IK
                  GOTO 31
               ENDIF
  30        CONTINUE
  31        CONTINUE
C
            ZI(IZONE + 2*(NUZO-1)-1+2) = N1
            ZI(IZONE + 2*(NUZO-1)-1+3) = N2
            IF(N1.EQ.N2) THEN
                  CALL U2MESK('F','ALGELINE_68',1,ZK8(IFSVK+3+NUZO))
            ENDIF
C
            AIRE = 0.D0
            X1 = ZR(IPV+N1-1)
            X2 = ZR(IPV+N2-1)
            DO 40 IK = N1+1,N2
               AIRE = AIRE + ( ZR(IPV+LNOE+IK-1) + ZR(IPV+LNOE+IK-2) )
     &                     * ( ZR(IPV+IK-1) - ZR(IPV+IK-2) ) / 2.D0
  40        CONTINUE
C
            VMOY = AIRE / (X2-X1)
            VMOYTO = VMOYTO + AIRE
            ALONTO = ALONTO + (X2-X1)
            DO 50 IK = N1,N2
               IF(VECI1(IK).NE.0) THEN
                  CALL U2MESK('F','ALGELINE_69',1,ZK8(IFSVK+3+NUZO))
               ENDIF
               VECR1(IK+LNOE) = VMOY
               VECI1(IK) = IRESZO
               VECR1(IK) = ZR(IPV+LNOE+IK-1)
  50        CONTINUE
C
            CALL JELIBE(PVITE)
C
C ---    FIN DE BOUCLE SUR LES ZONES D EXCITATION DU FLUIDE
  60     CONTINUE
C
C ---    VITESSE MOYENNE SUR L'ENSEMBLE DU TUBE
         VMOYTO = VMOYTO / ALONTO
         VECR1(1+2*LNOE) = VMOYTO
C
C
C ---   2.5.DEFORMEES MODALES    --> VECTEUR VECR3  ---
C
        IF (ICOUPL.EQ.1) THEN
C
C ---      DIRECTION DANS LAQUELLE AGISSENT LES FORCES FLUIDELASTIQUES
           IDEP = 0
           DEPL = ZK8(IFSVK+1)
           DO 70 IDE = 1,3
              IF ( DEPLA(IDE) .EQ. DEPL ) IDEP = IDE
  70       CONTINUE
C
C
C ---       DEFORMEES MODALES
C
            CALL JEVEUO ( BASE//'           .REFD' , 'L', KREF )
            MASSE = ZK24(KREF+1)(1:19)
            CALL MTDSCR ( MASSE )
            CALL JEVEUO ( MASSE//'.&INT' , 'L' , LMASSE )
            CALL DISMOI('F','NOM_NUME_DDL',MASSE,
     &                  'MATR_ASSE',IBID,NUMDDL,IRE)
            CALL DISMOI('F','NOM_MAILLA'  ,MASSE,
     &                  'MATR_ASSE',IBID,MAILLA,IRE)
            CALL DISMOI('F','NB_EQUA'     ,MASSE,
     &                  'MATR_ASSE',NEQ ,K8B   ,IRE)
C
            CALL EXTMOD(BASE,NUMDDL,NUOR,NBM,VECR3,NEQ,LNOE,IDEP,1)
C
         ENDIF
C
C
C ---   2.6.IMPRESSION  ---
C
        IF(IIMPR.EQ.1) THEN
          IPAS = ZI(IFSVI)
          VALI (1) = LNOE
          VALI (2) = IPAS
          VALK (1) = BASE
          VALK (2) = CAELEM(1:8)
          VALR (1) = PHIE
          CALL U2MESG('I','ALGELINE5_10',2,VALK,2,VALI,1,VALR)
          DO 170 NUZO = 1,NZEX
            VALK (1) = ZK8(IFSVK+NUZO+3)
            VALI (1) = ZI(IFSVI+NUZO+1)
            CALL U2MESG('I','ALGELINE5_11',1,VALK,1,VALI,0,0.D0)
 170      CONTINUE
          CALL U2MESS('I','VIDE_1')
        ENDIF
C
C --- 3.CONFIGURATION DE TYPE "GRAPPE DE COMMANDE"  ---
C
      ELSE IF(ITYPFL.EQ.2) THEN
C
        IF (ICOUPL.EQ.1) THEN
C
         FSVK = TYPFLU//'           .FSVK'
         CALL JEVEUO(FSVK,'L',LFSVK)
C
         FSVR = TYPFLU//'           .FSVR'
         CALL JEVEUO(FSVR,'L',LFSVR)
C
C------- 3.1.CREATION D'OBJETS DE TRAVAIL
C
         MLGNMA = NOMA//'.NOMMAI'
         CALL JELIRA(MLGNMA,'NOMMAX',NBMA,K1B)
         CALL WKVECT('&&MDCONF.TEMP.MAIL' ,'V V I',NBMA ,IMAIL )
C
C
C------- RECUPERATION DES DONNEES DANS LE CONCEPT TYPE_FLUI_STRU
C        DEDUCTION DE DONNEES COMPLEMENTAIRES
C
C ---    3.2.TYPE DE CONFIGURATION GRAPPE --> VARIABLE INDIC ---
C
         DO 120 IGRAP = 1,4
            IF (ZK8(LFSVK).EQ.CONFIG(IGRAP)) GOTO 121
 120     CONTINUE
 121     CONTINUE
         INDIC = IGRAP
         NOMNO0 = ZK8(LFSVK+1)
         MLGNNO = NOMA//'.NOMNOE'
         CALL JENONU(JEXNOM(MLGNNO,NOMNO0),NUMNO0)
         CAELEM = ZK8(LFSVK+2)
         MODELE = ZK8(LFSVK+3)
         CM1  = ZR(LFSVR)
         CM2  = CM1/3.D0
         RHOF = ZR(LFSVR+1)

C ---    3.3.DIAMETRE EXTERIEUR DU TUBE         --> VECTEUR VECR4  ---
C
         CALL EXMANO(NOMA,NUMNO0,ZI(IMAIL),NBMANO)
         IF (NBMANO.NE.2) CALL U2MESS('F','ALGELINE_70')
C
         CALL DEELPO(CAELEM(1:8),NOMA,ZI(IMAIL)  ,PHI1)
         CALL DEELPO(CAELEM(1:8),NOMA,ZI(IMAIL+1),PHI2)
         DIFPHI = DBLE(ABS(PHI1-PHI2))
         IF (DIFPHI.GT.PHI1*TOLR) THEN
           CALL U2MESS('F','ALGELINE_71')
         ELSE
            PHIE = PHI1
         ENDIF
C
         VECR4(1) = PHIE
C
C------- 3.4.RECUPERATION DES GRANDEURS GEOMETRIQUES CARACTERISTIQUES --
C        DEDUCTION DE COEFFICIENTS DE DIMENSIONNEMENT                ---
C ---                                            --> VECTEUR VECR2   ---
C
         LP = PHIE * 986.D0/890.D0
C
         COMAJ = 0.5D0*RHOF*PHIE*PHIE*LP
         COMAJ1 = COMAJ*CM1
         COMAJ2 = COMAJ*CM2*LP*LP
C
         COCAJ = -0.5D0*RHOF*PHIE*LP
         VECR2(1) = COCAJ
         VECR2(2) = COCAJ*LP*LP*0.12849663D0
C
         COKAJ = -0.5D0*RHOF*LP
         VECR2(3) = COKAJ
         VECR2(4) = COKAJ*LP*LP*0.12849663D0
C
C------- DETERMINATION DE L'AXE DIRECTEUR DE LA POUTRE
C        DEDUCTION DES DDLS A EXTRAIRE
C
         CALL AXDIPO(NOMA,CAELEM(1:8),MODELE,IAXE)
C
         IF (IAXE.EQ.1) THEN
           ITRAN1 = 2
           ITRAN2 = 3
           IROTA1 = 6
           IROTA2 = 5
         ELSE IF (IAXE.EQ.2) THEN
           ITRAN1 = 3
           ITRAN2 = 1
           IROTA1 = 4
           IROTA2 = 6
         ELSE
           ITRAN1 = 1
           ITRAN2 = 2
           IROTA1 = 5
           IROTA2 = 4
         ENDIF
C
C------- 3.5.PONDERATIONS DUES AUX DEFORMEES MODALES
C                                                --> VECTEUR VECR3  ---
C            MASSES MODALES EN EAU               --> VECTEUR VECR1  ---
C
         CALL JEVEUO ( BASE//'           .REFD' , 'L', KREF )
         MASSE = ZK24(KREF+1)(1:19)
         CALL MTDSCR ( MASSE )
         CALL JEVEUO ( MASSE//'.&INT' , 'L' , LMASSE )
         CALL DISMOI('F','NOM_NUME_DDL',MASSE,
     &               'MATR_ASSE',IBID,NUMDDL,IRE)
         CALL DISMOI('F','NOM_MAILLA'  ,MASSE,
     &               'MATR_ASSE',IBID,MAILLA,IRE)
         CALL DISMOI('F','NB_EQUA'     ,MASSE,
     &               'MATR_ASSE',NEQ ,K8B   ,IRE)
         DEEQ = NUMDDL//'.NUME.DEEQ'
         CALL JEVEUO(DEEQ,'L',IDEEQ)
C
         DO 140 IMOD = 1,NBM
C
            NUMOD = NUOR(IMOD)
C
            CALL RSADPA(BASE,'L',1,'MASS_GENE',NUMOD,0,LMASG,K8B)
C
            CALL RSEXCH('F',BASE,'DEPL',NUMOD,NOMCHA,IRET)
            NOMCHA = NOMCHA(1:19)//'.VALE'
            CALL JEVEUO(NOMCHA,'L',IVALE)
            IPM = 0
            DYI = 0.D0
            DZI = 0.D0
            DRYI = 0.D0
            DRZI = 0.D0
            DO 130 J = 1,NEQ
               IF (ZI(IDEEQ+(2*J)-1) .EQ. 1) THEN
                  IPM = IPM + 1
               ENDIF
               IF (IPM .EQ. NUMNO0) THEN
                  IF (ZI(IDEEQ+(2*J)-1) .EQ. ITRAN1) THEN
                     DYI  = ZR(IVALE+J-1)
                  ELSE IF (ZI(IDEEQ+(2*J)-1) .EQ. ITRAN2) THEN
                     DZI  = ZR(IVALE+J-1)
                  ELSE IF (ZI(IDEEQ+(2*J)-1) .EQ. IROTA1) THEN
                     DRZI = ZR(IVALE+J-1)
                  ELSE IF (ZI(IDEEQ+(2*J)-1) .EQ. IROTA2) THEN
                     DRYI = ZR(IVALE+J-1)
                  ENDIF
               ELSE IF (IPM .EQ. (NUMNO0+1)) THEN
                  GOTO 131
               ENDIF
 130        CONTINUE
 131        CONTINUE
            PTRAN = DYI*DYI + DZI*DZI
            PROTA = DRZI*DRZI + DRYI*DRYI
            VECR3(2*IMOD-1)   = PTRAN
            VECR3(2*IMOD) = PROTA
            CALL JELIBE(NOMCHA)
C
            VECR1(IMOD) = ZR(LMASG) + COMAJ1*PTRAN + COMAJ2*PROTA
C
 140     CONTINUE
C
C
C ---   2.6.IMPRESSION  ---
C
        IF(IIMPR.EQ.1) THEN
      VALK (1) = NOMNO0
      VALK (2) = BASE
      VALK (3) = CAELEM(1:8)
      VALK (4) = CONFIG(INDIC)
      VALR (1) = PHIE
      VALR (2) = CM1
      VALR (3) = RHOF
      CALL U2MESG('I','ALGELINE5_13',4,VALK,0,0,3,VALR)
        ENDIF
C
         CALL JEDETC('V','&&MDCONF',1)
C
       ELSE
C ---  PAS DE COUPLAGE
C
        IF(IIMPR.EQ.1) THEN
      CALL U2MESG('I','ALGELINE5_14',0,' ',0,0,0,0.D0)
        ENDIF
C
       ENDIF
C
C --- 4.AUTRES CONFIGURATIONS NON TRAITEES  ---
C
      ELSE
C
         CALL U2MESS('S','ALGELINE_72')
C
      ENDIF
C
      CALL JEDEMA()
C
C --- FIN DE MDCONF.
      END
