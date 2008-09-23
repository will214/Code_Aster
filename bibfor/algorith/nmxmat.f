      SUBROUTINE NMXMAT(MODELZ,MATE  ,CARELE,COMPOR,CARCRI,
     &                  SDDISC,SDDYNA,FONACT,NUMINS,ITERAT,
     &                  VALMOI,VALPLU,POUGD ,SOLALG,LISCHA,
     &                  COMREF,DEFICO,RESOCO,SOLVEU,NUMEDD,
     &                  SDTIME,NBMATR,LTYPMA,LOPTME,LOPTMA,
     &                  LCALME,LASSME,LCFINT,MEELEM,MEASSE,
     &                  VEELEM,LDCCVG,CODERE)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 23/09/2008   AUTEUR ABBAS M.ABBAS 
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
C TOLE CRP_21
C
      IMPLICIT NONE
      INTEGER       NBMATR    
      CHARACTER*6   LTYPMA(20)
      CHARACTER*16  LOPTME(20),LOPTMA(20)
      LOGICAL       LCALME(20),LASSME(20)       
      CHARACTER*(*) MODELZ
      CHARACTER*(*) MATE
      CHARACTER*24  COMPOR,CARCRI,CARELE
      INTEGER       NUMINS,ITERAT,LDCCVG
      CHARACTER*19  SDDISC,SDDYNA,LISCHA,SOLVEU
      CHARACTER*24  DEFICO,RESOCO,NUMEDD
      CHARACTER*24  COMREF,CODERE,SDTIME
      CHARACTER*24  VALMOI(8),VALPLU(8),POUGD(8)
      CHARACTER*19  MEELEM(*),MEASSE(*),VEELEM(*),SOLALG(*)
      LOGICAL       FONACT(*)   
      LOGICAL       LCFINT       
C 
C ----------------------------------------------------------------------
C
C ROUTINE MECA_NON_LINE (CALCUL - UTILITAIRE)
C
C CALCUL ET ASSEMBLAGE DES MATR_ELEM DE LA LISTE
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
C IN  LISCHA : LISTE DES CHARGES
C IN  RESOCO : SD RESOLUTION CONTACT
C IN  DEFICO : SD DEF. CONTACT
C IN  SDDYNA : SD POUR LA DYNAMIQUE
C IN  METHOD : INFORMATIONS SUR LES METHODES DE RESOLUTION (VOIR NMLECT)
C IN  PARMET : PARAMETRES DES METHODES DE RESOLUTION (VOIR NMLECT)
C IN  SOLVEU : SOLVEUR
C IN  CARCRI : PARAMETRES METHODES D'INTEGRATION LOCALES (VOIR NMLECT)
C IN  SDDISC : SD DISC_INST
C IN  PREMIE : SI PREMIER INSTANT DE CALCUL
C IN  NUMINS : NUMERO D'INSTANT
C IN  ITERAT : NUMERO D'ITERATION
C IN  VALMOI : VARIABLE CHAPEAU POUR ETAT EN T-
C IN  VALPLU : VARIABLE CHAPEAU POUR ETAT EN T+
C IN  POUGD  : VARIABLE CHAPEAU POUR POUR POUTRES EN GRANDES ROTATIONS
C IN  SOLALG : VARIABLE CHAPEAU POUR INCREMENTS SOLUTIONS
C IN  NBMATR : NOMBRE DE MATR_ELEM DANS LA LISTE
C IN  LTYPMA : LISTE DES NOMS DES MATR_ELEM
C IN  LOPTME : LISTE DES OPTIONS DES MATR_ELEM 
C IN  LOPTMA : LISTE DES OPTIONS DES MATR_ASSE
C IN  LASSME : SI MATR_ELEM A ASSEMBLER
C IN  LCALME : SI MATR_ELEM A CALCULER
C IN  LCFINT : .TRUE. SI VECT_ELEM DES FORCES INTERNES A CALCULER
C OUT LDCCVG : CODE RETOUR DE L'INTEGRATION DU COMPORTEMENT
C                0 : CAS DE FONCTIONNEMENT NORMAL
C                1 : ECHEC DE L'INTEGRATION DE LA LDC
C                3 : SIZZ PAS NUL POUR C_PLAN DEBORST
C OUT CODERE : CHAM_ELEM CODE RETOUR ERREUR INTEGRATION LDC
C      
C ----------------------------------------------------------------------
C
      CHARACTER*6  TYPMAT 
      INTEGER      IMATR
      CHARACTER*16 OPTCAL,OPTASS
      CHARACTER*19 NMCHEX,MATELE,MATASS      
      CHARACTER*1  BASE    
      REAL*8       DIINST,INSTAM,INSTAP 
      LOGICAL      LCALC,LASSE
      LOGICAL      LBID
      REAL*8       R8BID
C      
C ----------------------------------------------------------------------
C
         
C
C --- INITIALISATIONS
C
      BASE   = 'V'
      INSTAM = DIINST(SDDISC,NUMINS-1)
      INSTAP = DIINST(SDDISC,NUMINS)
      LDCCVG = 0 
C
C --- SI CALCUL DES FORCES INTERNES
C
      IF (LCFINT) THEN
        CALL ASSERT(.FALSE.) 
      ENDIF          
C
C --- CALCUL ET ASSEMBLAGE DES MATR_ELEM
C      
      DO 10 IMATR = 1,NBMATR
C
C --- MATR_ELEM COURANTE
C      
        TYPMAT = LTYPMA(IMATR)
        OPTCAL = LOPTME(IMATR)
        OPTASS = LOPTMA(IMATR)     
        LCALC  = LCALME(IMATR)
        LASSE  = LASSME(IMATR)
C
C --- CALCULER MATR_ELEM 
C           
        IF (LCALC) THEN
          MATELE = NMCHEX(MEELEM,'MEELEM',TYPMAT)
          IF (TYPMAT.EQ.'MERIGI') THEN
            CALL NMTIME('INIT' ,'TMP',SDTIME,LBID  ,R8BID )
            CALL NMTIME('DEBUT','TMP',SDTIME,LBID  ,R8BID )
            CALL NMRIGI(MODELZ,MATE  ,CARELE,COMPOR,CARCRI,
     &                  SDDYNA,FONACT,ITERAT,VALMOI,VALPLU,
     &                  POUGD ,SOLALG,LISCHA,COMREF,MEELEM,
     &                  VEELEM,OPTCAL,LDCCVG,CODERE) 
            CALL NMTIME('FIN'      ,'TMP',SDTIME,LBID  ,R8BID )
            CALL NMTIME('CALC_MATR','TMP',SDTIME,LBID  ,R8BID )
          ELSE
            CALL NMCALM(TYPMAT,MODELZ,LISCHA,MATE  ,CARELE,
     &                  COMPOR,INSTAM,INSTAP,CARCRI,VALMOI,
     &                  VALPLU,SOLALG,OPTCAL,BASE  ,MEELEM,
     &                  RESOCO,MATELE)
          ENDIF 
        ENDIF
C
C --- ASSEMBLER MATR_ELEM 
C             
        IF (LASSE) THEN
          MATASS = NMCHEX(MEASSE,'MEASSE',TYPMAT)
          CALL NMASSM(FONACT,DEFICO,LISCHA,SOLVEU,NUMEDD,
     &                TYPMAT,OPTASS,MEELEM,MATASS)
        ENDIF
  10  CONTINUE 
C
      END
