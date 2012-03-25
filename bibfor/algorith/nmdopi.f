      SUBROUTINE NMDOPI(MODELZ,NUMEDD,METHOD,LRELI ,SDPILO)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 26/03/2012   AUTEUR PROIX J-M.PROIX 
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
C RESPONSABLE MABBAS M.ABBAS
C
      IMPLICIT NONE
      CHARACTER*(*)      MODELZ
      CHARACTER*24       NUMEDD
      CHARACTER*16       METHOD(*)
      CHARACTER*19       SDPILO
      LOGICAL            LRELI
C
C ----------------------------------------------------------------------
C
C ROUTINE MECA_NON_LINE (STRUCTURES DE DONNEES)
C
C CONSTRUCTION DE LA SD PILOTAGE
C
C ----------------------------------------------------------------------
C
C
C IN  MODELE : MODELE
C IN  NUMEDD : NUME_DDL
C IN  METHOD : DESCRIPTION DE LA METHODE DE RESOLUTION
C IN  LRELI  : .TRUE. SI RECHERCHE LINEAIRE
C OUT SDPILO : SD PILOTAGE
C               .PLTK
C                (1) = TYPE DE PILOTAGE
C                (2) = LIGREL POUR LES PILOTAGES PAR ELEMENTS
C                (3) = NOM DE LA CARTE DU TYPE (PILO_K)
C                (4) = NOM DE LA CARTE DU TYPE (PILO_R) MIN/MAX
C                (5) = PROJECTION 'OUI' OU 'NON' SUR LES BORNES
C                (6) = TYPE DE SELECTION : 'RESIDU',
C                        'NORM_INCR_DEPL' OU 'ANGL_INCR_DEPL'
C                (7) = EVOLUTION DES BORNES
C                        'CROISSANT', 'DECROISSANT' OU 'SANS'
C               .PLCR  COEFFICIENTS DU PILOTAGE
C               .PLCI  REPERAGE DES BINOMES (ARETE,COMPOSANTE) AVEC XFEM
C               .PLIR  PARAMETRES DU PILOTAGE
C                (1) = COEF_PILO
C                (2) = ETA_PILO_MAX
C                (3) = ETA_PILO_MIN
C                (4) = ETA_PILO_R_MAX
C                (5) = ETA_PILO_R_MIN
C                (6) = COEF_PILO AU PAS DE TEMPS CONVERGE PRECEDENT
C
C --- DEBUT DECLARATIONS NORMALISEES JEVEUX ----------------------------
C
      INTEGER ZI
      COMMON /IVARJE/ ZI(1)
      REAL*8 ZR
      COMMON /RVARJE/ ZR(1)
      COMPLEX*16 ZC
      COMMON /CVARJE/ ZC(1)
      LOGICAL ZL
      COMMON /LVARJE/ ZL(1)
      CHARACTER*8 ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
      COMMON /KVARJE/ ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C
C -------------- FIN  DECLARATIONS  NORMALISEES  JEVEUX ----------------
C
      INTEGER       NBNO,NUMEQU, NDDL,NBNOMA
      INTEGER       INO,IDDL
      INTEGER       JVALE
      INTEGER       JPLIR,JPLTK,JPLSL
      INTEGER       IBID, IER, N1, N2, NEQ,NDIM
      REAL*8        COEF, R8BID, LM(2)
      REAL*8        R8VIDE,R8GAEM,R8PREM
      COMPLEX*16    C16BID
      CHARACTER*8   K8BID,NOMA,LBORN(2),NOMCMP
      CHARACTER*8   MODELE,FISS
      CHARACTER*16  RELMET
      CHARACTER*24  LISNOE,LISCMP,LISDDL,LISEQU
      INTEGER       JLINOE,JLICMP,JDDL,JEQU
      CHARACTER*24  TYPPIL,PROJBO,TYPSEL,EVOLPA,TXT(2)
      CHARACTER*19  CHAPIL,SELPIL,LIGRMO,LIGRPI
      CHARACTER*19  CARETA,CARTYP,CHAPIC
      REAL*8        ETRMAX,ETRMIN,ETAMIN,ETAMAX
      INTEGER       NBMOCL
      CHARACTER*16  LIMOCL(2),TYMOCL(2)
      INTEGER       IFM,NIV
      INTEGER       JLINO1,JLINO2,NBNOM,NOEU1,NOEU2
      INTEGER       IVALE,JEQ2,IERM
      CHARACTER*8   COMPO
      CHARACTER*19  GRLN,CNSLN,GRLT
      CHARACTER*24  LISEQ2,LISNO1,LISNO2
      REAL*8        COEF1,COEF2,COEFI,VECT(3)
      LOGICAL       ISXFE,SELXFE,SELFEM
      INTEGER      IARG
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
      CALL INFDBG('MECA_NON_LINE',IFM,NIV)
C
C --- INITIALISATIONS
C
      MODELE = MODELZ
      CALL EXIXFE(MODELE,IERM)
      ISXFE=(IERM.EQ.1)
      CALL DISMOI('F','NOM_MAILLA',NUMEDD,'NUME_DDL',IBID,NOMA,IER)
      CALL DISMOI('F','NB_NO_MAILLA',NOMA,'MAILLAGE',NBNOMA,K8BID,IER)
      CALL DISMOI('F','DIM_GEOM',NOMA,'MAILLAGE',NDIM,K8BID,IER)
      LISDDL = '&&NMDOPI.LISDDL'
      LISEQU = '&&NMDOPI.LISEQU'
      LISNOE = '&&NMDOPI.LISNOE'
      LISCMP = '&&NMDOPI.LISCMP'
      NBMOCL = 2
      LIMOCL(1) = 'GROUP_NO'
      LIMOCL(2) = 'NOEUD'
      TYMOCL(1) = 'GROUP_NO'
      TYMOCL(2) = 'NOEUD'
C
C --- AFFICHAGE
C
      IF (NIV.GE.2) THEN
        WRITE (IFM,*) '<MECANONLINE> ... CREATION SD PILOTAGE'
      ENDIF
C
C --- LECTURE DU TYPE ET DE LA ZONE
C
      CALL WKVECT(SDPILO(1:19)// '.PLTK','V V K24',7,JPLTK)
      CALL GETVTX('PILOTAGE','TYPE'           ,1,IARG,1,TYPPIL,N1)
      ZK24(JPLTK)   = TYPPIL
      CALL GETVTX('PILOTAGE','PROJ_BORNES'    ,1,IARG,1,PROJBO,N1)
      ZK24(JPLTK+4) = PROJBO
      CALL GETVTX('PILOTAGE','SELECTION'      ,1,IARG,1,TYPSEL,N1)
      ZK24(JPLTK+5) = TYPSEL
      CALL GETVTX('PILOTAGE','EVOL_PARA'      ,1,IARG,1,EVOLPA,N1)
      ZK24(JPLTK+6) = EVOLPA
C
C --- PARAMETRES COEF_MULT ET ETA_PILO_MAX
C
      CALL WKVECT(SDPILO(1:19)// '.PLIR','V V R8',6,JPLIR)
      CALL GETVR8('PILOTAGE','COEF_MULT',1,IARG,1,COEF  , N1)
      ZR(JPLIR)   = COEF
      ZR(JPLIR+5) = COEF
      IF (ABS(COEF).LE.R8PREM()) THEN
        CALL U2MESS('F','PILOTAGE_3')
      ENDIF

      CALL GETVR8('PILOTAGE','ETA_PILO_R_MAX',1,IARG,1,ETRMAX,N1)
      IF (N1.NE.1)  ETRMAX = R8GAEM()
      ZR(JPLIR+3) = ETRMAX

      CALL GETVR8('PILOTAGE','ETA_PILO_R_MIN',1,IARG,1,ETRMIN,N2)
      IF (N2.NE.1)  ETRMIN = -R8GAEM()
      ZR(JPLIR+4) = ETRMIN

      CALL GETVR8('PILOTAGE','ETA_PILO_MAX',1,IARG,1,ETAMAX,N1)
      IF (N1.NE.1)  THEN
        ETAMAX = R8VIDE()
      ELSE
        IF (ETAMAX.GT.ZR(JPLIR+3)) CALL U2MESS('F','PILOTAGE_48')
      END IF
      ZR(JPLIR+1) = ETAMAX

      CALL GETVR8('PILOTAGE','ETA_PILO_MIN',1,IARG,1,ETAMIN,N2)
      IF (N2.NE.1) THEN
        ETAMIN = R8VIDE()
      ELSE
        IF (ETAMIN.LT.ZR(JPLIR+4)) CALL U2MESS('F','PILOTAGE_49')
      END IF
      ZR(JPLIR+2) = ETAMIN

      IF(TYPPIL.EQ.'SAUT_IMPO'.OR.TYPPIL.EQ.'SAUT_LONG_ARC') THEN
        IF(.NOT.ISXFE) CALL U2MESS('F','PILOTAGE_60')
        CALL GETVID('PILOTAGE','FISSURE',1,IARG,0,FISS,N1)
        IF(N1.NE.0) THEN
          CALL GETVID('PILOTAGE','FISSURE',1,IARG,1,FISS,N1)
        ELSE
          CALL U2MESS('F','PILOTAGE_58')
        ENDIF
      ENDIF

      IF(ISXFE.AND.(TYPSEL.EQ.'ANGL_INCR_DEPL'.
     &           OR.TYPSEL.EQ.'NORM_INCR_DEPL')) THEN
        CALL GETVID('PILOTAGE','FISSURE',1,IARG,0,FISS,N1)
        IF(N1.NE.0) THEN
          CALL GETVID('PILOTAGE','FISSURE',1,IARG,1,FISS,N1)
        ELSE
          CALL U2MESS('F','PILOTAGE_59')
        ENDIF
      ENDIF
C ======================================================================
C             PILOTAGE PAR PREDICTION ELASTIQUE : PRED_ELAS
C ======================================================================

      IF (TYPPIL .EQ. 'PRED_ELAS' .OR.
     &    TYPPIL .EQ. 'DEFORMATION') THEN

        CALL EXLIMA('PILOTAGE',1,'V',MODELE,LIGRPI)
        ZK24(JPLTK+1) = LIGRPI


        CARTYP = '&&NMDOPI.TYPEPILO'
        LIGRMO = MODELE // '.MODELE'
        CALL MECACT('V'   ,CARTYP,'MODELE',LIGRMO,'PILO_K',
     &              1     ,'TYPE',IBID    ,R8BID ,C16BID  ,
     &              TYPPIL)
        ZK24(JPLTK+2) = CARTYP

        LM(1)    = ETRMAX
        LM(2)    = ETRMIN
        CARETA   = '&&NMDOPI.BORNEPILO'
        LBORN(1) = 'A0'
        LBORN(2) = 'A1'
        CALL MECACT('V'   ,CARETA,'MODELE',LIGRMO,'PILO_R',
     &              2     ,LBORN ,IBID    ,LM    ,C16BID  ,
     &              K8BID)
        ZK24(JPLTK+3) = CARETA



C ======================================================================
C              PILOTAGE PAR UN DEGRE DE LIBERTE : DDL_IMPO
C ======================================================================

      ELSE IF (TYPPIL .EQ. 'DDL_IMPO'.OR.TYPPIL .EQ. 'SAUT_IMPO') THEN

        CALL RELIEM(MODELE,NOMA  ,'NU_NOEUD','PILOTAGE',1   ,
     &              NBMOCL,LIMOCL,TYMOCL,LISNOE,NBNO)
        IF(TYPPIL .EQ. 'DDL_IMPO') THEN
           IF(NBNO.NE.1) CALL U2MESS('F','PILOTAGE_50')
           COEF = 1.D0
        ENDIF


C ======================================================================
C      PILOTAGE PAR UNE METHODE DE TYPE LONGUEUR D'ARC : LONG_ARC
C ======================================================================

      ELSE IF (TYPPIL.EQ.'LONG_ARC'.OR.TYPPIL.EQ.'SAUT_LONG_ARC') THEN

        CALL RELIEM(MODELE,NOMA  ,'NU_NOEUD','PILOTAGE',1   ,
     &              NBMOCL,LIMOCL,TYMOCL,LISNOE,NBNO)
        IF(TYPPIL .EQ. 'LONG_ARC') THEN
           IF (NBNO.EQ.0) CALL U2MESS('F','PILOTAGE_57')
           COEF = 1.D0 / NBNO
        ENDIF
      ENDIF
C
C --- CREATION SD SELECTION DES DDLS EN FEM ?
C
      SELFEM = ((TYPPIL .EQ. 'LONG_ARC' ).OR.(TYPPIL .EQ. 'DDL_IMPO' ))
C
C --- CREATION SD SELECTION DES DDLS EN X-FEM ?
C
      SELXFE = ((TYPPIL.EQ.'SAUT_LONG_ARC').OR.(TYPPIL .EQ. 'SAUT_IMPO')
     &            .OR.(ISXFE.AND.TYPSEL.NE.'RESIDU'))

      IF (SELFEM) THEN
        CALL GETVTX('PILOTAGE','NOM_CMP',1,IARG,0,K8BID,NDDL )
        NDDL = -NDDL
        IF(NDDL.NE.1.AND.TYPPIL.EQ.'DDL_IMPO') THEN
          TXT(1)='NOM_CMP'
          TXT(2)=TYPPIL
          CALL U2MESK('F','PILOTAGE_56',2,TXT)
        ELSEIF(NDDL.EQ.0.AND.TYPPIL.EQ.'LONG_ARC') THEN
          TXT(1)='NOM_CMP'
          TXT(2)=TYPPIL
          CALL U2MESK('F','PILOTAGE_55',2,TXT)
        ENDIF
        IF(NDDL.GT.0) THEN
           CALL WKVECT(LISCMP,'V V K8',NDDL,JLICMP)
           CALL GETVTX ('PILOTAGE','NOM_CMP',1,IARG,NDDL,
     &                ZK8(JLICMP), IBID)
        ENDIF
        CALL JEVEUO(LISNOE,'L',JLINOE)
      ENDIF



      IF (SELXFE) THEN
        CALL GETVTX('PILOTAGE','DIRE_PILO',1,IARG,0,K8BID,NDDL )
        NDDL = -NDDL
        IF(NDDL.NE.1.AND.TYPPIL.EQ.'SAUT_IMPO') THEN
          TXT(1)='DIRE_PILO'
          TXT(2)=TYPPIL
          CALL U2MESK('F','PILOTAGE_56',2,TXT)
        ELSEIF(NDDL.EQ.0.AND.TYPPIL.EQ.'SAUT_LONG_ARC') THEN
          TXT(1)='DIRE_PILO'
          TXT(2)=TYPPIL
          CALL U2MESK('F','PILOTAGE_55',2,TXT)
        ELSEIF(NDDL.EQ.0) THEN
          CALL U2MESK('F','PILOTAGE_64',1,TYPSEL)
        ENDIF
        IF(NDDL.GT.0) THEN
           CALL WKVECT(LISCMP,'V V K8',NDDL,JLICMP)
           CALL GETVTX ('PILOTAGE','DIRE_PILO',1,IARG,NDDL,
     &                ZK8(JLICMP), IBID)
        ENDIF

        LISNO1 ='&&NMDOPI.LISNO1'
        LISNO2 ='&&NMDOPI.LISNO2'
        CNSLN  ='&&NMDOPI.CNSLN'
        GRLN   ='&&NMDOPI.GRLN'
        GRLT   ='&&NMDOPI.GRLT'
        CALL CNOCNS(FISS//'.LNNO','V',CNSLN)
        CALL CNOCNS(FISS//'.GRLNNO','V',GRLN)
        CALL CNOCNS(FISS//'.GRLTNO','V',GRLT)

        CALL NMMEIN(FISS,NOMA,NBNO,LISNOE,LISCMP,NBNOM,
     &             LISNO1,LISNO2,NDIM,COMPO)
        CALL JEVEUO(LISNO1,'L',JLINO1)
        CALL JEVEUO(LISNO2,'L',JLINO2)
        NBNO=NBNOM
        LISEQ2='&&NMDOPI.LISEQ2'
        CALL WKVECT(LISEQ2,'V V I',NBNO,JEQ2)
        CHAPIC = SDPILO(1:14)//'.PLCI'
        CALL VTCREB(CHAPIC,NUMEDD,'V','R',NEQ)
        CALL JEVEUO(CHAPIC(1:19)//'.VALE','E',IVALE)
      ENDIF

      IF(SELFEM.OR.SELXFE) THEN
        CHAPIL = SDPILO(1:14)//'.PLCR'
        CALL VTCREB(CHAPIL,NUMEDD,'V','R',NEQ)
        CALL JEVEUO(CHAPIL(1:19)//'.VALE','E',JVALE)
        CALL WKVECT(LISDDL,'V V K8',NBNO ,JDDL )
        CALL WKVECT(LISEQU,'V V I' ,NBNO ,JEQU )
        CALL JEVEUO(LISCMP,'L',JLICMP)
        CALL JELIRA(LISCMP,'LONMAX',NDDL,K8BID)

        DO 10 IDDL = 1,NDDL
          NOMCMP = ZK8(JLICMP-1+IDDL)
          DO 15 INO = 1,NBNO
            ZK8(JDDL-1+INO) = NOMCMP
 15       CONTINUE
          IF(SELXFE) THEN
          CALL NUEQCH('F',CHAPIL, NOMA, NBNO, ZI(JLINO1),
     &                ZK8(JDDL), ZI(JEQU))
          CALL NUEQCH('F',CHAPIL, NOMA, NBNO, ZI(JLINO2),
     &                ZK8(JDDL), ZI(JEQ2))
          ELSE IF(SELFEM) THEN
          CALL NUEQCH('F',CHAPIL, NOMA, NBNO, ZI(JLINOE),
     &                ZK8(JDDL), ZI(JEQU))
          ENDIF
          DO 20 INO = 1,NBNO
            IF(SELXFE) THEN
              NOEU1=ZI(JLINO1-1+INO)
              NOEU2=ZI(JLINO2-1+INO)
              IF(COMPO(1:4).EQ.'DTAN'.OR.
     &           COMPO.EQ.'DNOR') THEN
                CALL NMDIRE(NOEU1,NOEU2,NDIM,CNSLN,
     &                      GRLN,GRLT,COMPO,VECT)
              ENDIF
              CALL NMCOEF(NOEU1,NOEU2,TYPPIL,NBNO,
     &         CNSLN,COMPO,VECT,IDDL,INO,COEF1,COEF2,COEFI)
             NUMEQU = ZI(JEQU-1+INO)
             ZR(JVALE-1+NUMEQU) = COEF1
             ZR(IVALE-1+NUMEQU) = COEFI
             NUMEQU = ZI(JEQ2-1+INO)
             ZR(JVALE-1+NUMEQU) = COEF2
             ZR(IVALE-1+NUMEQU) = COEFI
            ELSE IF(SELFEM) THEN
            NUMEQU = ZI(JEQU-1+INO)
            ZR(JVALE-1+NUMEQU) = COEF
            ENDIF
 20       CONTINUE
 10     CONTINUE
      ENDIF
C
      CALL JEDETR(LISDDL)
      CALL JEDETR(LISEQU)
      CALL JEDETR(LISNOE)
      CALL JEDETR(LISCMP)
      IF(SELXFE) THEN
        CALL JEDETR(LISNO1)
        CALL JEDETR(LISNO2)
        CALL JEDETR(LISEQ2)
        CALL JEDETR(CNSLN)
        CALL JEDETR(GRLN)
      ENDIF
C
C --- CREATION SD REPERAGE DES DX/DY/DZ
C
      IF (TYPPIL .EQ. 'LONG_ARC') THEN
        SELPIL = SDPILO(1:14)//'.PLSL'
        CALL VTCREB(SELPIL,NUMEDD,'V','R',NEQ)
        CALL JEVEUO(SELPIL(1:19)//'.VALE','E',JPLSL)

        NDDL = 3
        CALL WKVECT(LISCMP,'V V K8',NDDL,JLICMP)
        ZK8(JLICMP+1-1) = 'DX'
        ZK8(JLICMP+2-1) = 'DY'
        ZK8(JLICMP+3-1) = 'DZ'

        CALL WKVECT(LISDDL,'V V K8',NBNOMA,JDDL  )
        CALL WKVECT(LISNOE,'V V I' ,NBNOMA,JLINOE)
        CALL WKVECT(LISEQU,'V V I' ,NBNOMA,JEQU  )
        DO 16 INO = 1,NBNOMA
          ZI(JLINOE-1+INO) = INO
 16     CONTINUE
        DO 70 IDDL = 1,NDDL
          DO 75 INO = 1,NBNOMA
            ZK8(JDDL-1+INO) = ZK8(JLICMP-1+IDDL)
 75       CONTINUE

          CALL NUEQCH(' ',SELPIL,NOMA,NBNOMA,
     &    ZI(JLINOE),ZK8(JDDL),ZI(JEQU))

          DO 80 INO = 1,NBNOMA
            NUMEQU = ZI(JEQU-1+INO)
            CALL ASSERT(NUMEQU.LE.NEQ)
            IF (NUMEQU.NE.0) THEN
              ZR(JPLSL-1+NUMEQU) = 1.D0
            ENDIF
 80       CONTINUE
 70     CONTINUE
      ENDIF
C
C --- GESTION RECHERCHE LINEAIRE
C
      IF (LRELI) THEN
        RELMET = METHOD(7)
        IF (TYPPIL .NE. 'DDL_IMPO' ) THEN
          IF (RELMET.NE.'PILOTAGE') THEN
            CALL U2MESS('F','PILOTAGE_4')
          ENDIF
        ENDIF
      ENDIF
C
      CALL JEDETR(LISDDL)
      CALL JEDETR(LISEQU)
      CALL JEDETR(LISNOE)
      CALL JEDETR(LISCMP)
      CALL JEDEMA()
      END
