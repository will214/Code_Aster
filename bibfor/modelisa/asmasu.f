      SUBROUTINE ASMASU (MA1, MA2, MAG)
      IMPLICIT NONE
      CHARACTER*8        MA1, MA2, MAG
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF MODELISA  DATE 13/04/2010   AUTEUR PELLET J.PELLET 
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
C
C     OPERATEUR: ASSE_MAILLAGE / CAS DE L ASSEMBLAGE DE MAILLAGES
C     AVEC SUPERPOSITION
C
C-----------------------------------------------------------------------
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
C
      CHARACTER*1  KKK
      CHARACTER*8  KIND, KBID,ZER1,ZER2
      CHARACTER*19 COORDO
      CHARACTER*8  NOMA,NONO,NOGMA,NOGMAB,NOGNO,NOGNOB
      INTEGER      NBMA,NBM1,NBM2,NBNO,NBN1,NBN2,NBGMA,NBGM1,NBGM2
      INTEGER      I1,ICOMPT,INO,L1,L2,L3,I,N,NCOOR,K,IFM,NIV
      INTEGER      IADIM1,IADIM2,IADIME
      INTEGER      IAGMA1,IAGMA2,IAGMAX
      INTEGER      IACON1,IACON2,IACONX
      INTEGER      IAGNO1,IAGNO2,IAGNOX
      INTEGER      IATYP1,IATYP2,IATYPX
      INTEGER      NBGNO,NBGN1,NBGN2,II,IGEOMR,IADESC,IBID,IAREFE
      INTEGER      IATYMA,IACOO1,IACOO2,IAVALE,IRET,IRET1,IRET2
      INTEGER      LXLGUT
C
C     ------------------------------------------------------------------
C
      CALL JEMARQ()
      CALL INFNIV(IFM,NIV)
C
C     --OBJET .DIME :
C     ---------------
      CALL JEVEUO(MA1//'.DIME','L',IADIM1)
      CALL JEVEUO(MA2//'.DIME','L',IADIM2)
      CALL WKVECT(MAG//'.DIME','G V I',6,IADIME)
CCC SOMME POUR : 1 LE NB DE NOEUDS,
CCC              2       DE NOEUDS LAGRANGES,
CCC              3       DE MAILLES,
CCC              4       DE SUPER MAILLES
CCC              5       DU MAJORANT DE SUPER MAILLES
      DO 10,I=1,5
        ZI(IADIME-1+I)=ZI(IADIM1-1+I)+ZI(IADIM2-1+I)
 10   CONTINUE

      CALL DISMOI('F','Z_ZERO',MA1,'MAILLAGE',IBID,ZER1,IRET)
      CALL DISMOI('F','Z_ZERO',MA2,'MAILLAGE',IBID,ZER2,IRET)
      IF(ZER1.NE.ZER2) CALL U2MESS('F','MODELISA2_20')
C
      NCOOR=ZI(IADIM1-1+6)
      ZI(IADIME-1+6)=NCOOR
C
      NBMA=ZI(IADIME-1+3)
      NBM1=ZI(IADIM1-1+3)
      NBM2=ZI(IADIM2-1+3)
C
      NBNO=ZI(IADIME-1+1)
      NBN1=ZI(IADIM1-1+1)
      NBN2=ZI(IADIM2-1+1)
C
C     --OBJET .NOMMAI:
C     ----------------
      IF (NBMA.GT.0) THEN
        CALL JECREO(MAG//'.NOMMAI','G N K8')
        CALL JEECRA(MAG//'.NOMMAI','NOMMAX',NBMA,KBID)
        DO 21,I=1,NBM1
          CALL CODENT(I,'G',KIND)
          NOMA='M'//KIND
          CALL JECROC(JEXNOM(MAG//'.NOMMAI',NOMA))
 21     CONTINUE
        DO 22,I=1,NBM2
          CALL CODENT(NBM1+I,'G',KIND)
          NOMA='M'//KIND
          CALL JECROC(JEXNOM(MAG//'.NOMMAI',NOMA))
 22     CONTINUE
      END IF
C
C     --OBJET .NOMNOE:
C     ----------------
      IF (NBNO.GT.0) THEN
        CALL JECREO(MAG//'.NOMNOE','G N K8')
        CALL JEECRA(MAG//'.NOMNOE','NOMMAX',NBNO,KBID)
        DO 31,I=1,NBN1
          CALL CODENT(I,'G',KIND)
          NONO='N'//KIND
          CALL JECROC(JEXNOM(MAG//'.NOMNOE',NONO))
 31     CONTINUE
        DO 32,I=1,NBN2
          CALL CODENT(NBN1+I,'G',KIND)
          NONO='N'//KIND
          CALL JECROC(JEXNOM(MAG//'.NOMNOE',NONO))
 32     CONTINUE
      END IF
C
C
C     --OBJET .CONNEX:
C     -----------------
      IF (NBMA.GT.0) THEN
        CALL JECREC(MAG//'.CONNEX','G V I','NU'
     &            ,'CONTIG','VARIABLE',NBMA)
        L1=0
        L2=0
        IF (NBM1.GT.0) CALL JELIRA(MA1//'.CONNEX','LONT',L1,KBID)
        IF (NBM2.GT.0) CALL JELIRA(MA2//'.CONNEX','LONT',L2,KBID)
        L3= L1+L2
        CALL JEECRA(MAG//'.CONNEX','LONT',L3,KBID)
        DO 41,I=1,NBM1
          CALL JEVEUO(JEXNUM(MA1//'.CONNEX',I),'L',IACON1)
          CALL JELIRA(JEXNUM(MA1//'.CONNEX',I),'LONMAX',N,KBID)
          CALL JEECRA(JEXNUM(MAG//'.CONNEX',I),'LONMAX',N,KBID)
          CALL JEVEUO(JEXNUM(MAG//'.CONNEX',I),'E',IACONX)
          DO 411,II=1,N
            ZI(IACONX-1+II)=ZI(IACON1-1+II)
 411      CONTINUE
 41     CONTINUE
        DO 42,I=1,NBM2
          I1= I+NBM1
          CALL JEVEUO(JEXNUM(MA2//'.CONNEX',I),'L',IACON2)
          CALL JELIRA(JEXNUM(MA2//'.CONNEX',I),'LONMAX',N,KBID)
          CALL JEECRA(JEXNUM(MAG//'.CONNEX',I1),'LONMAX',N,KBID)
          CALL JEVEUO(JEXNUM(MAG//'.CONNEX',I1),'E',IACONX)
          DO 421,II=1,N
            ZI(IACONX-1+II)=ZI(IACON2-1+II)+NBN1
 421      CONTINUE
 42     CONTINUE
      END IF
C
C     -- CREATION DU CHAMP .COORDO :
C     ------------------------------
      COORDO= MAG//'.COORDO'
C
      CALL JENONU(JEXNOM('&CATA.GD.NOMGD','GEOM_R'),IGEOMR)
      CALL WKVECT(COORDO//'.DESC','G V I',3,IADESC)
      CALL JEECRA(COORDO//'.DESC','DOCU',IBID,'CHNO')
      ZI (IADESC-1+1)= IGEOMR
C     -- TOUJOURS 3 COMPOSANTES X, Y ET Z
      ZI (IADESC-1+2)= -3
C     -- 14 = 2**1 + 2**2 + 2**3
      ZI (IADESC-1+3)= 14
C
      CALL WKVECT(COORDO//'.REFE','G V K24',2,IAREFE)
      ZK24(IAREFE-1+1)= MAG
      CALL JEVEUO(MA1//'.COORDO    .VALE','L',IACOO1)
      CALL JEVEUO(MA2//'.COORDO    .VALE','L',IACOO2)
      CALL WKVECT(COORDO//'.VALE','G V R',3*NBNO,IAVALE)
C     -- COORDONNEES DES NOEUDS :
      DO 51 , INO=1, NBN1
        DO 511, K=1,3
          ZR(IAVALE-1+3*(INO-1)+K)=ZR(IACOO1-1+3*(INO-1)+K)
 511    CONTINUE
 51   CONTINUE
      DO 52 , INO=1, NBN2
        DO 521, K=1,3
          ZR(IAVALE-1+3*(NBN1+INO-1)+K)=ZR(IACOO2-1+3*(INO-1)+K)
 521    CONTINUE
 52   CONTINUE
C
C
C     --OBJET .TYPMAIL:
C     -----------------
      IF (NBMA.GT.0) THEN
        CALL WKVECT(MAG//'.TYPMAIL','G V I',NBMA,IBID)
        DO 61,I=1,NBM1
          CALL JEVEUO(MA1//'.TYPMAIL','L',IATYMA)
          IATYP1=IATYMA-1+I
          CALL JEVEUO(MAG//'.TYPMAIL','E',IATYMA)
          IATYPX=IATYMA-1+I
          ZI(IATYPX)=ZI(IATYP1)
 61     CONTINUE
        DO 62,I=1,NBM2
          I1=I+NBM1
          CALL JEVEUO(MA2//'.TYPMAIL','L',IATYMA)
          IATYP2=IATYMA-1+I
          CALL JEVEUO(MAG//'.TYPMAIL','E',IATYMA)
          IATYPX=IATYMA-1+I1
          ZI(IATYPX)=ZI(IATYP2)
 62     CONTINUE
      END IF
C
C
C     --OBJET .GROUPEMA:
C     -----------------
      CALL JEEXIN(MA1//'.GROUPEMA',IRET1)
      CALL JEEXIN(MA2//'.GROUPEMA',IRET2)
      NBGM1 = 0
      NBGM2 = 0
      IF (IRET1.GT.0) CALL JELIRA(MA1//'.GROUPEMA','NUTIOC',
     &                            NBGM1,KBID)
      IF (IRET2.GT.0) CALL JELIRA(MA2//'.GROUPEMA','NUTIOC',
     &                            NBGM2,KBID)
      NBGMA = NBGM1 + NBGM2
      IF ( NBGMA .GT. 0 ) THEN
        CALL JECREC(MAG//'.GROUPEMA','G V I','NO',
     &                               'DISPERSE','VARIABLE',NBGMA)
        DO 71,I=1,NBGM1
          CALL JEVEUO(JEXNUM(MA1//'.GROUPEMA',I),'L',IAGMA1)
          CALL JELIRA(JEXNUM(MA1//'.GROUPEMA',I),'LONMAX',N,KBID)
          CALL JENUNO(JEXNUM(MA1//'.GROUPEMA',I),NOGMA)
          CALL JECROC(JEXNOM(MAG//'.GROUPEMA',NOGMA))
          CALL JEECRA(JEXNUM(MAG//'.GROUPEMA',I),'LONMAX',N,KBID)
          CALL JEVEUO(JEXNUM(MAG//'.GROUPEMA',I),'E',IAGMAX)
          DO 711, II=1,N
            ZI(IAGMAX-1+II)=ZI(IAGMA1-1+II)
 711      CONTINUE
 71     CONTINUE
        ICOMPT = 0
        DO 72,I=1,NBGM2
          CALL JEVEUO(JEXNUM(MA2//'.GROUPEMA',I),'L',IAGMA2)
          CALL JELIRA(JEXNUM(MA2//'.GROUPEMA',I),'LONMAX',N,KBID)
          CALL JENUNO(JEXNUM(MA2//'.GROUPEMA',I),NOGMA)
          CALL JEEXIN(JEXNOM(MAG//'.GROUPEMA',NOGMA),IRET)
          IF (IRET.GT.0) THEN
            CALL U2MESK('A','MODELISA2_21',1,NOGMA)
            NOGMAB=NOGMA
            II = LXLGUT(NOGMAB(1:7))
            DO 724,K=II+1,7
               NOGMAB(K:K)='_'
 724        CONTINUE
            DO 722,K=0,9
               CALL CODENT(K,'G',KKK)
               NOGMAB(8:8)=KKK
               CALL JEEXIN(JEXNOM(MAG//'.GROUPEMA',NOGMAB),IRET)
               IF (IRET.EQ.0) GOTO 723
 722        CONTINUE
 723        CONTINUE
            WRITE (IFM,*) ' LE GROUP_MA '//NOGMA//' DU MAILLAGE '
     &           //MA2//' EST RENOMME '//NOGMAB//' DANS '//MAG
            NOGMA=NOGMAB
          END IF
          ICOMPT = ICOMPT + 1
          I1 = NBGM1 + ICOMPT
          CALL JECROC(JEXNOM(MAG//'.GROUPEMA',NOGMA))
          CALL JEECRA(JEXNUM(MAG//'.GROUPEMA',I1),'LONMAX',N,KBID)
          CALL JEVEUO(JEXNUM(MAG//'.GROUPEMA',I1),'E',IAGMAX)
          DO 721, II=1,N
            ZI(IAGMAX-1+II)=ZI(IAGMA2-1+II)+NBM1
 721      CONTINUE
 72     CONTINUE
      END IF
C
C
C     --OBJET .GROUPENO:
C     -----------------
      CALL JEEXIN(MA1//'.GROUPENO',IRET1)
      CALL JEEXIN(MA2//'.GROUPENO',IRET2)
      NBGN1 = 0
      NBGN2 = 0
      IF (IRET1.GT.0) CALL JELIRA(MA1//'.GROUPENO','NUTIOC',
     &                            NBGN1,KBID)
      IF (IRET2.GT.0) CALL JELIRA(MA2//'.GROUPENO','NUTIOC',
     &                            NBGN2,KBID)
      NBGNO = NBGN1 + NBGN2
      IF ( NBGNO .GT. 0 ) THEN
        CALL JECREC(MAG//'.GROUPENO','G V I','NO',
     &                               'DISPERSE','VARIABLE',NBGNO)
        DO 81,I=1,NBGN1
          CALL JEVEUO(JEXNUM(MA1//'.GROUPENO',I),'L',IAGNO1)
          CALL JELIRA(JEXNUM(MA1//'.GROUPENO',I),'LONMAX',N,KBID)
          CALL JENUNO(JEXNUM(MA1//'.GROUPENO',I),NOGMA)
          CALL JECROC(JEXNOM(MAG//'.GROUPENO',NOGMA))
          CALL JEECRA(JEXNUM(MAG//'.GROUPENO',I),'LONMAX',N,KBID)
          CALL JEVEUO(JEXNUM(MAG//'.GROUPENO',I),'E',IAGNOX)
          DO 811, II=1,N
            ZI(IAGNOX-1+II)=ZI(IAGNO1-1+II)
 811      CONTINUE
 81     CONTINUE
        ICOMPT = 0
        DO 82,I=1,NBGN2
          CALL JEVEUO(JEXNUM(MA2//'.GROUPENO',I),'L',IAGNO2)
          CALL JELIRA(JEXNUM(MA2//'.GROUPENO',I),'LONMAX',N,KBID)
          CALL JENUNO(JEXNUM(MA2//'.GROUPENO',I),NOGNO)
          CALL JEEXIN(JEXNOM(MAG//'.GROUPENO',NOGNO),IRET)
          IF (IRET.GT.0) THEN
            CALL U2MESK('A','MODELISA2_22',1,NOGNO)
            NOGNOB=NOGNO
            II = LXLGUT(NOGNOB(1:7))
            DO 824,K=II+1,7
               NOGNOB(K:K)='_'
 824        CONTINUE
            DO 822,K=0,9
               CALL CODENT(K,'G',KKK)
               NOGNOB(8:8)=KKK
               CALL JEEXIN(JEXNOM(MAG//'.GROUPENO',NOGNOB),IRET)
               IF (IRET.EQ.0) GOTO 823
 822        CONTINUE
 823        CONTINUE
            WRITE (IFM,*) ' LE GROUP_NO '//NOGNO//' DU MAILLAGE '
     &           //MA2//' EST RENOMME '//NOGNOB//' DANS '//MAG
            NOGNO=NOGNOB
          END IF
          ICOMPT = ICOMPT + 1
          I1 = NBGN1 + ICOMPT
          CALL JECROC(JEXNOM(MAG//'.GROUPENO',NOGNO))
          CALL JEECRA(JEXNUM(MAG//'.GROUPENO',I1),'LONMAX',N,KBID)
          CALL JEVEUO(JEXNUM(MAG//'.GROUPENO',I1),'E',IAGNOX)
          DO 821, II=1,N
            ZI(IAGNOX-1+II)=ZI(IAGNO2-1+II)+NBN1
 821      CONTINUE
 82     CONTINUE
      END IF
C
      CALL JEDEMA()
      END
