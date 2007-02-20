      SUBROUTINE TE0546(OPTION,NOMTE)

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 20/02/2007   AUTEUR MICHEL S.MICHEL 
C ======================================================================
C COPYRIGHT (C) 1991 - 2002  EDF R&D                  WWW.CODE-ASTER.ORG
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

      IMPLICIT NONE
      CHARACTER*16 OPTION,NOMTE
C ......................................................................
C    - FONCTION REALISEE:  CALCUL DES OPTIONS NON-LINEAIRES MECANIQUES
C                          ELEMENTS 3D  POUR LES ELEMNTS GRAD_VARI
C    - ARGUMENTS:
C        DONNEES:      OPTION       -->  OPTION DE CALCUL
C                      NOMTE        -->  NOM DU TYPE ELEMENT
C ......................................................................
      CHARACTER*8 TYPMOD(2)

      INTEGER JGANO,NNO,NPG1,I,K,KP,L,IMATUU,LGPG,NDIM,LGPG1
      INTEGER IPOIDS,IVF,IDFDE,IGEOM,IMATE
      INTEGER ITREF,ICONTM,IVARIM,ITEMPM,ITEMPP
      INTEGER IINSTM,IINSTP,IDEPLM,IDEPLP,ICOMPO,ICARCR,IRET
      INTEGER IVECTU,ICONTP,IVARIP,LI,JCRET,CODRET
      INTEGER IVARIX,ICAMAS,IDIM
      INTEGER NDDL,KK,NI,MJ,JTAB(7),NNOS
      REAL*8 R8VIDE,ANGMAS(7),R8DGRD,XYZ(3)
      REAL*8 PFF(6*27*27),DEF(6*27*3),DFDI(3*27),DFDI2(3*27)
      LOGICAL MATSYM

C --------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ---------------------
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

      CALL ELREF4(' ','RIGI',NDIM,NNO,NNOS,NPG1,IPOIDS,IVF,IDFDE,JGANO)
      IF (NNO.GT.27) CALL U2MESS('F','ELEMENTS3_24')



C - TYPE DE MODELISATION
      TYPMOD(1) = '3D      '
      TYPMOD(2) = 'GRADVARI'


C - PARAMETRES EN ENTREE

      CALL JEVECH('PGEOMER','L',IGEOM)
      CALL JEVECH('PMATERC','L',IMATE)
      CALL JEVECH('PCONTMR','L',ICONTM)
      CALL JEVECH('PVARIMR','L',IVARIM)
      CALL JEVECH('PDEPLMR','L',IDEPLM)
      CALL JEVECH('PDEPLPR','L',IDEPLP)
      CALL JEVECH('PCOMPOR','L',ICOMPO)
      CALL JEVECH('PCARCRI','L',ICARCR)
      CALL TECACH('OON','PVARIMR',7,JTAB,IRET)
      LGPG1 = MAX(JTAB(6),1)*JTAB(7)
      LGPG = LGPG1

C --- ORIENTATION DU MASSIF
C       COORDONNEES DU BARYCENTRE ( POUR LE REPRE CYLINDRIQUE )
      XYZ(1) = 0.D0
      XYZ(2) = 0.D0
      XYZ(3) = 0.D0
      DO 150 I = 1,NNO
        DO 140 IDIM = 1,NDIM
          XYZ(IDIM) = XYZ(IDIM)+ZR(IGEOM+IDIM+NDIM*(I-1)-1)/NNO
140     CONTINUE
150   CONTINUE
      CALL RCANGM ( NDIM, XYZ, ANGMAS )

C - VARIABLES DE COMMANDE

      CALL JEVECH('PTEREF','L',ITREF)
      CALL JEVECH('PTEMPMR','L',ITEMPM)
      CALL JEVECH('PTEMPPR','L',ITEMPP)
      CALL JEVECH('PINSTMR','L',IINSTM)
      CALL JEVECH('PINSTPR','L',IINSTP)

C - PARAMETRES EN SORTIE

      IF (OPTION(1:10).EQ.'RIGI_MECA_' .OR.
     &    OPTION(1:9).EQ.'FULL_MECA') THEN
        CALL NMTSTM(ZK16(ICOMPO),IMATUU,MATSYM)
      END IF

      IF (OPTION(1:9).EQ.'RAPH_MECA' .OR.
     &    OPTION(1:9).EQ.'FULL_MECA') THEN
        CALL JEVECH('PVECTUR','E',IVECTU)
        CALL JEVECH('PCONTPR','E',ICONTP)
        CALL JEVECH('PVARIPR','E',IVARIP)

C      ESTIMATION VARIABLES INTERNES A L'ITERATION PRECEDENTE
        CALL JEVECH('PVARIMP','L',IVARIX)
        CALL DCOPY(NPG1*LGPG,ZR(IVARIX),1,ZR(IVARIP),1)

      END IF


      IF (ZK16(ICOMPO+3) (1:9).EQ.'COMP_ELAS') THEN

C - LOIS DE COMPORTEMENT ECRITES EN CONFIGURATION DE REFERENCE
C                          COMP_ELAS

        IF (OPTION(1:10).EQ.'RIGI_MECA_') THEN

C        OPTION RIGI_MECA_TANG :         ARGUMENTS EN T-
          CALL NMEL3D('RIGI',NNO,NPG1,IPOIDS,IVF,IDFDE,
     &                ZR(IGEOM),TYPMOD,OPTION,ZI(IMATE),
     &                ZK16(ICOMPO),LGPG,ZR(ICARCR),ZR(ITEMPM),
     &                ZR(ITREF),ZR(IDEPLM),ANGMAS,DFDI,
     &                PFF,DEF,ZR(ICONTM),ZR(IVARIM),ZR(IMATUU),
     &                ZR(IVECTU),CODRET)

        ELSE

C        OPTION FULL_MECA OU RAPH_MECA : ARGUMENTS EN T+

          DO 10 LI = 1,3*NNO
            ZR(IDEPLP+LI-1) = ZR(IDEPLM+LI-1) + ZR(IDEPLP+LI-1)
   10     CONTINUE

          CALL NMEL3D('RIGI',NNO,NPG1,IPOIDS,IVF,IDFDE,
     &                ZR(IGEOM),TYPMOD,OPTION,ZI(IMATE),
     &                ZK16(ICOMPO),LGPG,ZR(ICARCR),ZR(ITEMPP),
     &                ZR(ITREF),ZR(IDEPLP),ANGMAS,DFDI,
     &                PFF,DEF,ZR(ICONTP),ZR(IVARIP),ZR(IMATUU),
     &                ZR(IVECTU),CODRET)
        END IF

      ELSE

C - LOIS DE COMPORTEMENT ECRITE EN CONFIGURATION ACTUELLE
C                          COMP_INCR
C      PETITES DEFORMATIONS (AVEC EVENTUELLEMENT REACTUALISATION)
        IF (ZK16(ICOMPO+2) (1:5).EQ.'PETIT') THEN
          IF (ZK16(ICOMPO+2) (6:10).EQ.'_REAC') THEN
            DO 20 I = 1,3*NNO
              ZR(IGEOM+I-1) = ZR(IGEOM+I-1) + ZR(IDEPLM+I-1) +
     &                        ZR(IDEPLP+I-1)
   20       CONTINUE
          END IF
          CALL NMPL3D(NNO,NPG1,IPOIDS,IVF,IDFDE,
     &                ZR(IGEOM),TYPMOD,OPTION,ZI(IMATE),
     &                ZK16(ICOMPO),LGPG,ZR(ICARCR),
     &                ZR(IINSTM),ZR(IINSTP),
     &                ZR(ITEMPM),ZR(ITEMPP),ZR(ITREF),
     &                ZR(IDEPLM),ZR(IDEPLP),
     &                ANGMAS,
     &                ZR(ICONTM),ZR(IVARIM),
     &                .TRUE.,DFDI,DEF,ZR(ICONTP),ZR(IVARIP),
     &                ZR(IMATUU),ZR(IVECTU),CODRET)


C 7.3 - GRANDES ROTATIONS ET PETITES DEFORMATIONS
        ELSE IF (ZK16(ICOMPO+2) (1:5).EQ.'GREEN') THEN

          DO 50 LI = 1,3*NNO
            ZR(IDEPLP+LI-1) = ZR(IDEPLM+LI-1) + ZR(IDEPLP+LI-1)
   50     CONTINUE

          CALL NMGR3D(NNO,NPG1,IPOIDS,IVF,IDFDE,
     &                ZR(IGEOM),TYPMOD,OPTION,ZI(IMATE),
     &                ZK16(ICOMPO),LGPG,ZR(ICARCR),
     &                ZR(IINSTM),ZR(IINSTP),
     &                ZR(ITEMPM),ZR(ITEMPP),ZR(ITREF),
     &                ZR(IDEPLM),ZR(IDEPLP),
     &                ANGMAS,
     &                ZR(ICONTM),ZR(IVARIM),MATSYM,
     &                DFDI,PFF,DEF,ZR(ICONTP),ZR(IVARIP),
     &                ZR(IMATUU),ZR(IVECTU),CODRET)

C      GRANDES DEFORMATIONS : FORMULATION SIMO - MIEHE
C       DESACTIVE EN ATTENDANT LA NOUVELLE FORMULATION POUR GRAD_VARI

        ELSE IF (ZK16(ICOMPO+2) (1:10).EQ.'SIMO_MIEHE') THEN
           CALL U2MESS('F','ELEMENTS5_10')

        ELSE
          CALL U2MESK('F','ELEMENTS3_16',1,ZK16(ICOMPO+2))
        END IF

      END IF

      IF (OPTION(1:9).EQ.'RAPH_MECA' .OR.
     &    OPTION(1:9).EQ.'FULL_MECA') THEN
        CALL JEVECH('PCODRET','E',JCRET)
        ZI(JCRET) = CODRET
      END IF

      END
