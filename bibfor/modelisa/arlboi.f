      SUBROUTINE ARLBOI(MAIL  ,NOMARL,TYPMAI,DIME  ,NOMA  ,
     &                  NOMB  ,NORM  )
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF MODELISA  DATE 08/04/2008   AUTEUR MEUNIER S.MEUNIER 
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
C RESPONSABLE MEUNIER S.MEUNIER
C
      IMPLICIT NONE
      CHARACTER*16 TYPMAI
      CHARACTER*8  MAIL,NOMARL
      CHARACTER*10 NOMA,NOMB,NORM
      INTEGER      DIME
C
C ----------------------------------------------------------------------
C
C ROUTINE ARLEQUIN
C
C MISE EN BOITES DES MAILLES DES MODELES
C
C ----------------------------------------------------------------------
C
C
C IN  MAIL   : NOM DU MAILLAGE
C IN  NOMARL : NOM DE LA SD PRINCIPALE ARLEQUIN
C IN  NOMA   : NOM DE LA SD POUR STOCKAGE MAILLES GROUP_MA_1
C IN  NOMB   : NOM DE LA SD POUR STOCKAGE MAILLES GROUP_MA_2
C IN  NORM   : NOM DE LA SD POUR STOCKAGE DES NORMALES
C IN  TYPMAI : SD CONTENANT NOM DES TYPES ELEMENTS (&&CATA.NOMTM)
C IN  DIME   : DIMENSION DE L'ESPACE GLOBAL
C
C SD PRODUITE: NOMX(1:10) (X VAUT A OU B)
C     NOMX(1:10)//'.BOITE'   : LISTE DES BOITES ENGLOBANTES
C
C
C ----------------------------------------------------------------------
C
      INTEGER      IFM,NIV
      CHARACTER*16 NOMBOA,NOMBOB
      CHARACTER*19 NGRMA,NGRMB
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
      CALL INFNIV(IFM,NIV)
C
C --- MISE EN BOITES DES MAILLES DES MODELES
C
      IF (NIV.GE.2) THEN
        WRITE(IFM,*) '<ARLEQUIN> GROUP_MA_1 - MISE EN BOITES...'
      ENDIF
C
      NOMBOA = NOMA(1:10)//'.BOITE'
      NGRMA  = NOMA(1:10)//'.GROUPEMA'
      CALL ARLBO0(MAIL  ,NOMARL,NGRMA ,NORM  ,DIME  ,
     &            TYPMAI,NOMBOA)
C
      IF (NIV.GE.2) THEN
        WRITE(IFM,*) '<ARLEQUIN> GROUP_MA_1 - BOITES...'
        CALL ARLIMP(IFM,'BOITE',NOMA)
      ENDIF
C
      IF (NIV.GE.2) THEN
        WRITE(IFM,*) '<ARLEQUIN> GROUP_MA_2 - MISE EN BOITES...'
      ENDIF
C
      NOMBOB = NOMB(1:10)//'.BOITE'
      NGRMB  = NOMB(1:10)//'.GROUPEMA'
      CALL ARLBO0(MAIL  ,NOMARL,NGRMB ,NORM  ,DIME  ,
     &            TYPMAI,NOMBOB)
C
      IF (NIV.GE.2) THEN
        WRITE(IFM,*) '<ARLEQUIN> GROUP_MA_2 - BOITES...'
        CALL ARLIMP(IFM,'BOITE',NOMB)
      ENDIF
C
      CALL JEDEMA()
      END
