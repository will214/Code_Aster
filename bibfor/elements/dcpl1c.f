      SUBROUTINE DCPL1C(MOM,DEPS,PLAMOM,DC,DTG,ZEROG,DCP)
      IMPLICIT NONE
      COMMON /TDIM/ N, ND
      REAL*8 DCP(3),     MOM(3), DEPS(6),  PLAMOM(3), DC(3,3), DTG(6,6)
      REAL*8 LAMBDA,     DF(3),  TDF(1,3), A,         B,       TMP(3)
      REAL*8 S,          FPLAS,  R1
      REAL*8 MATMP(3,6), ZEROG
      INTEGER N,ND
C-----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 18/11/2003   AUTEUR LEBOUVIE F.LEBOUVIER 
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
C-----------------------------------------------------------------------
C     BUT    :  CALCULS DE LAMBDA ET DE L'INCREMENT DE LA COURBURE 
C               PLASTIQUE QUAND LE CRITERE DE PLASTICITE VAUT 1
C               PAR UNE METHODE EXPLICITE 
C
C IN    R  MOM    : MOMENT DE RAPPEL = M - BACKM
C       R  DC     : MATRICE ELASTIQUE + CONSTANTE DE PRAGER
C       R  DEPS   : INCREMENT DE DEFORMATION (MEMBRANE, COURBURE)
C       R  DTG    : MATRICE TANGENTE
C       R  PLAMOM : MOMENTS LIMITES ELASTIQUES LIMITES 
C        
C OUT   R  DCP    : INCREMENT DE COURBURE PLASTIQUE
C-----------------------------------------------------------------------
C
      N = 3
C
      CALL LCDIVE(MOM,PLAMOM,TMP)
C     NORME EUCLIDIENNE DE TMP : R1
      CALL LCNRVE(TMP,R1)
C
C     SI LE MOMENT EST TROP PRES DU SOMMET DU CONE
C     --------------------------------------------
      IF (R1.LT.50.D0*ZEROG)THEN
         CALL DC1CO2(MOM,DEPS,PLAMOM,DC,DTG,ZEROG,DCP)
         GOTO 9999
      ENDIF
C
C     CALCUL CONSIDERANT LE 1ER ORDRE F(M,M)
C     --------------------------------------
      CALL DFPLAS(MOM,PLAMOM,DF)
      CALL EXTMAT(DTG,6,3,6,'IG',MATMP)
      CALL PRMRVE(MATMP,3,6,DEPS,TMP)
C
      N=3
      CALL LCPRSC(TMP,DF,S)
      A=S
C
      CALL PMAVEC('ZERO',3,DC,DF,TMP)
      CALL LCPRSC(TMP,DF,S)
      B=S
      LAMBDA=(FPLAS(MOM,PLAMOM)+A)/B
C
      CALL LCPRSV(LAMBDA,DF,DCP)
C
9999  CONTINUE 
C
      END
