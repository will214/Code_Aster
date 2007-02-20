      SUBROUTINE LCPIMA (MATE,COMPOR,TEMP,TREF,INSTAM,INSTAP)

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 20/02/2007   AUTEUR MICHEL S.MICHEL 
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
C ***************************************************************
C *       INTEGRATION DE LA LOI SIMO_MIEHE ECROUISSAGE ISOTROPE *
C *        LECTURE DES CARACTERISTIQUES DU MATERIAU             *
C ***************************************************************
C IN  MATE    : ADRESSE DU MATERIAU
C IN  COMPOR  : COMPORTEMENT
C IN  TEMP    : TEMPERATURE A L'INSTANT DU CALCUL
C IN  TREF    : TEMPERATURE DE REFERENCE
C IN  INSTAM  : INTANT T-
C IN  INSTAP  : INSTANT T+
C IN COMMON   : PM DOIT DEJA ETRE AFFECTE (PLASTICITE CUMULEE EN T-)
C ----------------------------------------------------------------------

      IMPLICIT NONE
      
C DECLARATION GLOBALE

      INTEGER       MATE
      CHARACTER*16 COMPOR(3)
      REAL*8        TEMP,TREF,INSTAM,INSTAP
      
C  COMMON MATERIAU POUR VON MISES

      INTEGER JPROL,JVALE,NBVAL
      REAL*8  PM,YOUNG,NU,MU,UNK,TROISK,COTHER
      REAL*8  SIGM0,EPSI0,DT,COEFM,RPM,PENTE

      COMMON /LCPIM/
     &          PM,YOUNG,NU,MU,UNK,TROISK,COTHER,
     &          SIGM0,EPSI0,DT,COEFM,RPM,PENTE,
     &          JPROL,JVALE,NBVAL
C ----------------------------------------------------------------------

C DECLARATION LOCALE

      CHARACTER*2 CODRET(3)
      CHARACTER*8 NOMRES(3)
      REAL*8       NUM,YOUNGM,ALPHA,SIGY,AIRE,DSDE
      REAL*8       R8BID,VALRES(3)
C ----------------------------------------------------------------------

      
C 1 - A L INSTANT COURANT YOUNG, MU ET UNK

      CALL RCVALA(MATE,' ','ELAS',1,'TEMP',TEMP,1,'NU',NU,
     &            CODRET(1),'F ')
      
      IF (COMPOR(1)(6:14).EQ.'ISOT_TRAC') THEN
        CALL RCTRAC(MATE,'TRACTION','SIGM',TEMP,JPROL,JVALE,NBVAL,
     &             YOUNG)
      ELSE
        CALL RCVALA(MATE,' ','ELAS',1,'TEMP',TEMP,1,'E',YOUNG,
     &              CODRET(1),'F ')
      ENDIF

      MU     = YOUNG/(2.D0*(1.D0+NU))
      TROISK = YOUNG/(1.D0-2.D0*NU)
      UNK    = TROISK/3.D0
     
C 2 - COEFFICIENT DE DILATATION THERMIQUE ALPHA
C     => CONTRAINTE THERMIQUE COTHER

      CALL RCVALA(MATE,' ','ELAS',1,'TEMP',TEMP,1,'ALPHA',
     &            ALPHA,CODRET(1),'  ')
      IF(CODRET(1).NE.'OK') ALPHA=0.D0

      COTHER = TROISK*ALPHA*(TEMP-TREF)

C 3 - SIGY, PENTE ET ECROUISSAGE A TEMP ET EN P-

      IF(COMPOR(1)(10:14).EQ.'_TRAC') THEN
        CALL RCFONC('S','TRACTION',JPROL,JVALE,NBVAL,SIGY,
     &             R8BID,R8BID,R8BID,R8BID,R8BID,R8BID,R8BID,R8BID)

        CALL RCFONC('V','TRACTION',JPROL,JVALE,NBVAL,R8BID,
     &             R8BID,R8BID,PM,RPM,PENTE,AIRE,R8BID,R8BID)
      ENDIF
      
      IF(COMPOR(1)(10:14).EQ.'_LINE') THEN
        NOMRES(1)='D_SIGM_EPSI'
        NOMRES(2)='SY'
        CALL RCVALA(MATE,' ','ECRO_LINE',1,'TEMP',TEMP,2,
     &              NOMRES,VALRES,CODRET,'F ')
         DSDE=VALRES(1)
         SIGY=VALRES(2)
         PENTE=DSDE*YOUNG/(YOUNG-DSDE)
         RPM=PENTE*PM+SIGY
      ENDIF

C 4 - PARAMETRES DE CARACTERISTIQUES VISQUEUSES SI BESOIN

      DT = INSTAP - INSTAM
      IF (COMPOR(1)(1:4).EQ.'VISC') THEN
        NOMRES(1)= 'SIGM_0'
        NOMRES(2)= 'EPSI_0'
        NOMRES(3)= 'M'
        CALL RCVALA(MATE,' ','VISC_SINH',1,'TEMP',TEMP,3,
     &              NOMRES(1),VALRES(1),CODRET(1),'F ')
        SIGM0=VALRES(1)
        EPSI0=VALRES(2)
        COEFM= VALRES(3)
      ENDIF
      
      END
