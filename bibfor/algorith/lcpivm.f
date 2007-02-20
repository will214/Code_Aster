      SUBROUTINE LCPIVM (MATE,COMPOR,CARCRI,INSTAM,INSTAP,
     &                   TM,TP,TREF,FM,DF,VIM,
     &                   OPTION,TAUP,VIP,DTAUDF,IRET)

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
C TOLE CRP_20

      IMPLICIT NONE
      INTEGER            MATE,IRET
      CHARACTER*16       COMPOR,OPTION
      REAL*8             INSTAM,INSTAP,TM,TP,TREF
      REAL*8             DF(3,3),FM(3,3)
      REAL*8             VIM(8),VIP(8)
      REAL*8             TAUP(6),DTAUDF(6,3,3)
      REAL*8             CARCRI(3)

C ----------------------------------------------------------------------
C       INTEGRATION DE LA LOI DE COMPORTEMENT PLASTIQUE ISOTROPE 
C              EN GRANDES DEFORMATIONS DE TYPE SIMO-MIEHE        
C              AINSI QUE SA VERSION VISQUEUSE (LOI SINH)         
C ----------------------------------------------------------------------

C IN  MATE   : ADRESSE DU MATERIAU CODE
C IN  COMPOR : COMPORTEMENT
C IN  CARCRI : PARAMETRES POUR L INTEGRATION DE LA LOI DE COMMPORTEMENT
C                 CARCRI(1) = NOMBRE D ITERATIONS
C                 CARCRI(3) = PRECISION SUR LA CONVERGENCE
C IN  INSTAM : INSTANT PRECEDENT
C IN  INSTAP : INSTANT COURANT
C IN  TM     : TEMPERATURE A L INSTANT PRECEDENT
C IN  TP     : TEMPERATURE A L'INSTANT DU CALCUL
C IN  TREF   : TEMPERATURE DE REFERENCE
C IN  DF     : INCREMENT DU GRADIENT DE LA TRANSFORMATION
C IN  FM     : GRADIENT DE LA TRANSFORMATION A L INSTANT PRECEDENT
C IN  VIM    : VARIABLES INTERNES A L INSTANT DU CALCUL PRECEDENT
C                 VIM(1)=P (DEFORMATION PLASTIQUE CUMULEE)
C                 VIM(2)=INDICATEUR DE PLASTICITE
C                          0 : ELASTIQUE  1: PLASTIQUE
C                 TRE/3 AVEC E=(ID-BE)/2.D0 EST STOCKE DANS :
C                 VIP(3) POUR LA PLASTICITE OU 
C                 VIP(1) POUR L ELASTICITE
C IN  OPTION : OPTION DEMANDEE : RIGI_MECA_TANG , FULL_MECA , RAPH_MECA
C OUT TAUP   : CONTRAINTES DE KIRCHHOFF A L'INSTANT ACTUEL
C OUT VIP    : VARIABLES INTERNES A L'INSTANT ACTUEL
C OUT DTAUDF : DERIVEE DE TAU PAR RAPPORT A DF  * (F)T
C OUT IRET   : CODE RETOUR DE  L'INTEGRATION DE LA LDC
C               IRET=0 => PAS DE PROBLEME
C               IRET=1 => DJ<0 ET INTEGRATION IMPOSSIBLE
C ----------------------------------------------------------------------
C  COMMON MATERIAU POUR VON MISES

      INTEGER JPROL,JVALE,NBVAL
      REAL*8  PM,YOUNG,NU,MU,UNK,TROISK,COTHER
      REAL*8  SIGM0,EPSI0,DT,COEFM,RPM,PENTE

      COMMON /LCPIM/
     &          PM,YOUNG,NU,MU,UNK,TROISK,COTHER,
     &          SIGM0,EPSI0,DT,COEFM,RPM,PENTE,
     &          JPROL,JVALE,NBVAL
C ----------------------------------------------------------------------
C COMMON GRANDES DEFORMATIONS SIMO - MIEHE      
      
      INTEGER IND(3,3),IND1(6),IND2(6)
      REAL*8  KR(6),RAC2,RC(6),ID(6,6)
      REAL*8 BEM(6),BETR(6),DVBETR(6),EQBETR,TRBETR
      REAL*8 JP,DJ,JM,DFB(3,3)  
      REAL*8 DJDF(3,3),DBTRDF(6,3,3)
             
      COMMON /GDSMC/
     &            BEM,BETR,DVBETR,EQBETR,TRBETR,
     &            JP,DJ,JM,DFB,
     &            DJDF,DBTRDF,
     &            KR,ID,RAC2,RC,IND,IND1,IND2
C ----------------------------------------------------------------------
C ----------------------------------------------------------------------
      LOGICAL RESI,RIGI,ELAS
      INTEGER I,IJ,LINE
      REAL*8  TEMP,DP,SEUIL,R8BID      
      REAL*8  RP,PENTEP,AIRERP
      REAL*8  EM(6),EP(6),TRTAU,DVBE(6),JE

C ----------------------------------------------------------------------


C 1 - INITIALISATION
C-----------------------------------------------------------------------

C    DONNEES DE CONTROLE DE L'ALGORITHME
      RESI   = OPTION(1:4).EQ.'RAPH' .OR. OPTION(1:4).EQ.'FULL'
      RIGI   = OPTION(1:4).EQ.'RIGI' .OR. OPTION(1:4).EQ.'FULL'
      ELAS   = OPTION(11:14).EQ.'ELAS'
      CALL GDSMIN() 
            
C    LECTURE DES VARIABLES INTERNES (DEFORMATION PLASITQUE CUMULEE ET 
C                                   -DEFORMATION ELASTIQUE)
      PM=VIM(1)
      CALL DCOPY(6,VIM(2),1,EM,1)
      CALL DSCAL(3,RAC2,EM(4),1)
      
C    CALCUL DES ELEMENTS CINEMATIQUES
      CALL GDSMCI(FM,DF,EM)

C    CARACTERISTIQUES MATERIAU 
      IF (RESI) THEN
        TEMP = TP
      ELSE
        TEMP = TM
      END IF
      CALL LCPIMA(MATE,COMPOR,TEMP,TREF,INSTAM,INSTAP)
           
C 2 - RESOLUTION
C-----------------------------------------------------------------------
      IF (RESI) THEN
        SEUIL = MU*EQBETR - RPM

        IF (SEUIL .LE. 0.D0) THEN
          DP   = 0.D0
          LINE = 0

        ELSE
          LINE = 1
          IF (COMPOR.EQ.'VMIS_ISOT_LINE') THEN
            DP = SEUIL/(PENTE+MU*TRBETR)

          ELSE IF (COMPOR.EQ.'VMIS_ISOT_TRAC') THEN
            CALL RCFONC('E','TRACTION',JPROL,JVALE,NBVAL,R8BID,
     &             YOUNG*TRBETR/3,NU,PM,RP,PENTE,AIRERP,MU*EQBETR,DP)
          ELSE 
C CAS VISQUEUX : CALCUL DE DP PAR RESOLUTION DE          
C  FPLAS - (R'+MU TR BEL)DP - PHI(DP) = 0
            CALL CALCDP(CARCRI,SEUIL,DT,PENTE,MU*TRBETR,
     &                  SIGM0,EPSI0,COEFM,DP,IRET)
C DANS LE CAS NON LINEAIRE ON VERFIE QUE L ON A LA BONNE PENTE
            IF (COMPOR(10:14).EQ.'_TRAC')  THEN
              CALL RCFONC('V','TRACTION',JPROL,JVALE,NBVAL,R8BID,
     &           R8BID,R8BID,PM+DP,RP,PENTEP,R8BID,R8BID,R8BID)
              DO 10 I = 1,NBVAL
                IF (ABS(PENTE-PENTEP).LE.1.D-3) THEN
                  GOTO 20
                ELSE
                  PENTE=PENTEP
                  SEUIL = MU*EQBETR - (RP-PENTE*DP)
                  CALL CALCDP(CARCRI,SEUIL,DT,PENTE,MU*TRBETR,
     &                        SIGM0,EPSI0,COEFM,DP,IRET)
                  CALL RCFONC('V','TRACTION',JPROL,JVALE,
     &              NBVAL,R8BID,R8BID,R8BID,VIM(1)+DP,RP,PENTEP,
     &              R8BID,R8BID,R8BID)
                ENDIF
 10           CONTINUE 
 20           CONTINUE                
            ENDIF
          ENDIF            
        ENDIF 

C 4 - MISE A JOUR DES CHAMPS
C 4.1 - CONTRAINTE 
      
        CALL DCOPY(6,DVBETR,1,DVBE,1)
        IF (LINE.EQ.1) CALL DSCAL(6,1-DP*TRBETR/EQBETR,DVBE,1)
      
        TRTAU = (TROISK*(JP**2-1) - 3.D0*COTHER*(JP+1.D0/JP)) / 2.D0
        
        DO 30 IJ=1,6
          TAUP(IJ) = MU*DVBE(IJ) + TRTAU/3.D0*KR(IJ)
 30     CONTINUE
        
C 4.2 - CORRECTION HYDROSTATIQUE A POSTERIORI

        DO 40 IJ = 1,6
          EP(IJ)=(KR(IJ)-JP**(2.D0/3.D0)*(DVBE(IJ)+TRBETR/3.D0*KR(IJ)))
     &             /2.D0
 40     CONTINUE
        CALL GDSMHY(JP,EP)

C 4.3 - P, DEFORMATION ELASTIQUE ET INDICE DE PLASTICITE
        
        VIP(1) = PM+DP
        VIP(8) = LINE
        CALL DCOPY(6,EP,1,VIP(2),1)
        CALL DSCAL(3,1.D0/RAC2,VIP(5),1)
      END IF
           
C 5 - CALCUL DE LA MATRICE TANGENTE
      
      IF (RIGI) THEN
        IF (.NOT. RESI) THEN
          DP   = 0.D0
          LINE = NINT(VIM(8))
          CALL DCOPY(6,DVBETR,1,DVBE,1)
        END IF
        
        IF (ELAS) LINE = 0
        
        CALL GDSMTG()
        CALL LCPITG(COMPOR,DF,LINE,DP,DVBE,DTAUDF)
      ENDIF

      END
