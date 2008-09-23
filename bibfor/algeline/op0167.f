      SUBROUTINE OP0167(IER)
      IMPLICIT REAL*8(A-H,O-Z)
      INTEGER IER
C     ------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGELINE  DATE 22/09/2008   AUTEUR COURTOIS M.COURTOIS 
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
C TOLE CRP_20
C RESPONSABLE MCOURTOI M.COURTOIS
C     OPERATEUR CREA_MAILLAGE
C     ------------------------------------------------------------------

C     ----- DEBUT COMMUNS NORMALISES  JEVEUX  --------------------------
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
      CHARACTER*32 JEXNUM,JEXNOM
C     -----  FIN  COMMUNS NORMALISES  JEVEUX  --------------------------
      INTEGER I,LGNO,LGNU,NBECLA,NBMC,IRET,IAD,NBMA,NBMST,IQTR,NBVOLU,
     &        N1,NUMMA,NBJOIN,NBREST
      PARAMETER(NBMC=5)
      REAL*8 EPAIS
      CHARACTER*1 K1B
      CHARACTER*4 CDIM
      CHARACTER*8 K8B,NOMAIN,NOMAOU,NEWMAI,NOGMA,PREFIX
      CHARACTER*8 NOMG,NOMORI,KNUME,PRFNO,PRFMA,PLAN,TRANS
      CHARACTER*16 TYPCON,NOMCMD,OPTION
      CHARACTER*16 MOTFAC,TYMOCL(NBMC),MOTCLE(NBMC)
      CHARACTER*19 TABLE
      CHARACTER*24 NOMMAI,GRPMAI,TYPMAI,CONNEX,NODIME,GRPNOE,NOMNOE,
     &             COOVAL,COODSC,COOREF,NOMJV
      CHARACTER*24 NOMMAV,GRPMAV,TYPMAV,CONNEV,NODIMV,GRPNOV,NOMNOV,
     &             COOVAV,COODSV,COOREV
      CHARACTER*24 MOMANU,MOMANO,CRMANU,CRMANO,CRGRNU,CRGRNO,LISI,LISK
      CHARACTER*24 VALK(2)
      CHARACTER*24 PRFN1,PRFN2,NUME2,IADR,NUME1,MOMOTO,MOMUTO,PRFN
      INTEGER NN1
      LOGICAL LOGIC
C     ------------------------------------------------------------------

      CALL JEMARQ()

      CALL INFMAJ()
      CALL INFNIV(IFM,NIV)

      CALL GETRES(NOMAOU,TYPCON,NOMCMD)
      CALL GETVID(' ','MAILLAGE',1,1,1,NOMAIN,NN1)

C ----------------------------------------------------------------------
C               TRAITEMENT DU MOT CLE "ECLA_PG"
C ----------------------------------------------------------------------

      CALL GETFAC('ECLA_PG',NBECLA)
      IF (NBECLA.GT.0) THEN
        CALL ECLPGM()
        GOTO 350

      ENDIF

C ----------------------------------------------------------------------
C          TRAITEMENT DU MOT CLE "CREA_FISS"
C ----------------------------------------------------------------------

      CALL GETFAC('CREA_FISS',NBJOIN)
      IF (NBJOIN.NE.0) THEN
        IF (NN1.EQ.0) THEN
          CALL U2MESS('F','ALGELINE2_89')
        ENDIF
        CALL WKVECT('&&OP0167.NOMMC','V V K16',NBJOIN,JNOMMC)
        CALL WKVECT('&&OP0167.OCCMC','V V I',NBJOIN,JOCCMC)
        DO 10 I=1,NBJOIN
          ZK16(JNOMMC-1+I)='CREA_FISS'
          ZI(JOCCMC-1+I)=I
   10   CONTINUE

        CALL CMCREA(NOMAIN,NOMAOU,NBJOIN,ZK16(JNOMMC),ZI(JOCCMC))
        GOTO 350

      ENDIF


C ----------------------------------------------------------------------
C          TRAITEMENT DU MOT CLE "LINE_QUAD"
C ----------------------------------------------------------------------

      CALL GETFAC('LINE_QUAD',NBMOMA)
      IF (NBMOMA.GT.0) THEN
        IF (NN1.EQ.0) THEN
          CALL U2MESS('F','ALGELINE2_90')
        ENDIF
        CALL GETVTX('LINE_QUAD','PREF_NOEUD',1,1,1,PREFIX,N1)
        CALL GETVIS('LINE_QUAD','PREF_NUME',1,1,1,NDINIT,N1)

        MOTCLE(1)='MAILLE'
        MOTCLE(2)='GROUP_MA'
        MOTCLE(3)='TOUT'
        NOMJV='&&OP0167.LISTE_MA'
        CALL RELIEM(' ',NOMAIN,'NU_MAILLE','LINE_QUAD',1,3,MOTCLE,
     &              MOTCLE,NOMJV,NBMA)
        CALL JEVEUO(NOMJV,'L',JLIMA)
        CALL JEEXIN(NOMAIN//'.NOMACR',IRET)
        IF (IRET.NE.0) CALL U2MESS('F','ALGELINE2_91')
        CALL JEEXIN(NOMAIN//'.ABS_CURV',IRET)
        IF (IRET.NE.0) CALL U2MESS('F','ALGELINE2_92')

        CALL CMLQLQ(NOMAIN,NOMAOU,NBMA,ZI(JLIMA),PREFIX,NDINIT)

        GOTO 350

      ENDIF

C ----------------------------------------------------------------------
C          TRAITEMENT DU MOT CLE "HEXA20_27"
C ----------------------------------------------------------------------

      CALL GETFAC('HEXA20_27',NBMOMA)
      IF (NBMOMA.GT.0) THEN
        IF (NN1.EQ.0) THEN
          CALL U2MESS('F','MAIL0_14')
        ENDIF
        CALL GETVTX('HEXA20_27','PREF_NOEUD',1,1,1,PREFIX,N1)
        CALL GETVIS('HEXA20_27','PREF_NUME',1,1,1,NDINIT,N1)

        MOTCLE(1)='MAILLE'
        MOTCLE(2)='GROUP_MA'
        MOTCLE(3)='TOUT'
        NOMJV='&&OP0167.LISTE_MA'
        CALL RELIEM(' ',NOMAIN,'NU_MAILLE','HEXA20_27',1,3,MOTCLE,
     &              MOTCLE,NOMJV,NBMA)
        CALL JEVEUO(NOMJV,'L',JLIMA)
        CALL JEEXIN(NOMAIN//'.NOMACR',IRET)
        IF (IRET.NE.0) CALL U2MESS('F','MAIL0_12')
        CALL JEEXIN(NOMAIN//'.ABS_CURV',IRET)
        IF (IRET.NE.0) CALL U2MESS('F','MAIL0_13')

        CALL CM2027(NOMAIN,NOMAOU,NBMA,ZI(JLIMA),PREFIX,NDINIT)

        GOTO 350

      ENDIF
C ----------------------------------------------------------------------
C          TRAITEMENT DU MOT CLE "QUAD_LINE"
C ----------------------------------------------------------------------

      CALL GETFAC('QUAD_LINE',NBMOMA)
      IF (NBMOMA.GT.0) THEN
        IF (NN1.EQ.0) THEN
          CALL U2MESS('F','ALGELINE2_93')
        ENDIF
        MOTCLE(1)='MAILLE'
        MOTCLE(2)='GROUP_MA'
        MOTCLE(3)='TOUT'
        NOMJV='&&OP0167.LISTE_MA'
        CALL RELIEM(' ',NOMAIN,'NU_MAILLE','QUAD_LINE',1,3,MOTCLE,
     &              MOTCLE,NOMJV,NBMA)
        CALL JEVEUO(NOMJV,'L',JLIMA)
        CALL JEEXIN(NOMAIN//'.NOMACR',IRET)
        IF (IRET.NE.0) CALL U2MESS('F','ALGELINE2_94')
        CALL JEEXIN(NOMAIN//'.ABS_CURV',IRET)
        IF (IRET.NE.0) CALL U2MESS('F','ALGELINE2_95')

        CALL CMQLQL(NOMAIN,NOMAOU,NBMA,ZI(JLIMA))

        GOTO 350

      ENDIF

C ----------------------------------------------------------------------
C          TRAITEMENT DU MOT CLE "MODI_MAILLE", OPTION "QUAD_TRIA3"
C ----------------------------------------------------------------------

      CALL GETFAC('MODI_MAILLE',NBMOMA)
      IF (NBMOMA.GT.0) THEN
        IF (NN1.EQ.0) THEN
          CALL U2MESS('F','ALGELINE2_96')
        ENDIF
        IQTR=0
        DO 20 IOCC=1,NBMOMA
          CALL GETVTX('MODI_MAILLE','OPTION',IOCC,1,1,OPTION,N1)
          IF (OPTION.EQ.'QUAD_TRIA3')IQTR=IQTR+1
   20   CONTINUE
        IF (IQTR.EQ.0) THEN
          GOTO 30

        ELSEIF (IQTR.GT.1) THEN
          CALL U2MESS('F','ALGELINE2_97')
        ELSEIF (IQTR.EQ.1 .AND. NBMOMA.NE.1) THEN
          CALL U2MESS('F','ALGELINE2_97')
        ENDIF

        CALL GETVTX('MODI_MAILLE','PREF_MAILLE',1,1,1,PREFIX,N1)
        CALL GETVIS('MODI_MAILLE','PREF_NUME',1,1,1,NDINIT,N1)

        MOTCLE(1)='MAILLE'
        MOTCLE(2)='GROUP_MA'
        MOTCLE(3)='TOUT'
        NOMJV='&&OP0167.LISTE_MA'
        CALL RELIEM(' ',NOMAIN,'NU_MAILLE','MODI_MAILLE',1,3,MOTCLE,
     &              MOTCLE,NOMJV,NBMA)
        CALL JEVEUO(NOMJV,'L',JLIMA)

        CALL CMQUTR('G',NOMAIN,NOMAOU,NBMA,ZI(JLIMA),PREFIX,NDINIT)

        GOTO 350

      ENDIF
   30 CONTINUE

C ----------------------------------------------------------------------
C                 TRAITEMENT DU MOT CLE "COQU_VOLU"
C ----------------------------------------------------------------------

      CALL GETFAC('COQU_VOLU',NBVOLU)
      IF (NBVOLU.NE.0) THEN
        IF (NN1.EQ.0) THEN
          CALL U2MESS('F','ALGELINE2_98')
        ENDIF
C
        CALL GETVR8('COQU_VOLU','EPAIS',1,1,1,EPAIS,N1)
        CALL GETVTX('COQU_VOLU','PREF_NOEUD',1,1,1,PRFNO,N1)
        CALL GETVTX('COQU_VOLU','PREF_MAILLE',1,1,1,PRFMA,N1)
        CALL GETVIS('COQU_VOLU','PREF_NUME',1,1,1,NUMMA,N1)
        CALL GETVTX('COQU_VOLU','PLAN',1,1,1,PLAN,N1)
C
        IF (PLAN.EQ.'MOY') THEN
          TRANS='INF'
          CALL GETVTX('COQU_VOLU','TRANSLATION',1,1,1,TRANS,N1)
        ENDIF

        NOMJV='&&OP0167.LISTE_MAV'
        CALL RELIEM(' ',NOMAIN,'NU_MAILLE','COQU_VOLU',1,1,'GROUP_MA',
     &              'GROUP_MA',NOMJV,NBMA)
        CALL JEVEUO(NOMJV,'L',JMA)
C
        CALL CMCOVO(NOMAIN,NOMAOU,NBMA,ZI(JMA),PRFNO,PRFMA,NUMMA,EPAIS,
     &              PLAN,TRANS)
C
C
        GOTO 350

      ENDIF

C ----------------------------------------------------------------------
C                 TRAITEMENT DU MOT CLE "RESTREINT"
C ----------------------------------------------------------------------
      CALL GETFAC('RESTREINT',NBREST)
      IF (NBREST.NE.0) THEN
        IF (NN1.EQ.0) THEN
          CALL U2MESS('F','ALGELINE2_98')
        ENDIF
        CALL RDTMAI(NOMAIN,NOMAOU,'G',' ',' ')
C ---    VERIFICATIONS DU MAILLAGE
        CALL CHCKMA(NOMAOU,NOMCMD,1.0D-03)
        GOTO 350

      ENDIF

C ----------------------------------------------------------------------
C               AURES MOTS CLES :
C ----------------------------------------------------------------------

      NOMMAV=NOMAIN//'.NOMMAI         '
      NOMNOV=NOMAIN//'.NOMNOE         '
      TYPMAV=NOMAIN//'.TYPMAIL        '
      CONNEV=NOMAIN//'.CONNEX         '
      GRPMAV=NOMAIN//'.GROUPEMA       '
      GRPNOV=NOMAIN//'.GROUPENO       '
      NODIMV=NOMAIN//'.DIME           '
      COOVAV=NOMAIN//'.COORDO    .VALE'
      COODSV=NOMAIN//'.COORDO    .DESC'
      COOREV=NOMAIN//'.COORDO    .REFE'

      NOMMAI=NOMAOU//'.NOMMAI         '
      NOMNOE=NOMAOU//'.NOMNOE         '
      TYPMAI=NOMAOU//'.TYPMAIL        '
      CONNEX=NOMAOU//'.CONNEX         '
      GRPMAI=NOMAOU//'.GROUPEMA       '
      GRPNOE=NOMAOU//'.GROUPENO       '
      NODIME=NOMAOU//'.DIME           '
      COOVAL=NOMAOU//'.COORDO    .VALE'
      COODSC=NOMAOU//'.COORDO    .DESC'
      COOREF=NOMAOU//'.COORDO    .REFE'


      LOGIC=.FALSE.
      CALL JEDUPO(NODIMV,'G',NODIME,LOGIC)
      CALL JEDUPO(COODSV,'G',COODSC,LOGIC)
      CALL JEDUPO(COOREV,'G',COOREF,LOGIC)
      CALL JEDUPO(NOMAIN//'.NOMACR','G',NOMAOU//'.NOMACR',LOGIC)
      CALL JEDUPO(NOMAIN//'.PARA_R','G',NOMAOU//'.PARA_R',LOGIC)
      CALL JEDUPO(NOMAIN//'.SUPMAIL','G',NOMAOU//'.SUPMAIL',LOGIC)
      CALL JEDUPO(NOMAIN//'.TYPL','G',NOMAOU//'.TYPL',LOGIC)
      CALL JEDUPO(NOMAIN//'.ABS_CURV','G',NOMAOU//'.ABS_CURV',LOGIC)

      CALL JEVEUO(COOREF,'E',JREFE)
      ZK24(JREFE)=NOMAOU

      CALL JEVEUO(NODIME,'E',JDIME)
      NBNOEV=ZI(JDIME)
      NBMAIV=ZI(JDIME+3-1)

      CALL JEVEUO(TYPMAV,'L',JTYPMV)

C ----------------------------------------------------------------------
C               TRAITEMENT DU MOT CLE "MODI_MAILLE"
C ----------------------------------------------------------------------

      CALL GETFAC('MODI_MAILLE',NBMOMA)
      NBNOAJ=0
C
      IF (NBMOMA.NE.0) THEN
        IF (NN1.EQ.0) CALL U2MESS('F','ALGELINE2_96')
        MOMANU='&&OP0167.MO_MA.NUM'
        MOMANO='&&OP0167.MO_MA.NOM'

        MOMUTO='&&OP0167.MO_TO.NUM'
        MOMOTO='&&OP0167.MO_TO.NOM'

        LISI='&&OP0167.LISI'
        LISK='&&OP0167.LISK'

        IADR='&&OP0167.IADR'
        PRFN='&&OP0167.PRFN'
        NUME1='&&OP0167.NUME'
        PRFN2='&&OP0167.PRFN2'
        NUME2='&&OP0167.NUME2'

        CALL WKVECT(MOMANU,'V V I',NBMAIV,JMOMNU)
        CALL WKVECT(MOMANO,'V V K8',NBMAIV,JMOMNO)

        CALL WKVECT(IADR,'V V I',NBMOMA,JIAD)
        CALL WKVECT(PRFN,'V V K8',NBMOMA,JPRO)
        CALL WKVECT(NUME1,'V V I',NBMOMA,JNUM)
        CALL WKVECT(PRFN2,'V V K8',NBMAIV,JPR2)
        CALL WKVECT(NUME2,'V V I',NBMAIV,JNU2)
C
        IAD=1
        DO 60 IOCC=1,NBMOMA
          ZI(JIAD+IOCC-1)=1
          CALL GETVTX('MODI_MAILLE','PREF_NOEUD',IOCC,1,0,K8B,N1)
          IF (N1.NE.0) THEN
            CALL GETVTX('MODI_MAILLE','PREF_NOEUD',IOCC,1,1,
     &                  ZK8(JPRO+IOCC-1),N1)
            LGNO=LXLGUT(ZK8(JPRO+IOCC-1))
          ENDIF
          CALL GETVIS('MODI_MAILLE','PREF_NUME',IOCC,1,0,IBID,N1)
          IF (N1.NE.0) CALL GETVIS('MODI_MAILLE','PREF_NUME',IOCC,1,1,
     &                             ZI(JNUM+IOCC-1),N1)
          CALL PALIM2('MODI_MAILLE',IOCC,NOMAIN,MOMANU,MOMANO,
     &                ZI(JIAD+IOCC-1))
          IF (ZI(JIAD+IOCC-1)-1.LE.0)GOTO 60

          CALL WKVECT(LISI,'V V I',ZI(JIAD+IOCC-1)-1,JLII)
          CALL WKVECT(LISK,'V V K8',ZI(JIAD+IOCC-1)-1,JLIK)

          DO 40 II=1,ZI(JIAD+IOCC-1)-1
            ZI(JLII+II-1)=ZI(JMOMNU+II-1)
            ZK8(JLIK+II-1)=ZK8(JMOMNO+II-1)
   40     CONTINUE
          CALL COCALI(MOMUTO,LISI,'I')
          CALL COCALI(MOMOTO,LISK,'K8')
          IAA=IAD
          IAD=IAD+ZI(JIAD+IOCC-1)-1
C
C LE PREFIXE EST LE MEME POUR TOUS LES NOEUDS ENTRE
C L'ANCIENNE ET LA NOUVELLE ADRESSE
C
          DO 50 II=IAA,IAD-1
            ZK8(JPR2+II-1)=ZK8(JPRO+IOCC-1)
   50     CONTINUE
C
C LE PREF_NUME EST A DEFINIR POUR LE PREMIER NOEUD
C LES AUTRES SE TROUVENT EN INCREMENTANT

          ZI(JNU2+IAA-1)=ZI(JNUM+IOCC-1)
          CALL JEDETR(LISI)
          CALL JEDETR(LISK)

          IF (NIV.GE.1) THEN
            WRITE (IFM,9000)IOCC
            CALL GETVTX('MODI_MAILLE','OPTION',IOCC,1,1,OPTION,N1)
            IF (OPTION.EQ.'TRIA6_7') THEN
              WRITE (IFM,9010)ZI(JIAD+IOCC-1)-1,'TRIA6','TRIA7'
            ELSEIF (OPTION.EQ.'QUAD8_9') THEN
              WRITE (IFM,9010)ZI(JIAD+IOCC-1)-1,'QUAD8','QUAD9'
            ELSEIF (OPTION.EQ.'SEG3_4') THEN
              WRITE (IFM,9010)ZI(JIAD+IOCC-1)-1,'SEG3','SEG4'
            ENDIF
          ENDIF
   60   CONTINUE
C
        CALL JEVEUO(MOMUTO,'L',JMOMTU)
        CALL JEVEUO(MOMOTO,'L',JMOMTO)
        NBNOAJ=IAD-1
        IF (NBNOAJ.EQ.0) CALL U2MESS('F','ALGELINE2_99')
      ENDIF

C ----------------------------------------------------------------------
C                TRAITEMENT DU MOT CLE "CREA_MAILLE"
C ----------------------------------------------------------------------

      CALL GETFAC('CREA_MAILLE',NBCRMA)
      NBMAJ1=0
      IF (NBCRMA.NE.0) THEN
        IF (NN1.EQ.0) THEN
          CALL U2MESS('F','ALGELINE3_1')
        ENDIF
        CRMANU='&&OP0167.CR_MA.NUM'
        CRMANO='&&OP0167.CR_MA.NOM'
        CALL WKVECT(CRMANU,'V V I',NBMAIV,JCRMNU)
        CALL WKVECT(CRMANO,'V V K8',NBMAIV,JCRMNO)
        NBMAJ1=0
        DO 70 IOCC=1,NBCRMA
          NBMST=NBMAJ1
          CALL PALIM3('CREA_MAILLE',IOCC,NOMAIN,CRMANU,CRMANO,NBMAJ1)
          IF (NIV.GE.1) THEN
            WRITE (IFM,9040)IOCC
            WRITE (IFM,9050)NBMAJ1-NBMST
          ENDIF
   70   CONTINUE
        CALL JEVEUO(CRMANU,'L',JCRMNU)
        CALL JEVEUO(CRMANO,'L',JCRMNO)
      ENDIF

C ----------------------------------------------------------------------
C                 TRAITEMENT DU MOT CLE "CREA_GROUP_MA"
C ----------------------------------------------------------------------

      CALL GETFAC('CREA_GROUP_MA',NBGRMA)
      NBMAJ2=0
      IF (NBGRMA.NE.0) THEN
        IF (NN1.EQ.0) THEN
          CALL U2MESS('F','ALGELINE3_2')
        ENDIF
        CRGRNU='&&OP0167.CR_GR.NUM'
        CRGRNO='&&OP0167.CR_GR.NOM'
        CALL WKVECT(CRGRNU,'V V I',NBMAIV,JCRGNU)
        CALL WKVECT(CRGRNO,'V V K8',NBMAIV,JCRGNO)
        NBMAJ2=0
        DO 80 IOCC=1,NBGRMA
          CALL PALIM3('CREA_GROUP_MA',IOCC,NOMAIN,CRGRNU,CRGRNO,NBMAJ2)
   80   CONTINUE
        CALL JEVEUO(CRGRNU,'L',JCRGNU)
        CALL JEVEUO(CRGRNO,'L',JCRGNO)
      ENDIF

C ----------------------------------------------------------------------
C                TRAITEMENT DU MOT CLE "CREA_POI1"
C ----------------------------------------------------------------------

      CALL GETFAC('CREA_POI1',NBCRP1)
      NBMAJ3=0
      IF (NBCRP1.NE.0) THEN
        IF (NN1.EQ.0) THEN
          CALL U2MESS('F','ALGELINE3_3')
        ENDIF
        CALL JENONU(JEXNOM('&CATA.TM.NOMTM','POI1'),NTPOI)

C        -- RECUPERATION DE LA LISTE DES NOEUD :
        NOMJV='&&OP0167.LISTE_NO'
        MOTFAC='CREA_POI1'
        MOTCLE(1)='NOEUD'
        TYMOCL(1)='NOEUD'
        MOTCLE(2)='GROUP_NO'
        TYMOCL(2)='GROUP_NO'
        MOTCLE(3)='MAILLE'
        TYMOCL(3)='MAILLE'
        MOTCLE(4)='GROUP_MA'
        TYMOCL(4)='GROUP_MA'
        MOTCLE(5)='TOUT'
        TYMOCL(5)='TOUT'

        CALL WKVECT('&&OP0167.IND_NOEUD','V V I',NBNOEV,JTRNO)
        CALL WKVECT('&&OP0167.NOM_NOEUD','V V K8',NBNOEV,JNONO)

        DO 100 IOCC=1,NBCRP1
          CALL RELIEM(' ',NOMAIN,'NO_NOEUD',MOTFAC,IOCC,NBMC,MOTCLE,
     &                TYMOCL,NOMJV,NBNO)
          CALL JEVEUO(NOMJV,'L',JNOEU)
          DO 90 I=0,NBNO-1
            CALL JENONU(JEXNOM(NOMNOV,ZK8(JNOEU+I)),INO)
            ZI(JTRNO-1+INO)=1
   90     CONTINUE
  100   CONTINUE

C        --- VERIFICATION QUE LE NOM N'EXISTE PAS ET COMPTAGE---
        DO 110 IMA=1,NBNOEV
          IF (ZI(JTRNO+IMA-1).EQ.0)GOTO 110
          CALL JENUNO(JEXNUM(NOMNOV,IMA),NEWMAI)
          CALL JENONU(JEXNOM(NOMMAV,NEWMAI),IBID)
          IF (IBID.EQ.0) THEN
            NBMAJ3=NBMAJ3+1
            ZK8(JNONO-1+NBMAJ3)=NEWMAI
          ELSE
            VALK(1)=NEWMAI
            VALK(2)=NEWMAI
            CALL U2MESG('A','ALGELINE4_43',2,VALK,0,0,0,0.D0)
          ENDIF
  110   CONTINUE
      ENDIF

C ----------------------------------------------------------------------
C          ON AGRANDIT LE '.NOMNOE' ET LE '.COORDO    .VALE'
C ----------------------------------------------------------------------

      IF (NBNOAJ.NE.0) THEN
        NBNOT=NBNOEV+NBNOAJ
        ZI(JDIME)=NBNOT

        CALL JECREO(NOMNOE,'G N K8')
        CALL JEECRA(NOMNOE,'NOMMAX',NBNOT,' ')
        DO 120 INO=1,NBNOEV
          CALL JENUNO(JEXNUM(NOMNOV,INO),NOMG)
          CALL JEEXIN(JEXNOM(NOMNOE,NOMG),IRET)
          IF (IRET.EQ.0) THEN
            CALL JECROC(JEXNOM(NOMNOE,NOMG))
          ELSE
            VALK(1)=NOMG
            CALL U2MESG('F','ALGELINE4_5',1,VALK,0,0,0,0.D0)
          ENDIF
  120   CONTINUE
        DO 130 INO=NBNOEV+1,NBNOT
C TRAITEMENT DES NOEUDS AJOUTES
C ON CODE LE NUMERO DU NOEUD COURANT
          CALL CODENT(ZI(JNU2+INO-NBNOEV-1),'G',KNUME)
C
C SI LE PREFIXE COURANT EST LE MEME QUE LE SUIVANT ALORS
C LE NUME EST INCREMENTE
          IF (ZK8(JPR2+INO-NBNOEV-1).EQ.ZK8(JPR2+INO-NBNOEV)) THEN
            ZI(JNU2+INO-NBNOEV)=ZI(JNU2+INO-NBNOEV-1)+1
          ENDIF
C
          LGNU=LXLGUT(KNUME)
          PRFN1=ZK8(JPR2+INO-NBNOEV-1)
          LGNO=LXLGUT(PRFN1)
          IF (LGNU+LGNO.GT.8) CALL U2MESS('F','ALGELINE_16')
          NOMG=PRFN1(1:LGNO)//KNUME
          CALL JEEXIN(JEXNOM(NOMNOE,NOMG),IRET)
          IF (IRET.EQ.0) THEN
            CALL JECROC(JEXNOM(NOMNOE,NOMG))
          ELSE
            VALK(1)=NOMG
            CALL U2MESG('F','ALGELINE4_5',1,VALK,0,0,0,0.D0)
          ENDIF
  130   CONTINUE

        CALL JEVEUO(COOVAV,'L',JVALE)
        CALL WKVECT(COOVAL,'G V R8',3*NBNOT,KVALE)
        DO 140 I=0,3*NBNOEV-1
          ZR(KVALE+I)=ZR(JVALE+I)
  140   CONTINUE
        CALL JELIRA(COOVAV,'DOCU',IBID,CDIM)
        CALL JEECRA(COOVAL,'DOCU',IBID,CDIM)
      ELSE
        CALL JEDUPO(NOMNOV,'G',NOMNOE,LOGIC)
        CALL JEDUPO(COOVAV,'G',COOVAL,LOGIC)
      ENDIF

C --- CAS OU L'ON FOURNIT UNE TABLE.
C --- IL S'AGIT DE DEFINIR LES COORDONNEES DES NOEUDS DU MAILLAGE
C --- EN SORTIE DANS UN NOUVEAU REPERE.
C --- CETTE FONCTIONNALITE SERT DANS LE CAS OU L'ON CALCULE LES
C --- CARACTERISTIQUES DE CISAILLEMENT D'UNE POUTRE A PARTIR DE LA
C --- DONNEE D'UNE SECTION DE CETTE POUTRE MAILLEE AVEC DES ELEMENTS
C --- MASSIFS 2D.
C --- LA TABLE OBTENUE PAR POST_ELEM (OPTION : CARA_GEOM)  CONTIENT
C --- LES COORDONNEES DE LA NOUVELLE ORIGINE  (I.E. LE CENTRE DE
C --- GRAVITE) ET L'ANGLE FORME PAR LES AXES PRINCIPAUX D'INERTIE
C --- (LES NOUVEAUX AXES) AVEC LES AXES GLOBAUX :
C --- ON DEFINIT LE MAILLAGE EN SORTIE DANS CE NOUVEAU REPERE
C --- POUR LE CALCUL DU CENTRE DE CISAILLEMENT TORSION ET DES
C --- COEFFICIENTS DE CISAILLEMENT.
C --- DANS LE CAS OU L'ON DONNE LE MOT-CLE ORIG_TORSION
C --- LA TABLE CONTIENT LES COORDONNEES DU CENTRE DE CISAILLEMENT-
C --- TORSION ET ON DEFINIT LE NOUVEAU MAILLAGE EN PRENANT COMME
C --- ORIGINE CE POINT. CETTE OPTION EST UTILISEE POUR LE CALCUL
C --- DE L'INERTIE DE GAUCHISSEMENT :
C     -----------------------------
      CALL GETFAC('REPERE',NREP)
      IF (NREP.NE.0) THEN
        IF (NN1.EQ.0) THEN
          CALL U2MESS('F','ALGELINE3_4')
        ENDIF
        CALL GETVID('REPERE','TABLE',1,1,0,K8B,NTAB)
        IF (NTAB.NE.0) THEN
          CALL GETVID('REPERE','TABLE',1,1,1,TABLE,NTAB)
          CALL GETVTX('REPERE','NOM_ORIG',1,1,0,K8B,NORI)
          IF (NORI.NE.0) THEN
            CALL GETVTX('REPERE','NOM_ORIG',1,1,1,NOMORI,NORI)
            IF (NOMORI.EQ.'CDG') THEN
              CALL CHCOMA(TABLE,NOMAOU)
            ELSEIF (NOMORI.EQ.'TORSION') THEN
              CALL CHCOMB(TABLE,NOMAOU)
            ELSE
              CALL U2MESS('F','ALGELINE3_5')
            ENDIF
          ENDIF
        ENDIF
      ENDIF

C ----------------------------------------------------------------------
C         ON AGRANDIT LE '.NOMMAI' ET LE '.CONNEX'
C ----------------------------------------------------------------------

C     NBNOMX = NBRE DE NOEUDS MAX. POUR UNE MAILLE :
      CALL DISMOI('F','NB_NO_MAX','&CATA','CATALOGUE',NBNOMX,K1B,IERD)

      NBMAIN=NBMAIV+NBMAJ1+NBMAJ2+NBMAJ3

      ZI(JDIME+3-1)=NBMAIN
      CALL JECREO(NOMMAI,'G N K8')
      CALL JEECRA(NOMMAI,'NOMMAX',NBMAIN,' ')

      CALL WKVECT(TYPMAI,'G V I',NBMAIN,IATYMA)

      CALL JECREC(CONNEX,'G V I','NU','CONTIG','VARIABLE',NBMAIN)
      CALL JEECRA(CONNEX,'LONT',NBNOMX*NBMAIN,' ')


      DO 180 IMA=1,NBMAIV
        CALL JENUNO(JEXNUM(NOMMAV,IMA),NOMG)
        CALL JEEXIN(JEXNOM(NOMMAI,NOMG),IRET)
        IF (IRET.EQ.0) THEN
          CALL JECROC(JEXNOM(NOMMAI,NOMG))
        ELSE
          VALK(1)=NOMG
          CALL U2MESG('F','ALGELINE4_7',1,VALK,0,0,0,0.D0)
        ENDIF

        CALL JENONU(JEXNOM(NOMMAV,NOMG),IBID)
        JTOM=JTYPMV-1+IBID
        CALL JENONU(JEXNOM(NOMMAI,NOMG),IBID)
        ZI(IATYMA-1+IBID)=ZI(JTOM)

        CALL JENONU(JEXNOM(NOMMAV,NOMG),IBID)
        CALL JELIRA(JEXNUM(CONNEV,IBID),'LONMAX',NBPT,K1B)
        CALL JEVEUO(JEXNUM(CONNEV,IBID),'L',JOPT)
        NBPTT=NBPT
        DO 150 IN=1,NBNOAJ
          IF (IMA.EQ.ZI(JMOMTU+IN-1)) THEN
            NBPTT=NBPT+1
            GOTO 160

          ENDIF
  150   CONTINUE
  160   CONTINUE
        CALL JENONU(JEXNOM(NOMMAI,NOMG),IBID)
        CALL JEECRA(JEXNUM(CONNEX,IBID),'LONMAX',NBPTT,K8B)
        CALL JEVEUO(JEXNUM(CONNEX,IBID),'E',JNPT)
        DO 170 INO=0,NBPT-1
          ZI(JNPT+INO)=ZI(JOPT+INO)
  170   CONTINUE
  180 CONTINUE

      DO 200 IMA=1,NBMAJ1
        NEWMAI=ZK8(JCRMNO+IMA-1)
        INUMOL=ZI(JCRMNU+IMA-1)
        CALL JEEXIN(JEXNOM(NOMMAI,NEWMAI),IRET)
        IF (IRET.EQ.0) THEN
          CALL JECROC(JEXNOM(NOMMAI,NEWMAI))
        ELSE
          VALK(1)=NEWMAI
          CALL U2MESG('F','ALGELINE4_7',1,VALK,0,0,0,0.D0)
        ENDIF

        JTOM=JTYPMV-1+INUMOL
        CALL JENONU(JEXNOM(NOMMAI,NEWMAI),IBID)
        IF (IBID.EQ.0) THEN
          CALL U2MESK('F','ALGELINE3_6',1,NEWMAI)
        ENDIF
        ZI(IATYMA-1+IBID)=ZI(JTOM)

        CALL JELIRA(JEXNUM(CONNEV,INUMOL),'LONMAX',NBPT,K1B)
        CALL JEVEUO(JEXNUM(CONNEV,INUMOL),'L',JOPT)
        CALL JEECRA(JEXNUM(CONNEX,IBID),'LONMAX',NBPT,K8B)
        CALL JEVEUO(JEXNUM(CONNEX,IBID),'E',JNPT)
        DO 190 INO=0,NBPT-1
          ZI(JNPT+INO)=ZI(JOPT+INO)
  190   CONTINUE
  200 CONTINUE

      DO 220 IMA=1,NBMAJ2
        NEWMAI=ZK8(JCRGNO+IMA-1)
        INUMOL=ZI(JCRGNU+IMA-1)
        CALL JEEXIN(JEXNOM(NOMMAI,NEWMAI),IRET)
        IF (IRET.EQ.0) THEN
          CALL JECROC(JEXNOM(NOMMAI,NEWMAI))
        ELSE
          VALK(1)=NEWMAI
          CALL U2MESG('F','ALGELINE4_7',1,VALK,0,0,0,0.D0)
        ENDIF

        JTOM=JTYPMV-1+INUMOL
        CALL JENONU(JEXNOM(NOMMAI,NEWMAI),IBID)
        IF (IBID.EQ.0) THEN
          CALL U2MESK('F','ALGELINE3_6',1,NEWMAI)
        ENDIF
        ZI(IATYMA-1+IBID)=ZI(JTOM)

        CALL JELIRA(JEXNUM(CONNEV,INUMOL),'LONMAX',NBPT,K1B)
        CALL JEVEUO(JEXNUM(CONNEV,INUMOL),'L',JOPT)
        CALL JEECRA(JEXNUM(CONNEX,IBID),'LONMAX',NBPT,K8B)
        CALL JEVEUO(JEXNUM(CONNEX,IBID),'E',JNPT)
        DO 210 INO=0,NBPT-1
          ZI(JNPT+INO)=ZI(JOPT+INO)
  210   CONTINUE
  220 CONTINUE

      DO 230 IMA=1,NBMAJ3
        NEWMAI=ZK8(JNONO+IMA-1)
        CALL JENONU(JEXNOM(NOMMAI,NEWMAI),IBID)
        IF (IBID.NE.0)GOTO 230
        CALL JEEXIN(JEXNOM(NOMMAI,NEWMAI),IRET)
        IF (IRET.EQ.0) THEN
          CALL JECROC(JEXNOM(NOMMAI,NEWMAI))
        ELSE
          VALK(1)=NEWMAI
          CALL U2MESG('F','ALGELINE4_7',1,VALK,0,0,0,0.D0)
        ENDIF

        CALL JENONU(JEXNOM(NOMMAI,NEWMAI),IBID)
        IF (IBID.EQ.0) THEN
          CALL U2MESK('F','ALGELINE3_6',1,NEWMAI)
        ENDIF
        ZI(IATYMA-1+IBID)=NTPOI

        CALL JEECRA(JEXNUM(CONNEX,IBID),'LONMAX',1,K8B)
        CALL JEVEUO(JEXNUM(CONNEX,IBID),'E',JNPT)
        CALL JENONU(JEXNOM(NOMNOE,NEWMAI),ZI(JNPT))
  230 CONTINUE

C ----------------------------------------------------------------------

      CALL JEEXIN(GRPMAV,IRET)
      IF (IRET.EQ.0) THEN
        NBGRMV=0
      ELSE
        CALL JELIRA(GRPMAV,'NOMUTI',NBGRMV,K1B)
      ENDIF
      NBGRMN=NBGRMV+NBGRMA
      IF (NBGRMN.NE.0) THEN
        CALL JECREC(GRPMAI,'G V I','NO','DISPERSE','VARIABLE',NBGRMN)
        DO 250 I=1,NBGRMV
          CALL JENUNO(JEXNUM(GRPMAV,I),NOMG)
          CALL JEEXIN(JEXNOM(GRPMAI,NOMG),IRET)
          IF (IRET.EQ.0) THEN
            CALL JECROC(JEXNOM(GRPMAI,NOMG))
          ELSE
            VALK(1)=NOMG
            CALL U2MESG('F','ALGELINE4_9',1,VALK,0,0,0,0.D0)
          ENDIF
          CALL JEVEUO(JEXNUM(GRPMAV,I),'L',JVG)
          CALL JELIRA(JEXNUM(GRPMAV,I),'LONMAX',NBMA,K1B)
          CALL JEECRA(JEXNOM(GRPMAI,NOMG),'LONMAX',NBMA,' ')
          CALL JEVEUO(JEXNOM(GRPMAI,NOMG),'E',JGG)
          DO 240 J=0,NBMA-1
            ZI(JGG+J)=ZI(JVG+J)
  240     CONTINUE
  250   CONTINUE
        DO 270 I=1,NBGRMA
          CALL GETVID('CREA_GROUP_MA','NOM',I,1,1,NOMG,N1)
          CALL JEEXIN(JEXNOM(GRPMAI,NOMG),IRET)
          IF (IRET.EQ.0) THEN
            CALL JECROC(JEXNOM(GRPMAI,NOMG))
          ELSE
            VALK(1)=NOMG
            CALL U2MESG('F','ALGELINE4_9',1,VALK,0,0,0,0.D0)
          ENDIF
          NBMAJ2=0
          CALL PALIM3('CREA_GROUP_MA',I,NOMAIN,CRGRNU,CRGRNO,NBMAJ2)
          CALL JEVEUO(CRGRNO,'L',JCRGNO)
          CALL JEECRA(JEXNOM(GRPMAI,NOMG),'LONMAX',NBMAJ2,' ')
          CALL JEVEUO(JEXNOM(GRPMAI,NOMG),'E',IAGMA)
          DO 260 IMA=0,NBMAJ2-1
            CALL JENONU(JEXNOM(NOMMAI,ZK8(JCRGNO+IMA)),ZI(IAGMA+IMA))
  260     CONTINUE
  270   CONTINUE
      ENDIF

C ----------------------------------------------------------------------

      CALL JEEXIN(GRPNOV,IRET)
      IF (IRET.EQ.0) THEN
        NBGRNO=0
      ELSE
        CALL JELIRA(GRPNOV,'NOMUTI',NBGRNO,K1B)
        CALL JECREC(GRPNOE,'G V I','NO','DISPERSE','VARIABLE',NBGRNO)
        DO 290 I=1,NBGRNO
          CALL JENUNO(JEXNUM(GRPNOV,I),NOMG)
          CALL JEVEUO(JEXNUM(GRPNOV,I),'L',JVG)
          CALL JELIRA(JEXNUM(GRPNOV,I),'LONMAX',NBNO,K1B)
          CALL JEEXIN(JEXNOM(GRPNOE,NOMG),IRET)
          IF (IRET.EQ.0) THEN
            CALL JECROC(JEXNOM(GRPNOE,NOMG))
          ELSE
            VALK(1)=NOMG
            CALL U2MESG('F','ALGELINE4_11',1,VALK,0,0,0,0.D0)
          ENDIF
          CALL JEECRA(JEXNOM(GRPNOE,NOMG),'LONMAX',NBNO,' ')
          CALL JEVEUO(JEXNOM(GRPNOE,NOMG),'E',JGG)
          DO 280 J=0,NBNO-1
            ZI(JGG+J)=ZI(JVG+J)
  280     CONTINUE
  290   CONTINUE
      ENDIF

      IF (NBMOMA.NE.0) CALL CMMOMA(NOMAOU,MOMUTO,NBNOEV,NBNOAJ)


C ----------------------------------------------------------------------
C         CREATION DES GROUP_MA ASSOCIE AU MOT CLE "CREA_POI1"
C ----------------------------------------------------------------------

      IF (NBCRP1.NE.0) THEN
        NBGRMA=0
        DO 300 IOCC=1,NBCRP1
          CALL GETVID('CREA_POI1','NOM_GROUP_MA',IOCC,1,0,K8B,N1)
          IF (N1.NE.0)NBGRMA=NBGRMA+1
  300   CONTINUE
        IF (NBGRMA.NE.0) THEN
          CALL JEEXIN(GRPMAI,IRET)
          IF (IRET.EQ.0) THEN
            CALL JECREC(GRPMAI,'G V I','NOM','DISPERSE','VARIABLE',
     &                  NBGRMA)
          ELSE
            GRPMAV='&&OP0167.GROUP_MA'
            CALL JELIRA(GRPMAI,'NOMUTI',NBGMA,K8B)
            NBGRMT=NBGMA+NBGRMA
            CALL JEDUPO(GRPMAI,'V',GRPMAV,.FALSE.)
            CALL JEDETR(GRPMAI)
            CALL JECREC(GRPMAI,'G V I','NOM','DISPERSE','VARIABLE',
     &                  NBGRMT)
            DO 320 I=1,NBGMA
              CALL JENUNO(JEXNUM(GRPMAV,I),NOMG)
              CALL JEEXIN(JEXNOM(GRPMAI,NOMG),IRET)
              IF (IRET.EQ.0) THEN
                CALL JECROC(JEXNOM(GRPMAI,NOMG))
              ELSE
                VALK(1)=NOMG
                CALL U2MESG('F','ALGELINE4_9',1,VALK,0,0,0,0.D0)
              ENDIF
              CALL JEVEUO(JEXNUM(GRPMAV,I),'L',JVG)
              CALL JELIRA(JEXNUM(GRPMAV,I),'LONMAX',NBMA,K8B)
              CALL JEECRA(JEXNOM(GRPMAI,NOMG),'LONMAX',NBMA,' ')
              CALL JEVEUO(JEXNOM(GRPMAI,NOMG),'E',JGG)
              DO 310 J=0,NBMA-1
                ZI(JGG+J)=ZI(JVG+J)
  310         CONTINUE
  320       CONTINUE
          ENDIF
          DO 340 IOCC=1,NBCRP1
            CALL GETVID('CREA_POI1','NOM_GROUP_MA',IOCC,1,0,K8B,N1)
            IF (N1.NE.0) THEN
              CALL GETVID('CREA_POI1','NOM_GROUP_MA',IOCC,1,1,NOGMA,N1)
              CALL JENONU(JEXNOM(GRPMAI,NOGMA),IBID)
              IF (IBID.GT.0) CALL U2MESK('F','ALGELINE3_7',1,NOGMA)
              CALL RELIEM(' ',NOMAIN,'NO_NOEUD',MOTFAC,IOCC,NBMC,MOTCLE,
     &                    TYMOCL,NOMJV,NBMA)
              CALL JEVEUO(NOMJV,'L',JMAIL)

              CALL JEEXIN(JEXNOM(GRPMAI,NOGMA),IRET)
              IF (IRET.EQ.0) THEN
                CALL JECROC(JEXNOM(GRPMAI,NOGMA))
              ELSE
                VALK(1)=NOGMA
                CALL U2MESG('F','ALGELINE4_9',1,VALK,0,0,0,0.D0)
              ENDIF
              CALL JEECRA(JEXNOM(GRPMAI,NOGMA),'LONMAX',NBMA,K8B)
              CALL JEVEUO(JEXNOM(GRPMAI,NOGMA),'E',IAGMA)
              DO 330,IMA=0,NBMA-1
                CALL JENONU(JEXNOM(NOMMAI,ZK8(JMAIL+IMA)),ZI(IAGMA+IMA))
  330         CONTINUE
              IF (NIV.GE.1) THEN
                WRITE (IFM,9020)IOCC
                WRITE (IFM,9030)NOGMA,NBMA
              ENDIF
            ENDIF
  340     CONTINUE
        ENDIF
      ENDIF
C ----------------------------------------------------------------------
C              TRAITEMENT DU MOT CLE DETR_GROUP_MA
C ----------------------------------------------------------------------

      CALL GETFAC('DETR_GROUP_MA',NBDGMA)
      IF (NBDGMA.EQ.1) THEN
        IF (NN1.EQ.0) THEN
          CALL U2MESS('F','ALGELINE3_8')
        ENDIF
        CALL CMDGMA(NOMAOU)
      ENDIF
  350 CONTINUE

      CALL TITRE()

      CALL CARGEO(NOMAOU)

C     IMPRESSIONS DU MOT CLE INFO :
C     -----------------------------
      CALL INFOMA(NOMAOU)


      CALL JEDEMA()

 9000 FORMAT ('MOT CLE FACTEUR "MODI_MAILLE", OCCURRENCE ',I4)
 9010 FORMAT ('  MODIFICATION DE ',I6,' MAILLES ',A8,' EN ',A8)
 9020 FORMAT ('MOT CLE FACTEUR "CREA_POI1", OCCURRENCE ',I4)
 9030 FORMAT ('  CREATION DU GROUP_MA ',A8,' DE ',I6,' MAILLES POI1')
 9040 FORMAT ('MOT CLE FACTEUR "CREA_MAILLE", OCCURRENCE ',I4)
 9050 FORMAT ('  CREATION DE ',I6,' MAILLES')
      END
