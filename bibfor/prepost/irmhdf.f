      SUBROUTINE IRMHDF ( FICH, NDIM,NBNOEU,COORDO,NBMAIL,CONNEX,
     >                    POINT,NOMAST,TYPMA,TITRE,NBTITR,
     >                    NBGRNO,NOMGNO,NBGRMA,NOMGMA,NOMMAI,NOMNOE,
     >                    INFMED )
C     ------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF PREPOST  DATE 08/03/2004   AUTEUR REZETTE C.REZETTE 
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
C     ECRITURE DU MAILLAGE - FORMAT MED
C        -  -     -                 ---
C-----------------------------------------------------------------------
C     ENTREE:
C       FICH   : NOM DU FICHIER OU ON DOIT IMPRIMER LE MAILLAGE
C       NDIM   : DIMENSION DU PROBLEME (2  OU 3)
C       NBNOEU : NOMBRE DE NOEUDS DU MAILLAGE
C       COORDO : VECTEUR DES COORDONNEES DES NOEUDS
C       NBMAIL : NOMBRE DE MAILLES DU MAILLAGE
C       CONNEX : CONNECTIVITES
C       POINT  : VECTEUR POINTEUR DES CONNECTIVITES (LONGUEURS CUMULEES)
C       NOMAST : NOM DU MAILLAGE
C       TYPMA  : VECTEUR TYPES DES MAILLES
C       TITRE  : TITRE ASSOCIE AU MAILLAGE
C       NBGRNO : NOMBRE DE GROUPES DE NOEUDS
C       NBGRMA : NOMBRE DE GROUPES DE MAILLES
C       NOMGNO : VECTEUR NOMS DES GROUPES DE NOEUDS
C       NOMGMA : VECTEUR NOMS DES GROUPES DE MAILLES
C       NOMMAI : VECTEUR NOMS DES MAILLES
C       NOMNOE : VECTEUR NOMS DES NOEUDS
C       INFMED : NIVEAU DES INFORMATIONS A IMPRIMER
C     ------------------------------------------------------------------
C
      IMPLICIT NONE
C
C 0.1. ==> ARGUMENTS
C
      INTEGER      CONNEX(*),TYPMA(*),POINT(*)
      INTEGER      NDIM,NBNOEU,NBMAIL,NBGRNO,NBGRMA
      INTEGER      INFMED,NBTITR
C
      CHARACTER*(*) FICH
      CHARACTER*80 TITRE(*)
      CHARACTER*8  NOMGNO(*),NOMGMA(*),NOMMAI(*),NOMNOE(*),NOMAST
C
      REAL*8       COORDO(*)
C
C 0.2. ==> COMMUNS
C
C 0.3. ==> VARIABLES LOCALES
C
      CHARACTER*6 NOMPRO
      PARAMETER ( NOMPRO = 'IRMHDF' )
C
      INTEGER NTYMAX
      PARAMETER (NTYMAX = 48)
      INTEGER EDECRI
      PARAMETER (EDECRI=1)
C
      INTEGER CODRET
      INTEGER NBTYP,  FID 
      INTEGER NITTYP(NTYMAX)
      INTEGER NMATYP(NTYMAX), NNOTYP(NTYMAX), TYPGEO(NTYMAX)
      INTEGER RENUMD(NTYMAX)
      INTEGER IAUX
      INTEGER LNOMAM
      INTEGER IFM, NIVINF
C
      CHARACTER*6   SAUX06
      CHARACTER*8   NOMTYP(NTYMAX)
      CHARACTER*8   SAUX08
      CHARACTER*32  NOMAMD
      CHARACTER*200 NOFIMD
C
      LOGICAL EXISTM
C
      INTEGER IUNIFI
C
C     ------------------------------------------------------------------
C
      CALL JEMARQ()
C
C====
C 1. PREALABLES
C====
C
C 1.1. ==> RECUPERATION DU NIVEAU D'IMPRESSION
C
      CALL INFNIV ( IFM, NIVINF )
C
C 1.2. ==> NOM DU FICHIER MED
C
      IAUX = IUNIFI (FICH)
      CALL CODENT ( IAUX, 'G', SAUX08 )
      NOFIMD = 'fort.'//SAUX08
      IF ( NIVINF.GT.1 ) THEN
        WRITE (IFM,*) NOMPRO, ' : NOM DU FICHIER MED : ', NOFIMD
      ENDIF
C
C 1.3. ==> NOM DU MAILLAGE
C
      CALL MDNOMA ( NOMAMD, LNOMAM, NOMAST, CODRET )
      IF ( CODRET.NE.0 ) THEN
        CALL CODENT ( CODRET,'G',SAUX08 )
        CALL UTMESS ( 'F', NOMPRO, 'MED:ERREUR MDNOMA NUMERO '//SAUX08 )
      ENDIF
C
C 1.4. ==> LE MAILLAGE EST-IL DEJA PRESENT DANS LE FICHIER ?
C          SI OUI, ON NE FAIT RIEN DE PLUS QU'EMETTRE UNE INFORMATION
C
      IAUX = 0
      CALL MDEXMA ( NOFIMD, NOMAMD, IAUX, EXISTM, IAUX, CODRET )
C
      IF ( EXISTM ) THEN
C
        CALL UTDEBM ( 'A', NOMPRO, 'FICHIER ' )
        CALL UTIMPK ( 'S', 'MED : ', 1, NOFIMD )
        CALL UTIMPK ( 'L', 'MAILLAGE : ', 1, NOMAMD )
        CALL UTFINM ()
        CALL UTMESS ( 'A', NOMPRO,
     >  'CE MAILLAGE EST DEJA PRESENT DANS LE FICHIER.')
C
C     ------------------------------------------------------------------
C
      ELSE
C
C====
C 2. DEMARRAGE
C====
C
C 2.1. ==> OUVERTURE FICHIER MED EN MODE 'ECRITURE'
C          CELA SIGNIFIE QUE LE FICHIER EST ENRICHI.
C          LE MODE 'REMPLACEMENT' EFFACERAIT TOUT LE CONTENU DU FICHIER.
C
      CALL EFOUVR (FID,NOFIMD,EDECRI,CODRET)
      IF ( CODRET.NE.0 ) THEN
        CALL UTDEBM ( 'A', NOMPRO, 'FICHIER ' )
        CALL UTIMPK ( 'S', 'MED : ', 1, NOFIMD )
        CALL UTIMPK ( 'L', 'MAILLAGE : ', 1, NOMAMD )
        CALL UTIMPI ( 'L', 'ERREUR EFOUVR NUMERO ', 1, CODRET )
        CALL UTFINM ()
        CALL UTMESS ( 'F', NOMPRO, 'PROBLEME A L OUVERTURE DU FICHIER' )
      ENDIF
C
C 2.2. ==> CREATION DU MAILLAGE AU SENS MED
C
      CALL EFMAAC ( FID, NOMAMD, NDIM, CODRET )          
      IF ( CODRET.NE.0 ) THEN
        CALL CODENT ( CODRET,'G',SAUX08 )
        CALL UTMESS ('F',NOMPRO,'MED: ERREUR EFMAAC NUMERO '//SAUX08)
      ENDIF
C
C 2.3. ==> . RECUPERATION DES NB/NOMS/NBNO/NBITEM DES TYPES DE MAILLES
C            DANS CATALOGUE
C          . RECUPERATION DES TYPES GEOMETRIE CORRESPONDANT POUR MED
C          . VERIF COHERENCE AVEC LE CATALOGUE
C
      CALL LRMTYP ( NDIM, NBTYP, NOMTYP,
     >              NNOTYP, NITTYP, TYPGEO, RENUMD )
C
C====
C 3. LA DESCRIPTION
C====
C
      CALL IRMDES ( FID,
     >              TITRE, NBTITR,
     >              INFMED )
C
C====
C 4. LES NOEUDS
C====
C
      CALL IRMMNO ( FID, NOMAMD, NDIM,
     >              NBNOEU , COORDO, NOMNOE,
     >              INFMED )
C
C====
C 5. LES MAILLES
C====
C
      SAUX06 = NOMPRO
C
      CALL IRMMMA ( FID, NOMAMD,
     >              NDIM, NBMAIL,
     >              CONNEX, POINT, TYPMA, NOMMAI,
     >              SAUX06,
     >              NBTYP, TYPGEO, NOMTYP, NNOTYP, NITTYP, RENUMD,
     >              NMATYP,
     >              INFMED )
C
C====
C 6. LES FAMILLES
C====
C
      SAUX06 = NOMPRO
C
      CALL IRMMFA ( FID, NOMAMD,
     >              NBNOEU, NBMAIL,
     >              NOMAST, NBGRNO, NOMGNO, NBGRMA, NOMGMA,
     >              SAUX06,
     >              TYPGEO, NOMTYP, NMATYP,
     >              INFMED )
C
C====
C 7. LES EQUIVALENCES
C====
C
      CALL IRMMEQ ( FID, NOMAMD,
     >              INFMED )
C
C====
C 8. FERMETURE DU FICHIER MED  
C====
C
      CALL EFFERM ( FID, CODRET )
      IF ( CODRET.NE.0 ) THEN
        CALL UTDEBM ( 'A', NOMPRO, 'FICHIER ' )
        CALL UTIMPK ( 'S', 'MED : ', 1, NOFIMD )
        CALL UTIMPK ( 'L', 'MAILLAGE : ', 1, NOMAMD )
        CALL UTIMPI ( 'L', 'ERREUR EFFERM NUMERO ', 1, CODRET )
        CALL UTFINM ()
        CALL UTMESS ( 'F', NOMPRO, 'PROBLEME A LA FERMETURE DU FICHIER')
      ENDIF
C
C====
C 9. LA FIN
C====
C
      CALL JEDETC('V','&&'//NOMPRO,1)
C
      ENDIF
C
C     ------------------------------------------------------------------
C
      CALL JEDEMA()
C
      END
