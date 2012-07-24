      SUBROUTINE OP0172()
      IMPLICIT NONE
C     ------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF PREPOST  DATE 24/07/2012   AUTEUR PELLET J.PELLET 
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
C     ------------------------------------------------------------------
      INCLUDE 'jeveux.h'
C
      INTEGER       IBID, APRNO, IDDL, NCMP, NEC, IERD, GD, NBMODE
      INTEGER       VALI
      REAL*8        R8B, ZERO, RIGI(6), AMOSOL, SEUIL, AMOMO, POUCEN
      REAL*8        VALRR(2)
      REAL*8        A(3),B(3),C(3),VALR(6),R8PI
      COMPLEX*16    C16B
      CHARACTER*3   REP
      CHARACTER*16  METHOD
      CHARACTER*8   NOMNOE, NOMGR
      CHARACTER*8   K8B, RESU, MECA, MASSE, NOMA, AMOGEO(6), CTYPE
      CHARACTER*14  NUME
      CHARACTER*16  CONCEP, NOMCMD, VALEK(2)
      CHARACTER*19  ENERPO
      CHARACTER*24  NPRNO, REFD, DEEQ, NOMCH1, NOMOB1, NOMOB2
      CHARACTER*24  MAGRNO, MANONO, MAGRMA, MANOMA
      INTEGER      IARG
C     ------------------------------------------------------------------
C-----------------------------------------------------------------------
      INTEGER I ,IADMO1 ,IAMOMO ,IC ,IDAM ,IDDEEQ ,IDEPMO
      INTEGER IDGA ,IDGM ,IDGN ,IDN2 ,IDNO ,IENEMO ,IENMOT
      INTEGER IFR ,II ,IJ ,IM ,IMOD ,IN ,INO
      INTEGER INOE ,IRE ,IRET ,IRIGNO ,IUNIFI ,JBOR ,JCOOR
      INTEGER JFREQ ,JNBP ,JNUME ,JNUOR ,JPAS ,JREFD ,JVAL
      INTEGER LDGM ,LDGN ,LDNM ,NB ,NBA ,NBB ,NBEC
      INTEGER NBEN ,NBG ,NBGA ,NBGR ,NBMD ,NBMOD2 ,NBNO
      INTEGER NBNOEU ,NBOCC ,NBS ,NBV ,NBVALE ,NCG ,NCO
      INTEGER NCOMPO ,NEQ ,NGN ,NK ,NKR ,NM ,NMM
      INTEGER NMT ,NN ,NNO ,NRP
      REAL*8 ALFA ,AMOGE ,BETA ,ENESOL ,F ,OMEGA ,PI
      REAL*8 R8PREM ,XG ,YG ,ZG ,ZRIG
C-----------------------------------------------------------------------
      DATA  REFD  /'                   .REFD'/
C     ------------------------------------------------------------------
C
      CALL JEMARQ()
      CALL INFMAJ()
      CALL GETRES( RESU , CONCEP , NOMCMD )
      ZERO = 0.D0
      IFR = IUNIFI('RESULTAT')
      CALL GETFAC('ENER_SOL',NBOCC)
      IF (NBOCC.EQ.0) GOTO 9998
C
C     --- ON RECUPERE LES RAIDEURS ---
C
      CALL GETVR8 ( 'ENER_SOL', 'KX' ,1,IARG,1, RIGI(1),NK)
      CALL GETVR8 ( 'ENER_SOL', 'KY' ,1,IARG,1, RIGI(2),NK)
      CALL GETVR8 ( 'ENER_SOL', 'KZ' ,1,IARG,1, RIGI(3),NK)
      CALL GETVR8 ( 'ENER_SOL', 'KRX',1,IARG,0, R8B    ,NK)
      IF ( NK .NE. 0 ) THEN
         CALL GETVR8 ( 'ENER_SOL', 'KRX', 1,IARG,1, RIGI(4),NKR)
         CALL GETVR8 ( 'ENER_SOL', 'KRY', 1,IARG,1, RIGI(5),NKR)
         CALL GETVR8 ( 'ENER_SOL', 'KRZ', 1,IARG,1, RIGI(6),NKR)
         NCOMPO = 6
      ELSE
         NCOMPO = 3
      ENDIF
C
C     ----- RECUPERATION DES MODES -----
C
      CALL GETVID( 'ENER_SOL','MODE_MECA',1,IARG,1,MECA,NMM)
      REFD(1:8) = MECA
      CALL JEVEUO(REFD,'L',JREFD)
      MASSE = ZK24(JREFD+1)
C
C     --- ON RECUPERE LA TABLE D'ENERGIE ---
C
      CALL GETVID( 'AMOR_INTERNE','ENER_POT',1,IARG,1,ENERPO,NBEN)
C
C     --- VERIFICATION DES PARAMETRES DE LA TABLE 'ENERPO'
      CALL TBEXP2(ENERPO,'NUME_ORDRE')
      CALL TBEXP2(ENERPO,'FREQ')
      CALL TBEXP2(ENERPO,'LIEU')
      CALL TBEXP2(ENERPO,'POUR_CENT')
C
C     --- ON RECUPERE FREQ ET NUME_ORDRE DE LA TABLE ---
C
      NOMOB2 = '&&OP0172.NUME'
      CALL TBEXVE ( ENERPO, 'NUME_ORDRE', NOMOB2, 'V', NBMOD2, K8B )
      IF ( NBMOD2 .EQ. 0 ) CALL U2MESS('F','MODELISA2_89')
      CALL JEVEUO ( NOMOB2, 'L', JNUOR )
      CALL ORDIS  ( ZI(JNUOR) , NBMOD2 )
C     --- ON ELIMINE LES DOUBLONS ---
      CALL WKVECT ( '&&OP0172.NUME_2', 'V V I', NBMOD2, JNUME )
      NBMODE = 1
      ZI(JNUME) = ZI(JNUOR)
      DO 10 I = 2 , NBMOD2
         IF ( ZI(JNUOR+I-1) .EQ. ZI(JNUME+NBMODE-1) ) GOTO 10
         NBMODE = NBMODE + 1
         ZI(JNUME+NBMODE-1) = ZI(JNUOR+I-1)
 10   CONTINUE
C
      NOMOB1 = '&&OP0172.FREQ'
      CALL WKVECT ( NOMOB1, 'V V R', NBMODE, JFREQ )
      DO 12 I = 1 , NBMODE
         CALL TBLIVA ( ENERPO, 1, 'NUME_ORDRE', ZI(JNUME+I-1), R8B,
     &                 C16B, K8B, K8B, R8B, 'FREQ',
     &                 CTYPE, IBID, ZR(JFREQ+I-1), C16B, K8B, IRET )
         IF ( IRET .EQ. 0 ) THEN
         ELSEIF ( IRET .EQ. 3 ) THEN
         ELSE
            CALL U2MESS('F','PREPOST4_18')
         ENDIF
 12   CONTINUE
C
C
C--------RECUPERATION DU NOMBRE D'EQUATIONS DU SYSTEME PHYSIQUE
C
      CALL DISMOI('F','NOM_NUME_DDL',MASSE,'MATR_ASSE',IBID  ,NUME,IERD)
      CALL DISMOI('F','NB_EQUA'     ,MASSE,'MATR_ASSE',NEQ   ,K8B ,IERD)
      CALL DISMOI('F','NOM_MAILLA'  ,MASSE,'MATR_ASSE',IBID  ,NOMA,IERD)
      CALL DISMOI('F','NB_NO_MAILLA',NOMA ,'MAILLAGE' ,NBNOEU,K8B ,IERD)
      CALL DISMOI('F','NUM_GD_SI'   ,NUME ,'NUME_DDL' ,GD    ,K8B ,IERD)
      DEEQ = NUME//'.NUME.DEEQ'
      CALL JEVEUO ( DEEQ, 'L', IDDEEQ )
C
C     --- ECRITURE DESCRIPTION NOEUDS STRUCTURE ---
      CALL JEVEUO ( NOMA//'.COORDO    .VALE', 'L', JCOOR )
      NPRNO = NUME//'.NUME.PRNO'
      CALL JENONU ( JEXNOM(NPRNO(1:19)//'.LILI','&MAILLA'),IBID)
      CALL JEVEUO ( JEXNUM(NPRNO,IBID), 'L', APRNO )
      NEC = NBEC( GD )
      CALL WKVECT('&&OP0172.DEPMOD','V V R',NCOMPO*NBMODE,IDEPMO)
      CALL WKVECT('&&OP0172.ENEMOD','V V R',NCOMPO*NBMODE,IENEMO)
      CALL WKVECT('&&OP0172.ENMOTO','V V R',NBMODE,IENMOT)
      CALL WKVECT('&&OP0172.RIGNOE','V V R',6*NBNOEU,IRIGNO)
C
      CALL GETVTX ( 'ENER_SOL', 'METHODE', 1,IARG,1, METHOD, NMT )
C
C       RECUPERATION DU CENTRE
C
      XG = ZERO
      YG = ZERO
      ZG = ZERO
      MAGRNO = NOMA//'.GROUPENO'
      MANONO = NOMA//'.NOMNOE'
      MAGRMA = NOMA//'.GROUPEMA'
      MANOMA = NOMA//'.CONNEX'
      IF (METHOD.NE.'DEPL') GOTO 111
C
C
C     --- ON RECUPERE LES POINTS D'ANCRAGE ---
C
C
C        --- ON RECUPERE UNE LISTE DE GROUP_NO ---
      CALL GETVEM(NOMA,'GROUP_NO', 'ENER_SOL','GROUP_NO_RADIER',
     &                   1,IARG,0,K8B,NBGR)
      IF ( NBGR.EQ.0 ) GOTO 114
      NBGR = -NBGR
      CALL WKVECT ( '&&OP0172.GROUP_NO', 'V V K8', NBGR, IDGN )
      CALL GETVEM(NOMA,'GROUP_NO','ENER_SOL','GROUP_NO_RADIER',
     &                  1,IARG,NBGR,ZK8(IDGN),NBV)
C
C        --- ON ECLATE LE GROUP_NO EN NOEUDS ---
      CALL COMPNO ( NOMA, NBGR, ZK8(IDGN), NBNO )
      CALL WKVECT ( '&&OP0172.NOEUD', 'V V I', NBNO, IDNO )
      II = -1
      DO 20 I = 1,NBGR
         CALL JELIRA(JEXNOM(MAGRNO,ZK8(IDGN+I-1)),'LONUTI',NB,K8B)
         CALL JEVEUO(JEXNOM(MAGRNO,ZK8(IDGN+I-1)),'L',LDGN)
         DO 22 IN = 0, NB-1
            II = II + 1
            ZI(IDNO+II) = ZI(LDGN+IN)
 22      CONTINUE
 20   CONTINUE
      GOTO 111
 114  CONTINUE
      CALL GETVEM(NOMA,'GROUP_MA', 'ENER_SOL','GROUP_MA_RADIER',
     &                   1,IARG,0,K8B,NBGR)
      IF ( NBGR.EQ.0 )
     & CALL U2MESS('F','PREPOST4_19')
      NBGR = -NBGR
      CALL WKVECT ( '&&OP0172.GROUP_MA', 'V V K8', NBGR, IDGM )
      CALL WKVECT ( '&&OP0172.NOEUD', 'V V I', NBNOEU, IDNO )
      CALL WKVECT ( '&&OP0172.PARNO','V V I',NBNOEU,IDN2)
      CALL GETVEM(NOMA,'GROUP_MA','ENER_SOL','GROUP_MA_RADIER',
     &                  1,IARG,NBGR,ZK8(IDGM),NBV)
      DO 21 I = 1,NBGR
         CALL JELIRA(JEXNOM(MAGRMA,ZK8(IDGM+I-1)),'LONUTI',NB,K8B)
         CALL JEVEUO(JEXNOM(MAGRMA,ZK8(IDGM+I-1)),'L',LDGM)
         DO 23 IN = 0,NB-1
           CALL JELIRA(JEXNUM(MANOMA,ZI(LDGM+IN)),'LONMAX',NM,K8B)
           CALL JEVEUO(JEXNUM(MANOMA,ZI(LDGM+IN)),'L',LDNM)
           DO 24 NN = 1, NM
              INOE = ZI(LDNM+NN-1)
              ZI(IDN2+INOE-1) = ZI(IDN2+INOE-1) + 1
 24        CONTINUE
 23      CONTINUE
 21   CONTINUE
      II = 0
      DO 25 IJ = 1, NBNOEU
         IF (ZI(IDN2+IJ-1).EQ.0) GOTO 25
         II = II + 1
         ZI(IDNO+II-1) = IJ
 25   CONTINUE
      NBNO = II
      CALL JEDETR ( '&&OP0172.GROUP_MA'  )
 111  CONTINUE
      IF (METHOD.NE.'RIGI_PARASOL') GOTO 112
      ZRIG = MIN(ABS(RIGI(1)),ABS(RIGI(2)))
      ZRIG = MIN(ZRIG,ABS(RIGI(3)))
      IF ( ZRIG.LE.R8PREM( ) )
     & CALL U2MESS('F','PREPOST4_20')
      CALL GETVEM(NOMA,'GROUP_MA', 'ENER_SOL','GROUP_MA_RADIER',
     &                   1,IARG,0,K8B,NBGR)
      IF ( NBGR.EQ.0 )
     & CALL U2MESS('F','PREPOST4_19')
      NBGR = -NBGR
      CALL WKVECT ( '&&OP0172.GROUP_MA', 'V V K8', NBGR, IDGM )
      CALL WKVECT ( '&&OP0172.NOEUD', 'V V I', NBNOEU, IDNO )
      CALL GETVEM(NOMA,'GROUP_MA','ENER_SOL','GROUP_MA_RADIER',
     &                  1,IARG,NBGR,ZK8(IDGM),NBV)
      CALL RAIRE2(NOMA,RIGI,NBGR,ZK8(IDGM),NBNOEU,NBNO,ZI(IDNO),
     &            ZR(IRIGNO))
 112  CONTINUE
      IF (METHOD.NE.'RIGI_PARASOL'.OR.NCOMPO.NE.6) GOTO 113
      ZRIG = MIN(ABS(RIGI(4)),ABS(RIGI(5)))
      ZRIG = MIN(ZRIG,ABS(RIGI(6)))
      IF ( ZRIG.LE.R8PREM( ) )
     & CALL U2MESS('F','PREPOST4_21')
      CALL GETVR8('ENER_SOL','COOR_CENTRE',1,IARG,0,R8B,NCG)
      CALL GETVEM(NOMA,'NOEUD','ENER_SOL','NOEUD_CENTRE',
     &               1,IARG,0,K8B,NNO)
      CALL GETVEM(NOMA,'GROUP_NO','ENER_SOL','GROUP_NO_CENTRE',
     &                  1,IARG,0,K8B,NGN)
      IF (NCG.NE.0) THEN
        CALL GETVR8('ENER_SOL','COOR_CENTRE',1,IARG,3,C,NCG)
        XG = C(1)
        YG = C(2)
        ZG = C(3)
      ELSEIF (NNO.NE.0) THEN
        CALL GETVEM(NOMA,'NOEUD','ENER_SOL','NOEUD_CENTRE',
     &                 1,IARG,1,NOMNOE,NNO)
        CALL JENONU(JEXNOM(MANONO,NOMNOE),INOE)
        XG = ZR(JCOOR+3*(INOE-1)+1-1)
        YG = ZR(JCOOR+3*(INOE-1)+2-1)
        ZG = ZR(JCOOR+3*(INOE-1)+3-1)
      ELSEIF (NGN.NE.0) THEN
        CALL GETVEM(NOMA,'GROUP_NO','ENER_SOL','GROUP_NO_CENTRE',
     &                    1,IARG,1,NOMGR,NGN)
        CALL JEVEUO(JEXNOM(MAGRNO,NOMGR),'L',LDGN)
        INOE = ZI(LDGN)
C        CALL JENUNO(JEXNUM(MANONO,INOE),NOMNOE)
        XG = ZR(JCOOR+3*(INOE-1)+1-1)
        YG = ZR(JCOOR+3*(INOE-1)+2-1)
        ZG = ZR(JCOOR+3*(INOE-1)+3-1)
      ENDIF
C
 113  CONTINUE
C
      DO 51 I = 1 , NBMODE
        IF (METHOD.EQ.'DEPL') THEN
         CALL RSEXCH('F',MECA, 'DEPL', ZI(JNUME+I-1), NOMCH1, IRET )
         NOMCH1 = NOMCH1(1:19)//'.VALE'
         CALL JEVEUO ( NOMCH1, 'L', IADMO1 )
         DO 52 INO = 1 , NBNO
            INOE = ZI(IDNO+INO-1)
            IDDL = ZI( APRNO + (NEC+2)*(INOE-1) + 1 - 1 ) - 1
            NCMP = ZI( APRNO + (NEC+2)*(INOE-1) + 2 - 1 )
            IF (NCMP.NE.NCOMPO) THEN
               CALL U2MESS('F','PREPOST4_22')
            ENDIF
            DO 53 IC = 1,NCMP
               ZR(IDEPMO+(IC-1)*NBMODE+I-1) =
     &               ZR(IDEPMO+(IC-1)*NBMODE+I-1) + ZR(IADMO1+IDDL+IC-1)
 53         CONTINUE
 52      CONTINUE
        ELSEIF (METHOD.EQ.'RIGI_PARASOL') THEN
         CALL RSEXCH('F',MECA,'DEPL',ZI(JNUME+I-1),NOMCH1,IRET )
         NOMCH1 = NOMCH1(1:19)//'.VALE'
         CALL JEVEUO ( NOMCH1, 'L', IADMO1 )
         DO 72 INO = 1 , NBNO
            INOE = ZI(IDNO+INO-1)
C            CALL JENUNO(JEXNUM(MANONO,INOE),NOMNOE)
            IDDL = ZI( APRNO + (NEC+2)*(INOE-1) + 1 - 1 ) - 1
            NCMP = ZI( APRNO + (NEC+2)*(INOE-1) + 2 - 1 )
            IF (NCMP.NE.NCOMPO) THEN
               CALL U2MESS('F','PREPOST4_22')
            ENDIF
            DO 73 IC = 1,NCMP
              VALR(IC) = ZR(IADMO1+IDDL+IC-1)*ZR(IRIGNO+6*(INO-1)+IC-1)
              ZR(IDEPMO+(IC-1)*NBMODE+I-1) =
     &              ZR(IDEPMO+(IC-1)*NBMODE+I-1) + VALR(IC)
 73         CONTINUE
            A(1) = ZR(JCOOR+3*(INOE-1)+1-1) - XG
            A(2) = ZR(JCOOR+3*(INOE-1)+2-1) - YG
            A(3) = ZR(JCOOR+3*(INOE-1)+3-1) - ZG
            DO 74 IC = 1,3
               B(IC) = VALR(IC)
 74         CONTINUE
            CALL PROVEC(A,B,C)
            DO 75 IC = 4,NCMP
               ZR(IDEPMO+(IC-1)*NBMODE+I-1) =
     &               ZR(IDEPMO+(IC-1)*NBMODE+I-1) + C(IC-3)
 75         CONTINUE
 72      CONTINUE
        ENDIF
 51   CONTINUE
C
      IF ( NCMP .EQ. 6 ) WRITE(IFR,1000)
      IF ( NCMP .EQ. 3 ) WRITE(IFR,2000)
      DO 54 I = 1,NBMODE
        IF (METHOD.EQ.'DEPL') THEN
         DO 55 IC = 1,NCMP
            ZR(IDEPMO+(IC-1)*NBMODE+I-1) =
     &                              ZR(IDEPMO+(IC-1)*NBMODE+I-1)/NBNO
            ZR(IENEMO+(IC-1)*NBMODE+I-1) = 0.5D0*
     &                        RIGI(IC)*ZR(IDEPMO+(IC-1)*NBMODE+I-1)**2
            ZR(IENMOT+I-1) =
     &                   ZR(IENEMO+(IC-1)*NBMODE+I-1) + ZR(IENMOT+I-1)
 55      CONTINUE
        ELSEIF (METHOD.EQ.'RIGI_PARASOL') THEN
         DO 76 IC = 1,NCMP
            ZR(IENEMO+(IC-1)*NBMODE+I-1) = 0.5D0*
     &                        ZR(IDEPMO+(IC-1)*NBMODE+I-1)**2/RIGI(IC)
            ZR(IENMOT+I-1) =
     &                   ZR(IENEMO+(IC-1)*NBMODE+I-1) + ZR(IENMOT+I-1)
 76      CONTINUE
        ENDIF
        F = ZR(JFREQ+I-1)
        WRITE(IFR,1001) F,(ZR(IENEMO+(IC-1)*NBMODE+I-1),IC=1,NCMP),
     &                                 ZR(IENMOT+I-1)
 54   CONTINUE
C
C        --- ON RECUPERE LES SOUS_STRUC ET LEURS AMOR ---
C
      CALL GETVEM(NOMA,'GROUP_MA', 'AMOR_INTERNE','GROUP_MA',
     &                1,IARG,0,K8B,NBGA)
      NBGA= -NBGA
      CALL WKVECT ('&&OP0172.GAMOR','V V K8',NBGA,IDGA)
      CALL GETVEM(NOMA,'GROUP_MA','AMOR_INTERNE','GROUP_MA',
     &               1,IARG,NBGA,ZK8(IDGA),NBG)
      CALL WKVECT ('&&OP0172.AMINT','V V R',NBGA,IDAM)
      CALL GETVR8 ( 'AMOR_INTERNE', 'AMOR_REDUIT', 1,IARG,0, R8B, NBA )
      NBA = -NBA
      IF ( NBGA .NE. NBA ) CALL U2MESS('F','PREPOST4_23')
C
      CALL GETVR8 ('AMOR_INTERNE','AMOR_REDUIT',1,IARG,NBGA,
     &             ZR(IDAM),NBA)
      CALL GETVR8 ('AMOR_SOL','AMOR_REDUIT'  ,1,IARG,1,AMOSOL,NBA)
      CALL GETVR8 ('AMOR_SOL','SEUIL'        ,1,IARG,1,SEUIL ,NBS)
      CALL GETVID('AMOR_SOL','FONC_AMOR_GEO',1,IARG,0,K8B,NCO)
      NCO = -NCO
      IF (NCMP.NE.NCO)  CALL U2MESS('F','PREPOST4_24')
      CALL GETVID('AMOR_SOL','FONC_AMOR_GEO',1,IARG,NCMP,AMOGEO,NBA)
      CALL GETVTX ('AMOR_SOL','HOMOGENE'     ,1,IARG,1   ,REP   ,NRP)
C
      CALL WKVECT('&&OP0172.AMOMOD','V V R',NBMODE,IAMOMO)
C
      VALEK(1) = 'NUME_ORDRE'
      DO 60 IMOD = 1,NBMODE
C
         IM = ZI(JNUME+IMOD-1)
         F = ZR(JFREQ+IMOD-1)
         ENESOL = ZERO
C
         DO 61 I = 1 , NBGA
C
            VALEK(2) = 'LIEU'
            CALL TBLIVA (ENERPO, 2, VALEK, IM, R8B, C16B, ZK8(IDGA+I-1),
     &                   'RELA', 1.D-03, 'POUR_CENT',
     &                           K8B, IBID, POUCEN , C16B, K8B, IRET )
            IF (IRET.GE.2) CALL U2MESK('A','STBTRIAS_6',1,ZK8(IDGA+I-1))
C
            ZR(IAMOMO+IMOD-1) = ZR(IAMOMO+IMOD-1) +
     &                          1.0D-2*POUCEN*ZR(IDAM+I-1)
            ENESOL = ENESOL + POUCEN
 61      CONTINUE
C
         ENESOL = 1.D0 - 1.0D-2*ENESOL
C
         ZR(IAMOMO+IMOD-1) = ZR(IAMOMO+IMOD-1) + AMOSOL*ENESOL
C
         DO 62 IC = 1,NCMP
            CALL FOINTE ( 'F ', AMOGEO(IC), 1, 'FREQ', F, AMOGE, IRE )
            IF ( REP .EQ. 'OUI' ) AMOGE = AMOGE / 2.D0
            IF ( ABS(ZR(IENMOT+IMOD-1)).GT.R8PREM( ) )
     &       ZR(IAMOMO+IMOD-1) = ZR(IAMOMO+IMOD-1) +
     &       AMOGE*ZR(IENEMO+(IC-1)*NBMODE+IMOD-1)
     &                                   *ENESOL/ZR(IENMOT+IMOD-1)
 62      CONTINUE
C
         AMOMO = ZR(IAMOMO+IMOD-1)
         IF ( AMOMO .GT. SEUIL ) THEN
            ZR(IAMOMO+IMOD-1) = SEUIL
            VALRR (1) = AMOMO
            VALRR (2) = SEUIL
            VALI = IMOD
            CALL U2MESG('I', 'PREPOST5_64',0,' ',1,VALI,2,VALRR)
         ENDIF
 60   CONTINUE
C
      WRITE(IFR,1002)
      DO 64 IMOD = 1,NBMODE
         WRITE(IFR,1003) IMOD, ZR(JFREQ+IMOD-1), ZR(IAMOMO+IMOD-1)
 64   CONTINUE
C
      GOTO 9999
 9998 CONTINUE
      NBMODE = 0
      PI = R8PI()
C
C --- MATRICE DES MODES MECA
C
      CALL GETVID('AMOR_RAYLEIGH','MODE_MECA',1,IARG,1,MECA,NBMD)
      CALL GETVR8('AMOR_RAYLEIGH','AMOR_ALPHA',1,IARG,1,ALFA,NBA)
      CALL GETVR8('AMOR_RAYLEIGH','AMOR_BETA',1,IARG,1,BETA,NBB)
      CALL MGINFO(MECA,NUME,NBMODE,NEQ)
      CALL WKVECT('&&OP0172.AMOMOD','V V R',NBMODE,IAMOMO)
      WRITE(IFR,1002)
      DO 11 IMOD = 1,NBMODE
         CALL RSADPA(MECA,'L',1,'FREQ',IMOD,0,JFREQ,K8B)
         OMEGA=2.D0*PI*ZR(JFREQ)
         ZR(IAMOMO+IMOD-1) = 0.5D0*(ALFA*OMEGA+BETA/OMEGA)
         WRITE(IFR,1003) IMOD, ZR(JFREQ), ZR(IAMOMO+IMOD-1)
 11   CONTINUE
 9999 CONTINUE
      NBVALE = NBMODE
      IF ( NBVALE .GT. 1 ) THEN
         CALL WKVECT(RESU//'           .LPAS','G V R',NBVALE-1,JPAS)
         CALL WKVECT(RESU//'           .NBPA','G V I',NBVALE-1,JNBP)
         CALL WKVECT(RESU//'           .BINT','G V R',NBVALE,JBOR)
         CALL WKVECT(RESU//'           .VALE','G V R',NBVALE,JVAL)
         DO 70 I = 1,NBVALE-1
            ZR(JPAS+I-1) = ZR(IAMOMO+I) - ZR(IAMOMO+I-1)
            ZI(JNBP+I-1) = 1
            ZR(JBOR+I-1) = ZR(IAMOMO+I-1)
            ZR(JVAL+I-1) = ZR(IAMOMO+I-1)
 70      CONTINUE
         ZR(JBOR+NBVALE-1) = ZR(IAMOMO+NBVALE-1)
         ZR(JVAL+NBVALE-1) = ZR(IAMOMO+NBVALE-1)
      ELSE
C
         CALL WKVECT(RESU//'           .LPAS','G V R',1,JPAS)
         CALL WKVECT(RESU//'           .NBPA','G V I',1,JNBP)
         CALL WKVECT(RESU//'           .BINT','G V R',1,JBOR)
         CALL WKVECT(RESU//'           .VALE','G V R',1,JVAL)
         ZR(JPAS) = 0.D0
         ZI(JNBP) = 1
         ZR(JBOR) = ZR(IAMOMO)
         ZR(JVAL) = ZR(IAMOMO)
      ENDIF
C
C
 1000 FORMAT(4X,'FREQUENCE',10X,'ETX',10X,'ETY',10X,'ETZ',10X,'ERX'
     & ,10X,'ERY',10X,'ERZ',6X,'ETOTALE')
 2000 FORMAT(4X,'FREQUENCE',10X,'ETX',10X,'ETY',10X,'ETZ',
     & 6X,'ETOTALE')
 1001 FORMAT(8(1X,1PE12.5))
 1002 FORMAT(2X,'MODE',4X,'FREQUENCE',9X,'AMOR')
 1003 FORMAT(1X,I5,2(1X,1PE12.5))
C
      CALL JEDEMA()
C
      END
