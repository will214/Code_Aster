        SUBROUTINE LCJPLA (LOI , MOD , IMAT , NMAT , MATER , NVI , TEMP,
     1                     DEPS , SIG , VIN   , DSDE, VIND,
     2                     THETA, DT, DEVG, DEVGII)
        IMPLICIT   NONE
C       ================================================================
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 06/04/2004   AUTEUR DURAND C.DURAND 
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
C       ----------------------------------------------------------------
C       MATRICE SYMETRIQUE DE COMPORTEMENT TANGENT ELASTO-PLASTIQUE
C       VISCO-PLASTIQUE EN VITESSE A T+DT OU T
C       IN  LOI    :  MODELE DE COMPORTEMENT
C           MOD    :  TYPE DE MODELISATION
C           IMAT   :  ADRESSE DU MATERIAU CODE
C           NMAT   :  DIMENSION MATER
C           MATER  :  COEFFICIENTS MATERIAU
C           NVI    :  NB VARIABLES INTERNES
C           TEMP   :  TEMPERATURE
C           DEPS   :  INCREMENT DE DEFORMATION
C           SIG    :  CONTRAINTE
C           VIN    :  VARIABLES INTERNES
C       OUT DSDE   :  MATRICE DE COMPORTEMENT TANGENT = DSIG/DEPS
C       ----------------------------------------------------------------
        INTEGER         IMAT, NMAT , NVI
        REAL*8          DSDE(6,6),DEVG(*),DEVGII,SIG(6),DEPS(6)
        REAL*8          VIN(*), VIND(*),TEMP,THETA,DT,MATER(NMAT,2)
        CHARACTER*8     MOD
        CHARACTER*16    LOI
C       ----------------------------------------------------------------
        IF     ( LOI(1:8) .EQ. 'ROUSS_PR' .OR. 
     1           LOI(1:10) .EQ. 'ROUSS_VISC' ) THEN           
          CALL  RSLJPL(LOI,IMAT,NMAT,MATER,TEMP,SIG,VIN,VIND,DEPS,
     1                 THETA,DT,DSDE)
C
        ELSEIF ( LOI(1:8) .EQ. 'CHABOCHE'    ) THEN
          CALL  CHBJPL(MOD,NMAT,MATER,SIG,VIN,DSDE)
C
        ELSEIF ( LOI(1:4) .EQ. 'OHNO'      ) THEN
          CALL  ONOJPL(MOD,NMAT,MATER,SIG,VIN,DSDE)
C
        ELSEIF ( LOI(1:7)  .EQ. 'NADAI_B'    ) THEN
          CALL  INSJPL(MOD,NMAT,MATER,SIG,VIN,DSDE)
C
        ELSEIF ( LOI(1:6) .EQ. 'LAIGLE'   ) THEN
          CALL  LGLJPL(MOD,NMAT,MATER,SIG,DEVG,DEVGII,VIN,DSDE)
C
        ENDIF
C
        END
