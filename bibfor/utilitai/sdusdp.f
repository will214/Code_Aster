      SUBROUTINE SDUSDP(SDUZ,SDPZ)
      IMPLICIT NONE
      CHARACTER*(*) SDPZ, SDUZ
      CHARACTER*16 SDP, SDU
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF UTILITAI  DATE 19/06/2006   AUTEUR VABHHTS J.PELLET 
C ======================================================================
C COPYRIGHT (C) 1991 - 2006  EDF R&D                  WWW.CODE-ASTER.ORG
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
C ----------------------------------------------------------------------
C    POUR TRANSFORMER UN TYPE DE SD "UTILISATEUR" (SDU)
C         EN UN TYPE DE SD "PROGRAMMEUR" (SDP)
C ----------------------------------------------------------------------
      SDU=SDUZ

      IF (SDU(1:14).EQ.'MATR_ASSE_GENE') THEN
         SDP='MATR_ASSE_GENE'

      ELSEIF (SDU(1:9).EQ.'MATR_ASSE') THEN
         SDP='MATR_ASSE'

      ELSEIF (SDU(1:13).EQ.'NUME_DDL_GENE') THEN
         SDP='NUME_DDL_GENE'

      ELSEIF (SDU(1:8).EQ.'NUME_DDL') THEN
         SDP='NUME_DDL'

      ELSEIF (SDU(1:11).EQ.'MODELE_GENE') THEN
         SDP='MODELE_GENE'

      ELSEIF (SDU(1:6).EQ.'MODELE') THEN
         SDP='MODELE'

      ELSEIF (SDU(1:7).EQ.'CHAM_NO') THEN
         SDP='CHAM_NO'

      ELSEIF (SDU(1:9).EQ.'CHAM_ELEM') THEN
         SDP='CHAM_ELEM'

      ELSEIF (SDU(1:4).EQ.'CART') THEN
         SDP='CARTE'

      ELSEIF (SDU(1:8).EQ.'MAILLAGE') THEN
         SDP='MAILLAGE'

      ELSEIF (SDU(1:14).EQ.'VECT_ASSE_GENE') THEN
         SDP='VECT_ASSE_GENE'

      ELSE
         SDP=SDU
      ENDIF
      SDPZ=SDP
      END
