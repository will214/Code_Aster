      SUBROUTINE GDCLEL(YOUNG,NU,ALPHA,TEMP,TREF)

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

      IMPLICIT NONE
      REAL*8 YOUNG,NU,ALPHA,TEMP,TREF

C ----------------------------------------------------------------------
C        INTEGRATION DES LOIS EN GRANDES DEFORMATIONS CANO-LORENTZ
C           AFFECTATION DES CARACTERISTIQUES THERMO-ELASTIQUES
C ----------------------------------------------------------------------
C  COMMON GRANDES DEFORMATIONS CANO-LORENTZ

      INTEGER IND1(6),IND2(6)
      REAL*8  KR(6),RAC2,RC(6)
      REAL*8  LAMBDA,MU,DEUXMU,UNK,TROISK,COTHER
      REAL*8  JM,DJ,JP,DJDF(3,3)
      REAL*8  ETR(6),DVETR(6),EQETR,TRETR,DETRDF(6,3,3)
      REAL*8  DTAUDE(6,6)

      COMMON /GDCLC/
     &          IND1,IND2,KR,RAC2,RC,
     &          LAMBDA,MU,DEUXMU,UNK,TROISK,COTHER,
     &          JM,DJ,JP,DJDF,
     &          ETR,DVETR,EQETR,TRETR,DETRDF,
     &          DTAUDE
C ----------------------------------------------------------------------
C ----------------------------------------------------------------------


      LAMBDA = YOUNG*NU/(1+NU)/(1-2*NU)
      DEUXMU = YOUNG/(1+NU)
      MU     = DEUXMU/2
      TROISK = YOUNG/(1-2*NU)
      UNK    = TROISK/3
      COTHER = TROISK*ALPHA*(TEMP-TREF)

      END
