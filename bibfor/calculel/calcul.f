      SUBROUTINE CALCUL(STOP,OPTIO,LIGRLZ,NIN,LCHIN,LPAIN,NOU,LCHOU,
     &                  LPAOU,BASE)

      IMPLICIT NONE

C MODIF CALCULEL  DATE 06/04/2004   AUTEUR DURAND C.DURAND 
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
C RESPONSABLE                            VABHHTS J.PELLET
C     ARGUMENTS:
C     ----------
      INTEGER NIN,NOU
      CHARACTER*(*) BASE,OPTIO
      CHARACTER*(*) LCHIN(*),LCHOU(*),LPAIN(*),LPAOU(*),LIGRLZ
C ----------------------------------------------------------------------
C     ENTREES:
C        STOP   :  /'S' : ON S'ARRETE SI AUCUN ELEMENT FINI DU LIGREL
C                         NE SAIT CALCULER L'OPTION.
C                  /'C' : ON CONTINUE SI AUCUN ELEMENT FINI DU LIGREL
C                         NE SAIT CALCULER L'OPTION. IL N'EXISTE PAS DE
C                         CHAMP "OUT" DANS CE CAS.
C        OPTIO  :  NOM D'1 OPTION
C        LIGRLZ :  NOM DU LIGREL SUR LEQUEL ON DOIT FAIRE LE CALCUL
C        NIN    :  NOMBRE DE CHAMPS PARAMETRES "IN"
C        NOU    :  NOMBRE DE CHAMPS PARAMETRES "OUT"
C        LCHIN  :  LISTE DES NOMS DES CHAMPS "IN"
C        LCHOU  :  LISTE DES NOMS DES CHAMPS "OUT"
C        LPAIN  :  LISTE DES NOMS DES PARAMETRES "IN"
C        LPAOU  :  LISTE DES NOMS DES PARAMETRES "OUT"
C        BASE   :  'G' , 'V' OU 'L'

C     SORTIES:
C       ALLOCATION ET CALCUL DES OBJETS CORRESPONDANT AUX CHAMPS "OUT"

C ----------------------------------------------------------------------
      CHARACTER*19 LCHIN2(50),LCHOU2(50)
      CHARACTER*8 LPAIN2(50),LPAOU2(50)
      CHARACTER*19 LIGREL
      CHARACTER*1 STOP
      INTEGER IACHII,IACHIK,IACHIX,IADSGD,IBID
      INTEGER IALIEL,IAMACO,IAMLOC,IAMSCO,IANOOP,IANOTE,IAOBTR
      INTEGER IAOPDS,IAOPMO,IAOPNO,IAOPPA,IAOPTT,IAWLOC
      INTEGER IAWTYP,IER,ILLIEL,ILMACO,ILMLOC,ILMSCO,ILOPMO
      INTEGER ILOPNO,IPARG,IPARIN,IRET,IUNCOD,J,LGCO
      INTEGER NPARIO,NBOBMX,NPARIN
      INTEGER NBGREL,TYPELE,NBELEM,NUCALC
      INTEGER NBPARA,NBOBTR,NVAL,INDIK8
      CHARACTER*32 JEXNOM,JEXNUM,PHEMOD
      CHARACTER*8 NOPARA
      INTEGER OPT,AFAIRE,INPARA
      INTEGER NGREL,NBELGR,IGR,IEL,NUMC
      INTEGER NPIN,I,IPAR,NIN2,NIN3,NOU2,NOU3,JTYPMA
      CHARACTER*8 NOMPAR,CAS
      CHARACTER*1 BASE2
      COMMON /CAII02/IAOPTT,LGCO,IAOPMO,ILOPMO,IAOPNO,ILOPNO,IAOPDS,
     &       IAOPPA,NPARIO,NPARIN,IAMLOC,ILMLOC,IADSGD
      COMMON /CAII03/IAMACO,ILMACO,IAMSCO,ILMSCO,IALIEL,ILLIEL
      COMMON /CAII04/IACHII,IACHIK,IACHIX
      COMMON /CAII05/IANOOP,IANOTE,NBOBTR,IAOBTR,NBOBMX
      CHARACTER*16 OPTION,NOMTE,NOMTM,PHENO,MODELI
      COMMON /CAKK01/OPTION,NOMTE,NOMTM,PHENO,MODELI
      COMMON /CAII06/IAWLOC,IAWTYP,NBELGR,IGR
      COMMON /CAII08/IEL
      INTEGER NBOBJ,IAINEL,ININEL
      COMMON /CAII09/NBOBJ,IAINEL,ININEL

      INTEGER NUTE,JNBELR,JNOELR,IACTIF,JPNLFP,JNOLFP,NBLFPG
      COMMON /CAII11/NUTE,JNBELR,JNOELR,IACTIF,JPNLFP,JNOLFP,NBLFPG

      INTEGER CAINDZ(512),CAPOIZ
      COMMON /CAII12/CAINDZ,CAPOIZ

C---------------- COMMUNS NORMALISES  JEVEUX  --------------------------
      COMMON /IVARJE/ZI(1)
      COMMON /RVARJE/ZR(1)
      COMMON /CVARJE/ZC(1)
      COMMON /LVARJE/ZL(1)
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
      INTEGER ZI
      REAL*8 ZR
      COMPLEX*16 ZC
      LOGICAL ZL,EXICH,DBG
      CHARACTER*8 ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80

C DEB-------------------------------------------------------------------

      CALL JEMARQ()
      IACTIF = 1
      DO 10 I = 1,512
        CAINDZ(I) = 1
   10 CONTINUE
      CALL MECOEL()

      LIGREL = LIGRLZ
      BASE2 = BASE
      OPTION = OPTIO


C     DEBCA1  MET DES OBJETS EN MEMOIRE (ET COMMON):
C     -----------------------------------------------------------------
      CALL DEBCA1(OPTION,LIGREL)



      CALL JEVEUO('&CATA.TE.TYPEMA','L',JTYPMA)
      CALL JENONU(JEXNOM('&CATA.OP.NOMOPT',OPTION),OPT)
      IF (OPT.LE.0) THEN
        CALL UTMESS('F','CALCUL','OPTION INCONNUE AU CATALOGUE : '//
     &              OPTION)
      END IF

C     -- POUR SAVOIR L'UNITE LOGIQUE OU ECRIRE LE FICHIER ".CODE" :
      CALL GETVLI(IUNCOD,CAS)


C     1- SI AUCUN TYPE_ELEMENT DU LIGREL NE SAIT CALCULER L'OPTION,
C     -- ON VA DIRECTEMENT A LA SORTIE :
C     -------------------------------------------------------------
      AFAIRE = 0
      IER = 0
      DO 20,J = 1,NBGREL(LIGREL)
        NUTE = TYPELE(LIGREL,J)
        CALL JENUNO(JEXNUM('&CATA.TE.NOMTE',NUTE),NOMTE)
        NOMTM = ZK8(JTYPMA-1+NUTE)
        NUMC = NUCALC(OPT,NUTE)

C        -- SI LE NUMERO DU TEOOIJ EST NEGATIF :
        IF (NUMC.LT.0) THEN
          IF (NUMC.EQ.-1) THEN
            IER = IER + 1
            CALL UTMESS('E','CALCUL',' LE TYPE_ELEMENT: '//NOMTE//
     &                  ' NE SAIT PAS ENCORE '//'CALCULER L''OPTION: '//
     &                  OPTION//'. ON ARRETE TOUT.')
          ELSE IF (NUMC.EQ.-2) THEN
            CALL UTMESS('A','CALCUL',' LE TYPE_ELEMENT: '//NOMTE//
     &                  ' NE SAIT PAS ENCORE '//'CALCULER L''OPTION: '//
     &                  OPTION//'.')
          ELSE
            CALL UTMESS('F','CALCUL','VALEUR INTERDITE')
          END IF
        END IF

        AFAIRE = MAX(AFAIRE,NUMC)
   20 CONTINUE
      IF (IER.GT.0) CALL UTMESS('F','CALCUL','1')
      IF (AFAIRE.EQ.0) THEN
        IF (STOP.EQ.'S') THEN
          CALL UTMESS('F','CALCUL','LE CALCUL DE L''OPTION : '//OPTION//
     &              ' N''EST POSSIBLE POUR AUCUN DES TYPES D''ELEMENTS '
     &                //' DU LIGREL.')
        ELSE
          GO TO 120
        END IF
      END IF



C     2- ON REND PROPRES LES LISTES : LPAIN,LCHIN,LPAOU,LCHOU :
C        EN NE GARDANT QUE LES PARAMETRES DU CATALOGUE DE L'OPTION
C        QUI SERVENT A AU MOINS UN TYPE_ELEMENT
C     ---------------------------------------------------------
      IF (NIN.GT.50) CALL UTMESS('F','CALCUL',
     &                        'ERREUR PROGRAMMEUR : TROP DE CHAMPS "IN"'
     &                           )
      NIN3 = ZI(IAOPDS-1+2)
      NOU3 = ZI(IAOPDS-1+3)

      NIN2 = 0
      DO 40,I = 1,NIN
        NOMPAR = LPAIN(I)
        IPAR = INDIK8(ZK8(IAOPPA),NOMPAR,1,NIN3)
        IF (IPAR.GT.0) THEN
          DO 30,J = 1,NBGREL(LIGREL)
            NUTE = TYPELE(LIGREL,J)
            IPAR = INPARA(OPT,NUTE,'IN ',NOMPAR)

            IF (IPAR.EQ.0) GO TO 30
            CALL EXISD('CHAMP_GD',LCHIN(I),IRET)
            IF (IRET.EQ.0) GO TO 30
            NIN2 = NIN2 + 1
            LPAIN2(NIN2) = LPAIN(I)
            LCHIN2(NIN2) = LCHIN(I)
            GO TO 40
   30     CONTINUE
        END IF
   40 CONTINUE
C     -- VERIF PAS DE DOUBLONS DANS LPAIN2 :
      CALL KNDOUB(8,LPAIN2,NIN2,IRET)
      CALL ASSERT(IRET.EQ.0)

      NOU2 = 0
      DO 60,I = 1,NOU
        NOMPAR = LPAOU(I)
        IPAR = INDIK8(ZK8(IAOPPA+NIN3),NOMPAR,1,NOU3)
        IF (IPAR.GT.0) THEN
          DO 50,J = 1,NBGREL(LIGREL)
            NUTE = TYPELE(LIGREL,J)
            IPAR = INPARA(OPT,NUTE,'OUT',NOMPAR)

            IF (IPAR.EQ.0) GO TO 50
            NOU2 = NOU2 + 1
            LPAOU2(NOU2) = LPAOU(I)
            LCHOU2(NOU2) = LCHOU(I)
            GO TO 60
   50     CONTINUE
        END IF
   60 CONTINUE
C     -- VERIF PAS DE DOUBLONS DANS LPAOU2 :
      CALL KNDOUB(8,LPAOU2,NOU2,IRET)
      CALL ASSERT(IRET.EQ.0)


C     3- DEBCAL FAIT DES INITIALISATIONS ET MET LES OBJETS EN MEMOIRE :
C     -----------------------------------------------------------------
      CALL DEBCAL(OPTION,LIGREL,NIN2,LCHIN2,LPAIN2,NOU2,LCHOU2)


C     4- ALLOCATION DES RESULTATS ET DES CHAMPS LOCAUX:
C     -------------------------------------------------
      CALL ALRSLT(OPT,LIGREL,NOU2,LCHOU2,LPAOU2,BASE2)
      CALL ALCHLO(OPT,LIGREL,NIN2,LPAIN2,LCHIN2,NOU2,LPAOU2)



C     5- BOUCLE SUR LES GREL :
C     -------------------------------------------------
      NGREL = NBGREL(LIGREL)
      DO 80 IGR = 1,NGREL
        NUTE = TYPELE(LIGREL,IGR)
        CALL JENUNO(JEXNUM('&CATA.TE.NOMTE',NUTE),NOMTE)
        NOMTM = ZK8(JTYPMA-1+NUTE)
        CALL DISMOI('F','PHEN_MODE',NOMTE,'TYPE_ELEM',IBID,PHEMOD,IBID)
        PHENO = PHEMOD(1:16)
        MODELI = PHEMOD(17:32)
        NBELGR = NBELEM(LIGREL,IGR)
        NUMC = NUCALC(OPT,NUTE)
        IF (NUMC.LT.-10) CALL UTMESS('F','CALCUL','STOP 1')
        IF (NUMC.GT.9999) CALL UTMESS('F','CALCUL','STOP 2')


        IF (NUMC.GT.0) THEN
          CALL INIGRL(LIGREL,IGR,NBOBJ,ZI(IAINEL),ZK24(ININEL),NVAL)


C           5.2 ECRITURE AU FORMAT ".CODE" DU COUPLE (OPTION,TYPE_ELEM)
C           ------------------------------------------------------
          IF (IUNCOD.GT.0) THEN
            WRITE (IUNCOD,*) CAS,' &&CALCUL ',OPTION,' ',NOMTE,
     &        ' ''OUI'' '
          END IF


          NPIN = NBPARA(OPT,NUTE,'IN ')
          CALL MECOE1(OPT,NUTE)
          DO 70 IPAR = 1,NPIN
            NOMPAR = NOPARA(OPT,NUTE,'IN ',IPAR)
            IPARG = INDIK8(ZK8(IAOPPA),NOMPAR,1,NPARIO)
            IPARIN = INDIK8(LPAIN2,NOMPAR,1,NIN2)
            EXICH = ((IPARIN.GT.0) .AND. ZL(IACHIX-1+IPARIN))
            IF (.NOT.EXICH) THEN
              ZI(IAWLOC-1+7* (IPARG-1)+1) = -1
              ZI(IAWLOC-1+7* (IPARG-1)+4) = 0
              GO TO 70
            END IF

            CALL EXTRAI(NIN2,LCHIN2,LPAIN2,NOMPAR,LIGREL)
   70     CONTINUE


C           5.3 MISE A ZERO DES CHAMPS "OUT"
          CALL ZECHLO(OPT,NUTE)

C           5.4 ON ECRIT UNE VALEUR "UNDEF" AU BOUT DE
C              TOUS LES CHAMPS LOCAUX "IN" ET "OUT":
          CALL CAUNDF('ECRIT',OPT,NUTE)

C           5.5 ON FAIT LES CALCULS ELEMENTAIRES:
C         WRITE (6,*) 'AJACO OPTION=',OPTION,NOMTE,' ',NUMC
          CALL TE0000(NUMC,OPT,NUTE)

C           5.6 ON VERIFIE LA VALEUR "UNDEF" AU BOUT DES
C               CHAMPS LOCAUX "OUT" :
          CALL CAUNDF('VERIF',OPT,NUTE)

C           5.7 ON RECOPIE DES CHAMPS LOCAUX DANS LES CHAMPS GLOBAUX:
          CALL MONTEE(OPT,NUTE,NOU2,LCHOU2,LPAOU2)

        END IF
   80 CONTINUE
C     ---FIN BOUCLE IGR

      GO TO 100


   90 CONTINUE

C     -- SI 1 ELEMENT NE TROUVE PAS LES CHAMPS NECESSAIRES
C     -- POUR 1 CALCUL(OPT) QU'IL SAIT FAIRE, ON ARRETE TOUT:
C     -------------------------------------------------------
      CALL UTMESS('F',' CALCUL  ',' PROBLEME POUR UN CHAMP PARAMETRE:'//
     &            ' OPTION: '//OPTION//' LIGREL: '//LIGREL//
     &            ' TYPE_ELEMENT: '//NOMTE//' PARAMETRE: '//NOMPAR//
     &            ' ON ARRETE TOUT.')


  100 CONTINUE


C     6- SI DBG=.TRUE. ON FAIT DES IMPRESSIONS POUR LE DEBUG :
C     ----------------------------------------------------
      DBG = .FALSE.
      IF (DBG) CALL CALDBG(OPTION,NIN2,LCHIN2,NOU2,LCHOU2)


C     7- ON DETRUIT LES OBJETS VOLATILES CREES PAR CALCUL:
C     ----------------------------------------------------
      DO 110,I = 1,NBOBTR
        CALL JEDETR(ZK24(IAOBTR-1+I))
  110 CONTINUE
      CALL JEDETR('&&CALCUL.OBJETS_TRAV')

  120 CONTINUE
      IACTIF = 0
      CALL JEDEMA()
      END
