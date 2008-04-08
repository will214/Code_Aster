      SUBROUTINE CAARLE ( CHARGE )
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF MODELISA  DATE 08/04/2008   AUTEUR MEUNIER S.MEUNIER 
C TOLE CRP_20
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
C RESPONSABLE MEUNIER S.MEUNIER
C
      IMPLICIT NONE
      CHARACTER*8   CHARGE
C
C ----------------------------------------------------------------------
C
C              CREATION D'UN CHARGEMENT DE TYPE ARLEQUIN
C
C ----------------------------------------------------------------------
C
C IN  CHARGE  : SD CHARGE
C
C SD DE SORTIE:
C CHARGE.POIDS_MAILLE : VECTEUR DE PONDERATION DES MAILLES DU MAILLAGE
C                          (P1, P2, ...) AVEC P* POIDS DE LA MAILLE *
C
C SD D'ENTREE / SORTIE:
C CHARGE.CHME.LIGRE     : LIGREL DE CHARGE
C CHARGE.CHME.CIMPO     : CARTE COEFFICIENTS IMPOSES
C CHARGE.CHME.CMULT     : CARTE COEFFICIENTS MULTIPLICATEURS
C
C --------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ---------------------
C
      CHARACTER*32       JEXNUM
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
C
C --- FIN DECLARATIONS NORMALISEES JEVEUX ------------------------------
C
      CHARACTER*16 TYPMAI
      CHARACTER*10 NOMA,NOMB,NOMC,NOM1,NOM2,NORM,TANG,QUADRA
      CHARACTER*8  NOMO,MAIL,MODEL(3),CINE(3),NOMARL
      CHARACTER*8  K8BID
      INTEGER      DIME,NOCC
      INTEGER      NBTYP,NBMAC,NAPP
      INTEGER      IOCC,IBID,I
      INTEGER      JTYPM,JLGRF
      INTEGER      DIMVAR(2),DEGRE
      REAL*8       BC(2,3),LCARA
      REAL*8       POND1,POND2
      INTEGER      GRFIN,GRMED,GRCOL
      INTEGER      IFM,NIV
      CHARACTER*16 MOTCLE
C
      DATA MOTCLE /'ARLEQUIN'/
      DATA TYPMAI /'&&CAARLE.NOMTM'/
      DATA NOMARL /'&&ARL'/
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
      CALL INFNIV(IFM,NIV)
C
C --- INITIALISATIONS
C
      CALL GETFAC('ARLEQUIN',NOCC)
      IF (NOCC.EQ.0) GOTO 999
C
C --- LECTURE MAILLAGE
C
      CALL GETVID(' ','MODELE',0,1,1,NOMO,IBID)
      CALL JEVEUO(NOMO//'.MODELE    .LGRF','L',JLGRF)
      MAIL = ZK8(JLGRF)
C
C --- INITIALISATIONS
C
      NOMA   = CHARGE(1:8)//'.A'
      NOMB   = CHARGE(1:8)//'.B'
      NOMC   = CHARGE(1:8)//'.C'
      NOM1   = CHARGE(1:8)//'.1'
      NOM2   = CHARGE(1:8)//'.2'
      NORM   = CHARGE(1:8)//'.N'
      TANG   = CHARGE(1:8)//'.T'
      QUADRA = CHARGE(1:8)//'.Q'
C
C --- CREATION D'UN VECTEUR CONTENANT LE NOM DES TYPES DE MAILLES
C
      CALL JELIRA('&CATA.TM.NOMTM','NOMMAX',NBTYP,K8BID)
      CALL WKVECT(TYPMAI, 'V V K8',NBTYP, JTYPM)
      DO 10 I = 1,NBTYP
        CALL JENUNO(JEXNUM('&CATA.TM.NOMTM',I),ZK8(JTYPM-1+I))
 10   CONTINUE
C
C --- STOCKAGE DE QUELQUES PARAMETRES
C
      CALL ARLPAR(1,NOMARL,'V')
C
C --- CREATION DE LA SD PRINCIPALE ARLEQUIN
C
      CALL ARLCAR(NOMARL,'V')
C
C --- CREATION DU VECTEUR DE PONDERATION DES MAILLES
C
      CALL ARLCVP(NOMARL,CHARGE,MAIL  ,'G')
C
C --- MOT-CLEF FACTEUR ARLEQUIN
C
      DO 30 IOCC = 1, NOCC
C
C --- LECTURE ET VERIFICATION DES MAILLES DES MODELES
C
        CALL ARLLEC(MOTCLE,IOCC  ,NOMO  ,NOMA  ,NOMB  ,
     &              MODEL ,CINE  ,DIMVAR,DIME)
C
C --- CALCUL DES NORMALES DES COQUES (SI NECESSAIRE)
C
        CALL ARLNOR(MOTCLE,IOCC  ,CINE  ,NORM  ,TANG  ,
     &              TYPMAI,DIME  )
C
C --- MISE EN BOITE DES MAILLES DES DEUX ZONES
C
        CALL ARLBOI(MAIL  ,NOMARL,TYPMAI,DIME  ,NOMA  ,
     &              NOMB  ,NORM  )
C
C --- CALCUL DE LA BOITE DE SUPERPOSITION ET LONGUEUR CARACTERISTIQUE
C
        CALL ARLBBS(DIME  ,NOMA  ,NOMB  ,BC    ,LCARA)
C
C --- FILTRAGE DES MAILLES SITUEES DANS LA ZONE DE SUPERPOSITION
C
        CALL ARLFIL(NOMA  ,NOMB  ,BC    ,NOM1  ,NOM2)
C
C --- LECTURE ET VERIFICATION PONDERATION
C
        CALL ARLLPO(MOTCLE,IOCC  ,NOM1  ,NOM2  ,POND1 ,
     &              POND2 ,GRFIN)
C
C --- CHOIX DU MEDIATEUR
C
        CALL ARLMED(MOTCLE,IOCC  ,GRFIN ,GRMED)
C
C --- MAILLES DE LA ZONE DE COLLAGE
C
        CALL ARLLCC(MOTCLE,IOCC  ,NOMARL,NOMO  ,MAIL  ,
     &              DIME  ,TYPMAI,NOM1  ,NOM2  ,NORM  ,
     &              BC    ,NOMC  ,NBMAC ,GRMED ,GRCOL ,
     &              MODEL ,CINE)
C
C --- CALCUL DU DEGRE MAXIMAL DES GRAPHES NOEUDS -> MAILLES
C
        CALL ARLGDG(MAIL  ,NOM1  ,NOM2  ,DIMVAR,DEGRE)
C
C --- APPARIEMENT DES MAILLES ET FAMILLES D'INTEGRALES
C
        CALL ARLAPF(MAIL  ,DIME  ,TYPMAI,NOM1  ,NOM2  ,
     &              NOMARL,NORM  ,GRMED ,GRCOL ,CINE  ,
     &              DEGRE ,NBMAC ,NOMC  ,NAPP  ,QUADRA)
C
C --- ELIMINATION REDONDANCE CONDITIONS LIMITES / COUPLAGE ARLEQUIN
C
        CALL ARLCLR(MOTCLE,IOCC  ,MAIL  ,NOMARL,DIME  ,
     &              NOMC  ,TANG  )
C
C --- CALCUL DES EQUATIONS DE COUPLAGE
C
        CALL ARLCOU(MAIL  ,NOMO  ,NOMARL,TYPMAI,QUADRA,
     &              NOMC  ,NOM1  ,NOM2  ,CINE  ,NORM  ,
     &              TANG  ,GRMED ,LCARA ,DIME)
C
C --- PONDERATION DES MAILLES
C
        CALL ARLPON(MAIL  ,DIME  ,NOMARL,TYPMAI,NOMC  ,
     &              NOM1  ,NOM2  ,CINE  ,NORM  ,BC    ,
     &              GRCOL ,POND1 ,POND2 )
C
C --- DESALLOCATION GROUPES 1 ET 2
C
        CALL ARLDSD('GROUPEMA',NOM1)
        CALL ARLDSD('GRMAMA'  ,NOM1)
        CALL ARLDSD('BOITE'   ,NOM1)
        CALL ARLDSD('GROUPEMA',NOM2)
        CALL ARLDSD('GRMAMA'  ,NOM2)
        CALL ARLDSD('BOITE'   ,NOM2)
C
C --- ASSEMBLAGE EN CHARGE .CHME
C
        CALL ARLCHR(DIME  ,NOMARL,CINE  ,NOM1  ,NOM2  ,
     &              CHARGE)
C
C --- DESALLOCATION MATRICES MORSES
C
        CALL ARLDSD('MORSE'   ,NOM1)
        CALL ARLDSD('MORSE'   ,NOM2)
C
C --- DESALLOCATIONS GROUPE COLLAGE
C
        CALL ARLDSD('COLLAGE',NOMC)
C
 30   CONTINUE
C
C --- DESALLOCATION OBJETS ARLEQUIN
C
      CALL ARLDSD('ARLEQUIN',NOMARL)
C
C --- AUTRES OBJETS
C
      CALL JEDETR(TYPMAI)
      CALL JEDETR(NORM)
      CALL JEDETR(TANG)
C

 999  CONTINUE

      CALL JEDEMA()

      END
