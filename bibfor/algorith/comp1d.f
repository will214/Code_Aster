      SUBROUTINE COMP1D(OPTION,SIGX,EPSX,DEPX,TREF,TEMPM,
     +                  TEMPP,VIM,VIP,SIGXP,ETAN,CODRET,
     +                   CORRM,CORRP)
      IMPLICIT NONE
      CHARACTER*16   OPTION
      INTEGER        CODRET
      REAL*8         TEMPM,TEMPP,TREF
      REAL*8         VIM(*),VIP(*),SIGX,SIGXP,EPSX,DEPX,ETAN
C ----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 25/03/2004   AUTEUR OUGLOVA A.OUGLOVA 
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
C
C     INTEGRATION DE LOIS DE COMPORTEMENT NON LINEAIRES 
C     POUR DES ELEMENTS 1D PAR UNE METHODE INSPIREE DE CELLE DE DEBORST
C     EN CONTRAINTES PLANES.
C
C     PERMET D'UTILISER TOUS LES COMPORTEMENTS DEVELOPPES EN AXIS POUR
C     TRAITER DES PROBLEMES 1D (BARRES, PMF,...)
C
C     POUR POUVOIR UTILISER CETTE METHODE, IL FAUT FOURNIR SOUS LE
C     MOT-CLES COMP_INCR : ALGO_1D='DEBORST'
C
C     EN ENTREE ON DONNE LES VALEURS UNIAXIALES A L'INSTANT PRECEDENT :
C      - SIGX(T-),EPSX(T-),VIM(T-) ET L'INCREMENT DEPSX
C      - LES TEMPERATURES
C      - ET LES VARIABLES INTERNES A L'ITERATION PRECEDENTE, 
C     RECOPIEES DANS VIP
C     EN SORTIE, ON OBTIENT LES CONTRAINTES SIGXP(T+), LE MODULES
C     TANGENT ETAN, LES VARAIBLES INTERNES VIP(T+) ET LE 
C     CODE RETOUR CODRET.             
C   EN SORTIE DE COMP1D, CE CODE RETOUR EST TRANSMIS A LA ROUTINE NMCONV
C   POUR AJOUTER DES ITERATIONS SI SIGYY OU SIGZZ NE SONT PAS NULLES. 

C ----------------------------------------------------------------------
C IN  : OPTION    : NOM DE L'OPTION A CALCULER 
C IN  : SIGM      : SIGMA XX A L'INSTANT MOINS
C IN  : EPSX      : EPSI XX A L'INSTANT MOINS
C IN  : DEPX      : DELTA-EPSI XX A L'INSTANT ACTUEL
C IN  : TREF      : TEMPERATURE DE REFERENCE
C IN  : TEMPM     : TEMPERATURE A L'INSTANT MOINS
C IN  : TEMPP     : TEMPERATURE A L'INSTANT PLUS
C IN  : VIM       : VARIABLES INTERNES A L'INSTANT MOINS
C VAR : VIP       : VARIABLES INTERNES A L'INSTANT PLUS EN SORTIE
C IN  CORRM  : CORROSION A L'INSTANT MOINS
C IN  CORRP  : CORROSION A L'INSTANT PLUS
C                  VARIABLES INTERNES A L'ITERATION PRECEDENTE EN ENTREE
C OUT : SIGXP     : CONTRAINTES A L'INSTANT PLUS
C OUT : ETAN      : MODULE TANGENT DIRECTION X
C OUT : CODRET    : CODE RETOUR NON NUL SI SIGYY OU SIGZZ NON NULS
C ----------------------------------------------------------------------
C
C **************** DEBUT COMMUNS NORMALISES JEVEUX *********************
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
      CHARACTER*80                                             ZK80
      COMMON  / KVARJE / ZK8(1) , ZK16(1) , ZK24(1) , ZK32(1) ,ZK80(1)
C
C ***************** FIN COMMUNS NORMALISES JEVEUX **********************
C
C
C *************** DECLARATION DES VARIABLES LOCALES ********************
C
      INTEGER        NEQ,NVAMAX,IMATE,IINSTM
      INTEGER        IINSTP,ICOMPO,ICARCR,NZ
      INTEGER        I,J,NZMAX,ICOMPT,ITER      
C
      REAL*8         DSIDEP(6,6)
      REAL*8         ZERO,UN,DEUX,XM,XI,XS,ALPH,SIGYI,SIGYS
      REAL*8         HYDRGM,HYDRGP,SECHGM,SECHGP
      REAL*8         EPSANM(6),EPSANP(6),PHASM(7),PHASP(7)
      REAL*8         LC(10,27),SIGMAY,CORRM,CORRP
      REAL*8         R8PREM,R8MIEM,NU,ALPHA,SIGXI,SIGXS
      REAL*8         SIGM(6),SIGP(6),EPS(6),DEPS(6)
C
      CHARACTER*8    TYPMOD(2)
C
C *********** FIN DES DECLARATIONS DES VARIABLES LOCALES ***************
C
C ********************* DEBUT DE LA SUBROUTINE *************************
C
C ---    INITIALISATIONS :
         NEQ  = 6
         ZERO = 0.0D0

         CALL R8INIR (6,ZERO,EPS,1)
         CALL R8INIR (6,ZERO,SIGM,1)
         CALL R8INIR (6,ZERO,DEPS,1)
         CALL R8INIR (36,ZERO,DSIDEP,1)
         EPS(1)=EPSX
         DEPS(1)=DEPX
         SIGM(1)=SIGX
         TYPMOD(1) = 'COMP1D '
         TYPMOD(2) = '        '
         
C
C ---    PARAMETRES EN ENTREE
C
         CALL JEVECH ('PMATERC','L',IMATE)
         CALL JEVECH ('PINSTMR','L',IINSTM)
         CALL JEVECH ('PINSTPR','L',IINSTP)
         CALL JEVECH ('PCOMPOR','L',ICOMPO)
         CALL JEVECH ('PCARCRI','L',ICARCR)
C
C ---    INITIALISATION DES TABLEAUX
C
         HYDRGM = ZERO
         HYDRGP = ZERO
         SECHGM = ZERO
         SECHGP = ZERO
C
         CALL R8INIR (NEQ,ZERO,EPSANM,1)
C
         CALL R8INIR (NEQ,ZERO,EPSANP,1)
C
         NZMAX = 7
         CALL R8INIR (NZMAX,ZERO,PHASM,1)
         CALL R8INIR (NZMAX,ZERO,PHASP,1) 
         NZ = NZMAX        
         CALL R8INIR (270,ZERO,LC,1) 
C
         CALL NMCOMP(2,TYPMOD,ZI(IMATE),ZK16(ICOMPO),ZR(ICARCR),
     +               ZR(IINSTM),ZR(IINSTP),TEMPM,TEMPP,TREF,HYDRGM,
     +               HYDRGP,SECHGM,SECHGP,EPS,DEPS,SIGM,
     +               VIM,OPTION,EPSANM,EPSANP,NZ,PHASM,
     +               PHASP,LC,SIGP,VIP,DSIDEP,
     +               CODRET,CORRM,CORRP)
C         
         SIGXP=SIGP(1)
         ETAN=DSIDEP(1,1)
C
9999  CONTINUE
      END
