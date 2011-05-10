      SUBROUTINE LRMMF2 ( FID, NOMAMD, NBRFAM,
     &                    CARAFA, NBGRMX, NBATMX,
     &                    INFMED, NIVINF, IFM )
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF MODELISA  DATE 10/05/2011   AUTEUR SELLENET N.SELLENET 
C ======================================================================
C COPYRIGHT (C) 1991 - 2011  EDF R&D                  WWW.CODE-ASTER.ORG
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
C RESPONSABLE SELLENET N.SELLENET
C-----------------------------------------------------------------------
C     LECTURE DU MAILLAGE - FORMAT MED - LES FAMILLES - 2
C     -    -     -                 -         -          -
C-----------------------------------------------------------------------
C    POUR CHAQUE FAMILLE, ON RECUPERE :
C     . LE NOMBRE D'ATTRIBUTS
C     . LE NOMBRE DE GROUPES
C    ON MEMROISE LES MAXIMUM ATTEINTS EN PREVISION DES ALLOCATIONS
C
C ENTREES :
C   FID    : IDENTIFIANT DU FICHIER MED
C   NOMAMD : NOM DU MAILLAGE MED
C   NBRFAM : NOMBRE DE FAMILLES POUR CE MAILLAGE
C SORTIES :
C   CARAFA : CARACTERISTIQUES DE CHAQUE FAMILLE
C     CARAFA(1,I) = NOMBRE DE GROUPES
C     CARAFA(2,I) = NOMBRE D'ATTRIBUTS
C     CARAFA(3,I) = NOMBRE D'ENTITES
C   NBGRMX : NOMBRE MAXIMUM DE GROUPES POUR CHAQUE FAMILLE
C   NBATMX : NOMBRE MAXIMUM D'ATTRIBUTS POUR CHAQUE FAMILLE
C DIVERS
C   INFMED : NIVEAU DES INFORMATIONS SPECIFIQUES A MED A IMPRIMER
C   NIVINF : NIVEAU DES INFORMATIONS GENERALES
C   IFM    : UNITE LOGIQUE DU FICHIER DE MESSAGE
C-----------------------------------------------------------------------
C
      IMPLICIT NONE
C
C 0.1. ==> ARGUMENTS
C
      INTEGER FID
      INTEGER NBRFAM
      INTEGER CARAFA(3,NBRFAM)
      INTEGER NBGRMX, NBATMX
      INTEGER INFMED
      INTEGER IFM, NIVINF
C
      CHARACTER*(*) NOMAMD
C
C 0.2. ==> COMMUNS
C 0.3. ==> VARIABLES LOCALES
C
      CHARACTER*6 NOMPRO
      PARAMETER ( NOMPRO = 'LRMMF2' )
C
      INTEGER CODRET
      INTEGER IAUX
      INTEGER NBGR, NBAT
C
      CHARACTER*8 SAUX08
C
      IF ( NIVINF.GE.2 ) THEN
C
        WRITE (IFM,1001) NOMPRO
 1001 FORMAT( 60('-'),/,'DEBUT DU PROGRAMME ',A)
C
      ENDIF
C
C====
C 1. CARACTERISTIQUES DE CHACUNE DES NBRFAM FAMILLES
C====
C
      NBGRMX = 0
      NBATMX = 0
C
      DO 1 , IAUX = 1 , NBRFAM
C
C 1.1. ==> NOMBRE DE GROUPES
C
        CALL MFNGRO ( FID, NOMAMD, IAUX, NBGR, CODRET )
        IF ( CODRET.NE.0 ) THEN
          SAUX08='MFNGRO  '
          CALL U2MESG('F','DVP_97',1,SAUX08,1,CODRET,0,0.D0)
        ENDIF

        NBGRMX = MAX(NBGRMX,NBGR)
C
C 1.2. ==> NOMBRE D'ATTRIBUTS
C
        CALL MFNATT ( FID, NOMAMD, IAUX, NBAT, CODRET )
        IF ( CODRET.NE.0 ) THEN
          SAUX08='MFNATT  '
          CALL U2MESG('F','DVP_97',1,SAUX08,1,CODRET,0,0.D0)
        ENDIF

        NBATMX = MAX(NBATMX,NBAT)
C
C 1.3. ==> STOCKAGE
C
        CARAFA(1,IAUX) = NBGR
        CARAFA(2,IAUX) = NBAT
C
    1 CONTINUE
C
C====
C 2. LA FIN
C====
C
      IF ( INFMED.GE.3 ) THEN
C
        WRITE (IFM,2001)
        DO 21 , IAUX = 1 , NBRFAM
          WRITE (IFM,2002) IAUX, CARAFA(1,IAUX), CARAFA(2,IAUX)
   21 CONTINUE
        WRITE (IFM,2003)
C
      ENDIF
 2001 FORMAT(
     &  4X,40('*'),
     &/,4X,'*   RANG DE  *       NOMBRE DE         *',
     &/,4X,'* LA FAMILLE *  GROUPES   * ATTRIBUTS  *',
     &/,4X,40('*'))
 2002 FORMAT(4X,'*',I9,'   *',I9,'   *',I9,'   *')
 2003 FORMAT(4X,40('*'))
C
      IF ( NIVINF.GE.2 ) THEN
        WRITE (IFM,2222) NOMPRO
 2222 FORMAT(/,'FIN DU PROGRAMME ',A,/,60('-'))
      ENDIF
C
      END
