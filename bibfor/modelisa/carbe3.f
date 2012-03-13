      SUBROUTINE CARBE3(CHARGE)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF MODELISA  DATE 13/03/2012   AUTEUR PELLET J.PELLET 
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
      IMPLICIT NONE
      CHARACTER*8 CHARGE
C TOLE CRP_20
C
C     TRAITER LE MOT CLE LIAISON_RBE3 DE AFFE_CHAR_MECA
C     ET ENRICHIR LA CHARGE (CHARGE) AVEC LES RELATIONS LINEAIRES
C IN/JXVAR : CHARGE : NOM D'UNE SD CHARGE
C ----------------------------------------------------------------------
C     ----------- COMMUNS NORMALISES  JEVEUX  --------------------------
      INTEGER ZI
      INTEGER VALI(2)
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
      CHARACTER*32 JEXNOM,JEXNUM
C---------------- FIN COMMUNS NORMALISES  JEVEUX  ----------------------

      CHARACTER*1  K1BID
      CHARACTER*2  TYPLAG
      CHARACTER*4  TYPCOE,TYPVAL,TYPCO2
      CHARACTER*7  TYPCHA
      CHARACTER*8  K8BID,MODE,NOMA,NOMRES,GROMAI,NOEMAI,NOMNOE,DDLTRR(6)
      CHARACTER*8  DDLCOD,DDLMAC(6),BETAF,NUMLAG
      CHARACTER*15 COORDO
      CHARACTER*16 MOTFAC,CONCEP,NOMCMD
      CHARACTER*19 LISREL
      CHARACTER*24 DDLSTR,GROUNO,NOEUMA
      COMPLEX*16   BETAC
      INTEGER      IFM,NIV,IBID,IARG,IER,IRET
      INTEGER      IDXRBE,IDXLIG,IDXCOL,IDXVEC,IDXNOE,IDXGRO,IDXTER
      INTEGER      POSESC,POSMAI,CNTLIG,CNTDDL,CNTNOE,INILIG
      INTEGER      JCOOR,JLISES,JCOFES,JDDLES,JCESCL,JCOORE,JW,JS,JB
      INTEGER      JLISRE,JNOREL,JDDL,JCMUR,JCMUC,JCMUF,JDIREC,JDIME
      INTEGER      JNOGRO,JNOESC,JXAB
      INTEGER      NBRBE3,NBDLES,NBCFES,NBDDL,NBLIGN,NBCOL,NBGROU,NBENT
      INTEGER      NBNOEU,NBDLMA,MAXESC,MAXLES,MAXDDL,DIME
      INTEGER      LXLGUT
      LOGICAL      FINCOD,DDLESC(6),DDLMAI(6),FRSTCO,DIME2D
      REAL*8       RBID,COOMAI(3),COOESC(3),LC,NORME,LCSQUA,STWS(6,6)
      REAL*8       COFESC,BETA,X(6,6)
C ----------------------------------------------------------------------

      CALL JEMARQ()

      CALL INFNIV(IFM,NIV)

      MOTFAC = 'LIAISON_RBE3    '
      BETAC = (1.0D0,0.0D0)
      TYPCOE = 'REEL'
      TYPVAL = 'REEL'
      DDLTRR(1) = 'DX'
      DDLTRR(2) = 'DY'
      DDLTRR(3) = 'DZ'
      DDLTRR(4) = 'DRX'
      DDLTRR(5) = 'DRY'
      DDLTRR(6) = 'DRZ'

      CALL GETFAC(MOTFAC,NBRBE3)

      IF (NIV.EQ.2) THEN
        WRITE(IFM,*) 'NOMBRE RELATIONS RBE3 : ',NBRBE3
      ENDIF

      IF (NBRBE3.EQ.0) GO TO 9999

      CALL GETRES(NOMRES,CONCEP,NOMCMD)
      CALL DISMOI('F','TYPE_CHARGE',CHARGE,'CHARGE',IBID,TYPCHA,IER)
      CALL DISMOI('F','NOM_MODELE',CHARGE,'CHARGE',IBID,MODE,IER)
      CALL DISMOI('F','DIM_GEOM',MODE,'MODELE',DIME,K8BID,IER)
      DIME2D=(DIME.EQ.2)
      IF (NIV.EQ.2) THEN
        WRITE(IFM,*) 'MODELE 2D : ',DIME2D
      ENDIF

      CALL DISMOI('F','NOM_MAILLA',CHARGE,'CHARGE',IBID,NOMA,IER)

      NOEUMA = NOMA//'.NOMNOE'
      GROUNO = NOMA//'.GROUPENO'
      COORDO = NOMA//'.COORDO'
      CALL JEVEUO(COORDO//'    .VALE','L',JCOOR)

C     -- CALCUL DE MAXLES : NBRE DE TERMES MAXI D'UNE LISTE
C        DE GROUP_NO_ESCL OU DE NOEUD_ESCL
C        --------------------------------------------------
      MAXLES = 0
      DO 10 IDXRBE = 1,NBRBE3
        CALL GETVEM(NOMA,'GROUP_NO',MOTFAC,'GROUP_NO_ESCL',IDXRBE,
     &              IARG,0,K8BID,NBGROU)
        MAXLES = MAX(MAXLES,-NBGROU)
        CALL GETVEM(NOMA,'NOEUD',MOTFAC,'NOEUD_ESCL',IDXRBE,IARG,0,
     &              K8BID,NBNOEU)
        MAXLES = MAX(MAXLES,-NBNOEU)
   10 CONTINUE

      IF (MAXLES.EQ.0) THEN
        CALL U2MESS('F', 'MODELISA10_7')
      END IF
      CALL WKVECT('&&CARBE3.LISTESCL','V V K8',MAXLES,JLISES)

C     -- CALCUL DE MAXDDL ET VERIFICATION DES NOEUDS ET GROUP_NO
C        MAXDDL EST LE NOMBRE MAXI DE NOEUDS IMPLIQUES DANS UNE
C        RELATION LINEAIRE
C        -------------------------------------------------------
      MAXDDL = 0
      MAXESC = 0
      DO 40 IDXRBE=1,NBRBE3

        CALL GETVTX(MOTFAC,'GROUP_NO_ESCL',IDXRBE,IARG,MAXLES,
     &              ZK8(JLISES),NBGROU)
        IF (NBGROU.NE.0) THEN
          DO 100 IDXGRO = 1,NBGROU
            CALL JELIRA(JEXNOM(GROUNO,ZK8(JLISES-1+IDXGRO)),'LONUTI',
     &                  NBNOEU,K1BID)
            IF (NBNOEU.EQ.0) THEN
              CALL U2MESK('F', 'MODELISA10_8', 1, ZK8(JLISES-1+IDXGRO))
            ENDIF
            MAXESC = MAX(MAXESC, NBNOEU)
  100     CONTINUE
        ELSE
          CALL GETVTX(MOTFAC,'NOEUD_ESCL',IDXRBE,IARG,0,K8BID,NBNOEU)
          NBNOEU = -NBNOEU
          MAXESC = MAX(MAXESC, NBNOEU)
        ENDIF

        CNTDDL = 1
        CNTDDL = CNTDDL + MAXESC * 6
        MAXDDL = MAX(MAXDDL,CNTDDL)
   40 CONTINUE

C     -- ALLOCATION DES TABLEAUX DE TRAVAIL
C     -------------------------------------
      LISREL = '&&CARBE3.RLLISTE'
      CALL WKVECT('&&CARBE3.LISNOREL','V V K8',MAXDDL,JNOREL)
      CALL WKVECT('&&CARBE3.LISNOESC','V V K8',MAXESC,JNOESC)
      CALL WKVECT('&&CARBE3.DDL  ','V V K8',MAXDDL,JDDL)
      CALL WKVECT('&&CARBE3.COEMUR','V V R',MAXDDL,JCMUR)
      CALL WKVECT('&&CARBE3.COEMUC','V V C',MAXDDL,JCMUC)
      CALL WKVECT('&&CARBE3.COEMUF','V V K8',MAXDDL,JCMUF)
      CALL WKVECT('&&CARBE3.DIRECT','V V R',3*MAXDDL,JDIREC)
      CALL WKVECT('&&CARBE3.DIMENSION','V V I',MAXDDL,JDIME)
      CALL WKVECT('&&CARBE3.CESCL','V V L',MAXESC*6,JCESCL)
      CALL WKVECT('&&CARBE3.COEFES','V V R',MAXESC,JCOFES)
      CALL WKVECT('&&CARBE3.COOREL','V V R',MAXESC*3,JCOORE)
      CALL WKVECT('&&CARBE3.DDLESCL','V V K24',MAXESC,JDDLES)

C     BOUCLE SUR LES RELATIONS RBE3
C     -----------------------------------
      DO 80 IDXRBE=1,NBRBE3
        IF (NIV.EQ.2) THEN
          WRITE(IFM,*) 'INDEX RELATION RBE3 : ',IDXRBE
        ENDIF

        CALL GETVTX(MOTFAC,'GROUP_NO_MAIT',IDXRBE,IARG,0,K8BID,NBENT)
        NBENT = -NBENT
        IF (NBENT.NE.0) THEN
          CALL GETVEM(NOMA,'GROUP_NO',MOTFAC,'GROUP_NO_MAIT',IDXRBE,
     &                IARG,1,GROMAI,NBENT)
          CALL JEVEUO(JEXNOM(GROUNO,GROMAI),'L',JNOGRO)
          CALL JELIRA(JEXNOM(GROUNO,GROMAI),'LONUTI',NBENT,K1BID)
          IF (NBENT.NE.1) THEN
            CALL U2MESG('F', 'MODELISA10_9', 1, GROMAI, 1, NBENT, 
     &                  0, RBID)
          ENDIF
          CALL JENUNO(JEXNUM(NOEUMA,ZI(JNOGRO-1+1)),NOEMAI)
        ENDIF

        CALL GETVTX(MOTFAC,'NOEUD_MAIT',IDXRBE,IARG,0,K8BID,NBENT)
        IF (NBENT.NE.0) THEN
          CALL GETVEM(NOMA,'NOEUD',MOTFAC,'NOEUD_MAIT',IDXRBE,IARG,1,
     &                NOEMAI,NBENT)
        ENDIF

        IDXTER = 1
        ZK8(JNOREL-1+IDXTER) = NOEMAI
        ZR(JCMUR-1+IDXTER) = -1.0D0
        ZK8(JNOREL+1) = NOEMAI
        CALL JENONU(JEXNOM(NOMA//'.NOMNOE',NOEMAI),POSMAI)
        COOMAI(1) = ZR(JCOOR-1+3*(POSMAI-1)+1)
        COOMAI(2) = ZR(JCOOR-1+3*(POSMAI-1)+2)
        COOMAI(3) = ZR(JCOOR-1+3*(POSMAI-1)+3)
        IF (NIV.EQ.2) THEN
          WRITE(IFM,*) 'COORDS : ',COOMAI, ' DU NOEUD MAITRE : ',NOEMAI
        ENDIF

        CALL GETVTX(MOTFAC,'DDL_MAIT',IDXRBE,IARG,6,DDLMAC,NBDLMA)

        DO 500 IDXLIG=1,6
          DDLMAI(IDXLIG) = .FALSE.
  500   CONTINUE

        DO 510 IDXLIG=1,NBDLMA
          DDLCOD = DDLMAC(IDXLIG)(1:LXLGUT(DDLMAC(IDXLIG)))
          IF (DDLTRR(1).EQ.DDLCOD) THEN
            DDLMAI(1) = .TRUE.
          ELSE IF (DDLTRR(2).EQ.DDLCOD) THEN
            DDLMAI(2) = .TRUE.
          ELSE IF (DDLTRR(3).EQ.DDLCOD) THEN
            DDLMAI(3) = .TRUE.
          ELSE IF (DDLTRR(4).EQ.DDLCOD) THEN
            DDLMAI(4) = .TRUE.
          ELSE IF (DDLTRR(5).EQ.DDLCOD) THEN
            DDLMAI(5) = .TRUE.
          ELSE IF (DDLTRR(6).EQ.DDLCOD) THEN
            DDLMAI(6) = .TRUE.
          ENDIF          
  510   CONTINUE

        CALL GETVTX(MOTFAC,'GROUP_NO_ESCL',IDXRBE,IARG,0,K8BID,NBGROU)
        IF (NBGROU.NE.0) THEN
          NBGROU = -NBGROU
          NBNOEU = 0
          CALL GETVTX(MOTFAC,'GROUP_NO_ESCL',IDXRBE,IARG,NBGROU,
     &                ZK8(JLISES),NBENT)
          CNTNOE = 0
          DO 70 IDXGRO = 1,NBGROU
            CALL JEVEUO(JEXNOM(GROUNO,ZK8(JLISES-1+IDXGRO)),'L',JNOGRO)
            CALL JELIRA(JEXNOM(GROUNO,ZK8(JLISES-1+IDXGRO)),'LONUTI',
     &                  NBENT,K1BID)
            NBNOEU = NBNOEU + NBENT
            DO 60 IDXNOE = 1,NBENT
              CNTNOE = CNTNOE + 1
              CALL JENUNO(JEXNUM(NOEUMA,ZI(JNOGRO-1+IDXNOE)),NOMNOE)
              ZK8(JNOESC+CNTNOE-1) = NOMNOE
   60       CONTINUE
   70     CONTINUE
        ENDIF

        CALL GETVTX(MOTFAC,'NOEUD_ESCL',IDXRBE,IARG,0,K8BID,NBENT)
        IF (NBENT.NE.0) THEN
          NBNOEU = -NBENT
          CALL GETVTX(MOTFAC,'NOEUD_ESCL',IDXRBE,IARG,NBNOEU,
     &                ZK8(JNOESC),NBENT)
        ENDIF

        IF (NIV.EQ.2) THEN
          WRITE(IFM,*) 'LISTE DES ',NBNOEU, ' NOEUDS ESCLAVES'
          WRITE(IFM,*) (ZK8(JNOESC+IDXLIG-1),IDXLIG=1,NBNOEU)
        ENDIF

        CALL GETVTX(MOTFAC,'DDL_ESCL',IDXRBE,IARG,NBNOEU,ZK24(JDDLES),
     &              NBDDL)

        IF (NBDDL.NE.1 .AND. NBDDL.NE.NBNOEU) THEN
          VALI(1) = NBDDL
          VALI(2) = NBNOEU
          CALL U2MESI('F', 'MODELISA10_10', 2, VALI)
        ENDIF

C       BOUCLE SUR LES NOEUDS ESCLAVES POUR EXTRAIRE LES DDLS
C       -----------------------------------------------------
        NBDLES = 0
        DO 110 IDXNOE=1,NBNOEU
          IF (NBDDL.GT.1 .OR. IDXNOE.EQ.1) THEN
            IF (NBDDL.EQ.1) THEN
              DDLSTR = ZK24(JDDLES-1+1)
            ELSE
              DDLSTR = ZK24(JDDLES-1+1)
            ENDIF

C           EXTRACTION DDL_ESCL
C           -------------------------------------------------------
            DO 200 IDXLIG=1,6
              DDLESC(IDXLIG) = .FALSE.
  200       CONTINUE

            IDXCOL = 1
            DO 210 IDXLIG=1,LXLGUT(DDLSTR)
              IF (DDLSTR(IDXLIG:IDXLIG).EQ.'-') THEN
                DDLCOD = DDLSTR(IDXCOL:IDXLIG-1)
                IDXCOL = IDXLIG + 1
                FINCOD = .TRUE.
              ELSE IF (IDXLIG.EQ.LXLGUT(DDLSTR)) THEN
                DDLCOD = DDLSTR(IDXCOL:IDXLIG)
                FINCOD = .TRUE.
              ELSE
                FINCOD = .FALSE.
              ENDIF
              IF (FINCOD) THEN
                IF (DDLTRR(1).EQ.DDLCOD) THEN
                  DDLESC(1) = .TRUE.
                ELSE IF (DDLTRR(2).EQ.DDLCOD) THEN
                  DDLESC(2) = .TRUE.
                ELSE IF (DDLTRR(3).EQ.DDLCOD) THEN
                  DDLESC(3) = .TRUE.
                ELSE IF (DDLTRR(4).EQ.DDLCOD) THEN
                  DDLESC(4) = .TRUE.
                ELSE IF (DDLTRR(5).EQ.DDLCOD) THEN
                  DDLESC(5) = .TRUE.
                ELSE IF (DDLTRR(6).EQ.DDLCOD) THEN
                  DDLESC(6) = .TRUE.
                ELSE
                  CALL U2MESK('F', 'MODELISA10_11', 1, DDLCOD)
                ENDIF
              ENDIF
  210       CONTINUE
          ENDIF
          DO 215 IDXLIG=1,6
            IF (DDLESC(IDXLIG)) THEN
              NBDLES = NBDLES + 1
              ZK8(JNOREL-1+1+NBDLES) = ZK8(JNOESC-1+IDXNOE)
              ZK8(JDDL-1+1+NBDLES) = DDLTRR(IDXLIG)
            ENDIF
            ZL(JCESCL+(IDXNOE-1)*6+IDXLIG) = DDLESC(IDXLIG)
  215     CONTINUE
  110   CONTINUE
        IF (NIV.EQ.2) THEN
          WRITE (IFM,*) 'NOMBRE DDL NOEUDS ESCLAVES : ',NBDLES
        ENDIF

C       BOUCLE SUR LES NOEUDS ESCLAVES POUR CALCULER Lc
C       -----------------------------------------------
        LC = 0
        DO 120 IDXNOE=1,NBNOEU
          CALL JENONU(JEXNOM(NOMA//'.NOMNOE',ZK8(JNOESC-1+IDXNOE)),
     &                POSESC)
          COOESC(1) = ZR(JCOOR-1+3*(POSESC-1)+1)
          COOESC(2) = ZR(JCOOR-1+3*(POSESC-1)+2)
          COOESC(3) = ZR(JCOOR-1+3*(POSESC-1)+3)
          ZR(JCOORE-1+3*(IDXNOE-1)+1) = COOESC(1) - COOMAI(1)
          ZR(JCOORE-1+3*(IDXNOE-1)+2) = COOESC(2) - COOMAI(2)
          ZR(JCOORE-1+3*(IDXNOE-1)+3) = COOESC(3) - COOMAI(3)
          NORME=ZR(JCOORE-1+3*(IDXNOE-1)+1)*ZR(JCOORE-1+3*(IDXNOE-1)+1)+
     &          ZR(JCOORE-1+3*(IDXNOE-1)+2)*ZR(JCOORE-1+3*(IDXNOE-1)+2)+
     &          ZR(JCOORE-1+3*(IDXNOE-1)+3)*ZR(JCOORE-1+3*(IDXNOE-1)+3)
          IF(NORME.NE.0.0D0) THEN
            NORME = SQRT(NORME)
          ENDIF
          LC = LC + NORME
  120   CONTINUE
        LC = LC / NBNOEU
        IF (NIV.EQ.2) THEN
          WRITE(IFM,*) 'LC : ',LC
        ENDIF
        LCSQUA = LC * LC

C       BOUCLE SUR LES NOEUDS ESCLAVES POUR CALCULER W
C       -------------------------------------------------------
        CALL WKVECT('&&CARBE3.W','V V R',NBDLES*NBDLES,JW)
        CALL GETVR8(MOTFAC,'COEF_ESCL',IDXRBE,IARG,NBNOEU,ZR(JCOFES),
     &              NBCFES)
        IF (NBCFES.LT.0) THEN
          NBCFES = -NBCFES
        ENDIF

        IF (NBDDL.NE.1 .AND. NBCFES.NE.1 .AND. NBDDL.NE.NBCFES) THEN
          VALI(1) = NBDDL
          VALI(2) = NBCFES
          CALL U2MESI('F', 'MODELISA10_12', 2, VALI)
        ENDIF

        IF (NBCFES.NE.1 .AND. NBDDL.NE.NBNOEU) THEN
          VALI(1) = NBDDL
          VALI(2) = NBNOEU
          CALL U2MESI('F', 'MODELISA10_13', 2, VALI)
        ENDIF

        NBCOL = 0
        INILIG = 0
        DO 130 IDXNOE=1,NBNOEU
          IF (NBCFES.EQ.1) THEN
            COFESC = ZR(JCOFES-1+1)
          ELSE
            COFESC = ZR(JCOFES-1+IDXNOE)
          ENDIF

          FRSTCO = .TRUE.
          CNTLIG = 0
          DO 220 IDXCOL=1,6
            IF (ZL(JCESCL+(IDXNOE-1)*6+IDXCOL)) THEN
              NBCOL = NBCOL + 1
              NBLIGN = INILIG
              DO 300 IDXLIG=1,6
                IF (ZL(JCESCL+(IDXNOE-1)*6+IDXLIG)) THEN
                  NBLIGN = NBLIGN + 1
                  IF (FRSTCO) THEN
                    CNTLIG = CNTLIG + 1
                  ENDIF
                  IDXVEC = NBDLES*(NBCOL-1)+NBLIGN
                  IF (IDXLIG.NE.IDXCOL) THEN
                    ZR(JW-1+IDXVEC) = 0.0D0
                  ELSE IF (IDXCOL.LE.3) THEN
                    ZR(JW-1+IDXVEC) = COFESC
                  ELSE
                    ZR(JW-1+IDXVEC) = COFESC * LCSQUA
                  ENDIF
                ENDIF
  300         CONTINUE
              FRSTCO = .FALSE.
            ENDIF
  220     CONTINUE
          INILIG = INILIG + CNTLIG
  130   CONTINUE

        IF (NIV.EQ.2) THEN
          WRITE (IFM,*) 'IMPRESSION W'
          DO 750 IDXLIG=1,NBDLES
            WRITE (IFM,*) 'LIGNE : ',IDXLIG,
     &       (ZR(JW-1+IDXLIG+NBDLES*(IDXCOL-1)),IDXCOL=1,NBDLES)
  750   CONTINUE
        ENDIF

C       BOUCLE SUR LES NOEUDS ESCLAVES POUR CALCULER S
C       -------------------------------------------------------
        NBLIGN = 0
        INILIG = 0
        CALL WKVECT('&&CARBE3.S','V V R',NBDLES*6,JS)
        DO 140 IDXNOE=1,NBNOEU
          FRSTCO = .TRUE.
          CNTLIG = 0
          DO 230 IDXCOL=1,6
            NBLIGN = INILIG
            DO 400 IDXLIG=1,6
              IF (ZL(JCESCL+(IDXNOE-1)*6+IDXLIG)) THEN
                NBLIGN = NBLIGN + 1
                IF (FRSTCO) THEN
                  CNTLIG = CNTLIG + 1
                ENDIF
                IDXVEC = NBDLES*(IDXCOL-1)+NBLIGN
                IF ((IDXLIG.LE.3 .AND. IDXCOL.LE.3) .OR.
     &              (IDXLIG.GE.4 .AND. IDXCOL.GE.4)) THEN
                  IF (IDXLIG.EQ.IDXCOL) THEN
                    ZR(JS-1+IDXVEC) = 1.0D0
                  ELSE
                    ZR(JS-1+IDXVEC) = 0.0D0
                  ENDIF
                ELSE IF (IDXLIG.GE.4 .AND. IDXCOL.LE.3) THEN
                  ZR(JS-1+IDXVEC) = 0.0D0
                ELSE
                  IF (IDXLIG.EQ.1 .AND. IDXCOL.EQ.5) THEN
                    ZR(JS-1+IDXVEC) = ZR(JCOORE-1+3*(IDXNOE-1)+3)
                  ELSE IF (IDXLIG.EQ.1 .AND. IDXCOL.EQ.6) THEN
                    ZR(JS-1+IDXVEC) = -ZR(JCOORE-1+3*(IDXNOE-1)+2)
                  ELSE IF (IDXLIG.EQ.2 .AND. IDXCOL.EQ.4) THEN
                    ZR(JS-1+IDXVEC) = -ZR(JCOORE-1+3*(IDXNOE-1)+3)
                  ELSE IF (IDXLIG.EQ.2 .AND. IDXCOL.EQ.6) THEN
                    ZR(JS-1+IDXVEC) = ZR(JCOORE-1+3*(IDXNOE-1)+1)
                  ELSE IF (IDXLIG.EQ.3 .AND. IDXCOL.EQ.4) THEN
                    ZR(JS-1+IDXVEC) = ZR(JCOORE-1+3*(IDXNOE-1)+2)
                  ELSE IF (IDXLIG.EQ.3 .AND. IDXCOL.EQ.5) THEN
                    ZR(JS-1+IDXVEC) = -ZR(JCOORE-1+3*(IDXNOE-1)+1)
                  ELSE
                    ZR(JS-1+IDXVEC) = 0.0D0
                  ENDIF
                ENDIF
              ENDIF
  400       CONTINUE
            FRSTCO = .FALSE.
  230     CONTINUE
          INILIG = INILIG + CNTLIG
  140   CONTINUE

        IF (NIV.EQ.2) THEN
          WRITE (IFM,*) 'IMPRESSION S'
          DO 800 IDXLIG=1,NBDLES
            WRITE (IFM,*) 'LIGNE : ',IDXLIG,
     &       (ZR(JS-1+IDXLIG+NBDLES*(IDXCOL-1)),IDXCOL=1,6)
  800   CONTINUE
        ENDIF

        CALL WKVECT('&&CARBE3.XAB','V V R',NBDLES*6,JXAB)
        CALL UTBTAB('ZERO',NBDLES,6,ZR(JW),ZR(JS),ZR(JXAB),STWS)

        IF (NIV.EQ.2) THEN
          WRITE (IFM,*) 'IMPRESSION MATRICE MGAUSS'
          DO 850 IDXLIG=1,6
            WRITE (IFM,*) 'LIGNE : ', IDXLIG, 
     &       (STWS(IDXCOL, IDXLIG),IDXCOL=1,6)
  850     CONTINUE
        ENDIF

        DO 240 IDXLIG=1,6
          DO 410 IDXCOL=1,6
            IF (IDXCOL.EQ.IDXLIG) THEN
              X(IDXCOL, IDXLIG) = 1.0D0
            ELSE
              X(IDXCOL, IDXLIG) = 0.0D0
            ENDIF
  410     CONTINUE
  240   CONTINUE

        CALL MGAUSS('NFSP',STWS,X,6,6,6,RBID,IRET)

        IF (IRET.NE.0) THEN
          CALL U2MESS('F', 'MODELISA10_6')
        END IF

        IF (NIV.EQ.2) THEN
          WRITE (IFM,*) 'IMPRESSION MATRICE X'
          DO 900 IDXLIG=1,6
            WRITE (IFM,*) 'LIGNE : ',IDXLIG,
     &       (X(IDXCOL, IDXLIG),IDXCOL=1,6)
  900     CONTINUE
        ENDIF

        CALL PMPPR(ZR(JS),NBDLES,6,-1,ZR(JW),NBDLES,NBDLES,-1,
     &              ZR(JXAB),6,NBDLES)

        CALL JEDETR('&&CARBE3.W')
        CALL JEDETR('&&CARBE3.S')

        CALL WKVECT('&&CARBE3.B','V V R',NBDLES*6,JB)

        CALL PMPPR(X,6,6,-1,ZR(JXAB),6,NBDLES,1,ZR(JB),6,NBDLES)

        CALL JEDETR('&&CARBE3.XAB')

C --- ON REGARDE SI LES MULTIPLICATEURS DE LAGRANGE SONT A METTRE
C --- APRES LES NOEUDS PHYSIQUES LIES PAR LA RELATION DANS LA MATRICE
C --- ASSEMBLEE :
C --- SI OUI TYPLAG = '22'
C --- SI NON TYPLAG = '12'

        CALL GETVTX(MOTFAC,'NUME_LAGR',IDXRBE,IARG,0,K8BID,NBENT)

        IF (NBENT.NE.0) THEN
          CALL GETVTX(MOTFAC,'NUME_LAGR',IDXRBE,IARG,1,NUMLAG,NBENT)
          IF (NUMLAG(1:5).EQ.'APRES') THEN
            TYPLAG = '22'
          ELSE
            TYPLAG = '12'
          ENDIF
        ELSE
          TYPLAG = '12'
        ENDIF

        DO 250 IDXLIG=1,6
          IF (DDLMAI(IDXLIG)) THEN
            IDXTER = 1
            ZK8(JDDL-1+IDXTER) = DDLTRR(IDXLIG)
            DO 420 IDXCOL=1,NBDLES
              IDXTER = IDXTER + 1
              ZR(JCMUR-1+IDXTER) = ZR(JB-1+6*(IDXCOL-1)+IDXLIG)
  420       CONTINUE
          CALL AFRELA(ZR(JCMUR),ZC(JCMUC),ZK8(JDDL),ZK8(JNOREL),
     &           ZI(JDIME),ZR(JDIREC),1+NBDLES,BETA,BETAC,BETAF,TYPCOE,
     &           TYPVAL,TYPLAG,0.D0,LISREL)
          ENDIF
  250   CONTINUE

        CALL JEDETR('&&CARBE3.B')


   80 CONTINUE

C     -- AFFECTATION DE LA LISTE_RELA A LA CHARGE :
C     ---------------------------------------------
      CALL AFLRCH(LISREL,CHARGE)

 9999 CONTINUE
      CALL JEDEMA()
      END
