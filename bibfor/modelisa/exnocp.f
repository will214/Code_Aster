      SUBROUTINE EXNOCP(NOMA  ,NOMO ,NOMTM ,NUMAIL,NBNO  ,
     &                  INDQUA,LISTMA,LISTNO,LISTQU,IPMA  ,
     &                  IPNO  ,IPNOQU)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF MODELISA  DATE 27/11/2007   AUTEUR ABBAS M.ABBAS 
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
      CHARACTER*8  NOMA,NOMO
      CHARACTER*8  NOMTM     
      INTEGER      NUMAIL
      INTEGER      INDQUA      
      INTEGER      NBNO  
      INTEGER      LISTMA(*)
      INTEGER      LISTNO(*)
      INTEGER      LISTQU(*)
      INTEGER      IPMA,IPNO,IPNOQU
C     
C ----------------------------------------------------------------------
C
C ROUTINE CONTACT (TOUTES METHODES - LECTURE DONNEES)
C
C REMPLIT TABLEAUX NOEUDS ELEMENTS/SOMMETS/NOEUDS MILIEUX SUIVANT 
C OPTION ET TYPE ELEMENT
C      
C ----------------------------------------------------------------------
C
C
C IN  NOMA   : NOM DU MAILLAGE
C IN  NOMO   : NOM DU MODELE
C IN  NOMTM  : NOM DU TYPE DE MAILLE
C IN  NUMAIL : NUMERO ABSOLU DE LA MAILLE
C IN  NBNO   : NOMBRE NOEUDS TOTAL DE LA MAILLE
C IN  INDQUA : VAUT 0 LORSQUE L'ON DOIT PRENDRE LES NOEUDS MILIEUX
C              VAUT 1 LORSQUE L'ON DOIT IGNORER LES NOEUDS MILIEUX
C I/O LISTMA : LISTE DES NUMEROS DES MAILLES DE CONTACT
C I/O LISTNO : LISTE DES NUMEROS DES NOEUDS DE CONTACT
C I/O LISTQU : LISTE DES NUMEROS DES NOEUDS QUADRATIQUES DE CONTACT
C I/O IPMA   : INDICE POUR LA LISTE DES NUMEROS DES MAILLES DE CONTACT
C I/O IPNO   : INDICE POUR LA LISTE DES NUMEROS DES NOEUDS DE CONTACT
C I/O IPNOQU : INDICE POUR LA LISTE DES NUMEROS DES NOEUDS QUADRATIQUES
C              DE CONTACT
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
      INTEGER      INO,JDES   
      INTEGER      NOEUMI,NOEUSO
      LOGICAL      LVERIF,LQUADV 
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
C
C --- INITIALISATIONS
C 
      CALL JEVEUO(JEXNUM(NOMA//'.CONNEX',NUMAIL),'L',JDES)      
C
C --- NOMBRE DE NOEUDS SOMMETS ET MILIEUX
C
      CALL NBNOCP(NOMO  ,NOMTM ,NBNO  ,NUMAIL,INDQUA,
     &            NOEUMI,NOEUSO,LVERIF,LQUADV)   
C
C --- AJOUT DE LA MAILLE
C 
      IPMA   = IPMA + 1
      LISTMA(IPMA) = NUMAIL
C
C --- AJOUT DES NOEUDS SOMMETS
C       
      DO 60 INO = 1,NOEUSO
        IPNO = IPNO + 1
        LISTNO(IPNO) = ZI(JDES+INO-1)
   60 CONTINUE      
C
C --- AJOUT DES NOEUDS QUADRATIQUES
C --- NOEUSO=4
C ---    SI NOEUMI=4: QUAD8 STANDARD
C ---    SINON: ABORT
C --- NOEUSO=8
C ---    SI NOEUMI=1: QUAD9 DE COQUE 3D
C ---    SINON: ABORT
C --- NOEUSO=6
C ---    SI NOEUMI=1: TRIA7 DE COQUE 3D
C ---    SINON: ABORT 
C    
      IF (NOEUMI.NE.0) THEN 
        IF (NOEUSO.EQ.4) THEN
          IF (NOEUMI.EQ.4) THEN
            DO 10 INO = 1,NOEUMI - 1
              IPNOQU = IPNOQU + 1
              LISTQU((IPNOQU-1)*3+1) = ZI(JDES+(NOEUSO+INO)-1)
              LISTQU((IPNOQU-1)*3+2) = ZI(JDES+INO-1)
              LISTQU((IPNOQU-1)*3+3) = ZI(JDES+(INO+1)-1)
   10       CONTINUE
            IPNOQU = IPNOQU + 1
            LISTQU((IPNOQU-1)*3+1) = ZI(JDES+NBNO-1)
            LISTQU((IPNOQU-1)*3+2) = ZI(JDES+NOEUMI-1)
            LISTQU((IPNOQU-1)*3+3) = ZI(JDES+1-1) 
          ELSE
            CALL ASSERT(.FALSE.)  
          ENDIF  
        ELSEIF (NOEUSO.EQ.8) THEN  
          IF (NOEUMI.EQ.1) THEN
            IPNOQU = IPNOQU + 1
            LISTQU((IPNOQU-1)*3+1) = ZI(JDES+9-1)
            LISTQU((IPNOQU-1)*3+2) = 0
            LISTQU((IPNOQU-1)*3+3) = 0  
          ELSE
            CALL ASSERT(.FALSE.)            
          ENDIF 
        ELSEIF (NOEUSO.EQ.6) THEN  
          IF (NOEUMI.EQ.1) THEN
            IPNOQU = IPNOQU + 1
            LISTQU((IPNOQU-1)*3+1) = ZI(JDES+7-1)
            LISTQU((IPNOQU-1)*3+2) = 0
            LISTQU((IPNOQU-1)*3+3) = 0  
          ELSE
            CALL ASSERT(.FALSE.)            
          ENDIF 
        ELSE
          CALL ASSERT(.FALSE.)              
        ENDIF       
      ENDIF 
C
 999  CONTINUE        
C
      CALL JEDEMA()
      END
