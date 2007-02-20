      SUBROUTINE DRZ12D(LISNOZ,LONLIS,CHARGZ,TYPLAZ,LISREZ)
      IMPLICIT REAL*8 (A-H,O-Z)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF MODELISA  DATE 20/02/2007   AUTEUR LEBOUVIER F.LEBOUVIER 
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
      CHARACTER*8 CHARGE
      CHARACTER*19 LISREL
      CHARACTER*24 LISNOE
      CHARACTER*(*) CHARGZ,LISNOZ,TYPLAZ,LISREZ
C -------------------------------------------------------
C     BLOCAGE DES DEPLACEMENTS RELATIFS D'UNE LISTE DE NOEUDS
C     SPECIFIEE PAR L'UTILISATEUR DANS LE CAS OU L' ON EST
C     EN 2D ET AU-MOINS L'UN DES NOEUDS PORTE LE DDL DRZ
C -------------------------------------------------------
C  LISNOE        - IN    - K24 - : NOM DE LA LISTE DES
C                -       -     -   NOEUDS A LIER
C -------------------------------------------------------
C  LONLIS        - IN    - I   - : LONGUEUR DE LA LISTE DES
C                -       -     -   NOEUDS A LIER
C -------------------------------------------------------
C  CHARGE        - IN    - K8  - : NOM DE LA SD CHARGE
C                - JXIN  -     -
C -------------------------------------------------------
C TYPLAG         - IN    - K2  - : TYPE DES MULTIPLICATEURS DE LAGRANGE
C                                  ASSOCIES A LA RELATION :
C                              SI = '12'  LE PREMIER LAGRANGE EST AVANT
C                                         LE NOEUD PHYSIQUE
C                                         LE SECOND LAGRANGE EST APRES
C                              SI = '22'  LE PREMIER LAGRANGE EST APRES
C                                         LE NOEUD PHYSIQUE
C                                         LE SECOND LAGRANGE EST APRES
C -------------------------------------------------------
C  LISREL        - IN    - K19 - : NOM DE LA SD
C                - JXVAR -     -   LISTE DE RELATIONS
C -------------------------------------------------------

C --------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ------
      CHARACTER*32 JEXNUM,JEXNOM,JEXR8,JEXATR
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
      COMPLEX*16 BETAC
      CHARACTER*2 TYPLAG
      CHARACTER*4 TYPVAL,TYPCOE
      CHARACTER*8 BETAF,RESU
      CHARACTER*8 MOD,NOMG,NOMNOE,K8BID,NO1
      CHARACTER*8 NOMA,CMP,NOMCMP(NMOCL)
      CHARACTER*9 NOMTE
      CHARACTER*16 TYPE,OPER
      CHARACTER*19 LIGRMO
      INTEGER NTYPEL(NMOCL)
      INTEGER VALI(2)
      LOGICAL VERIF,EXISDG
      CHARACTER*1 K1BID
C --------- FIN  DECLARATIONS  VARIABLES LOCALES --------
      CALL JEMARQ()
      CALL GETRES(RESU,TYPE,OPER)
      LISREL = LISREZ
      CHARGE = CHARGZ
      TYPLAG = TYPLAZ
      LISNOE = LISNOZ

C --- INITIALISATIONS

      BETAF = '&FOZERO'
      BETA = 0.0D0
      BETAC = (0.0D0,0.0D0)
      UN = 1.0D0

C --- MODELE ASSOCIE AU LIGREL DE CHARGE

      CALL DISMOI('F','NOM_MODELE',CHARGE(1:8),'CHARGE',IBID,MOD,IER)

C ---  LIGREL DU MODELE

      LIGRMO = MOD(1:8)//'.MODELE'

C --- MAILLAGE ASSOCIE AU MODELE

      CALL JEVEUO(LIGRMO//'.NOMA','L',JNOMA)
      NOMA = ZK8(JNOMA)

C --- TYPE DES VALEURS DES COEFFICIENTS DES RELATIONS

      TYPCOE = 'REEL'

C --- TYPE DES VALEURS AU SECOND MEMBRE DES RELATIONS

      IF (OPER(15:16).EQ.'_F') THEN
        TYPVAL = 'FONC'
      ELSE IF (OPER(15:16).EQ.'_C') THEN
        TYPVAL = 'COMP'
      ELSE IF (OPER(15:16).EQ.'  ') THEN
        TYPVAL = 'REEL'
      ELSE
        CALL ASSERT(.FALSE.)
      END IF

C --- RECUPERATION DES NOMS DES DDLS ET DES NUMEROS
C --- D'ELEMENTS DE LAGRANGE ASSOCIES

      NOMG = 'DEPL_R'
      NOMTE = 'D_DEPL_R_'

      CALL JEVEUO(JEXNOM('&CATA.GD.NOMCMP',NOMG),'L',INOM)
      CALL JELIRA(JEXNOM('&CATA.GD.NOMCMP',NOMG),'LONMAX',NBCMP,K1BID)
      NDDLA = NBCMP - 1
      IF (NDDLA.GT.NMOCL) THEN
        VALI (1) = NMOCL
        VALI (2) = NDDLA
        CALL U2MESG('F', 'MODELISA8_62',0,' ',2,VALI,0,0.D0)
      END IF
      DO 10 I = 1,NDDLA
        NOMCMP(I) = ZK8(INOM-1+I)
        CALL JENONU(JEXNOM('&CATA.TE.NOMTE',NOMTE//NOMCMP(I) (1:7)),
     &              NTYPEL(I))
   10 CONTINUE
      CALL DISMOI('F','NB_EC',NOMG,'GRANDEUR',NBEC,K8BID,IERD)

C --- ACCES A L'OBJET .PRNM

      IF (NBEC.GT.10) THEN
        CALL U2MESS('F','MODELISA_94')
      ELSE
        CALL JEVEUO(LIGRMO//'.PRNM','L',JPRNM)
      END IF

C --- CREATION DES TABLEAUX DE TRAVAIL NECESSAIRES A L'AFFECTATION
C --- DE LISREL

C ---  MAJORANT DU NOMBRE DE TERMES DANS UNE RELATION
      NBTERM = 12
C ---  VECTEUR DU NOM DES NOEUDS
      CALL WKVECT('&&DRZ12D.LISNO','V V K8',NBTERM,JLISNO)
C ---  VECTEUR DU NOM DES DDLS
      CALL WKVECT('&&DRZ12D.LISDDL','V V K8',NBTERM,JLISDL)
C ---  VECTEUR DES COEFFICIENTS REELS
      CALL WKVECT('&&DRZ12D.COER','V V R',NBTERM,JLISCR)
C ---  VECTEUR DES COEFFICIENTS COMPLEXES
      CALL WKVECT('&&DRZ12D.COEC','V V C',NBTERM,JLISCC)
C ---  VECTEUR DES DIRECTIONS DES DDLS A CONTRAINDRE
      CALL WKVECT('&&DRZ12D.DIRECT','V V R',3*NBTERM,JLISDI)
C ---  VECTEUR DES DIMENSIONS DE CES DIRECTIONS
      CALL WKVECT('&&DRZ12D.DIME','V V I',NBTERM,JLISDM)

C --- RECUPERATION DU TABLEAU DES COORDONNEES

      CALL JEVEUO(NOMA//'.COORDO    .VALE','L',JCOOR)

C --- ACQUISITION DE LA LISTE DES NOEUDS A LIER
C --- (CETTE LISTE EST NON REDONDANTE)

      CALL JEVEUO(LISNOE,'L',ILISNO)


C ---      ON REGARDE S'IL Y A UN NOEUD DE LA LISTE PORTANT LE DDL DRZ

      CMP = 'DRZ'
      DO 20 I = 1,LONLIS
C ---        NUMERO DU NOEUD COURANT DE LA LISTE
        CALL JENONU(JEXNOM(NOMA//'.NOMNOE',ZK8(ILISNO+I-1)),IN)

        ICMP = INDIK8(NOMCMP,CMP,1,NDDLA)
        IF (EXISDG(ZI(JPRNM-1+ (IN-1)*NBEC+1),ICMP)) THEN
          NOMNOE = ZK8(ILISNO+I-1)
          INO = IN
          GO TO 30
        END IF
   20 CONTINUE

      CALL U2MESS('F','MODELISA4_43')

   30 CONTINUE

      ZK8(JLISNO+2-1) = NOMNOE
      ZK8(JLISNO+3-1) = NOMNOE

      DO 40 I = 1,LONLIS
        IF (ZK8(ILISNO+I-1).EQ.NOMNOE) GO TO 40
        CALL JENONU(JEXNOM(NOMA//'.NOMNOE',ZK8(ILISNO+I-1)),IN)
        X = ZR(JCOOR-1+3* (IN-1)+1) - ZR(JCOOR-1+3* (INO-1)+1)
        Y = ZR(JCOOR-1+3* (IN-1)+2) - ZR(JCOOR-1+3* (INO-1)+2)

C ---    PREMIERE RELATION
C ---    DX(M) - DX(A) + Y*DRZ(A) = 0

        NBTERM = 3

        ZK8(JLISNO+1-1) = ZK8(ILISNO+I-1)

        ZK8(JLISDL+1-1) = 'DX'
        ZK8(JLISDL+2-1) = 'DX'
        ZK8(JLISDL+3-1) = 'DRZ'

        ZR(JLISCR+1-1) = UN
        ZR(JLISCR+2-1) = -UN
        ZR(JLISCR+3-1) = Y

        CALL AFRELA(ZR(JLISCR),ZC(JLISCC),ZK8(JLISDL),ZK8(JLISNO),
     &              ZI(JLISDM),ZR(JLISDI),NBTERM,BETA,BETAC,BETAF,
     &              TYPCOE,TYPVAL,TYPLAG,0.D0,LISREL)

C ---    DEUXIEME RELATION
C ---    DY(M) - DY(A) - X*DRZ(A) = 0

        NBTERM = 3

        ZK8(JLISNO+1-1) = ZK8(ILISNO+I-1)

        ZK8(JLISDL+1-1) = 'DY'
        ZK8(JLISDL+2-1) = 'DY'
        ZK8(JLISDL+3-1) = 'DRZ'

        ZR(JLISCR+1-1) = UN
        ZR(JLISCR+2-1) = -UN
        ZR(JLISCR+3-1) = -X

        CALL AFRELA(ZR(JLISCR),ZC(JLISCC),ZK8(JLISDL),ZK8(JLISNO),
     &              ZI(JLISDM),ZR(JLISDI),NBTERM,BETA,BETAC,BETAF,
     &              TYPCOE,TYPVAL,TYPLAG,0.D0,LISREL)

C ---    TROISIEME RELATION SI LE NOEUD COURANT PORTE LE DDL DRZ
C ---    DRZ(M) - DRZ(A)  = 0

        ICMP = INDIK8(NOMCMP,CMP,1,NDDLA)
        IF (EXISDG(ZI(JPRNM-1+ (IN-1)*NBEC+1),ICMP)) THEN

          NBTERM = 2

          ZK8(JLISNO+1-1) = ZK8(ILISNO+I-1)
          ZK8(JLISNO+2-1) = NOMNOE

          ZK8(JLISDL+1-1) = 'DRZ'
          ZK8(JLISDL+2-1) = 'DRZ'

          ZR(JLISCR+1-1) = UN
          ZR(JLISCR+2-1) = -UN

          CALL AFRELA(ZR(JLISCR),ZC(JLISCC),ZK8(JLISDL),ZK8(JLISNO),
     &                ZI(JLISDM),ZR(JLISDI),NBTERM,BETA,BETAC,BETAF,
     &                TYPCOE,TYPVAL,TYPLAG,0.D0,LISREL)
        END IF
   40 CONTINUE

C --- DESTRUCTION DES OBJETS DE TRAVAIL

      CALL JEDETR('&&DRZ12D.LISNO')
      CALL JEDETR('&&DRZ12D.LISDDL')
      CALL JEDETR('&&DRZ12D.COER')
      CALL JEDETR('&&DRZ12D.COEC')
      CALL JEDETR('&&DRZ12D.DIRECT')
      CALL JEDETR('&&DRZ12D.DIME')

      CALL JEDEMA()
      END
