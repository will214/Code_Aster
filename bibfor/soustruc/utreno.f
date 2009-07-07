      SUBROUTINE UTRENO ( MCF , MCS , IOCC , MA , NOEUD )
      IMPLICIT   NONE
      INTEGER             IOCC
      CHARACTER*8         MA , NOEUD
      CHARACTER*(*)       MCF , MCS
C ----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF SOUSTRUC  DATE 06/07/2009   AUTEUR COURTOIS M.COURTOIS 
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
C ----------------------------------------------------------------------
C     BUT: RECUPERER UN NOEUD "ORIGINE" OU "EXTREMITE"
C
C IN  : MCF    : MOT CLE FACTEUR
C IN  : MCS    : MOT CLE SIMPLE, ORIGINE OU EXTREMITE
C IN  : IOCC   : NUMERO D'OCCURENCE
C IN  : MA     : NOM DU MAILLAGE
C OUT : NOEUD  : NOM DU NOEUD RECUPERE
C     ------------------------------------------------------------------
      INTEGER       N1, IRET
      CHARACTER*8   K8B, NOGNO
      CHARACTER*16  MCNOEU, MCGRNO
      CHARACTER*24 VALK
C     ------------------------------------------------------------------
C
      NOEUD = '        '
      IF ( MCS(1:4) .EQ. 'ORIG' ) THEN
         MCNOEU = 'NOEUD_ORIG'
         MCGRNO = 'GROUP_NO_ORIG'
      ELSEIF ( MCS(1:4) .EQ. 'EXTR' ) THEN
         MCNOEU = 'NOEUD_EXTR'
         MCGRNO = 'GROUP_NO_EXTR'
      ENDIF
C
      CALL GETVTX ( MCF, MCNOEU, IOCC,1,0, K8B, N1 )
      IF ( N1 .NE. 0 ) THEN
         CALL GETVEM ( MA, 'NOEUD', MCF, MCNOEU, IOCC,1,1, NOEUD, N1 )
      ENDIF
C
      CALL GETVTX ( MCF, MCGRNO, IOCC,1,0, K8B, N1)
      IF ( N1 .NE. 0 ) THEN
         CALL GETVTX ( MCF,  MCGRNO, IOCC,1,1, NOGNO, N1 )
         CALL UTNONO ( ' ', MA, 'NOEUD', NOGNO, NOEUD, IRET )
         IF ( IRET .EQ. 10 ) THEN
            CALL U2MESK('F','ELEMENTS_67',1,NOGNO)
         ELSEIF ( IRET .EQ. 1 ) THEN
            VALK = NOEUD
            CALL U2MESG('A', 'SOUSTRUC_87',1,VALK,0,0,0,0.D0)
         ENDIF
      ENDIF
C
      END
