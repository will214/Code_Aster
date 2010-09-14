      SUBROUTINE IRMGMS(IFC,NDIM,NNO,NOMA,NBGRM,NONOE,LGMSH,VERSIO)
      IMPLICIT REAL*8 (A-H,O-Z)
C
      CHARACTER*8  NOMA,NONOE(*)
      INTEGER      IFC,VERSIO
      LOGICAL      LGMSH
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF PREPOST  DATE 14/09/2010   AUTEUR REZETTE C.REZETTE 
C ======================================================================
C COPYRIGHT (C) 1991 - 2002  EDF R&D                  WWW.CODE-ASTER.ORG
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
C     BUT :   ECRITURE DU MAILLAGE AU FORMAT GMSH
C     ENTREE:
C       IFC    : NUMERO D'UNITE LOGIQUE DU FICHIER GMSH
C       NDIM   : DIMENSION DU PROBLEME (2  OU 3)
C       NNO    : NOMBRE DE NOEUDS DU MAILLAGE
C       NOMA   : NOM DU MAILLAGE
C       NBGRM  : NOMBRE DE GROUPES DE MAILLES
C       NONOE  : NOM DES NOEUDS
C       LGMSH  : VRAI SI MAILLAGE PRODUIT PAR PRE_GMSH (DANS CE CAS,
C                ON CONSERVE LES NUMEROS DE NOEUDS ET DE MAILLES)
C       VERSIO :  =1 SI ON NE PREND QUE DES MAILLES TRI3 ET TET4
C                 =2 SI ON PREND TOUTES LES MAILLES LINEAIRES
C
C     ----------- COMMUNS NORMALISES  JEVEUX  --------------------------
      COMMON /IVARJE/ZI(1)
      COMMON /RVARJE/ZR(1)
      COMMON /CVARJE/ZC(1)
      COMMON /LVARJE/ZL(1)
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
      INTEGER ZI
      REAL*8 ZR
      COMPLEX*16 ZC
      LOGICAL ZL
      CHARACTER*8  ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32,JEXNUM,JEXNOM,JEXATR
      CHARACTER*80 ZK80
C     ------------------------------------------------------------------
C ---------------------------------------------------------------------
C
      INTEGER      NUTYGM
      REAL*8       ZERO
      CHARACTER*8  NOMAOU, K8BID, NOMTYP, NOMGRM
      CHARACTER*8  K8NNO, K8NBMA
      CHARACTER*24 TYPMAI, NOMMAI, NOMAIL, VALK
      INTEGER      TYPPOI, TYPSEG, TYPTRI, TYPTET, TYPQUA,
     +             TYPPYR, TYPPRI, TYPHEX
C
C     --- TABLEAU DE DECOUPAGE
      INTEGER    NTYELE
      PARAMETER (NTYELE = 28)
C     NBRE, NOM D'OBJET POUR CHAQUE TYPE D'ELEMENT
      INTEGER      NBEL(NTYELE)
      CHARACTER*24 NOBJ(NTYELE)
      CHARACTER*7  K7NO,K7MA,TK7NO(NTYELE)
      CHARACTER*8  NMTYP(NTYELE),BLANC8
      INTEGER      NBTYP(NTYELE),IFM,NIV,VALI
C     ------------------------------------------------------------------
C
      CALL INFNIV(IFM,NIV)
      CALL JEMARQ()
C
C     FORMAT DES NOMS DE NOEUDS (N1234567 : IDN=2, ROUTINE GMENEU)
C                    DE MAILLES (M1234567 : IDM=2, ROUTINE GMEELT)
C          ET GROUPE DE MAILLES (GM123456 : IDGM=3, ROUTINE GMEELT)
C     PRODUITS PAR PRE_GMSH
      IDN=2
      IDM=2
      IDGM=3
      BLANC8='        '
C
C --- TRANSFORMATION DES MAILLES D'ORDRE 2 DU MAILLAGE EN MAILLES
C --- D'ORDRE 1 :
C     =========
      ZERO   = 0.0D0
      NOMAOU = '&&MAILLA'
      IBID   =  1
C
      TYPMAI = NOMAOU//'.TYPMAIL'
      NOMMAI = NOMAOU//'.NOMMAI'
C 
C --- INIT
      DO 101 I=1,NTYELE
         NBEL(I) = 0
         NOBJ(I) = ' '
 101  CONTINUE
      CALL JENONU ( JEXNOM('&CATA.TM.NOMTM', 'POI1'   ), TYPPOI )
      CALL JENONU ( JEXNOM('&CATA.TM.NOMTM', 'SEG2'   ), TYPSEG )
      CALL JENONU ( JEXNOM('&CATA.TM.NOMTM', 'TRIA3'  ), TYPTRI )
      CALL JENONU ( JEXNOM('&CATA.TM.NOMTM', 'QUAD4'  ), TYPQUA )
      CALL JENONU ( JEXNOM('&CATA.TM.NOMTM', 'TETRA4' ), TYPTET )
      CALL JENONU ( JEXNOM('&CATA.TM.NOMTM', 'PYRAM5' ), TYPPYR )
      CALL JENONU ( JEXNOM('&CATA.TM.NOMTM', 'PENTA6' ), TYPPRI )
      CALL JENONU ( JEXNOM('&CATA.TM.NOMTM', 'HEXA8' ) , TYPHEX )
      NOBJ(TYPPOI) = NOMAOU//'_POI'
      NOBJ(TYPSEG) = NOMAOU//'_SEG'
      NOBJ(TYPTRI) = NOMAOU//'_TRI'
      NOBJ(TYPQUA) = NOMAOU//'_QUA'
      NOBJ(TYPTET) = NOMAOU//'_TET'
      NOBJ(TYPPYR) = NOMAOU//'_PYR'
      NOBJ(TYPPRI) = NOMAOU//'_PRI'
      NOBJ(TYPHEX) = NOMAOU//'_HEX'
C
      CALL IRGMM3( NOMA, NOMAOU, 0, IBID, 'V', NOBJ, NBEL, VERSIO)
C      
      CALL JEVEUO(NOMAOU//'.COORDO    .VALE','L',JCOOR)
      CALL JEVEUO(NOMAOU//'.CONNEX'         ,'L',JCONX)
      CALL JEVEUO(JEXATR(NOMAOU//'.CONNEX','LONCUM'),'L',JPOIN)
      CALL JEVEUO(TYPMAI,'L',IATYMA)
      CALL JEVEUO(NOMAOU//'.NBNUNE','L',JDNBNU)
C
C --- ECRITURE DES NOEUDS DU MAILLAGE SUR LE FICHIER GMSH :
C     ===================================================
      WRITE(IFC,'(A4)') '$NOD'
      CALL CODENT(NNO,'G',K8NNO)
      WRITE(IFC,'(A8)') K8NNO
C
C
      DO 10 INO = 1,NNO
         IF(LGMSH)THEN
            K7NO=NONOE(INO)(IDN:8)
         ELSE
            CALL CODENT(INO,'D',K7NO)
         ENDIF
         IF (NDIM.EQ.3) THEN
            WRITE(IFC,1001) K7NO,
     +                    (ZR(JCOOR+3*(INO-1)+J-1),J=1,NDIM)
         ELSEIF (NDIM.EQ.2) THEN
            WRITE(IFC,1001) K7NO,
     +                    (ZR(JCOOR+3*(INO-1)+J-1),J=1,NDIM),ZERO
         ENDIF
  10  CONTINUE
C
      WRITE(IFC,'(A7)') '$ENDNOD'
C
      NBMA2 = 0
      DO 102 I=1,NTYELE
         NBMA2 = NBMA2 + NBEL(I)
 102  CONTINUE
C
C --- NUMERO DES GROUP_MA (POUR L'ECRITURE DES MAILLES) :
C     =================================================
C --- CREATION DU VECTEUR DES NUMEROS DE GROUP_MA :
C     -------------------------------------------
      CALL WKVECT('&&IRMGMS.NUMGRMA','V V I',NBMA2,IDNUGM)
C
C     LES NOMS DE GROUPE DE MAILLES SONT AU FORMAT : GM123456
C
      NUMGRX = 10000
      DO 20 IGM = 1, NBGRM
        CALL JENUNO(JEXNUM(NOMA//'.GROUPEMA',IGM),NOMGRM)
        CALL LXLIIS(NOMGRM(IDGM:8),NUMGRM,IER)
        IF (IER.EQ.0) THEN
          NUMGRX = MAX(NUMGRX,NUMGRM)
        ENDIF
  20  CONTINUE
C
      IF(NBGRM.GT.0) CALL U2MESS('I','PREPOST6_31')
C
      DO 30 IGM = 1, NBGRM
        CALL JENUNO(JEXNUM(NOMA//'.GROUPEMA',IGM),NOMGRM)
        CALL JEVEUO(JEXNOM(NOMA//'.GROUPEMA',NOMGRM),'L',IDGRMA)
        CALL LXLIIS(NOMGRM(IDGM:8),NUMGRM,IER)
        IF (IER.EQ.1) THEN
          NUMGRM = IGM + NUMGRX
        ENDIF
        CALL JELIRA(JEXNUM(NOMA//'.GROUPEMA',IGM),'LONMAX',NBM,K8BID)
        DO 40 I = 1, NBM
          NBMLI = ZI(JDNBNU+ZI(IDGRMA+I-1)-1)
          CALL JEVEUO ( JEXNUM( '&&IRMGMS.LISMA', ZI(IDGRMA+I-1) ),
     +                 'L', IDLIMA)
          DO 50 J = 1, NBMLI
            ZI(IDNUGM+ZI(IDLIMA+J-1)-1) = NUMGRM
  50      CONTINUE
  40    CONTINUE
        WRITE(6,1002) NOMGRM,NUMGRM
  30  CONTINUE
C
C --- ECRITURE DES MAILLES DU MAILLAGE SUR LE FICHIER GMSH :
C     ====================================================
      WRITE(IFC,'(A4)') '$ELM'
      CALL CODENT(NBMA2,'G',K8NBMA)
      WRITE(IFC,'(A8)') K8NBMA
C
      DO 70 I=1,NTYELE
        NMTYP(I) = BLANC8
        NBTYP(I) = 0
70    CONTINUE
      NBELGM =0
      DO 60 IMA = 1,NBMA2
         IPOIN = ZI(JPOIN+IMA-1)
         NNOE  = ZI(JPOIN+IMA) - IPOIN
C
C ---    NOM DU TYPE DE L'ELEMENT :
C        ------------------------
         ITYPE = ZI(IATYMA+IMA-1)
         CALL JENUNO(JEXNUM('&CATA.TM.NOMTM',ITYPE),NOMTYP)
         ITYPGM = NUTYGM(NOMTYP)
         IF (ZI(IDNUGM+IMA-1).EQ.0) THEN
           NBELGM=NBELGM+1
           ZI(IDNUGM+IMA-1) = 10000

           DO 80 I=1,NTYELE
             IF(NMTYP(I).EQ.NOMTYP)THEN
                NBTYP(I)=NBTYP(I)+1
                GOTO 90
             ELSEIF(NMTYP(I).EQ.BLANC8)THEN
                NBTYP(I)=NBTYP(I)+1
                NMTYP(I)=NOMTYP
                GOTO 90
             ENDIF
 80        CONTINUE
 90        CONTINUE
         ENDIF
         CALL JENUNO(JEXNUM(NOMMAI,IMA),NOMAIL)
         IF(LGMSH)THEN
            K7MA=NOMAIL(IDM:8)
         ELSE
            CALL CODENT(IMA,'D',K7MA)
         ENDIF
         DO 61 INO=1,NNOE
            IF(LGMSH)THEN
               TK7NO(INO)=NONOE(ZI(JCONX+IPOIN-1+INO-1))(IDN:8)
            ELSE
               CALL CODENT(ZI(JCONX+IPOIN-1+INO-1),'D',TK7NO(INO))
            ENDIF
  61     CONTINUE
         WRITE(IFC,1003)
     +       K7MA,ITYPGM,ZI(IDNUGM+IMA-1),ZI(IDNUGM+IMA-1),NNOE,
     +      (TK7NO(INO),INO=1,NNOE)
  60  CONTINUE

      IF(NBTYP(1).NE.0.AND.NIV.GE.1) THEN
         CALL U2MESG('I','PREPOST6_32',0,' ',1,NBELGM,0,0.D0)
         DO 95 I=1,NTYELE
           IF(NMTYP(I).NE.BLANC8) THEN
             VALK = NMTYP(I)
             VALI = NBTYP(I)
             CALL U2MESG('I','PREPOST6_33',1,VALK,1,VALI,0,0.D0)
           ENDIF
95       CONTINUE
      ENDIF
C  
      WRITE(IFC,'(A7)') '$ENDELM'
C
      CALL JEDETC('V',NOMAOU,1)
      CALL JEDETC('V','&&IRMGMS',1)
C
 1001 FORMAT (1X,A7,1X,1PE23.16,1X,1PE23.16,1X,1PE23.16,1X,1PE23.16)
 1002 FORMAT (11X,A8,9X,I8)
 1003 FORMAT (1X,A7,1X,I2,1X,I8,1X,I8,1X,I8,27(1X,A7))
C
      CALL JEDEMA()
      END
