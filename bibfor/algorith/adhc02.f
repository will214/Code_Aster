      SUBROUTINE ADHC02 ( NBOPT, TABENT)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 08/03/2004   AUTEUR REZETTE C.REZETTE 
C RESPONSABLE GNICOLAS G.NICOLAS
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
C      ADAPTATION PAR HOMARD - DECODAGE DE LA COMMANDE - PHASE 02
C      --             -                       -                --
C      ECRITURE DU FICHIER DE DONNEES POUR L'INFORMATION
C     ------------------------------------------------------------------
C
      IMPLICIT NONE
C
C 0.1. ==> ARGUMENTS
C
      INTEGER NBOPT
      INTEGER TABENT(NBOPT)
C
C
C 0.2. ==> VARIABLES LOCALES
C
      CHARACTER*6 NOMPRO
      PARAMETER ( NOMPRO = 'ADHC02' )
C
      INTEGER IAUX, JAUX
      INTEGER CODRET
      INTEGER NUFIDO
      INTEGER MODHOM
C
      CHARACTER*100 LIGBLA, LIGNE
C
C     ------------------------------------------------------------------
C
      MODHOM = TABENT(2)
C
      IF ( MODHOM.EQ.2 ) THEN
C
C     ------------------------------------------------------------------
C====
C 1. RECUPERATION DES ARGUMENTS
C====
C
      CODRET = 0
C
C 1.1. ==> ENTIERS
C
      NUFIDO = TABENT(40)
C
C 1.2. ==> CARACTERES
C 1.3. ==> REELS
C
C====
C 2. ECRITURE DU FICHIER, LIGNE APRES LIGNE
C====
C
C 2.1. ==> LIGNE BLANCHE
C
      JAUX = LEN(LIGBLA)
      DO 21 , IAUX = 1 , JAUX
        LIGBLA(IAUX:IAUX) = ' '
  21  CONTINUE
C
C 2.2. ==> PAS GRAND-CHOSE POUR LE MOMENT
C
      LIGNE = LIGBLA
      LIGNE(1:1) = '0'
      WRITE (NUFIDO,30000) LIGNE
      WRITE (NUFIDO,30000) LIGNE
C
      LIGNE(1:1) = 'q'
      WRITE (NUFIDO,30000) LIGNE
C
30000 FORMAT (A100)
C
C====
C 3. ARRET SI PROBLEME
C====
C
      IF ( CODRET.NE.0 ) THEN
        CALL UTMESS
     > ('F',NOMPRO,'ERREURS CONSTATEES POUR IMPR_FICO_HOMA')
      ENDIF
C
C     ------------------------------------------------------------------
C
      ENDIF
C
C     ------------------------------------------------------------------
C
      END
