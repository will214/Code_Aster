      SUBROUTINE IRCH19 ( CHAM19,FORM,FICH,TITRE,NOMO,
     >                    NOMSD,NOSIMP,NOPASE,NOMSYM,
     >                    NUMORD,NUORD1,NORDEN,IORDEN,NBCHAM,ICHAM,
     >                    LCHAM1,LCOR,NBNOT,NUMNOE,NBMAT,NUMMAI,NBCMP,
     >                    NOMCMP,LSUP,BORSUP,LINF,BORINF,LMAX,LMIN,
     >                    LRESU,FORMR,NIVE )
C     ------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF PREPOST  DATE 06/04/2004   AUTEUR DURAND C.DURAND 
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
C TOLE CRP_21
C ----------------------------------------------------------------------
C     IMPRIMER UN CHAMP (CHAM_NO OU CHAM_ELEM)
C
C IN  CHAM19: NOM DU CHAM_XX
C IN  FORM  : FORMAT :'RESULTAT','SUPERTAB', 'ENSIGHT'
C IN  FICH  : NOM DU FICHIER OU ON DOIT IMPRIMER LE CHAMP.
C IN  TITRE : TITRE.
C IN  NOMO  : NOM DU MODELE SUPPORT.
C IN  NOMSD : NOM DU RESULTAT D'OU PROVIENT LE CHAMP A IMPRIMER.
C IN  NOSIMP: NOM SIMPLE ASSOCIE AU CONCEPT NOMSD SI SENSIBILITE
C IN  NOPASE: NOM DU PARAMETRE SENSIBLE
C IN  NOMSYM: NOM SYMBOLIQUE DU CHAMP A IMPRIMER
C IN  NUMORD: NUMERO D'ORDRE DU CHAMP DANS LE RESULTAT_COMPOSE.
C             (1 SI LE RESULTAT EST UN CHAM_GD)
C IN  NUORD1: NUMERO DU PREMIER DES NUMEROS D'ORDRE A IMPRIMER
C             (POUR FORMAT 'ENSIGHT')
C IN  NORDEN: NOMBRE DE NUMEROS D'ORDRE A IMPRIMER
C             (POUR FORMAT 'ENSIGHT')
C IN  IORDEN: INDICE DE NUMORD DANS LA LISTE DES NUMEROS D'ORDRE
C             A IMPRIMER (POUR FORMAT 'ENSIGHT')
C IN  NBCHAM: NOMBRE DE CHAMPS A IMPRIMER (POUR FORMAT 'ENSIGHT')
C IN  ICHAM : INDICE DU CHAMP DANS LA LISTE DES CHAMPS A IMPRIMER
C             (POUR FORMAT 'ENSIGHT')
C IN  LCHAM1: INDIQUE SI LE CHAMP EST LE PREMIER DES CHAMPS A IMPRIMER
C             POUR LE NUMERO D'ORDRE NUMORD
C             (POUR FORMAT 'ENSIGHT')
C IN  LCOR  : IMPRESSION DES COORDONNEES DE NOEUDS .TRUE. IMPRESSION
C IN  NBNOT : NOMBRE DE NOEUDS A IMPRIMER
C IN  NUMNOE: NUMEROS DES NOEUDS A IMPRIMER
C IN  NBMAT : NOMBRE DE MAILLES A IMPRIMER
C IN  NUMMAI: NUMEROS DES MAILLES A IMPRIMER
C IN  NBCMP : NOMBRE DE COMPOSANTES A IMPRIMER
C IN  NOMCMP: NOMS DES COMPOSANTES A IMPRIMER
C IN  LSUP  : =.TRUE. INDIQUE PRESENCE D'UNE BORNE SUPERIEURE
C IN  BORSUP: VALEUR DE LA BORNE SUPERIEURE
C IN  LINF  : =.TRUE. INDIQUE PRESENCE D'UNE BORNE INFERIEURE
C IN  BORINF: VALEUR DE LA BORNE INFERIEURE
C IN  LMAX  : =.TRUE. INDIQUE IMPRESSION VALEUR MAXIMALE
C IN  LMIN  : =.TRUE. INDIQUE IMPRESSION VALEUR MINIMALE
C IN  LRESU : =.TRUE. INDIQUE IMPRESSION D'UN CONCEPT RESULTAT
C IN  FORMR : FORMAT D'ECRITURE DES REELS SUR "RESULTAT"
C IN  NIVE  : NIVEAU IMPRESSION CASTEM 3 OU 10
C ----------------------------------------------------------------------
C
      IMPLICIT NONE
C
C 0.1. ==> ARGUMENTS
C
C
      CHARACTER*(*)     CHAM19, NOMSD,NOSIMP,NOPASE, NOMSYM
      CHARACTER*(*)     FORM, FICH, NOMO, FORMR, TITRE, NOMCMP(*)
      REAL*8            BORSUP, BORINF
      INTEGER           NUMORD,NUORD1,NORDEN,IORDEN,NBCHAM,ICHAM,NBMAT
      INTEGER           NBNOT,NUMNOE(*),NUMMAI(*),NBCMP,NCMP
      INTEGER           NIVE
      LOGICAL           LCOR, LCHAM1, LSUP, LINF, LMAX, LMIN, LRESU
C
C 0.3. ==> VARIABLES LOCALES
C
      CHARACTER*6 NOMPRO
      PARAMETER ( NOMPRO = 'IRCH19' )
      INTEGER       IFIEN1
      PARAMETER   ( IFIEN1 = 31 )
C
      CHARACTER*8   TYCH, NOMGD
      CHARACTER*8   NOMSD8, NOSIM8, NOMPA8
      CHARACTER*16  NOSY16
      CHARACTER*19  CH19
      INTEGER       LGNOGD,LGCH16,IBID,IERD,IFI,IUNIFI,LXLGUT,
     +              NUMCMP(100)
C
C     PASSAGE DANS DES VARIABLES FIXES
C
      CH19 = CHAM19
      NOMSD8 = NOMSD
      NOSIM8 = NOSIMP
      NOMPA8 = NOPASE
      NOSY16 = NOMSYM
      LGCH16 = LXLGUT(NOSY16)
C
C     --- TYPE DU CHAMP A IMPRIMER (CHAM_NO OU CHAM_ELEM)
      CALL DISMOI('F','TYPE_CHAMP',CH19,'CHAMP',IBID,TYCH,IERD)
C
      IF ((TYCH(1:4).EQ.'NOEU') .OR. (TYCH(1:2).EQ.'EL')) THEN
      ELSEIF ( TYCH(1:4).EQ. 'CART' ) THEN
         GOTO 9999
      ELSE
         CALL UTMESS('A',NOMPRO,'ON NE SAIT PAS IMPRIMER'//
     >               ' LE CHAMP DE TYPE: '//TYCH//' CHAMP : '//CH19)
      ENDIF
C
C     --- NOM DE LA GRANDEUR ASSOCIEE AU CHAMP CH19
      CALL DISMOI('F','NOM_GD',CH19,'CHAMP',IBID,NOMGD,IERD)
C
       NCMP = 0
       IF ( NBCMP .NE. 0 ) THEN
         IF ( (NOMGD.EQ.'VARI_R') .AND. (TYCH(1:2).EQ.'EL') ) THEN
C --------- TRAITEMENT SUR LES "NOMCMP"
            NCMP = NBCMP
            CALL UTCMP3 ( NBCMP, NOMCMP, NUMCMP )
         ENDIF
       ENDIF
C
C     -- POUR LE FORMAT "ENSIGHT" ON VERIFIE LE CHAMP:
C     -------------------------------------------------
      IF((FORM(1:7).EQ.'ENSIGHT') .AND. (TYCH(1:2).EQ.'EL')) THEN
        LGNOGD=LXLGUT(NOMGD)
        CALL UTMESS('A',NOMPRO,' ON NE SAIT PAS IMPRIMER'//
     >       ' AU FORMAT ENSIGHT LE CHAMP '//NOSY16(1:LGCH16)//
     >       ' CORRESPONDANT A LA GRANDEUR :'//NOMGD(1:LGNOGD)//
     >        '. IL FAUT IMPRIMER DES CHAMPS AUX NOEUDS A CE FORMAT.')
        GO TO 9999
      ENDIF
C
C     -- ON LANCE L'IMPRESSION:
C     -------------------------
      IF(FORM(1:7).EQ.'ENSIGHT') THEN
        IFI=IFIEN1
      ELSE
        IFI=IUNIFI(FICH)
      ENDIF
C
C     -- EMBRANCHEMENT DE L'ECRITURE AU FORMAT MED
C     -- POUR LES AUTRES, PROCEDURE CLASSIQUE
C
      IF (FORM(1:3).EQ.'MED') THEN
         CALL IRCHME ( FICH, CH19,
     >                 LRESU, NOMSD8, NOSIM8, NOMPA8, NOSY16,
     >                 TYCH, NUMORD,
     >                 NBCMP, NOMCMP,
     >                 NBNOT, NUMNOE, NBMAT, NUMMAI,
     >                 IERD )
      ELSE IF (TYCH(1:4).EQ.'NOEU'.AND.NBNOT.GE.0) THEN
         CALL IRDEPL(CH19,IFI,FORM,TITRE,NOMSD,NOMSYM,
     >      NUMORD,NUORD1,NORDEN,IORDEN,NBCHAM,ICHAM,LCHAM1,LCOR,
     >      NBNOT,NUMNOE,NBCMP,NOMCMP,LSUP,BORSUP,LINF,BORINF,
     >      LMAX,LMIN,LRESU, FORMR ,NIVE )
      ELSE IF (TYCH(1:2).EQ.'EL'.AND.NBMAT.GE.0) THEN
         CALL IRCHML(CH19,IFI,FORM,TITRE,TYCH(1:4),NOMSD,NOMSYM,NUMORD,
     >      LCOR,NBNOT,NUMNOE,NBMAT,NUMMAI,NBCMP,NOMCMP,LSUP,BORSUP,
     >      LINF,BORINF,LMAX,LMIN,LRESU, FORMR, NCMP,NUMCMP,NIVE )
      ELSE IF (TYCH(1:4).NE.'NOEU'.AND.TYCH(1:2).NE.'EL') THEN
         CALL UTMESS('A',NOMPRO,'1 '//TYCH(1:4))
      ENDIF
C
 9999 CONTINUE
      IF (FORM.EQ.'ALI_BABA') THEN
        FICH='        '
      ENDIF
C
      IF ( IERD.NE.0 ) THEN
        CALL UTMESS ('A',NOMPRO,'ON NE SAIT PAS IMPRIMER'//
     >               ' LE CHAMP '//CH19//' AU FORMAT '//FORM(1:7))
      ENDIF
C
      END
