      SUBROUTINE TE0139(OPTION,NOMTE)
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

      IMPLICIT NONE
      CHARACTER*16 OPTION,NOMTE
C ......................................................................
C    - FONCTION REALISEE:  CALCUL DES OPTIONS NON-LINEAIRES MECANIQUES
C                          ELEMENTS 3D
C    - ARGUMENTS:
C        DONNEES:      OPTION       -->  OPTION DE CALCUL
C                      NOMTE        -->  NOM DU TYPE ELEMENT
C ......................................................................
      CHARACTER*8 TYPMOD(2)
      INTEGER JGANO,NNO,NPG,I,IMATUU,LGPG,NDIM,LGPG1,IRET
      INTEGER IPOIDS,IVF,IDFDE,IGEOM,IMATE
      INTEGER ITREF,ICONTM,IVARIM,ITEMPM,ITEMPP,IPHASM,IPHASP
      INTEGER IINSTM,IINSTP,IDEPLM,IDEPLP,ICOMPO,ICARCR
      INTEGER IVECTU,ICONTP,IVARIP,LI,IDEFAM,IDEFAP,JCRET,CODRET
      INTEGER IHYDRM,IHYDRP,ISECHM,ISECHP,IVARIX
      LOGICAL DEFANE, MATSYM
      INTEGER NDDL,KK,NI,MJ,JTAB(7),NZ,NNOS,ICORRM,ICORRP
      REAL*8 MATNS(3*27*3*27),CORRM,CORRP
      REAL*8 PFF(6*27*27),DEF(6*27*3),DFDI(3*27),DFDI2(3*27)

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


C - FONCTIONS DE FORMES ET POINTS DE GAUSS
      CALL ELREF4(' ','RIGI',NDIM,NNO,NNOS,NPG,IPOIDS,IVF,IDFDE,JGANO)
      IF (NNO.GT.27) CALL UTMESS('F','TE0139','MATNS MAL DIMENSIONNEE')

C - TYPE DE MODELISATION
      TYPMOD(1) = '3D      '
      TYPMOD(2) = '        '

C - PARAMETRES EN ENTREE

      CALL JEVECH('PGEOMER','L',IGEOM)
      CALL JEVECH('PMATERC','L',IMATE)
      CALL JEVECH('PCONTMR','L',ICONTM)
      CALL JEVECH('PVARIMR','L',IVARIM)
      CALL JEVECH('PDEPLMR','L',IDEPLM)
      CALL JEVECH('PDEPLPR','L',IDEPLP)
      CALL JEVECH('PCOMPOR','L',ICOMPO)
      CALL JEVECH('PCARCRI','L',ICARCR)
      CALL JEVECH('PCORRMR','L',ICORRM)
      CORRM = ZR(ICORRM)
      CALL JEVECH('PCORRPR','L',ICORRP)
      CORRP = ZR(ICORRP)
      CALL TECACH('OON','PVARIMR',7,JTAB,IRET)
      LGPG1 = MAX(JTAB(6),1)*JTAB(7)
      LGPG = LGPG1


C - VARIABLES DE COMMANDE

      CALL JEVECH('PTEREF','L',ITREF)
      CALL JEVECH('PTEMPMR','L',ITEMPM)
      CALL JEVECH('PTEMPPR','L',ITEMPP)
      CALL JEVECH('PINSTMR','L',IINSTM)
      CALL JEVECH('PINSTPR','L',IINSTP)
      CALL JEVECH('PHYDRMR','L',IHYDRM)
      CALL JEVECH('PHYDRPR','L',IHYDRP)
      CALL JEVECH('PSECHMR','L',ISECHM)
      CALL JEVECH('PSECHPR','L',ISECHP)
      CALL TECACH('ONN','PDEFAMR',1,IDEFAM,IRET)
      CALL TECACH('ONN','PDEFAPR',1,IDEFAP,IRET)
      DEFANE = IDEFAM .NE. 0
      CALL TECACH('NNN','PPHASMR',1,IPHASM,IRET)
      CALL TECACH('NNN','PPHASPR',1,IPHASP,IRET)
      IF (IPHASP.NE.0) THEN
        CALL TECACH('OON','PPHASPR',7,JTAB,IRET)
        NZ = JTAB(6)
      END IF

C - PARAMETRES EN SORTIE

      IF (OPTION(1:10).EQ.'RIGI_MECA_' .OR.
     &    OPTION(1:9).EQ.'FULL_MECA') THEN
          CALL NMTSTM(ZK16(ICOMPO),IMATUU,MATSYM)
      ENDIF


      IF (OPTION(1:9).EQ.'RAPH_MECA' .OR.
     &    OPTION(1:9).EQ.'FULL_MECA') THEN
        CALL JEVECH('PVECTUR','E',IVECTU)
        CALL JEVECH('PCONTPR','E',ICONTP)
        CALL JEVECH('PVARIPR','E',IVARIP)

C      ESTIMATION VARIABLES INTERNES A L'ITERATION PRECEDENTE
        CALL JEVECH('PVARIMP','L',IVARIX)
        CALL R8COPY(NPG*LGPG,ZR(IVARIX),1,ZR(IVARIP),1)

      END IF


      IF (ZK16(ICOMPO+3) (1:9).EQ.'COMP_ELAS') THEN

C - LOIS DE COMPORTEMENT ECRITES EN CONFIGURATION DE REFERENCE
C                          COMP_ELAS

        IF (OPTION(1:10).EQ.'RIGI_MECA_') THEN

C        OPTION RIGI_MECA_TANG :         ARGUMENTS EN T-
          CALL NMEL3D(NNO,NPG,IPOIDS,IVF,IDFDE,
     &                ZR(IGEOM),TYPMOD,OPTION,ZI(IMATE),
     &                ZK16(ICOMPO),LGPG,ZR(ICARCR),ZR(ITEMPM),
     &                ZR(IHYDRM),ZR(ISECHM),ZR(ITREF),ZR(IDEPLM),DFDI,
     &                PFF,DEF,ZR(ICONTM),ZR(IVARIM),ZR(IMATUU),
     &                ZR(IVECTU),CODRET)

        ELSE

C        OPTION FULL_MECA OU RAPH_MECA : ARGUMENTS EN T+

          DO 10 LI = 1,3*NNO
            ZR(IDEPLP+LI-1) = ZR(IDEPLM+LI-1) + ZR(IDEPLP+LI-1)
   10     CONTINUE

          CALL NMEL3D(NNO,NPG,IPOIDS,IVF,IDFDE,
     &                ZR(IGEOM),TYPMOD,OPTION,ZI(IMATE),
     &                ZK16(ICOMPO),LGPG,ZR(ICARCR),ZR(ITEMPP),
     &                ZR(IHYDRP),ZR(ISECHP),ZR(ITREF),ZR(IDEPLP),DFDI,
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
          CALL NMPL3D(NNO,NPG,IPOIDS,IVF,IDFDE,
     &                ZR(IGEOM),TYPMOD,OPTION,ZI(IMATE),
     &                ZK16(ICOMPO),LGPG,ZR(ICARCR),ZR(IINSTM),
     &                ZR(IINSTP),ZR(ITEMPM),ZR(ITEMPP),ZR(IHYDRM),
     &                ZR(IHYDRP),ZR(ISECHM),ZR(ISECHP),NZ,ZR(IPHASM),
     &                ZR(IPHASP),ZR(ITREF),ZR(IDEPLM),ZR(IDEPLP),
     &                ZR(IDEFAM),ZR(IDEFAP),DEFANE,ZR(ICONTM),
     &                ZR(IVARIM),MATSYM,DFDI,DEF,ZR(ICONTP),ZR(IVARIP),
     &                ZR(IMATUU),ZR(IVECTU),CODRET,CORRM,CORRP)


C      GRANDES DEFORMATIONS : FORMULATION SIMO - MIEHE

        ELSE IF (ZK16(ICOMPO+2) (1:10).EQ.'SIMO_MIEHE') THEN
          CALL NMGP3D(NNO,NPG,IPOIDS,IVF,IDFDE,
     &                ZR(IGEOM),TYPMOD,OPTION,ZI(IMATE),
     &                ZK16(ICOMPO),LGPG,ZR(ICARCR),ZR(IINSTM),
     &                ZR(IINSTP),ZR(ITEMPM),ZR(ITEMPP),ZR(IHYDRM),
     &                ZR(IHYDRP),ZR(ISECHM),ZR(ISECHP),NZ,ZR(IPHASM),
     &                ZR(IPHASP),ZR(ITREF),ZR(IDEPLM),ZR(IDEPLP),
     &                ZR(ICONTM),ZR(IVARIM),DFDI,DFDI2,ZR(ICONTP),
     &                ZR(IVARIP),MATNS,ZR(IVECTU),CODRET,CORRM,CORRP)

C        SYMETRISATION DE MATNS DANS MATUU
          IF (OPTION(1:10).EQ.'RIGI_MECA_' .OR.
     &        OPTION(1:9).EQ.'FULL_MECA') THEN
            NDDL = 3*NNO
            KK = 0
            DO 40 NI = 1,NDDL
              DO 30 MJ = 1,NI
                ZR(IMATUU+KK) = (MATNS((NI-1)*NDDL+MJ)+
     &                          MATNS((MJ-1)*NDDL+NI))/2.D0
                KK = KK + 1
   30         CONTINUE
   40       CONTINUE
          END IF

C 7.3 - GRANDES ROTATIONS ET PETITES DEFORMATIONS
        ELSE IF (ZK16(ICOMPO+2) (1:5).EQ.'GREEN') THEN

          DO 50 LI = 1,3*NNO
            ZR(IDEPLP+LI-1) = ZR(IDEPLM+LI-1) + ZR(IDEPLP+LI-1)
   50     CONTINUE

          CALL NMGR3D(NNO,NPG,IPOIDS,IVF,IDFDE,
     &                ZR(IGEOM),TYPMOD,OPTION,ZI(IMATE),
     &                ZK16(ICOMPO),LGPG,ZR(ICARCR),ZR(IINSTM),
     &                ZR(IINSTP),ZR(ITEMPM),ZR(ITEMPP),ZR(IHYDRM),
     &                ZR(IHYDRP),ZR(ISECHM),ZR(ISECHP),NZ,ZR(IPHASM),
     &                ZR(IPHASP),ZR(ITREF),ZR(IDEPLM),ZR(IDEPLP),
     &                ZR(IDEFAM),ZR(IDEFAP),DEFANE,ZR(ICONTM),
     &                ZR(IVARIM),DFDI,PFF,DEF,ZR(ICONTP),ZR(IVARIP),
     &                ZR(IMATUU),ZR(IVECTU),CODRET,CORRM,CORRP)
        ELSE
          CALL UTMESS('F','TE0139','COMPORTEMENT:'//ZK16(ICOMPO+2)//
     &                'NON IMPLANTE')
        END IF

      END IF

      IF (OPTION(1:9).EQ.'RAPH_MECA' .OR.
     &    OPTION(1:9).EQ.'FULL_MECA') THEN
        CALL JEVECH('PCODRET','E',JCRET)
        ZI(JCRET) = CODRET
      END IF

      END
