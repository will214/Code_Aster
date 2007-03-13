      SUBROUTINE CFCOEM(JAPCOE,JAPCOF,JAPDDL,JAPPTR,JPDDL ,
     &                  TYPALF,FROT3D,NESMAX,POSESC,IESCL ,
     &                  NBDDLT,NBNOM ,POSNO ,DDL   ,COEF  ,
     &                  COFX  ,COFY)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 13/03/2007   AUTEUR ABBAS M.ABBAS 
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
      IMPLICIT     NONE
      INTEGER      JAPCOE
      INTEGER      JAPCOF
      INTEGER      JAPDDL
      INTEGER      JAPPTR
      INTEGER      JPDDL
      INTEGER      TYPALF
      INTEGER      FROT3D
      INTEGER      NESMAX      
      INTEGER      POSESC
      INTEGER      IESCL
      INTEGER      NBDDLT
      INTEGER      NBNOM
      INTEGER      POSNO(10)
      INTEGER      DDL(30)  
      REAL*8       COEF(30)
      REAL*8       COFX(30)
      REAL*8       COFY(30)          
C      
C ----------------------------------------------------------------------
C
C ROUTINE CONTACT (METHODES DISCRETES - APPARIEMENT - MAIT/ESCL)
C
C COEFFICIENTS RELATIONS LINEAIRES APPARIEMENT
C
C ----------------------------------------------------------------------
C
C
C IN  JAPCOE : POINTEUR VERS RESOCO(1:14)//'.APCOEF'
C               COEFFICIENTS DES RELATIONS LINEAIRES POUR LE CONTACT
C IN  JAPCOF : POINTEUR VERS RESOCO(1:14)//'.APCOFR'
C               COEFFICIENTS DES RELATIONS LINEAIRES POUR LE FROTTEMENT
C IN  JAPDDL : POINTEUR VERS RESOCO(1:14)//'.APDDL'
C IN  JAPPTR : POINTEUR VERS RESOCO(1:14)//'.APPOIN'
C IN  JPDDL  : POINTEUR VERS DEFICO(1:16)//'.PDDLCO'
C IN  TYPALF : TYPE ALGO UTILISE POUR LE FROTTEMENT
C   LES VALEURS SONT NEGATIVES SI AUCUNE LIAISON ACTIVE
C   0 PAS DE FROTTEMENT
C   1 FROTTEMENT PENALISE
C   2 FROTTEMENT LAGRANGIEN
C   3 FROTTEMENT METHODE CONTINUE
C IN  FROT3D : VAUT 1 LORSQU'ON CONSIDERE LE FROTTEMENT EN 3D
C IN  POSESC : POSITION DANS DEFICO(1:16)//'.CONTNO' DU NOEUD ESCLAVE
C IN  IESCL  : INDICE DU NOEUD ESCLAVE
C IN  NESMAX : NOMBRE MAX DE NOEUDS ESCLAVES
C IN  COEF   : VALEURS EN M DES FONCTIONS DE FORME ASSOCIEES AUX NOEUDS
C IN  COFX   : VALEURS EN M DES FONCTIONS DE FORME ASSOCIEES AUX NOEUDS
C                POUR LA PREMIERE DIRECTION TANGENTE
C IN  COFY   : VALEURS EN M DES FONCTIONS DE FORME ASSOCIEES AUX NOEUDS
C                POUR LA SECONDE DIRECTION TANGENTE
C IN  NBNOM  : NOMBRE DE NOEUDS MAITRES CONCERNES (MAX: 9)
C IN  POSNO  : INDICES DANS CONTNO DU NOEUD ESCLAVE ET DES NOEUDS 
C               MAITRES (MAX: 1+9=10)
C IN  NBDDLT : NOMBRE DE DDL NOEUD ESCLAVE+NOEUDS MAITRES
C IN  DDL    : NUMEROS DES DDLS ESCLAVE ET MAITRES CONCERNES
C
C -------------- DEBUT DECLARATIONS NORMALISEES JEVEUX -----------------
C
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
      INTEGER NBDDLE,NBDDLM
      INTEGER JDECAL,JDECDL,K,INO
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
C
C --- NOMBRE DE DDL POUR LE NOEUD ESCLAVE
C      
      NBDDLE = ZI(JPDDL+POSESC) - ZI(JPDDL+POSESC-1)
      IF (NBDDLE.GT.3) THEN
        CALL U2MESS('F','CONTACT_76')
      END IF 
C
C --- NOMBRE TOTAL RELATIONS LINEAIRES
C
      ZI(JAPPTR+IESCL) = ZI(JAPPTR+IESCL-1) + NBDDLT
C 
C --- RELATION DE CONTACT POUR LE NOEUD ESCLAVE
C
      JDECAL = ZI(JAPPTR+IESCL-1)
      DO 5 K = 1,NBDDLE
        ZR(JAPCOE+JDECAL+K-1) = COEF(K)
        ZI(JAPDDL+JDECAL+K-1) = DDL(K)
   5  CONTINUE
C 
C --- RELATION DE FROTTEMENT POUR LE NOEUD ESCLAVE
C
      IF (TYPALF.NE.0) THEN
        DO 10 K = 1,NBDDLE
          ZR(JAPCOF+JDECAL+K-1) = COFX(K)
          IF (FROT3D.EQ.1) THEN
            ZR(JAPCOF+JDECAL+30*NESMAX+K-1) = COFY(K)
          END IF
   10   CONTINUE
      ENDIF
C 
C --- RELATION DE CONTACT POUR LE NOEUD MAITRE
C
      JDECAL = JDECAL + NBDDLE
      JDECDL = NBDDLE 
      DO 50 INO = 1,NBNOM
        NBDDLM = ZI(JPDDL+POSNO(INO+1)) - ZI(JPDDL+POSNO(INO+1)-1)
        IF (NBDDLM.GT.3) THEN
          CALL U2MESS('F','CONTACT_76')
        END IF         
        DO 40 K = 1,NBDDLM
          ZR(JAPCOE+JDECAL+K-1) = COEF(JDECDL+K)
          ZI(JAPDDL+JDECAL+K-1) = DDL(JDECDL+K)
   40   CONTINUE
C 
C --- RELATION DE FROTTEMENT POUR LE NOEUD MAITRE
C  
        DO 41 K = 1,NBDDLM
          IF ((ABS(TYPALF).EQ.2).AND.(FROT3D.EQ.0)) THEN
            ZR(JAPCOF+JDECAL+K-1) = COFX(JDECDL+K)
          ELSE IF (FROT3D.EQ.1) THEN
            ZR(JAPCOF+JDECAL+K-1) = COFX(JDECDL+K)
            ZR(JAPCOF+JDECAL+30*NESMAX+K-1) = COFY(JDECDL+K) 
          END IF
   41   CONTINUE
        JDECAL = JDECAL + NBDDLM
        JDECDL = JDECDL + NBDDLM
   50 CONTINUE
C
      CALL JEDEMA()
      END
