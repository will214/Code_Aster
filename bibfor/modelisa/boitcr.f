      SUBROUTINE BOITCR(NOMBOI,BASE  ,NMA   ,NDIME ,NPAN  ,
     &                  NSOM  )
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF MODELISA  DATE 09/01/2007   AUTEUR ABBAS M.ABBAS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2007  EDF R&D                  WWW.CODE-ASTER.ORG
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
      CHARACTER*1  BASE
      CHARACTER*16 NOMBOI
      INTEGER      NMA,NDIME,NPAN,NSOM          
C      
C ----------------------------------------------------------------------
C
C CONSTRUCTION DE BOITES ENGLOBANTES POUR UN ENSEMBLE DE MAILLES
C 
C CREATION DE LA SD BOITE
C
C ----------------------------------------------------------------------
C
C
C IN  NOMBOI : NOM DE LA SD BOITE
C IN  BASE   : TYPE DE BASE ('V' OU 'G')
C IN  NMA    : NOMBRE DE MAILLES (= NOMBRE DE BOITES)
C IN  NDIME  : DIMENSION DE L'ESPACE (2 OU 3)
C IN  NPAN   : NOMBRE DE PANS
C IN  NSOM   : NOMBRE DE SOMMETS
C
C SD PRODUITE
C
C NOMBOI(1:16)//'.DIME'   : DIMENSIONS ET INDEX DE LA SD BOITE
C               ( DIME, NMA, PAN1, SOM1, PAN2, ...)
C                 DIME : DIMENSION DE L'ESPACE
C                 NMA  : NOMBRE DE MAILLES
C                 PAN* : INDEX DES PANS DE MA* DANS BOITE.PAN
C                 SOM* : INDEX DES SOMMETS DE MA* DANS BOITE.SOMMET
C NOMBOI(1:16)//'.MINMAX' : BOITES ENGLOBANT LES MAILLES 
C                 SUIVANT X, Y, [Z]
C                (X1MIN,X1MAX,Y1MIN,Y1MAX,[Z1MIN],[Z1MAX],X2MIN,...)
C NOMBOI(1:16)//'.PAN'    : PANS (2D = ARETES, 3D = FACES) DES CONVEXES
C                ENGLOBANTS ET INSCRITS DES MAILLES
C                (A1,B1,[C1],D1,E1,A2...)
C                   TELS QUE AX+BY+[CZ]+D<=0 (CONVEXE ENGLOBANT)
C                   ET       AX+BY+[CZ]+E<=0 (CONVEXE INSCRIT)
C NOMBOI(1:16)//'.SOMMET' : SOMMETS DES CONVEXES ENGLOBANT LES MAILLES
C                (X1,Y1,[Z1],X2,...)
C NOMBOI(1:16)//'.MMGLOB' : BOITE ENGLOBANT TOUTES LES MAILLES DE NGRMA
C                (XMIN,XMAX,YMIN,YMAX,[ZMIN,ZMAX])
C NOMBOI(1:16)//'.H'      : TAILLE MOYENNE DES MAILLES
C                (H1,H2,...)
C
C
C --------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ---------------------
C
      INTEGER            ZI
      COMMON  / IVARJE / ZI(1)
      REAL*8             ZR
      COMMON  / RVARJE / ZR(1)
      COMPLEX*16         ZC
      COMMON  / CVARJE / ZC(1)
      LOGICAL            ZL
      COMMON  / LVARJE / ZL(1)
      CHARACTER*8        ZK8
      CHARACTER*16                ZK16
      CHARACTER*24                          ZK24
      CHARACTER*32                                    ZK32
      CHARACTER*80                                              ZK80
      COMMON  / KVARJE / ZK8(1) , ZK16(1) , ZK24(1) , ZK32(1) , ZK80(1)
C      
C --- FIN DECLARATIONS NORMALISEES JEVEUX ------------------------------
C
      INTEGER      IBID,IDIME
      INTEGER      LGBDI,LGBMI,LGBPA,LGBSO,LGBMM,LGBH   
      INTEGER      JDIME,JMMGL
      REAL*8       R8MAEM        
C      
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
C
C --- LONGUEURS
C
      LGBDI = 4+2*NMA
      LGBMI = 2*NDIME*NMA
      LGBPA = NPAN*(NDIME+2)
      LGBSO = NSOM*NDIME
      LGBMM = 2*NDIME
      LGBH  = NMA
C
C --- VERIFICATIONS COHERENCE DONNEES
C      
      IF ((NMA.LE.0).OR.
     &    (NPAN.LE.0).OR.
     &    (NSOM.LE.0).OR.
     &    (NDIME.LT.2).OR.
     &    (NDIME.GT.3)) THEN
        WRITE(6,*) 'BOITE <',NOMBOI(1:10),'> :',NDIME,NMA,NPAN,NSOM
        CALL ASSERT(.FALSE.)
      ENDIF  
C
C --- CREATION VECTEURS JEVEUX
C
      CALL WKVECT(NOMBOI(1:16)//'.MMGLOB',BASE//' V R',LGBMM,JMMGL)
      CALL WKVECT(NOMBOI(1:16)//'.MINMAX',BASE//' V R',LGBMI,IBID)
      CALL WKVECT(NOMBOI(1:16)//'.DIME'  ,BASE//' V I',LGBDI,JDIME)
      CALL WKVECT(NOMBOI(1:16)//'.PAN'   ,BASE//' V R',LGBPA,IBID)
      CALL WKVECT(NOMBOI(1:16)//'.SOMMET',BASE//' V R',LGBSO,IBID)
      CALL WKVECT(NOMBOI(1:16)//'.H'     ,BASE//' V R',LGBH ,IBID)
C
C --- QUELQUES INITIALISATIONS ELEMENTAIRES
C
      DO 30 IDIME = 1, NDIME
        ZR(JMMGL+2*(IDIME-1))   = R8MAEM()
        ZR(JMMGL+2*(IDIME-1)+1) = -R8MAEM()
 30   CONTINUE
C
      ZI(JDIME)   = NDIME
      ZI(JDIME+1) = NMA
      ZI(JDIME+2) = 1
      ZI(JDIME+3) = 1      
C
      CALL JEDEMA()
      END
