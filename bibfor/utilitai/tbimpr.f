      SUBROUTINE TBIMPR ( TABLE , FORMAZ, IFR   , NPARIM, LIPAIM,
     &                    NPARPG, LIPAPG, FORMAR, FORMAC )
C ----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF UTILITAI  DATE 24/07/2012   AUTEUR PELLET J.PELLET 
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
C      IMPRESSION DE LA TABLE "TABLE".
C ----------------------------------------------------------------------
C IN  : TABLE  : NOM D'UNE STRUCTURE "TABLE"
C IN  : FORMAZ : FORMAT D'IMPRESSION DE LA TABLE
C IN  : IFR    : UNITE LOGIQUE D'IMPRESSION
C IN  : NPARIM : NOMBRE DE PARAMETRES D'IMPRESSION
C IN  : LIPAIM : LISTE DES PARAMETRES D'IMPRESSION
C IN  : NPARPG : PLUS UTILISE (DOIT ETRE PASSE A ZERO)
C IN  : LIPAPG : PLUS UTILISE
C IN  : FORMAR : FORMAT D'IMPRESSION DES REELS
C IN  : FORMAC : FORMAT D'IMPRESSION DES COMPLEXES
C ----------------------------------------------------------------------
C
      IMPLICIT NONE
C
C 0.1. ==> ARGUMENTS
C
      INCLUDE 'jeveux.h'
      INTEGER       NPARIM, NPARPG, IFR
      CHARACTER*(*) TABLE
      CHARACTER*(*) FORMAZ, LIPAIM(*), LIPAPG(*)
      CHARACTER*(*) FORMAR, FORMAC
C
C 0.2. ==> COMMUNS
C
C 0.3. ==> VARIABLES LOCALES
C
C
      INTEGER      IRET, JTBNP, NBPARA, NBLIGN
      INTEGER      LTITR, LONMAX, ITITR
      CHARACTER*8  K8B, FORMAT
      CHARACTER*19 NOMTAB
C     ------------------------------------------------------------------
C
C====
C 1. PREALABLES
C====
C
      CALL JEMARQ()
C
      NOMTAB = TABLE
      FORMAT = FORMAZ
C
C====
C  2. DECODAGE DES ARGUMENTS
C====
C
      CALL EXISD ( 'TABLE', NOMTAB, IRET )
      IF ( IRET .EQ. 0 ) THEN
        CALL U2MESS('A','UTILITAI4_64')
        GOTO 9999
      ENDIF
C
      CALL JEVEUO ( NOMTAB//'.TBNP' , 'L', JTBNP )
      NBPARA = ZI(JTBNP  )
      NBLIGN = ZI(JTBNP+1)
      IF ( NBPARA .EQ. 0 ) THEN
         CALL U2MESS('A','UTILITAI4_65')
         GOTO 9999
      ENDIF
      IF ( NBLIGN .EQ. 0 ) THEN
         CALL U2MESS('A','UTILITAI4_76')
         GOTO 9999
      ENDIF
CSV
      WRITE(IFR,*) ' '
      IF ( FORMAT .EQ. 'ASTER') THEN
          WRITE(IFR,1000) '#DEBUT_TABLE'
      ENDIF
C
C     --- IMPRESSION DU TITRE ---
C
      CALL JEEXIN ( NOMTAB//'.TITR', IRET )
      IF ( IRET .NE. 0 ) THEN
         CALL JEVEUO ( NOMTAB//'.TITR', 'L', LTITR )
         CALL JELIRA ( NOMTAB//'.TITR', 'LONMAX', LONMAX, K8B )
         DO 10 ITITR = 1 , LONMAX
             IF ( FORMAT .EQ. 'ASTER') THEN
                 WRITE(IFR,2000) '#TITRE',ZK80(LTITR+ITITR-1)
             ELSE
                 WRITE(IFR,'(1X,A)') ZK80(LTITR+ITITR-1)
             ENDIF
 10      CONTINUE
      ENDIF
C
      IF ( NPARPG .EQ. 0 ) THEN
C
C        --- FORMAT "EXCEL" OU "AGRAF" ---
C
         IF ( FORMAT .EQ. 'EXCEL' .OR.
     &        FORMAT .EQ. 'AGRAF'.OR.
     &        FORMAT .EQ. 'ASTER' ) THEN
            CALL TBIMEX ( TABLE, IFR, NPARIM, LIPAIM, FORMAT,
     &                                                FORMAR)
C
C        --- FORMAT "TABLEAU" ---
C
         ELSEIF ( FORMAT .EQ. 'TABLEAU' ) THEN
            CALL TBIMTA ( TABLE, IFR, NPARIM, LIPAIM, FORMAR)
         ENDIF
      ELSE
C               --- TRAITEMENT DE LA "PAGINATION" ---
         CALL U2MESS('F','UTILITAI4_85')
C
      ENDIF
C
      IF ( FORMAT .EQ. 'ASTER' ) THEN
         WRITE(IFR,1000) '#FIN_TABLE'
      ENDIF
C
 9999 CONTINUE
 1000 FORMAT(A)
 2000 FORMAT(A,1X,A)

      CALL JEDEMA()
C
      END
