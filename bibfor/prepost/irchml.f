      SUBROUTINE IRCHML(CHAMEL,IFI,FORM,TITRE,LOC,NOMSD,NOMSYM,NUMORD,
     +            LCOR,NBNOT,NUMNOE,NBMAT,NUMMAI,NBCMP,NOMCMP,LSUP,
     +            BORSUP,LINF,BORINF,LMAX,LMIN,LRESU,FORMR,NCMP,NUCMP,
     +            NIVE )
      IMPLICIT REAL*8 (A-H,O-Z)
C
      CHARACTER*(*)     CHAMEL,NOMCMP(*),FORM,TITRE,LOC,NOMSD,NOMSYM
      CHARACTER*(*)     FORMR
      REAL*8            BORSUP,BORINF
      INTEGER           NBNOT,NUMNOE(*),NBMAT,NUMMAI(*),NBCMP,IFI,
     +                  NUMORD,NCMP,NUCMP(*),NIVE
      LOGICAL           LCOR,LSUP,LINF,LMAX,LMIN,LRESU
C     ------------------------------------------------------------------
C MODIF PREPOST  DATE 06/04/2004   AUTEUR DURAND C.DURAND 
C ======================================================================
C            CONFIGURATION MANAGEMENT OF EDF VERSION
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
C TOLE  CRP_21
C        IMPRESSION D'UN CHAM_ELEM A COMPOSANTES REELLES OU COMPLEXES
C         AU FORMAT IDEAS, RESULTAT, CASTEM
C  ENTREES:
C     CHAMEL : NOM DU CHAM_ELEM A ECRIRE
C     IFI    : NUMERO LOGIQUE DU FICHIER DE SORTIE
C     FORM   : FORMAT DES SORTIES: IDEAS, RESULTAT
C     TITRE  : TITRE POUR IDEAS
C     LOC    : LOCALISATION DES VALEURS ( ELNO OU ELGA)
C     NOMSD  : NOM DU RESULTAT
C     NOMSYM : NOM SYMBOLIQUE
C     NUMORD : NUMERO D'ORDRE DU CHAMP DANS LE RESULTAT_COMPOSE.
C     LCOR   : =.TRUE.  IMPRESSION DES COORDONNES DE NOEUDS DEMANDEE
C     NBNOT  : NOMBRE DE NOEUDS A IMPRIMER
C     NUMNOE : NUMEROS DES NOEUDS A IMPRIMER
C     NBMAT  : NOMBRE DE MAILLES A IMPRIMER
C     NUMMAI : NUMEROS DES MAILLES A IMPRIMER
C     NBCMP  : NOMBRE DE COMPOSANTES A IMPRIMER
C     NOMCMP : NOMS DES COMPOSANTES A IMPRIMER
C     LSUP   : =.TRUE.  INDIQUE PRESENCE D'UNE BORNE SUPERIEURE
C     BORSUP : VALEUR DE LA BORNE SUPERIEURE
C     LINF   : =.TRUE.  INDIQUE PRESENCE D'UNE BORNE INFERIEURE
C     BORINF : VALEUR DE LA BORNE INFERIEURE
C     LMAX   : =.TRUE.  INDIQUE IMPRESSION VALEUR MAXIMALE
C     LMIN   : =.TRUE.  INDIQUE IMPRESSION VALEUR MINIMALE
C     LRESU  : =.TRUE.  INDIQUE IMPRESSION D'UN CONCEPT RESULTAT
C     FORMR  : FORMAT D'ECRITURE DES REELS SUR "RESULTAT"
C     NIVE   : NIVEAU IMPRESSION CASTEM 3 OU 10
C ----------------------------------------------------------------------
C --------------- COMMUNS NORMALISES  JEVEUX  --------------------------
      COMMON /IVARJE/ZI(1)
      COMMON /RVARJE/ZR(1)
      COMMON /CVARJE/ZC(1)
      COMMON /LVARJE/ZL(1)
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
      INTEGER    ZI
      REAL*8     ZR
      COMPLEX*16 ZC
      LOGICAL    ZL
      CHARACTER*8  ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32,JEXNUM,JEXNOM,JEXATR
      CHARACTER*80 ZK80
C
      CHARACTER*1  K1BID, TYPE
      INTEGER      GD, DATE(9), NBACC, JPARA
      REAL*8       PARA
      CHARACTER*8  NOMMA, NOMGD, NOMEL, NOMNO, CBID
      CHARACTER*16 TSD,NOMSY2
      CHARACTER*19 NOMLIG, CHAME
      CHARACTER*24 NOLILI, NCONEC, NCNCIN
      CHARACTER*80 TITMAI
      LOGICAL      LMASU
C
      CALL JEMARQ ( )
      CHAME = CHAMEL(1:19)
      NBCMPT=0
      CALL JELIRA(CHAME//'.CELV','TYPE',IBID,TYPE)
      IF (TYPE(1:1).EQ.'R') THEN
         ITYPE = 1
      ELSE IF (TYPE(1:1).EQ.'C') THEN
         ITYPE = 2
      ELSE
         CALL UTMESS('A','IMPR_RESU ',
     +                 'ON NE SAIT PAS IMPRIMER LES CHAMPS DE TYPE "'//
     +     TYPE(1:1)//'"   ON EST VRAIMENT DESOLE.')
         GOTO 9999
      END IF


C     -- ON VERIFIE QUE LE CHAM_ELEM N'EST PAS TROP DYNAMIQUE :
C        SINON ON LE REMET SOUS SON ANCIENNE FORME :
C     ----------------------------------------------------------
      CALL CELVER(CHAME,'NBVARI_CST','COOL',KK)
      IF (KK.EQ.1) THEN
        CALL CELCEL('NBVARI_CST',CHAME,'V','&&IRCHML.CHAMEL1')
        CHAME= '&&IRCHML.CHAMEL1'
      END IF

      CALL CELVER(CHAME,'NBSPT_1','COOL',KK)
      IF (KK.EQ.1) THEN
        NOMSY2=NOMSYM
        IF (FORM.EQ.'RESULTAT') THEN
          CALL UTMESS('I','IRCHML','LE CHAMP: '//NOMSY2
     &  //' A DES ELEMENTS AYANT DES SOUS-POINTS.'
     &  //' IL EST ECRIT AVEC UN FORMAT DIFFERENT.')
          CALL CELCES(CHAME,'V','&&IRCHML_CES')
          CALL CESIMP('&&IRCHML_CES',IFI,NBMAT,NUMMAI)
          CALL DETRSD('CHAM_ELEM_S','&&IRCHML_CES')
          GO TO 9999
        ELSE
          CALL UTMESS('I','IRCHML','LE CHAMP: '//NOMSY2
     &  //' A DES ELEMENTS AYANT DES SOUS-POINTS.'
     &  //' CES ELEMENTS NE SERONT PAS ECRITS.')
        END IF
        CALL CELCEL('PAS_DE_SP',CHAME,'V','&&IRCHML.CHAMEL2')
        CHAME= '&&IRCHML.CHAMEL2'
      END IF


      CALL JEVEUO(CHAME//'.CELD','L',JCELD)
      GD = ZI(JCELD-1+1)
      NGR = ZI(JCELD-1+2)
      CALL JENUNO(JEXNUM('&CATA.GD.NOMGD',GD),NOMGD)
      CALL JELIRA(JEXNUM('&CATA.GD.NOMCMP',GD),'LONMAX',NCMPMX,K1BID)
      CALL JEVEUO(JEXNUM('&CATA.GD.NOMCMP',GD),'L',IAD)
      CALL WKVECT('&&IRCHML.NUM_CMP','V V I',NCMPMX,JNCMP)
      IF ( NBCMP.NE.0 .AND. NOMGD.NE.'VARI_R' ) THEN
         CALL IRCCMP(NOMGD,NCMPMX,ZK8(IAD),NBCMP,NOMCMP,NBCMPT,JNCMP)
      ENDIF
      CALL JEVEUO(CHAME//'.CELK','L',IACELK)
      NOLILI = ZK24(IACELK)
      CALL JEVEUO(NOLILI(1:19)//'.NOMA','L',IANOMA)
      NOMMA = ZK8(IANOMA)
C     RECHERCHE DU NOMBRE D'ELEMENTS : NBEL
      CALL JELIRA(NOMMA//'.NOMMAI','NOMMAX',NBEL,K1BID)
      CALL DISMOI('F','NB_NO_MAILLA',NOMMA,'MAILLAGE',NBNO,CBID,IER)
      CALL WKVECT('&&IRCHML.NOMMAI','V V K8',NBEL,JNOEL)
      CALL WKVECT('&&IRCHML.NBNOMA','V V I',NBEL,JNBNM)
      DO 11 IEL = 1,NBEL
         CALL JENUNO(JEXNUM(NOMMA//'.NOMMAI',IEL),NOMEL)
         ZK8(JNOEL-1+IEL) = NOMEL
         CALL JELIRA(JEXNUM(NOMMA//'.CONNEX',IEL),'LONMAX',NBN,K1BID)
         ZI(JNBNM-1+IEL) = NBN
   11 CONTINUE
      CALL JEVEUO(CHAME//'.CELV','L',JCELV)
      CALL JEVEUO(NOLILI(1:19)//'.LIEL','L',JLIGR)
      CALL JELIRA(NOLILI(1:19)//'.LIEL','NUTIOC',NBGREL,K1BID)
      CALL JEVEUO(JEXATR(NOLILI(1:19)//'.LIEL','LONCUM'),'L',JLONGR)
      IF (NGR.NE.NBGREL) THEN
         CALL UTDEBM('F','IRCHML','NGR DIFFERENT DE NBGREL')
         CALL UTIMPI('L',' NGR   =',1,NGR)
         CALL UTIMPI('S',' NBGREL=',1,NBGREL)
         CALL UTFINM()
      END IF
C ---------------------------------------------------------------------
C                    F O R M A T   R E S U L T A T
C ---------------------------------------------------------------------
      IF (FORM.EQ.'RESULTAT') THEN
C
         IF ( NBMAT .EQ. 0  .AND.  NBNOT .NE. 0 ) THEN
            NCONEC = NOMMA//'.CONNEX'
            CALL JELIRA(NCONEC,'NMAXOC',NBTMA,K1BID)
            CALL WKVECT('&&IRCHML.MAILLE','V V I',NBTMA,JLISTE)
            NCNCIN = '&&IRCHML.CONNECINVERSE  '
            CALL JEEXIN(NCNCIN,N2)
            IF ( N2 .EQ. 0 ) CALL CNCINV ( NOMMA,IBID,0, 'V', NCNCIN )
            LIBRE = 1
            CALL JEVEUO(JEXATR(NCNCIN,'LONCUM'),'L',JDRVLC)
            CALL JEVEUO(JEXNUM(NCNCIN,1)       ,'L',JCNCIN)
            DO 100, IN = 1, NBNOT, 1
               N   = NUMNOE(IN)
               NBM = ZI(JDRVLC + N+1-1) - ZI(JDRVLC + N-1)
               IADR = ZI(JDRVLC + N-1)
               CALL I2TRGI(ZI(JLISTE),ZI(JCNCIN+IADR-1),NBM,LIBRE)
 100        CONTINUE
            NBMAC = LIBRE - 1
         ELSE
            NBMAC = NBMAT
            JLISTE = 1
            IF ( NBMAT .NE. 0 ) THEN
               CALL WKVECT('&&IRCHML.MAILLE','V V I',NBMAC,JLISTE)
               DO 110 IM = 1 , NBMAC
                  ZI(JLISTE+IM-1) = NUMMAI(IM)
 110           CONTINUE
            ENDIF
         ENDIF
C
        IF (LOC.EQ.'ELNO') THEN
          CALL WKVECT('&&IRCHML.NOMNOE','V V K8',NBNO,JNMN)
          DO 21 INO = 1,NBNO
            CALL JENUNO(JEXNUM(NOMMA//'.NOMNOE',INO),NOMNO)
            ZK8(JNMN-1+INO) = NOMNO
   21     CONTINUE
          CALL JEVEUO(NOMMA//'.CONNEX','L',JCNX)
          CALL JEVEUO(JEXATR(NOMMA//'.CONNEX','LONCUM'),'L',JPNT)
C --
C --  RECHERCHE DES COORDONNEES ET DE LA DIMENSION
C
          IF(LCOR) THEN
            CALL DISMOI('F','DIM_GEOM',NOMMA,'MAILLAGE',NDIM,CBID,IER)
            CALL JEVEUO(NOMMA//'.COORDO    .VALE','L',JCOOR)
          ENDIF
        END IF
        IF (ITYPE.EQ.1) THEN
          CALL IRCERL(IFI,NBEL,ZI(JLIGR),NBGREL,ZI(JLONGR),NCMPMX,
     +       ZR(JCELV),ZK8(IAD),ZK8(JNOEL),LOC,ZI(JCELD),
     +       ZI(JCNX),ZI(JPNT),ZK8(JNMN),NBCMPT,ZI(JNCMP),
     +       NBNOT,NUMNOE,NBMAC,ZI(JLISTE),
     +       LSUP,BORSUP,LINF,BORINF,LMAX,LMIN,
     +       LCOR,NDIM,ZR(JCOOR),NOLILI(1:19), FORMR, NCMP,NUCMP )
        ELSE IF (ITYPE.EQ.2) THEN
          CALL IRCECL(IFI,NBEL,ZI(JLIGR),NBGREL,ZI(JLONGR),NCMPMX,
     +       ZC(JCELV),ZK8(IAD),ZK8(JNOEL),LOC,ZI(JCELD),
     +       ZI(JCNX),ZI(JPNT),ZK8(JNMN),NBCMPT,ZI(JNCMP),
     +       NBNOT,NUMNOE,NBMAC,ZI(JLISTE),
     +       LSUP,BORSUP,LINF,BORINF,LMAX,LMIN,
     +       LCOR,NDIM,ZR(JCOOR),NOLILI(1:19), FORMR, NCMP,NUCMP )
        ENDIF
        IF (LOC.EQ.'ELNO') CALL JEDETR('&&IRCHML.NOMNOE')
        CALL JEDETR('&&IRCHML.MAILLE')
C ---------------------------------------------------------------------
C                    F O R M A T   I D E A S
C ---------------------------------------------------------------------
      ELSE IF (FORM(1:5).EQ.'IDEAS') THEN
         LMASU = .FALSE.
         CALL JEEXIN(NOMMA//'           .TITR',IRET)
         IF(IRET.NE.0) THEN
           CALL JEVEUO(NOMMA//'           .TITR','L',JTITR)
           CALL JELIRA(NOMMA//'           .TITR','LONMAX',NBTITR,K1BID)
           IF(NBTITR.GE.1) THEN
             TITMAI=ZK80(JTITR-1+1)
             IF(TITMAI(10:31).EQ.'AUTEUR=INTERFACE_IDEAS') LMASU=.TRUE.
           ENDIF
         ENDIF
         CALL JEVEUO(NOMMA//'.TYPMAIL','L',JTYPM)
         CALL JEEXIN('&IRCHML.PERMUTA',IRET)
         IF (IRET.EQ.0) CALL IRADHS
         CALL JEVEUO('&&IRADHS.PERMUTA','L',JPERM)
         CALL JELIRA('&&IRADHS.PERMUTA','LONMAX',LON1,K1BID)
         MAXNOD=ZI(JPERM-1+LON1)
         IF (ITYPE.EQ.1) THEN
            CALL IRCERS(IFI,ZI(JLIGR),NBGREL,ZI(JLONGR),NCMPMX,
     +                  ZR(JCELV),NOMGD,ZK8(IAD),TITRE,ZK8(JNOEL),LOC,
     +                  ZI(JCELD),ZI(JNBNM),ZI(JPERM),MAXNOD,
     +                  ZI(JTYPM),NOMSD,NOMSYM,NUMORD,NBMAT,NUMMAI,
     +                  LMASU,NCMP,NUCMP,NBCMP,ZI(JNCMP),NOMCMP)
         ELSE IF (ITYPE.EQ.2) THEN
            CALL IRCECS(IFI,ZI(JLIGR),NBGREL,ZI(JLONGR),NCMPMX,
     +                  ZC(JCELV),ZK8(IAD),TITRE,ZK8(JNOEL),LOC,
     +                  ZI(JCELD),ZI(JNBNM),ZI(JPERM),MAXNOD,
     +                  ZI(JTYPM),NOMSD,NOMSYM,NUMORD,NBMAT,NUMMAI,
     +                  LMASU,NCMP,NUCMP)
         ENDIF
         CALL JEDETR('&&IRADHS.PERMUTA')
         CALL JEDETR('&&IRADHS.CODEGRA')
         CALL JEDETR('&&IRADHS.CODEPHY')
         CALL JEDETR('&&IRADHS.CODEPHD')
C ---------------------------------------------------------------------
C                    F O R M A T   C A S T E M
C ---------------------------------------------------------------------
      ELSE IF (FORM.EQ.'CASTEM')  THEN
         CALL JEVEUO ( '&&OP0039.NOM_MODELE', 'L', JMODE )
         CALL JELIRA ( '&&OP0039.NOM_MODELE', 'LONUTI', NBMODL, CBID )
         DO 200 IMOD = 1 , NBMODL
            IF ( NOLILI .EQ. ZK24(JMODE-1+IMOD) ) GOTO 202
 200     CONTINUE
         CALL UTMESS('A','IRCHML','MODELE INCONNU, PAS D''IMPRESSION '
     +                          //'DU CHAMP '//CHAME)
         GOTO 204
 202     CONTINUE
         IF(ITYPE.EQ.1) THEN
           CALL JEVEUO(NOMMA//'.TYPMAIL','L',JTYPM)
           IF (LOC.EQ.'ELNO') THEN
             CALL IRCECA(IFI,ZI(JLIGR),NBGREL,ZI(JLONGR),NCMPMX,
     +                  ZR(JCELV),NOMGD,ZK8(IAD),
     +                  ZI(JCELD),ZI(JNBNM),ZI(JTYPM),
     +                  NOMSYM,NBMAT,LRESU,NBCMP,NOMCMP,IMOD,
     +                  NCMP,NUCMP,NIVE)
           ELSEIF (LOC.EQ.'ELGA') THEN
             CALL UTMESS('A','IRCHML','ON NE SAIT PAS ECRIRE DES '
     +           //' CHAMPS PAR ELEMENT AUX POINTS DE GAUSS AU FORMAT'
     +           //' CASTEM')
           ENDIF
         ELSEIF (ITYPE.EQ.2) THEN
         ENDIF
      END IF
 204  CONTINUE
      CALL JEDETR('&&IRCHML.NUM_CMP')
      CALL JEDETR('&&IRCHML.NOMMAI')
      CALL JEDETR('&&IRCHML.NBNOMA')
      CALL JEDETR('&&IRCHML.MAILLE')
      CALL JEDETR('&&IRCHML.NOMNOE')
      CALL DETRSD('CHAM_ELEM','&&IRCHML.CHAMEL1')
      CALL DETRSD('CHAM_ELEM','&&IRCHML.CHAMEL2')
 9999 CONTINUE
      CALL JEDEMA ( )
      END
