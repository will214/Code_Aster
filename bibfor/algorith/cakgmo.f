      SUBROUTINE CAKGMO(OPTION,RESULT,MODELE,DEPLA,THETAI,MATE,COMPOR,
     &                 NCHAR,LCHAR,SYMECH,CHFOND,NNOFF,BASLOC,COURB,
     &                 IORD,NDEG,THLAGR,GLAGR,THLAG2,PAIR,NDIMTE,
     &                 PULS,NBPRUP,NOPRUP,FISS,MILIEU,CONNEX)
      IMPLICIT  NONE

      INCLUDE 'jeveux.h'
      INTEGER IORD,NCHAR,NBPRUP,NDIMTE
      REAL*8 PULS
      CHARACTER*8 MODELE,THETAI,LCHAR(*),FISS
      CHARACTER*8 RESULT,SYMECH
      CHARACTER*16 OPTION,NOPRUP(*)
      CHARACTER*24 DEPLA,CHFOND,MATE,COMPOR,BASLOC,COURB,CHPULS
      LOGICAL THLAGR,GLAGR,THLAG2,PAIR,MILIEU,CONNEX

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 28/08/2012   AUTEUR TRAN V-X.TRAN 
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
C     TOLE CRP_21

C  FONCTION REALISEE:   CALCUL DES FACTEURS D'INTENSITE DE CONTRAINTES
C                       POUR UN MODE PROPRE EN 3D

C  IN    OPTION --> K_G_MODA
C  IN    RESULT --> NOM UTILISATEUR DU RESULTAT ET TABLE
C  IN    MODELE --> NOM DU MODELE
C  IN    DEPLA  --> CHAMP DE DEPLACEMENT
C  IN    THETAI --> BASE DE I CHAMPS THETA
C  IN    MATE   --> CHAMP DE MATERIAUX
C  IN    COMPOR --> COMPORTEMENT
C  IN    NCHAR  --> NOMBRE DE CHARGES
C  IN    LCHAR  --> LISTE DES CHARGES
C  IN    SYMECH --> SYMETRIE DU CHARGEMENT
C  IN    CHFOND --> POINTS DU FOND DE FISSURE
C  IN    NNOFF  --> NOMBRE DE POINTS DU FOND DE FISSURE
C  IN    BASLOC --> BASE LOCALE
C  IN    IORD   --> NUMERO D'ORDRE DE LA SD
C  IN    THLAGR --> VRAI SI LISSAGE THETA_LAGRANGE (SINON LEGENDRE)
C  IN    GLAGR  --> VRAI SI LISSAGE G_LAGRANGE (SINON LEGENDRE)
C  IN    NDEG   --> DEGRE DU POLYNOME DE LEGENDRE
C  IN    FISS   --> NOM DE LA SD FISS_XFEM OU SD FOND_FISS
C  IN    MILIEU --> .TRUE.  : ELEMENT QUADRATIQUE
C                   .FALSE. : ELEMENT LINEAIRE
C  IN    CONNEX --> .TRUE.  SI FOND FERME
C                   .FALSE. SI FOND OUVERT
C ......................................................................


      INTEGER I,J,IBID,IADRGK,IADGKS,JRESU,NCHIN
      INTEGER NNOFF,NUM,NSIG,NDEP
      INTEGER NDEG,IERD,INIT,GPMI(2)
      INTEGER IADGKI,IADABS,IFM,NIV,NEXCI
      REAL*8  GKTHI(8),GPMR(8),TIME
      COMPLEX*16 CBID
      LOGICAL EXIGEO,FONC,EPSI,EXTIM
      CHARACTER*1  K1BID
      CHARACTER*8  LPAIN(21),LPAOUT(1)
      CHARACTER*16 OPTI,VALK
      CHARACTER*19 CHROTA,CHPESA,CHVOLU,CF1D2D,CHEPSI,CF2D3D,CHPRES
      CHARACTER*24 LIGRMO,CHGEOM,CHGTHI
      CHARACTER*24 CHSIGI,CHDEPI
      CHARACTER*24 LCHIN(21),LCHOUT(1),CHTHET
      CHARACTER*24 ABSCUR,PAVOLU
      CHARACTER*19 PINTTO,CNSETO,HEAVTO,LONCHA,LNNO,LTNO
      INTEGER      IARG

C     ------------------------------------------------------------------
C
      CALL JEMARQ()
      CALL INFNIV(IFM,NIV)

      TIME = 0.D0
      EXTIM = .FALSE.
      OPTI = OPTION

C- RECUPERATION DU CHAMP GEOMETRIQUE

      CALL MEGEOM(MODELE,' ',EXIGEO,CHGEOM)

C- RECUPERATION DE L'ETAT INITIAL

      CALL GETVID('COMP_INCR','SIGM_INIT',1,IARG,1,CHSIGI,INIT)
      IF (INIT.NE.0) THEN
        VALK='K_G_MODA'
        CALL U2MESK('F','RUPTURE1_13',1,VALK)
      END IF


C --- RECUPERATION DES DONNEES XFEM (TOPOSE)
C

      PINTTO = MODELE(1:8)//'.TOPOSE.PIN'
      CNSETO = MODELE(1:8)//'.TOPOSE.CNS'
      HEAVTO = MODELE(1:8)//'.TOPOSE.HEA'
      LONCHA = MODELE(1:8)//'.TOPOSE.LON'
C     ON NE PREND PAS LES LSN ET LST DU MODELE
C     CAR LES CHAMPS DU MODELE SONT DEFINIS QUE AUTOUR DE LA FISSURE
C     OR ON A BESOIN DE LSN ET LST MEME POUR LES �L�MENTS CLASSIQUES
      LNNO   = FISS//'.LNNO'
      LTNO   = FISS//'.LTNO'

C traitement des chargements

      CHVOLU = '&&CAKGMO.VOLU'
      CF1D2D = '&&CAKGMO.1D2D'
      CF2D3D = '&&CAKGMO.2D3D'
      CHPRES = '&&CAKGMO.PRES'
      CHEPSI = '&&CAKGMO.EPSI'
      CHPESA = '&&CAKGMO.PESA'
      CHROTA = '&&CAKGMO.ROTA'
      CALL GCHARG(MODELE,NCHAR,LCHAR,CHVOLU,CF1D2D,CF2D3D,CHPRES,CHEPSI,
     &            CHPESA,CHROTA,FONC,EPSI,TIME,IORD)

      CALL GETFAC('EXCIT',NEXCI)

C   IF (NEXCI.EQ.0) CALL U2MESS('A','RUPTURE1_50')

      PAVOLU = 'PFRVOLU'

      CALL MEFOR0 ( MODELE, CHVOLU, .FALSE. )
      CALL MEFOR0 ( MODELE, CF2D3D, .FALSE. )
      CALL MEPRES ( MODELE, CHPRES, .FALSE. )

C- CALCUL DES K(THETA_I) AVEC I=1,NDIMTE  NDIMTE = NNOFF  SI TH-LAGRANGE
C                                         NDIMTE = NDEG+1 SI TH-LEGENDRE
      IF (THLAG2) THEN
        NDIMTE = NDIMTE
      ELSEIF (THLAGR) THEN
        NDIMTE = NNOFF
      ELSE
        NDIMTE = NDEG + 1
      END IF

      CALL WKVECT('&&CAKGMO.VALG','V V R8',NDIMTE*8,IADRGK)
      CALL JEVEUO(THETAI,'L',JRESU)

      LIGRMO = MODELE//'.MODELE'

      CHPULS = '&&CAKGMO.PULS'
      CALL MECACT('V',CHPULS,'MODELE',LIGRMO,'FREQ_R  ',1,'FREQ   ',
     &            IBID,PULS,CBID,' ')

      DO 20 I = 1,NDIMTE

        CHTHET = ZK24(JRESU+I-1)
        CALL CODENT(I,'G',CHGTHI)
        LPAOUT(1) = 'PGTHETA'
        LCHOUT(1) = CHGTHI
        LPAIN(1) = 'PGEOMER'
        LCHIN(1) = CHGEOM
        LPAIN(2) = 'PDEPLAR'
        LCHIN(2) = DEPLA
        LPAIN(3) = 'PTHETAR'
        LCHIN(3) = CHTHET
        LPAIN(4) = 'PMATERC'
        LCHIN(4) = MATE
        LPAIN(5) = 'PCOMPOR'
        LCHIN(5) = COMPOR
        LPAIN(6) = 'PBASLOR'
        LCHIN(6) = BASLOC
        LPAIN(7) = 'PCOURB'
        LCHIN(7) = COURB
        LPAIN(8) = 'PPULPRO'
        LCHIN(8) = CHPULS
        LPAIN(9) = 'PLSN'
        LCHIN(9) = LNNO
        LPAIN(10) = 'PLST'
        LCHIN(10) = LTNO
        LPAIN(11) = 'PPINTTO'
        LCHIN(11) = PINTTO
        LPAIN(12) = 'PCNSETO'
        LCHIN(12) = CNSETO
        LPAIN(13) = 'PHEAVTO'
        LCHIN(13) = HEAVTO
        LPAIN(14) = 'PLONCHA'
        LCHIN(14) = LONCHA
        LPAIN(15) = PAVOLU(1:8)
        LCHIN(15) = CHVOLU
C
        NCHIN = 15
C
        CALL CALCUL('S',OPTI,LIGRMO,NCHIN,LCHIN,LPAIN,1,LCHOUT,LPAOUT,
     &              'V','OUI')

C     BUT :  FAIRE LA "SOMME" D'UN CHAM_ELEM
        CALL MESOMM(CHGTHI,8,IBID,GKTHI,CBID,0,IBID)

        DO 29 J=1,7
          ZR(IADRGK-1+(I-1)*8+J) = GKTHI(J)
 29     CONTINUE

 20   CONTINUE

C- CALCUL DE G(S), K1(S), K2(S) et K3(S)
C             SUR LE FOND DE FISSURE PAR 2 METHODES
C- PREMIERE METHODE : G_LEGENDRE ET THETA_LEGENDRE
C- DEUXIEME METHODE : G_LEGENDRE ET THETA_LAGRANGE
C- TROISIEME METHODE: G_LAGRANGE ET THETA_LAGRANGE
C    (OU G_LAGRANGE_NO_NO ET THETA_LAGRANGE)

      CALL WKVECT('&&CAKGMO.VALGK_S','V V R8',NNOFF*6,IADGKS)
      IF (GLAGR.OR.THLAG2) THEN
        CALL WKVECT('&&CAKGMO.VALGKI','V V R8',NNOFF*5,IADGKI)
      ELSE
        CALL WKVECT('&&CAKGMO.VALGKI','V V R8',(NDEG+1)*5,IADGKI)
      END IF

      ABSCUR='&&CAKGMO.TEMP     .ABSCU'
      CALL WKVECT(ABSCUR,'V V R',NNOFF,IADABS)

      IF(THLAG2) THEN
        NUM = 5
        CALL GKMET4(NNOFF,NDIMTE,CHFOND,PAIR,IADRGK,MILIEU,CONNEX,
     &              IADGKS,IADGKI,ABSCUR,NUM)
      ELSEIF ((.NOT.GLAGR) .AND. (.NOT.THLAGR)) THEN
        NUM = 1
        CALL GKMET1(NDEG,NNOFF,CHFOND,IADRGK,IADGKS,IADGKI,ABSCUR)
C
      ELSE IF (THLAGR) THEN
C        NORMFF = ZK24(JRESU+NNOFF+1-1)
C        NORMFF(20:24) = '.VALE'
        IF (.NOT.GLAGR) THEN
          NUM = 2
          CALL U2MESS('F','RUPTURE1_17')
C         CALL GMETH2(NDEG,NNOFF,CHFOND,IADRGK,IADGKS,IADGKI,ABSCUR,NUM)
        ELSE
          NUM = 3
          CALL GKMET3(NNOFF,CHFOND,IADRGK,MILIEU,CONNEX,IADGKS,IADGKI,
     &                ABSCUR,NUM,MODELE)
        END IF
      END IF
C
C- SYMETRIE DU CHARGEMENT ET IMPRESSION DES RESULTATS
C
      IF (SYMECH.EQ.'OUI') THEN
        DO 30 I = 1,NNOFF
C         G(S) = 2*G(S)
          ZR(IADGKS+6*(I-1)) = 2.D0*ZR(IADGKS+6*(I-1))
C         K1(S) = 2*K1(S)
          ZR(IADGKS+6*(I-1) + 1) = 2.D0*ZR(IADGKS+6*(I-1) + 1)
C         K2(S) = 0, K3(S) = 0
          ZR(IADGKS+6*(I-1) + 2) = 0.D0
          ZR(IADGKS+6*(I-1) + 3) = 0.D0
 30    CONTINUE
      END IF
C
C- IMPRESSION ET ECRITURE DANS TABLE(S) DE K1(S), K2(S) ET K3(S)

      IF (NIV.GE.2) THEN
        CALL GKSIMP(RESULT,NNOFF,ZR(IADABS),IADRGK,NUM,IADGKS,
     &              NDEG,NDIMTE,IADGKI,EXTIM,TIME,IORD,IFM)
      END IF
C
      DO 40 I = 1,NNOFF
          GPMI(1)=IORD
          GPMI(2)=I
          GPMR(1) = ZR(IADABS-1+I)
            GPMR(2) = ZR(IADGKS-1+6*(I-1)+2)
            GPMR(3) = ZR(IADGKS-1+6*(I-1)+3)
            GPMR(4) = ZR(IADGKS-1+6*(I-1)+4)
            GPMR(5) = ZR(IADGKS-1+6*(I-1)+1)
            GPMR(6) = ZR(IADGKS-1+6*(I-1)+6)
            GPMR(7) = ZR(IADGKS-1+6*(I-1)+5)

        CALL TBAJLI(RESULT,NBPRUP,NOPRUP,GPMI,GPMR,CBID,K1BID,0)
 40   CONTINUE
C
C- DESTRUCTION D'OBJETS DE TRAVAIL
C
      CALL JEDETR(ABSCUR)
      CALL JEDETR('&&CAKGMO.VALG_S')
      CALL JEDETR('&&CAKGMO.VALGKI')
      CALL JEDETR('&&CAKGMO.VALGK_S')
C
      CALL JEDETR('&&CAKGMO.VALG')
C
      CALL JEDEMA()
      END
