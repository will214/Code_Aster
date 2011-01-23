      SUBROUTINE XJACFF(ELREFP,ELREFC,ELC,NDIM,FPG,JINTER,IFA,CFACE,
     &                  IPG,NNO,IGEOM,JBASEC,G,CINEM,JAC,FFP,FFPC,DFDI,
     &                  ND1,TAU1,TAU2)
      IMPLICIT NONE

      INTEGER       JINTER,IFA,CFACE(5,3),IPG,NNO,IGEOM,JBASEC,NDIM
      REAL*8        JAC,FFP(27),FFPC(27),DFDI(NNO,NDIM)
      REAL*8        ND(NDIM),TAU1(NDIM),TAU2(NDIM)
      CHARACTER*3   CINEM
      CHARACTER*8   ELREFP,FPG,ELREFC,ELC

C     ------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 25/01/2011   AUTEUR PELLET J.PELLET 
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
C   1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================
C TOLE CRP_21 CRS_1404
C
C                   CALCUL DU JACOBIEN DE LA TRANSFORMATION FACETTE
C                       R�ELLE EN 3D � FACETTE DE R�F�RENCE 2D
C                   ET DES FF DE L'�L�MENT PARENT AU POINT DE GAUSS
C               ET DE LA NORMALE � LA FACETTE ORIENT�E DE ESCL -> MAIT
C     ENTREE
C       ELREFP  : TYPE DE L'ELEMENT DE REF PARENT
C       FPG     : FAMILLE DE POINTS DE GAUSS (SCHEMA D'INTEGRATION)
C       PINTER  : COORDONN�ES DES POINTS D'INTERSECTION
C       IFA     : INDINCE DE LA FACETTE COURANTE
C       CFACE   : CONNECTIVIT� DES NOEUDS DES FACETTES
C       IPG     : NUM�RO DU POINTS DE GAUSS
C       NNO     : NOMBRE DE NOEUDS DE L'ELEMENT DE REF PARENT
C       IGEOM   : COORDONNEES DES NOEUDS DE L'ELEMENT DE REF PARENT
C       CINEM   : CALCUL DES QUANTIT�S CIN�MATIQUES
C                'NON' : ON S'ARRETE APRES LE CALCUL DES FF
C                'DFF' : ON S'ARRETE APRES LE CALCUL DES DERIVEES DES FF
C                'OUI' : ON VA JUSQU'AU BOUT

C
C     SORTIE
C       G       : COORDONN�ES R�ELLES 3D DU POINT DE GAUSS
C       JAC     : PRODUIT DU JACOBIEN ET DU POIDS
C       FF      : FF DE L'�L�MENT PARENT AU POINT DE GAUSS
C       ND      : NORMALE � LA FACETTE ORIENT�E DE ESCL -> MAIT
C
C     ------------------------------------------------------------------
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
      CHARACTER*16             ZK16
      CHARACTER*24                      ZK24
      CHARACTER*32                               ZK32
      CHARACTER*80                                        ZK80
      COMMON  /KVARJE/ ZK8(1), ZK16(1), ZK24(1), ZK32(1), ZK80(1)
C     -----  FIN  COMMUNS NORMALISES  JEVEUX  --------------------------
C
      REAL*8          A(3),B(3),C(3),AB(3),AC(3),Y(3),NORME,NAB,G(3)
      REAL*8          RBID,XG(2),KSIG(2),DDOT
      REAL*8          FF(27),RBID1(3),RBID2(3)
      REAL*8          GRLT(3),NORM2,PS,ND1(3)
      INTEGER         IBID,NBNOMX,NNOC
      INTEGER         I,J,K,NNOF,IPOIDF,IVFF,IDFDEF,JCOR2D,JCOR3D,NDIMF
      CHARACTER*8     K8BID
      CHARACTER*24    COOR2D,COOR3D
      INTEGER         DDLH,NFE,DDLS,DDLM,IDEPL
      REAL*8          HE,FE(4),DGDGL(4,3)
      REAL*8          XE(3),F(3,3),DFDIC(27,3)
      REAL*8          EPS(6),GRAD(3,3)
      
      LOGICAL         LTEATT, AXI
      
      PARAMETER       (NBNOMX = 27)
C ----------------------------------------------------------------------

      CALL JEMARQ()

      CALL ELREF4(ELC,FPG,NDIMF,NNOF,IBID,IBID,IPOIDF,IVFF,
     &                                             IDFDEF,IBID)
     
      AXI = LTEATT(' ','AXIS','OUI')
     
      CALL ASSERT(NNOF.EQ.3)
      CALL ASSERT(NDIM.EQ.3)

C --- INITIALISATION
      CALL VECINI(3,0.D0,A)
      CALL VECINI(3,0.D0,B)
      CALL VECINI(3,0.D0,C)
      CALL VECINI(3,0.D0,AB)
      CALL VECINI(3,0.D0,AC)
      CALL VECINI(3,0.D0,ND1)
      CALL VECINI(3,0.D0,ND)
      CALL VECINI(3,0.D0,GRLT)
      CALL VECINI(3,0.D0,TAU1)
      CALL VECINI(3,0.D0,TAU2)

C     COORDONN�ES DES SOMMETS DE LA FACETTE DANS LE REP�RE GLOBAL 3D
      COOR3D='&&JACFF.COOR3D'
      CALL WKVECT(COOR3D,'V V R',NNOF*NDIM,JCOR3D)
      DO 10 I=1,NNOF
        DO 11 J=1,NDIM
          ZR(JCOR3D-1+(I-1)*NDIM+J)=ZR(JINTER-1+NDIM*(CFACE(IFA,I)-1)+J)
 11     CONTINUE
 10   CONTINUE


      DO 20 J=1,NDIM
        A(J)=ZR(JINTER-1+NDIM*(CFACE(IFA,1)-1)+J)
        B(J)=ZR(JINTER-1+NDIM*(CFACE(IFA,2)-1)+J)
        C(J)=ZR(JINTER-1+NDIM*(CFACE(IFA,3)-1)+J)
        AB(J)=B(J)-A(J)
        AC(J)=C(J)-A(J)
 20   CONTINUE

      CALL PROVEC(AB,AC,ND)
      CALL NORMEV(ND,NORME)
      CALL NORMEV(AB,NAB)
      CALL PROVEC(ND,AB,Y)

C     COORDONN�ES DES SOMMETS DE LA FACETTE DANS LE REP�RE LOCAL 2D
      COOR2D='&&JACFF.COOR2D'
      CALL WKVECT(COOR2D,'V V R',6,JCOR2D)
      ZR(JCOR2D-1+1)=0.D0
      ZR(JCOR2D-1+2)=0.D0
      ZR(JCOR2D-1+3)=NAB
      ZR(JCOR2D-1+4)=0.D0
      ZR(JCOR2D-1+5)=DDOT(3,AC,1,AB,1)
      ZR(JCOR2D-1+6)=DDOT(3,AC,1,Y ,1)

C     CALCUL DE JAC EN 2D
      CALL DFDM2D(NNOF,IPG,IPOIDF,IDFDEF,ZR(JCOR2D),RBID1,RBID2,JAC)

C     COORDONN�ES R�ELLES 2D DU POINT DE GAUSS IPG
      CALL VECINI(2,0.D0,XG)
      DO 30 J=1,NNOF
         XG(1)=XG(1)+ZR(IVFF-1+NNOF*(IPG-1)+J)*ZR(JCOR2D-1+2*J-1)
         XG(2)=XG(2)+ZR(IVFF-1+NNOF*(IPG-1)+J)*ZR(JCOR2D-1+2*J)
 30   CONTINUE

C     COORDONN�ES R�ELLES 3D DU POINT DE GAUSS
      G(1)=A(1)+AB(1)*XG(1)+Y(1)*XG(2)
      G(2)=A(2)+AB(2)*XG(1)+Y(2)*XG(2)
      G(3)=A(3)+AB(3)*XG(1)+Y(3)*XG(2)

C --- COORDONNEES DE REFERENCE 2D DU POINT DE GAUSS
      CALL REEREG('S',ELC,NNOF,ZR(JCOR2D),XG,NDIMF,KSIG,IBID)

C --- CONSTRUCTION DE LA BASE AU POINT DE GAUSS
C     CALCUL DES FF DE LA FACETTE EN CE POINT DE GAUSS
      CALL ELRFVF(ELC,KSIG,NBNOMX,FF,IBID)

      DO 40 J=1,NDIM
        DO 41 K=1,NNOF
          ND1(J)  = ND1(J) + FF(K)*ZR(JBASEC-1+NDIM*NDIM*(K-1)+J)
          GRLT(J)= GRLT(J) + FF(K)*ZR(JBASEC-1+NDIM*NDIM*(K-1)+J+NDIM)
 41     CONTINUE
 40   CONTINUE

      CALL NORMEV(ND1,NORME)
      PS=DDOT(NDIM,GRLT,1,ND1,1)
      DO 50 J=1,NDIM
        TAU1(J)=GRLT(J)-PS*ND1(J)
 50   CONTINUE

      CALL NORMEV(TAU1,NORME)

      IF (NORME.LT.1.D-12) THEN
C       ESSAI AVEC LE PROJETE DE OX
        TAU1(1)=1.D0-ND1(1)*ND1(1)
        TAU1(2)=0.D0-ND1(1)*ND1(2)
        IF (NDIM .EQ. 3) TAU1(3)=0.D0-ND1(1)*ND1(3)
        CALL NORMEV(TAU1,NORM2)
        IF (NORM2.LT.1.D-12) THEN
C         ESSAI AVEC LE PROJETE DE OY
          TAU1(1)=0.D0-ND1(2)*ND1(1)
          TAU1(2)=1.D0-ND1(2)*ND1(2)
          IF (NDIM .EQ. 3) TAU1(3)=0.D0-ND1(2)*ND1(3)
          CALL NORMEV(TAU1,NORM2)
        ENDIF
        CALL ASSERT(NORM2.GT.1.D-12)
      ENDIF
      IF (NDIM .EQ. 3) THEN
       CALL PROVEC(ND1,TAU1,TAU2)
      ENDIF

      CALL REEREF(ELREFP,AXI,NNO,NNO,IGEOM,G,IBID,.FALSE.,
     &             NDIM,HE, RBID, RBID,
     &             IBID,IBID,DDLH,NFE,DDLS,DDLM,FE,DGDGL,CINEM,
     &             XE,FFP,DFDI,F,EPS,GRAD)


      IF (ELREFC.EQ.ELREFP) GO TO 999
      IF (ELREFC(1:3).EQ.'NON') GO TO 999

C     CALCUL DES FF DE L'�L�MENT DE CONTACT EN CE POINT DE GAUSS
      CALL ELELIN(3,ELREFC,K8BID,NNOC,IBID)

      CALL REEREF(ELREFC,AXI, NNOC,NNOC,IGEOM,G,IBID,.FALSE.,
     &             NDIM,HE,RBID, RBID,
     &             IBID,IBID,DDLH,NFE,DDLS,DDLM,FE,DGDGL,CINEM,
     &             XE,FFPC,DFDIC,F,EPS,GRAD)

 999  CONTINUE

      CALL JEDETR(COOR2D)
      CALL JEDETR(COOR3D)
      CALL JEDEMA()
      END
