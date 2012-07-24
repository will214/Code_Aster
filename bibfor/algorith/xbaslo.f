      SUBROUTINE XBASLO(NOMA  ,FISS  ,GRLT  ,GRLN  , NDIM)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 24/07/2012   AUTEUR PELLET J.PELLET 
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
C RESPONSABLE GENIAUT S.GENIAUT
C
      IMPLICIT NONE
      INCLUDE 'jeveux.h'
      INTEGER         NDIM
      CHARACTER*8     NOMA,FISS
      CHARACTER*19    GRLT,GRLN
C
C ----------------------------------------------------------------------
C
C ROUTINE XFEM (PREPARATION)
C
C CREATION D'UN CHAM_EL QUI CONTIENT LA BASE
C LOCALE AU POINT DU FOND DE FISSURE ASSOCIE - (2D/3D)
C
C ----------------------------------------------------------------------
C
C
C IN  FISS   : NOM DE LA FISSURE
C IN  NOMA   : NOM DU MAILLAGE
C IN  MODELE : NOM DE L'OBJET MODELE
C IN  GRLT   : CHAM_NO_S DES GRADIENTS DE LA LEVEL-SET TANGENTE
C IN  GRLN   : CHAM_NO_S DES GRADIENTS DE LA LEVEL-SET NORMALE
C IN  NDIM   : DIMENSION DU MAILLAGE
C OUT FISS   : FISSURE AVEC LE .BASLOC EN PLUS
C
C
C
C
      INTEGER           NBCMP
      CHARACTER*8       LICMP(9)
      CHARACTER*24      COORN
      CHARACTER*24      XFONFI
      INTEGER           IFON,NPOINT,IFM,NIV,IER,IBID
      CHARACTER*8       K8BID
      CHARACTER*19      CNSBAS,BASLOC
      INTEGER           IADRCO,JGSV,JGSL,JGT,JGTL,JGN
      INTEGER           LONG,NFON,NBNO,IRET,INO,J
      REAL*8            XI1,YI1,ZI1,XJ1,YJ1,ZJ1,XIJ,YIJ,ZIJ,EPS,D,NORM2
      REAL*8            XM,YM,ZM,XIM,YIM,ZIM,S,DMIN,XN,YN,ZN,A(3)
      REAL*8            R8MAEM
C
      DATA LICMP / 'X1','X2','X3',
     &             'X4','X5','X6',
     &             'X7','X8','X9'/
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
      CALL INFDBG('XFEM',IFM,NIV)

C --- CREATION DU CHAM_NO
C
      CNSBAS = '&&OP0041.CNSBAS'
      NBCMP = NDIM*3
      CALL CNSCRE(NOMA,'NEUT_R',NBCMP,LICMP,'V',CNSBAS)
      CALL JEVEUO(CNSBAS//'.CNSV','E',JGSV)
      CALL JEVEUO(CNSBAS//'.CNSL','E',JGSL)
C
C --- ACCES AU MAILLAGE
C
      COORN = NOMA//'.COORDO    .VALE'
      CALL JEVEUO(COORN,'L',IADRCO)
      CALL DISMOI('F','NB_NO_MAILLA',NOMA,'MAILLAGE',NBNO,K8BID,IRET)
C
C --- ACCES AUX OBJETS: NOM DES POINTS DU FOND DE FISSURE
C
      XFONFI = FISS(1:8)//'.FONDFISS'
      CALL JEEXIN(XFONFI,IER)
      IF (IER.EQ.0) THEN
C       LE FOND DE FISSURE N'EXISTE PAS (CAS D'UNE INTERFACE)
C       ON MET TOUT A ZERO ET ON SORT
        DO 10 INO=1,NBNO
          DO 20 J=1,NDIM
            ZR(JGSV-1+3*NDIM*(INO-1)+J)=0.D0
            ZL(JGSL-1+3*NDIM*(INO-1)+J)=.TRUE.
            ZR(JGSV-1+3*NDIM*(INO-1)+J+NDIM)=0.D0
            ZL(JGSL-1+3*NDIM*(INO-1)+J+NDIM)=.TRUE.
            ZR(JGSV-1+3*NDIM*(INO-1)+J+2*NDIM)=0.D0
            ZL(JGSL-1+3*NDIM*(INO-1)+J+2*NDIM)=.TRUE.
 20      CONTINUE
 10     CONTINUE
      GOTO 999
      ENDIF

      CALL JEVEUO(XFONFI,'L',IFON)
      CALL JELIRA(XFONFI,'LONMAX',LONG,K8BID)
      NFON = LONG/4
C
C --- R�CUP�RATION DES GRADIENTS DE LST ET LSN
C
      CALL JEVEUO(GRLT//'.CNSV','L',JGT)
      CALL JEVEUO(GRLT//'.CNSL','L',JGTL)
      CALL JEVEUO(GRLN//'.CNSV','L',JGN)
C
C     CALCUL DES PROJET�S DES NOEUDS SUR LE FOND DE FISSURE
      EPS = 1.D-12
      DO 100 INO=1,NBNO
        IF (.NOT. ZL(JGTL-1+NDIM*(INO-1)+1)) GOTO 100
C       COORD DU NOEUD M DU MAILLAGE
        XM = ZR(IADRCO+(INO-1)*3+1-1)
        YM = ZR(IADRCO+(INO-1)*3+2-1)
        ZM = ZR(IADRCO+(INO-1)*3+3-1)
C       INITIALISATION
        DMIN = R8MAEM()
C       BOUCLE SUR PT DE FONFIS
        IF (NDIM.EQ.2) NPOINT = NFON
        IF (NDIM.EQ.3) NPOINT = NFON-1
        DO 110 J=1,NPOINT
          IF (NDIM.EQ.2) THEN
C           COORD PT N
            XN = ZR(IFON-1+4*(J-1)+1)
            YN = ZR(IFON-1+4*(J-1)+2)
            ZN = 0.D0
C           DISTANCE MN
            D = SQRT((XN-XM)*(XN-XM)+(YN-YM)*(YN-YM))
          ELSEIF (NDIM.EQ.3) THEN
C           COORD PT I, ET J
            XI1 = ZR(IFON-1+4*(J-1)+1)
            YI1 = ZR(IFON-1+4*(J-1)+2)
            ZI1 = ZR(IFON-1+4*(J-1)+3)
            XJ1 = ZR(IFON-1+4*(J-1+1)+1)
            YJ1 = ZR(IFON-1+4*(J-1+1)+2)
            ZJ1 = ZR(IFON-1+4*(J-1+1)+3)
C           VECTEUR IJ ET IM
            XIJ = XJ1-XI1
            YIJ = YJ1-YI1
            ZIJ = ZJ1-ZI1
            XIM = XM-XI1
            YIM = YM-YI1
            ZIM = ZM-ZI1
C           PARAM S (PRODUIT SCALAIRE...)
            S        = XIJ*XIM + YIJ*YIM + ZIJ*ZIM
            NORM2 = XIJ*XIJ + YIJ *YIJ + ZIJ*ZIJ
            S        = S/NORM2
C           SI N=P(M) SORT DU SEGMENT
            IF ((S-1).GE.EPS) S = 1.D0
            IF (S.LE.EPS)     S = 0.D0
C           COORD DE N
            XN = S*XIJ+XI1
            YN = S*YIJ+YI1
            ZN = S*ZIJ+ZI1
C           DISTANCE MN
            D = SQRT((XN-XM)*(XN-XM)+(YN-YM)*(YN-YM)+
     &               (ZN-ZM)*(ZN-ZM))
          ENDIF
          IF(D.LT.DMIN) THEN
            DMIN = D
            A(1)=XN
            A(2)=YN
            A(3)=ZN
          ENDIF
110     CONTINUE
C       STOCKAGE DU PROJET� ET DES GRADIENTS
        DO 120 J=1,NDIM
          ZR(JGSV-1+3*NDIM*(INO-1)+J)=A(J)
          ZL(JGSL-1+3*NDIM*(INO-1)+J)=.TRUE.
          ZR(JGSV-1+3*NDIM*(INO-1)+J+NDIM)=ZR(JGT-1+NDIM*(INO-1)+J)
          ZL(JGSL-1+3*NDIM*(INO-1)+J+NDIM)=.TRUE.
          ZR(JGSV-1+3*NDIM*(INO-1)+J+2*NDIM)=ZR(JGN-1+NDIM*(INO-1)+J)
          ZL(JGSL-1+3*NDIM*(INO-1)+J+2*NDIM)=.TRUE.
 120    CONTINUE
 100  CONTINUE

 999  CONTINUE
C
C     ENREGISTREMENT DU .BASLOC DANS LA SD FISS_XFEM
      BASLOC = FISS(1:8)//'.BASLOC'
      CALL CNSCNO(CNSBAS,' ','NON','G',BASLOC,'F',IBID)
      CALL DETRSD('CHAM_NO_S',CNSBAS)

      IF (NIV.GT.2) THEN
        CALL IMPRSD('CHAMP',BASLOC,IFM,'FISSURE.BASLOC=')
      ENDIF

      CALL JEDEMA()
      END
