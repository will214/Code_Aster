      SUBROUTINE OP0136()
      IMPLICIT   NONE
C     ------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF PREPOST  DATE 26/03/2012   AUTEUR TRAN V-X.TRAN 
C ======================================================================
C COPYRIGHT (C) 1991 - 2012  EDF R&D                  WWW.CODE-ASTER.ORG
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
C     ------------------------------------------------------------------
C     COMMANDE POST_FATIGUE
C     ------------------------------------------------------------------
      INTEGER       N1
      CHARACTER*8   TYPCHA
      INTEGER      IARG
C     ------------------------------------------------------------------
C
      CALL INFMAJ
      CALL GETVTX ( ' ', 'CHARGEMENT', 1,IARG,1, TYPCHA, N1 )
C
C     --- CHARGEMENT PUREMENT UNAXIAL ---
C
      IF ( TYPCHA .EQ. 'UNIAXIAL' ) THEN
         CALL POFAUN
C
C     --- CHARGEMENT MULTIAXIAL ---
C
      ELSEIF ( TYPCHA .EQ. 'MULTIAXI' ) THEN
         CALL POFAPE
C
C     --- CHARGEMENT QUELCONQUE (ENDOMMAGEMENT DE LEMAITRE) ---
C
      ELSEIF ( TYPCHA .EQ. 'QUELCONQ' ) THEN
         CALL POFAQU
      ENDIF
      CALL TITRE
C
      END
