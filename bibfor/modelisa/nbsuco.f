      SUBROUTINE NBSUCO(CHAR  ,MOTFAC,NOMA  ,NOMO  ,NZOCO,
     &                  NMACO ,NNOCO )
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF MODELISA  DATE 23/09/2008   AUTEUR ABBAS M.ABBAS 
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
      CHARACTER*8  CHAR
      CHARACTER*16 MOTFAC
      CHARACTER*8  NOMA,NOMO
      INTEGER      NZOCO,NMACO,NNOCO
C      
C ----------------------------------------------------------------------
C
C ROUTINE CONTACT (METHODES MAILLEES - LECTURE DONNEES)
C
C DETERMINATION DU NOMBRE DE MAILLES ET DE NOEUDS DE CONTACT
C REMPLISSAGE DES POINTEURS ASSOCIES JSUMA,JSUNO
C      
C ----------------------------------------------------------------------
C
C 
C IN  CHAR   : NOM UTILISATEUR DU CONCEPT DE CHARGE
C IN  MOTFAC : MOT-CLE FACTEUR (VALANT 'CONTACT')
C IN  NOMA   : NOM DU MAILLAGE
C IN  NOMO   : NOM DU MODELE
C IN  NZOCO  : NOMBRE DE ZONES DE CONTACT
C OUT NMACO  : NOMBRE TOTAL DE MAILLES DES SURFACES DE CONTACT
C OUT NNOCO  : NOMBRE TOTAL DE NOEUDS DES SURFACES DE CONTACT
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
      CHARACTER*24 DEFICO
      CHARACTER*24 PSURMA,PSURNO
      INTEGER      JSUMA,JSUNO 
      INTEGER      IZONE,ISUCO 
      INTEGER      NBMAES,NBNOES
      INTEGER      NBMAMA,NBNOMA      
      CHARACTER*24 LISTME,LISTMM
      CHARACTER*24 LISTNE,LISTNM            
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
C
C --- INITIALISATIONS
C
      NNOCO  = 0
      NMACO  = 0   
      ISUCO  = 1
      DEFICO = CHAR(1:8)//'.CONTACT'
C 
C --- ACCES AUX STRUCTURES DE DONNEES DE CONTACT
C  
      PSURMA = DEFICO(1:16)//'.PSUMACO'
      PSURNO = DEFICO(1:16)//'.PSUNOCO'          
      CALL JEVEUO(PSURMA,'E',JSUMA)
      CALL JEVEUO(PSURNO,'E',JSUNO)  
C
C --- NOM DES SD TEMPORAIRES
C          
      LISTMM = '&&NBSUCO.MAIL.MAIT'
      LISTME = '&&NBSUCO.MAIL.ESCL'
      LISTNM = '&&NBSUCO.NOEU.MAIT'
      LISTNE = '&&NBSUCO.NOEU.ESCL' 
C                             
C --- ON COMPTE LES MAILLES/NOEUDS DES ZONES DE CONTACT 
C     
      DO 10 IZONE = 1,NZOCO
        CALL LIRECO(CHAR  ,MOTFAC,NOMA  ,NOMO  ,IZONE ,
     &              LISTME,LISTMM,LISTNE,LISTNM,NBMAES,
     &              NBNOES,NBMAMA,NBNOMA)
        NNOCO  = NNOCO+NBNOMA+NBNOES
        NMACO  = NMACO+NBMAMA+NBMAES     
C
C --- NOMBRE DE MAILLES ET DE NOEUDS MAITRES
C  
        ZI(JSUMA+ISUCO) = ZI(JSUMA+ISUCO-1) + NBMAMA 
        ZI(JSUNO+ISUCO) = ZI(JSUNO+ISUCO-1) + NBNOMA  
        ISUCO = ISUCO + 1  
C
C --- NOMBRE DE MAILLES ET DE NOEUDS ESCLAVES
C
        ZI(JSUMA+ISUCO) = ZI(JSUMA+ISUCO-1) + NBMAES    
        ZI(JSUNO+ISUCO) = ZI(JSUNO+ISUCO-1) + NBNOES 
        ISUCO = ISUCO + 1
        
   10 CONTINUE 
C   
      CALL JEDETR(LISTME)
      CALL JEDETR(LISTMM) 
      CALL JEDETR(LISTNE)
      CALL JEDETR(LISTNM)
C      
      CALL JEDEMA()
      END
