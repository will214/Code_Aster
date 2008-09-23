      SUBROUTINE NMCHSE(MODE  ,NRPASE,MODELE,NUMEDD,MATE  ,
     &                  CARELE,COMPOR,LISCHA,CARCRI,NUMINS,
     &                  SDDISC,PARCON,FONACT,DEFICO,RESOCO,
     &                  RESOCU,COMREF,VALMOI,VALPLU,POUGD ,
     &                  SOLALG,VEELEM,MEASSE,VEASSE,SDSENS,
     &                  SDDYNA)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 23/09/2008   AUTEUR ABBAS M.ABBAS 
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
C TOLE CRP_21 
C
      IMPLICIT NONE
      CHARACTER*19  LISCHA
      CHARACTER*24  MODELE,MATE,CARELE, NUMEDD
      CHARACTER*24  VALMOI(8),VALPLU(8),POUGD(8)
      CHARACTER*24  COMPOR,CARCRI,SDSENS,COMREF
      CHARACTER*19  SDDYNA,SDDISC
      LOGICAL       FONACT(*)
      INTEGER       NUMINS
      REAL*8        PARCON(8)
      CHARACTER*24  DEFICO,RESOCO,RESOCU
      CHARACTER*19  VEELEM(*),MEASSE(*),VEASSE(*) 
      CHARACTER*19  SOLALG(*)         
      INTEGER       NRPASE     
      CHARACTER*4   MODE
C 
C ----------------------------------------------------------------------
C
C ROUTINE MECA_NON_LINE (ALGORITHME - CALCUL)
C
C CALCUL DES CHARGEMENTS POUR LA SENSIBILITE
C      
C ----------------------------------------------------------------------
C 
C
C IN  MODE   : 'SENS' -> CALCUL CHARGES SENSIBLES 
C              'SEDY' -> CALCUL CHARGES SENSIBLES EN DYNAMIQUE 
C IN  NRPASE : NUMERO PARAMETRE SENSIBLE
C IN  MODELE : MODELE
C IN  NUMEDD : NUME_DDL
C IN  LISCHA : LISTE DES CHARGES
C IN  MATE   : CHAMP MATERIAU
C IN  CARELE : CARACTERISTIQUES DES ELEMENTS DE STRUCTURE
C IN  COMPOR : CARTE DECRIVANT LE TYPE DE COMPORTEMENT
C IN  CARCRI : PARAMETRES DES METHODES D'INTEGRATION LOCALES
C IN  NUMEDD : NUME_DDL
C IN  NUMINS : NUMERO INSTANT
C IN  SDDISC : SD DISCRETISATION TEMPORELLE
C IN  PARCON : PARAMETRES DU CRITERE DE CONVERGENCE REFERENCE
C IN  FONACT : FONCTIONNALITES ACTIVEES
C IN  COMREF : VARI_COM DE REFERENCE
C IN  RESOCO : SD POUR LA RESOLUTION DE CONTACT
C IN  RESOCU : SD POUR LA RESOLUTION LIAISON_UNILATER
C IN  DEFICO : SD POUR LA DEFINITION DE CONTACT
C IN  VALMOI : VARIABLE CHAPEAU POUR ETAT EN T-
C IN  VALPLU : VARIABLE CHAPEAU POUR ETAT EN T+
C IN  SOLALG : VARIABLE CHAPEAU POUR INCREMENTS SOLUTIONS
C IN  POUGD  : VARIABLE CHAPEAU POUR POUTRES EN GRANDES ROTATIONS
C IN  MEASSE : VARIABLE CHAPEAU POUR NOM DES MATR_ASSE
C IN  VEELEM : VARIABLE CHAPEAU POUR NOM DES VECT_ELEM
C IN  VEASSE : VARIABLE CHAPEAU POUR NOM DES VECT_ASSE
C IN  SDDYNA : SD DYNAMIQUE
C IN  SDSENS : SD SENSIBILITE
C
C --- DEBUT DECLARATIONS NORMALISEES JEVEUX ----------------------------
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
      LOGICAL      NDYNLO,LIMPE,LSENS,LAMMO  
      INTEGER      NBVECT   
      CHARACTER*6  LTYPVE(20)
      CHARACTER*16 LOPTVE(20)
      LOGICAL      LASSVE(20),LCALVE(20)         
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()   
C
C --- INITIALISATIONS
C
      CALL NMCVEC('INIT',' ',' ',.FALSE.,.FALSE.,
     &            NBVECT,LTYPVE,LOPTVE,LCALVE,LASSVE)              
C
C --- FONCTIONNALITES ACTIVEES
C    
      LSENS  = .TRUE. 
      LIMPE  = NDYNLO(SDDYNA,'IMPE_ABSO')
      LAMMO  = NDYNLO(SDDYNA,'AMOR_MODAL')           
C
C --- CHARGEMENT DU A LA DERIVATION (PARTIE COMPORTEMENT)   
C
      CALL NMCVEC('AJOU','CNMSME',' ',.TRUE.,.TRUE.,
     &            NBVECT,LTYPVE,LOPTVE,LCALVE,LASSVE)
C      
C --- DERIVATION CHARGEMENTS MECANIQUES DONNES              
C
      CALL NMCVEC('AJOU','CNFEDO',' ',.TRUE.,.TRUE.,
     &            NBVECT,LTYPVE,LOPTVE,LCALVE,LASSVE)
C      
C --- DERIVATION DEPLACEMENTS IMPOSES DONNES               
C 
      CALL NMCVEC('AJOU','CNDIDO',' ',.TRUE.,.TRUE.,
     &            NBVECT,LTYPVE,LOPTVE,LCALVE,LASSVE)
C
C --- CALCUL ET ASSEMBLAGE
C
      CALL NMXVEC(MODELE,MATE  ,CARELE,COMPOR,CARCRI,
     &            SDDISC,SDDYNA,NUMINS,VALMOI,VALPLU,
     &            POUGD ,SOLALG,LISCHA,COMREF,DEFICO,
     &            RESOCO,RESOCU,NUMEDD,PARCON,SDSENS,
     &            LSENS ,NRPASE,VEELEM,VEASSE,MEASSE,
     &            NBVECT,LTYPVE,LOPTVE,LCALVE,LASSVE)      
C
      IF (MODE.EQ.'SEDY') THEN 
C
C --- FORCES D'EQUILIBRE DYNAMIQUE
C
        CALL NMCVEC('AJOU','CNDYNA',' ',.FALSE.,.TRUE.,
     &              NBVECT,LTYPVE,LOPTVE,LCALVE,LASSVE)
C
C --- FORCES D'AMORTISSEMENT MODAL
C           
        IF (LAMMO) THEN  
          CALL NMCVEC('AJOU','CNMODC',' ',.FALSE.,.TRUE.,
     &                NBVECT,LTYPVE,LOPTVE,LCALVE,LASSVE)          
        ENDIF 
C
C --- FORCES IMPEDANCES
C   
        IF (LIMPE) THEN
          CALL ASSERT(.FALSE.)
        ENDIF   
C
C --- CALCUL ET ASSEMBLAGE
C
        CALL NMXVEC(MODELE,MATE  ,CARELE,COMPOR,CARCRI,
     &              SDDISC,SDDYNA,NUMINS,VALMOI,VALPLU,
     &              POUGD ,SOLALG,LISCHA,COMREF,DEFICO,
     &              RESOCO,RESOCU,NUMEDD,PARCON,SDSENS,
     &              LSENS ,NRPASE,VEELEM,VEASSE,MEASSE,
     &              NBVECT,LTYPVE,LOPTVE,LCALVE,LASSVE)
      ENDIF
C
      CALL JEDEMA()
      END
