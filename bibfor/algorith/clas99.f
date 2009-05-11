      SUBROUTINE CLAS99 (NOMRES)
      IMPLICIT REAL*8 (A-H,O-Z)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 11/05/2009   AUTEUR NISTOR I.NISTOR 
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
C  P. RICHARD   DATE 09/07/91
C-----------------------------------------------------------------------
C  BUT : ROUTINE DE CREATION D'UNE BASE MODALE CLASSIQUE
C        BASE MODALE DE TYPE MIXTE CRAIG-BAMPTON, MAC-NEAL OU AUCUN
C
C-------- DEBUT COMMUNS NORMALISES  JEVEUX  ----------------------------
C
      INTEGER          ZI
      INTEGER VALI
      COMMON  /IVARJE/ ZI(1)
      REAL*8           ZR
      COMMON  /RVARJE/ ZR(1)
      COMPLEX*16       ZC
      COMMON  /CVARJE/ ZC(1)
      LOGICAL          ZL
      COMMON  /LVARJE/ ZL(1)
      CHARACTER*8      ZK8
      CHARACTER*16            ZK16
      CHARACTER*24                    ZK24
      CHARACTER*32                            ZK32
      CHARACTER*80                                    ZK80
      COMMON  /KVARJE/ ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C
C-----  FIN  COMMUNS NORMALISES  JEVEUX  -------------------------------
C
      CHARACTER*6  PGC
      CHARACTER*24 VALK
      CHARACTER*8  NOMRES,INTF,KBID
      CHARACTER*19 NUMDDL,RAID,MASS,RAIDLT
      COMPLEX*16   CBID
C
C-----------------------------------------------------------------------
      DATA PGC /'CLAS99'/
C-----------------------------------------------------------------------
C
C --- RECUPERATION DES CONCEPTS AMONT
C
      CALL JEMARQ()
      CALL JEVEUO(NOMRES//'           .REFD','L',LLREF)
      RAID=ZK24(LLREF)
      MASS=ZK24(LLREF+1)
      NUMDDL=ZK24(LLREF+3)
      INTF=ZK24(LLREF+4)
C
C --- RECUPERATION DU NOMBRE DE MODE_MECA A PRENDRE EN COMPTE
C
      CALL GETVID('CLASSIQUE','MODE_MECA',1,1,0,KBID,NBMOME)
      NBMOME = -NBMOME
C
C --- CREATION DES OBJETS TEMPORAIRES
C
      CALL WKVECT('&&'//PGC//'.LIST.MODE_MECA','V V K8',NBMOME,LTMOME)
      CALL WKVECT('&&'//PGC//'.LIST.NBMOD','V V I',NBMOME,LTNBMO)
C
      CALL GETVID('CLASSIQUE','MODE_MECA',1,1,NBMOME,ZK8(LTMOME),IBID)
      CALL GETVIS('CLASSIQUE','NMAX_MODE',1,1,1,NBMOUT,NBID)
C
C --- DETERMINATION DU NOMBRE TOTAL DE MODES PROPRES DE LA BASE
C
      NBMOD  = 0
      NBMOMA = 0
C
      DO 5 I=1,NBMOME
        CALL RSORAC(ZK8(LTMOME-1+I),'LONUTI',IBID,BID,KBID,CBID,EBID,
     &             'ABSOLU',NBMODO,1,NBID)
C
        IF (NBMODO.LT.NBMOUT) THEN
          CALL U2MESS('I+','ALGORITH15_92')
          VALK = ZK8(LTMOME-1+I)
          CALL U2MESG('I+','ALGORITH15_93',1,VALK,0,0,0,0.D0)
          VALI = NBMODO
          CALL U2MESG('I','ALGORITH15_94',0,' ',1,VALI,0,0.D0)
        ELSE
          NBMODO=NBMOUT
        ENDIF
C
        ZI(LTNBMO+I-1) = NBMODO
        NBMOMA = MAX(NBMOMA,NBMODO)
        NBMOD = NBMOD+NBMODO
5     CONTINUE
C
      CALL WKVECT('&&'//PGC//'.NUME.ORD','V V I',NBMOMA,LTORD)
      DO 10 II=1,NBMOMA
        ZI(LTORD+II-1)=II
 10   CONTINUE
C

C --- DETERMINATION NOMBRE TOTAL DE MODES ET DEFORMEES
C
      CALL JEVEUO(INTF//'.IDC_DESC','L',LLDESC)
      NBSDD=NBMOD+ZI(LLDESC+4)
C      NBSDD1=ZI(LLDESC+4)

C
C
C --- NOMBRE DE DEFORMEES STATIQUES A CALCULER
C
C
C --- ALLOCATION DE LA STRUCTURE DE DONNEES MODE_MECA
C
      CALL RSCRSD('G',NOMRES,'MODE_MECA',NBSDD)
      RAIDLT=' '
C
C --- COPIE DES MODES DYNAMIQUES
C
      INOR=1
      DO 6 I=1,NBMOME
        CALL MOCO99(NOMRES,ZK8(LTMOME+I-1),ZI(LTNBMO+I-1),
     &              ZI(LTORD),INOR,.TRUE.)
6     CONTINUE
      IF (NBMOMA.GT.0) CALL JEDETR('&&'//PGC//'.NUME.ORD')
      IF (NBMOME.GT.0) CALL JEDETR('&&'//PGC//'.LIST.MODE_MECA')
      IF (NBMOME.GT.0) CALL JEDETR('&&'//PGC//'.LIST.NBMOD')
C      CALL UTIMSD(6,2,.TRUE.,.TRUE.,NOMRES(1:8),1,'G')
C
C --- CALCUL DES MODES D'ATTACHE
      CALL CAMOAT(NOMRES,NUMDDL,INTF,RAID,RAIDLT,INOR)
C
C --- CALCUL DES MODES CONTRAINTS
      CALL CAMOCO(NOMRES,NUMDDL,INTF,RAID,RAIDLT,INOR)
C
C --- CALCUL DES MODES CONTRAINTS HARMONIQUES
      CALL CAMOCH(NOMRES,NUMDDL,INTF,RAID,MASS,RAIDLT,INOR)
C
C --- DESTRUCTION MATRICE FACTORISEE
C
      IF(RAIDLT(1:1).NE.' ') THEN
        CALL JEDETC('V',RAIDLT,1)
        RAIDLT=' '
      ENDIF
C
 9999 CONTINUE
      CALL JEDEMA()
      END
