      SUBROUTINE CARACO(CHAR  ,NOMO  ,MOTFAC,NZOCO ,IFORM )
C      
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF MODELISA  DATE 14/09/2010   AUTEUR ABBAS M.ABBAS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2004  EDF R&D                  WWW.CODE-ASTER.ORG
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
C RESPONSABLE MABBAS M.ABBAS

      IMPLICIT NONE
      CHARACTER*8  CHAR,NOMO
      CHARACTER*16 MOTFAC
      INTEGER      NZOCO,IFORM
C      
C ----------------------------------------------------------------------
C
C ROUTINE CONTACT (TOUTES METHODES - LECTURE DONNEES)
C
C LECTURE DES PRINCIPALES CARACTERISTIQUES DU CONTACT (SURFACE IREAD)
C REMPLISSAGE DE LA SD 'DEFICO' (SURFACE IWRITE)
C      
C ----------------------------------------------------------------------
C
C
C IN  CHAR   : NOM UTILISATEUR DU CONCEPT DE CHARGE
C IN  NOMO   : NOM DU MODELE
C IN  MOTFAC : MOT-CLE FACTEUR (VALANT 'CONTACT')
C IN  NZOCO  : NOMBRE DE ZONES DE CONTACT
C IN  IFORM  : TYPE DE FORMULATION (DISCRETE/CONTINUE/XFEM)
C
C -------------- DEBUT DECLARATIONS NORMALISEES JEVEUX -----------------
C
      INTEGER ZI
      COMMON /IVARJE/ ZI(1)
      REAL*8 ZR
      COMMON /RVARJE/ ZR(1)
      COMPLEX*16 ZC
      COMMON /CVARJE/ ZC(1)
      LOGICAL ZL
      COMMON /LVARJE/ ZL(1)
      CHARACTER*8 ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
      COMMON /KVARJE/ ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C
C ---------------- FIN DECLARATIONS NORMALISEES JEVEUX -----------------
C
      INTEGER      IZONE 
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
C
C --- CREATION DES SD DEFINITION DU CONTACT
C
      CALL CARAMX(CHAR  ,IFORM ,NZOCO )
C
C --- AFFECTATION FORMULATION/METHODE DE CONTACT
C
      CALL CAZOFM(CHAR  ,MOTFAC,IFORM ,NZOCO )      
C
C --- LECTURE PARAMETRES GENERAUX
C     
      CALL CAZOCP(CHAR  )
C
C --- LECTURE DES DONNEES PAR ZONE
C
      DO 8 IZONE = 1,NZOCO      
        CALL CAZOCO(CHAR  ,NOMO  ,MOTFAC,IFORM ,IZONE ,NZOCO)
 8    CONTINUE
C      
C --- QUELQUES PARAMETRES GLOBAUX
C
      CALL CARALV(CHAR  ,NZOCO ,IFORM )    
C
      CALL JEDEMA()
C
      END
