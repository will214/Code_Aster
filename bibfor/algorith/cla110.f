      SUBROUTINE CLA110(NOMRES,MODGEN)
      IMPLICIT REAL*8 (A-H,O-Z)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 06/07/2009   AUTEUR COURTOIS M.COURTOIS 
C TOLE CRP_20
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
C***********************************************************************
C  P. RICHARD     DATE 22/04/91
C-----------------------------------------------------------------------
C  BUT : < MAILLAGE SQUELETTE SOUS-STRUCTURATION CLASSIQUE >
C
C  CREER LE MAILLAGE SQUELETTE CORRESPONDANT A UN MODELE GENERALISE
C
C-----------------------------------------------------------------------
C
C NOMRES  /I/ : NOM K8 DU MAILLAGE A CREER
C MODGEN  /I/ : NOM K8 DU MODELE GENERALISE
C
C-------- DEBUT COMMUNS NORMALISES  JEVEUX  ----------------------------
C
      INTEGER          ZI
      COMMON  /IVARJE/ ZI(1)
      REAL*8           ZR
      COMMON  /RVARJE/ ZR(1)
      COMPLEX*16       ZC
      COMMON  /CVARJE/ ZC(1)
      LOGICAL          ZL
      COMMON  /LVARJE/ ZL(1)
      CHARACTER*8      ZK8
      CHARACTER*16              ZK16
      CHARACTER*24                        ZK24
      CHARACTER*32                                  ZK32
      CHARACTER*80                                            ZK80
      COMMON  /KVARJE/ ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C
      CHARACTER*32 JEXNOM,JEXNUM
C
C----------  FIN  COMMUNS NORMALISES  JEVEUX  --------------------------
C
C   PARAMETER : REPRESENTE LE NOMBRE MAX DE COMPOSANTES DE LA GRANDEUR
C   SOUS-JACENTE TRAITEE
C
      PARAMETER   (NBCMPM=10)
      CHARACTER*8  NOMRES,MODGEN,TT,NOMSST,MAILLA,NOMCOU
      CHARACTER*16 CSS,CMA,CGR,MAICON,NOMCON
      REAL*8       XANC(3)
      CHARACTER*24 REPNOM,MODROT,MODTRA
      CHARACTER*24 VALK(2)
      REAL*8       MATROT(NBCMPM,NBCMPM)
      REAL*8       MATBUF(NBCMPM,NBCMPM),MATTMP(NBCMPM,NBCMPM)
      CHARACTER*8  K8BID,NOMGR,EXCLU
C
C-----------------------------------------------------------------------
      DATA TT      /'&&CLA110'/
      DATA CSS,CMA,CGR /'SOUS_STRUC','MAILLE','GROUP_MA'/
C-----------------------------------------------------------------------
C
      CALL JEMARQ()
      REPNOM=MODGEN//'      .MODG.SSNO'
      CALL JELIRA(REPNOM,'NOMMAX',NBSST,K8BID)
C
C-----PRISE EN COMPTE DE LA PRESENCE DES SST DANS LE SQUELETTE----------
C
      CALL WKVECT(TT//'.ACTIF','V V I',NBSST,LTFAC)
      CALL GETFAC(CSS,IOC)
C
      DO 20 I=1,IOC
        CALL GETVTX(CSS,'NOM',I,1,1,NOMSST,IBID)
        CALL JENONU(JEXNOM(REPNOM,NOMSST),NUSST)
        IF (NUSST.EQ.0) THEN
               VALK (1) = NOMSST
          CALL U2MESG('A', 'ALGORITH12_49',1,VALK,0,0,0,0.D0)
        ELSE
          ZI(LTFAC+NUSST-1)=1
        ENDIF
20    CONTINUE
C
      NBSTAC=0
      DO 30 I=1,NBSST
        NBSTAC=NBSTAC+ZI(LTFAC+I-1)
30    CONTINUE
C
      IF(NBSTAC.EQ.0) THEN
        CALL U2MESG('F', 'ALGORITH12_50',0,' ',0,0,0,0.D0)
      ENDIF
C
C-----DEFINITION DES REPERTOIRES DE TRAVAIL-----------------------------
      CALL WKVECT(TT//'.DESC','V V I',NBSST,LTDESC)
      CALL WKVECT(TT//'.NB.MA','V V I',NBSTAC,LTNBMA)
      CALL WKVECT(TT//'.NB.GR','V V I',NBSTAC,LTNBGR)
      DO 80 I =1,NBSTAC
         ZI(LTNBMA-1+I) = 0
         ZI(LTNBGR-1+I) = 0
 80   CONTINUE
      CALL JECREO(TT//'.NOM.SST','V N K8')
      CALL JEECRA(TT//'.NOM.SST','NOMMAX',NBSTAC,' ')
      CALL JECREC(TT//'.LISTE.MA','V V I','NU',
     +                                    'DISPERSE','VARIABLE',NBSTAC)
      CALL JECREC(TT//'.LISTE.NO','V V I','NU',
     +                                    'DISPERSE','VARIABLE',NBSTAC)
C
C --- RECHERCHE DES NOMS DE GROUPES DE MAILLES UTILISATEUR ---
      CALL GETVTX(' ','EXCLUSIF',0,1,1,EXCLU,IBID)
      CALL GETFAC('NOM_GROUP_MA',NBGRUT)
      IF (NBGRUT .GT. 0) THEN
         CALL WKVECT(TT//'.UT.NOM','V V K8',NBGRUT,LUTNOM)
         CALL WKVECT(TT//'.UT.SST','V V K8',NBGRUT,LUTSST)
         CALL WKVECT(TT//'.UT.GMA','V V K8',NBGRUT,LUTGMA)
         DO 100 I = 1,NBGRUT
            CALL GETVTX('NOM_GROUP_MA','NOM',I,1,1,
     +                   ZK8(LUTNOM-1+I),IBID)
            CALL GETVTX('NOM_GROUP_MA','SOUS_STRUC',I,1,1,
     +                   ZK8(LUTSST-1+I),IBID)
            CALL GETVEM(MAILLA,'GROUP_MA','NOM_GROUP_MA','GROUP_MA',
     +                     I,1,1,ZK8(LUTGMA-1+I),IBID)
C           --- RECHERCHE SI LA SOUS-STRUCTURE EXISTE ---
            IS = 0
 90         CONTINUE
            IS = IS+1
            IF (IS.LE.NBSST) THEN
               IF (ZI(LTFAC-1+IS).NE.0) THEN
                 CALL JENUNO(JEXNUM(REPNOM,IS),NOMSST)
                 IF (NOMSST.NE.ZK8(LUTSST-1+I)) GOTO 90
               ELSE
                 GOTO 90
               ENDIF
            ELSE
               VALK (1) = ZK8(LUTSST-1+I)
               VALK (2) = K8BID
               CALL U2MESG('F', 'ALGORITH12_51',2,VALK,0,0,0,0.D0)
            ENDIF
 100     CONTINUE
      ENDIF
C
C  ECRITURE DES NOMS DES SST ACTIVES
      ICOMP=0
      DO 200 I=1,NBSST
        IF (ZI(LTFAC-1+I).NE.0) THEN
          CALL JENUNO(JEXNUM(REPNOM,I),NOMSST)
          CALL JECROC(JEXNOM(TT//'.NOM.SST',NOMSST))
          ICOMP=ICOMP+1
          ZI(LTDESC-1+I)=ICOMP
        ELSE
          ZI(LTDESC-1+I)=0
        ENDIF
200   CONTINUE
C
C-----DETERMINATION DES DIMENSIONS MAX DES LISTES UTILISATEUR-----------
      MAXMA=0
      MAXGR=0
C
      DO 210 I=1,IOC
        CALL GETVTX(CSS,CMA,I,1,0,K8BID,NBVMA)
        MAXMA=MAX(MAXMA,-NBVMA)
        CALL GETVTX(CSS,CGR,I,1,0,K8BID,NBVGR)
        MAXGR=MAX(MAXGR,-NBVGR)
210   CONTINUE
C
C-----ALLOCATION VECTEUR DE TRAVAIL-------------------------------------
C
      IF(MAXMA.NE.0) THEN
        CALL WKVECT(TT//'.NOM.MA','V V K8',MAXMA,LTNOMA)
      ENDIF
      IF(MAXGR.NE.0) THEN
        CALL WKVECT(TT//'.NOM.GR','V V K8',MAXGR,LTNOGR)
      ENDIF
      CALL WKVECT(TT//'.MAILLAGE','V V K8',NBSTAC,LTMAIL)
C
C-----DETERMINATION DU NOMBRE DE MAILLES POUR CHAQUE SST ACTIVE---------
C
      NGRMAT = 0
      DO 220 I=1,IOC
        CALL GETVTX(CSS,'NOM',I,1,1,NOMSST,IBID)
        CALL JENONU(JEXNOM(REPNOM,NOMSST),NUSST)
        NUACT=ZI(LTDESC-1+NUSST)
        CALL GETVTX(CSS,CMA,I,1,0,K8BID,NBMA)
        NBMA=-NBMA
        CALL GETVTX(CSS,CGR,I,1,0,K8BID,NBGR)
        NBGR=-NBGR
        CALL GETVTX(CSS,'TOUT',I,1,0,K8BID,NBTOUT)
        NBTOUT=-NBTOUT
        CALL MGUTDM(MODGEN,NOMSST,IBID,'NOM_MAILLAGE',IBID,MAILLA)
        ZK8(LTMAIL+NUACT-1)=MAILLA
        NGRMA = 0
        IF(NBTOUT.EQ.0) THEN
          CALL GETVTX(CSS,CGR,I,1,NBGR,ZK8(LTNOGR),IBID)
          CALL COMPMA(MAILLA,NBGR,ZK8(LTNOGR),NBUF)
          NBMA=NBMA+NBUF
        ELSE
          CALL DISMOI('F','NB_MA_MAILLA',MAILLA,'MAILLAGE',NBMA,
     +                                               K8BID,IRET)
          CALL JEEXIN(MAILLA//'.GROUPEMA',IRET)
          IF (IRET .NE.0) THEN
             CALL JELIRA(MAILLA//'.GROUPEMA','NUTIOC',NGRMA,K8BID)
             CALL WKVECT(TT//'.GR.'//NOMSST,'V V K8',NGRMA,IGRMA)
          ENDIF
          DO 215 IGR = 1,NGRMA
             CALL JENUNO(JEXNUM(MAILLA//'.GROUPEMA',IGR),NOMGR)
             ZK8(IGRMA-1+IGR) = NOMGR
 215      CONTINUE
        ENDIF
        ZI(LTNBMA+NUACT-1)=ZI(LTNBMA+NUACT-1)+NBMA
        ZI(LTNBGR+NUACT-1)=ZI(LTNBGR+NUACT-1)+NGRMA
        NGRMAT = NGRMAT + NGRMA
220   CONTINUE
C
C-----ECRITURE ATTRIBUT LONGUEUR----------------------------------------
C
      DO 230 I=1,NBSTAC
        NTAIL=ZI(LTNBMA+I-1)
        CALL JEECRA(JEXNUM(TT//'.LISTE.MA',I),'LONMAX',NTAIL,' ')
        ZI(LTNBMA+I-1)=0
230   CONTINUE
C
C-----DETERMINATION DES LISTES DES MAILLES PAR SST ACTIVE---------------
C
      DO 240 I=1,IOC
        CALL GETVTX(CSS,'NOM',I,1,1,NOMSST,IBID)
        CALL JENONU(JEXNOM(REPNOM,NOMSST),NUSST)
        NUACT=ZI(LTDESC-1+NUSST)
        CALL GETVTX(CSS,'TOUT',I,1,0,K8BID,NBTOUT)
        NBTOUT=-NBTOUT
        MAILLA=ZK8(LTMAIL+NUACT-1)
        CALL JEVEUO(JEXNUM(TT//'.LISTE.MA',NUACT),'E',LTLIMA)
        IF(NBTOUT.GT.0) THEN
          CALL DISMOI('F','NB_MA_MAILLA',MAILLA,'MAILLAGE',NBMA,
     +                                             K8BID,IRET)
          IAD=LTLIMA+ZI(LTNBMA+NUACT-1)
          DO 250 J=1,NBMA
            ZI(IAD+J-1)=J
250       CONTINUE
          ZI(LTNBMA+NUACT-1)=ZI(LTNBMA+NUACT-1)+NBMA
        ELSE
          CALL GETVTX(CSS,CMA,I,1,0,K8BID,NBMA)
          NBMA=-NBMA
          CALL GETVTX(CSS,CGR,I,1,0,K8BID,NBGR)
          NBGR=-NBGR
          CALL GETVTX(CSS,CMA,I,1,NBMA,ZK8(LTNOMA),IBID)
          CALL GETVTX(CSS,CGR,I,1,NBGR,ZK8(LTNOGR),IBID)
          IAD=LTLIMA+ZI(LTNBMA+NUACT-1)
          CALL RECUMA(MAILLA,NBMA,NBGR,ZK8(LTNOMA),ZK8(LTNOGR),
     +                                                NBSKMA,ZI(IAD))
          ZI(LTNBMA+NUACT-1)=ZI(LTNBMA+NUACT-1)+NBSKMA
        ENDIF
C
        CALL JELIBE(JEXNUM(TT//'.LISTE.MA',NUACT))
240   CONTINUE
      IF(MAXMA.NE.0) THEN
        CALL JEDETR(TT//'.NOM.MA')
      ENDIF
      IF(MAXGR.NE.0) THEN
        CALL JEDETR(TT//'.NOM.GR')
      ENDIF
C
C-----TRI DES MAILLES ET COMPTAGE DES NOEUDS----------------------------
C
      CALL WKVECT(TT//'.NB.NO','V V I',NBSTAC,LTNBNO)
C
      DO 260 I=1,NBSTAC
        CALL JEVEUO(JEXNUM(TT//'.LISTE.MA',I),'L',LTLIMA)
        NBTEMP=ZI(LTNBMA+I-1)
        NBSKMA = NBTEMP
        IF (NBSKMA.NE.0) CALL UTTRII(ZI(LTLIMA),NBSKMA)
        ZI(LTNBMA+I-1)=NBSKMA
        MAILLA=ZK8(LTMAIL+I-1)
        MAICON = MAILLA//'.CONNEX'
        ICOMP=0
        DO 270 J=1,NBSKMA
          NUMMA=ZI(LTLIMA+J-1)
          CALL JELIRA(JEXNUM(MAICON,NUMMA),'LONMAX',NBNO,K8BID)
          ICOMP=ICOMP+NBNO
270     CONTINUE
        ZI(LTNBNO+I-1)=ICOMP
260   CONTINUE
C
C-----ECRITURE ATTRIBUT DIMENSION DES NOEUDS----------------------------
C
      DO 300 I=1,NBSTAC
        NTAIL=ZI(LTNBNO+I-1)
        CALL JEECRA(JEXNUM(TT//'.LISTE.NO',I),'LONMAX',NTAIL,' ')
300   CONTINUE
C
C-----RECUPERATION DES NOEUDS-------------------------------------------
C
      NBNOT=0
      NBMAT=0
      NCTAIL=0
C
      DO 310 I=1,NBSTAC
        MAILLA=ZK8(LTMAIL+I-1)
        MAICON = MAILLA//'.CONNEX'
        CALL JEVEUO(JEXNUM(TT//'.LISTE.MA',I),'L',LTLIMA)
        CALL JEVEUO(JEXNUM(TT//'.LISTE.NO',I),'E',LTLINO)
        NBMA=ZI(LTNBMA+I-1)
        ICOMP=0
        DO 320 J=1,NBMA
          NUMMA=ZI(LTLIMA-1+J)
          CALL JELIRA(JEXNUM(MAICON,NUMMA),'LONMAX',NBTMP,K8BID)
          CALL JEVEUO(JEXNUM(MAICON,NUMMA),'L',LLMA)
          NCTAIL=NCTAIL+NBTMP
          DO 330 K=1,NBTMP
            ICOMP=ICOMP+1
            ZI(LTLINO+ICOMP-1)=ZI(LLMA+K-1)
330       CONTINUE
320     CONTINUE
        CALL JELIBE(MAICON)
        CALL JELIBE(JEXNUM(TT//'.LISTE.MA',I))
        NBTMP=ICOMP
        NBNO = NBTMP
        IF (NBNO.NE.0) CALL UTTRII(ZI(LTLINO),NBNO)
        CALL JELIBE(JEXNUM(TT//'.LISTE.NO',I))
        ZI(LTNBNO+I-1)=NBNO
        NBNOT=NBNOT+NBNO
        NBMAT=NBMAT+NBMA
310   CONTINUE
C
C-----TRAITEMENT DES ORIENTATIONS ET DES TRANSLATIONS DES SST-----------
C
      CALL WKVECT(TT//'.ROTATION','V V R',NBSTAC*3,LTROT)
      CALL WKVECT(TT//'.TRANSLATION','V V R',NBSTAC*3,LTTRA)
      MODROT=MODGEN//'      .MODG.SSOR'
      MODTRA=MODGEN//'      .MODG.SSTR'
      DO 500 I=1,NBSST
        ICOMP=ZI(LTDESC-1+I)
        IF (ICOMP.NE.0) THEN
          CALL JENUNO(JEXNUM(REPNOM,I),NOMSST)
          CALL JENONU(JEXNOM(MODROT(1:19)//'.SSNO',NOMSST),IBID)
          CALL JEVEUO(JEXNUM(MODROT,IBID),'L',LLROT)
          DO 510 K=1,3
            ZR(LTROT+3*(ICOMP-1)+K-1)=ZR(LLROT+K-1)
510       CONTINUE
        ENDIF
500   CONTINUE
      DO 600 I=1,NBSST
        ICOMP=ZI(LTDESC-1+I)
        IF (ICOMP.NE.0) THEN
          CALL JENUNO(JEXNUM(REPNOM,I),NOMSST)
          CALL JENONU(JEXNOM(MODTRA(1:19)//'.SSNO',NOMSST),IBID)
          CALL JEVEUO(JEXNUM(MODTRA,IBID),'L',LLTRA)
          DO 610 K=1,3
            ZR(LTTRA+3*(ICOMP-1)+K-1)=ZR(LLTRA+K-1)
610       CONTINUE
        ENDIF
600   CONTINUE
C
C-----ALLOCATION DES OBJETS MAILLAGE RESULTAT---------------------------
C
      NOMCON=NOMRES//'.CONNEX'
      CALL WKVECT(NOMRES//'.DIME','G V I',6,LDDIME)
      CALL WKVECT(NOMRES//'           .TITR','G V K80',1,LDTITR)
      CALL WKVECT(NOMRES//'         .NOMSST','G V K8',NBSTAC,LSTAC)
C
      CALL JECREO(NOMRES//'.NOMMAI','G N K8')
      CALL JEECRA(NOMRES//'.NOMMAI','NOMMAX',NBMAT,' ')
      CALL JECREC(NOMCON,'G V I','NU',
     +                         'CONTIG','VARIABLE',NBMAT)
      CALL JEECRA(NOMCON,'LONT',NCTAIL,K8BID)
      CALL WKVECT(NOMRES//'.TYPMAIL','G V I',NBMAT,IBID)
C
      CALL JECREO(NOMRES//'.NOMNOE','G N K8')
      CALL JEECRA(NOMRES//'.NOMNOE','NOMMAX',NBNOT,' ')
C
      CALL JECREC(NOMRES//'.GROUPEMA','G V I','NO',
     +                         'DISPERSE','VARIABLE',NBSTAC+NGRMAT)
C
      CALL WKVECT(NOMRES//'.COORDO    .REFE','G V K24',2,LDREF)
      ZK24(LDREF) = NOMRES
      CALL WKVECT(NOMRES//'.COORDO    .DESC','G V I',3,LDDES)
      CALL JEECRA(NOMRES//'.COORDO    .DESC','DOCU',IBID,'CHNO')
      CALL WKVECT(NOMRES//'.COORDO    .VALE','G V R',3*NBNOT,LDCOO)
C
C-----REMPLISSAGE DU TITRE----------------------------------------------
      ZK80(LDTITR)='MAILLAGE SQUELETTE SOUS-STRUCTURATION CLASSIQUE'
C
C-----REMPLISSAGE DU DIME ET DU DESC------------------------------------
C
      CALL DISMOI('F','NUM_GD','GEOM_R','GRANDEUR',IGD,K8BID,IRET)
      ZI(LDDES)=IGD
      ZI(LDDES+1)=-3
      ZI(LDDES+2)=14
      ZI(LDDIME)=NBNOT
      ZI(LDDIME+1)=0
      ZI(LDDIME+2)=NBMAT
      ZI(LDDIME+3)=0
      ZI(LDDIME+4)=0
      ZI(LDDIME+5)=3
C
C-----ALLOCATION DU INV.SQUELETTE---------------------------------------
      CALL WKVECT(NOMRES//'.INV.SKELETON','G V I',NBNOT*2,LDSKIN)
C
C-----LET'S GET CRAZY !!!-----------------------------------------------
C
      NBTMMA=0
      NBTMNO=0
      NBTGRM=0
      NBINCR=0
      ITCON=0
      CALL JEVEUO(NOMRES//'.TYPMAIL','E',LDTYP)
      CALL JEVEUO(NOMCON,'E',LDCONE)
C
      DO 400 I=1,NBSTAC
        MAILLA=ZK8(LTMAIL+I-1)
        MAICON = MAILLA//'.CONNEX'
        CALL JEVEUO(MAILLA//'.COORDO    .VALE','L',LLCOO)
        CALL JENUNO(JEXNUM(TT//'.NOM.SST',I),NOMSST)
        ZK8(LSTAC-1+I) = NOMSST
C
        CALL INTET0(ZR(LTROT+(I-1)*3),MATTMP,3)
        CALL INTET0(ZR(LTROT+(I-1)*3+1),MATROT,2)
        CALL R8INIR(NBCMPM*NBCMPM,0.D0,MATBUF,1)
        CALL PMPPR(MATTMP,NBCMPM,NBCMPM,1,MATROT,NBCMPM,NBCMPM,1,
     +                                    MATBUF,NBCMPM,NBCMPM)
        CALL R8INIR(NBCMPM*NBCMPM,0.D0,MATROT,1)
        CALL INTET0(ZR(LTROT+(I-1)*3+2),MATTMP,1)
        CALL PMPPR(MATBUF,NBCMPM,NBCMPM,1,MATTMP,NBCMPM,NBCMPM,1,
     +                                    MATROT,NBCMPM,NBCMPM)
C
        NBNO=ZI(LTNBNO+I-1)
        CALL JEVEUO(JEXNUM(TT//'.LISTE.NO',I),'L',LTLINO)
C
C  BOUCLE SUR LES NOEUDS GENERIQUES DE LA SST COURANTE
        CALL WKVECT(TT//'.INV.MAILLA','V V I',NBNOT,LTINV)
        DO 410 J=1,NBNO
          NUMNO=ZI(LTLINO+J-1)
          NBTMNO=NBTMNO+1
          ZI(LTINV-1+NBTMNO)=NUMNO
          NOMCOU='NO'
          CALL NOMCOD(NOMCOU,NBTMNO,3,8)
C
          CALL JECROC(JEXNOM(NOMRES//'.NOMNOE',NOMCOU))
          DO 411 K=1,NBSST
            IF (ZI(LTDESC-1+K).EQ.I) ZI(LDSKIN+NBTMNO-1)=K
411       CONTINUE
          ZI(LDSKIN+NBNOT+NBTMNO-1)=NUMNO
          DO 420 K=1,3
            XANC(K)=ZR(LLCOO+(NUMNO-1)*3+K-1)
420       CONTINUE
          DO 430 K=1,3
            XNEW=0.D0
            DO 440 L=1,3
              XNEW=XNEW+MATROT(K,L)*XANC(L)
440         CONTINUE
            ZR(LDCOO+(NBTMNO-1)*3+K-1)=XNEW+ZR(LTTRA+(I-1)*3+K-1)
430       CONTINUE
410     CONTINUE
        CALL JELIBE(MAILLA//'.COORDO    .VALE')
        CALL JEVEUO(JEXNUM(TT//'.LISTE.NO',I),'L',LTLINO)
C
C  BOUCLE SUR LES ELEMENTS GENERIQUES DE LA SST COURANTE
        NBMA=ZI(LTNBMA+I-1)
        CALL JEVEUO(JEXNUM(TT//'.LISTE.MA',I),'L',LTLIMA)
        CALL JECROC(JEXNOM(NOMRES//'.GROUPEMA',NOMSST))
        CALL JEECRA(JEXNOM(NOMRES//'.GROUPEMA',NOMSST),'LONMAX',NBMA,
     +                  K8BID)
        CALL JEVEUO(JEXNOM(NOMRES//'.GROUPEMA',NOMSST),'E',LDGRMA)
        NBTGRM = NBTGRM+1
        DO 450 J=1,NBMA
          NUMMA=ZI(LTLIMA+J-1)
          NBTMMA=NBTMMA+1
          NOMCOU='MA'
          CALL NOMCOD(NOMCOU,NBTMMA,3,8)
          ZI(LDGRMA+J-1)=NBTMMA
          CALL JECROC(JEXNOM(NOMRES//'.NOMMAI',NOMCOU))
          CALL JELIRA(JEXNUM(MAICON,NUMMA),'LONMAX',NBCON,K8BID)
          CALL JEECRA(JEXNUM(NOMCON,NBTMMA),'LONMAX',NBCON,K8BID)
          CALL JEVEUO(JEXNUM(MAICON,NUMMA),'L',LLCONA)
          DO 460 K=1,NBCON
            ITCON=ITCON+1
            NUNEW=0
            DO 461 L=1,NBNOT
              IF(ZI(LTINV-1+L).EQ.ZI(LLCONA+K-1)) NUNEW=L
461         CONTINUE
            ZI(LDCONE+ITCON-1)=NUNEW
460       CONTINUE
          CALL JEVEUO(MAILLA//'.TYPMAIL','L',IATYMA)
          LLTYP=IATYMA-1+NUMMA
          ZI(LDTYP+NBTMMA-1)=ZI(LLTYP)
450     CONTINUE
C
        NBGR = ZI(LTNBGR-1+I)
        IF (NBGR.GT.0) THEN
C       --- TRAITEMENT DES GROUPES DE MAILLES
           CALL JEVEUO(TT//'.GR.'//NOMSST,'L',ILSTGR)
           CALL GMA110(NBGR,EXCLU,NBGRUT,MAILLA,NOMSST,NBTGRM,NOMRES,
     +          NBINCR, ZK8(ILSTGR),ZK8(LUTSST),ZK8(LUTGMA),ZK8(LUTNOM))
        ENDIF
        CALL JELIBE(JEXNUM(TT//'.LISTE.MA',I))
        CALL JELIBE(JEXNOM(NOMRES//'.GROUPEMA',NOMSST))
        CALL JELIBE(MAICON)
        CALL JELIBE(MAILLA//'.TYPMAIL')
        CALL JEDETR(TT//'.INV.MAILLA')
        NBINCR = NBINCR + NBMA
C
400   CONTINUE
C
      CALL JEDETC('V',TT,1)
      CALL JEDEMA()
      END
