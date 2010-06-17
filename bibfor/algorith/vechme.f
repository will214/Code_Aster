      SUBROUTINE VECHME(TYPCAL,MODELZ,CHARGZ,INFCHZ,INST  ,
     &                  CARELE,MATE  ,VRCPLU,LIGREZ,VAPRIZ,
     &                  NOPASZ,TYPESE,STYPSE,VECELZ)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 16/06/2010   AUTEUR CARON A.CARON 
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
C RESPONSABLE VABHHTS J.PELLET
C ----------------------------------------------------------------------

C     CALCUL DES VECTEURS ELEMENTAIRES DES CHARGEMENTS MECANIQUES
C     DE NEUMANN NON SUIVEURS ET NON PILOTABLES (CONSTANTS).

C     PRODUIT UN VECT_ELEM DEVANT ETRE ASSEMBLE PAR LA ROUTINE ASASVE

C IN  TYPCAL  : TYPE DU CALCUL :
C               'MECA', POUR LA RESOLUTION DE LA MECANIQUE,
C               'DLAG', POUR LE CALCUL DE LA DERIVEE LAGRANGIENNE
C IN  MODELE  : NOM DU MODELE
C IN  CHARGZ  : LISTE DES CHARGES
C IN  INFCHZ  : INFORMATIONS SUR LES CHARGEMENTS
C IN  INST    : TABLEAU DONNANT T+, DELTAT ET THETA (POUR LE THM)
C IN  CARELE  : CARACTERISTIQUES DES POUTRES ET COQUES
C IN  MATE    : MATERIAU CODE
C IN  TEMPLU  : CHAMP DE TEMPERATURE A L'INSTANT T+
C IN  LIGREZ  : (SOUS-)LIGREL DE MODELE POUR CALCUL REDUIT
C                  SI ' ', ON PREND LE LIGREL DU MODELE
C . POUR LE CALCUL DU DEPLACEMENT :
C IN  VAPRIN : SANS OBJET
C IN  NOPASE : SANS OBJET
C . POUR LE CALCUL D'UNE DERIVEE :
C IN  VAPRIN : VARIABLE PRINCIPALE (DEPLACEMENT) A L'INSTANT COURANT
C IN  NOPASE : PARAMETRE SENSIBLE
C              . POUR LA DERIVEE LAGRANGIENNE, C'EST UN CHAMP THETA
C IN  TYPESE  : TYPE DE SENSIBILITE
C                0 : CALCUL STANDARD, NON DERIVE
C                SINON : DERIVE (VOIR METYSE)
C IN  STYPSE  : SOUS-TYPE DE SENSIBILITE (VOIR NTTYSE)
C VAR/JXOUT  VECELZ  : VECT_ELEM RESULTAT.

C   ATTENTION :
C   -----------
C   LE VECT_ELEM (VECELZ) RESULTAT A 1 PARTICULARITE :
C   1) CERTAINS RESUELEM NE SONT PAS DES RESUELEM MAIS DES
C      CHAM_NO (.VEASS)

      IMPLICIT NONE

C 0.1. ==> ARGUMENTS

      INTEGER TYPESE

      CHARACTER*4 TYPCAL
      CHARACTER*(*) MODELZ,CHARGZ,INFCHZ,CARELE,MATE
      CHARACTER*(*) VAPRIZ
      CHARACTER*(*) NOPASZ
      CHARACTER*(*) VRCPLU,VECELZ,LIGREZ
      CHARACTER*24 STYPSE

      REAL*8 INST(3)

C 0.2. ==> COMMUNS

C --- DEBUT DECLARATIONS NORMALISEES JEVEUX ----------------------------

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

C 0.3. ==> VARIABLES LOCALES

      CHARACTER*6 NOMPRO
      PARAMETER (NOMPRO='VECHME')

      INTEGER NCHINX
      PARAMETER (NCHINX=42)

      INTEGER NBCHMX
      PARAMETER (NBCHMX=17)

      INTEGER JLCHIN,EXICHA,ISIGI
      INTEGER IER,JCHAR,JINF
      INTEGER IBID,IRET,NCHAR,K,ICHA,II,IEXIS
      INTEGER NUMCHM,NUMORD,NCHIN,NBNOLI,JNOLI,IAUX

      CHARACTER*5 SUFFIX
      CHARACTER*6 NOMLIG(NBCHMX),NOMPAF(NBCHMX),NOMPAR(NBCHMX)
      CHARACTER*6 NOMOPF(NBCHMX),NOMOPR(NBCHMX)
      CHARACTER*7 NOMCMP(3)
      CHARACTER*8 NOMCHA,NOMCH0,NOMCHS,K8BID
      CHARACTER*8 LPAIN(NCHINX),PAOUT,NEWNOM,NOPASE,MODELE
      CHARACTER*16 OPTION,OPER,K16B
      CHARACTER*24 CHGEOM,CHCARA(18),CHTIME,LIGREL
      CHARACTER*24 LIGRMO,LIGRCH,LIGRCS
      CHARACTER*1 STOP
      CHARACTER*19 RESUEL,RESUFV(3),VECELE
      CHARACTER*24 LCHIN(NCHINX)
      CHARACTER*24 CHARGE,INFCHA
      CHARACTER*24 VECTTH,GRADTH
CC      CHARACTER*24 VAPRIN

      LOGICAL EXIGEO,EXICAR,BIDON

      COMPLEX*16 CBID

      DATA NOMLIG/'.FORNO','.F3D3D','.F2D3D','.F1D3D','.F2D2D','.F1D2D',
     &     '.F1D1D','.PESAN','.ROTAT','.PRESS','.FELEC','.FCO3D',
     &     '.FCO2D','.EPSIN','.FLUX','.VEASS','.SIINT'/
      DATA NOMOPF/'FORC_F','FF3D3D','FF2D3D','FF1D3D','FF2D2D','FF1D2D',
     &     'FF1D1D','PESA_R','ROTA_R','PRES_F','FRELEC','FFCO3D',
     &     'FFCO2D','EPSI_F','FLUX_F','      ',' '/
      DATA NOMPAF/'FORNOF','FF3D3D','FF2D3D','FF1D3D','FF2D2D','FF1D2D',
     &     'FF1D1D','PESANR','ROTATR','PRESSF','FRELEC','FFCO3D',
     &     'FFCO2D','EPSINF','FLUXF','      ',' '/
      DATA NOMOPR/'FORC_R','FR3D3D','FR2D3D','FR1D3D','FR2D2D','FR1D2D',
     &     'FR1D1D','PESA_R','ROTA_R','PRES_R','FRELEC','FRCO3D',
     &     'FRCO2D','EPSI_R','FLUX_R','      ',' '/
      DATA NOMPAR/'FORNOR','FR3D3D','FR2D3D','FR1D3D','FR2D2D','FR1D2D',
     &     'FR1D1D','PESANR','ROTATR','PRESSR','FRELEC','FRCO3D',
     &     'FRCO2D','EPSINR','FLUXR','      ',' '/

C DEB ------------------------------------------------------------------
      CALL JEMARQ()
      NEWNOM = '.0000000'

      DO 10,II = 1,NCHINX
        LCHIN(II) = ' '
        LPAIN(II) = ' '
   10 CONTINUE

      CALL ASSERT (TYPCAL.EQ.'MECA' .OR. TYPCAL.EQ.'DLAG')


      MODELE = MODELZ
      CHARGE = CHARGZ
      INFCHA = INFCHZ
      LIGRMO = LIGREZ
CC      VAPRIN = VAPRIZ
      NOPASE = NOPASZ


C     -- CALCUL DE 'STOP':
      STOP='S'
C     -- SI CALC_NO ET QUE LE CALCUL EST FAIT SUR UN GROUPE DE MAILLE,
C        IL FAUT QUE STOP='C'
      CALL GETRES(K16B,K16B,OPER)
      IF ((OPER.EQ.'CALC_NO').AND.(LIGRMO(1:8).NE.MODELE(1:8))) STOP='C'


      IF (LIGRMO.EQ.' ') THEN
        LIGRMO = MODELE(1:8)//'.MODELE'
      END IF

      RESUEL = '&&'//NOMPRO//'.???????'
C     -- CALCUL DU NOM DU RESULTAT :
C     ------------------------------
      VECELE = VECELZ
      IF (VECELE.EQ.' ') THEN
        IF (TYPCAL.EQ.'MECA') THEN
          VECELE = '&&VEMCHA'
        ELSE IF (TYPCAL.EQ.'DLAG') THEN
          VECELE = '&&VETCHD'
        END IF
      END IF
C     -- CALCUL DE BIDON :
C        .FALSE. : IL EXISTE DES CHARGES ET DONC 1 VECT_ELEM
C                  A CALCULER.
C        .TRUE. : IL N'Y A PAS DE CHARGE ET ON FABRIQUE 1 VECT_ELEM
C                 BIDON.
C -------------------------------------------------------------------
      BIDON = .TRUE.
      CALL JEEXIN(CHARGE,IRET)
      IF (IRET.NE.0) THEN
        CALL JELIRA(CHARGE,'LONMAX',NCHAR,K8BID)
        IF (NCHAR.NE.0) THEN
          BIDON = .FALSE.
          CALL JEVEUO(CHARGE,'L',JCHAR)
          CALL JEVEUO(INFCHA,'L',JINF)
        END IF
      END IF

      IF (TYPCAL.EQ.'DLAG') THEN
        NUMORD = 0
        CALL RSEXCH(NOPASE,'THETA',NUMORD,VECTTH,IRET)
        CALL RSEXCH(NOPASE,'GRAD_NOEU_THETA',NUMORD,GRADTH,IRET)
      END IF

C     -- ALLOCATION DU VECT_ELEM RESULTAT :
C     -------------------------------------
      CALL DETRSD('VECT_ELEM',VECELE)
      CALL MEMARE('V',VECELE,MODELE,MATE,CARELE,'CHAR_MECA')
      CALL REAJRE(VECELE,' ','V')
      IF (BIDON) GO TO 80

      CALL MEGEOM(MODELE,ZK24(JCHAR) (1:8),EXIGEO,CHGEOM)
      CALL MECARA(CARELE,EXICAR,CHCARA)

      CHTIME = '&&'//NOMPRO//'.CH_INST_R'
      NOMCMP(1) = 'INST   '
      NOMCMP(2) = 'DELTAT '
      NOMCMP(3) = 'THETA  '

      CALL MECACT('V',CHTIME,'LIGREL',LIGRMO,'INST_R  ',3,NOMCMP,IBID,
     &            INST,CBID,K8BID)

      LPAIN(2) = 'PGEOMER'
      LCHIN(2) = CHGEOM
      LPAIN(3) = 'PTEMPSR'
      LCHIN(3) = CHTIME
      LPAIN(4) = 'PMATERC'
      LCHIN(4) = MATE
      LPAIN(5) = 'PCACOQU'
      LCHIN(5) = CHCARA(7)
      LPAIN(6) = 'PCAGNPO'
      LCHIN(6) = CHCARA(6)
      LPAIN(7) = 'PCADISM'
      LCHIN(7) = CHCARA(3)
      LPAIN(8) = 'PCAORIE'
      LCHIN(8) = CHCARA(1)
      LPAIN(9) = 'PCACABL'
      LCHIN(9) = CHCARA(10)
      LPAIN(10) = 'PCAARPO'
      LCHIN(10) = CHCARA(9)
      LPAIN(11) = 'PCAGNBA'
      LCHIN(11) = CHCARA(11)
      LCHIN(12) = VRCPLU
      LPAIN(12) = 'PVARCPR '
      LPAIN(13) = 'PCAMASS'
      LCHIN(13) = CHCARA(12)
      LPAIN(14) = 'PCAGEPO'
      LCHIN(14) = CHCARA(5)
      LPAIN(15) = 'PNBSP_I'
      LCHIN(15) = CHCARA(16)
      LPAIN(16) = 'PFIBRES'
      LCHIN(16) = CHCARA(17)
      LPAIN(17) = 'PCINFDI'
      LCHIN(17) = CHCARA(15)
      NCHIN = 17

      PAOUT = 'PVECTUR'


      DO 70 ICHA = 1,NCHAR
        NUMCHM = ZI(JINF+NCHAR+ICHA)

        IF (NUMCHM.GT.0) THEN

          NOMCH0 = ZK24(JCHAR+ICHA-1) (1:8)
          LIGRCH = NOMCH0//'.CHME.LIGRE'

          IF (TYPESE.NE.0) THEN
            CALL PSGENC(NOMCH0,NOPASE,NOMCHS,EXICHA)
          ELSE
            EXICHA = 0
            NOMCHA = NOMCH0
          END IF


C ------- BOUCLES SUR LES TOUS LES TYPES DE CHARGE PREVUS

C ------- LE LIGREL UTILISE DANS CALCUL EST LE LIGREL DU MODELE
C ------- SAUF POUR LES FORCES NODALES (K=1)

          DO 40 K = 1,NBCHMX
            IF (NOMLIG(K).EQ.'.FORNO') THEN
              LIGREL = LIGRCH
            ELSE
              LIGREL = LIGRMO
            END IF

            IF (NOMLIG(K).EQ.'.VEASS') THEN
              SUFFIX = '     '
            ELSE
              SUFFIX = '.DESC'
            END IF


            IF (EXICHA.EQ.0 .OR. TYPCAL.EQ.'DLAG') THEN
              LCHIN(1) = NOMCH0//'.CHME'//NOMLIG(K)//SUFFIX
              CALL JEEXIN(LCHIN(1),IRET)
              IF (IRET.NE.0) THEN

C           ATTENTION : DANS LE CAS D'UN CALCUL DE SENSIBILITE TYPE
C           NEUMANN, ON UTILISERA LE LIGREL DU CHARGEMENT STANDARD.
C           POUR CELA ON REMPLACE LE NOM JEVEUX STOCKE DANS LE
C           CHARGEMENT SENSIBLE PAR LE NOM STANDARD, LIGRCH. EVIDEMMENT,
C           A LA FIN DU TRAITEMENT, ON REMETTRA LE VRAI NOM, SAUVEGARDE
C           DANS LIGRCS.

                IF (TYPESE.EQ.5) THEN
                  CALL JELIRA(NOMCHS//'.CHME'//NOMLIG(K)//'.NOLI',
     &                        'LONMAX',NBNOLI,K8BID)
                  CALL JEVEUO(NOMCHS//'.CHME'//NOMLIG(K)//'.NOLI','E',
     &                        JNOLI)
                  LIGRCS = ZK24(JNOLI)
                  DO 20,IAUX = 0,NBNOLI - 1
                    ZK24(JNOLI+IAUX) = LIGRCH
   20             CONTINUE
                  NOMCHA = NOMCHS
                  LCHIN(1) = NOMCHA//'.CHME'//NOMLIG(K)//SUFFIX
                END IF


                IF (NUMCHM.EQ.1) THEN
                  OPTION = 'CHAR_'//TYPCAL//'_'//NOMOPR(K)
                  LPAIN(1) = 'P'//NOMPAR(K)
                ELSE IF (NUMCHM.EQ.2) THEN
                  OPTION = 'CHAR_'//TYPCAL//'_'//NOMOPF(K)
                  LPAIN(1) = 'P'//NOMPAF(K)
                ELSE IF (NUMCHM.EQ.3) THEN
                  OPTION = 'CHAR_'//TYPCAL//'_'//NOMOPF(K)
                  LPAIN(1) = 'P'//NOMPAF(K)
                ELSE IF (NUMCHM.EQ.55) THEN
                  OPTION = 'FORC_NODA'
                  CALL JEVEUO(LIGRCH(1:13)//'.SIINT.VALE','L',ISIGI)
                  LPAIN(1) = 'PCONTMR'
                  LCHIN(1) = ZK8(ISIGI)
                  NCHIN = NCHIN + 1
                  LPAIN(NCHIN) = 'PDEPLMR'
                  LCHIN(NCHIN) = ' '
                ELSE IF (NUMCHM.GE.4) THEN
                  GO TO 40
                END IF
C               PCOMPOR UTILE POUR POUTRES MULTI-FIBRES. ON PREND
C               LA CARTE QUI EST DANS MATE
                NCHIN = NCHIN + 1
                LPAIN(NCHIN) = 'PCOMPOR'
                LCHIN(NCHIN) =  MATE(1:8)//'.COMPOR'
                CALL GCNCO2(NEWNOM)
                RESUEL(10:16) = NEWNOM(2:8)
                CALL CORICH('E',RESUEL,ICHA,IBID)
                NCHIN = 20
                IF (TYPCAL.EQ.'DLAG') THEN
                  NCHIN = NCHIN + 1
                  LPAIN(NCHIN) = 'PVECTTH'
                  LCHIN(NCHIN) = VECTTH
                  NCHIN = NCHIN + 1
                  LPAIN(NCHIN) = 'PGRADTH'
                  LCHIN(NCHIN) = GRADTH
                END IF

C               POUR LES ELEMENTS DE BORD X-FEM
                CALL EXIXFE(MODELE,IER)

                IF (IER.NE.0) THEN
                  LPAIN(NCHIN + 1) = 'PPINTTO'
                  LCHIN(NCHIN + 1) = MODELE(1:8)//'.TOPOSE.PIN'
                  LPAIN(NCHIN + 2) = 'PCNSETO'
                  LCHIN(NCHIN + 2) = MODELE(1:8)//'.TOPOSE.CNS'
                  LPAIN(NCHIN + 3) = 'PHEAVTO'
                  LCHIN(NCHIN + 3) = MODELE(1:8)//'.TOPOSE.HEA'
                  LPAIN(NCHIN + 4) = 'PLONCHA'
                  LCHIN(NCHIN + 4) = MODELE(1:8)//'.TOPOSE.LON'
                  LPAIN(NCHIN + 5) = 'PLSN'
                  LCHIN(NCHIN + 5) = MODELE(1:8)//'.LNNO'
                  LPAIN(NCHIN + 6) = 'PLST'
                  LCHIN(NCHIN + 6) = MODELE(1:8)//'.LTNO'
                  LPAIN(NCHIN + 7) = 'PSTANO'
                  LCHIN(NCHIN + 7) = MODELE(1:8)//'.STNO'
                  LPAIN(NCHIN + 8) = 'PPMILTO'
                  LCHIN(NCHIN + 8) = MODELE(1:8)//'.TOPOSE.PMI'
                  NCHIN = NCHIN + 8
                  IF (OPTION.EQ.'CHAR_MECA_PRES_R'.OR.
     &                OPTION.EQ.'CHAR_MECA_PRES_F') THEN
                    LPAIN(NCHIN + 1) = 'PPINTER'
C                    LCHIN(NCHIN + 1) = MODELE(1:8)//'.TOPOFAC.PI'
                    LCHIN(NCHIN + 1) = MODELE(1:8)//'.TOPOFAC.OE'
                    LPAIN(NCHIN + 2) = 'PAINTER'
                    LCHIN(NCHIN + 2) = MODELE(1:8)//'.TOPOFAC.AI'
                    LPAIN(NCHIN + 3) = 'PCFACE'
                    LCHIN(NCHIN + 3) = MODELE(1:8)//'.TOPOFAC.CF'
                    LPAIN(NCHIN + 4) = 'PLONGCO'
                    LCHIN(NCHIN + 4) = MODELE(1:8)//'.TOPOFAC.LO'
                    LPAIN(NCHIN + 5) = 'PBASECO'
                    LCHIN(NCHIN + 5) = MODELE(1:8)//'.TOPOFAC.BA'
                    NCHIN = NCHIN + 5
                  ENDIF
                ENDIF

C             -- SI .VEASS, IL N'Y A PAS DE CALCUL A LANCER
                IF (NOMLIG(K).EQ.'.VEASS') THEN
                  CALL JEVEUO(LCHIN(1),'L',JLCHIN)
                  CALL COPISD('CHAMP_GD','V',ZK8(JLCHIN),RESUEL)

                ELSE

                  CALL ASSERT(NCHIN.LE.NCHINX)

                  CALL CALCUL(STOP,OPTION,LIGREL,NCHIN,LCHIN,LPAIN,1,
     &                        RESUEL,PAOUT,'V')

                END IF

C               -- RECOPIE DU CHAMP (S'IL EXISTE) DANS LE VECT_ELEM
                CALL EXISD('CHAMP_GD',RESUEL,IEXIS)
                CALL ASSERT((IEXIS.GT.0).OR.(STOP.EQ.'C'))

                CALL REAJRE(VECELE,RESUEL,'V')

C               ON REMET LE VRAI NOM DU LIGREL POUR LE CHRGT SENSIBLE :
                IF (TYPESE.EQ.5) THEN
                  DO 30,IAUX = 0,NBNOLI - 1
                    ZK24(JNOLI+IAUX) = LIGRCS
   30             CONTINUE
                END IF
              END IF
            END IF
   40     CONTINUE
        END IF

C       --TRAITEMENT DE AFFE_CHAR_MECA/EVOL_CHAR
C       ----------------------------------------
C       RESULTATS POSSIBLE
C          1 - VOLUMIQUE
C          2 - SURFACIQUE
C          3 - PRESSION
        DO 50 II = 1,3
          RESUFV(II) = RESUEL
          CALL GCNCO2(NEWNOM)
          RESUFV(II) (10:16) = NEWNOM(2:8)
   50   CONTINUE
        CALL NMDEPR(MODELZ,LIGRMO,CARELE,CHARGZ,ICHA,INST(1),
     &              RESUFV)
        DO 60 II = 1,3
          CALL REAJRE(VECELE,RESUFV(II),'V')
   60   CONTINUE

   70 CONTINUE

   80 CONTINUE

      VECELZ = VECELE//'.RELR'

      CALL JEDEMA()
      END
