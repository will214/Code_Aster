      SUBROUTINE PJEFPR(RESU1,RESU2,MODEL2,CORRES)
C RESPONSABLE VABHHTS J.PELLET
C A_UTIL
C ---------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF CALCULEL  DATE 19/06/2006   AUTEUR VABHHTS J.PELLET 
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
C BUT :
C  PROJETER LES CHAMPS CONTENUS DANS LA SD RESU1
C  SUR LE MODELE MODEL2
C  ET CREER UNE NOUVELLE SD RESU2 DE MEME TYPE QUE RESU1
C
C  IN/JXIN  RESU1   K8  : NOM DE LA SD_RESULTAT A PROJETER
C  IN/JXOUT RESU2   K8  : NOM DE LA SD_RESULTAT RESULTAT
C  IN/JXIN  MODEL2  K8  : NOM DU MODELE ASSOCIE A RESU2
C  IN/JXIN  CORRES  K16 : NOM DE LA SD CORRESP_2_MAILLA

C  RESTRICTIONS :
C   1- ON TRAITE SYSTEMATIQUEMENT TOUS LES NUMEROS D'ORDRE
C   2- ON NE TRAITE CORRECTEMENT QUE LES EVOL_XXX (INST)
C  -----------------------------------------------------------------
      IMPLICIT   NONE
C
C 0.1. ==> ARGUMENTS
C
      CHARACTER*16 CORRES,TYPRES
      CHARACTER*8  RESU1,RESU2,MODEL2
C
C 0.2. ==> COMMUNS
C --- DEBUT DECLARATIONS NORMALISEES JEVEUX ---------------------------
C
      INTEGER            ZI
      COMMON  / IVARJE / ZI(1)
      REAL*8             ZR
      COMMON  / RVARJE / ZR(1)
      CHARACTER*8        ZK8
      CHARACTER*16                ZK16
      CHARACTER*24                          ZK24,NOOJB
      CHARACTER*32     ZK32,JEXNUM,JEXNOM,JEXATR
      CHARACTER*80                                              ZK80
      COMMON  / KVARJE / ZK8(1) , ZK16(1) , ZK24(1) , ZK32(1) , ZK80(1)
C
C --- FIN DECLARATIONS NORMALISEES JEVEUX -----------------------------
C
C 0.3. ==> VARIABLES LOCALES
C

C
      INTEGER       IBID, IE, JCONO, IRET, JORDR, NBORDR, I, IORDR
      INTEGER       IAINS1, IAINS2, NBSYM, ISYM, ICO, IND, J, NBMAX
      PARAMETER     (NBMAX=50)
      INTEGER       IPAR, IPAR1, IPAR2
      LOGICAL       ACCENO
      CHARACTER*8   KB, MA1, MA2, NUME,PROL0,K8B, TYP1, TYP2
      CHARACTER*16  NOMSYM(200)
      CHARACTER*19  CH1, CH2, PRFCHN,LIGREL,PRFCH2
      CHARACTER*19  NOMS2,REFE, KPAR(NBMAX)
      INTEGER IACONB,IACONU,NBNO2,JPJM1,IACNX1,ILCNX1,IDECAL,INO2
      INTEGER KMA1,NBNO1,IMA1,NBMA1,INO1
      INTEGER NUNO1A,NUNO1B
      INTEGER IER,LMATAS
      
C     FONCTIONS FORMULES :

C DEB -----------------------------------------------------------------
      CALL JEMARQ()
C 
      K8B='        '
C
      LIGREL=MODEL2//'.MODELE'

      CALL DISMOI('F','NOM_MAILLA', RESU1,'RESULTAT',IBID,MA1,IE)
      CALL DISMOI('F','NOM_MAILLA', MODEL2,'MODELE',IBID,MA2,IE)

      CALL JEVEUO(CORRES//'.PJEF_NO','L',JCONO)
      IF (ZK8(JCONO-1+1).NE.MA1)
     &CALL UTMESS('F','PJEFPR','MAILLAGES 1 DIFFERENTS.')
      IF (ZK8(JCONO-1+2).NE.MA2)
     &CALL UTMESS('F','PJEFPR','MAILLAGES 2 DIFFERENTS.')

      CALL RSUTC4(RESU1,' ',1,200,NOMSYM,NBSYM,ACCENO)
      CALL ASSERT (NBSYM.GT.0)

      CALL GETVTX(' ','PROL_ZERO',1,1,1,PROL0,IER)


C     1- CREATION DE LA SD RESULTAT : RESU2
C     ------------------------------------
      CALL RSUTNU(RESU1,' ',0,'&&PJEFPR.NUME_ORDRE',NBORDR,0.D0,
     &            'ABSO',IRET)
      IF ( IRET.NE.0 ) THEN
        CALL UTMESS('F','PJEFPR','PROBLEME DANS L''EXAMEN DE '//RESU1)
      ENDIF
      IF ( NBORDR.EQ.0 ) THEN
        CALL UTMESS('F','PJEFPR','AUCUN NUMERO D''ORDRE DANS '//RESU1)
      ENDIF
      CALL JEVEUO('&&PJEFPR.NUME_ORDRE','L',JORDR)
      NOMS2 = RESU2
      CALL JEEXIN (NOMS2//'.DESC', IRET )
      IF ( IRET.EQ.0 ) THEN
        CALL GETTCO(RESU1,TYPRES)
        CALL RSCRSD ( RESU2, TYPRES, NBORDR )
      ENDIF

C Dans le cas des concepts type modes meca on teste la presence
C des matrices afin de recuperer la numerotation sous-jacente
      PRFCH2='12345678.00000.NUME'
C    On essaye de recuperer la numerotation imposee
      CALL GETVID(' ','NUME_DDL',1,1,1,NUME,IER)
      IF (IER.NE.0) THEN
        PRFCH2=NUME(1:8)//'      .NUME'
      ENDIF

C     2- ON CALCULE LES CHAMPS RESULTATS :
C     ------------------------------------
      ICO=0
      DO 4,ISYM=1,NBSYM

        IF (PRFCH2.NE.'12345678.00000.NUME') THEN
C On prend la numerotation imposee
          PRFCHN=PRFCH2
        ELSE
C On definit une numerotation 'bidon"
          NOOJB='12345678.00000.NUME.PRNO'
          CALL GNOMSD ( NOOJB,10,14)
          PRFCHN=NOOJB(1:19)
        ENDIF

        DO 5,I=1,NBORDR
          IORDR = ZI(JORDR+I-1)
          CALL RSEXCH(RESU1,NOMSYM(ISYM),IORDR,CH1,IRET)
          IF (IRET.GT.0) GOTO 5

C       -- PROJECTION DU CHAMP SI POSSIBLE :
          CALL RSEXCH(RESU2,NOMSYM(ISYM),IORDR,CH2,IRET)
          CALL PJEFCH(CORRES,CH1,CH2,PRFCHN,PROL0,LIGREL,IRET)
          IF (IRET.GT.0) THEN
            IF (ACCENO) THEN
              CALL UTMESS('F','PJEFPR','ON NE SAIT PAS ENCORE PROJETER'
     &      //' LES CHAMPS '//NOMSYM(ISYM))
            ELSE
              GO TO 5
            END IF
          END IF
          CALL RSNOCH ( RESU2, NOMSYM(ISYM), IORDR, ' ' )

C       -- Attribution des attributs du concept resultat
C         Extraction des parametres modaux � sauver dans le resultat
          IF ((TYPRES(1:9).EQ.'MODE_MECA') .OR.
     &     (TYPRES(1:4).EQ.'BASE')) THEN     
              CALL VPCREA(0,RESU2,K8B,K8B,K8B,PRFCH2(1:8),IER)
              CALL RSADPA ( RESU1,'L',1,'FREQ',IORDR,0,IAINS1,KB)
              CALL RSADPA ( RESU2,'E',1,'FREQ',IORDR,0,IAINS2,KB)
              ZR(IAINS2)=ZR(IAINS1)              
C             Recuperation de nume_mode
              CALL JEEXIN (RESU1//'           .NUMO', IRET )
              IF ( IRET.NE.0 ) THEN
                CALL JEVEUO (RESU1//'           .NUMO', 'L', IAINS1)
                CALL JEVEUO (RESU2//'           .NUMO', 'E', IAINS2)
                ZI(IAINS2+IORDR-1)=ZI(IAINS1+IORDR-1)
              ENDIF
          ELSEIF (TYPRES(1:9).EQ.'MODE_STAT') THEN
              CALL VPCREA(0,RESU2,K8B,K8B,K8B,PRFCH2(1:8),IER)
              CALL RSADPA ( RESU1,'L',1,'NOEUD_CMP',IORDR,0,IAINS1,KB)
              CALL RSADPA ( RESU2,'E',1,'NOEUD_CMP',IORDR,0,IAINS2,KB)
              ZK16(IAINS2)=ZK16(IAINS1)
          ELSEIF ((TYPRES(1:4) .EQ. 'EVOL') .OR.
     &        (TYPRES(1:4) .EQ. 'DYNA')) THEN
            CALL RSADPA ( RESU1,'L',1,'INST',IORDR,0,IAINS1,KB)
            CALL RSADPA ( RESU2,'E',1,'INST',IORDR,0,IAINS2,KB)
            ZR(IAINS2)=ZR(IAINS1)
          ELSE 
C            on fait rien
          ENDIF

C         REMPLIT D AUTRES PARAMETRES SI DEMANDE PAR UTILISATEUR
          CALL GETVTX(' ','NOM_PARA',1,1,NBMAX,KPAR,IPAR)
 
          DO 15 IND=1,IPAR
             CALL RSADPA ( RESU1,'L',1,KPAR(IND),
     &                     IORDR,1,IPAR1,TYP1)
             CALL RSADPA ( RESU2,'E',1,KPAR(IND),
     &                     IORDR,0,IPAR2,TYP2)
             IF (TYP1(1:1) .EQ. 'I') THEN
                ZI(IPAR2) = ZI(IPAR1)
             ELSEIF (TYP1(1:1) .EQ. 'R') THEN
                ZR(IPAR2) = ZR(IPAR1)
             ELSEIF (TYP1(1:2) .EQ. 'K8') THEN
                ZK8(IPAR2) = ZK8(IPAR1)
             ELSEIF (TYP1(1:3) .EQ. 'K16') THEN
                ZK16(IPAR2) = ZK16(IPAR1)
             ELSEIF (TYP1(1:3) .EQ. 'K32') THEN
                ZK32(IPAR2) = ZK32(IPAR1)
             ELSE 
C               ON NE FAIT RIEN
             ENDIF
 15       CONTINUE
          ICO=ICO+1

 5      CONTINUE
 4    CONTINUE

      IF (ICO.EQ.0) CALL UTMESS('F','PJEFPR','AUCUN CHAMP PROJETE.')
      CALL JEDETR('&&PJEFPR.NUME_ORDRE')

      CALL JEDEMA()
      END
