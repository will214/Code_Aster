      SUBROUTINE MMEXCR(NOMA  ,NEQ   ,DEFICO,RESOCO,LPIVAU,
     &                  LSSCON,POSMAE,NDEXCL,TYPRAC,TYPBAR,
     &                  NDEXFR)
C     
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 14/09/2010   AUTEUR ABBAS M.ABBAS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2008  EDF R&D                  WWW.CODE-ASTER.ORG
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
      LOGICAL       LPIVAU,LSSCON
      INTEGER       POSMAE,NEQ
      CHARACTER*24  DEFICO,RESOCO
      CHARACTER*8   NOMA
      INTEGER       TYPRAC,TYPBAR,NDEXFR
      INTEGER       NDEXCL(9)
C
C ----------------------------------------------------------------------
C
C ROUTINE CONTACT (METHODE CONTINUE - APPARIEMENT)
C
C EXCLUE LES NOEUDS SUIVANT OPTIONS
C      
C ----------------------------------------------------------------------
C
C
C IN  NOMA   : NOM DU MAILLAGE
C IN  NEQ    : NOMBRE D'EQUATIONS DU SYSTEME
C IN  LPIVAU : IL Y A EXCLUSION_PIV_NUL
C IN  LSSCON : IL Y A DES NOEUDS DANS SANS_GROUP_NO
C IN  DEFICO : SD POUR LA DEFINITION DE CONTACT 
C IN  RESOCO : SD POUR LA RESOLUTION DE CONTACT 
C IN  POSMAE : POSITION DE LA MAILLE ESCLAVE DANS LES SD CONTACT
C OUT NDEXCL : NOEUDS EXCLUS SUR LA MAILLE
C OUT NDEXFR : ENTIER CODE POUR LES NOEUDS INTERDITS DANS
C              SANS_GROUP_NO_FR OU SANS_NOEUD_FR
C OUT TYPBAR : NOEUDS EXCLUS PAR CET ELEMENT DE BARSOUM
C               TYPBAR = 0
C                PAS DE FOND DE FISSURE
C               TYPBAR = 1
C                QUAD 8 - FOND FISSURE: 1-2
C               TYPBAR = 2
C                QUAD 8 - FOND FISSURE: 2-3
C               TYPBAR = 3
C                QUAD 8 - FOND FISSURE: 3-4
C               TYPBAR = 4
C                QUAD 8 - FOND FISSURE: 4-1
C               TYPBAR = 5
C                SEG 3  - FOND FISSURE: 1
C               TYPBAR = 6
C                SEG 3  - FOND FISSURE: 2
C OUT TYPRAC : TYPE DE RACCORD LINE/QUAD (ON EST SUR UN QUAD8/9)
C               1 - NOEUD MILIEU 5 EXCLU
C               2 - NOEUD MILIEU 6 EXCLU
C               3 - NOEUD MILIEU 7 EXCLU
C               4 - NOEUD MILIEU 8 EXCLU
C
C -------------- DEBUT DECLARATIONS NORMALISEES JEVEUX -----------------
C
      CHARACTER*32 JEXNUM
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
C ---------------- FIN DECLARATIONS NORMALISEES JEVEUX -----------------
C
      CHARACTER*24 TGELNO
      INTEGER      JTGELN
      REAL*8       TAU1(3),TAU2(3),NORM(3),NOOR     
      INTEGER      I
      INTEGER      CFDISI,NDIMG
      INTEGER      POSNNO(9),NUMNNO(9)
      INTEGER      INOE,NNOMAI,NUMNOE
      LOGICAL      EXNOE
      CHARACTER*8  NOMNOE
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ() 
C
C --- INITIALISATIONS
C
      DO 10 I=1,9
        NDEXCL(I) = 0
   10 CONTINUE 
C
C --- TYPE DU NOEUD EXCLU PAR GROUP_NO_RACC
C     
      CALL MMINFM(POSMAE,DEFICO,'TYPRAC',TYPRAC)
C
C --- TYPE DE LA MAILLE SI BARSOUM
C
      CALL MMINFM(POSMAE,DEFICO,'TYPBAR',TYPBAR)
C
C --- ENTIER CODE POUR LES NOEUDS INTERDITS DANS
C --- SANS_GROUP_NO_FR OU SANS_NOEUD_FR
C
      CALL MMINFM(POSMAE,DEFICO,'NDEXFR',NDEXFR)
C
      IF ((.NOT.LPIVAU).AND.(.NOT.LSSCON)) GOTO 99      
C
C --- ACCES OBJETS
C 
      TGELNO = RESOCO(1:14)//'.TGELNO'            
C
C --- ACCES A LA MAILLE ESCLAVE
C      
      NDIMG  = CFDISI(DEFICO,'NDIM') 
      CALL CFPOSN(DEFICO,POSMAE,POSNNO,NNOMAI) 
      CALL ASSERT(NNOMAI.LE.9) 
      CALL CFNUMN(DEFICO,NNOMAI,POSNNO,NUMNNO)  
      CALL JEVEUO(JEXNUM(TGELNO,POSMAE),'L',JTGELN) 
C
C --- BOUCLE SUR LES NOEUDS
C
      DO 15 INOE = 1,NNOMAI
        NUMNOE = NUMNNO(INOE)
        CALL JENUNO(JEXNUM(NOMA//'.NOMNOE',NUMNOE),NOMNOE) 
        IF (LPIVAU) THEN          
C       --- NORMALE AU NOEUD      
          TAU1(1) = ZR(JTGELN+6*(INOE-1)+1 -1)
          TAU1(2) = ZR(JTGELN+6*(INOE-1)+2 -1)
          TAU1(3) = ZR(JTGELN+6*(INOE-1)+3 -1)
          TAU2(1) = ZR(JTGELN+6*(INOE-1)+4 -1)
          TAU2(2) = ZR(JTGELN+6*(INOE-1)+5 -1)
          TAU2(3) = ZR(JTGELN+6*(INOE-1)+6 -1) 
          CALL MMNORM(NDIMG ,TAU1  ,TAU2  ,NORM  ,NOOR)       
C       --- ON TESTE SI NOEUDS DE LA MAILLE IMPLIQUES DANS RELATIONS
C       --- DE TYPE LAGRANGE/LIAISON_DDL   

          EXNOE  = .FALSE.
          CALL REDCEX(NDIMG ,RESOCO,NEQ   ,NUMNOE,NORM  ,
     &                EXNOE )
          IF (EXNOE) THEN
            NDEXCL(INOE) = 1
          ENDIF
        ENDIF
  15  CONTINUE
C
  99  CONTINUE
C
      CALL JEDEMA()      
C
      END
