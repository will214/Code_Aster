      SUBROUTINE ACEARM(NOMA,NOMO,LMAX,NOEMAF,NBOCC,IVR,
     +                  IFM)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF MODELISA  DATE 06/07/2009   AUTEUR COURTOIS M.COURTOIS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2003  EDF R&D                  WWW.CODE-ASTER.ORG
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
      IMPLICIT REAL*8 (A-H,O-Z)
      INTEGER           LMAX,NBOCC,IVR(*)
      CHARACTER*8       NOMA,NOMO
C ----------------------------------------------------------------------
C     AFFE_CARA_ELEM
C     AFFECTATION DES CARACTERISTIQUES POUR LES ELEMENTS DISCRET
C ----------------------------------------------------------------------
C IN  : NOMA   : NOM DU MAILLAGE
C IN  : NOMO   : NOM DU MODELE
C IN  : LMAX   : NOMBRE MAX DE MAILLE OU GROUPE DE MAILLE
C IN  : NBOCC  : NOMBRE D'OCCURENCES DU MOT CLE DISCRET
C IN  : IVR    : TABLEAU DES INDICES DE VERIFICATION
C ----------------------------------------------------------------------
C     ----- DEBUT COMMUNS NORMALISES  JEVEUX  --------------------------
      INTEGER          ZI
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
      CHARACTER*32     JEXNUM, JEXNOM
C     -----  FIN  COMMUNS NORMALISES  JEVEUX  --------------------------
      PARAMETER    ( NRD = 2 )
      INTEGER      JDC(3), JDV(3), ULISOP
      REAL*8       ETA, VALE(3)
      CHARACTER*1  KMA(3)
      CHARACTER*8  NOGP, NOMMAI, NOGL, K8B, NOMU
      CHARACTER*9  CARA
      CHARACTER*16 REP, REPDIS(NRD), CONCEP, CMD, K16NOM
      CHARACTER*19 CART(3), CARTDI
      CHARACTER*24 TMPND(3), TMPVD(3), MLGNMA, TMCINF,TMVINF
      DATA REPDIS  /'GLOBAL          ','LOCAL           '/
      DATA KMA     /'K','M','A'/
C     ------------------------------------------------------------------
C
      CALL JEMARQ()
      CALL GETRES(NOMU,CONCEP,CMD)
      MLGNMA = NOMA//'.NOMMAI'
      CALL WKVECT('&&TMPRIGMA','V V R',3*LMAX,IRGMA)
      CALL WKVECT('&&TMPRIGM2','V V R',3*LMAX,IRGM2)
      CALL WKVECT('&&TMPRIGM3','V V R',3*LMAX,IRGM3)
      CALL WKVECT('&&TMPRIPTO','V V R',3*NOEMAF,IRPTO)
      CALL WKVECT('&&TMPRILTO','V V R',3*NOEMAF,IRLTO)
      CALL WKVECT('&&TMPTABMP','V V K8',LMAX,ITBMP)
      IFM = IUNIFI('MESSAGE')
C
C --- RECUPERATION DE LA DIMENSION DU MAILLAGE
      NDIM = 3
C      CALL DISMOI('F','Z_CST',NOMO,'MODELE',IBID,K8B,IER)
C      IF ( K8B(1:3) .EQ. 'OUI' )  NDIM = 2
C
C --- CONSTRUCTION DES CARTES ET ALLOCATION
      CARTDI = NOMU//'.CARDINFO'
      TMCINF = CARTDI//'.NCMP'
      TMVINF = CARTDI//'.VALV'
C     SI LA CARTE N'EXISTE PAS ON LA CREE
      CALL JEEXIN(TMCINF,IXCI)
      IF (IXCI .EQ. 0) CALL ALCART('G',CARTDI,NOMA,'CINFDI')
C
      CALL JEVEUO(TMCINF,'E',JDCINF)
      CALL JEVEUO(TMVINF,'E',JDVINF)
C     PAR DEFAUT POUR M, A, K : REPERE GLOBAL , MATRICE SYMETRIQUE
      DO 200 I = 1 , 3
         ZK8(JDCINF+I-1) = 'REP'//KMA(I)//'    '
         ZR (JDVINF+I-1) = 1.D0
         ZK8(JDCINF+I+2) = 'SYM'//KMA(I)//'    '
         ZR (JDVINF+I+2) = 1.D0
200   CONTINUE
      ZK8(JDCINF+6) = 'ETAK    '
      ZR (JDVINF+6) = 0.D0

      DO 220 I = 1 , 3
         CART(I)  = NOMU//'.CARDISC'//KMA(I)
         TMPND(I) = CART(I)//'.NCMP'
         TMPVD(I) = CART(I)//'.VALV'
C        SI LES CARTES N'EXISTENT PAS ON LES CREES
         CALL JEEXIN(TMPND(I),IXCKMA)
         IF (IXCKMA .EQ. 0) THEN
            CALL ALCART('G',CART(I),NOMA,'CADIS'//KMA(I))
         ENDIF
         CALL JEVEUO(TMPND(I),'E',JDC(I))
         CALL JEVEUO(TMPVD(I),'E',JDV(I))
220   CONTINUE
C
C --- BOUCLE SUR LES OCCURENCES DE DISCRET
      DO 30 IOC = 1 , NBOCC
         ETA  = 0.0D0
C        PAR DEFAUT ON EST DANS LE REPERE GLOBAL, MATRICES SYMETRIQUES
         IREP = 1
         ISYM = 1
         REP = REPDIS(1)
         CALL GETVIS('RIGI_MISS_3D','UNITE_RESU_IMPE',IOC,1,1,IFMIS,NU)
         K16NOM = ' '
         IF ( ULISOP ( IFMIS, K16NOM ) .EQ. 0 )  THEN
           CALL ULOPEN ( IFMIS,' ',' ','NEW','O')
         ENDIF
         CALL GETVR8('RIGI_MISS_3D','FREQ_EXTR',IOC,1,1,FREQ,NFR)
         CALL GETVTX('RIGI_MISS_3D','GROUP_MA_POI1',IOC,1,1,NOGP,NGP)
         CALL GETVTX('RIGI_MISS_3D','GROUP_MA_SEG2',IOC,1,1,NOGL,NGL)
         DO 32 I = 1 , NRD
            IF (REP.EQ.REPDIS(I)) IREP = I
 32      CONTINUE
         IF (IVR(3).EQ.1) THEN
            WRITE(IFM,1000)REP,IOC
 1000       FORMAT(/,3X,
     &            '<DISCRET> MATRICES AFFECTEES AUX ELEMENTS DISCRET ',
     &                                '(REPERE ',A6,'), OCCURENCE ',I4)
         ENDIF
         CALL IRMIFR(IFMIS,FREQ,IFREQ,NFREQ)
C
C ---    "GROUP_MA" = TOUTES LES MAILLES DE TOUS LES GROUPES DE MAILLES
         IF (NGL.NE.0) THEN
           CALL RIGMI2(NOMA,NOGL,IFREQ,NFREQ,IFMIS,ZR(IRGM2),
     &                 ZR(IRGM3),ZR(IRLTO))
         ENDIF
         CARA = 'K_T_D_N'
         IF (NGP.NE.0) THEN
           CALL JELIRA(JEXNOM(NOMA//'.GROUPEMA',NOGP),'LONMAX',
     &                 NMA,K8B)
           CALL JEVEUO(JEXNOM(NOMA//'.GROUPEMA',NOGP),'L',LDGM)
           NBPO = NMA
           CALL RIGMI1(NOMA,NOGP,IFREQ,NFREQ,IFMIS,ZR(IRGMA),
     &                 ZR(IRGM3),ZR(IRPTO))
           DO 21 IN = 0,NMA-1
            CALL JENUNO(JEXNUM(MLGNMA,ZI(LDGM+IN)),NOMMAI)
            ZK8(ITBMP+IN) = NOMMAI
 21        CONTINUE
           DO 41 I = 1,NBPO
             IV = 1
             JD = ITBMP + I - 1
             CALL AFFDIS(NDIM,IREP,ETA,CARA,ZR(IRGMA+3*I-3),JDC,
     &                   JDV,IVR,IV,KMA,NCMP,L,
     &                   JDCINF,JDVINF,ISYM,IFM)
             CALL NOCART(CARTDI ,3,' ','NOM',1,ZK8(JD),0,' ',7)
             CALL NOCART(CART(L),3,' ','NOM',1,ZK8(JD),0,' ',NCMP)
 41        CONTINUE
         ENDIF
C
         CARA = 'K_T_D_L'
         IF (NGL.NE.0) THEN
           COEF=20.D0
           CALL JELIRA(JEXNOM(NOMA//'.GROUPEMA',NOGL),'LONMAX',
     &                 NMA,K8B)
           CALL JEVEUO(JEXNOM(NOMA//'.GROUPEMA',NOGL),'L',LDGM)
           NBLI = NMA
           DO 22 IN = 0,NMA-1
            CALL JENUNO(JEXNUM(MLGNMA,ZI(LDGM+IN)),NOMMAI)
            ZK8(ITBMP+IN) = NOMMAI
 22        CONTINUE
           CALL R8INIR(3,0.D0,VALE,1)
           DO 42 I = 1,NBLI
             IV = 1
             JD = ITBMP + I - 1
             VALE(1)=-ZR(IRGM2+3*I-3)*COEF
             VALE(2)=-ZR(IRGM2+3*I-2)*COEF
             VALE(3)=-ZR(IRGM2+3*I-1)*COEF
             CALL AFFDIS(NDIM,IREP,ETA,CARA,VALE,JDC,JDV,
     &                   IVR,IV,KMA,NCMP2,L,JDCINF,JDVINF,ISYM,IFM)
             CALL NOCART(CARTDI ,3,' ','NOM',1,ZK8(JD),0,' ',7)
             CALL NOCART(CART(L),3,' ','NOM',1,ZK8(JD),0,' ',NCMP2)
 42        CONTINUE
         ENDIF
 30   CONTINUE
C
      CALL JEDETR('&&TMPRIGMA')
      CALL JEDETR('&&TMPRIGM2')
      CALL JEDETR('&&TMPRIGM3')
      CALL JEDETR('&&TMPRIPTO')
      CALL JEDETR('&&TMPRILTO')
      CALL JEDETR('&&TMPTABMP')
      CALL JEDETR('&&ACEARM.RIGM')
      DO 240 I = 1 , 3
         CALL JEDETR(TMPND(I))
         CALL JEDETR(TMPVD(I))
240   CONTINUE
      CALL JEDETR(TMCINF)
      CALL JEDETR(TMVINF)
C
      CALL JEDEMA()
      END
