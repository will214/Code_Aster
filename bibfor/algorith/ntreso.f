      SUBROUTINE NTRESO(NRORES, NBPASE, INPSCO, PARTPS,
     &                  MODELE,MATE,CARELE,FOMULT,CHARGE,INFCHA,
     &                  INFOCH,NUMEDD,SOLVEU,LOSTAT,TIME,TPSTHE,
     &                  REASVC,REASVT,REASMT,REASRG,REASMS,CREAS,
     &                  VEC2ND,MATASS,MAPREC,CNDIRP,CNCHCI,MEDIRI,
     &                  COMPOR,NUMORD,PARA,
     &                  LISCHA)
C ----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 07/09/2009   AUTEUR PELLET J.PELLET 
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
C TOLE CRP_21
C ----------------------------------------------------------------------
C     THERMIQUE LINEAIRE - RESOLUTION
C     *                    ****
C     COMMANDE:  THER_LINEAIRE
C ----------------------------------------------------------------------
C IN  NRORES  : NUMERO DE LA RESOLUTION
C               0 : CALCUL STANDARD
C               >0 : CALCUL DE LA DERIVEE NUMERO NRORES
C IN  NBPASE  : NOMBRE DE PARAMETRES SENSIBLES
C IN  INPSCO  : STRUCTURE CONTENANT LA LISTE DES NOMS
C   -------------------------------------------------------------------
C     SUBROUTINES APPELLEES:
C       MESSAGE:INFMAJ,INFNIV.
C       JEVEUX/SD:COPISD,DETRSD,RSEXCH,RSAGSD,RSNOCH.
C       SENSIBILITE: PSNSLE,NTTYSE.
C       THERMIQUE: NXACMV,NTARCH.
C       SOLVEUR EF: RESOUD.
C
C     FONCTIONS INTRINSEQUES:
C       AUCUNE.
C   -------------------------------------------------------------------
C     ASTER INFORMATIONS:
C       30/11/01 (OB): MODIFICATIONS POUR INSERER LES SENSIBILITES.
C----------------------------------------------------------------------
C CORPS DU PROGRAMME
      IMPLICIT   NONE

C 0.1. ==> ARGUMENTS

      INTEGER NRORES, NBPASE
      INTEGER JARCH,  NUMORD, DIARCH, NUMARC

      REAL*8       TPSTHE(6), PARA(*)
      CHARACTER*1  CREAS
      CHARACTER*19 INFCHA,SOLVEU,MAPREC,LISCHA,PARTPS
      CHARACTER*24 MODELE,MATE,CARELE,FOMULT,CHARGE,INFOCH,NUMEDD,
     &             TIME,VEC2ND,MATASS,CNDIRP,CNCHCI,COMPOR
      CHARACTER*(*) INPSCO

      LOGICAL      REASVC,REASVT,REASMT,REASRG,REASMS,LOSTAT,FORCE
      LOGICAL      DIDERN,INCR

C 0.2. ==> COMMUNS

C --- DEBUT DECLARATIONS NORMALISEES JEVEUX ----------------------------
      INTEGER ZI
      COMMON /IVARJE/ZI(1)
      REAL*8 ZR
      COMMON /RVARJE/ZR(1)
      COMPLEX*16 ZC,CBID
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

C 0.3. ==> VARIABLES LOCALES

      CHARACTER*6 NOMPRO
      PARAMETER ( NOMPRO = 'NTRESO' )
      INTEGER      IFM,NIV,IARCH,IAUX,JAUX,TYPESE,JTEMPI,NDDL,I
      REAL*8       TPSNP1,RBID
      CHARACTER*8  NOPASE,K8BID
      CHARACTER*19 CHSOL
      CHARACTER*24 MEDIRI,VHYDR,TMPCHI,TMPCHF,VEC2NI,K24BID,CRITER,
     &             RESULT,NOMCH,VTEMP,VTEMPM,VAPRIN,VAPRMO
      CHARACTER*24 STYPSE

C DEB ------------------------------------------------------------------
C====
C 1. PREALABLES
C====

C-----RECUPERATION DU NIVEAU D'IMPRESSION

      CALL INFNIV(IFM,NIV)

C 1.2. ==> NOM DES STRUCTURES

C 1.2.1. ==> FIXES

C               12   345678   90123456789
      CHSOL  = '&&'//NOMPRO//'_SOLUTION  '

C               12   345678   9012345678901234
      CRITER = '&&'//NOMPRO//'_RESGRA_GCPC    '

C 1.2.2. ==> ASSOCIEES AUX DERIVATIONS
C               3. LE NOM DU RESULTAT
C               4. LA VARIABLE PRINCIPALE A L'INSTANT N
C               5. LA VARIABLE PRINCIPALE A L'INSTANT N-1
C               6. LA VARIABLE PRINCIPALE A L'INSTANT N+1

      IAUX = NRORES
      JAUX = 1
      CALL PSNSLE ( INPSCO, IAUX, JAUX, NOPASE )
      JAUX = 3
      CALL PSNSLE ( INPSCO, IAUX, JAUX, RESULT )

C POUR UN CALCUL THERMIQUE LINEAIRE STD VTEMP ET VTEMPM CONTIENNENT
C TOUS LES DEUX T-. TANDIS QUE POUR UN CALCUL DE SENSIBILITE
C VTEMP CONTIENT (DT/DS)- ET T+ ET T- SONT CONTENUS DANS VAPRIN ET
C VAPRMO
      JAUX = 4
      CALL PSNSLE ( INPSCO, IAUX, JAUX, VTEMP )

C 1.3 ==> RECHERCHE DE CHAMPS AU CAS PAR CAS

      IF ( NBPASE.NE.0 .AND. .NOT.LOSTAT .AND. NRORES.EQ.0 ) THEN
C CALCUL STD TRANSITOIRE AVEC SENSIBILITE A SUIVRE (POUR 5.1)
        JAUX = 5
        CALL PSNSLE ( INPSCO, IAUX, JAUX, VTEMPM )
      ENDIF
      IF (NRORES.GT.0) THEN
C CALCUL DE SENSIBILITE
        IAUX = 0
        JAUX = 4
        CALL PSNSLE ( INPSCO, IAUX, JAUX, VAPRIN )
        JAUX = 5
        CALL PSNSLE ( INPSCO, IAUX, JAUX, VAPRMO )
      ENDIF

C====
C 2. REPERAGE DU TYPE DE DERIVATION
C====

      IF ( NRORES.GT.0 ) THEN
C CALCUL DE SENSIBILITE: TYPESE NON NUL (NOMENCLATURE VOIR NTTYSE)
        CALL NTTYSE ( NBPASE, INPSCO, NOPASE, TYPESE, STYPSE )
      ELSE
C CALCUL STD
        TYPESE = 0
        STYPSE = ' '
      ENDIF
C====
C 3. ACTUALISATION DU CHARGEMENT A TMOINS SI ON NE TRAITE PAS UN PB
C    DERIVEE INSENSIBLE (TYPESE.EQ.1), CREATION D'UN CHAMP NUL SINON.
C====
      IF (TYPESE.NE.1) THEN
C 3.1 ==> ASSEMBLAGE DU SECOND MEMBRE
        CALL NXACMV(MODELE,MATE,CARELE,FOMULT,CHARGE,INFCHA,
     &              INFOCH,NUMEDD,SOLVEU,LOSTAT,TIME,TPSTHE,
     &              REASVC,REASVT,REASMT,REASRG,REASMS,CREAS,
     &              VTEMP,VHYDR,TMPCHI,TMPCHF,VEC2ND,VEC2NI,
     &              MATASS,MAPREC,CNDIRP,CNCHCI,MEDIRI,COMPOR,
     &              TYPESE,STYPSE,NOPASE,VAPRIN,VAPRMO)

C 3.2 ==> RESOLUTION AVEC VEC2ND COMME SECOND MEMBRE
        CALL RESOUD(MATASS,MAPREC,VEC2ND,SOLVEU,CNCHCI,'V',CHSOL,
     &              CRITER,0,RBID,CBID)

C 3.3 ==> ON DOIT GARDER LA TEMPERATURE DU PAS DE TEMPS PRECEDENT SI
C          TOUT CE QUI SUIT EST REUNI :
C          . IL Y AURA UN CALCUL DE DERIVEE
C          . ON EST EN TRANSITOIRE
C          . ON EST DANS LE CALCUL STANDARD
C              NOMCH : NOM DU CHAMP DE TEMPERATURE A L'INSTANT N

        IF ( NBPASE.NE.0 .AND. .NOT.LOSTAT .AND. NRORES.EQ.0 )
     &    CALL COPISD('CHAMP_GD','V',VTEMP(1:19),VTEMPM(1:19))

      ELSE

C 3.4 ==> PB DERIVEE INSENSIBLE ==> ON N'A PAS A RESOUDRE DE
C    SYSTEME, CAR LA SOLUTION EST NULLE. ON CREER DONC UN CHAMP
C    SOLUTION NUL VTEMP DE MEME TYPE QUE VEC2ND SUR LA BASE VOLATILE.
C    ON AURAIT PU FAIRE AUSSI CALL VTDEFS(VTEMP,VEC2ND,'V',' ')

        CALL JEVEUO(VTEMP(1:19)//'.VALE','E',JTEMPI)
        CALL JELIRA(VTEMP(1:19)//'.VALE','LONMAX',NDDL,K8BID)
        DO 11 , I = 1 , NDDL
          ZR(JTEMPI+I-1) = 0.D0
   11   CONTINUE

      ENDIF

C====
C 4. ==> SAUVEGARDE DE LA SOLUTION
C====

      IF (TYPESE.NE.1) THEN
C 4.1 ==> SAUVEGARDE DU CHAMP SOLUTION CHSOL DANS VTEMP
        CALL COPISD('CHAMP_GD','V',CHSOL(1:19),VTEMP(1:19))

C 4.2 ==> DESTRUCTION DU CHAMP SOLUTION CHSOL
        CALL DETRSD('CHAMP_GD',CHSOL)
      ENDIF

C 4.3 ==> STOCKAGE DE LA SOLUTION, VTEMP, DANS LA STRUCTURE RESULTAT
C         EN TANT QUE CHAMP DE TEMPERATURE A L'INSTANT COURANT
      IF (LOSTAT) THEN
        NUMARC=0
        FORCE=.TRUE.
      ELSE
        FORCE = DIDERN(PARTPS, NUMORD)
        INCR  = NRORES.EQ.NBPASE
        NUMARC = DIARCH(PARTPS,NUMORD,FORCE,INCR)
        IF ( NUMARC .GE. 0 ) THEN
          CALL JEVEUO(PARTPS // '.DIAL','E',JARCH)
          ZL(JARCH+NUMORD) = .TRUE.
        ENDIF
      ENDIF


C --- IMPRESSION EVENTUELLE DES MESURES DE TEMPS
      CALL UTTCPG('IMPR','INCR')

C --- ARCHIVAGE EVENTUEL DU PAS DE TEMPS
      IF ( NUMARC.GE.0 ) THEN
        TPSNP1 = TPSTHE(1)
        K24BID='  '
        CALL NTARCH(NUMARC,RESULT,NOMCH,COMPOR,VTEMP,VHYDR,
     &              TPSNP1,K24BID,PARA,MODELE,MATE,CARELE,LISCHA)
        WRITE(IFM,1010) 'TEMP',NUMARC,TPSNP1
      ENDIF

C FIN ------------------------------------------------------------------
 1010 FORMAT (1P,3X,'CHAMP    STOCKE   :',1X,A4,10X,' NUME_ORDRE:',I8,
     &       ' INSTANT:',D12.5)

      END
