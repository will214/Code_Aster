      SUBROUTINE LRMMDI ( FID, NOMAMD,
     &                    TYPGEO, NOMTYP, NNOTYP,
     &                    NMATYP,
     &                    NBNOEU, NBMAIL, NBNOMA,
     &                    DESCFI, ADAPMA )
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
C    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================
C RESPONSABLE SELLENET N.SELLENET
C-----------------------------------------------------------------------
C     LECTURE DU MAILLAGE -  FORMAT MED - LES DIMENSIONS
C     -    -     -                  -         --
C-----------------------------------------------------------------------
C     LECTURE DU FICHIER MAILLAGE AU FORMAT MED
C               PHASE 0 : LA DESCRIPTION
C     ENTREES :
C       FID    : IDENTIFIANT DU FICHIER MED
C       NOMAMD : NOM MED DU MAILLAGE A LIRE
C       TYPGEO : TYPE MED POUR CHAQUE MAILLE
C       NOMTYP : NOM DES TYPES POUR CHAQUE MAILLE
C       NNOTYP : NOMBRE DE NOEUDS POUR CHAQUE TYPE DE MAILLES
C       DESCFI : DESCRIPTION DU FICHIER
C     SORTIES:
C       NMATYP : NOMBRE DE MAILLES PAR TYPE
C       NBNOEU : NOMBRE DE NOEUDS DU MAILLAGE
C       NBMAIL : NOMBRE DE MAILLES DU MAILLAGE
C       NBNOMA : NOMBRE CUMULE DE NOEUDS PAR MAILLE
C       ADAPMA : REPERAGE DU NUMERO D'ADAPTATION EVENTUEL
C-----------------------------------------------------------------------
C
      IMPLICIT NONE
C
C 0.1. ==> ARGUMENTS
C
      INTEGER FID
      INTEGER NBNOEU, NBMAIL, NBNOMA
      INTEGER TYPGEO(*), NMATYP(*), NNOTYP(*)
C
      CHARACTER*8 NOMTYP(*)
      CHARACTER*(*) NOMAMD
      CHARACTER*(*) ADAPMA
      CHARACTER*(*) DESCFI
C
C 0.2. ==> COMMUNS
C
C     ----- DEBUT COMMUNS NORMALISES  JEVEUX  --------------------------
      INTEGER            ZI
      COMMON  / IVARJE / ZI(1)
      REAL*8             ZR
      COMMON  / RVARJE / ZR(1)
      COMPLEX*16         ZC
      COMMON  / CVARJE / ZC(1)
      LOGICAL            ZL
      COMMON  / LVARJE / ZL(1)
      CHARACTER*8        ZK8
      CHARACTER*16                ZK16
      CHARACTER*24                          ZK24
      CHARACTER*32                                    ZK32
      CHARACTER*80                                              ZK80
      COMMON  / KVARJE / ZK8(1) , ZK16(1) , ZK24(1) , ZK32(1) , ZK80(1)
C     -----  FIN  COMMUNS NORMALISES  JEVEUX  --------------------------
C
C 0.3. ==> VARIABLES LOCALES
C
C
      INTEGER NTYMAX
      PARAMETER (NTYMAX = 56)
      INTEGER EDCOOR
      PARAMETER (EDCOOR=0)
      INTEGER EDNOEU
      PARAMETER (EDNOEU=3)
      INTEGER TYPNOE
      PARAMETER (TYPNOE=0)
      INTEGER EDCONN
      PARAMETER (EDCONN=1)
      INTEGER EDMAIL
      PARAMETER (EDMAIL=0)
      INTEGER EDNODA
      PARAMETER (EDNODA=0)
C
      INTEGER CODRET
      INTEGER IAUX, JAUX, ITYP
C
      CHARACTER*8 SAUX08
C
      INTEGER LXLGUT
C
C     ------------------------------------------------------------------
      CALL JEMARQ ( )
C
C====
C 1. DIVERS NOMBRES
C====
C
C 1.1. ==> NOMBRE DE NOEUDS
C
      CALL MFNEMA ( FID, NOMAMD, EDCOOR, EDNOEU, TYPNOE, IAUX,
     &              NBNOEU, CODRET)
      IF ( CODRET.NE.0 ) THEN
        CALL CODENT ( CODRET,'G',SAUX08 )
        CALL U2MESK('F','MED_12',1,SAUX08)
      ENDIF
      IF ( NBNOEU.EQ.0 ) THEN
        CALL U2MESS('F','MED_21')
      ENDIF
C
C 1.2. ==> NOMBRE DE MAILLES PAR TYPE ET LONGUEUR TOTALE DU TABLEAU
C          DE CONNECTIVITE NODALE
C
      NBMAIL = 0
      NBNOMA = 0
C
      DO 12 , ITYP = 1 , NTYMAX
C
        IF ( TYPGEO(ITYP) .NE. 0 ) THEN
C
          CALL MFNEMA ( FID, NOMAMD,
     &                  EDCONN, EDMAIL, TYPGEO(ITYP), EDNODA,
     &                  NMATYP(ITYP), CODRET )
          IF ( CODRET.NE.0 ) THEN
            CALL U2MESK('A','MED_23',1,NOMTYP(ITYP))
            CALL CODENT ( CODRET,'G',SAUX08 )
            CALL U2MESK('F','MED_12',1,SAUX08)
          ENDIF
C
          NBMAIL       = NBMAIL + NMATYP(ITYP)
          NBNOMA       = NBNOMA + NMATYP(ITYP) * NNOTYP(ITYP)
C
        ELSE
C
          NMATYP(ITYP) = 0
C
        ENDIF
C
   12 CONTINUE
C
      IF ( NBMAIL.EQ.0 ) THEN
        CALL U2MESS('F','MED_29')
      ENDIF
C
C====
C 2. NUMERO D'ITERATION POUR L'ADAPTATION DE MAILLAGE
C    IL VAUT ZERO SAUF SI LE FICHIER A ETE ECRIT PAR HOMARD. ON TROUVE
C    ALORS LE NUMERO DANS LA DESCRIPTION DU FICHIER SOUS LA FORME :
C    DESCFI = 'HOMARD VN.P   NITER '
C              123456789012345678901
C====
C
      IAUX = LXLGUT(DESCFI)
      IF ( IAUX.GE.20 ) THEN
        IF ( DESCFI(1:6).EQ.'HOMARD' ) THEN
          READ ( DESCFI(17:21) , FMT='(I5)' ) JAUX
        ELSE
          JAUX = 0
        ENDIF
      ELSE
        JAUX = 0
      ENDIF
C
      CALL WKVECT ( ADAPMA, 'G V I', 1, IAUX )
      ZI(IAUX) = JAUX
C
C====
C 3. LA FIN
C====
C
      CALL JEDEMA ( )
C
      END
