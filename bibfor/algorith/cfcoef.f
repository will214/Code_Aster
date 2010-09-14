      SUBROUTINE CFCOEF(NDIMG ,RESOCO,NBNOM ,POSNSM,COEFNO,
     &                  POSNOE,NORM  ,TAU1  ,TAU2  ,COEF  ,
     &                  COFX  ,COFY  ,NBDDLT,DDL   )
C     
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 14/09/2010   AUTEUR ABBAS M.ABBAS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2004  EDF R&D                  WWW.CODE-ASTER.ORG
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
      IMPLICIT     NONE
      INTEGER      NDIMG
      CHARACTER*24 RESOCO
      INTEGER      NBNOM
      INTEGER      POSNSM(9),POSNOE
      REAL*8       COEFNO(9)
      REAL*8       NORM(3),TAU1(3),TAU2(3)
      REAL*8       COEF(30),COFX(30),COFY(30)
      INTEGER      NBDDLT
      INTEGER      DDL(30)
C      
C ----------------------------------------------------------------------
C
C ROUTINE CONTACT (METHODES DISCRETES - APPARIEMENT)
C
C CALCULE LES COEFFICIENTS DES RELATIONS LINEAIRES ET DONNE LES NUMEROS
C  DES DDL ASSOCIES
C
C ----------------------------------------------------------------------
C
C
C IN  NDIMG  : DIMENSION DE L'ESPACE (2 OU 3)
C IN  RESOCO : SD DE TRAITEMENT NUMERIQUE DU CONTACT
C IN  NBNOM  : NOMBRE DE NOEUDS MAITRES CONCERNES
C IN  POSNSM : INDICES DANS CONTNO DES NOEUDS MAITRES
C IN  POSNOE : INDICES DANS CONTNO DU NOEUD ESCLAVE
C IN  COEFNO : COEFFICIENTS DES FONCTIONS DE FORME APRES PROJECTION
C                SUR LA MAILLE MAITRE
C IN  NORM   : NORMALE 
C IN  TAU1   : PREMIER VECTEUR TANGENT
C IN  TAU2   : SECOND VECTEUR TANGENT
C OUT COEF   : COEFFICIENTS LIES AU NOEUD ESCLAVE ET AUX NOEUDS MAITRES
C              (DIRECTION NORMALE)
C OUT COEFX  : COEFFICIENTS LIES AU NOEUD ESCLAVE ET AUX NOEUDS MAITRES
C              (PROJECTION SUR LA PREMIERE TANGENTE)
C OUT COEFY  : COEFFICIENTS LIES AU NOEUD ESCLAVE ET AUX NOEUDS MAITRES
C              (PROJECTION SUR LA SECONDE TANGENTE)
C OUT NBDDLT : NOMBRE DE DDLS CONCERNES (ESCLAVES + MAITRES)
C OUT DDL    : NUMEROS DES DDLS ESCLAVE ET MAITRES CONCERNES
C
C -------------- DEBUT DECLARATIONS NORMALISEES JEVEUX -----------------
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
C ---------------- FIN DECLARATIONS NORMALISEES JEVEUX -----------------
C
      INTEGER      IDIM,INO,K
      INTEGER      JDECAL,NBDDLM,NBDDLE,JDECDL
      CHARACTER*24 DDLCO,NBDDL
      INTEGER      JDDL,JNBDDL
      INTEGER      POSNOM
C      
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
C
C --- LECTURE DES STRUCTURES DE DONNEES DE CONTACT
C
      NBDDL  = RESOCO(1:14)//'.NBDDL'
      DDLCO  = RESOCO(1:14)//'.DDLCO'     
      CALL JEVEUO(NBDDL, 'L',JNBDDL)
      CALL JEVEUO(DDLCO, 'L',JDDL)
C
C --- INITIALISATIONS
C        
      DO 1 K=1,30 
        COEF(K) = 0.D0
        COFX(K) = 0.D0
        COFY(K) = 0.D0
        DDL (K) = 0
   1  CONTINUE          
C
C --- POUR LES NOEUDS ESCLAVES
C 
      JDECDL = ZI(JNBDDL+POSNOE-1) 
      NBDDLE = ZI(JNBDDL+POSNOE) - ZI(JNBDDL+POSNOE-1)
C         
      DO 5 IDIM = 1,NDIMG
        COEF(IDIM) = 1.D0 * NORM(IDIM)
        COFX(IDIM) = 1.D0 * TAU1(IDIM)
        COFY(IDIM) = 1.D0 * TAU2(IDIM)
        DDL(IDIM)  = ZI(JDDL+JDECDL+IDIM-1)  
5     CONTINUE
      JDECAL = NBDDLE
C
C --- POUR LES NOEUDS MAITRES
C 
      DO 100 INO = 1,NBNOM
        POSNOM = POSNSM(INO)
        JDECDL = ZI(JNBDDL+POSNOM-1)        
        NBDDLM = ZI(JNBDDL+POSNOM) - ZI(JNBDDL+POSNOM-1)
        DO 85 IDIM = 1,NBDDLM
          COEF(JDECAL+IDIM) = COEFNO(INO) * NORM(IDIM)
          COFX(JDECAL+IDIM) = COEFNO(INO) * TAU1(IDIM)
          COFY(JDECAL+IDIM) = COEFNO(INO) * TAU2(IDIM)       
          DDL(JDECAL+IDIM)  = ZI(JDDL+JDECDL+IDIM-1)
 85     CONTINUE
        JDECAL = JDECAL + NBDDLM         
  100 CONTINUE
C 
C --- NOMBRE TOTAL DE DDL (NOEUD ESCLAVE+NOEUDS MAITRES)
C
      NBDDLT = JDECAL
C
      CALL JEDEMA()
      END
