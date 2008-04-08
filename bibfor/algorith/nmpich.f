      SUBROUTINE NMPICH(MODELE,NUMEDD,MATE  ,CARELE,COMREF,
     &                  COMPOR,LISCHA,CNFEXT,CNFINT,CNDIRI,
     &                  CARCRI,FONACT,SDPILO,SDDYNA,ITERAT,
     &                  INDRO ,DINST ,RESOCO,RESOCU,VALMOI,
     &                  VALPLU,SECMBR,POUGD ,DEPALG,VEELEM,
     &                  MEELEM,MEASSE,ETA   ,RHO   ,OFFSET,
     &                  LICCVG)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 08/04/2008   AUTEUR DESOZA T.DESOZA 
C ======================================================================
C COPYRIGHT (C) 1991 - 2003  EDF R&D                  WWW.CODE-ASTER.ORG
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
C TOLE CRP_21
C
      IMPLICIT NONE
      LOGICAL       FONACT(*)
      INTEGER       ITERAT,LICCVG(*),INDRO
      REAL*8        DINST ,ETA,RHO,OFFSET
      CHARACTER*14  SDPILO
      CHARACTER*19  LISCHA,SDDYNA
      CHARACTER*19  CNFEXT,CNFINT,CNDIRI
      CHARACTER*24  CARCRI,MODELE,NUMEDD,MATE ,CARELE,COMREF,COMPOR
      CHARACTER*24  RESOCO,RESOCU
      CHARACTER*24  VALMOI(8),VALPLU(8),POUGD (8),DEPALG(8),SECMBR(8)  
      CHARACTER*19  MEELEM(8),VEELEM(30) 
      CHARACTER*19  MEASSE(8)   
C 
C ----------------------------------------------------------------------
C
C ROUTINE MECA_NON_LINE (ALGORITHME - PILOTAGE)
C
C CALCUL DU ETA DE PILOTAGE ET CALCUL DE LA CORRECTION
C      
C ----------------------------------------------------------------------
C
C
C IN  MODELE : MODELE
C IN  NUMEDD : NUME_DDL
C IN  MATE   : CHAMP MATERIAU
C IN  CARELE : CARACTERISTIQUES DES ELEMENTS DE STRUCTURE
C IN  COMREF : VARI_COM DE REFERENCE
C IN  COMPOR : COMPORTEMENT
C IN  LISCHA : L_CHARGES
C IN  PARMET : PARAMETRES DES METHODES DE RESOLUTION
C IN  CARCRI : PARAMETRES DES METHODES D'INTEGRATION LOCALES
C IN  PARCRI : CRITERES DE CONVERGENCE GLOBAUX
C IN  POUGD  : DONNES POUR POUTRES GRANDES DEFORMATIONS
C IN  ITERAT : NUMERO D'ITERATION DE NEWTON
C IN  VALMOI : ETAT EN T-
C IN  VALPLU : ETAT EN T+ 
C IN  SECMBR : SECONDS MEMBRES
C IN  POUGD  : INFOS POUTRES EN GRANDES ROTATIONS
C IN  DEPALG : VARIABLE CHAPEAU POUR DEPLACEMENTS 
C IN  RESOCO : SD CONTACT
C IN  RESOCU : SD LIAISON_UNILATER
C IN  CNFEXT : FORCES EXTERNES
C OUT CNFINT : FORCES INTERNES   - FINT + AT.MU
C OUT CNDIRI : REACTIONS D'APPUI - BT.LAMBDA + AT.MU
C IN  SDPILO : SD PILOTAGE
C IN  NBEFFE : NOMBRE DE VALEURS DE PILOTAGE ENTRANTES
C OUT ETA    : PARAMETRE DE PILOTAGE
C OUT RHO    : PARAMETRE DE RECHERCHE_LINEAIRE
C OUT OFFSET : DECALAGE DE ETA_PILOTAGE EN FONCTION DE RHO
C OUT LICCVG : (1) CODE DE CONVERGENCE POUR LE PILOTAGE
C                     - 1 : BORNE ATTEINTE -> FIN DU CALCUL
C                       0 : RAS
C                       1 : PAS DE SOLUTION
C              (2) CODE RETOUR DE L'INTEGRATION DU COMPORTEMENT
C                       0 : CAS DE FONCTIONNEMENT NORMAL
C                       1 : ECHEC DE L'INTEGRATION DE LA LDC
C                       3 : SIZZ PAS NUL POUR C_PLAN DEBORST
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
      INTEGER      PILCVG,NBEFFE,NBATTE
      REAL*8       PROETA(2),RESIDU 
      INTEGER      IFM,NIV     
      CHARACTER*24 CNFEPI,K24BID
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
      CALL INFDBG('PILOTAGE',IFM,NIV)
C
C --- AFFICHAGE
C
      IF (NIV.GE.2) THEN
        WRITE (IFM,*) '<PILOTAGE> ... PILOTAGE SANS RECH_LINE'  
      ENDIF
C
C --- INITIALISATIONS
C
      RHO    = 1.D0
      OFFSET = 0.D0
      NBATTE = 2
C
C --- DECOMPACTION VARIABLES CHAPEAUX
C      
      CALL DESAGG(SECMBR,K24BID,CNFEPI,K24BID,K24BID,
     &            K24BID,K24BID,K24BID,K24BID)           
C
C --- CALCUL DE ETA_PILOTAGE
C         
      CALL NMPILO(SDPILO,DINST ,RHO   ,DEPALG,CNFEPI,
     &            MODELE,MATE  ,COMPOR,VALMOI,NBATTE,
     &            NUMEDD,NBEFFE,PROETA,PILCVG)
      LICCVG(1) = PILCVG
      IF (PILCVG.EQ.1) GOTO 9999
C
C --- CHOIX DE ETA_PILOTAGE
C  
      CALL NMCETA(MODELE,NUMEDD,MATE  ,CARELE,COMREF,
     &            COMPOR,LISCHA,CNFEXT,CNFINT,CNDIRI,
     &            CARCRI,FONACT,SDPILO,SDDYNA,ITERAT,
     &            INDRO ,POUGD ,RESOCO,RESOCU,VALMOI,
     &            VALPLU,SECMBR,DEPALG,NBEFFE,VEELEM,
     &            MEELEM,MEASSE,.FALSE.,PROETA,OFFSET,
     &            RHO   ,ETA   ,LICCVG,RESIDU)
C        
 9999 CONTINUE
      CALL JEDEMA()
      END
