      SUBROUTINE CBCHEI ( CHAR, NOMA, LIGRMO, NDIM, FONREE )
      IMPLICIT   NONE
      INTEGER           NDIM
      CHARACTER*4       FONREE
      CHARACTER*8       CHAR, NOMA
      CHARACTER*(*)     LIGRMO
C-----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF MODELISA  DATE 06/04/2004   AUTEUR DURAND C.DURAND 
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
C     ------------------------------------------------------------------
      INTEGER       NBFAC, NBET
      CHARACTER*5   PARA
      CHARACTER*8   TYPMCL(2)
      CHARACTER*16  MOTFAC, MOTCLS(2)
C     ------------------------------------------------------------------
C
      MOTFAC = 'EPSI_INIT'
      CALL GETFAC ( MOTFAC , NBFAC )
C
      MOTCLS(1) = 'GROUP_MA'
      MOTCLS(2) = 'MAILLE'
      TYPMCL(1) = 'GROUP_MA'
      TYPMCL(2) = 'MAILLE'  
C    
      IF ( NBFAC.NE.0 ) THEN
         CALL ALCAR0 ( NOMA, MOTFAC, 2, MOTCLS, TYPMCL, NBET )
         PARA = 'EPSIN'
         CALL CACHEI ( CHAR, LIGRMO, NBFAC, NBET, NOMA, FONREE,
     +                                                  PARA, MOTFAC )
      ENDIF
C
      END
