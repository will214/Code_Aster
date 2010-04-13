      SUBROUTINE NMOP45(MATRIG,MATGEO,DEFO  ,OPTION,NFREQ ,BANDE ,
     &                  MOD45 ,DDL, NDDLE, MODES)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGELINE  DATE 12/04/2010   AUTEUR MICHEL S.MICHEL 
C ======================================================================
C COPYRIGHT (C) 1991 - 2003  EDF R&D                  WWW.CODE-ASTER.ORG
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
C TOLE CRP_20
C
      IMPLICIT NONE
      CHARACTER*4  MOD45
      CHARACTER*19 MATRIG,MATGEO
      INTEGER      DEFO,NFREQ
      CHARACTER*16 OPTION
      REAL*8       BANDE(2)
      CHARACTER*8  MODES
      INTEGER      NDDLE
      CHARACTER*8  DDL(NDDLE)            
C
C ======================================================================
C        MODE_ITER_SIMULT
C        RECHERCHE DE MODES PAR ITERATION SIMULTANEE EN SOUS-ESPACE
C-----------------------------------------------------------------------
C        - POUR LE PROBLEME GENERALISE AUX VALEURS PROPRES :
C                         2
C                        L (M) Y  + (K) Y = 0

C          LES MATRICES (K) ET (M) SONT REELLES SYMETRIQUES
C          LES VALEURS PROPRES ET DES VECTEURS PROPRES SONT REELS

C     ------------------------------------------------------------------
C     APPLICATION DE LA METHODE DE LANCZOS (VARIANTE DE NEUMANN-PIPANO)
C     POUR CONSTRUIRE UNE MATRICE TRIDIAGONALE D'ORDRE REDUIT DE MEME
C     VALEURS PROPRES QUE LE PROBLEME INITIAL (EVENTUELLEMENT DECALE)

C
C -------------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ----------------
C
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
C
C -------------- FIN  DECLARATIONS  NORMALISEES  JEVEUX ----------------
C
      INTEGER NBPARI,NBPARR,NBPARK,MXDDL,NBPARA
      PARAMETER (NBPARI=8,NBPARR=16,NBPARK=3,NBPARA=27)
      PARAMETER (MXDDL=1)
      INTEGER INDF,ISNNEM,IMET,I,IEQ,IRET,
     &        IER1,IBID,IERD,IFREQ,IER
      INTEGER LSELEC,LRESID,LAMOR,LMASSE,LMTPSC,LRESUR,
     &        LWORKD,LAUX,LRAIDE,LWORKL,
     &        LRESUI,LWORKV,LPROD,LRESUK,LDDL,EDDL,
     &        LMATRA,LONWL,ITYP,IORDRE,NBVEC2,ICOEF
      INTEGER NPIVOT,NBVECT,PRIRAM(8),MAXITR,NEQACT,MFREQ,
     &        NPARR,NBCINE,NBRSS,MXRESF,NBLAGR,
     &        NPREC,NCONV
      INTEGER IFM,NIV,NBDDL
      CHARACTER*1 KTYP
      REAL*8 OMEGA2,ALPHA,TOLSOR,UNDF,R8VIDE,
     &       FREQOM,OMEMIN,OMEMAX,OMESHI,OMECOR,PRECDC,
     &       VPINF,PRECSH,VPMAX
      COMPLEX*16 CBID
      CHARACTER*8  KNEGA,METHOD,CHAINE
      CHARACTER*16 TYPCON,TYPRES
      CHARACTER*19 MATPSC,MATOPA,NUMEDD
      INTEGER      LDSOR,LVEC,NEQ
      CHARACTER*24 NOPARA(NBPARA)
      LOGICAL STURM,FLAGE,LBID
C     ------------------------------------------------------------------
      DATA  NOPARA /
     &  'NUME_MODE'       , 'ITER_QR'         , 'ITER_BATHE'      ,
     &  'ITER_ARNO'       , 'ITER_JACOBI'     , 'ITER_SEPARE'     ,
     &  'ITER_AJUSTE'     , 'ITER_INVERSE'    ,
     &  'NORME'           , 'METHODE'         , 'TYPE_MODE'       ,
     &  'FREQ'            ,
     &  'OMEGA2'          , 'AMOR_REDUIT'     , 'ERREUR'          ,
     &  'MASS_GENE'       , 'RIGI_GENE'       , 'AMOR_GENE'       ,
     &  'MASS_EFFE_DX'    , 'MASS_EFFE_DY'    , 'MASS_EFFE_DZ'    ,
     &  'FACT_PARTICI_DX' , 'FACT_PARTICI_DY' , 'FACT_PARTICI_DZ' ,
     &  'MASS_EFFE_UN_DX' , 'MASS_EFFE_UN_DY' , 'MASS_EFFE_UN_DZ' /
C     ------------------------------------------------------------------


C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
      CALL INFDBG('MECA_NON_LINE',IFM,NIV)
C
C --- INITIALISATIONS
C
      OMECOR = OMEGA2(1.D-2)
      PRECSH = 5.D-2
      PRECDC = 5.D-2
      FLAGE  = .FALSE.
      UNDF   = R8VIDE()
      INDF   = ISNNEM()
      METHOD = 'SORENSEN'
      TYPRES = 'MODE_FLAMB'
      IF ( MOD45 .EQ. 'VIBR' ) TYPRES = 'DYNAMIQUE'
      NPREC = 8
      NBRSS = 5
      NCONV = NFREQ
      NBVECT = 100
      NBVEC2 = 0
      LAMOR = 0
      OMEMIN = BANDE(1)
      OMEMAX = BANDE(2)
C
C --- RECUPERATION DU RESULTAT
C
      TYPCON = 'MODE_FLAMB'
      IF ( MOD45 .EQ. 'VIBR' ) TYPCON = 'MODE_MECA'



C     --- TEST DU TYPE (COMPLEXE OU REELLE) DE LA MATRICE DE RAIDEUR ---
      CALL JELIRA(MATRIG//'.VALM','TYPE',IBID,KTYP)

C     --- RECUPERATION DE LA NUMEROTATION DE LA MATRICE DE RAIDEUR ---
      CALL DISMOI('F','NOM_NUME_DDL',MATRIG,'MATR_ASSE',IBID,
     &              NUMEDD,IRET)

C     --- COMPATIBILITE DES MODES (DONNEES ALTEREES) ---s

C------------------a remettre------------------------------
C
      CALL VPCREA(0,MODES,MATGEO,' ',MATRIG,NUMEDD,IER1)
C------------------------------------------------------------


C     --- VERIFICATION DES "REFE" ---
      IF (OPTION.EQ.'BANDE') THEN
        CALL VRREFE(MATGEO,MATRIG,IRET)
      END IF

C     --- DESCRIPTEUR DES MATRICES ---
      CALL MTDSCR(MATGEO)
      CALL JEVEUO(MATGEO(1:19)//'.&INT','E',LMASSE)

      CALL MTDSCR(MATRIG)
      CALL JEVEUO(MATRIG(1:19)//'.&INT','E',LRAIDE)
C     --- NOMBRE D'EQUATIONS ---
      NEQ = ZI(LRAIDE+2)

C     ------------------------------------------------------------------
C     ----------- DDL : LAGRANGE, BLOQUE PAR AFFE_CHAR_CINE  -----------
C     ------------------------------------------------------------------

      CALL WKVECT('&&NMOP45.POSITION.DDL','V V I',NEQ*MXDDL,LDDL)
      CALL WKVECT('&&NMOP45.DDL.BLOQ.CINE','V V I',NEQ,LPROD)

      CALL VPDDL(MATRIG,MATGEO,NEQ,NBLAGR,NBCINE,NEQACT,ZI(LDDL),
     &           ZI(LPROD),IERD)
      IF (IERD.NE.0) GO TO 80

C     --- CREATION DE LA MATRICE DYNAMIQUE ET DE SA FACTORISEE ---

      MATPSC = '&&NMOP45.DYN_FAC_R '
      MATOPA = '&&NMOP45.DYN_FAC_C '

C     --- CREATION / AFFECTATION DES MATRICES DYNAMIQUES  ---


C     --- PROBLEME GENERALISE ---
C      - CAS REEL

        CALL MTDEFS(MATPSC,MATRIG,'V','R')
        CALL MTDEFS(MATOPA,MATRIG,'V','R')
        CALL MTDSCR(MATPSC)
        CALL JEVEUO(MATPSC(1:19)//'.&INT','E',LMTPSC)
        CALL MTDSCR(MATOPA)
        CALL JEVEUO(MATOPA(1:19)//'.&INT','E',LMATRA)
C        RECHERCHE DU NOMBRE DE CHAR_CRIT DANS LINTERVALEE OMEMIN,OMEMAX
        IF (OPTION.EQ.'BANDE') THEN
          CALL VPFOPR(OPTION,TYPRES,LMASSE,LRAIDE,LMATRA,OMEMIN,OMEMAX,
     &                OMESHI,NFREQ,NPIVOT,OMECOR,PRECSH,NPREC,NBRSS,
     &                NBLAGR)
          IF (NFREQ.LE.0) THEN
            CALL U2MESS('I','ALGELINE2_15')
            GO TO 80
          ELSE
            CALL CODENT(NFREQ,'G',CHAINE)
            CALL U2MESK('I','ALGELINE2_16',1,CHAINE)
          END IF
        ELSE
          OMESHI = 0.D0
          CALL VPSHIF(LRAIDE,OMESHI,LMASSE,LMTPSC)
          CALL VPFOPR(OPTION,TYPRES,LMASSE,LRAIDE,LMATRA,OMEMIN,OMEMAX,
     &              OMESHI,NFREQ,NPIVOT,OMECOR,PRECSH,NPREC,NBRSS,
     &              NBLAGR)
        END IF

C     ------------------------------------------------------------------
C     ----  DETERMINATION DE LA DIMENSION DU SOUS ESPACE NBVECT   ------
C     ------------------------------------------------------------------

      IF (NIV.GE.2) THEN
        WRITE (IFM,*) 'INFORMATIONS SUR LE CALCUL DEMANDE:'
        WRITE (IFM,*) 'NOMBRE DE MODES DEMANDES     : ',NFREQ
        WRITE (IFM,*)
      END IF

C     --- CORRECTION DU NOMBRE DE FREQUENCES DEMAMDEES EN FONCTION
C         DE NEQACT

      IF (NFREQ.GT.NEQACT) THEN
        NFREQ = NEQACT
        IF (NIV.GE.2) THEN
          WRITE (IFM,*) 'INFORMATIONS SUR LE CALCUL DEMANDE:'
          WRITE (IFM,*) 'TROP DE MODES DEMANDES POUR LE NOMBRE '//
     &      'DE DDL ACTIFS, ON EN CALCULERA LE MAXIMUM '//'A SAVOIR: ',
     &      NFREQ
        END IF
      END IF

C     --- DETERMINATION DE NBVECT (DIMENSION DU SOUS ESPACE) ---

      IF (NIV.GE.2) THEN
        WRITE (IFM,*) 'LA DIMENSION DE L''ESPACE REDUIT EST : ',NBVECT
      END IF

      IF (NBVEC2.NE.0) THEN
        ICOEF = NBVEC2
      ELSE
        ICOEF = 2
      END IF

      IF (NBVECT.LT.NFREQ) THEN
        NBVECT = MIN(MAX(2+NFREQ,ICOEF*NFREQ),NEQACT)
        IF (NIV.GE.2) THEN
          WRITE (IFM,*) 'ELLE EST INFERIEURE AU NOMBRE '//
     &      'DE MODES, ON LA PREND EGALE A ',NBVECT
          WRITE (IFM,*)
        END IF
      ELSE
        IF (NBVECT.GT.NEQACT) THEN
          NBVECT = NEQACT
          IF (NIV.GE.2) THEN
            WRITE (IFM,*) 'ELLE EST SUPERIEURE AU'//
     &        ' NOMBRE DE DDL ACTIFS, ON LA RAMENE A CE NOMBRE ',NBVECT
            WRITE (IFM,*)
          END IF
        END IF
      END IF

C     --- TRAITEMENT SPECIFIQUE A SORENSEN ---

      IF ((METHOD.EQ.'SORENSEN') .AND. (NBVECT-NFREQ.LT.2)) THEN
CC  AUGMENTATION FORCEE DE NBVECT
CC (NECESSITE UNE ALARME OU INFO UTILISATEUR : A VOIR)
        NBVECT = NFREQ + 2
      END IF

C     ------------------------------------------------------------------
C     --------------  ALLOCATION DES ZONES DE TRAVAIL   ----------------
C     ------------------------------------------------------------------

      MXRESF = NFREQ
      CALL WKVECT('&&NMOP45.RESU_I','V V I',NBPARI*MXRESF,LRESUI)
      CALL WKVECT('&&NMOP45.RESU_R','V V R',NBPARR*MXRESF,LRESUR)
      CALL WKVECT('&&NMOP45.RESU_K','V V K24',NBPARK*MXRESF,LRESUK)

C     --- INITIALISATION A UNDEF DE LA STRUCTURE DE DONNEES RESUF --

      DO 10 IEQ = 1,NBPARR*MXRESF
        ZR(LRESUR+IEQ-1) = UNDF
   10 CONTINUE
      DO 20 IEQ = 1,NBPARI*MXRESF
        ZI(LRESUI+IEQ-1) = INDF
   20 CONTINUE

C     --- CAS REEL ET GENERALISE ---
      CALL WKVECT('&&NMOP45.VECT_PROPRE','V V R',NEQ*NBVECT,LVEC)

      LONWL = 3*NBVECT*NBVECT + 6*NBVECT
      CALL WKVECT('&&NMOP45.SELECT','V V L',NBVECT,LSELEC)
C     --- CAS REEL GENERALISE ---

      CALL WKVECT('&&NMOP45.RESID','V V R',NEQ,LRESID)
      CALL WKVECT('&&NMOP45.VECT.WORKD','V V R',3*NEQ,LWORKD)
      CALL WKVECT('&&NMOP45.VECT.WORKL','V V R',LONWL,LWORKL)
      CALL WKVECT('&&NMOP45.VECT.WORKV','V V R',3*NBVECT,LWORKV)
      CALL WKVECT('&&NMOP45.VAL.PRO','V V R',2* (NFREQ+1),LDSOR)
      CALL WKVECT('&&NMOP45.VECT.AUX','V V R',NEQ,LAUX)


C     ------------------------------------------------------------------
C     -------  CALCUL DES VALEURS PROPRES ET VECTEURS PROPRES   --------
C     ------------------------------------------------------------------

      ALPHA = 0.717D0
      MAXITR = 200
      TOLSOR = 0.D0

      IF (NIV.EQ.2) THEN
        PRIRAM(1) = 2
        PRIRAM(2) = 2
        PRIRAM(3) = 2
        PRIRAM(4) = 2
        PRIRAM(5) = 0
        PRIRAM(6) = 0
        PRIRAM(7) = 0
        PRIRAM(8) = 2
      ELSE
        DO 30 I = 1,8
          PRIRAM(I) = 0
   30   CONTINUE
      END IF
C     --- SORENSEN : CAS REEL GENERALISE ---
C     CALCUL DES MODES PROPRES



      IF ( MOD45 .EQ. 'FLAM' ) THEN
        IF (DEFO.EQ.0) THEN

          CALL VPSORN(LMASSE,LMATRA,NEQ,NBVECT,NFREQ,TOLSOR,ZR(LVEC),
     &              ZR(LRESID),ZR(LWORKD),ZR(LWORKL),LONWL,ZL(LSELEC),
     &              ZR(LDSOR),OMESHI,ZR(LAUX),ZR(LWORKV),ZI(LPROD),
     &              ZI(LDDL),NEQACT,MAXITR,IFM,NIV,PRIRAM,ALPHA,OMECOR,
     &              NCONV,FLAGE)

        ELSE
          CALL WKVECT('&&NMOP45.POSI.EDDL','V V I',
     &                NEQ*MXDDL,EDDL)
          CALL ELMDDL(MATRIG,NEQ,DDL,NDDLE,NBDDL,ZI(EDDL),IER)  
C     			
          CALL VPSOR1(LMATRA,NEQ,NBVECT,NFREQ,TOLSOR,ZR(LVEC),
     &              ZR(LRESID),ZR(LWORKD),ZR(LWORKL),LONWL,ZL(LSELEC),
     &              ZR(LDSOR),OMESHI,ZR(LAUX),ZR(LWORKV),ZI(LPROD),
     &              ZI(LDDL),ZI(EDDL),NBDDL,NEQACT,MAXITR,IFM,NIV,
     &              PRIRAM,ALPHA,OMECOR,NCONV,FLAGE)

        END IF
      ELSE
        CALL VPSORN(LMASSE,LMATRA,NEQ,NBVECT,NFREQ,TOLSOR,ZR(LVEC),
     &              ZR(LRESID),ZR(LWORKD),ZR(LWORKL),LONWL,ZL(LSELEC),
     &              ZR(LDSOR),OMESHI,ZR(LAUX),ZR(LWORKV),ZI(LPROD),
     &              ZI(LDDL),NEQACT,MAXITR,IFM,NIV,PRIRAM,ALPHA,OMECOR,
     &              NCONV,FLAGE)

      ENDIF

C     TRI DE CES MODES
      CALL RECTFR(NCONV,NCONV,OMESHI,NPIVOT,NBLAGR,ZR(LDSOR),
     &            NFREQ+1,ZI(LRESUI),ZR(LRESUR),NFREQ)
      CALL VPBOST(TYPRES,NCONV,NCONV,OMESHI,ZR(LDSOR),NFREQ+1,VPINF,
     &            VPMAX,PRECDC,METHOD,OMECOR,STURM)
      IF (MOD45 .EQ. 'VIBR') THEN
        CALL VPORDI (1,0,NCONV,ZR(LRESUR+MXRESF),ZR(LVEC),NEQ,
     &                  ZI(LRESUI))
      ENDIF
      DO 40 IMET = 1,NCONV
        ZI(LRESUI-1+MXRESF+IMET) = 0
        ZR(LRESUR-1+IMET) = FREQOM(ZR(LRESUR-1+MXRESF+IMET))
        ZR(LRESUR-1+2*MXRESF+IMET) = 0.0D0
        ZK24(LRESUK-1+MXRESF+IMET) = 'SORENSEN'
   40 CONTINUE


      IF (MOD45 .NE. 'VIBR') THEN
        ITYP = 0
        IORDRE = 0
        CALL VPORDO(ITYP,IORDRE,NCONV,ZR(LRESUR+MXRESF),ZR(LVEC),NEQ)
        DO 50 IMET = 1,NCONV
          ZR(LRESUR-1+IMET) = FREQOM(ZR(LRESUR-1+MXRESF+IMET))
          ZI(LRESUI-1+IMET) = IMET
   50   CONTINUE
      ENDIF

C     ------------------------------------------------------------------
C     -------------------- CORRECTION : OPTION BANDE -------------------
C     ------------------------------------------------------------------

C     --- SI OPTION BANDE ON NE GARDE QUE LES FREQUENCES DANS LA BANDE

      MFREQ = NCONV
      IF (OPTION.EQ.'BANDE') THEN
         DO 110 IFREQ = MFREQ - 1,0
            IF (ZR(LRESUR+MXRESF+IFREQ).GT.OMEMAX .OR.
     &          ZR(LRESUR+MXRESF+IFREQ).LT.OMEMIN ) THEN
                NCONV = NCONV - 1
            ENDIF
110      CONTINUE
         IF (MFREQ.NE.NCONV) THEN
            CALL U2MESS('I','ALGELINE2_17')
         ENDIF
      ENDIF

      KNEGA = 'NON'
      NPARR = NBPARR

      CALL VPPARA(MODES,TYPCON,KNEGA,LRAIDE,LMASSE,LAMOR,
     &               MXRESF,NEQ,NCONV,OMECOR,ZI(LDDL),ZI(LPROD),
     &               ZR(LVEC),CBID, NBPARI, NPARR, NBPARK, NOPARA,MOD45,
     &               ZI(LRESUI), ZR(LRESUR), ZK24(LRESUK),KTYP )

      IF (NIV.GE.2) THEN
        CALL VPWECF(' ',TYPRES,NCONV,MXRESF,ZI(LRESUI),ZR(LRESUR),
     &              ZK24(LRESUK),LAMOR,KTYP,LBID)
      END IF



   80 CONTINUE

      CALL JEDETC('V','&&NMOP45',1)
      CALL JEDEMA()

C     ------------------------------------------------------------------

C     FIN DE NMOP45

      END
