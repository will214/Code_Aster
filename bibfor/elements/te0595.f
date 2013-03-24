      SUBROUTINE TE0595(OPTION,NOMTE)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 18/03/2013   AUTEUR SFAYOLLE S.FAYOLLE 
C ======================================================================
C COPYRIGHT (C) 1991 - 2013  EDF R&D                  WWW.CODE-ASTER.ORG
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
C RESPONSABLE SFAYOLLE S.FAYOLLE
      IMPLICIT  NONE
      INCLUDE 'jeveux.h'

      CHARACTER*16 OPTION,NOMTE
C ----------------------------------------------------------------------
C FONCTION REALISEE:  CALCUL DES FORCES INTERNES POUR LES ELEMENTS
C                     INCOMPRESSIBLES A 2 CHAMPS UP
C                     EN 3D/D_PLAN/AXI
C
C    - ARGUMENTS:
C        DONNEES:      OPTION       -->  OPTION DE CALCUL
C                      NOMTE        -->  NOM DU TYPE ELEMENT
C ----------------------------------------------------------------------

      LOGICAL      RIGI,RESI,LTEATT,MINI,MATSYM
      INTEGER      NDIM,NNO1,NNO2,NPG,NNOS,JGN,NTROU
      INTEGER      ICORET,CODRET,IRET
      INTEGER      IW,IVF1,IVF2,IDF1,IDF2
      INTEGER      JTAB(7),LGPG,I,IDIM
      INTEGER      VU(3,27),VG(27),VP(27),VPI(3,27)
      INTEGER      IGEOM,IMATE,ICONTM,IVARIM
      INTEGER      IINSTM,IINSTP,IDDLM,IDDLD,ICOMPO,ICARCR
      INTEGER      IVECTU,ICONTP,IVARIP,IMATUU
      INTEGER      IDBG,NDDL,IA,JA,IBID
      REAL*8       ANGMAS(7),BARY(3)
      CHARACTER*8  LIELRF(10),TYPMOD(2),ALIAS8
C ----------------------------------------------------------------------

      IDBG = 0

C - FONCTIONS DE FORMES ET POINTS DE GAUSS
      CALL ELREF2(NOMTE,10,LIELRF,NTROU)
      CALL ASSERT(NTROU.GE.2)
      CALL ELREF4(LIELRF(2),'RIGI',NDIM,NNO2,NNOS,NPG,IW,IVF2,IDF2,JGN)
      CALL ELREF4(LIELRF(1),'RIGI',NDIM,NNO1,NNOS,NPG,IW,IVF1,IDF1,JGN)
      MATSYM = .TRUE.

C - TYPE DE MODELISATION
      IF (NDIM.EQ.2 .AND. LTEATT(' ','AXIS','OUI')) THEN
        TYPMOD(1) = 'AXIS  '
      ELSE IF (NDIM.EQ.2 .AND. LTEATT(' ','D_PLAN','OUI')) THEN
        TYPMOD(1) = 'D_PLAN  '
      ELSE IF (NDIM .EQ. 3) THEN
        TYPMOD(1) = '3D'
      ELSE
        CALL U2MESK('F','ELEMENTS_34',1,NOMTE)
      END IF
      TYPMOD(2) = '        '
      CODRET = 0

C - OPTION
      RESI = OPTION(1:4).EQ.'RAPH' .OR. OPTION(1:4).EQ.'FULL'
      RIGI = OPTION(1:4).EQ.'RIGI' .OR. OPTION(1:4).EQ.'FULL'

C - PARAMETRES EN ENTREE
      CALL JEVECH('PGEOMER','L',IGEOM)
      CALL JEVECH('PMATERC','L',IMATE)
      CALL JEVECH('PCONTMR','L',ICONTM)
      CALL JEVECH('PVARIMR','L',IVARIM)
      CALL JEVECH('PDEPLMR','L',IDDLM)
      CALL JEVECH('PDEPLPR','L',IDDLD)
      CALL JEVECH('PCOMPOR','L',ICOMPO)
      CALL JEVECH('PCARCRI','L',ICARCR)

      CALL JEVECH('PINSTMR','L',IINSTM)
      CALL JEVECH('PINSTPR','L',IINSTP)

      CALL TECACH('OON','PVARIMR','L',7,JTAB,IRET)
      LGPG = MAX(JTAB(6),1)*JTAB(7)

C - ORIENTATION DU MASSIF
C - COORDONNEES DU BARYCENTRE ( POUR LE REPRE CYLINDRIQUE )
      BARY(1) = 0.D0
      BARY(2) = 0.D0
      BARY(3) = 0.D0
      DO 150 I = 1,NNO1
        DO 140 IDIM = 1,NDIM
          BARY(IDIM) = BARY(IDIM)+ZR(IGEOM+IDIM+NDIM*(I-1)-1)/NNO1
 140    CONTINUE
 150  CONTINUE
      CALL RCANGM(NDIM,BARY,ANGMAS)

C - PARAMETRES EN SORTIE
      IF (RESI) THEN
        CALL JEVECH('PVECTUR','E',IVECTU)
        CALL JEVECH('PCONTPR','E',ICONTP)
        CALL JEVECH('PVARIPR','E',IVARIP)
      ELSE
        IVECTU=1
        ICONTP=1
        IVARIP=1
      END IF

      IF (ZK16(ICOMPO+2) (1:6).EQ.'PETIT ') THEN
C - PARAMETRES EN SORTIE
        IF (RIGI) THEN
          CALL JEVECH('PMATUUR','E',IMATUU)
        ELSE
          IMATUU=1
        END IF

        IF (LTEATT(' ','INCO','C2PD ')) THEN

C - MINI ELEMENT ?
          CALL TEATTR(' ','S','ALIAS8',ALIAS8,IBID)
          IF (ALIAS8(6:8).EQ.'TR3' .OR. ALIAS8(6:8) .EQ. 'TE4') THEN
            MINI = .TRUE.
          ELSE
            MINI = .FALSE.
          END IF

C - ACCES AUX COMPOSANTES DU VECTEUR DDL
          CALL NIINIT(NOMTE,TYPMOD,NDIM,NNO1,0,NNO2,0,VU,VG,VP,VPI)
          NDDL = NNO1*NDIM + NNO2

          CALL NUFIPD(NDIM,NNO1,NNO2,NPG,IW,ZR(IVF1),ZR(IVF2),IDF1,
     &                VU,VP,ZR(IGEOM),TYPMOD,OPTION,ZI(IMATE),
     &                ZK16(ICOMPO),LGPG,ZR(ICARCR),ZR(IINSTM),
     &                ZR(IINSTP),ZR(IDDLM),ZR(IDDLD),ANGMAS,
     &                ZR(ICONTM),ZR(IVARIM),ZR(ICONTP),ZR(IVARIP),
     &                RESI,RIGI,MINI,ZR(IVECTU),ZR(IMATUU),CODRET)
        ELSEIF (LTEATT(' ','INCO','C2PDO')) THEN
C - ACCES AUX COMPOSANTES DU VECTEUR DDL
          CALL NIINIT(NOMTE,TYPMOD,NDIM,NNO1,0,NNO2,NNO2,VU,VG,VP,VPI)
          NDDL = NNO1*NDIM + NNO2 + NNO2*NDIM

          CALL NOFIPD(NDIM,NNO1,NNO2,NNO2,NPG,IW,ZR(IVF1),ZR(IVF2),
     &                ZR(IVF2),IDF1,VU,VP,VPI,ZR(IGEOM),TYPMOD,OPTION,
     &                NOMTE,ZI(IMATE),ZK16(ICOMPO),LGPG,ZR(ICARCR),
     &                ZR(IINSTM),ZR(IINSTP),ZR(IDDLM),ZR(IDDLD),ANGMAS,
     &                ZR(ICONTM),ZR(IVARIM),ZR(ICONTP),ZR(IVARIP),
     &                RESI,RIGI,ZR(IVECTU),ZR(IMATUU),CODRET)
        ELSE
          CALL ASSERT(.FALSE.)
        END IF
      ELSEIF (ZK16(ICOMPO+2) (1:8).EQ.'GDEF_LOG') THEN
C - PARAMETRES EN SORTIE
        IF (RIGI) THEN
          CALL NMTSTM(ZK16(ICOMPO),IMATUU,MATSYM)
        ELSE
          IMATUU=1
        END IF

        IF (LTEATT(' ','INCO','C2LG ')) THEN

C - ACCES AUX COMPOSANTES DU VECTEUR DDL
          CALL NIINIT(NOMTE,TYPMOD,NDIM,NNO1,0,NNO2,0,VU,VG,VP,VPI)
          NDDL = NNO1*NDIM + NNO2

          CALL NUFILG(NDIM,NNO1,NNO2,NPG,IW,ZR(IVF1),ZR(IVF2),IDF1,
     &                VU,VP,ZR(IGEOM),TYPMOD,OPTION,ZI(IMATE),
     &                ZK16(ICOMPO),LGPG,ZR(ICARCR),ZR(IINSTM),
     &                ZR(IINSTP),ZR(IDDLM),ZR(IDDLD),ANGMAS,
     &                ZR(ICONTM),ZR(IVARIM),ZR(ICONTP),ZR(IVARIP),
     &                RESI,RIGI,ZR(IVECTU),ZR(IMATUU),MATSYM,CODRET)

        ELSE
          CALL ASSERT(.FALSE.)
        END IF
      ELSE
        CALL U2MESK('F','ELEMENTS3_16',1,ZK16(ICOMPO+2))
      END IF

      IF (RESI) THEN
        CALL JEVECH('PCODRET','E',ICORET)
        ZI(ICORET) = CODRET
      END IF

      IF (IDBG.EQ.1) THEN
        IF (RIGI) THEN
          WRITE(6,*) 'MATRICE TANGENTE'
          DO 10 IA = 1,NDDL
            WRITE(6,'(108(1X,E11.4))')
     &      (ZR(IMATUU+(IA*(IA-1)/2)+JA-1),JA=1,IA)
 10       CONTINUE
        END IF
        IF (RESI) THEN
          WRITE(6,*) 'FORCE INTERNE'
          WRITE(6,'(108(1X,E11.4))') (ZR(IVECTU+JA-1),JA=1,NDDL)
        ENDIF
      ENDIF

      END
