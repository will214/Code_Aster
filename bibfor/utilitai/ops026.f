      SUBROUTINE OPS026()
      IMPLICIT  NONE
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF UTILITAI  DATE 14/02/2012   AUTEUR COURTOIS M.COURTOIS 
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
C   1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================
C
C    OPERATEUR DEFI_FICHIER
C
C     ------------------------------------------------------------------
      INTEGER        UNITE, ULNUME, ULNOMF, IFM, NIV, N1, NF, NU
      LOGICAL        SORTIE
      CHARACTER*1    KACC, KTYP
      CHARACTER*8    ACTION, ACCES, TYPE
      CHARACTER*16   KNOM
      CHARACTER*255  FICHIE
      INTEGER      IARG
C     ------------------------------------------------------------------
C
      CALL INFMAJ ()
      CALL INFNIV ( IFM, NIV )
C
      SORTIE = .FALSE.
      UNITE  = 999
      KNOM   = ' '
      KACC   = ' '
      KTYP   = 'A'
      FICHIE = ' '
C
      CALL GETVTX ( ' ', 'ACTION',  1,IARG,1, ACTION, N1 )
      CALL GETVTX ( ' ', 'FICHIER', 1,IARG,1, FICHIE, NF )
      CALL GETVIS ( ' ', 'UNITE',   1,IARG,1, UNITE,  NU )
      CALL GETVTX ( ' ', 'ACCES',   1,IARG,1, ACCES,  N1 )
      IF ( N1 .NE. 0 ) KACC = ACCES(1:1)
      CALL GETVTX ( ' ', 'TYPE',    1,IARG,1, TYPE,   N1 )
      IF ( N1 .NE. 0 ) KTYP = TYPE(1:1)
C
      IF ( ACTION .EQ. 'LIBERER ' ) THEN
C          ---------------------
        IF ( NU .EQ. 0 ) THEN
C --------- L'ACCES AU FICHIER EST REALISE PAR NOM, IL FAUT VERIFIER
C           SA PRESENCE DANS LA STRUCTURE DE DONNEES
          UNITE = ULNOMF ( FICHIE, KACC, KTYP )
          IF (UNITE .LT. 0) THEN
            CALL U2MESK('A','UTILITAI3_33',1,FICHIE)
            GOTO 999
          ENDIF
        ENDIF
        UNITE = -UNITE
C
      ELSEIF ( (ACTION .EQ. 'ASSOCIER') .OR.
     &         (ACTION .EQ. 'RESERVER') ) THEN
C               ---------------------
        IF ( NU .EQ. 0 .AND. NF .GT. 0 ) THEN
          SORTIE = .TRUE.
          UNITE = ULNUME()
          IF (UNITE .LT. 0) THEN
            CALL U2MESS('F','UTILITAI3_34')
          ENDIF
        ENDIF
C
      ELSE
C
         CALL U2MESK('F','UTILITAI3_35',1,ACTION)
C
      ENDIF
C
      IF ( KTYP .EQ. 'A' ) THEN
        IF ( ACTION .EQ. 'RESERVER' ) THEN
           CALL ULOPEN ( UNITE, FICHIE, KNOM, KACC, 'R' )
        ELSE
           CALL ULOPEN ( UNITE, FICHIE, KNOM, KACC, 'O' )
        ENDIF
      ELSE IF ( KTYP .EQ. 'L' ) THEN
        CALL ULDEFI ( UNITE, FICHIE, KNOM, KTYP, KACC, 'O' )
      ELSE
        CALL ULDEFI ( UNITE, KNOM, KNOM, KTYP, KACC, 'O' )
      ENDIF
C
C---- POUR DETRUIRE LE FICHIER SI CE DERNIER EST OUVERT EN NEW
C
      IF ( KTYP .NE. 'A' ) THEN
        IF ( KACC .EQ. 'N' ) THEN
          CALL RMFILE (FICHIE,1)
        ENDIF
      ENDIF

      IF ( SORTIE )  CALL PUTVIR ( UNITE )
C
 999  CONTINUE
      IF (NIV.GT.1) CALL ULIMPR(IFM)

      END
