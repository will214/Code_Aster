      SUBROUTINE TE0459(OPTION,NOMTE)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 30/03/2004   AUTEUR CIBHHLV L.VIVAN 
C ======================================================================
C COPYRIGHT (C) 1991 - 2001  EDF R&D                  WWW.CODE-ASTER.ORG
C THIS PROGRAM IS FREE SOFTWARE; YOU CAN REDISTRIBUTE IT AND/OR MODIFY
C IT UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICENSE AS PUBLISHED BY
C THE FREE SOFTWARE FOUNDATION; EITHER VERSION 2 OF THE LICENSE, OR
C (AT YOUR OPTION) ANY LATER VERSION.

C THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT
C WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF
C MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. SEE THE GNU
C GENERAL PUBLIC LICENSE FOR MORE DETAILS.

C YOU SHOULD HAVE RECEIVED A COPY OF THE GNU GENERAL PUBLIC LICENSE
C ALONG WITH THIS PROGRAM; IF NOT, WRITE TO EDF R&D CODE_ASTER,
C    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================

      IMPLICIT  NONE

      CHARACTER*16 OPTION,NOMTE
C ......................................................................
C    - FONCTION REALISEE: CALCUL DES OPTIONS NON-LINEAIRES MECANIQUES
C                         POUR DES ELEMENTS MIXTES A 3 CHAMPS EN 3D
C    - ARGUMENTS:
C        DONNEES:      OPTION       -->  OPTION DE CALCUL
C                      NOMTE        -->  NOM DU TYPE ELEMENT
C ......................................................................

      CHARACTER*8 ELREF2,TYPMOD(2)

      INTEGER NNO1,NNO2,NPG1,JCRET,CODRET,NBELR,IRET,NNO1S,NNO2S
      INTEGER JGANO1,JGANO2
      INTEGER IPOI1,IPOI2,IVF1,IVF2,IDFDE1
      INTEGER NDIM,JTAB(7)
      INTEGER IGEOM,IMATE,ITREF,ICONTM,IVARIM,ITEMPM,ITEMPP
      INTEGER IINSTM,IINSTP,IDEPLM,IDEPLP,ICOMPO,LGPG,ICARCR
      INTEGER IVECTU,ICONTP,IVARIP,IMATUU
      INTEGER I,N,M,KK,J,JMAX,NPG2,IDFDE2

      REAL*8 DEPLM(3,20),DDEPL(3,20)
      REAL*8 GONFLM(2,8),DGONFL(2,8)
      REAL*8 KUU(3,20,3,20),KUA(3,20,2,8),KAA(2,8,2,8)
      REAL*8 FINTU(3,20),FINTA(2,8),DFDIM(3*27),DFDIP(3*27)

C --------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ---------------------
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
C --------- FIN  DECLARATIONS  NORMALISEES  JEVEUX ---------------------
C  REMARQUE :
C  DANS SIGMA : 1,2,3 : (SIGMA)D + P I
C               4,5,6 : SIGMA/SQRT(2)
C               7     : TR(SIGM) - P

C   FONCTIONS DE FORMES ET POINTS DE GAUSS

      IF (NOMTE(6:10).EQ.'TETRA') THEN
        ELREF2 = 'TE4'
      ELSE IF (NOMTE(6:9).EQ.'HEXA') THEN
        ELREF2 = 'HE8'
      ELSE IF (NOMTE(6:10).EQ.'PENTA') THEN
        ELREF2 = 'PE6'
      ELSE
        CALL UTMESS('F','TE0459','ELEMENT:'//NOMTE//'NON IMPLANTE')
      END IF

      CALL ELREF4(' ','RIGI',NDIM,NNO1,NNO1S,NPG1,IPOI1,IVF1,IDFDE1,
     &            JGANO1)

      CALL ELREF4(ELREF2,'RIGI',NDIM,NNO2,NNO2S,NPG2,IPOI2,IVF2,IDFDE2,
     &            JGANO2)


      TYPMOD(1) = '3D'
      TYPMOD(2) = ' '


C PARAMETRES EN ENTREE

      CALL JEVECH('PGEOMER','L',IGEOM)
      CALL JEVECH('PMATERC','L',IMATE)
      CALL JEVECH('PTEREF','L',ITREF)
      CALL JEVECH('PCONTMR','L',ICONTM)
      CALL JEVECH('PVARIMR','L',IVARIM)
      CALL JEVECH('PTEMPMR','L',ITEMPM)
      CALL JEVECH('PTEMPPR','L',ITEMPP)
      CALL JEVECH('PINSTMR','L',IINSTM)
      CALL JEVECH('PINSTPR','L',IINSTP)
      CALL JEVECH('PDEPLMR','L',IDEPLM)
      CALL JEVECH('PDEPLPR','L',IDEPLP)
      CALL JEVECH('PCOMPOR','L',ICOMPO)
      CALL TECACH('OON','PVARIMR',7,JTAB,IRET)
      LGPG = MAX(JTAB(6),1)*JTAB(7)
      CALL JEVECH('PCARCRI','L',ICARCR)

C PARAMETRES EN SORTIE

      IF (OPTION(1:9).EQ.'RIGI_MECA' .OR.
     &    OPTION(1:9).EQ.'FULL_MECA') THEN
        CALL JEVECH('PMATUUR','E',IMATUU)
      END IF
      IF (OPTION(1:9).EQ.'RAPH_MECA' .OR.
     &    OPTION(1:9).EQ.'FULL_MECA') THEN
        CALL JEVECH('PVECTUR','E',IVECTU)
        CALL JEVECH('PCONTPR','E',ICONTP)
        CALL JEVECH('PVARIPR','E',IVARIP)
        CALL JEVECH('PCODRET','E',JCRET)
      END IF

C - HYPO-ELASTICITE

C        REMISE EN FORME DES DONNEES
      KK = 0
      DO 20 N = 1,NNO1
        DO 10 I = 1,5
          IF (I.LE.3) THEN
            DEPLM(I,N) = ZR(IDEPLM+KK)
            DDEPL(I,N) = ZR(IDEPLP+KK)
            KK = KK + 1
          END IF
          IF (I.GE.4 .AND. N.LE.NNO2) THEN
            GONFLM(I-3,N) = ZR(IDEPLM+KK)
            DGONFL(I-3,N) = ZR(IDEPLP+KK)
            KK = KK + 1
          END IF
   10   CONTINUE
   20 CONTINUE

      IF (ZK16(ICOMPO+2) (1:5).EQ.'PETIT') THEN
        CALL NIPL3D(NNO1,NNO2,NPG1,IPOI1,IVF1,IVF2,
     &              IDFDE1,ZR(IGEOM),TYPMOD,
     &              OPTION,ZI(IMATE),ZK16(ICOMPO),LGPG,ZR(ICARCR),
     &              ZR(IINSTM),ZR(IINSTP),ZR(ITEMPM),ZR(ITEMPP),
     &              ZR(ITREF),DEPLM,DDEPL,GONFLM,DGONFL,ZR(ICONTM),
     &              ZR(IVARIM),DFDIM,ZR(ICONTP),ZR(IVARIP),FINTU,FINTA,
     &              KUU,KUA,KAA,CODRET)
      ELSE IF (ZK16(ICOMPO+2) (1:10).EQ.'SIMO_MIEHE') THEN
        CALL NIGP3D(NNO1,NNO2,NPG1,IPOI1,IVF1,IVF2,
     &              IDFDE1,DFDIM,DFDIP,
     &              ZR(IGEOM),TYPMOD,OPTION,ZI(IMATE),ZK16(ICOMPO),LGPG,
     &              ZR(ICARCR),ZR(IINSTM),ZR(IINSTP),ZR(ITEMPM),
     &              ZR(ITEMPP),ZR(ITREF),DEPLM,DDEPL,GONFLM,DGONFL,
     &              ZR(ICONTM),ZR(IVARIM),ZR(ICONTP),ZR(IVARIP),FINTU,
     &              FINTA,KUU,KUA,KAA,CODRET)
      ELSE
        CALL UTMESS('F','TE0459','COMPORTEMENT:'//ZK16(ICOMPO+2)//
     &              'NON IMPLANTE')
      END IF

C   REMISE EN FORME DES DONNEES DANS ZR

      IF (OPTION(1:9).EQ.'RAPH_MECA' .OR.
     &    OPTION(1:9).EQ.'FULL_MECA') THEN
        ZI(JCRET) = CODRET
        KK = 0
        DO 40 N = 1,NNO1
          DO 30 I = 1,5
            IF (I.LE.3) THEN
              ZR(IVECTU+KK) = FINTU(I,N)
              KK = KK + 1
            END IF
            IF (I.GE.4 .AND. N.LE.NNO2) THEN
              ZR(IVECTU+KK) = FINTA(I-3,N)
              KK = KK + 1
            END IF
   30     CONTINUE
   40   CONTINUE
      END IF

      IF (OPTION(1:9).EQ.'FULL_MECA' .OR.
     &    OPTION(1:9).EQ.'RIGI_MECA') THEN

        KK = 0
        DO 80 N = 1,NNO1
          DO 70 I = 1,5
            DO 60 M = 1,N
              IF (M.EQ.N) THEN
                JMAX = I
              ELSE
                JMAX = 5
              END IF
              DO 50 J = 1,JMAX
                IF (I.LE.3 .AND. J.LE.3) THEN
                  ZR(IMATUU+KK) = KUU(I,N,J,M)
                  KK = KK + 1
                END IF
                IF (I.GE.4 .AND. N.LE.NNO2 .AND. J.LE.3) THEN
                  ZR(IMATUU+KK) = KUA(J,M,I-3,N)
                  KK = KK + 1
                END IF
                IF (I.LE.3 .AND. M.LE.NNO2 .AND. J.GE.4) THEN
                  ZR(IMATUU+KK) = KUA(I,N,J-3,M)
                  KK = KK + 1
                END IF
                IF (I.GE.4 .AND. N.LE.NNO2 .AND. J.GE.4 .AND.
     &              M.LE.NNO2) THEN
                  ZR(IMATUU+KK) = KAA(I-3,N,J-3,M)
                  KK = KK + 1
                END IF
   50         CONTINUE
   60       CONTINUE
   70     CONTINUE
   80   CONTINUE

      END IF

      END
