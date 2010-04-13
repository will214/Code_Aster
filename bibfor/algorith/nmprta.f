      SUBROUTINE NMPRTA(MODELE,NUMEDD,MATE  ,CARELE,COMREF,
     &                  COMPOR,LISCHA,METHOD,SOLVEU,FONACT,
     &                  PARMET,CARCRI,SDDISC,SDTIME,NUMINS,
     &                  VALINC,SOLALG,LICCVG,CODERE,MATASS,
     &                  MAPREC,DEFICO,RESOCO,RESOCU,SDDYNA,
     &                  SDSENS,MEELEM,MEASSE,VEELEM,VEASSE)
C
C MODIF ALGORITH  DATE 12/04/2010   AUTEUR ABBAS M.ABBAS 
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C ======================================================================
C COPYRIGHT (C) 1991 - 2001  EDF R&D                  WWW.CODE-ASTER.ORG
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
C    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================
C RESPONSABLE MABBAS M.ABBAS
C TOLE CRP_21
C
      IMPLICIT NONE
      INTEGER      FONACT(*)
      INTEGER      NUMINS,LICCVG(*)
      REAL*8       PARMET(*)
      CHARACTER*16 METHOD(*)
      CHARACTER*19 MATASS,MAPREC
      CHARACTER*19 LISCHA,SOLVEU,SDDISC,SDDYNA
      CHARACTER*24 MODELE,NUMEDD,MATE  ,CARELE,COMREF,COMPOR
      CHARACTER*24 CARCRI,CODERE,SDTIME,SDSENS
      CHARACTER*19 SOLALG(*),VALINC(*)
      CHARACTER*24 DEFICO,RESOCO,RESOCU
      CHARACTER*19 VEELEM(*),VEASSE(*)
      CHARACTER*19 MEELEM(*),MEASSE(*)          
C 
C ----------------------------------------------------------------------
C
C ROUTINE MECA_NON_LINE (ALGORITHME - PREDICTION)
C
C PREDICTION PAR METHODE DE NEWTON-EULER
C      
C ----------------------------------------------------------------------
C
C
C IN  MODELE : MODELE
C IN  NUMEDD : NUME_DDL
C IN  MATE   : CHAMP MATERIAU
C IN  CARELE : CARACTERISTIQUES DES ELEMENTS DE STRUCTURE
C IN  COMREF : VARIABLES DE COMMANDE DE REFERENCE
C IN  COMPOR : COMPORTEMENT
C IN  LISCHA : L_CHARGES
C IN  METHOD : INFORMATIONS SUR LES METHODES DE RESOLUTION
C IN  SOLVEU : SOLVEUR
C IN  FONACT : FONCTIONNALITES ACTIVEES (VOIR NMFONC)
C IN  PARMET : PARAMETRES DES METHODES DE RESOLUTION
C IN  CARCRI : PARAMETRES DES METHODES D'INTEGRATION LOCALES
C IN  SDTIME : SD TIMER
C IN  SDDISC : SD DISC_INST
C IN  NUMINS : NUMERO D'INSTANT
C IN  VALINC : VARIABLE CHAPEAU POUR INCREMENTS VARIABLES
C IN  SOLALG : VARIABLE CHAPEAU POUR INCREMENTS SOLUTIONS
C IN  MEELEM : VARIABLE CHAPEAU POUR NOM DES MATR_ELEM
C IN  MEASSE : VARIABLE CHAPEAU POUR NOM DES MATR_ASSE
C IN  VEELEM : VARIABLE CHAPEAU POUR NOM DES VECT_ELEM
C IN  VEASSE : VARIABLE CHAPEAU POUR NOM DES VECT_ASSE
C IN  DEFICO : SD DEFINITION CONTACT
C IN  RESOCO : SD RESOLUTION CONTACT
C IN  RESOCU : SD RESOLUTION LIAISON_UNILATER
C IN  SDDYNA : SD DYNAMIQUE
C IN  SDSENS : SD SENSIBILITE
C IN  MATASS : NOM DE LA MATRICE DU PREMIER MEMBRE ASSEMBLEE
C IN  MAPREC : NOM DE LA MATRICE DE PRECONDITIONNEMENT (GCPC)
C OUT CODERE : CHAM_ELEM CODE RETOUR ERREUR INTEGRATION LDC
C OUT LICCVG : CODES RETOURS (* POUR INDIQUER CEUX QUI SONT CHANGES)
C               (1)   - PILOTAGE
C               (2) * - INTEGRATION DE LA LOI DE COMPORTEMENT
C               (3)   - TRAITEMENT DU CONTACT 
C               (4)   - MATRICE DE CONTACT
C               (5) * - MATRICE DU SYSTEME SINGULIERE
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
      REAL*8       INSTAP,DIINST
      CHARACTER*19 CNCINE,CNDONN,CNPILO
      INTEGER      LDCCVG,FACCVG  
      REAL*8       R8BID
      LOGICAL      NDYNLO,LSTAT,LIMPL
      INTEGER      IFM,NIV
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
      CALL INFDBG('MECA_NON_LINE',IFM,NIV)
C
C --- AFFICHAGE
C
      IF (NIV.GE.2) THEN
        WRITE (IFM,*) '<MECANONLINE> PREDICTION TYPE EULER' 
      ENDIF
C
C --- FONCTIONNALITES ACTIVEES
C
      LSTAT  = NDYNLO(SDDYNA,'STATIQUE')
      LIMPL  = NDYNLO(SDDYNA,'IMPLICITE')  
C
C --- INITIALISATIONS
C
      INSTAP = DIINST(SDDISC,NUMINS)
      LDCCVG = 0
      FACCVG = 0 
      CNDONN = '&&CNCHAR.DONN'
      CNPILO = '&&CNCHAR.PILO'    
      CALL VTZERO(CNDONN) 
      CALL VTZERO(CNPILO)                     
C
C --- DECOMPACTION DES VARIABLES CHAPEAUX
C      
      CALL NMCHEX(VEASSE,'VEASSE','CNCINE',CNCINE) 
C
C --- INCREMENT DE DEPLACEMENT NUL EN PREDICTION
C     
      IF (LSTAT.OR.LIMPL) THEN 
        CALL NMDEP0('ON ',SOLALG)
      ENDIF      
C
C --- CALCUL DE LA MATRICE GLOBALE
C  
      CALL NMPRMA(MODELE,MATE  ,CARELE,COMPOR,CARCRI,
     &            PARMET,METHOD,LISCHA,NUMEDD,SOLVEU,
     &            COMREF,SDDISC,SDDYNA,SDTIME,NUMINS,
     &            FONACT,DEFICO,RESOCO,VALINC,SOLALG,
     &            VEELEM,MEELEM,MEASSE,MAPREC,MATASS,
     &            CODERE,FACCVG,LDCCVG)
C  
      IF ((FACCVG.EQ.1).OR.(FACCVG.EQ.2)) GOTO 9999
C
C --- CALCUL DES CHARGEMENTS VARIABLES AU COURS DU PAS DE TEMPS
C   
      CALL NMCHAR('VARI','PREDICTION'   ,
     &            MODELE,NUMEDD,MATE  ,CARELE,COMPOR,
     &            LISCHA,CARCRI,NUMINS,SDDISC,R8BID,
     &            FONACT,DEFICO,RESOCO,RESOCU,COMREF,
     &            VALINC,SOLALG,VEELEM,MEASSE,VEASSE,
     &            SDSENS,SDDYNA)
C
C --- CALCUL DU SECOND MEMBRE 
C  
      CALL NMASSP(MODELE,NUMEDD,MATE  ,CARELE,COMREF,
     &            COMPOR,LISCHA,CARCRI,FONACT,DEFICO,
     &            SDDYNA,VALINC,SOLALG,VEELEM,VEASSE,
     &            SDTIME,LDCCVG,CODERE,CNPILO,CNDONN)
C
C --- INCREMENT DE DEPLACEMENT NUL EN PREDICTION
C     
      IF (LSTAT.OR.LIMPL) THEN 
        CALL NMDEP0('OFF',SOLALG)
      ENDIF       
C     
      IF (LDCCVG.EQ.1) GOTO 9999
C
C --- RESOLUTION K.DU = DF
C
      CALL NMRESD(FONACT,SDDYNA,SDTIME,SOLVEU,NUMEDD,
     &            INSTAP,MAPREC,MATASS,CNDONN,CNPILO,
     &            CNCINE,SOLALG)   
C
9999  CONTINUE
C
C --- RECOPIE CODE RETOUR ERREURS      
C
      LICCVG(2) = LDCCVG
      LICCVG(5) = FACCVG           
C      
      CALL JEDEMA()
      END
