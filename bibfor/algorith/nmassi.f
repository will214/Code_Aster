      SUBROUTINE NMASSI(MODELE,NUMEDD,LISCHA,FONACT,SDDYNA,
     &                  VALINC,VEELEM,VEASSE,CNDONN,MATASS)
C ----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 14/06/2011   AUTEUR TARDIEU N.TARDIEU 
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
C RESPONSABLE ABBAS M.ABBAS
C
      IMPLICIT NONE
      INTEGER      FONACT(*)
      CHARACTER*19 SDDYNA,LISCHA
      CHARACTER*24 NUMEDD,MODELE
      CHARACTER*19 VALINC(*)
      CHARACTER*19 VEASSE(*),VEELEM(*)
      CHARACTER*19 CNDONN,MATASS
C
C ----------------------------------------------------------------------
C
C ROUTINE MECA_NON_LINE (ALGORITHME)
C
C CALCUL DU SECOND MEMBRE POUR LE CALCUL DE L'ACCELERATION INITIALE
C
C ----------------------------------------------------------------------
C
C
C IN  MODELE : NOM DU MODELE
C IN  NUMEDD : NOM DE LA NUMEROTATION
C IN  LISCHA : LISTE DES CHARGES
C IN  FONACT : FONCTIONNALITES ACTIVEES
C IN  SDDYNA : SD DYNAMIQUE
C IN  VEELEM : VARIABLE CHAPEAU POUR NOM DES VECT_ELEM
C IN  VEASSE : VARIABLE CHAPEAU POUR NOM DES VECT_ASSE
C IN  VALINC : VARIABLE CHAPEAU POUR INCREMENTS VARIABLES
C OUT CNDONN : SECOND MEMBRE CALCULE
C IN  MATASS : SD MATRICE ASSEMBLEE
C
C -------------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ----------------
C
      INTEGER ZI
      COMMON /IVARJE/ ZI(1)
      REAL*8 ZR
      COMMON /RVARJE/ ZR(1)
      COMPLEX*16 ZC
      COMMON /CVARJE/ ZC(1)
      LOGICAL ZL
      COMMON /LVARJE/ ZL(1)
      CHARACTER*8 ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
      COMMON /KVARJE/ ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C
C -------------- FIN  DECLARATIONS  NORMALISEES  JEVEUX ----------------
C
      INTEGER      IFM,NIV
      INTEGER      I,NBVEC,NBCOEF
      CHARACTER*19 VEBUDI
      CHARACTER*19 CNFFDO,CNDFDO,CNFVDO
      PARAMETER    (NBCOEF=8)
      REAL*8       COEF(NBCOEF)
      CHARACTER*19 VECT(NBCOEF)
      CHARACTER*19 CNFNOD,CNBUDI,DEPMOI
      LOGICAL      NDYNLO,ISFONC,LONDE,LLAPL
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
      CALL INFDBG('MECA_NON_LINE',IFM,NIV)
C
C --- AFFICHAGE
C
      IF (NIV.GE.2) THEN
        WRITE (IFM,*) '<MECANONLINE> ...... CALCUL SECOND MEMBRE'
      ENDIF
C
C --- FONCTIONNALITES ACTIVEES
C
      LONDE  = NDYNLO(SDDYNA,'ONDE_PLANE')
      LLAPL  = ISFONC(FONACT,'LAPLACE')
      IF (LONDE.OR.LLAPL) THEN
        CALL U2MESS('A','MECANONLINE_23')
      ENDIF
C
C --- INITIALISATIONS
C
      CNFFDO = '&&CNCHAR.FFDO'
      CNDFDO = '&&CNCHAR.DFDO'
      CNFVDO = '&&CNCHAR.FVDO'
C
C --- DECOMPACTION DES VARIABLES CHAPEAUX
C
      CALL NMCHEX(VALINC,'VALINC','DEPMOI',DEPMOI)
C
C --- CALCUL DU VECTEUR DES FORCES FIXES
C
      CALL NMACFI(FONACT,VEASSE,CNFFDO,CNDFDO)
C
C --- CALCUL DU VECTEUR DES FORCES VARIABLES
C
      CALL NMACVA(VEASSE,CNFVDO)
C
C --- FORCES NODALES
C
      CALL NMCHEX(VEASSE,'VEASSE','CNFNOD',CNFNOD)
C
C --- CONDITIONS DE DIRICHLET B.U
C
      CALL NMCHEX(VEASSE,'VEASSE','CNBUDI',CNBUDI)
      CALL NMCHEX(VEELEM,'VEELEM','CNBUDI',VEBUDI)
      CALL NMBUDI(MODELE,NUMEDD,LISCHA,DEPMOI,VEBUDI,
     &            CNBUDI,MATASS)
C
C --- VALEURS POUR SOMME DES FORCES
C
      NBVEC   = 5
      COEF(1) = 1.D0
      COEF(2) = 1.D0
      COEF(3) = -1.D0
      COEF(4) = -1.D0
      COEF(5) = 1.D0
      VECT(1) = CNFFDO
      VECT(2) = CNFVDO
      VECT(3) = CNFNOD
      VECT(4) = CNBUDI
      VECT(5) = CNDFDO
C
C --- FORCES DONNEES
C
      IF (NBVEC.GT.NBCOEF) THEN
        CALL ASSERT(.FALSE.)
      ENDIF
      DO 10 I = 1,NBVEC
        CALL VTAXPY(COEF(I),VECT(I),CNDONN)
 10   CONTINUE
C
      CALL JEDEMA()
      END
