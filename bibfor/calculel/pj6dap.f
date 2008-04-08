      SUBROUTINE PJ6DAP(INO2,GEOM2,MA2,GEOM1,SEG2,COBARY,ITR3,NBTROU,
     &                  BTDI,BTVR,BTNB,BTLC,BTCO,IFM,NIV,LDMAX,DISTMA,
     &                  LOIN,DMIN)
      IMPLICIT NONE
      REAL*8 COBARY(2),GEOM1(*),GEOM2(*),BTVR(*)
      INTEGER ITR3,NBTROU,BTDI(*),BTNB(*),BTLC(*),BTCO(*)
      INTEGER SEG2(*),IFM,NIV
      CHARACTER*8 MA2
C ----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF CALCULEL  DATE 07/04/2008   AUTEUR GALENNE E.GALENNE 
C ======================================================================
C COPYRIGHT (C) 1991 - 2005  EDF R&D                  WWW.CODE-ASTER.ORG
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
C RESPONSABLE VABHHTS J.PELLET
C ======================================================================
C     BUT :
C       TROUVER LE SEG2 QUI SERVIRA A INTERPOLER LE NOEUD INO2
C       AINSI QUE LES COORDONNEES BARYCENTRIQUES DE INO2 DANS CE SEG2
C
C  IN   INO2       I  : NUMERO DU NOEUD DE M2 CHERCHE
C  IN   MA2        K8 : NOM DU MAILLAGE M2
C  IN   GEOM2(*)   R  : COORDONNEES DES NOEUDS DU MAILLAGE M2
C  IN   GEOM1(*)   R  : COORDONNEES DES NOEUDS DU MAILLAGE M1
C  IN   SEG2(*)   I  : OBJET '&&PJXXCO.SEG2'
C  IN   BTDI(*)    I  : OBJET .BT3DDI DE LA SD BOITE_3D
C  IN   BTVR(*)    R  : OBJET .BT3DVR DE LA SD BOITE_3D
C  IN   BTNB(*)    I  : OBJET .BT3DNB DE LA SD BOITE_3D
C  IN   BTLC(*)    I  : OBJET .BT3DLC DE LA SD BOITE_3D
C  IN   BTCO(*)    I  : OBJET .BT3DCO DE LA SD BOITE_3D
C  IN   IFM        I  : NUMERO LOGIQUE DU FICHIER MESSAGE
C  IN   NIV        I  : NIVEAU D'IMPRESSION POUR LES "INFO"
C  IN   LDMAX      L  : .TRUE. : IL FAUT PRENDRE DISTMA EN COMPTE
C  IN   DISTMA     R  : DISTANCE AU DELA DE LAQUELLE LE NOEUD INO2
C                       NE SERA PAS PROJETE.
C  OUT  NBTROU     I  : 1 -> ON A TROUVE 1 SEG2 SOLUTION
C                     : 0 -> ON N'A PAS TROUVE DE SEG2 SOLUTION
C  OUT  ITR3       I  : NUMERO DU SEG2 SOLUTION
C  OUT  COBARY(4)  R  : COORDONNEES BARYCENTRIQUES DE INO2 DANS ITR3
C  OUT  DMIN       R  : DISTANCE DE INO2 AU BORD DE ITR3 SI INO2 EST
C                       EXTERIEUR A ITR3.
C  OUT  LOIN       L  : .TRUE. SI DMIN > 10% DIAMETRE(ITR3)

C  REMARQUE :
C    SI NBTROU=0, INO2 NE SERA PAS PROJETE CAR IL EST AU DELA DE DISTMA
C    ALORS : DMIN=0, LOIN=.FALSE.
C ----------------------------------------------------------------------
C --- DEBUT DECLARATIONS NORMALISEES JEVEUX ----------------------------
C
      CHARACTER*32 JEXNUM,JEXNOM,JEXR8,JEXATR
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
C
C --- FIN DECLARATIONS NORMALISEES JEVEUX ------------------------------
      REAL*8 COBAR2(2),DMIN,D2,R8MAEM,LONG,RTR3
      INTEGER P,Q,R,P1,Q1,P2,Q2,R1,R2,INO2,I,K,IPOSI,NX,NY,NTRBT,IBID
      CHARACTER*8 NONO2,ALARME

      LOGICAL LDMAX,LOIN
      REAL*8 DISTMA,VALR(2)
C DEB ------------------------------------------------------------------
      NBTROU=0
      LOIN=.FALSE.
      DMIN=0.D0

      NX=BTDI(1)
      NY=BTDI(2)


C     --  ON CHERCHE LE SEG2 ITR3 LE PLUS PROCHE DE INO2 :
C     ------------------------------------------------------
      IF (LDMAX) THEN
        DMIN=DISTMA
      ELSE
        DMIN=R8MAEM()
      ENDIF

C       -- ON RECHERCHE LA GROSSE BOITE CANDIDATE :
      CALL PJ3DGB(INO2,GEOM2,GEOM1,SEG2,3,BTDI,BTVR,BTNB,BTLC,BTCO,P1,
     &            Q1,R1,P2,Q2,R2)
      DO 40,P=P1,P2
        DO 30,Q=Q1,Q2
          DO 20,R=R1,R2
            NTRBT=BTNB((R-1)*NX*NY+(Q-1)*NX+P)
            IPOSI=BTLC((R-1)*NX*NY+(Q-1)*NX+P)
            DO 10,K=1,NTRBT
              I=BTCO(IPOSI+K)
              CALL PJ6DA2(INO2,GEOM2,I,GEOM1,SEG2,COBAR2,D2,LONG)
              IF (SQRT(D2).LT.DMIN) THEN
                RTR3=LONG
                ITR3=I
                DMIN=SQRT(D2)
                NBTROU=1
                COBARY(1)=COBAR2(1)
                COBARY(2)=COBAR2(2)
              ENDIF
   10       CONTINUE
   20     CONTINUE
   30   CONTINUE
   40 CONTINUE

      IF (NBTROU.EQ.1) THEN
        IF (RTR3.EQ.0) THEN
          LOIN=.TRUE.
        ELSE
          IF (DMIN/RTR3.GT.1.D-1) LOIN=.TRUE.
        END IF
      ELSE
        DMIN=0.D0
      ENDIF


      END
