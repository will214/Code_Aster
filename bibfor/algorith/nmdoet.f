      SUBROUTINE NMDOET(RESULT,MODELE,MODEDE,COMPOR,CARELE,INSTAM,
     &                  DEPMOI,SIGMOI,VARMOI,VARDEM,LAGDEM,NBPASE,
     &                  INPSCO)

C MODIF ALGORITH  DATE 06/04/2004   AUTEUR DURAND C.DURAND 
C ======================================================================
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C COPYRIGHT (C) 1991 - 2001  EDF R&D                  WWW.CODE-ASTER.ORG
C THIS PROGRAM IS FREE SOFTWARE; YOU CAN REDISTRIBUTE IT AND/OR MODIFY
C IT UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICENSE AS PUBLISHED BY
C THE FREE SOFTWARE FOUNDATION; EITHER VERSION 2 OF THE LICENSE, OR
C (AT YOUR OPTION) ANY LATER VERSION.

C THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT
C WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF
C MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. SEE THE GNU
C GENERAL PUBLIC LICENSE FOR MORE DETAILS.

C YOU SHOULD HAVE RECEIVED A COPY OF THE GNU GENERAL PUBLIC LICENSE
C ALONG WITH THIS PROGRAM; IF NOT, WRITE TO EDF R&D CODE_ASTER,
C    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================
C RESPONSABLE                            GJBHHEL E.LORENTZ

      IMPLICIT     NONE
      REAL*8 INSTAM
      INTEGER NBPASE
      CHARACTER*8 RESULT,MODEDE
      CHARACTER*13 INPSCO
      CHARACTER*24 MODELE,COMPOR,CARELE,COMPOM
      CHARACTER*24 DEPMOI,SIGMOI,VARMOI,VARDEM,LAGDEM

C ----------------------------------------------------------------------
C                 SAISIE DES CHAMPS A L'ETAT INITIAL
C ----------------------------------------------------------------------
C IN       RESULT  : NOM DU CONCEPT RESULTAT
C IN       MODELE  : MODELE MECANIQUE
C IN       MODEDE  : MODELE NON LOCAL (OU ' ')
C IN       COMPOR  : CARTE DECRIVANT LE TYPE DE COMPORTEMENT
C OUT      INSTAM  : INSTANT INITIAL
C IN/JXVAR DEPMOI  : CHAM_NO DE DEPLACEMENTS INITIAUX (NUL EN IN)
C IN/JXOUT SIGMOI  : CHAM_ELEM DE CONTRAINTES INITIALES
C IN/JXOUT VARMOI  : CHAM_ELEM DE VARIABLES INTERNES INITIALES
C IN/JXVAR VARDEM  : VARIABLES NON LOCALES INITIALES (NUL EN IN)
C IN/JXOUT LAGDEM  : MULTIPLICATEURS DE LAGRANGE NON LOCAUX INITIAUX
C IN       NBPASE  : NOMBRE DE PARAMETRES SENSIBLES
C IN       INPSCO  : SD CONTENANT LISTE DES NOMS POUR SENSIBILITE
C --- DEBUT DECLARATIONS NORMALISEES JEVEUX ----------------------------

      CHARACTER*32 JEXNUM,JEXNOM,JEXR8,JEXATR
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

C --- FIN DECLARATIONS NORMALISEES JEVEUX ------------------------------

      LOGICAL LBID,EVONOL
      INTEGER N1,N2,REENTR,NOCC,NUME,NCHOUT,JINST,IRET,IBID
      INTEGER NBR,NRPASE,IAUX,JAUX
      REAL*8 VALCMP(4),PREC,R8VIDE,RBID,INST
      COMPLEX*16 CBID
      CHARACTER*8 NOMCMP(4),LPAIN(1),LPAOUT(2),CRITER,K8BID
      CHARACTER*8 NOPASE
      CHARACTER*16 OPT
      CHARACTER*24 LIGRMO,LIGRDE,EVOL,LCHIN(1),LCHOUT(2),TYPE
      CHARACTER*24 CHAMP,CHGEOM,RESUID,STRUCT,K24BID

C      DATA         NOMCMP    /'VALEUR', 'GRAD_X', 'GRAD_Y', 'GRAD_Z'/
C      DATA         VALCMP    / 0.D0   ,  0.D0   ,  0.D0   ,  0.D0   /
C ----------------------------------------------------------------------


C -- EXTENSION DU COMPORTEMENT : NOMBRE DE VARIABLES INTERNES
C                                ET NOMBRE DE SOUS-POINTS

      CALL DISMOI('F','NOM_LIGREL',MODELE,'MODELE',IBID,LIGRMO,IRET)
      CALL EXISD('CHAM_ELEM_S',COMPOR,IRET)
      IF (IRET.EQ.0) CALL CESVAR(CARELE,COMPOR,LIGRMO,COMPOR)

C -- PAS D'ETAT INITIAL EN PRESENCE D'UN CONCEPT REENTRANT

      CALL GETFAC('ETAT_INIT',NOCC)
      CALL JEEXIN(RESULT//'           .DESC',REENTR)
      IF (NOCC.EQ.0 .AND. REENTR.NE.0) CALL UTMESS('A','NMDOET',
     &    'SURCHARGE D''UN RESULTAT SANS DEFINIR D''ETAT INITIAL : '//
     &    'ON PREND UN ETAT INITIAL NUL')

      CALL GETVID('ETAT_INIT','EVOL_NOLI',1,1,1,EVOL,NOCC)
      EVONOL = NOCC .GT. 0

      DO 10 NRPASE = NBPASE,0,-1
        IAUX = NRPASE
        JAUX = 5
        CALL PSNSLE(INPSCO,IAUX,JAUX,DEPMOI)
        JAUX = 9
        CALL PSNSLE(INPSCO,IAUX,JAUX,SIGMOI)
        JAUX = 11
        CALL PSNSLE(INPSCO,IAUX,JAUX,VARMOI)

C ======================================================================
C         ETAT INITIAL DEFINI PAR UN CONCEPT DE TYPE EVOL_NOLI
C ======================================================================

        IF (EVONOL) THEN
          COMPOM = ' '

C       CONTROLE DU TYPE DE EVOL
          CALL DISMOI('F','TYPE_RESU',EVOL,'RESULTAT',IBID,TYPE,IRET)
          IF (TYPE.NE.'EVOL_NOLI') CALL UTMESS('F','NMDOET',
     &             'LE CONCEPT DANS ETAT_INIT N''EST DU TYPE EVOL_NOLI')


C -- NUMERO D'ACCES ET INSTANT CORRESPONDANT

          CALL GETVR8('ETAT_INIT','INST',1,1,1,INST,N1)
          CALL GETVIS('ETAT_INIT','NUME_ORDRE',1,1,1,NUME,N2)

C      NUME_ORDRE ET INST ABSENTS, ON PREND LE DERNIER PAS ARCHIVE
          IF (N1+N2.EQ.0) THEN
            CALL RSORAC(EVOL,'DERNIER',IBID,RBID,K8BID,CBID,RBID,K8BID,
     &                  NUME,1,N2)
            IF (N2.EQ.0) CALL UTMESS('F','NMDOET','PAS DE NUMERO '//
     &                               'D''ORDRE POUR LE CONCEPT '//EVOL)
          END IF

C      ACCES PAR INSTANT
          IF (N1.NE.0) THEN
            CALL GETVR8('ETAT_INIT','PRECISION',1,1,1,PREC,IBID)
            CALL GETVTX('ETAT_INIT','CRITERE',1,1,1,CRITER,IBID)
            CALL RSORAC(EVOL,'INST',IBID,INST,K8BID,CBID,PREC,CRITER,
     &                  NUME,1,NBR)
            IF (NBR.EQ.0) CALL UTMESS('F','NMDOET',
     &                                'L''INSTANT SPECIFIE '//
     &                            'SOUS ''ETAT_INIT'' N''EST PAS TROUVE'
     &                                )
            IF (NBR.LT.0) CALL UTMESS('F','NMDOET',
     &                                'PLUSIEURS INSTANTS '//
     &               'CORRESPONDENT A CELUI SPECIFIE SOUS ''ETAT_INIT'''
     &                                )
          END IF

C      ACCES PAR NUMERO D'ORDRE
          IF (N2.NE.0) THEN
            CALL RSADPA(EVOL,'L',1,'INST',NUME,0,JINST,K8BID)
            INST = ZR(JINST)
          END IF

          IF ( NRPASE.GT.0 ) THEN
            IAUX = NRPASE
            JAUX = 1
            CALL PSNSLE ( INPSCO, IAUX, JAUX, NOPASE )
            CALL PSRENC ( EVOL, NOPASE, RESUID, IRET )
            IF ( IRET.NE.0 ) THEN
              CALL UTDEBM ( 'A','NMDOET', 'CODE DE RETOUR DE PSRENC' )
              CALL UTIMPI ( 'S', ': ', 1, IRET )
              CALL UTFINM
              CALL UTMESS ( 'F','NMDOET', 'LA DERIVEE DE '//EVOL//
     >            ' PAR RAPPORT A '//NOPASE//' EST INTROUVABLE.')
            ENDIF
            STRUCT = RESUID
          ELSE
            STRUCT = EVOL
          END IF 

C -- LECTURE DES DEPLACEMENTS (OU DERIVE) 

          CALL RSEXCH(STRUCT,'DEPL',NUME,CHAMP,IRET)
          IF (IRET.NE.0) CALL UTMESS('F','NMDOET',
     &                               'LE CHAMP DE DEPL_R (OU DERIVE)'//
     &                              'N''EST PAS TROUVE DANS LE CONCEPT '
     &                               //STRUCT)
          CALL VTCOPY(CHAMP,DEPMOI,IRET)

C -- LECTURE DES CONTRAINTES AUX POINTS DE GAUSS (OU DERIVE) 

          CALL RSEXCH(STRUCT,'SIEF_ELGA',NUME,CHAMP,IRET)
          IF (IRET.EQ.0) THEN
            CALL COPISD('CHAMP_GD','V',CHAMP,SIGMOI)
          ELSE

C        CONTRAINTES AUX NOEUDS : PASSAGE AUX POINTS DE GAUSS
            CALL RSEXCH(STRUCT,'SIEF_ELNO',NUME,CHAMP,IRET)
            IF (IRET.NE.0) CALL UTMESS('F','NMDOET',
     &                              'LE CHAMP DE SIEF_R (OU DERIVE) '//
     &                              'N''EST PAS TROUVE DANS LE CONCEPT '
     &                                 //STRUCT)
            CALL COPISD('CHAM_ELEM_S','V',COMPOR,SIGMOI)
            CALL MENOGA('SIEF_ELGA_ELNO  ',LIGRMO,COMPOR,CHAMP,SIGMOI,
     &                  K24BID)
          END IF

C         CHARGEMENTS DE TYPE PRECONTRAINTE (LE CAS ECHEANT)
          CALL NMSIGI(LIGRMO,COMPOR,SIGMOI)

C -- LECTURE DES VARIABLES INTERNES AUX POINTS DE GAUSS (OU DERIVE) 

          CALL RSEXCH(STRUCT,'COMPORTEMENT',NUME,COMPOM,IRET)
          IF (IRET.NE.0) COMPOM = ' '

          CALL RSEXCH(STRUCT,'VARI_ELGA',NUME,CHAMP,IRET)
          IF (IRET.EQ.0) THEN
            CALL COPISD('CHAMP_GD','V',CHAMP,VARMOI)
            IF (NRPASE.EQ.NBPASE) CALL VRCOMP(COMPOM,COMPOR,VARMOI)
          ELSE

C        VARIABLES INTERNES AUX NOEUDS : PASSAGE AUX POINTS DE GAUSS
            CALL RSEXCH(STRUCT,'VARI_ELNO',NUME,CHAMP,IRET)
            IF (IRET.NE.0) CALL UTMESS('F','NMDOET','LE CHAMP '//
     &                    'DE VARI_R (OU DERIVE) N''EST PAS TROUVE'
     &                               //' DANS LE CONCEPT '//STRUCT)

            IF (NRPASE.EQ.NBPASE) CALL VRCOMP(COMPOM,COMPOR,CHAMP)
            CALL COPISD('CHAM_ELEM_S','V',COMPOR,VARMOI)
            CALL MENOGA('VARI_ELGA_ELNO  ',LIGRMO,COMPOR,CHAMP,VARMOI,
     &                  K24BID)
          END IF


C -- LECTURE DES VARIABLES NON LOCALES

          IF (MODEDE.NE.' ') THEN
            CALL RSEXCH(STRUCT,'VARI_NON_LOCAL',NUME,CHAMP,IRET)
            IF (IRET.NE.0) CALL UTMESS('F','NMDOET','LE CHAMP DE '//
     &                'VARI_NON_LOCAL (OU DERIVE) N''EST PAS TROUVE'
     &                               //' DANS LE CONCEPT '//STRUCT)
            CALL VTCOPY(CHAMP,VARDEM,IRET)
          END IF


C -- LECTURE DES MULTIPLICATEURS DE LAGRANGE NON LOCAUX

          IF (MODEDE.NE.' ') THEN
            CALL RSEXCH(STRUCT,'LANL_ELGA',NUME,CHAMP,IRET)
            IF (IRET.NE.0) CALL UTMESS('F','NMDOET','LE CHAMP DE '//
     &                    'LANL_ELGA N''EST PAS TROUVE DANS LE CONCEPT '
     &                                 //STRUCT)
            CALL COPISD('CHAMP_GD','V',CHAMP,LAGDEM)
          END IF


        ELSE

C ======================================================================
C      DEFINITION CHAMP PAR CHAMP (OU PAS D'ETAT INITIAL DU TOUT)
C ======================================================================

          NCHOUT = 0

C -- LECTURE DES DEPLACEMENTS

          CALL GETVID('ETAT_INIT','DEPL',1,1,1,CHAMP,NOCC)
          IF (NOCC.NE.0) CALL VTCOPY(CHAMP,DEPMOI,IRET)

          IF (NOCC.NE.0 .AND. NBPASE.GT.0) CALL UTMESS('F','NMDOET',
     &        'POUR FAIRE UNE REPRISE AVEC'//
     &        'UN CALCUL DE SENSIBILITE, IL FAUT RENSEIGNER '//
     &        '"EVOL_NOLI" DANS "ETAT_INIT"')


C -- LECTURE DES CONTRAINTES AUX POINTS DE GAUSS

          CALL GETVID('ETAT_INIT','SIGM',1,1,1,CHAMP,NOCC)

          IF (NOCC.NE.0 .AND. NBPASE.GT.0 .AND. NRPASE.EQ.0 )
     &        CALL UTMESS('F','NMDOET',
     &        'POUR FAIRE UNE REPRISE AVEC'//
     &        'UN CALCUL DE SENSIBILITE, IL FAUT RENSEIGNER '//
     &        '"EVOL_NOLI" DANS "ETAT_INIT"')

C      PREPARATION POUR CREER UN CHAMP NUL
          IF (NOCC.EQ.0) THEN
            NCHOUT = NCHOUT + 1
            LPAOUT(NCHOUT) = 'PSIEF_R'
            LCHOUT(NCHOUT) = SIGMOI
            CALL COPISD('CHAM_ELEM_S','V',COMPOR,SIGMOI)

          ELSE
            CALL DISMOI('F','TYPE_CHAMP',CHAMP,'CHAMP',IBID,TYPE,IRET)

C        PASSAGE NOEUDS -> POINTS DE GAUSS LE CAS ECHEANT
            IF (TYPE.EQ.'ELNO') THEN
              CALL COPISD('CHAM_ELEM_S','V',COMPOR,SIGMOI)
              CALL MENOGA('SIEF_ELGA_ELNO  ',LIGRMO,COMPOR,CHAMP,SIGMOI,
     &                    K24BID)
            ELSE
              CALL COPISD('CHAMP_GD','V',CHAMP,SIGMOI)
            END IF
          END IF


C -- LECTURE DES VARIABLES INTERNES

          CALL GETVID('ETAT_INIT','VARI',1,1,1,CHAMP,NOCC)

          IF (NOCC.NE.0 .AND. NBPASE.GT.0) CALL UTMESS('F','NMDOET',
     &        'POUR FAIRE UNE REPRISE AVEC'//
     &        'UN CALCUL DE SENSIBILITE, IL FAUT RENSEIGNER '//
     &        '"EVOL_NOLI" DANS "ETAT_INIT"')

C      PREPARATION POUR CREER UN CHAMP NUL
          IF (NOCC.EQ.0) THEN
            NCHOUT = NCHOUT + 1
            LPAOUT(NCHOUT) = 'PVARI_R'
            LCHOUT(NCHOUT) = VARMOI
            CALL COPISD('CHAM_ELEM_S','V',COMPOR,VARMOI)

          ELSE
            CALL DISMOI('F','TYPE_CHAMP',CHAMP,'CHAMP',IBID,TYPE,IRET)

C        PASSAGE NOEUDS -> POINTS DE GAUSS LE CAS ECHEANT
            IF (TYPE.EQ.'ELNO') THEN
              IF (NRPASE.EQ.NBPASE) CALL VRCOMP(' ',COMPOR,CHAMP)
              CALL COPISD('CHAM_ELEM_S','V',COMPOR,VARMOI)
              CALL MENOGA('VARI_ELGA_ELNO  ',LIGRMO,COMPOR,CHAMP,VARMOI,
     &                    K24BID)
            ELSE
              CALL COPISD('CHAMP_GD','V',CHAMP,VARMOI)
              IF (NRPASE.EQ.NBPASE) CALL VRCOMP(' ',COMPOR,VARMOI)
            END IF
          END IF


C -- CREATION DES CHAM_ELEM DE CONTRAINTES ET DE VARIABLES INTERNES NULS

          IF (NCHOUT.GT.0) THEN
            CALL MEGEOM(MODELE,' ',LBID,CHGEOM)
            LCHIN(1) = CHGEOM
            LPAIN(1) = 'PGEOMER'
            OPT = 'TOU_INI_ELGA'
            CALL CALCUL('S',OPT,LIGRMO,1,LCHIN,LPAIN,NCHOUT,LCHOUT,
     &                  LPAOUT,'V')

C         CHARGEMENTS DE TYPE PRECONTRAINTE (LE CAS ECHEANT)
            CALL NMSIGI(LIGRMO,COMPOR,SIGMOI)
          END IF


C -- LECTURE DES VARIABLES NON LOCALES

          IF (MODEDE.NE.' ') THEN
            CALL GETVID('ETAT_INIT','VARI_NON_LOCAL',1,1,1,CHAMP,IRET)
            IF (IRET.NE.0) CALL VTCOPY(CHAMP,VARDEM,IRET)
          END IF


C -- CREATION DU CHAMP DE MULTIPLICATEURS DE LAGRANGE NON LOCAUX NULS

          IF (MODEDE.NE.' ') THEN
            CALL DISMOI('F','NOM_LIGREL',MODEDE,'MODELE',IBID,LIGRDE,
     &                  IRET)
            CALL MEGEOM(MODEDE,' ',LBID,CHGEOM)
            LCHIN(1) = CHGEOM
            LPAIN(1) = 'PGEOMER'
            LCHOUT(1) = LAGDEM
            LPAOUT(1) = 'PVALO_R'
            OPT = 'TOU_INI_ELGA'
            CALL CALCUL('S',OPT,LIGRDE,1,LCHIN,LPAIN,1,LCHOUT,LPAOUT,
     &                  'V')
          END IF
        END IF


   10 CONTINUE

C -- LECTURE DE L'INSTANT DU CHARGEMENT INITIAL (SI DONNE)

      CALL GETVR8('ETAT_INIT','INST_ETAT_INIT',1,1,1,INSTAM,NOCC)
      IF (NOCC.EQ.0) THEN
        IF (EVONOL) THEN
          INSTAM = INST
        ELSE
          INSTAM = R8VIDE()
        END IF
      END IF


      END
