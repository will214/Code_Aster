      SUBROUTINE IRCMEC ( IDFIMD,
     &                    NOCHMD, NOMPRF, NOLOPG,
     &                    NUMPT, INSTAN, NUMORD,
     &                    VAL,
     &                    NCMPVE, NBENTY, NBREPG, NVALEC,
     &                    TYPENT, TYPGEO,
     &                    CODRET )
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF PREPOST  DATE 10/05/2011   AUTEUR SELLENET N.SELLENET 
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
C_______________________________________________________________________
C     ECRITURE D'UN CHAMP -  FORMAT MED - ECRITURE
C        -  -       -               -     --
C_______________________________________________________________________
C     ENTREES :
C       IDFIMD : IDENTIFIANT DU FICHIER MED
C       NOMAM2 : NOM DU MAILLAGE MED
C       NOCHMD : NOM MED DU CHAMP A ECRIRE
C       NOMPRF : NOM MED DU PROFIL ASSOCIE AU CHAMP
C       NOLOPG : NOM MED LOCALISATION DES PTS DE GAUSS ASSOCIEE AU CHAMP
C       NUMPT  : NUMERO DE PAS DE TEMPS
C       INSTAN : VALEUR DE L'INSTANT A ARCHIVER
C       NUMORD : NUMERO D'ORDRE DU CHAMP
C       VAL    : VALEURS EN MODE ENTRELACE
C       NCMPVE : NOMBRE DE COMPOSANTES VALIDES EN ECRITURE
C       NBENTY : NOMBRE D'ENTITES DU TYPE CONSIDERE
C       NBREPG : NOMBRE DE POINTS DE GAUSS
C       NVALEC : NOMBRE DE VALEURS A ECRIRE EFFECTIVEMENT
C       TYPENT : TYPE D'ENTITE MED DU CHAMP A ECRIRE
C       TYPGEO : TYPE GEOMETRIQUE MED DU CHAMP A ECRIRE
C     SORTIES:
C       CODRET : CODE DE RETOUR (0 : PAS DE PB, NON NUL SI PB)
C_______________________________________________________________________
C
      IMPLICIT NONE
C
C 0.1. ==> ARGUMENTS
C
      CHARACTER*(*) NOCHMD, NOMPRF, NOLOPG
C
      INTEGER IDFIMD
      INTEGER NUMPT, NUMORD
      INTEGER NCMPVE, NBENTY, NBREPG, NVALEC
      INTEGER TYPENT, TYPGEO
C
      REAL*8 INSTAN
      REAL*8 VAL(*)
C
      INTEGER CODRET
C
C 0.2. ==> COMMUNS
C
C --------------- COMMUNS NORMALISES  JEVEUX  --------------------------
      REAL*8       ZR
      COMMON /RVARJE/ZR(1)
C     -----  FIN  COMMUNS NORMALISES  JEVEUX --------------------------
C
C 0.3. ==> VARIABLES LOCALES
C
C
      CHARACTER*6 NOMPRO
      PARAMETER ( NOMPRO = 'IRCMEC' )
C
      CHARACTER*32 EDNOPF
C                         12345678901234567890123456789012
      PARAMETER ( EDNOPF='                                ' )
      INTEGER EDFUIN
      PARAMETER (EDFUIN=0)
      INTEGER EDALL
      PARAMETER (EDALL=0)
      INTEGER EDNOPT
      PARAMETER (EDNOPT=-1)
      INTEGER EDNOPG
      PARAMETER (EDNOPG=1)
      INTEGER EDCOMP
      PARAMETER (EDCOMP=2)
      CHARACTER*32 EDNOGA
      PARAMETER ( EDNOGA='                                ' )
C
      INTEGER IFM, NIVINF
      INTEGER IAUX
C
      CHARACTER*8 SAUX08
      CHARACTER*14 SAUX14
      CHARACTER*35 SAUX35
C
C====
C 1. PREALABLES
C====
C
C 1.1. ==> RECUPERATION DU NIVEAU D'IMPRESSION
C
      CALL INFNIV ( IFM, NIVINF )
C
C 1.2. ==> INFORMATION
C
      IF ( NIVINF.GT.1 ) THEN
        WRITE (IFM,1001) 'DEBUT DE '//NOMPRO
 1001 FORMAT(/,4X,10('='),A,10('='),/)
        CALL U2MESS('I','MED_49')
        WRITE (IFM,13001) NBREPG, TYPENT, TYPGEO
        DO 13 , IAUX = 1 , NCMPVE
          WRITE (IFM,13002)
     &    '. PREMIERE ET DERNIERE VALEURS A ECRIRE POUR LA COMPOSANTE',
     &    IAUX, ' : ',VAL(IAUX),VAL((NVALEC*NBREPG-1)*NCMPVE+IAUX)
   13   CONTINUE
      ENDIF
13001 FORMAT(2X,'. NBREPG =',I4,', TYPENT =',I4,', TYPGEO =',I4)
13002 FORMAT(2X,A,I3,A3,5G16.6)
C
C====
C 2. ECRITURE DES VALEURS
C    LE TABLEAU DE VALEURS EST UTILISE AINSI :
C        TV(NCMPVE,NBSP,NBPG,NVALEC)
C    TV(1,1,1,1), TV(2,1,1,1), ..., TV(NCMPVE,1,1,1),
C    TV(1,2,1,1), TV(2,2,1,1), ..., TV(NCMPVE,2,1,1),
C            ...     ...     ...
C    TV(1,NBSP,NBPG,NVALEC), TV(2,NBSP,NBPG,NVALEC), ... ,
C                                      TV(NCMPVE,NBSP,NBPG,NVALEC)
C    C'EST CE QUE MED APPELLE LE MODE ENTRELACE
C    REMARQUE : LE 6-EME ARGUMENT DE MFCHRE EST LE NOMBRE DE VALEURS
C               C'EST LE PRODUIT DU NOMBRE TOTAL D'ENTITES DU TYPE EN
C               COURS PAR LE PRODUIT DES NOMBRES DE POINTS DE GAUSS
C               ET DE SOUS-POINT.
C               ATTENTION, CE N'EST DONC PAS LE NOMBRE DE VALEURS
C               REELLEMENT ECRITES MAIS PLUTOT LE NOMBRE MAXIMUM QU'ON
C               POURRAIT ECRIRE.
C====
C
C 2.1. ==> MESSAGES
C
CGN      PRINT *,'TABLEAU REELLEMENT ECRIT'
CGN      PRINT 1789,(VAL(IAUX),
CGN     >  IAUX=1,NVALEC*NBREPG*NCMPVE-1)
CGN 1789  FORMAT(10G12.5)
C
      IF ( NIVINF.GT.1 ) THEN 
C                  12345678901235
         SAUX14 = '. ECRITURE DES'
C                  12345678901234567890123456789012345
         SAUX35 = ' VALEURS POUR LE NUMERO D''ORDRE : '
C
         IF ( NBREPG.EQ.EDNOPG ) THEN
           WRITE (IFM,20001) SAUX14, NCMPVE, NVALEC, SAUX35, NUMORD
         ELSE
           WRITE (IFM,20002) SAUX14, NCMPVE, NBREPG, NVALEC, SAUX35, 
     &                       NUMORD
         ENDIF
         IF ( NUMPT.NE.EDNOPT ) THEN
           WRITE (IFM,20003) NUMPT, INSTAN
         ENDIF
         IF ( NOMPRF.EQ.EDNOPF ) THEN
             WRITE (IFM,20004)
         ELSE
           WRITE (IFM,20005) NOMPRF
         ENDIF
         IF ( NOLOPG.EQ.EDNOGA ) THEN
           WRITE (IFM,20006)
         ELSE
           WRITE (IFM,20007) NOLOPG
         ENDIF
      ENDIF
C
20001 FORMAT(2X,A14,I3,' * ',I8,A35,I5)
20002 FORMAT(2X,A14,2(I3,' * '),I8,A35,I5)
20003 FORMAT(5X,'( PAS DE TEMPS NUMERO :',I5,', T = ',G13.5,' )')
20004 FORMAT(2X,'. PAS DE PROFIL')
20005 FORMAT(2X,'. NOM DU PROFIL : ',A)
20006 FORMAT(2X,'. PAS DE LOCALISATION DE POINTS DE GAUSS')
20007 FORMAT(2X,'. NOM DE LA LOCALISATION DES POINTS DE GAUSS : ',A)
C
C 2.2. ==> NOMBRE DE VALEURS
C
      IAUX = NBENTY
C
C 2.3. ==> ECRITURE VRAIE
C
      CALL MFCHRE ( IDFIMD, NOCHMD, VAL,
     &              EDFUIN, IAUX,   NOLOPG, EDALL,
     &              NOMPRF, EDCOMP, TYPENT, TYPGEO,
     &              NUMPT, INSTAN, NUMORD, CODRET )
C
      IF ( CODRET.NE.0 ) THEN
        SAUX08='MFCHRE  '
        CALL U2MESG('F','DVP_97',1,SAUX08,1,CODRET,0,0.D0)
      ENDIF
C
      IF ( NIVINF.GT.1 ) THEN
        WRITE (IFM,1001) 'FIN DE '//NOMPRO
      ENDIF
C
      END
