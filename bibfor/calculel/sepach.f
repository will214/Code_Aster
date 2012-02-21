      SUBROUTINE SEPACH(CARAEL,CHINZ,BASE,CHREEL,CHIMAG)

      IMPLICIT NONE
      CHARACTER*1  BASE
      CHARACTER*8 CARAEL
      CHARACTER*19 CHREEL,CHIMAG
      CHARACTER*(*) CHINZ

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF CALCULEL  DATE 20/02/2012   AUTEUR SELLENET N.SELLENET 
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
C   1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================

C-----------------------------------------------------------------------
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
C     ----- FIN COMMUNS NORMALISES  JEVEUX  --------------------------

      INTEGER GD,GDRE,JDESC,JDESCR,JDESCI,NBVAL,NBVAL2
      INTEGER JVALER,JVALEI,IVALE,IER
      INTEGER NMAX1,NMAX2,JNCMPR,JNCMPC,I,JCELD,JCELK,ICELV,JCELVR
      INTEGER JCELVI,TAILLE,LONG,IBID,NBSP
      CHARACTER*8 NOMGD,NOMRE,K8B
      CHARACTER*4 TYPCH,KBID
      CHARACTER*19 CANBVA,CHIN
      CHARACTER*24 LIGREL,OPTION,PARAM,VALK(2)

      CALL JEMARQ()

      CHIN=CHINZ

      CALL JEEXIN(CHIN//'.DESC',IER)
      IF (IER.NE.0) THEN
        CALL JEEXIN(CHIN//'.LIMA',IER)
        IF( IER.NE.0 ) THEN
          TYPCH='CART'
        ELSE
          TYPCH='CHNO'
        ENDIF
      ELSE
        CALL JEEXIN(CHIN//'.CELK',IER)
        IF (IER.NE.0) THEN
          TYPCH='CHML'
        ELSE
          CALL U2MESS('F','CALCULEL_17')
        ENDIF
      ENDIF

      IER=0

      IF ( TYPCH.EQ.'CHNO'.OR.TYPCH.EQ.'CART' ) THEN
        CALL JEVEUO(CHIN//'.DESC','L',JDESC)
        GD=ZI(JDESC)
      ELSE
        CALL JEVEUO(CHIN//'.CELD','L',JCELD)
        GD=ZI(JCELD)
      ENDIF
      CALL JENUNO(JEXNUM('&CATA.GD.NOMGD',GD),NOMGD)
      IF ((NOMGD(7:7).NE.' ').OR.(NOMGD(5:6).NE.'_C')) THEN
        CALL U2MESK('F','CALCULEL4_80',1,NOMGD)
      ENDIF
      NOMRE=NOMGD(1:4)//'_R'
      CALL JENONU(JEXNOM('&CATA.GD.NOMGD',NOMRE),GDRE)

      CALL JELIRA(JEXNUM('&CATA.GD.NOMCMP',GD),'LONMAX',NMAX1,K8B)
      CALL JELIRA(JEXNUM('&CATA.GD.NOMCMP',GDRE),'LONMAX',NMAX2,K8B)

      IF (NMAX1.NE.NMAX2) THEN
         VALK(1) = NOMGD
         VALK(2) = NOMRE
         CALL U2MESK('F','CALCULEL4_81', 2 ,VALK)
      ENDIF
      CALL JEVEUO(JEXNUM('&CATA.GD.NOMCMP',GDRE),'L',JNCMPR)
      CALL JEVEUO(JEXNUM('&CATA.GD.NOMCMP',GD),'L',JNCMPC)

      DO 10 I=1,NMAX1
        IF (ZK8(JNCMPR-1+I).NE.ZK8(JNCMPC-1+I)) THEN
          IER=1
          GOTO 10
        ENDIF
 10   CONTINUE

      IF (IER.NE.0) THEN
         VALK(1) = NOMGD
         VALK(2) = NOMRE
         CALL U2MESK('F','CALCULEL4_82', 2 ,VALK)
      ENDIF

C     -- CHAM_NO :
C     -------------------
      IF ( TYPCH.EQ.'CHNO') THEN
        CALL JEDUP1(CHIN//'.DESC',BASE,CHREEL//'.DESC')
        CALL JEDUP1(CHIN//'.REFE',BASE,CHREEL//'.REFE')
        CALL JEVEUO(CHREEL//'.DESC','E',JDESCR)
        ZI(JDESCR)=GDRE

        CALL JEDUP1(CHIN//'.DESC',BASE,CHIMAG//'.DESC')
        CALL JEDUP1(CHIN//'.REFE',BASE,CHIMAG//'.REFE')
        CALL JEVEUO(CHIMAG//'.DESC','E',JDESCI)
        ZI(JDESCI)=GDRE

        CALL JELIRA(CHIN//'.VALE','LONMAX',NBVAL,K8B)
        CALL JEVEUO(CHIN//'.VALE','L',IVALE)

        CALL WKVECT(CHREEL//'.VALE',BASE//' V R',NBVAL,JVALER)
        CALL WKVECT(CHIMAG//'.VALE',BASE//' V R',NBVAL,JVALEI)

        DO 20 I=1,NBVAL
          ZR(JVALER-1+I)=DBLE(ZC(IVALE-1+I))
          ZR(JVALEI-1+I)=DIMAG(ZC(IVALE-1+I))
 20     CONTINUE



C     -- CHAM_ELEM :
C     -------------------
      ELSE IF ( TYPCH.EQ.'CHML') THEN
        CALL JEVEUO(CHIN//'.CELK','L',JCELK)
        LIGREL=ZK24(JCELK)
        OPTION=ZK24(JCELK+1)
        PARAM=ZK24(JCELK+5)
        LONG=24
        DO 40 I=1,LONG
          IF (PARAM(I:I).EQ.' ') THEN
            TAILLE=I-1
            GOTO 45
          ENDIF
 40     CONTINUE

 45     CONTINUE

        PARAM=PARAM(1:(TAILLE-1))//'R'

C       -- SI LE CHIN A DES SOUS-POINTS, IL FAUT ALLOUER CHREEL
C          ET CHIMAG AVEC DES SOUS-POINTS :
        CALL DISMOI('F','MXNBSP',CHIN,'CHAM_ELEM',NBSP,KBID,IBID)
        IF (NBSP.GT.1) THEN
          CANBVA='&&SEPACH.CANBVA'
          CALL CESVAR(CARAEL,' ',LIGREL,CANBVA)
          CALL ALCHML(LIGREL,OPTION,PARAM,BASE,CHREEL,IER,CANBVA)
          CALL ALCHML(LIGREL,OPTION,PARAM,BASE,CHIMAG,IER,CANBVA)
          CALL DETRSD('CHAM_ELEM_S',CANBVA)
        ELSE
          CALL ALCHML(LIGREL,OPTION,PARAM,BASE,CHREEL,IER,' ')
          CALL ALCHML(LIGREL,OPTION,PARAM,BASE,CHIMAG,IER,' ')
        ENDIF

        CALL JELIRA(CHIN//'.CELV','LONMAX',NBVAL,K8B)
        CALL JEVEUO(CHIN//'.CELV','L',ICELV)

        CALL JELIRA(CHREEL//'.CELV','LONMAX',NBVAL2,K8B)
        IF (NBVAL2.NE.NBVAL) THEN
          CALL ASSERT(NBVAL.GT.NBVAL2)
          CALL JUVECA(CHREEL//'.CELV',NBVAL)
          CALL JUVECA(CHIMAG//'.CELV',NBVAL)
        ENDIF


        CALL JEVEUO(CHREEL//'.CELV','E',JCELVR)
        CALL JEVEUO(CHIMAG//'.CELV','E',JCELVI)


        DO 50 I=1,NBVAL
          ZR(JCELVR-1+I)=DBLE(ZC(ICELV-1+I))
          ZR(JCELVI-1+I)=DIMAG(ZC(ICELV-1+I))
 50     CONTINUE

C     -- CART :
C     -------------------
      ELSE IF ( TYPCH.EQ.'CART') THEN
        CALL JEDUP1(CHIN//'.DESC',BASE,CHREEL//'.DESC')
        CALL JEDUP1(CHIN//'.NOMA',BASE,CHREEL//'.NOMA')
        CALL JEDUP1(CHIN//'.NOLI',BASE,CHREEL//'.NOLI')
        CALL JEDUP1(CHIN//'.LIMA',BASE,CHREEL//'.LIMA')
        CALL JEVEUO(CHREEL//'.DESC','E',JDESCR)
        ZI(JDESCR)=GDRE

        CALL JEDUP1(CHIN//'.DESC',BASE,CHIMAG//'.DESC')
        CALL JEDUP1(CHIN//'.NOMA',BASE,CHIMAG//'.NOMA')
        CALL JEDUP1(CHIN//'.NOLI',BASE,CHIMAG//'.NOLI')
        CALL JEDUP1(CHIN//'.LIMA',BASE,CHIMAG//'.LIMA')
        CALL JEVEUO(CHIMAG//'.DESC','E',JDESCI)
        ZI(JDESCI)=GDRE

        CALL JELIRA(CHIN//'.VALE','LONMAX',NBVAL,K8B)
        CALL JEVEUO(CHIN//'.VALE','L',IVALE)

        CALL WKVECT(CHREEL//'.VALE',BASE//' V R',NBVAL,JVALER)
        CALL WKVECT(CHIMAG//'.VALE',BASE//' V R',NBVAL,JVALEI)

        DO 60 I=1,NBVAL
          ZR(JVALER-1+I)=DBLE(ZC(IVALE-1+I))
          ZR(JVALEI-1+I)=DIMAG(ZC(IVALE-1+I))
 60     CONTINUE
        
      ENDIF

      CALL JEDEMA()

      END
