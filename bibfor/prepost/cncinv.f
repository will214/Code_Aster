      SUBROUTINE CNCINV(MAIL,LIMA,NLIMA,BASE,NOMZ)

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF PREPOST  DATE 25/01/2011   AUTEUR PELLET J.PELLET 
C ======================================================================
C COPYRIGHT (C) 1991 - 2011  EDF R&D                  WWW.CODE-ASTER.ORG
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
C RESPONSABLE VABHHTS J.PELLET
C
C**********************************************************************
C   OPERATION REALISEE
C   ------------------
C     CONSTRUCTION DE LA TABLE DE CONNECTIVITE INVERSE, I.E. :
C
C     NOEUD --> LISTE DES MAILLES CONTENANT LE NOEUD

C   ATTENTION :
C   -----------
C      - SI LIMA EST FOURNI (NBMA > 0) , LA CONNECTIVITE INVERSE
C        RETOURNEE FAIT REFERENCE AUX INDICES DES MAILLES DANS LIMA:
C        NUMA=LIMA(CONINV(NUNO))
C      - SI LIMA N'EST PAS FOURNI (NBMA = 0) , LA CONNECTIVITE INVERSE
C        RETOURNEE FAIT REFERENCE AUX NUMEROS DES MAILLES DU MAILLAGE:
C        NUMA=CONINV(NUNO)
C      - CONVENTION : SI UN NOEUD NUNO EST ORPHELIN :
C        LONG(CONINV(NUNO))=1 ET CONINV(NUNO)(1)=0
C
C   ARGUMENTS EN ENTREE
C   ------------------
C     MAIL   : NOM DU MAILLAGE
C     LIMA   : LISTE DES NUMEROS DE MAILLES
C     NLIMA  : NOMBRE DE MAILLES DANS LIMA
C              SI NLIMA=0 ON PREND TOUT LE MAILLAGE
C     BASE   : BASE DE CREATION POUR NOMZ
C     NOMZ   : NOM DE L' OJB A CREER
C
C   ORGANISATION DE L'OBJET CREE DE NOM NOMZ :
C   --------------------------------------------
C     TYPE : XC V I ACCES(NUMEROTE) LONG(VARIABLE)
C
C**********************************************************************

      IMPLICIT NONE

C
C  FONCTIONS EXTERNES
C  ------------------
      CHARACTER*32 JEXNOM,JEXNUM,JEXATR
C
C  DECLARATION DES COMMUNS NORMALISES JEVEUX
C  -----------------------------------------
C
      INTEGER         ZI
      COMMON /IVARJE/ ZI(1)
      REAL*8          ZR
      COMMON /RVARJE/ ZR(1)
      COMPLEX*16      ZC
      COMMON /CVARJE/ ZC(1)
      LOGICAL         ZL
      COMMON /LVARJE/ ZL(1)
      CHARACTER*8     ZK8
      CHARACTER*16    ZK16
      CHARACTER*24    ZK24
      CHARACTER*32    ZK32
      CHARACTER*80    ZK80
      COMMON /KVARJE/ ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C
C  FIN DES COMMUNS NORMALISES JEVEUX
C  ---------------------------------
C
C --- VARIABLES
      CHARACTER*(*) NOMZ
      CHARACTER*24 NOM
      CHARACTER*8  MAIL
      CHARACTER*1  BASE
      INTEGER      LIMA(*),NLIMA,NNO,NMA,IMA,NARE
      INTEGER      I,J,N,P0,P1,P2,P3,Q0,Q1,Q2,Q3

C --- LECTURE DONNEES

      CALL JEMARQ()

      NOM = NOMZ

      CALL JEVEUO(MAIL//'.DIME','L',P0)
      NNO = ZI(P0)
      IF (NLIMA.EQ.0) THEN
        NMA = ZI(P0+2)
      ELSE
        NMA = NLIMA
      ENDIF

      CALL JEVEUO(MAIL//'.CONNEX','L',P1)
      CALL JEVEUO(JEXATR(MAIL//'.CONNEX','LONCUM'),'L',P2)

      IF ((NNO.LE.0).OR.(NMA.LE.0)) GOTO 90

C --- ALLOCATION OBJETS TEMPORAIRES

      CALL WKVECT('&&CNCINV.INDICE','V V I',NMA,Q0)
      CALL WKVECT('&&CNCINV.NMAILLE','V V I',NNO,Q1)
      CALL WKVECT('&&CNCINV.POINTEUR','V V I',NNO+1,Q2)

      IF (NLIMA.EQ.0) THEN

        DO 10 I = 1, NMA
          ZI(Q0-1+I) = I
 10     CONTINUE

      ELSE

        DO 20 I = 1, NMA
          ZI(Q0-1+I) = LIMA(I)
 20     CONTINUE

      ENDIF

      DO 30 I = 1, NNO
        ZI(Q1-1+I) = 0
 30   CONTINUE

C --- NOMBRE DE MAILLES POUR CHAQUE NOEUD

      DO 40 I = 1, NMA

        IMA = ZI(Q0-1+I)
        P0 = ZI(P2-1+IMA)
        N = ZI(P2+IMA)-P0
        P0 = P1 + P0 - 1

        DO 40 J = 1, N
          P3 = Q1-1+ZI(P0)
          P0 = P0 + 1
          ZI(P3) = ZI(P3) + 1
 40   CONTINUE

C --- NOMBRE TOTAL D'ARETES NOEUD/MAILLE

      NARE = 0
      ZI(Q2) = 0

      DO 50 I = 1, NNO

        N = ZI(Q1-1+I)
        IF (N.EQ.0) N = 1

        NARE = NARE + N
        ZI(Q2+I) = NARE

 50   CONTINUE

C --- ALLOCATION DU GRAPHE NOEUD/MAILLE

      CALL JECREC(NOM,BASE//' V I','NU','CONTIG','VARIABLE',NNO)
      CALL JEECRA(NOM,'LONT',NARE,' ')

      DO 60 I = 1, NNO

        N = ZI(Q1-1+I)
        IF (N.EQ.0) N = 1
        CALL JECROC(JEXNUM(NOM,I))
        CALL JEECRA(JEXNUM(NOM,I),'LONMAX',N,' ')

 60   CONTINUE

C --- GRAPHE NOEUD/MAILLE

      CALL JEVEUO(NOM,'E',Q3)

      DO 70 I = 1, NARE
        ZI(Q3-1+I) = 0
 70   CONTINUE

      DO 80 I = 1, NMA

        IMA = ZI(Q0-1+I)
        P0 = ZI(P2-1+IMA)
        N = ZI(P2+IMA)-P0
        P0 = P1 + P0 - 1

        DO 80 J = 1, N

          Q1 = Q2-1+ZI(P0)
          P0 = P0 + 1
          ZI(Q3+ZI(Q1)) = I
          ZI(Q1) = ZI(Q1) + 1

 80   CONTINUE

C --- DESALLOCATION

      CALL JEDETR('&&CNCINV.INDICE')
      CALL JEDETR('&&CNCINV.NMAILLE')
      CALL JEDETR('&&CNCINV.POINTEUR')

 90   CONTINUE

      CALL JEDEMA()

      END
