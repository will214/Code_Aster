      SUBROUTINE NMINIT(RESULT,MODELE,NUMEDD,MATE  ,COMPOR,
     &                  CARELE,PARMET,LISCHA,MAPREC,SOLVEU,
     &                  CARCRI,NUMINS,SDDISC,SDNURO,DEFICO,
     &                  SDCRIT,COMREF,FONACT,PARCON,PARCRI,
     &                  LISCH2,MAILLA,SDPILO,SDDYNA,SDIMPR,
     &                  SDSUIV,SDSENS,SDOBSE,SDTIME,SDERRO,
     &                  DEFICU,RESOCU,RESOCO,VALINC,SOLALG,
     &                  MEASSE,VEELEM,MEELEM,VEASSE,CODERE)
C
C MODIF ALGORITH  DATE 09/03/2010   AUTEUR ABBAS M.ABBAS 
C ======================================================================
C            CONFIGURATION MANAGEMENT OF EDF VERSION
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
C TOLE CRP_21 CRP_20
C
      IMPLICIT NONE
      INTEGER      FONACT(*)
      REAL*8       PARCON(*),PARCRI(*),PARMET(*)
      INTEGER      NUMINS
      CHARACTER*8  RESULT,MAILLA
      CHARACTER*14 SDPILO,SDOBSE
      CHARACTER*19 SOLVEU,SDNURO,SDDISC,SDCRIT
      CHARACTER*19 LISCHA,LISCH2,SDDYNA
      CHARACTER*19 MAPREC
      CHARACTER*24 MODELE,COMPOR,NUMEDD
      CHARACTER*24 DEFICO,RESOCO
      CHARACTER*24 CARCRI
      CHARACTER*24 MATE,CARELE,CODERE
      CHARACTER*19 VEELEM(*),MEELEM(*)
      CHARACTER*19 VEASSE(*),MEASSE(*)
      CHARACTER*19 SOLALG(*),VALINC(*)
      CHARACTER*24 SDIMPR,SDSUIV,SDSENS,SDTIME,SDERRO
      CHARACTER*24 DEFICU,RESOCU
      CHARACTER*24 COMREF
C
C ----------------------------------------------------------------------
C
C ROUTINE MECA_NON_LINE (ALGORITHME)
C
C INITIALISATIONS
C
C ----------------------------------------------------------------------
C
C
C OUT LISCH2 : NOM DE LA SD INFO CHARGE POUR STOCKAGE DANS LA SD
C              RESULTAT
C
C
C ----------------------------------------------------------------------
C
      INTEGER      IRET,IBID
      REAL*8       R8BID3(3)      
      INTEGER      DERNIE
      REAL*8       DIINST,INSTIN
      CHARACTER*19 COMMOI
      CHARACTER*2  CODRET
      LOGICAL      REAROT,LACC0,LPILO,LMPAS,LSSTF,LERRT
      LOGICAL      ISFONC,NDYNLO
      LOGICAL      LCONT,LUNIL
      INTEGER      IFM,NIV
      CHARACTER*19 LIGRCF,LIGRXF
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
      CALL INFDBG('MECA_NON_LINE',IFM,NIV)
C
C --- AFFICHAGE
C
      IF (NIV.GE.2) THEN
        WRITE (IFM,*) '<MECANONLINE> INITIALISATION DU CALCUL'
      ENDIF
C
C --- INITIALISATIONS
C
      CALL DISMOI('F','NOM_MAILLA',MODELE,'MODELE',IBID,MAILLA,IRET)
      LACC0  = .FALSE.
      LUNIL  = .FALSE.
      REAROT = .FALSE.
      LCONT  = .FALSE.
C
C --- CREATION DE LA STRUCTURE DE DONNEE GESTION DU TEMPS
C
      CALL NMCRTI(SDTIME) 
C
C --- CREATION DE LA STRUCTURE DE DONNEE GESTION DES ERREURS
C
      CALL NMCRER(SDERRO)  
C
C --- SAISIE ET VERIFICATION DE LA COHERENCE DU CHARGEMENT CONTACT      
C
      CALL NMDOCT(LISCHA,DEFICO,DEFICU,LCONT ,LUNIL ,
     &            LIGRCF,LIGRXF)            
C
C --- NUMEROTATION ET CREATION DU PROFIL DE LA MATRICE
C
      CALL NMPROF(MODELE,RESULT,LISCHA,SOLVEU,SDTIME,
     &            NUMEDD)
C
C --- CREATION DE VARIABLES "CHAPEAU" POUR STOCKER LES NOMS
C
      CALL NMCHAP(SDSENS,SDDYNA,FONACT,VALINC,SOLALG,
     &            MEELEM,VEELEM,VEASSE,MEASSE)
C
C --- INITIALISATIONS LIEES AUX STRUCTURES EN GRANDS DEPLACEMENTS
C
      CALL NUROTA(NUMEDD(1:14),COMPOR(1:19),SDNURO,REAROT)
C
C --- FONCTIONNALITES ACTIVEES
C
      CALL NMFONC(PARCRI,PARMET,SOLVEU,MODELE,DEFICO,
     &            LISCHA,REAROT,LCONT ,LUNIL ,SDSENS,
     &            SDDYNA,MATE  ,COMPOR,FONACT)
      LPILO  = ISFONC(FONACT,'PILOTAGE'  )
      LMPAS  = NDYNLO(SDDYNA,'MULTI_PAS' )
      LSSTF  = ISFONC(FONACT,'SOUS_STRUC')
      LERRT  = ISFONC(FONACT,'ERRE_TEMPS')
C
C --- CREATION DE LA STRUCTURE DE DONNEE RESULTAT DU CONTACT
C
      IF (LCONT) THEN
        CALL CFMXSD(MAILLA,NUMEDD,DEFICO,RESOCO,LIGRCF,
     &              LIGRXF)
      ENDIF
C
C --- CREATION DE LA STRUCTURE DE LIAISON_UNILATERALE
C
      IF (LUNIL) THEN
        CALL CUCRSD(MAILLA,NUMEDD,DEFICU,RESOCU)
      ENDIF  
C
C --- CREATION DES VECTEURS D'INCONNUS
C
      CALL NMCRCH(NUMEDD,FONACT,SDDYNA,SDSENS,DEFICO,
     &            VALINC,SOLALG,VEASSE)    
C
C --- CONSTRUCTION DU CHAM_NO ASSOCIE AU PILOTAGE
C
      IF (LPILO) THEN
        CALL NMDOPI(MODELE,NUMEDD,SDPILO)
      ENDIF
C
C --- CONSTRUCTION DU CHAM_ELEM_S ASSOCIE AU COMPORTEMENT
C
      CALL NMDOCO(MODELE,CARELE,COMPOR)
C
C --- LECTURE ETAT_INIT
C
      CALL NMDOET(RESULT,MODELE,COMPOR,FONACT,NUMEDD,
     &            SDSENS,SDPILO,SDDYNA,SOLALG,LACC0 ,
     &            INSTIN)
C
C --- CREATION SD DISCRETISATION, ARCHIVAGE ET OBSERVATION
C
      CALL DIINIT(MAILLA,RESULT,MATE  ,CARELE,SDDYNA,
     &            INSTIN,SDDISC,DERNIE,SDOBSE,SDSUIV)
C
C --- CREATION DE LA SD POUR ARCHIVAGE DES INFORMATIONS DE CONVERGENCE
C
      CALL NMCRCV(SDCRIT)
C
C --- CREATION DU CHAMP DES VARIABLES DE COMMANDE DE REFERENCE
C
      CALL NMVCRE(MODELE,MATE  ,CARELE,COMREF)        
C
C --- PRE-CALCUL DES MATR_ELEM CONSTANTES AU COURS DU CALCUL
C
      CALL NMINMC(FONACT,LISCHA,SDDYNA,MODELE,COMPOR,
     &            SOLVEU,NUMEDD,DEFICO,RESOCO,CARCRI,
     &            SOLALG,VALINC,MATE  ,CARELE,SDDISC,
     &            SDTIME,COMREF,MEELEM,MEASSE,VEELEM,
     &            CODERE)
C
C --- INSTANT INITIAL
C
      NUMINS = 0
      INSTIN = DIINST(SDDISC,NUMINS)
C
C --- EXTRACTION VARIABLES DE COMMANDES AU TEMPS T-
C 
      CALL NMCHEX(VALINC,'VALINC','COMMOI',COMMOI)
      CALL NMVCLE(MODELE,MATE  ,CARELE,LISCHA,INSTIN,
     &            COMMOI,CODRET)
C
C --- CALCUL ET ASSEMBLAGE DES VECT_ELEM CONSTANTS AU COURS DU CALCUL
C 
      CALL NMINVC(MODELE,MATE  ,CARELE,COMPOR,CARCRI,
     &            SDDISC,SDDYNA,VALINC,SOLALG,LISCHA,
     &            COMREF,DEFICO,RESOCO,RESOCU,NUMEDD,
     &            FONACT,PARCON,VEELEM,SDSENS,VEASSE,
     &            MEASSE)   
C
C --- INITIALISATION CALCUL PAR SOUS-STRUCTURATION
C
      IF (LSSTF) THEN
        CALL NMLSSV('INIT',LISCHA,IBID  )
      ENDIF       
C
C --- CALCUL DE L'ACCELERATION INITIALE
C
      IF (LACC0) THEN
        CALL NMCHAR('ACCI',' ',
     &              MODELE,NUMEDD,MATE  ,CARELE,COMPOR,
     &              LISCHA,CARCRI,NUMINS,SDDISC,PARCON,
     &              FONACT,DEFICO,RESOCO,RESOCU,COMREF,
     &              VALINC,SOLALG,VEELEM,MEASSE,VEASSE,
     &              SDSENS,SDDYNA)
        CALL ACCEL0(MODELE,NUMEDD,FONACT,LISCHA,DEFICO,
     &              RESOCO,MAPREC,SOLVEU,VALINC,SDDYNA,
     &              SDTIME,SDDISC,MEELEM,MEASSE,VEELEM,
     &              VEASSE,SOLALG)
      ENDIF
C
C --- CREATION DE LA SD AFFICHAGE
C
      CALL IMPINI(SDIMPR,SDSUIV,FONACT,PARCRI)
C
C --- AFFICHAGE: INITIALISATION
C
      CALL NMIMPR('INIT',' ',' ',0.D0,0)    
C
C --- PRE-CALCUL DES MATR_ASSE CONSTANTES AU COURS DU CALCUL
C
      CALL NMINMA(FONACT,LISCHA,SDDYNA,SOLVEU,NUMEDD,
     &            MEELEM,MEASSE)   
C
C --- CREATION DE LA SD EVOL_NOLI
C
      CALL NMNOLI(COMPOR,SDDISC,CARCRI,SDCRIT,FONACT,
     &            DERNIE,MODELE,MAILLA,MATE  ,SDSENS,
     &            CARELE,LISCH2,DEFICO,RESOCO,SDDYNA)   
      CALL COPISD('LISTE_CHARGES','G',LISCHA,LISCH2)
C
C --- CREATION DE LA TABLE DES GRANDEURS
C
      IF (LERRT) THEN
        CALL CETULE(MODELE,R8BID3,IRET  )
      ENDIF        
C
C --- CALCUL DU SECOND MEMBRE INITIAL POUR MULTI-PAS
C
      IF (LMPAS) THEN
        CALL NMIHHT(MODELE,NUMEDD,MATE  ,COMPOR,CARELE,
     &              LISCHA,CARCRI,COMREF,FONACT,SDDYNA,
     &              SDSENS,SDTIME,DEFICO,RESOCO,RESOCU,
     &              VALINC,SDDISC,PARCON,SOLALG,VEASSE)
      ENDIF        
C
      CALL JEDEMA()
      END
