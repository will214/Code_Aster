      SUBROUTINE OP0149 (IER)
      IMPLICIT REAL*8 (A-H,O-Z)
C ----------------------------------------------------------------------
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
C
C     OPERATEUR:  MODI_BASE_MODALE
C
C ----------------------------------------------------------------------
C     ----- DEBUT COMMUNS NORMALISES  JEVEUX  --------------------------
      INTEGER          ZI
      COMMON  /IVARJE/ ZI(1)
      REAL*8           ZR
      COMMON  /RVARJE/ ZR(1)
      COMPLEX*16       ZC
      COMMON  /CVARJE/ ZC(1)
      LOGICAL          ZL
      COMMON  /LVARJE/ ZL(1)
      CHARACTER*8      ZK8
      CHARACTER*16             ZK16
      CHARACTER*24                      ZK24
      CHARACTER*32                               ZK32
      CHARACTER*80                                        ZK80
      COMMON  /KVARJE/ ZK8(1), ZK16(1), ZK24(1), ZK32(1), ZK80(1)
C     ----- FIN COMMUNS NORMALISES  JEVEUX  ----------------------------
      CHARACTER*8   NOMRES, BASEMO, CRIT, MODEFL, TYPFLU, K8BID, FORMAR
      CHARACTER*16  TYPRES, NOMCMD, NOMCH(1)
      CHARACTER*19  BASEFL
      CHARACTER*24  FREQI, NUMOI, NUMO, VITE, REFEFL, FSIC, FSVI
      LOGICAL       NEWRES, LNUOR, LAMOR, LAMORU, NOCOPL, NUMOK
      COMPLEX*16    CBID
C     ------------------------------------------------------------------
C
      CALL JEMARQ()
C
C-----0.VERIFICATIONS AVANT EXECUTION
C
      CALL GETVIS(' ','NUME_ORDRE',0,1,0,IBID,NBNUO1)
      NBNUO1 = ABS(NBNUO1)
      IF (NBNUO1.NE.0) THEN
        CALL GETVR8 ( ' ', 'AMOR_REDUIT', 0,1,0,RBID, NA1 )
         NBAMO1 = ABS( NA1 )
        IF ( NBAMO1.NE.0 ) THEN
           IF ( NBAMO1 .NE. NBNUO1 ) THEN
            CALL UTMESS('F','MODI_BASE_MODALE','SI LES MOTS-CLES '//
     &          '<NUME_ORDRE> ET <AMOR_REDUIT> SONT UTILISES, IL '//
     &              'FAUT AUTANT D ARGUMENTS POUR L UN ET L AUTRE')
           ENDIF
        ENDIF
      ENDIF
      
C
C     ---RECUPERATION DU NIVEAU D'IMPRESSION---
C
      CALL INFMAJ
      CALL INFNIV ( IFM , NIV )
C
C-----1.RECUPERATION DES ARGUMENTS DE LA COMMANDE
C
      CALL GETRES(NOMRES,TYPRES,NOMCMD)
C
      NEWRES = .TRUE.
      CALL GETVID(' ','BASE',0,1,1,BASEMO,IBID)
      IF (BASEMO.EQ.NOMRES) NEWRES = .FALSE.
C
      CALL GETVID(' ','BASE_ELAS_FLUI',0,1,1,BASEFL,IBID)
      CALL GETVIS(' ','NUME_VITE_FLUI',0,1,1,NUMVIT,IBID)
C
      LNUOR = .FALSE.
      CALL GETVIS(' ','NUME_ORDRE',0,1,0,IBID,NBNUO1)
      NBNUO1 = ABS(NBNUO1)
      IF (NBNUO1.NE.0) THEN
        LNUOR = .TRUE.
        CALL WKVECT('&&OP0149.TEMP.NUO1','V V I',NBNUO1,INUO1)
        CALL GETVIS(' ','NUME_ORDRE',0,1,NBNUO1,ZI(INUO1),IBID)
      ENDIF
C
      LAMOR  = .FALSE.
      LAMORU = .FALSE.
      CALL GETVR8 ( ' ', 'AMOR_REDUIT', 0,1,0, RBID, NA1 )
      NBAMO1 = ABS( NA1 )
      IF ( NBAMO1 .NE. 0 ) THEN
        LAMOR = .TRUE.
        CALL WKVECT('&&OP0149.TEMP.AMO1','V V R',NBAMO1,IAMO1)
        IF ( NA1 .NE. 0 ) THEN
           CALL GETVR8(' ','AMOR_REDUIT',0,1,NBAMO1,ZR(IAMO1),IBID)
        ENDIF
      ELSE
        CALL GETVR8(' ','AMOR_UNIF',0,1,0,RBID,NBAMUN)
        IF (NBAMUN.NE.0) THEN
          LAMORU = .TRUE.
          CALL GETVR8(' ','AMOR_UNIF',0,1,1,AMORUN,IBID)
        ENDIF
      ENDIF
C
C
C-----2.VERIFICATIONS A L'EXECUTION
C
C-----2.1.ERREUR FATALE SI LE CONCEPT MODE_MECA D'ENTREE N'EST PAS
C         CELUI AYANT SERVI AU CALCUL DE COUPLAGE FLUIDE-STRUCTURE
C
      REFEFL = BASEFL//'.REFE'
      CALL JEVEUO(REFEFL,'L',IREFFL)
      MODEFL = ZK8(IREFFL+1)
      IF (BASEMO.NE.MODEFL) CALL UTMESS('F',NOMCMD,'LE CONCEPT '//
     &  'MODE_MECA D ENTREE DOIT ETRE CELUI CORRESPONDANT A LA BASE '//
     &  'MODALE INITIALE POUR LE CALCUL DE COUPLAGE FLUIDE-STRUCTURE')
C
C-----2.2.ERREUR FATALE SI NUME_VITE_FLUI INVALIDE
C
      VITE = BASEFL//'.VITE'
      CALL JELIRA(VITE,'LONUTI',NBVITE,K8BID)
      IF (NUMVIT.LE.0 .OR. NUMVIT.GT.NBVITE) CALL UTMESS('F',NOMCMD,
     &  'NUMERO DE VITESSE D ECOULEMENT DU FLUIDE NON VALIDE')
C
C-----2.3.ERREUR FATALE SI TOUS LES MODES NON COUPLES SONT RETENUS
C         (MOT-CLE <NUME_ORDRE> NON UTILISE) ET NOMBRE D'ARGUMENTS
C         INVALIDE POUR LE MOT-CLE <AMOR_REDUIT>
C
      FREQI = BASEMO//'           .FREQ'
      CALL JELIRA(FREQI,'LONUTI',NBMODE,K8BID)
      NUMO = BASEFL//'.NUMO'
      CALL JELIRA(NUMO,'LONUTI',NBMFL,K8BID)
      NBMOD2 = NBMODE - NBMFL
      IF (.NOT.LNUOR .AND. LAMOR .AND. NBAMO1.NE.NBMOD2) THEN
        CALL UTMESS('F',NOMCMD,'TOUS LES MODES NON COUPLES ETANT '//
     &    'RETENUS, LE NOMBRE D ARGUMENTS VALIDE POUR LE MOT-CLE '//
     &    '<AMOR_REDUIT> EST LA DIFFERENCE ENTRE LE NOMBRE DE MODES '//
     &    'DE LA BASE MODALE INITIALE ET LE NOMBRE DE MODES PRIS '//
     &    'EN COMPTE POUR LE COUPLAGE FLUIDE-STRUCTURE')
      ENDIF
C
C
C-----3.CONSTITUTION DE LA LISTE DES NUMEROS D'ORDRE DES MODES RETENUS
C       POUR LA RECONSTRUCTION DE LA BASE MODALE
C       (MODES NON PERTURBES + MODES PRIS EN COMPTE POUR LE COUPLAGE)
C       LE CAS ECHEANT ON CREE UNE LISTE D'AMORTISSEMENTS REDUITS QUI
C       SERONT AFFECTES AUX MODES NON PERTURBES
C
      CALL JEVEUO(NUMO,'L',INUMO)
      NUMOI = BASEMO//'           .NUMO'
      CALL JEVEUO(NUMOI,'L',INUMOI)
C
C-----3.1.SI ON CREE UN NOUVEAU CONCEPT DE TYPE MODE_MECA EN SORTIE
C
      IF (NEWRES) THEN
C
C-------3.1.1.SI DONNEE D'UNE LISTE DE NUMEROS D'ORDRE PAR <NUME_ORDRE>
C
        IF (LNUOR) THEN
C
          CALL WKVECT('&&OP0149.TEMP.NUO2','V V I',NBNUO1,INUO2)
          NBNUO2 = 0
          IF (LAMOR) CALL WKVECT('&&OP0149.TEMP.AMO2','V V R',
     &                            NBNUO1,IAMO2)
C
C---------ON NE RETIENT QUE LES NUMEROS D'ORDRE QUI CORRESPONDENT
C         EFFECTIVEMENT A DES MODES NON COUPLES ET ON NOTE LE CAS
C         ECHEANT LES VALEURS D'AMORTISSEMENTS FOURNIES EN REGARD
C
          DO 10 I = 1,NBNUO1
            NOCOPL = .TRUE.
            NUMOK  = .FALSE.
            NUMODE = ZI(INUO1+I-1)
            DO 11 J = 1,NBMFL
              IF (ZI(INUMO+J-1).EQ.NUMODE) THEN
                NOCOPL = .FALSE.
                GOTO 12
              ENDIF
  11        CONTINUE
  12        CONTINUE
            DO 13 K = 1,NBMODE
              IF (ZI(INUMOI+K-1).EQ.NUMODE) THEN
                NUMOK = .TRUE.
                GOTO 14
              ENDIF
  13        CONTINUE
  14        CONTINUE
            IF (NOCOPL .AND. NUMOK) THEN
              NBNUO2 = NBNUO2 + 1
              ZI(INUO2+NBNUO2-1) = NUMODE
              IF (LAMOR) ZR(IAMO2+NBNUO2-1) = ZR(IAMO1+I-1)
            ENDIF
  10      CONTINUE
C
C---------CONSTITUTION DES LISTES
C
          IF (NBNUO2.EQ.0) THEN
            CALL UTMESS('F',NOMCMD,'LES NUMEROS D ORDRE FOURNIS NE '//
     &        'CORRESPONDENT PAS A DES MODES NON PERTURBES')
          ELSE
            NBNUOR = NBNUO2 + NBMFL
            CALL WKVECT('&&OP0149.TEMP.NUOR','V V I',NBNUOR,INUOR)
            CALL WKVECT('&&OP0149.TEMP.AMOR','V V I',NBNUOR,IAMOR)
            DO 20 I = 1,NBNUO2
              ZI(INUOR+I-1) = ZI(INUO2+I-1)
              IF (LAMOR) THEN
                ZR(IAMOR+I-1) = ZR(IAMO2+I-1)
              ELSE IF (LAMORU) THEN
                ZR(IAMOR+I-1) = AMORUN
              ENDIF
  20        CONTINUE
            DO 21 I = NBNUO2+1,NBNUOR
              ZI(INUOR+I-1) = ZI(INUMO+I-NBNUO2-1)
  21        CONTINUE
            DO 22 I = 1,NBNUOR-1
              NUOMIN = ZI(INUOR+I-1)
              IMIN = I
              DO 23 J = I+1,NBNUOR
                IF (ZI(INUOR+J-1).LT.NUOMIN) THEN
                  NUOMIN = ZI(INUOR+J-1)
                  IMIN = J
                ENDIF
  23          CONTINUE
              ZI(INUOR+IMIN-1) = ZI(INUOR+I-1)
              ZI(INUOR+I-1) = NUOMIN
              IF (LAMOR .OR. LAMORU) THEN
                RTAMP = ZR(IAMOR+IMIN-1)
                ZR(IAMOR+IMIN-1) = ZR(IAMOR+I-1)
                ZR(IAMOR+I-1) = RTAMP
              ENDIF
  22        CONTINUE
          ENDIF
C
C-------3.1.2.SINON
C
        ELSE
C
C---------SI DONNEE D'AMORTISSEMENTS REDUITS, ON RETIENT TOUS LES MODES
C
          IF (LAMOR .OR. LAMORU) THEN
            NBNUOR = NBMODE
            CALL WKVECT('&&OP0149.TEMP.NUOR','V V I',NBNUOR,INUOR)
            CALL WKVECT('&&OP0149.TEMP.AMOR','V V I',NBNUOR,IAMOR)
            DO 30 I = 1,NBNUOR
              ZI(INUOR+I-1) = ZI(INUMOI+I-1)
  30        CONTINUE
            IDEC = 0
            DO 31 I = 1,NBNUOR
              NOCOPL = .TRUE.
              NUMODE = ZI(INUOR+I-1)
              DO 32 J = 1,NBMFL
                IF (ZI(INUMO+J-1).EQ.NUMODE) THEN
                  NOCOPL = .FALSE.
                  GOTO 33
                ENDIF
  32          CONTINUE
  33          CONTINUE
              IF (NOCOPL) THEN
                IF (LAMOR) THEN
                  IDEC = IDEC + 1
                  ZR(IAMOR+I-1) = ZR(IAMO1+IDEC-1)
                ELSE IF (LAMORU) THEN
                  ZR(IAMOR+I-1) = AMORUN
                ENDIF
              ENDIF
  31        CONTINUE
C
C---------SINON, SEULS LES MODES COUPLES SONT RETENUS
C
          ELSE
            NBNUOR = NBMFL
            CALL WKVECT('&&OP0149.TEMP.NUOR','V V I',NBNUOR,INUOR)
            CALL WKVECT('&&OP0149.TEMP.AMOR','V V I',NBNUOR,IAMOR)
            DO 40 I = 1,NBMFL
              ZI(INUOR+I-1) = ZI(INUMO+I-1)
  40        CONTINUE
          ENDIF
C
        ENDIF
C
C-----3.2.SINON (ON MODIFIE LE CONCEPT D'ENTREE DE TYPE MODE_MECA)
C         => TOUS LES MODES SONT RETENUS
C
      ELSE
C
        NBNUOR = NBMODE
        CALL WKVECT('&&OP0149.TEMP.NUOR','V V I',NBNUOR,INUOR)
        CALL WKVECT('&&OP0149.TEMP.AMOR','V V I',NBNUOR,IAMOR)
        DO 50 I = 1,NBNUOR
          ZI(INUOR+I-1) = ZI(INUMOI+I-1)
  50    CONTINUE
        IF ((LNUOR.AND.LAMOR) .OR. (LNUOR.AND.LAMORU)) THEN
          DO 51 I = 1,NBNUO1
            NOCOPL = .TRUE.
            NUMOK  = .FALSE.
            NUMODE = ZI(INUO1+I-1)
            DO 52 J = 1,NBMFL
              IF (ZI(INUMO+J-1).EQ.NUMODE) THEN
                NOCOPL = .FALSE.
                GOTO 53
              ENDIF
  52        CONTINUE
  53        CONTINUE
            DO 54 K = 1,NBMODE
              IF (ZI(INUMOI+K-1).EQ.NUMODE) THEN
                NUMOK = .TRUE.
                GOTO 55
              ENDIF
  54        CONTINUE
  55        CONTINUE
            IF (NOCOPL .AND. NUMOK) THEN
              IF (LAMOR)  ZR(IAMOR+NUMODE-1) = ZR(IAMO1+I-1)
              IF (LAMORU) ZR(IAMOR+NUMODE-1) = AMORUN
            ENDIF
  51      CONTINUE
        ELSE IF (LAMOR .OR. LAMORU) THEN
          IDEC = 0
          DO 56 I = 1,NBNUOR
            NOCOPL = .TRUE.
            NUMODE = ZI(INUOR+I-1)
            DO 57 J = 1,NBMFL
              IF (ZI(INUMO+J-1).EQ.NUMODE) THEN
                NOCOPL = .FALSE.
                GOTO 58
              ENDIF
  57        CONTINUE
  58        CONTINUE
            IF (NOCOPL) THEN
              IF (LAMOR) THEN
                IDEC = IDEC + 1
                ZR(IAMOR+I-1) = ZR(IAMO1+IDEC-1)
              ELSE IF (LAMORU) THEN
                ZR(IAMOR+I-1) = AMORUN
              ENDIF
            ENDIF
  56      CONTINUE
        ENDIF
C
      ENDIF
C
C
C-----4.RECUPERATION DU TYPE DE LA CONFIGURATION ETUDIEE
C
      TYPFLU = ZK8(IREFFL)
      FSIC = TYPFLU//'           .FSIC'
      CALL JEVEUO(FSIC,'L',IFSIC)
      ITYPFL = ZI(IFSIC)
      IMASSE = -1
      IF (ITYPFL.EQ.4) THEN
        FSVI = TYPFLU//'           .FSVI'
        CALL JEVEUO(FSVI,'L',IFSVI)
        IMASSE = ZI(IFSVI)
      ENDIF
C
C
C-----5.RECONSTRUCTION OU MODIFICATION DE LA BASE MODALE EN FONCTION
C       DU TYPE DE LA CONFIGURATION ETUDIEE
C
      CALL MODIBA(NOMRES,BASEMO,BASEFL,NUMVIT,NEWRES,ITYPFL,IMASSE,
     &            ZI(INUOR),NBNUOR,ZI(INUMO),NBMFL)
C
      CALL JEDETC('V','&&OP0149',1)
      CALL JEDEMA()
      END
