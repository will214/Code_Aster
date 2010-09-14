      SUBROUTINE IRGMCE ( CHAMSY, PARTIE, IFI,
     &                    NOMCON, NOSIMP, NOPASE,
     &                    ORDR, NBORDR,
     &                    COORD, CONNX, POINT, NOBJ, NBEL,
     &                    NBCMPI, NOMCMP, LRESU, PARA,
     &                    NOMAOU, NOMAIN,
     &                    VERSIO, TYCHA)
      IMPLICIT NONE
      CHARACTER*(*) NOMCON, NOSIMP, NOPASE, CHAMSY, NOMCMP(*), PARTIE
      CHARACTER*8 NOMAOU,NOMAIN,TYCHA
      REAL*8 COORD(*),PARA(*)
      LOGICAL LRESU
      INTEGER NBCMPI,IFI,NBORDR,VERSIO
      INTEGER ORDR(*),CONNX(*),POINT(*)
C     NBRE, NOM D'OBJET POUR CHAQUE TYPE D'ELEMENT
      INTEGER    NELETR
      PARAMETER (NELETR =  8)
      INTEGER    NTYELE,MAXEL,MAXNO
      PARAMETER (NTYELE = 28)
      PARAMETER (MAXEL  = 48)
      PARAMETER (MAXNO  =  8)
      INTEGER             TDEC(NTYELE,MAXEL,MAXNO)
      INTEGER                   TYPD(NTYELE,3)
      INTEGER      TORD(NELETR)
      INTEGER      NBEL(NTYELE),NBEL2(NTYELE),JEL(NTYELE)
      CHARACTER*24 NOBJ(NTYELE)
C     ------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF PREPOST  DATE 14/09/2010   AUTEUR REZETTE C.REZETTE 
C ======================================================================
C COPYRIGHT (C) 1991 - 2002  EDF R&D                  WWW.CODE-ASTER.ORG
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

C        IMPRESSION D'UN CHAM_ELEM AU FORMAT GMSH

C        CHAMSY : NOM DU CHAM_ELEM A ECRIRE
C        IFI    : NUMERO D'UNITE LOGIQUE DU FICHIER DE SORTIE GMSH
C        NOMCON : NOM DU CONCEPT A IMPRIMER
C        PARTIE : IMPRESSION DE LA PARTIE COMPLEXE OU REELLE DU CHAMP
C        NBORDR : NOMBRE DE NUMEROS D'ORDRE DANS LE TABLEAU ORDR
C        ORDR   : LISTE DES NUMEROS D'ORDRE A IMPRIMER
C        COORD  : VECTEUR COORDONNEES DES NOEUDS DU MAILLAGE
C        CONNX  : VECTEUR CONNECTIVITES DES NOEUDS DU MAILLAGE
C        POINT  : VECTEUR DU NOMBRE DE NOEUDS DES MAILLES DU MAILLAGE
C        NOBJ(i): NOM JEVEUX DEFINISSANT LES ELEMENTS DU MAILLAGE
C        NBEL(i): NOMBRE D'ELEMENTS DU MAILLAGE DE TYPE i
C        NBCMPI : NOMBRE DE COMPOSANTES DEMANDEES A IMPRIMER
C        NOMCMP : NOMS DES COMPOSANTES DEMANDEES A IMPRIMER
C        LRESU  : LOGIQUE INDIQUANT SI NOMCON EST UNE SD RESULTAT
C        PARA   : VALEURS DES VARIABLES D'ACCES (INST, FREQ)
C        NOMAOU : NOM DU MAILLAGE REDECOUPE
C        VERSIO : NUMERO DE LA VERSION GMSH UTILISEE (1 OU 2)

C     ------------------------------------------------------------------
C     ----- DEBUT COMMUNS NORMALISES  JEVEUX  --------------------------
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
C     -----  FIN  COMMUNS NORMALISES  JEVEUX  --------------------------

      INTEGER IOR,I,J,K,INE,INOE,IMA,LISTNO(8),IX,NBNO
      INTEGER IQ, IFM, NIV, JTYPE,INDIK8,JZCMP,NCMPME
      INTEGER IBID,NBCMP,IPOIN,IRET,JCESC,JCESL
      INTEGER JTABC,JTABD,JTABV,JTABL,JCESK,JCESD
      INTEGER ICMP,JNCMP,IPT,ISP,NBPT,NBSP,JNUMOL
      INTEGER NBMA,NCMPU,IAD,NBCMPD,NBORD2,IADMAX,IADMM
      PARAMETER(NCMPME=12)
      LOGICAL IWRI, TENS, SCAL, VECT, LCMP
      CHARACTER*1 TSCA
      CHARACTER*8 K8B,NOMGD,TYPE,NOCMP
      CHARACTER*19 NOCH19,CHAMPS
      CHARACTER*24 NUMOLD,CONNEX
C     ------------------------------------------------------------------

      CALL INFNIV(IFM,NIV)
      CALL JEMARQ()

C --- TABLEAU DES INFOS DE DECOUPAGE
      CALL IRGMTB(TDEC,TYPD,VERSIO)
C
C --- ORDRE D'IMPRESSION DES VALEURS
      CALL IRGMOR(TORD,VERSIO)
C
      NBORD2 = MAX(1,NBORDR)
      NUMOLD = NOMAOU//'.NUMOLD         '
      CONNEX = NOMAIN//'.CONNEX         '

      CALL WKVECT('&&IRGMCE.CESD','V V I',NBORD2,JTABD)
      CALL WKVECT('&&IRGMCE.CESC','V V I',NBORD2,JTABC)
      CALL WKVECT('&&IRGMCE.CESV','V V I',NBORD2,JTABV)
      CALL WKVECT('&&IRGMCE.CESL','V V I',NBORD2,JTABL)
      CALL WKVECT('&&IRGMCG.TYPE','V V K8',NBORD2,JTYPE)

      NBCMP = 0
      DO 60 IOR = 1,NBORD2
        IF (LRESU) THEN
          CALL RSEXCH(NOMCON,CHAMSY,ORDR(IOR),NOCH19,IRET)
          IF (IRET.NE.0) GO TO 60
        ELSE
          NOCH19 = NOMCON
        END IF
        CALL CODENT(IOR,'D0',K8B)
        CHAMPS = '&&IRGMCE.CH'//K8B
        CALL CELCES(NOCH19,'V',CHAMPS)
        CALL JEVEUO(CHAMPS//'.CESK','L',JCESK)
        CALL JEVEUO(CHAMPS//'.CESD','L',ZI(JTABD+IOR-1))
        CALL JEVEUO(CHAMPS//'.CESC','L',ZI(JTABC+IOR-1))
        CALL JEVEUO(CHAMPS//'.CESV','L',ZI(JTABV+IOR-1))
        CALL JEVEUO(CHAMPS//'.CESL','L',ZI(JTABL+IOR-1))
        CALL JELIRA(CHAMPS//'.CESV','TYPE',IBID,ZK8(JTYPE+IOR-1))

        NOMGD = ZK8(JCESK-1+2)
        CALL DISMOI('F','TYPE_SCA',NOMGD,'GRANDEUR',IBID,TSCA,IBID)
        IF (TSCA.NE.'R') THEN
          CALL U2MESS('F','ALGORITH2_63')
        END IF

        TYPE = ZK8(JCESK-1+3)
        IF (TYPE(1:4).NE.'ELNO') THEN
          CALL U2MESS('F','PREPOST2_52')
        END IF

        IF (IOR.EQ.1) THEN
          JCESC = ZI(JTABC+IOR-1)
          JCESD = ZI(JTABD+IOR-1)
          JCESL = ZI(JTABL+IOR-1)
          NBMA = ZI(JCESD-1+1)
          NBCMP = ZI(JCESD-1+2)
          NCMPU = 0
          CALL WKVECT('&&IRGMCE.NOCMP','V V K8',NBCMP,JNCMP)
          DO 50,ICMP = 1,NBCMP
            DO 30,IMA = 1,NBMA
              NBPT = ZI(JCESD-1+5+4* (IMA-1)+1)
              NBSP = ZI(JCESD-1+5+4* (IMA-1)+2)
              DO 20,IPT = 1,NBPT
                DO 10,ISP = 1,NBSP
                  CALL CESEXI('C',JCESD,JCESL,IMA,IPT,ISP,ICMP,IAD)
                  IF (IAD.GT.0) GO TO 40
   10           CONTINUE
   20         CONTINUE
   30       CONTINUE
            GO TO 50
   40       CONTINUE
            NCMPU = NCMPU + 1
            ZK8(JNCMP+NCMPU-1) = ZK8(JCESC-1+ICMP)
   50     CONTINUE
        ELSE
          IF (ZI(ZI(JTABD+IOR-1)-1+2).NE.NBCMP) THEN
            CALL U2MESS('F','PREPOST2_53')
          END IF
        END IF

   60 CONTINUE

C --- RECUPERATION DU TABLEAU DE CORRESPONDANCE ENTRE NUMERO DES
C     NOUVELLES MAILLES ET NUMERO DE LA MAILLE INITIALE
C     CREE PAR IRGMMA
C
      CALL JEVEUO ( NUMOLD, 'L', JNUMOL )
      DO 101 I=1,NTYELE
         NBEL2(I)=0
101   CONTINUE
C
      TENS = .FALSE.
      VECT = .FALSE.
      SCAL = .FALSE.

C --- BOUCLE SUR LE NOMBRE DE COMPOSANTES DU CHAM_ELEM
C     *************************************************
      IF (NBCMPI.EQ.0) THEN
        NBCMPD = NBCMP
      ELSE
        NBCMPD = NBCMPI
      END IF

      IF (VERSIO.EQ.1) THEN
        TENS = .FALSE.
        SCAL = .TRUE.
        VECT = .FALSE.
      ELSEIF (VERSIO.EQ.2) THEN
        IF (TYCHA(1:4).EQ.'SCAL')THEN
          SCAL=.TRUE.
        ELSEIF (TYCHA(1:4).EQ.'TENS')THEN
          TENS=.TRUE.
        ELSEIF (TYCHA(1:4).EQ.'VECT')THEN
          VECT=.TRUE.
        ENDIF
      ENDIF

      IF(VERSIO.EQ.2 .AND. TENS)THEN
        LCMP=.FALSE.
        CALL WKVECT('&&IRGMCE.ORDRE_CMP','V V K8',NCMPME,JZCMP)
        DO 268 K=1,NCMPME
          ZK8(JZCMP+K-1)=' '
 268    CONTINUE 
        DO 269 K = 1,NBCMPD
            ZK8(JZCMP+K-1)=NOMCMP(K)
            ZK8(JZCMP+NCMPME/2+K-1)=ZK8(JNCMP+K-1)
            DO 61 IX = 1,NBCMP
              IF (ZK8(JNCMP+IX-1).EQ.NOMCMP(K)) THEN
                ICMP = IX
                GO TO 62
              END IF
   61       CONTINUE
            K8B = NOMCMP(K)
            CALL U2MESK('F','PREPOST2_54',1,K8B)
   62       CONTINUE
            IF(K.NE.IX) LCMP=.TRUE.  
 269    CONTINUE
        IF(LCMP)CALL U2MESK('A','PREPOST2_55',NCMPME,ZK8(JZCMP))
        CALL JEDETR('&&IRGMCE.ORDRE_CMP')
      ENDIF

      DO 270 K = 1,NBCMPD
        IF (NBCMPI.NE.0) THEN
          DO 70 IX = 1,NBCMP
            IF (ZK8(JNCMP+IX-1).EQ.NOMCMP(K)) THEN
              ICMP = IX
              GO TO 80
            END IF
   70     CONTINUE
          K8B = NOMCMP(K)
          CALL U2MESK('F','PREPOST2_54',1,K8B)
   80     CONTINUE
        ELSE
          ICMP = K
        END IF
        NOCMP = ZK8(JNCMP+ICMP-1)

C ----- PREMIER PASSAGE POUR DETERMINER SI LE CHAMP A ECRIRE EXISTE
C       SUR LES POI1, SEG2, TRIA3, TETR4...
C       DONC ON  N'ECRIT RIEN
        IWRI = .FALSE.

C ----- BOUCLE SUR LES ELEMENTS DANS L'ORDRE DONNE PAR IRGMOR
C
        DO 120 INE=1,NELETR
C         I=NUM DE L'ELEMENT DANS LE CATALOGUE
          I=TORD(INE)
          IF(NBEL(I).NE.0) THEN
            IADMM = 0
C           NBNO=NBRE DE NOEUDS DE CET ELEMENT
            NBNO  = TYPD(I,3)
            CALL JEVEUO(NOBJ(I),'L',JEL(I))
            DO 1201 IQ = 1,NBEL(I)
              IMA = ZI(JEL(I)-1+IQ)
              IPOIN = POINT(IMA)
              DO 1202 INOE = 1,NBNO
                LISTNO(INOE) = CONNX(IPOIN-1+INOE)
 1202       CONTINUE
             CALL IRGMEC(ZI(JNUMOL),IMA,CONNEX,NBORD2,ZI(JTABD),
     &                  ZI(JTABL),ZI(JTABV),PARTIE,JTYPE,NBNO,LISTNO,
     &                  ICMP,IFI,IWRI,IADMAX,ORDR,CHAMSY,NOMCON,
     &                  LRESU)
              IADMM = MAX(IADMAX,IADMM)
 1201       CONTINUE
            IF (IADMM.GT.0)  NBEL2(I) = NBEL(I)
          ENDIF
 120    CONTINUE
C
C
        IF (.NOT.TENS) THEN

C ----- ECRITURE DE L'ENTETE DE View
C       ****************************
        CALL IRGMPV ( IFI, LRESU, NOMCON, NOSIMP, NOPASE,
     &                CHAMSY, NBORD2, PARA, NOCMP, NBEL2,
     &                SCAL, VECT, TENS, VERSIO )
C
        IWRI = .TRUE.

C ----- BOUCLE SUR LES ELEMENTS DANS L'ORDRE DONNE PAR IRGMOR
C
        DO 130 INE=1,NELETR
C         I=NUM DE L'ELEMENT DANS LE CATALOGUE
          I=TORD(INE)
          IF(NBEL2(I).NE.0) THEN
C           NBNO=NBRE DE NOEUDS DE CET ELEMENT
            NBNO  = TYPD(I,3)
            CALL JEVEUO(NOBJ(I),'L',JEL(I))
            DO 1301 IQ = 1,NBEL(I)
              IMA = ZI(JEL(I)-1+IQ)
              IPOIN = POINT(IMA)
              DO 1302 INOE = 1,NBNO
                LISTNO(INOE) = CONNX(IPOIN-1+INOE)
 1302         CONTINUE
              DO 1303 J = 1,3
               WRITE(IFI,1000) (COORD(3*(LISTNO(INOE)-1)+J),INOE=1,NBNO)
 1303         CONTINUE
              CALL IRGMEC(ZI(JNUMOL),IMA,CONNEX,NBORD2,ZI(JTABD),
     &                    ZI(JTABL),ZI(JTABV),PARTIE,JTYPE,NBNO,
     &                    LISTNO,ICMP,IFI,IWRI,IADMAX,ORDR,
     &                    CHAMSY,NOMCON,LRESU)
 1301       CONTINUE
          ENDIF
 130    CONTINUE

C ----- FIN D'ECRITURE DE View
C       **********************
        WRITE (IFI,1010) '$EndView'

        ENDIF

  270 CONTINUE
C

      IF (TENS) THEN
C
C ----- VERIFICATION SUR LES COMPOSANTES FOURNIES PAR L'UTILISATEUR:
        DO 145 K=1,NBCMPI
          ICMP=INDIK8(ZK8(JNCMP),NOMCMP(K),1,NBCMP)
          IF(ICMP.EQ.0)THEN
            CALL U2MESK('F','PREPOST6_34',1,NOMCMP(K))
          ENDIF
 145    CONTINUE         
C
C ----- ECRITURE DE L'ENTETE DE View
C       ****************************
         NOCMP = 'TENSEUR'
         CALL IRGMPV ( IFI, LRESU, NOMCON, NOSIMP, NOPASE,
     &                 CHAMSY, NBORD2, PARA, NOCMP, NBEL2,
     &                 SCAL, VECT, TENS, VERSIO )
C
        IWRI = .TRUE.

C ----- BOUCLE SUR LES ELEMENTS DANS L'ORDRE DONNE PAR IRGMOR
C
        DO 140 INE=1,NELETR
C         I=NUM DE L'ELEMENT DANS LE CATALOGUE
          I=TORD(INE)
          IF(NBEL2(I).NE.0) THEN
C           NBNO=NBRE DE NOEUDS DE CET ELEMENT
            NBNO  = TYPD(I,3)
            CALL JEVEUO(NOBJ(I),'L',JEL(I))
            DO 1401 IQ = 1,NBEL(I)
              IMA = ZI(JEL(I)-1+IQ)
              IPOIN = POINT(IMA)
              DO 1402 INOE = 1,NBNO
                LISTNO(INOE) = CONNX(IPOIN-1+INOE)
 1402         CONTINUE
              DO 1403 J = 1,3
               WRITE(IFI,1000) (COORD(3*(LISTNO(INOE)-1)+J),INOE=1,NBNO)
 1403         CONTINUE
              CALL IRGME2(ZI(JNUMOL),IMA,CONNEX,NBORD2,ZI(JTABD),
     &             ZI(JTABL),ZI(JTABV),PARTIE,JTYPE,NBNO,LISTNO,
     &             NBCMP,IFI,IADMAX)
 1401       CONTINUE
          ENDIF
 140    CONTINUE

C ----- FIN D'ECRITURE DE View
C       **********************
        WRITE (IFI,1010) '$EndView'
C
      ENDIF

      CALL JEDETR('&&IRGMCE.CESC')
      CALL JEDETR('&&IRGMCE.CESD')
      CALL JEDETR('&&IRGMCE.CESV')
      CALL JEDETR('&&IRGMCE.CESL')
      CALL JEDETR('&&IRGMCE.NOCMP')
      CALL JEDETR('&&IRGMCG.TYPE')
      CALL JEDEMA()

 1000 FORMAT (1P,4(E15.8,1X))
 1010 FORMAT (A8)

      END
