      SUBROUTINE RAPOCO(NUMDLZ,IOCC,FONREZ,LISREZ,CHARGZ)
      IMPLICIT REAL*8 (A-H,O-Z)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF MODELISA  DATE 17/11/2003   AUTEUR VABHHTS J.PELLET 
C ======================================================================
C COPYRIGHT (C) 1991 - 2001  EDF R&D                  WWW.CODE-ASTER.ORG
C THIS PROGRAM IS FREE SOFTWARE; YOU CAN REDISTRIBUTE IT AND/OR MODIFY
C IT UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICENSE AS PUBLISHED BY
C THE FREE SOFTWARE FOUNDATION; EITHER VERSION 2 OF THE LICENSE, OR
C (AT YOUR OPTION) ANY LATER VERSION.

C THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT
C WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF
C MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. SEE THE GNU
C GENERAL PUBLIC LICENSE FOR MORE DETAILS.

C YOU SHOULD HAVE RECEIVED A COPY OF THE GNU GENERAL PUBLIC LICENSE
C ALONG WITH THIS PROGRAM; IF NOT, WRITE TO EDF R&D CODE_ASTER,
C    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================
C TOLE CRP_20

C    ATTENTION CETTE PROGRAMMATION SUPPOSE QUE L'OBJET NUEQ EST UN
C    VECTEUR IDENTITE. A MODIFIER

      CHARACTER*8 CHARGE
      CHARACTER*14 NUMDDL
      CHARACTER*19 LISREL
      CHARACTER*(*) NUMDLZ,CHARGZ,FONREZ,LISREZ
C -------------------------------------------------------
C     RACCORD POUTRE-COQUE PAR DES RELATIONS LINEAIRES
C     ENTRE LES NOEUDS DES MAILLES DE BORD MODELISANT
C     LA TRACE DE LA SECTION DE LA POUTRE SUR LA COQUE
C     ET LE NOEUD DE LA POUTRE DONNE PAR L'UTILISATEUR
C -------------------------------------------------------
C  NUMDLZ        - IN    - K14  - : NOM DU NUMEDDL DU LIGREL DU MODELE
C                                     (IL A ETE CREE SUR LA VOLATILE)
C  IOCC          - IN    - I    - : NUMERO D'OCCURENCE DU MOT-FACTEUR
C  FONREZ        - IN    - K4   - : 'REEL'
C  LISREZ        - IN    - K19  - : NOM DE LA SD LISTE_RELA
C  CHARGE        - IN    - K8   - : NOM DE LA SD CHARGE
C                - JXVAR -      -
C -------------------------------------------------------

C --------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ------
      CHARACTER*32 JEXNUM,JEXNOM
      INTEGER ZI
      COMMON /IVARJE/ZI(1)
      REAL*8 ZR
      COMMON /RVARJE/ZR(1)
      COMPLEX*16 ZC
      COMMON /CVARJE/ZC(1)
      LOGICAL ZL
      COMMON /LVARJE/ZL(1)
      CHARACTER*8 ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C --------- FIN  DECLARATIONS  NORMALISEES  JEVEUX ------

C --------- VARIABLES LOCALES ---------------------------
      PARAMETER (NMOCL=300)
      COMPLEX*16 CBID,BETAC,CCMP(3)
      CHARACTER*2 TYPLAG
      CHARACTER*4 TYPVAL,TYPCOE
      CHARACTER*8 BETAF
      CHARACTER*8 MOD,NOMG,K8BID,POSLAG,CARA
      CHARACTER*8 NOMA,NOMCMP(NMOCL),OPTION
      CHARACTER*8 NOEPOU,NOCMP(3),KCMP(3),CMP(6),NOGRNO
      CHARACTER*8 LPAIN(4),LPAOUT(2)
      CHARACTER*9 NOMTE
      CHARACTER*16 MOTFAC
      CHARACTER*19 LIGRMO
      CHARACTER*19 LIGREL
      CHARACTER*24 LCHIN(4),LCHOUT(2),NOLILI,LISMAI
      CHARACTER*24 LISNOE,NOEUMA,VALE1,GRNOMA,VALE2
      INTEGER NTYPEL(NMOCL),DG,ICMP(6),NIV,IFM
      REAL*8 IG(6),COORIG(3),AXEPOU(3)
      LOGICAL EXISDG
      CHARACTER*1 K1BID
C --------- FIN  DECLARATIONS  VARIABLES LOCALES --------

      CALL JEMARQ()
C --- RECUPERATION DES PARAMETRE D IMPRESSION
      CALL INFNIV(IFM,NIV)
C -------------------------------------------------------
      NUMDDL = NUMDLZ
      CHARGE = CHARGZ
      LISREL = LISREZ

      MOTFAC = 'LIAISON_ELEM'
      CALL GETVTX(MOTFAC,'OPTION',IOCC,1,1,OPTION,IOP)
      IF ((OPTION.NE.'COQ_POU') .AND. (OPTION.NE.'COQ_TUYA')) THEN
        CALL UTMESS('F','RAPOCO','OPTION '//OPTION//' INVALIDE')
      END IF

      CALL GETFAC(MOTFAC,NLIAI)
      IF (NLIAI.EQ.0) GO TO 130

C --- INITIALISATIONS :
C     ---------------

C --- TYPE DES VALEURS AU SECOND MEMBRE DES RELATIONS
      TYPVAL = FONREZ
C --- TYPE DES VALEURS DES COEFFICIENTS DES RELATIONS
      TYPCOE = 'REEL'
C --- VALEUR DU SECOND MEMBRE DES RELATIONS QUAND C'EST UNE FONCTION
      BETAF = '&FOZERO'
C --- VALEUR DU SECOND MEMBRE DES RELATIONS QUAND C'EST UN REEL
      BETA = 0.0D0
C --- VALEUR DU SECOND MEMBRE DES RELATIONS QUAND C'EST UN COMPLEXE
      BETAC = (0.0D0,0.0D0)
      EPS = 1.D-6
      UN = 1.0D0
      KCMP(1) = ' '
      KCMP(2) = ' '
      KCMP(3) = ' '
      CMP(1) = 'DX'
      CMP(2) = 'DY'
      CMP(3) = 'DZ'
      CMP(4) = 'DRX'
      CMP(5) = 'DRY'
      CMP(6) = 'DRZ'
      CCMP(1) = (0.0D0,0.0D0)
      CCMP(2) = (0.0D0,0.0D0)
      CCMP(3) = (0.0D0,0.0D0)
      DO 10 I = 1,6
        ICMP(I) = 0
   10 CONTINUE

      LIGREL = '&&RAPOCO'
      LISMAI = '&&RAPOCO.LISTE_MAILLES'
      LISNOE = '&&RAPOCO.LISTE_NOEUDS'

C --- ON REGARDE SI LES MULTIPLICATEURS DE LAGRANGE SONT A METTRE
C --- APRES LES NOEUDS PHYSIQUES LIES PAR LA RELATION DANS LA MATRICE
C --- ASSEMBLEE :
C --- SI OUI TYPLAG = '22'
C --- SI NON TYPLAG = '12' :
C     -------------------

      CALL GETVTX(MOTFAC,'NUME_LAGR',IOCC,1,0,K8BID,NARL)
      IF (NARL.NE.0) THEN
        CALL GETVTX(MOTFAC,'NUME_LAGR',IOCC,1,1,POSLAG,NRL)
        IF (POSLAG(1:5).EQ.'APRES') THEN
          TYPLAG = '22'
        ELSE
          TYPLAG = '12'
        END IF
      ELSE
        TYPLAG = '12'
      END IF

C --- MODELE ASSOCIE AU LIGREL DE CHARGE :
C     ----------------------------------
      CALL DISMOI('F','NOM_MODELE',CHARGE(1:8),'CHARGE',IBID,MOD,IER)

C ---  LIGREL DU MODELE :
C      ----------------
      LIGRMO = MOD(1:8)//'.MODELE'

C --- MAILLAGE ASSOCIE AU MODELE :
C     --------------------------
      CALL JEVEUO(LIGRMO//'.NOMA','L',JNOMA)
      NOMA = ZK8(JNOMA)

      NOEUMA = NOMA//'.NOMNOE'
      GRNOMA = NOMA//'.GROUPENO'

C --- RECUPERATION DU TABLEAU DES COORDONNEES :
C     ---------------------------------------
      CALL JEVEUO(NOMA//'.COORDO    .VALE','L',JCOOR)

C --- RECUPERATION DES NOMS DES DDLS :
C     ------------------------------
      NOMG = 'DEPL_R'
      NOMTE = 'D_DEPL_R_'

      CALL JEVEUO(JEXNOM('&CATA.GD.NOMCMP',NOMG),'L',INOM)
      CALL JELIRA(JEXNOM('&CATA.GD.NOMCMP',NOMG),'LONMAX',NBCMP,K1BID)
      NDDLA = NBCMP - 1
      IF (NDDLA.GT.NMOCL) THEN
        CALL UTDEBM('F','RAPOCO','NOMBRE DE CMPS SUPERIEUR AU MAX')
        CALL UTIMPI('L','NMAXCMP= ',1,NMOCL)
        CALL UTIMPI('L','NCMP   = ',1,NDDLA)
        CALL UTFINM()
      END IF
      DO 20 I = 1,NDDLA
        NOMCMP(I) = ZK8(INOM-1+I)
        CALL JENONU(JEXNOM('&CATA.TE.NOMTE',NOMTE//NOMCMP(I) (1:7)),
     &              NTYPEL(I))
   20 CONTINUE
      CALL DISMOI('F','NB_EC',NOMG,'GRANDEUR',NBEC,K8BID,IER)

C --- ACCES A L'OBJET .PRNM :
C     ----------------------
      IF (NBEC.GT.10) THEN
        CALL UTMESS('F','RAPOCO',
     &              'LE DESCRIPTEUR_GRANDEUR DES DEPLACEMENTS'//
     &              ' NE TIENT PAS SUR DIX ENTIERS CODES')
      ELSE
        CALL JEVEUO(LIGRMO//'.PRNM','L',JPRNM)
      END IF

C --- RECUPERATION DU .PRNO ASSOCIE AU MAILLAGE :
C     -----------------------------------------
      CALL JELIRA(NUMDDL//'.NUME.PRNO','NMAXOC',NLILI,K1BID)

      K = 0
      DO 30 I = 1,NLILI
        CALL JENUNO(JEXNUM(NUMDDL//'.NUME.LILI',I),NOLILI)
        IF (NOLILI(1:8).NE.'&MAILLA') GO TO 30
        K = I
   30 CONTINUE

      IF (K.EQ.0) THEN
        CALL UTMESS('F','RAPOCO',
     &              'ERREUR DANS LA RECUPERATION DU NUME.PRNO')
      END IF

      CALL JEVEUO(JEXNUM(NUMDDL//'.NUME.PRNO',K),'L',IAPRNO)

C --- ACQUISITION DE LA LISTE DES NOEUDS A LIER
C --- (CETTE LISTE EST NON REDONDANTE) :
C     -------------------------------
      CALL MALIN1(MOTFAC,CHARGE,IOCC,1,LISNOE,LONLIS)
      CALL JEVEUO(LISNOE,'L',ILISNO)

C --- CONSTITUTION DU LIGREL FORME DES MAILLES DE BORD MODELISANT
C --- LA TRACE DE LA SECTION DE LA POUTRE SUR LA COQUE :
C     ------------------------------------------------

C --- CREATION ET AFFECTATION DU VECTEUR DE K8 DE NOM LISMAI
C --- CONTENANT LES NOMS DES MAILLES FORMANT LE LIGREL A CREER :
C     --------------------------------------------------------
      CALL RECMAI(MOTFAC,IOCC,1,NOMA,LISMAI,LOLIMA)

C ---   CREATION ET AFFECTATION DU LIGREL :
C       ---------------------------------
      CALL EXLIM1(LISMAI,LOLIMA,MOD,'V',LIGREL)

C --- ACQUISITION DES MOTS-CLES NOEUD_2 OU GROUP_NO_2 :
C     -----------------------------------------------
      NBNO = 0
      NBGNO = 0

      CALL GETVEM(NOMA,'NOEUD',MOTFAC,'NOEUD_2',IOCC,1,0,K8BID,NBNO)

      IF (NBNO.EQ.0) THEN
        CALL GETVEM(NOMA,'GROUP_NO',MOTFAC,'GROUP_NO_2',IOCC,1,0,K8BID,
     &              NBGNO)
        IF (NBGNO.EQ.0) THEN
          CALL UTMESS('F','RAPOCO','IL FAUT INDIQUER LE MOT-CLE '//
     &                '''NOEUD_2'' OU ''GROUP_NO_2'''//
     &                ' APRES LE MOT-FACTEUR '//MOTFAC//
     &                ' POUR L''OPTION '//OPTION)
        END IF
      END IF

      IF (NBNO.NE.0) THEN
        NBNO = -NBNO
        IF (NBNO.NE.1) THEN
          CALL UTMESS('F','RAPOCO','IL NE FAUT DONNER QU''UN '//
     &                'SEUL NOEUD DE POUTRE A RACCORDER A LA '//
     &                'COQUE.')
        END IF
        CALL GETVEM(NOMA,'NOEUD',MOTFAC,'NOEUD_2',IOCC,1,NBNO,NOEPOU,
     &              NNO)
      END IF

      IF (NBGNO.NE.0) THEN
        NBGNO = -NBGNO
        IF (NBGNO.NE.1) THEN
          CALL UTMESS('F','RAPOCO','IL NE FAUT DONNER QU''UN '//
     &                'UN SEUL GROUP_NO A UN NOEUD A RACCORDER'//
     &                ' A LA COQUE.')
        END IF
        CALL GETVEM(NOMA,'GROUP_NO',MOTFAC,'GROUP_NO_2',IOCC,1,NBGNO,
     &              NOGRNO,NNO)
        CALL JELIRA(JEXNOM(GRNOMA,NOGRNO),'LONMAX',N1,K1BID)
        IF (N1.NE.1) THEN
          CALL UTMESS('F','RAPOCO','IL NE FAUT DONNER '//
     &                'Q"UN  SEUL NOEUD DANS LE GROUP_NO : '//NOGRNO)
        ELSE
          CALL JEVEUO(JEXNOM(GRNOMA,NOGRNO),'L',JGRO)
          IN = ZI(JGRO+1-1)
          CALL JENUNO(JEXNUM(NOEUMA,IN),NOEPOU)
        END IF
      END IF

C --- RECUPERATION DU VECTEUR ORIENTANT LA POUTRE ET DIRIGE
C --- DE LA PARTIE COQUE VERS LA PARTIE POUTRE :
C     ----------------------------------------
      CALL GETVR8(MOTFAC,'AXE_POUTRE',IOCC,1,3,AXEPOU,NAXE)
      IF (NAXE.EQ.0) THEN
        CALL UTMESS('F','RAPOCO','IL FAUT DONNER UN VECTEUR '//
     &              'ORIENTANT L''AXE DE LA POUTRE SOUS LE MOT-CLE '//
     &              '"AXE_POUTRE".')
      END IF

      XNORM = SQRT(AXEPOU(1)*AXEPOU(1)+AXEPOU(2)*AXEPOU(2)+
     &        AXEPOU(3)*AXEPOU(3))

      IF (XNORM.LE.R8PREM()) THEN
        CALL UTMESS('F','RAPOCO','IL FAUT DONNER UN VECTEUR '//
     &          'NON NUL ORIENTANT L''AXE DE LA POUTRE SOUS LE MOT-CLE '
     &              //'"AXE_POUTRE".')
      END IF

      AXEPOU(1) = AXEPOU(1)/XNORM
      AXEPOU(2) = AXEPOU(2)/XNORM
      AXEPOU(3) = AXEPOU(3)/XNORM

C --- NOTATION DANS LA CARTE DE NOM '&&RAPOCO.CAXE_POU' DES
C --- COORDONNEES DU VECTEUR UNITAIRE ORIENTANT LA POUTRE :
C     ---------------------------------------------------

      NOCMP(1) = 'X'
      NOCMP(2) = 'Y'
      NOCMP(3) = 'Z'

      CALL MECACT('V','&&RAPOCO.CAXE_POU','LIGREL',LIGREL,'GEOM_R',3,
     &            NOCMP,ICMP,AXEPOU,CCMP,KCMP)

C --- RECUPERATION DES CARACTERISTIQUES ELEMENTAIRES :
C     ----------------------------------------------
      CALL GETVID(MOTFAC,'CARA_ELEM',IOCC,1,1,CARA,NCARA)
      IF (NCARA.EQ.0) THEN
        CALL UTMESS('F','RAPOCO','IL FAUT DONNER UN CARA_ELEM '//
     &              'POUR RECUPERER L''EPAISSEUR DES ELEMENTS DE BORD.')
      END IF

C ---  NUMERO DU NOEUD POUTRE A LIER :
C      -----------------------------
      CALL JENONU(JEXNOM(NOEUMA,NOEPOU),NUMNOP)

C ---  COORDONNEES DU NOEUD POUTRE :
C      ---------------------------
      XPOU = ZR(JCOOR-1+3* (NUMNOP-1)+1)
      YPOU = ZR(JCOOR-1+3* (NUMNOP-1)+2)
      ZPOU = ZR(JCOOR-1+3* (NUMNOP-1)+3)

C --- VERIFICATION DU FAIT QUE LES NOEUDS DE LISNOE (DONC
C --- APPARTENANT A LA COQUE)  PORTENT LES DDLS DE ROTATION :
C     -----------------------------------------------------
      DO 50 I = 1,LONLIS
C ---     NUMERO DU NOEUD COURANT DE LA LISTE
        CALL JENONU(JEXNOM(NOMA//'.NOMNOE',ZK8(ILISNO+I-1)),INO)

        DG = ZI(JPRNM-1+ (INO-1)*NBEC+1)
        DO 40 J = 4,6
          ICMP(J) = INDIK8(NOMCMP,CMP(J),1,NDDLA)
          IF (.NOT.EXISDG(DG,ICMP(J))) THEN
            CALL UTMESS('F','RAPOCO','IMPOSSIBILITE,LE NOEUD '//
     &                  ZK8(ILISNO+I-1)//'NE PORTE PAS LE DDL DE '//
     &                  'ROTATION '//CMP(J))
          END IF
   40   CONTINUE
   50 CONTINUE

C --- VERIFICATION DU FAIT QUE LE NOEUD POUTRE A RACCORDER PORTE
C --- LES 3 DDLS DE TRANSLATION ET LES 3 DDLS DE ROTATION :
C     ---------------------------------------------------
      DG = ZI(JPRNM-1+ (NUMNOP-1)*NBEC+1)
      DO 60 J = 1,6
        ICMP(J) = INDIK8(NOMCMP,CMP(J),1,NDDLA)
        IF (.NOT.EXISDG(DG,ICMP(J))) THEN
          CALL UTMESS('F','RAPOCO','IMPOSSIBILITE,LE NOEUD POUTRE '//
     &                NOEPOU//' DEVRAIT PORTER LE DDL '//CMP(J))
        END IF
   60 CONTINUE

C --- CALCUL SUR CHAQUE ELEMENT DE BORD A RELIER A LA POUTRE
C --- DES CARACTERISTIQUES GEOMETRIQUES SUIVANTES :
C ---  SOMME/S_ELEMENT(1,X,Y,Z,X*X,Y*Y,Z*Z,X*Y,X*Z,Y*Z)DS
C     ---------------------------------------------------
      LPAIN(1) = 'PGEOMER'
      LCHIN(1) = NOMA//'.COORDO'
      LPAIN(2) = 'PCACOQU'
      LCHIN(2) = CARA//'.CARCOQUE'
      LPAIN(3) = 'PCAORIE'
      LCHIN(3) = '&&RAPOCO.CAXE_POU'
      LPAOUT(1) = 'PCASECT'
      LCHOUT(1) = '&&RAPOCO.PSECT'

      CALL CALCUL('S','CARA_SECT_POUT3',LIGREL,3,LCHIN,LPAIN,1,LCHOUT,
     &            LPAOUT,'V')

C --- VECTEUR DES QUANTITES GEOMETRIQUES PRECITEES SOMMEES
C --- SUR LA SURFACE DE RACCORD, CES QUANTITES SERONT NOTEES :
C ---  A1 = S,AX,AY,AZ,AXX,AYY,AZZ,AXY,AXZ,AYZ
C     ----------------------------------------
      CALL WKVECT('&&RAPOCO.INERTIE_RACCORD','V V R',10,IDINER)

C --- SOMMATION DES QUANTITES GEOMETRIQUES ELEMENTAIRES
C --- DANS LE VECTEUR &&RAPOCO.INERTIE_RACCORD :
C     ----------------------------------------
      CALL MESOMM(LCHOUT(1),10,IBID,ZR(IDINER),CBID,0,IBID)

      S = ZR(IDINER+1-1)
      AX = ZR(IDINER+2-1)
      AY = ZR(IDINER+3-1)
      AZ = ZR(IDINER+4-1)
      AXX = ZR(IDINER+5-1)
      AYY = ZR(IDINER+6-1)
      AZZ = ZR(IDINER+7-1)
      AXY = ZR(IDINER+8-1)
      AXZ = ZR(IDINER+9-1)
      AYZ = ZR(IDINER+10-1)

      IF (ABS(S).LT.R8PREM()) THEN
        CALL UTMESS('F','RAPOCO','IMPOSSIBILITE, LA SURFACE '//
     &              'DE RACCORD DE LA COQUE EST NULLE ')
      END IF
      S1 = 1.0D0/S

C --- COORDONNEES DU CENTRE GEOMETRIQUE G DE LA SECTION DE RACCORD
C --- XG = AX/S, YG = AY/S, ZG = AZ/S :
C     -------------------------------
      XG = S1*AX
      YG = S1*AY
      ZG = S1*AZ

C --- VERIFICATION DE L'IDENTITE GEOMETRIQUE DE G AVEC LE
C --- NOEUD POUTRE A RACCORDER :
C     ------------------------

      D = SQRT((XPOU-XG)* (XPOU-XG)+ (YPOU-YG)* (YPOU-YG)+
     &    (ZPOU-ZG)* (ZPOU-ZG))
      IF (D.GT.EPS) THEN
        WRITE (IFM,*) 'ATTENTION, IL N''YA PAS IDENTITE '//
     &    'GEOMETRIQUE ENTRE LE CENTRE GEOMETRIQUE DE LA TRACE DE'
        WRITE (IFM,*) 'LA SECTION DE LA POUTRE SUR LA COQUE ET LE'//
     &    'NOEUD POUTRE A RACCORDER'
      END IF

C --- CALCUL DU TENSEUR D'INERTIE EN G, CE TENSEUR EST SYMETRIQUE :
C --- ON CALCULE LES COMPOSANTES DE LA PARTIE SUPERIEURE PAR LIGNE
C     ------------------------------------------------------------

C ---    IGXX = AYY + AZZ -S*(YG*YG+ZG*ZG)
      IG(1) = AYY + AZZ - S* (YG*YG+ZG*ZG)
C ---    IGXY = -AXY + S*XG*YG
      IG(2) = -AXY + S*XG*YG
C ---    IGXZ = -AXZ + S*XG*ZG
      IG(3) = -AXZ + S*XG*ZG
C ---    IGYY = AZZ + AXX -S*(ZG*ZG+XG*XG)
      IG(4) = AZZ + AXX - S* (ZG*ZG+XG*XG)
C ---    IGYZ = -AYZ + S*YG*ZG
      IG(5) = -AYZ + S*YG*ZG
C ---    IGZZ = AXX + AYY -S*(XG*XG+YG*YG)
      IG(6) = AXX + AYY - S* (XG*XG+YG*YG)

C --- NOTATION DANS LA CARTE DE NOM '&&RAPOCO.CAORIGE' DES
C --- COORDONNEES DU CENTRE GEOMETRIQUE G DE LA SECTION DE RACCORD
C     ------------------------------------------------------------

      NOCMP(1) = 'X'
      NOCMP(2) = 'Y'
      NOCMP(3) = 'Z'

      COORIG(1) = XG
      COORIG(2) = YG
      COORIG(3) = ZG

      CALL MECACT('V','&&RAPOCO.CAORIGE','LIGREL',LIGREL,'GEOM_R',3,
     &            NOCMP,ICMP,COORIG,CCMP,KCMP)

C --- DETERMINATION DE 2 LISTES  DE VECTEURS PAR ELEMENT PRENANT
C --- LEURS VALEURS AUX NOEUDS DES ELEMENTS.
C --- LA PREMIERE LISTE DE NOM 'VECT_EINI' A POUR VALEURS AU NOEUD
C --- I D'UN ELEMENT :
C ---  SOMME/S_ELEMENT(E1(1)*NI,E1(2)*NI,E1(3)*NI,
C ---                  E2(1)*NI,E2(2)*NI,E2(3)*NI)DS
C --- OU E1 EST UN VECTEUR UNITAIRE PERPENDICULAIRE A L'ELEMENT
C --- DE BORD ORIENTE DE LA COQUE VERS LA POUTRE ET
C --- E2 EST LE VECTEUR TANGENT A LA FIBRE MOYENNE DE L'ELEMENT DE BORD
C --- LA SECONDE LISTE DE NOM 'VECT_XYZNI' A POUR VALEURS AU NOEUD
C --- I D'UN ELEMENT :
C ---  SOMME/S_ELEMENT(X*NI,Y*NI,Z*NI,NI,0,0)DS
C ---  AVEC X = XM - XG = NJ*XJ - XG
C ---       Y = YM - YG = NJ*YJ - YG
C ---       Z = ZM - ZG = NJ*ZJ - ZG
C     ------------------------------
      LPAIN(1) = 'PGEOMER'
      LCHIN(1) = NOMA//'.COORDO'
      LPAIN(2) = 'PORIGIN'
      LCHIN(2) = '&&RAPOCO.CAORIGE'
      LPAIN(3) = 'PCACOQU'
      LCHIN(3) = CARA//'.CARCOQUE'
      LPAIN(4) = 'PCAORIE'
      LCHIN(4) = '&&RAPOCO.CAXE_POU'
      LPAOUT(1) = 'PVECTU1'
      LPAOUT(2) = 'PVECTU2'
      LCHOUT(1) = '&&RAPOCO.VECT_XYZNI'
      LCHOUT(2) = '&&RAPOCO.VECT2'

      CALL CALCUL('S','CARA_SECT_POUT4',LIGREL,4,LCHIN,LPAIN,2,LCHOUT,
     &            LPAOUT,'V')

C --- CREATION DES .REFE_RESU DES VECTEURS EN SORTIE DE CALCUL
C     --------------------------------------------------------

      CALL WKVECT('&&RAPOCO.REFE_RESU','V V K24',5,IAREFE)
      ZK24(IAREFE+1-1) = MOD
      ZK24(IAREFE+2-1) = 'CHAR_MECA'
      ZK24(IAREFE+3-1) = 'NON_SOUS_STRUC'
      ZK24(IAREFE+4-1) = ' '
      ZK24(IAREFE+5-1) = ' '

C --- CREATION DU .LISTE_RESU
C     -----------------------
      CALL WKVECT('&&RAPOCO.LISTE_RESU','V V K24',1,ILIRES)

C --- ASSEMBLAGE DE LCHOUT(1) DANS LE CHAMNO DE NOM 'CH_DEPL_1'
C     ---------------------------------------------------------

      ZK24(ILIRES+1-1) = LCHOUT(1)

      CALL ASSVEC('V','&&RAPOCO.CH_DEPL_01',1,'&&RAPOCO.LISTE_RESU',UN,
     &            NUMDDL,' ','ZERO',1)

      VALE1 = '&&RAPOCO.CH_DEPL_01.VALE'
      CALL JEVEUO(VALE1,'L',IDCH1)


C --- ASSEMBLAGE DE LCHOUT(2) DANS LE CHAMNO DE NOM 'CH_DEPL_1'
C     ---------------------------------------------------------

      ZK24(ILIRES+1-1) = LCHOUT(2)

      CALL ASSVEC('V','&&RAPOCO.CH_DEPL_02',1,'&&RAPOCO.LISTE_RESU',UN,
     &            NUMDDL,' ','ZERO',1)

      VALE2 = '&&RAPOCO.CH_DEPL_02.VALE'
      CALL JEVEUO(VALE2,'L',IDCH2)

C --- CREATION DES TABLEAUX DE TRAVAIL NECESSAIRES A L'AFFECTATION
C --- DE LISREL
C     ------------------------------------------------------------

C ---     MAJORANT DU NOMBRE DE TERMES DANS UNE RELATION
      NBTERM = 5*LONLIS + 3
C ---     VECTEUR DU NOM DES NOEUDS
      CALL WKVECT('&&RAPOCO.LISNO','V V K8',NBTERM,JLISNO)
C ---     VECTEUR DU NOM DES DDLS
      CALL WKVECT('&&RAPOCO.LISDDL','V V K8',NBTERM,JLISDL)
C ---     VECTEUR DES COEFFICIENTS REELS
      CALL WKVECT('&&RAPOCO.COER','V V R',NBTERM,JLISCR)
C ---     VECTEUR DES COEFFICIENTS COMPLEXES
      CALL WKVECT('&&RAPOCO.COEC','V V C',NBTERM,JLISCC)
C ---     VECTEUR DES DIRECTIONS DES DDLS A CONTRAINDRE
      CALL WKVECT('&&RAPOCO.DIRECT','V V R',6*NBTERM,JLISDI)
C ---     VECTEUR DES DIMENSIONS DE CES DIRECTIONS
      CALL WKVECT('&&RAPOCO.DIME','V V I',NBTERM,JLISDM)

C ---    RELATIONS ENTRE LES NOEUDS DU MASSIF ET LE NOEUD POUTRE
C        -------------------------------------------------------
C ---    PREMIER GROUPE DE RELATIONS TRADUISANT :
C ---      SOMME/S_RACCORD(U_COQUE) = S_RACCORD*U_NOEUD_POUTRE
C         ----------------------------------------------------

C ---    PREMIERE RELATION :
C     -S.DX(NOEUD_POUTRE) + (SOMME/S_RACCORD(NI.DS)).DX(NOEUD_I) = 0
C     --------------------------------------------------------------

      NBTERM = LONLIS + 1
C ---    BOUCLE SUR LES NOEUDS DES MAILLES DE BORD DE LA PARTIE COQUE
      DO 70 I = 1,LONLIS
        CALL JENONU(JEXNOM(NOEUMA,ZK8(ILISNO+I-1)),INO)
C ---    ADRESSE DE LA PREMIERE COMPOSANTE DU NOEUD INO DANS LES
C ---    CHAMNO (SOMME/S_RACCORD(NI.DS))
        IVAL = ZI(IAPRNO+ (INO-1)* (NBEC+2)+1-1) - 1

        ZK8(JLISNO+I-1) = ZK8(ILISNO+I-1)
        ZK8(JLISDL+I-1) = 'DX'
        ZR(JLISCR+I-1) = ZR(IDCH1-1+IVAL+4)
   70 CONTINUE

      ZK8(JLISNO+LONLIS+1-1) = NOEPOU
      ZK8(JLISDL+LONLIS+1-1) = 'DX'
      ZR(JLISCR+LONLIS+1-1) = -S

      CALL AFRELA(ZR(JLISCR),ZC(JLISCC),ZK8(JLISDL),ZK8(JLISNO),
     &            ZI(JLISDM),ZR(JLISDI),NBTERM,BETA,BETAC,BETAF,TYPCOE,
     &            TYPVAL,TYPLAG,LISREL)
      CALL IMPREL(MOTFAC,NBTERM,ZR(JLISCR),ZK8(JLISDL),ZK8(JLISNO),BETA)

C ---    DEUXIEME RELATION :
C     -S.DY(NOEUD_POUTRE) + (SOMME/S_RACCORD(NI.DS)).DY(NOEUD_I) = 0
C     --------------------------------------------------------------

      NBTERM = LONLIS + 1
C ---   BOUCLE SUR LES NOEUDS DES MAILLES DE BORD DE LA PARTIE COQUE
      DO 80 I = 1,LONLIS
        CALL JENONU(JEXNOM(NOEUMA,ZK8(ILISNO+I-1)),INO)
C ---    ADRESSE DE LA PREMIERE COMPOSANTE DU NOEUD INO DANS LES
C ---    CHAMNO (SOMME/S_RACCORD(NI.DS))
        IVAL = ZI(IAPRNO+ (INO-1)* (NBEC+2)+1-1) - 1

        ZK8(JLISNO+I-1) = ZK8(ILISNO+I-1)
        ZK8(JLISDL+I-1) = 'DY'
        ZR(JLISCR+I-1) = ZR(IDCH1-1+IVAL+4)
   80 CONTINUE

      ZK8(JLISNO+LONLIS+1-1) = NOEPOU
      ZK8(JLISDL+LONLIS+1-1) = 'DY'
      ZR(JLISCR+LONLIS+1-1) = -S

      CALL AFRELA(ZR(JLISCR),ZC(JLISCC),ZK8(JLISDL),ZK8(JLISNO),
     &            ZI(JLISDM),ZR(JLISDI),NBTERM,BETA,BETAC,BETAF,TYPCOE,
     &            TYPVAL,TYPLAG,LISREL)
      CALL IMPREL(MOTFAC,NBTERM,ZR(JLISCR),ZK8(JLISDL),ZK8(JLISNO),BETA)

C ---    TROISIEME RELATION :
C     -S.DZ(NOEUD_POUTRE) + (SOMME/S_RACCORD(NI.DS)).DZ(NOEUD_I) = 0
C     --------------------------------------------------------------

      NBTERM = LONLIS + 1
C --- BOUCLE SUR LES NOEUDS DES MAILLES DE BORD DE LA PARTIE COQUE
      DO 90 I = 1,LONLIS
        CALL JENONU(JEXNOM(NOEUMA,ZK8(ILISNO+I-1)),INO)
C ---    ADRESSE DE LA PREMIERE COMPOSANTE DU NOEUD INO DANS LES
C ---    CHAMNO (SOMME/S_RACCORD(NI.DS))
        IVAL = ZI(IAPRNO+ (INO-1)* (NBEC+2)+1-1) - 1

        ZK8(JLISNO+I-1) = ZK8(ILISNO+I-1)
        ZK8(JLISDL+I-1) = 'DZ'
        ZR(JLISCR+I-1) = ZR(IDCH1-1+IVAL+4)
   90 CONTINUE

      ZK8(JLISNO+LONLIS+1-1) = NOEPOU
      ZK8(JLISDL+LONLIS+1-1) = 'DZ'
      ZR(JLISCR+LONLIS+1-1) = -S

      CALL AFRELA(ZR(JLISCR),ZC(JLISCC),ZK8(JLISDL),ZK8(JLISNO),
     &            ZI(JLISDM),ZR(JLISDI),NBTERM,BETA,BETAC,BETAF,TYPCOE,
     &            TYPVAL,TYPLAG,LISREL)
      CALL IMPREL(MOTFAC,NBTERM,ZR(JLISCR),ZK8(JLISDL),ZK8(JLISNO),BETA)

C ---    DEUXIEME GROUPE DE RELATIONS TRADUISANT :
C ---      SOMME/S_RACCORD(GM X U_COQUE) = I.OMEGA(NOEUD_POUTRE)
C         ------------------------------------------------------
C ---    QUATRIEME RELATION :

      NBTERM = 5*LONLIS + 3
C ---    BOUCLE SUR LES NOEUDS DES MAILLES DE BORD DE LA PARTIE COQUE
      DO 100 I = 1,LONLIS
        CALL JENONU(JEXNOM(NOEUMA,ZK8(ILISNO+I-1)),INO)
C ---    ADRESSE DE LA PREMIERE COMPOSANTE DU NOEUD INO DANS LES CHAMNO
        IVAL = ZI(IAPRNO+ (INO-1)* (NBEC+2)+1-1) - 1

        ZK8(JLISNO+5* (I-1)+1-1) = ZK8(ILISNO+I-1)
        ZK8(JLISNO+5* (I-1)+2-1) = ZK8(ILISNO+I-1)
        ZK8(JLISNO+5* (I-1)+3-1) = ZK8(ILISNO+I-1)
        ZK8(JLISNO+5* (I-1)+4-1) = ZK8(ILISNO+I-1)
        ZK8(JLISNO+5* (I-1)+5-1) = ZK8(ILISNO+I-1)

        ZK8(JLISDL+5* (I-1)+1-1) = 'DZ'
        ZK8(JLISDL+5* (I-1)+2-1) = 'DY'
        ZK8(JLISDL+5* (I-1)+3-1) = 'DRX'
        ZK8(JLISDL+5* (I-1)+4-1) = 'DRY'
        ZK8(JLISDL+5* (I-1)+5-1) = 'DRZ'

        ZR(JLISCR+5* (I-1)+1-1) = ZR(IDCH1-1+IVAL+2)
        ZR(JLISCR+5* (I-1)+2-1) = -ZR(IDCH1-1+IVAL+3)
        ZR(JLISCR+5* (I-1)+3-1) = ZR(IDCH2-1+IVAL+1)
        ZR(JLISCR+5* (I-1)+4-1) = ZR(IDCH2-1+IVAL+2)
        ZR(JLISCR+5* (I-1)+5-1) = ZR(IDCH2-1+IVAL+3)
  100 CONTINUE

      ZK8(JLISNO+5*LONLIS+1-1) = NOEPOU
      ZK8(JLISNO+5*LONLIS+2-1) = NOEPOU
      ZK8(JLISNO+5*LONLIS+3-1) = NOEPOU

      ZK8(JLISDL+5*LONLIS+1-1) = 'DRX'
      ZK8(JLISDL+5*LONLIS+2-1) = 'DRY'
      ZK8(JLISDL+5*LONLIS+3-1) = 'DRZ'

      ZR(JLISCR+5*LONLIS+1-1) = -IG(1)
      ZR(JLISCR+5*LONLIS+2-1) = -IG(2)
      ZR(JLISCR+5*LONLIS+3-1) = -IG(3)

      CALL AFRELA(ZR(JLISCR),ZC(JLISCC),ZK8(JLISDL),ZK8(JLISNO),
     &            ZI(JLISDM),ZR(JLISDI),NBTERM,BETA,BETAC,BETAF,TYPCOE,
     &            TYPVAL,TYPLAG,LISREL)
      CALL IMPREL(MOTFAC,NBTERM,ZR(JLISCR),ZK8(JLISDL),ZK8(JLISNO),BETA)

C ---    CINQUIEME RELATION :

      NBTERM = 5*LONLIS + 3
C ---    BOUCLE SUR LES NOEUDS DES MAILLES DE BORD DE LA PARTIE COQUE
      DO 110 I = 1,LONLIS
        CALL JENONU(JEXNOM(NOEUMA,ZK8(ILISNO+I-1)),INO)
C ---    ADRESSE DE LA PREMIERE COMPOSANTE DU NOEUD INO DANS LES CHAMNO
        IVAL = ZI(IAPRNO+ (INO-1)* (NBEC+2)+1-1) - 1

        ZK8(JLISNO+5* (I-1)+1-1) = ZK8(ILISNO+I-1)
        ZK8(JLISNO+5* (I-1)+2-1) = ZK8(ILISNO+I-1)
        ZK8(JLISNO+5* (I-1)+3-1) = ZK8(ILISNO+I-1)
        ZK8(JLISNO+5* (I-1)+4-1) = ZK8(ILISNO+I-1)
        ZK8(JLISNO+5* (I-1)+5-1) = ZK8(ILISNO+I-1)

        ZK8(JLISDL+5* (I-1)+1-1) = 'DX'
        ZK8(JLISDL+5* (I-1)+2-1) = 'DZ'
        ZK8(JLISDL+5* (I-1)+3-1) = 'DRX'
        ZK8(JLISDL+5* (I-1)+4-1) = 'DRY'
        ZK8(JLISDL+5* (I-1)+5-1) = 'DRZ'

        ZR(JLISCR+5* (I-1)+1-1) = ZR(IDCH1-1+IVAL+3)
        ZR(JLISCR+5* (I-1)+2-1) = -ZR(IDCH1-1+IVAL+1)
        ZR(JLISCR+5* (I-1)+3-1) = ZR(IDCH2-1+IVAL+2)
        ZR(JLISCR+5* (I-1)+4-1) = ZR(IDCH2-1+IVAL+4)
        ZR(JLISCR+5* (I-1)+5-1) = ZR(IDCH2-1+IVAL+5)
  110 CONTINUE

      ZK8(JLISNO+5*LONLIS+1-1) = NOEPOU
      ZK8(JLISNO+5*LONLIS+2-1) = NOEPOU
      ZK8(JLISNO+5*LONLIS+3-1) = NOEPOU

      ZK8(JLISDL+5*LONLIS+1-1) = 'DRX'
      ZK8(JLISDL+5*LONLIS+2-1) = 'DRY'
      ZK8(JLISDL+5*LONLIS+3-1) = 'DRZ'

      ZR(JLISCR+5*LONLIS+1-1) = -IG(2)
      ZR(JLISCR+5*LONLIS+2-1) = -IG(4)
      ZR(JLISCR+5*LONLIS+3-1) = -IG(5)

      CALL AFRELA(ZR(JLISCR),ZC(JLISCC),ZK8(JLISDL),ZK8(JLISNO),
     &            ZI(JLISDM),ZR(JLISDI),NBTERM,BETA,BETAC,BETAF,TYPCOE,
     &            TYPVAL,TYPLAG,LISREL)
      CALL IMPREL(MOTFAC,NBTERM,ZR(JLISCR),ZK8(JLISDL),ZK8(JLISNO),BETA)

C ---    SIXIEME RELATION :

      NBTERM = 5*LONLIS + 3
C ---    BOUCLE SUR LES NOEUDS DES MAILLES DE BORD DE LA PARTIE COQUE
      DO 120 I = 1,LONLIS
        CALL JENONU(JEXNOM(NOEUMA,ZK8(ILISNO+I-1)),INO)
C ---    ADRESSE DE LA PREMIERE COMPOSANTE DU NOEUD INO DANS LES CHAMNO
        IVAL = ZI(IAPRNO+ (INO-1)* (NBEC+2)+1-1) - 1

        ZK8(JLISNO+5* (I-1)+1-1) = ZK8(ILISNO+I-1)
        ZK8(JLISNO+5* (I-1)+2-1) = ZK8(ILISNO+I-1)
        ZK8(JLISNO+5* (I-1)+3-1) = ZK8(ILISNO+I-1)
        ZK8(JLISNO+5* (I-1)+4-1) = ZK8(ILISNO+I-1)
        ZK8(JLISNO+5* (I-1)+5-1) = ZK8(ILISNO+I-1)

        ZK8(JLISDL+5* (I-1)+1-1) = 'DY'
        ZK8(JLISDL+5* (I-1)+2-1) = 'DX'
        ZK8(JLISDL+5* (I-1)+3-1) = 'DRX'
        ZK8(JLISDL+5* (I-1)+4-1) = 'DRY'
        ZK8(JLISDL+5* (I-1)+5-1) = 'DRZ'

        ZR(JLISCR+5* (I-1)+1-1) = ZR(IDCH1-1+IVAL+1)
        ZR(JLISCR+5* (I-1)+2-1) = -ZR(IDCH1-1+IVAL+2)
        ZR(JLISCR+5* (I-1)+3-1) = ZR(IDCH2-1+IVAL+3)
        ZR(JLISCR+5* (I-1)+4-1) = ZR(IDCH2-1+IVAL+5)
        ZR(JLISCR+5* (I-1)+5-1) = ZR(IDCH2-1+IVAL+6)
  120 CONTINUE

      ZK8(JLISNO+5*LONLIS+1-1) = NOEPOU
      ZK8(JLISNO+5*LONLIS+2-1) = NOEPOU
      ZK8(JLISNO+5*LONLIS+3-1) = NOEPOU

      ZK8(JLISDL+5*LONLIS+1-1) = 'DRX'
      ZK8(JLISDL+5*LONLIS+2-1) = 'DRY'
      ZK8(JLISDL+5*LONLIS+3-1) = 'DRZ'

      ZR(JLISCR+5*LONLIS+1-1) = -IG(3)
      ZR(JLISCR+5*LONLIS+2-1) = -IG(5)
      ZR(JLISCR+5*LONLIS+3-1) = -IG(6)

      CALL AFRELA(ZR(JLISCR),ZC(JLISCC),ZK8(JLISDL),ZK8(JLISNO),
     &            ZI(JLISDM),ZR(JLISDI),NBTERM,BETA,BETAC,BETAF,TYPCOE,
     &            TYPVAL,TYPLAG,LISREL)
      CALL IMPREL(MOTFAC,NBTERM,ZR(JLISCR),ZK8(JLISDL),ZK8(JLISNO),BETA)

      IF ((OPTION.EQ.'COQ_TUYA')) THEN
        CALL RACOTU(ZI(IAPRNO),LONLIS,ZK8(ILISNO),NOEPOU,NOMA,LIGREL,
     &              MOD,CARA,NUMDDL,TYPLAG,LISREL,COORIG)
      END IF

C --- DESTRUCTION DES OBJETS DE TRAVAIL
C     ---------------------------------

      CALL JEDETC('V','&&RAPOCO',1)

  130 CONTINUE
      CALL JEDEMA()
      END
