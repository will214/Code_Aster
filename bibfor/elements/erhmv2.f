      SUBROUTINE ERHMV2 (AXI   , HK    ,
     &                   DIMDEP, DIMDEF, NMEC  , NP1   , NP2 ,
     &                   NDIM  , NNO   , NNOS  , NNOM  , NPI , NPG   ,
     &                   NDDLS , NDDLM , DIMUEL,
     &                   IPOIDS, IVF   , IDFDE , IPOID2, IVF2, IDFDE2,
     &                   GEOM  , TABFOR,
     &                   DEPLP ,
     &                   SIELNP, NBCMP ,
     &                   BIOT  ,
     &                   FPX   , FPY   , FRX   , FRY,
     &                   YAMEC , ADDEME, YAP1  , ADDEP1, YAP2, ADDEP2,
     &                   YATE  , ADDETE,
     &                   TERVOM)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 23/04/2007   AUTEUR GNICOLAS G.NICOLAS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2006  EDF R&D                  WWW.CODE-ASTER.ORG
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
C TOLE CRP_21
C =====================================================================
C  ERREUR EN HYDRO-MECANIQUE - TERME VOLUMIQUE - DIMENSION 2
C  **        *     *                 *                     *
C =====================================================================
C    - FONCTION REALISEE:  CALCUL DES TERMES VOLUMIQUES MECANIQUE ET
C      HYDRAULIQUE DE L'ESTIMATEUR D'ERREUR EN RESIDU POUR LA
C      MODELISATION HM PERMANENTE
C
C ENTREE :
C -------
C
C IN AXI     : AXISYMETRIQUE OU NON ?
C IN HK      : DIAMETRE DE L'ELEMENT
C IN DIMDEP  : DIMENSION DES DEPLACEMENTS
C IN DIMDEF  : DIMENSION DES DEFORMATIONS GENERALISEES ELEMENTAIRES
C IN NMEC    : = NDIM SI YAMEC, 0 SINON
C IN NP1     : = 1 SI YAP1, 0 SINON
C IN NP2     : = 1 SI YAP2, 0 SINON
C IN NDIM    : DIMENSION DE L'ESPACE
C IN NNO     : NOMBRE DE NOEUDS DE L'ELEMENT
C IN NNOS    : NOMBRE DE NOEUDS SOMMETS DE L'ELEMENT
C IN NNOM    : NOMBRE DE NOEUDS MILIEUX DE L'ELEMENT
C IN NPI     : NOMBRE DE POINTS D'INTEGRATION DE L'ELEMENT
C IN NPG     : NB DE POINTS DE GAUSS    POUR CLASSIQUE(=NPI)
C                    SOMMETS            POUR LUMPEE   (=NPI=NNOS)
C                    POINTS DE GAUSS    POUR REDUITE  (<NPI)
C IN NDDLS   : NOMBRE DE DDLS SUR LES SOMMETS
C IN NDDLM   : NOMBRE DE DDLS SUR LES POINTS MILIEUX 
C IN DIMUEL  : NOMBRE DE DDLS TOTAL DE L'ELEMENT
C IN IPOIDS  : ADRESSE DANS ZR DU TABLEAU POIDS(IPG)
C              POUR LES FONCTIONS DE FORME P2
C IN IVF     : ADRESSE JEVEUX DES FONCTIONS DE FORME QUADRATIQUES
C IN IDFDE   : ADRESSE DANS ZR DU TABLEAU DFF(IDIM,INO,IPG)
C              POUR LES FONCTIONS DE FORME P2
C IN IPOID2  : ADRESSE DANS ZR DU TABLEAU POIDS(IPG) 
C              POUR LES FONCTIONS DE FORME P1
C IN IVF2    : ADRESSE JEVEUX DES FONCTIONS DE FORME LINEAIRES
C IN IDFDE2  : ADRESSE DANS ZR DU TABLEAU DFF(IDIM,INO,IPG)
C              POUR LES FONCTIONS DE FORME P1
C IN GEOM    : TABLEAU DES COORDONNEES
C IN TABFOR  : TABLEAU DES FORCES VOLUMIQUES
C IN DEPLP   : TABLEAU DES DEPLACEMENTS GENERALISES A L'INSTANT ACTUEL
C IN SIELNP  : CONTRAINTES AUX NOEUDS PAR ELEMENT A L'INSTANT ACTUEL
C IN NBCMP   : NOMBRE DE CONTRAINTES GENERALISEES PAR NOEUD 
C IN BIOT    : VALEUR DU COEFFICIENT DE BIOT
C IN FPX     : VALEUR DE LA FORCE DE PESANTEUR SELON X
C IN FPY     : VALEUR DE LA FORCE DE PESANTEUR SELON Y
C IN FRX     : VALEUR DE LA FORCE DE ROTATION SELON X
C IN FRY     : VALEUR DE LA FORCE DE ROTATION SELON Y
C
C SORTIE :
C -------
C
C OUT TERVOM : TERME VOLUMIQUE DE LA MECANIQUE DE L'INDICATEUR HM
C
C
C   -------------------------------------------------------------------
C     SUBROUTINE APPELLEE :
C       ELEMENTS FINIS : CABTHM
C     FONCTION INTRINSEQUE :
C       SQRT.
C   -------------------------------------------------------------------
      IMPLICIT NONE
C
C DECLARATION PARAMETRES D'APPELS
C
      LOGICAL AXI
      INTEGER DIMUEL
      INTEGER NDIM,NNO,NNOS,NNOM,DIMDEP,DIMDEF,NMEC,NP1,NP2
      INTEGER NBCMP,NPG,NPI,NDDLS,NDDLM,IPOIDS,IVF,IDFDE
      INTEGER IPOID2,IVF2,IDFDE2
      INTEGER YAMEC,ADDEME,YATE,ADDETE,YAP1,ADDEP1,YAP2,ADDEP2
      REAL*8  BIOT,HK
      REAL*8  DEPLP(NNO*DIMDEP)
      REAL*8  TABFOR(18)
      REAL*8  GEOM(NDIM,NNO)
      REAL*8  FPX,FPY
      REAL*8  FRX(9),FRY(9)
      REAL*8  SIELNP(81)
      REAL*8  DFDI(NNO,3),DFDI2(NNOS,3)
      REAL*8  B(DIMDEF,DIMUEL)
C
C DECLARATION SORTIES 
C
      REAL*8 TERVOM
C
C DECLARATION VARIABLES LOCALES
C
      REAL*8  GRADPX,GRADPY,DSX,DSY,FORX,FORY
      REAL*8  POIDS,POIDS2
      REAL*8  SIGXX,SIGXY,SIGYY,DSXXDX,DSXYDY,DSXYDX,DSYYDY
      INTEGER IPI,KPI,N,I,IAUX,JAUX
C
C =====================================================================
C 1. INITIALISATION
C =====================================================================
C
      TERVOM = 0.D0
C
C =====================================================================
C 2. ------ BOUCLE SUR LES POINTS DE GAUSS ---------------------------
C =====================================================================
C
      DO 10 , IPI = 1,NPG
C
        KPI = IPI
C       
C =====================================================================
C 2.1. --- CALCUL DE LA MATRICE B AU POINT D'INTEGRATION --------------
C =====================================================================
C
        CALL CABTHM (NDDLS ,NDDLM ,NNO   ,NNOS ,NNOM  ,DIMUEL,
     &               DIMDEF,NDIM  ,NPI   ,KPI  ,IPOIDS,IPOID2,IVF,IVF2,
     &               IDFDE ,IDFDE2,DFDI  ,DFDI2,
     &               GEOM  ,POIDS ,POIDS2,B    ,NMEC  ,YAMEC ,
     &               ADDEME,YAP1  ,
     &               ADDEP1,YAP2  ,ADDEP2,YATE ,ADDETE,NP1   ,NP2,AXI)
C
C =====================================================================
C 2.2. ------ RECHERCHE DU GRADIENT DE LA PRESSION AU POINT DE GAUSS --
C EN THEORIE, ON PEUT FAIRE LA MULTIPLICATION DE LA MATRICE B PAR LE
C CHAMP DE DEPLACEMENT DEPLA POUR TOUTES LES COMPOSANTES DE DEPLA. EN
C EFFET, TOUTES LES VALEURS DE DEPLA QUI CORRESPONDENT A UN AUTRE DDL
C QUE P1 SERONT MULTIPLIEES PAR 0. IL EST PLUS ECONOMIQUE DE NE FAIRE
C QUE LES MULTIPLICATIONS 'UTILES', C'EST-A-DIRE CELLES QUI SONT LIEES
C A P1. DANS LE TABLEAU DEPLP, ELLES COMMENCENT A L'ADRESSE IAUX. ON
C LES RETROUVE ENSUITE ESPACEES DE DIMDEP, DIMENSION DU VECTEUR
C DEPLACEMENT. ON TERMINE AU NOMBRE DE NOEUDS SOMMETS MULTIPLIE PAR
C DIMDEP.
C LES TERMES DANS LA MATRICE B SE TROUVENT A L'ADRESSE DITE DES
C DEFORMATIONS GENERALISEES, ADDEP1,AUGMENTEE DE LA DIMENSION EN COURS.
C
C EXEMPLE POUR DU THM EN TRIA6 :
C DEPLA : 
C  UX1 UY1 P11 T1 UX2 UY2 P12 T2 UX3 UY3 P13 T3 UX4 UY4 UX5 UY5 UX6 UY6
C    1   2   3  4   5   6   7  8   9  10  11 12  13  14  15  16  17  18
C         ON A DIMDEP =  4 = 2 + 1 + 1 (UX, UY, P1, T)
C              IAUX   =  3 = 2 + 1 (NDIM + 1)
C              JAUX   = 12 = 3*4 (NNOS*DIMDEP)
C    LA BOUCLE 22 N = IAUX, JAUX, DIMDEP, EXPLORE DONC LES
C    POSITIONS 3, 7 ET 11 (P11, P12 ET P13). CQFD.
C =====================================================================
C
        GRADPX = 0.D0
        GRADPY = 0.D0
C
        IAUX = NDIM + 1
        JAUX = NNOS*DIMDEP
C
        DO 20 , N = IAUX, JAUX, DIMDEP
C
          GRADPX = GRADPX + B(ADDEP1+1,N)*DEPLP(N)
          GRADPY = GRADPY + B(ADDEP1+2,N)*DEPLP(N)
C
 20     CONTINUE
C
C =====================================================================
C 2.3. --------- CALCUL DE LA DIVERGENCE DES CONTRAINTES MECANIQUES ---
C    ON CALCULE LES DERIVEES DES CONTRAINTES SUR LE POINT DE GAUSS
C    COURANT AVEC LA FORMULE CLASSIQUE DES ELEMENTS FINIS :
C                  SOMME(VAL-NOEUD_I*WI)
C    LES VALEURS AUX NOEUDS SONT DANS SIELNP
C =====================================================================
C
        DSXXDX = 0.D0
        DSXYDY = 0.D0
        DSXYDX = 0.D0
        DSYYDY = 0.D0
C
        DO 30 , I=1,NNO
C
          IAUX  = NBCMP*(I-1)
          SIGXX = SIELNP(IAUX+1)
          SIGYY = SIELNP(IAUX+2)
          SIGXY = SIELNP(IAUX+4)
C
          DSXXDX = DSXXDX+SIGXX*DFDI(I,1)
          DSXYDY = DSXYDY+SIGXY*DFDI(I,2)
          DSYYDY = DSYYDY+SIGYY*DFDI(I,2)
          DSXYDX = DSXYDX+SIGXY*DFDI(I,1)
C
 30     CONTINUE
C
C LA DIVERGENCE DU TENSEUR DES CONTRAINTES EST UN VECTEUR
C DE COMPOSANTES :
C
        DSX = DSXXDX+DSXYDY
        DSY = DSXYDX+DSYYDY
C
C =====================================================================
C 2.4. ------ ASSEMBLAGE DES 3 TERMES : -------------------------------
C           FORCES MECANIQUES : VOLUMIQUES + PESANTEUR + ROTATION
C           CONTRAINTES MECANIQUES
C           GRADIENT DE PRESSION
C =====================================================================
C
        FORX = TABFOR(2*KPI-1) + FPX + FRX(KPI)
        FORY = TABFOR(2*KPI)   + FPY + FRY(KPI)
C
        TERVOM = TERVOM + POIDS*
     &         ( (FORX+DSX-BIOT*GRADPX)**2 + (FORY+DSY-BIOT*GRADPY)**2 )
C
C =====================================================================
C 2.5. TERME VOLUMIQUE DE L'HYDRAULIQUE (CF DOC R)
C
C ====================================================================
C 2.5.1. EN PERMANENT
C      
C        TOUS CES TERMES (DIVERGENCE DU FLUX HYDRAULIQUE) SONT DES
C        DERIVEES SECONDES DE TERMES DISCRETISES EN DEGRE 1,
C        DONC SONT STRUCTURELLEMENT NULS.
C        ON POURRAIT LES CALCULER QUAND MEME ET RETROUVER CES VALEURS
C        NULLES MAIS ON NE CALCULERA RIEN DU TOUT.

C
   10 CONTINUE
C
C FIN BOUCLE SUR LES POINTS DE GAUSS
C
C =====================================================================
C 3. PRISE EN COMPTE DU DIAMETRE DE L'ELEMENT
C =====================================================================
C
      TERVOM = HK*SQRT(TERVOM)
C
      END
