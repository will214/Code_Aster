      SUBROUTINE NMCHOI(PHASE ,
     &                  PREMIE,SDDYNA,METPRE,METCOR,REASMA,
     &                  OPTRIG,LCRIGI,LCFINT)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 23/09/2008   AUTEUR ABBAS M.ABBAS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2007  EDF R&D                  WWW.CODE-ASTER.ORG
C THIS PROGRAM IS FREE SOFTWARE; YOU CAN REDISTRIBUTE IT AND/OR MODIFY  
C IT UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICENSE AS PUBLISHED BY  
C THE FREE SOFTWARE FOUNDATION; EITHER VERSION 2 OF THE LICENSE, OR     
C (AT YOUR OPTRIG) ANY LATER VERSION.                                   
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
      CHARACTER*16 METCOR,METPRE,OPTRIG
      LOGICAL      REASMA,LCRIGI,LCFINT,PREMIE
      CHARACTER*19 SDDYNA
      CHARACTER*10 PHASE
C 
C ----------------------------------------------------------------------
C
C ROUTINE MECA_NON_LINE (CALCUL)
C
C CALCUL DES MATR_ELEM DE RIGIDITE ET OPTION DE CALCUL POUR MERIMO
C      
C ----------------------------------------------------------------------
C
C
C IN  PHASE  : PHASE DE CALCUL
C                'PREDICTION'
C                'CORRECTION' 
C                'FORCES_INT' 
C IN  SDDYNA : SD DYNAMIQUE
C IN  METCOR : TYPE DE MATRICE DE CORRECTION
C IN  METPRE : TYPE DE MATRICE DE PREDICTION
C IN  REASMA : REASSEMBLAGE MATRICE GLOBALE
C IN  PREMIE : .TRUE. SI PREMIER INSTANT
C OUT OPTRIG : OPTION DE CALCUL DE MERIMO 
C OUT LCRIGI : .TRUE. SI MATR_ELEM DE RIGIDITE A CALCULER
C OUT LCFINT : .TRUE. SI VECT_ELEM DES FORCES INTERNES A CALCULER
C      
C ----------------------------------------------------------------------
C
      LOGICAL NDYNLO,LEXPL,LAMOR
C      
C ----------------------------------------------------------------------
C
  
C
C --- INITIALISATIONS
C
      OPTRIG = ' '
      LCFINT = .FALSE.
      LCRIGI = .FALSE.
C
C --- FONCTIONNALITES ACTIVEES
C
      LEXPL  = NDYNLO(SDDYNA,'EXPLICITE')  
      LAMOR  = NDYNLO(SDDYNA,'MAT_AMORT')   
C
C --- OPTION DE CALCUL DE MERIMO
C
      IF (PHASE.EQ.'CORRECTION') THEN
        IF (REASMA) THEN
          IF (METCOR.EQ.'TANGENTE') THEN
            OPTRIG = 'FULL_MECA'
          ELSE
            OPTRIG = 'FULL_MECA_ELAS'
          ENDIF
        ELSE
          OPTRIG = 'RAPH_MECA'
        END IF
      ELSE IF (PHASE.EQ.'PREDICTION') THEN
        IF (METPRE.EQ.'TANGENTE') THEN
          OPTRIG = 'RIGI_MECA_TANG'
        ELSE IF (METPRE.EQ.'SECANTE') THEN
          OPTRIG = 'RIGI_MECA_ELAS'
        ELSE
          OPTRIG = 'RIGI_MECA'
        END IF
      ELSE
        CALL ASSERT(.FALSE.)
      END IF
C
C --- MATR_ELEM DE RIGIDITE A CALCULER ?
C
      IF (LEXPL) THEN
        IF (LAMOR) THEN
          LCRIGI  = .TRUE.
        ELSE
          LCRIGI  = .FALSE.  
        ENDIF          
      ELSE
        IF (PHASE.EQ.'PREDICTION') THEN
          LCRIGI = REASMA    
        ENDIF    
      ENDIF
C
C --- VECT_ELEM DES FORCES INTERNES A CALCULER ?
C      
      IF (PHASE.EQ.'PREDICTION') THEN
        IF (OPTRIG(1:9).EQ.'FULL_MECA') THEN
          LCFINT  = .TRUE.   
        ELSE IF (OPTRIG(1:10).EQ.'RIGI_MECA ') THEN
          LCFINT  = .FALSE.                 
        ELSE IF (OPTRIG(1:10).EQ.'RIGI_MECA_') THEN
          LCFINT  = .FALSE.               
        ELSE IF (OPTRIG(1:9).EQ.'RAPH_MECA') THEN
          LCFINT  = .TRUE.               
        ELSE
          CALL ASSERT(.FALSE.)
        END IF
      ELSEIF (PHASE.EQ.'CORRECTION') THEN
        LCFINT = LCRIGI 
      ELSE
        CALL ASSERT(.FALSE.)
      ENDIF  


C
      END
