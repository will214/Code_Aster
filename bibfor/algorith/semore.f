      SUBROUTINE SEMORE(LRAIDE,LAMOR,LMASSE,NEQ,MXRESF,NBMODE,
     &                  FREQ,VECT,
     &                  NBPARI,NBPARR,NBPARK,NBPARA,NOPARA,
     &                  RESUI,RESUK)

C-----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 06/03/2006   AUTEUR GREFFET N.GREFFET 
C ======================================================================
C COPYRIGHT (C) 1991 - 2004  EDF R&D                  WWW.CODE-ASTER.ORG
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
C
C CALCUL SENSIBILITE MODES REELS
C HYPOTHESES : MODES SIMPLES, DM/DP = 0
C-----------------------------------------------------------------------

      IMPLICIT NONE

C PARAMETRES D'APPELS
      INTEGER LRAIDE,LAMOR,LMASSE,NEQ,MXRESF,NBMODE,RESUI(MXRESF,*)
      INTEGER NBPARI,NBPARR,NBPARK,NBPARA
      REAL*8 FREQ(MXRESF,*),VECT(NEQ,*)
      CHARACTER*(*) NOPARA(*)
      CHARACTER*24 RESUK(MXRESF,*)

C ENTREES : 
C LRAIDE : DESCRIPTEUR MATRICE RAIDEUR
C LAMOR : DESCRIPTEUR MATRICE AMORTISSEMENT
C LMASSE : DESCRIPTEUR MATRICE MASSE
C NEQ : NOMBRE DE DDL
C MXRESF : PARAMETRE DE DIMENSIONNEMENT DE RESUR
C NBMODE : NOMBRE DE MODES CALCULES
C FREQ : FREQUENCES PROPRES ET VALEURS PROPRES
C VECT : VECTEURS PROPRES
C NBPARI,NBPARR,NBPARK,NBPARA,NOPARA : PARAMETRES CALCUL MODAL
C RESUI : VECTEUR ENTIER CALCUL MODAL
C RESUK : VECTEUR CHAR CALCUL MODAL

C --------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ---------------------
      INTEGER ZI
      COMMON /IVARJE/ZI(1)
      REAL*8 ZR
      COMMON /RVARJE/ZR(1)
      COMPLEX*16 ZC
      COMMON /CVARJE/ZC(1)
      LOGICAL ZL
      COMMON /LVARJE/ZL(1)
      CHARACTER*8  ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C --------- FIN  DECLARATIONS  NORMALISEES  JEVEUX ---------------------

C VARIABLES LOCALES

      LOGICAL SECAL

      INTEGER IAUX,JAUX,NBPASE,IRET,TYPESE,IBID,JCHAR,JINF
      INTEGER IEQ,NRPASE,NUMODE,NPARR,NCHAR,NBNO,LRESUI,LRESUK
      INTEGER JDVEC,LDVEC,LDVAL,INEG,IPREC,MULT,IMODE
      INTEGER JVALE,JA,JB,JTRAV,JCAN,JVALS,JU,JV,IRESU
      REAL*8 R8BID,TEMPS,R8DEPI,PSI,EPS,R8PREM,OMEGA2,DIFF,EPSCR
      REAL*8 R8VIDE,UNDF
      COMPLEX*16 CBID
      CHARACTER*1 VTYP
      CHARACTER*4 TYPCAL
      CHARACTER*6 NOMPRO
      CHARACTER*8  BASENO,NOMRES,NOPASE,RESULT,MAILLA,NOMGD,BLAN8
      CHARACTER*10 MATU,MATV
      CHARACTER*13 INPSCO
      CHARACTER*14 MATA,VECB
      CHARACTER*16 TYPCON,NOMCMD,NOMSY,VCAN,DRESUI,DRESUK
      CHARACTER*17 VTRAV,VALS
      CHARACTER*19 LIGRMO,RAIDE,INFCHA,MASSE
      CHARACTER*21 DVALPR,DVECPR
      CHARACTER*22 DVECT
      CHARACTER*24 STYPSE,MODELE,VECHMP,VACHMP,K24BID,INFOCH,NUMEDD
      CHARACTER*24 MATE,CARELE,LCHAR,CHARGE,VAPRIN,PRCHNO,CHAMNO

      PARAMETER (NOMPRO = 'SEMORE')

      CALL JEMARQ()

      UNDF = R8VIDE()

      CALL GETRES(NOMRES,TYPCON,NOMCMD)
      CALL GETVID(' ','MATR_A',1,1,1,RAIDE,IRET)
      CALL GETVID(' ','MATR_B',1,1,1,MASSE,IRET)

      CALL DISMOI('F','NOM_MODELE',RAIDE,'MATR_ASSE',IBID,MODELE,IRET)
      CALL DISMOI('F','NOM_NUME_DDL',RAIDE,'MATR_ASSE',IBID,NUMEDD,IRET)
      CALL DISMOI('F','NOM_MAILLA',MODELE,'MODELE',IBID,MAILLA,IRET)
      CALL DISMOI('F','NB_NO_MAILLA',MAILLA,'MAILLAGE',NBNO,K24BID,IRET)
      CALL DISMOI('F','NOM_GD',NUMEDD,'NUME_DDL',IBID,NOMGD,IRET)

      PRCHNO = NUMEDD(1:14)//'.NUME'
      BASENO = '&&'//NOMPRO
      INPSCO = BASENO//'_PSCO'
      LIGRMO = MODELE(1:8)//'.MODELE'

C SORTIE EN ERREUR FATALE SI PB DANS PSLECT (IAUX = 1)
      IAUX = 1
      JAUX = 1
      CALL PSLECT(' ',JAUX,BASENO,NOMRES,IAUX,NBPASE,INPSCO,IRET)

      BLAN8  = '        '

      CALL NMDOME(MODELE,MATE,CARELE,INFCHA,NBPASE,INPSCO,
     &               BLAN8,IBID)


C VARIABLES NECESSAIRES POUR STOCKAGE DE LA SD RESULTATS
      INEG = 0
      IPREC = 0
      IF (TYPCON.EQ.'MODE_ACOU') THEN
        NOMSY = 'PRES'
        NPARR = 7
      ELSE
        NOMSY = 'DEPL'
        NPARR = NBPARR
      ENDIF

C LES VECTEURS PROPRES SONT DE TYPE REEL
      VTYP = 'R'

C  BOUCLE SUR LES PARAMETRES SENSIBLES
      DO 100 NRPASE = 1,NBPASE

C -- NOM DU PARAMETRE DU PARAMETRE SENSIBLE, JAUX = 1
        JAUX = 1
        CALL PSNSLE(INPSCO,NRPASE,JAUX,NOPASE)

C -- NOM DU CONCEPT RESULTAT, JAUX = 3
        JAUX = 3
        CALL PSNSLE(INPSCO,NRPASE,JAUX,RESULT)

        CALL METYSE(NBPASE,INPSCO,NOPASE,TYPESE,STYPSE)

C -- REPERAGE DU TYPE DE DERIVATION (TYPESE)
C             0 : CALCUL STANDARD
C            -1 : DERIVATION EULERIENNE (VIA UN CHAMP THETA)
C             1 : DERIVEE SANS INFLUENCE
C             2 : DERIVEE DE LA CL DE DIRICHLET
C             3 : PARAMETRE MATERIAU
C             4 : CARACTERISTIQUE ELEMENTAIRE (COQUES, ...)
C             5 : FORCE
C             N : AUTRES DERIVEES

        SECAL = .FALSE.

        DVALPR = BASENO//'_D_VAL_PROPRE'
        DVECPR = BASENO//'_D_VEC_PROPRE'
        CALL WKVECT(DVALPR,'V V R',NBPARR*MXRESF,LDVAL)
        CALL WKVECT(DVECPR,'V V R',NEQ*MXRESF,LDVEC)

        DRESUI = BASENO//'_D_RESUI'
        DRESUK = BASENO//'_D_RESUK'
        CALL WKVECT(DRESUI,'V V I',NBPARI*MXRESF, LRESUI)
        CALL WKVECT(DRESUK,'V V K24',NBPARK*MXRESF, LRESUK)

C INITIALISATION PARAMETRES SUR LES DERIVEES DES MODES PROPRES
        DO 110 NUMODE = 1,NBMODE
          DO 111 IEQ = 1,NBPARR
            ZR(LDVAL-1+MXRESF*(IEQ-1)+NUMODE) = UNDF
111       CONTINUE
          DO 112 IEQ = 1,NBPARI
            ZI(LRESUI-1+MXRESF*(IEQ-1)+NUMODE) = RESUI(NUMODE,IEQ) 
112       CONTINUE
          DO 113 IEQ = 1,NBPARK
            ZK24(LRESUK-1+MXRESF*(IEQ-1)+NUMODE) = RESUK(NUMODE,IEQ) 
113       CONTINUE
110     CONTINUE          

C  BOUCLE SUR LES MODES
        DO 120 NUMODE = 1,NBMODE

C FREQ(NUMODE,1) : FREQUENCE PROPRE
C FREQ(NUMODE,2) : OMEGA2
C FREQ(NUMODE,3) : AMORTISSEMENT REDUIT
C FREQ(NUMODE,5) : MASSE GENERALISEE

C  STOCKAGE DU VECTEUR PROPRE NUMODE DANS VAPRIN

          DVECT = BASENO//'_DK_S_DP_VECT'
          CALL WKVECT(DVECT,'V V R',NEQ,JDVEC)

          JAUX = 4
          CALL PSNSLE(INPSCO,0,JAUX,VAPRIN)
          CALL JEEXIN(VAPRIN(1:19)//'.REFE',IRET)
          IF (IRET.EQ.0) CALL VTCREM(VAPRIN(1:19),MASSE,'V',VTYP)
          CALL JEVEUO(VAPRIN(1:19)//'.VALE','E',JVALE)
          DO 122 IEQ = 1,NEQ
            ZR(JVALE-1+IEQ) = VECT(IEQ,NUMODE)
122       CONTINUE

C -- DERIVATION EULERIENNE
  
          IF (TYPESE.EQ.-1) THEN
            SECAL = .FALSE.
C NON TRAITE POUR L INSTANT
          ENDIF

C -- LES DERIVEES SANS INFLUENCE

          IF (TYPESE.EQ.1) THEN
            SECAL = .TRUE.
            DO 123 IEQ = 1,NEQ
              ZR(JDVEC-1+IEQ) = 0.D0
123         CONTINUE
          ENDIF

C -- LES DIRICHLETS

          IF (TYPESE.EQ.2) THEN
            SECAL = .TRUE.
            CALL PSNSLE(INPSCO,NRPASE,11,VECHMP)
            TEMPS = 0.D0
            CALL VEDIME(MODELE,CHARGE,INFOCH,TEMPS,VTYP,
     &                  TYPESE,NOPASE,VECHMP)
            CALL ASASVE(VECHMP,NUMEDD,VTYP,VACHMP)        
            CALL JEVEUO(VACHMP,'L',IRET)
            CALL JEVEUO(ZK24(IRET)(1:19)//'.VALE','L',JDVEC)
          ENDIF

C -- LES PARAMETRES MATERIAUX (ATTENTION VERSION TEMPORAIRE)
C ON NE TRAITE PAS POUR L INSTANT LA DERIVEE DE MASSE
C PAR RAPPORT AU PARAMETRE MATERIAU

          IF (TYPESE.EQ.3) THEN
            SECAL = .TRUE.
            TYPCAL = 'MECA'
            CALL JEEXIN(CHARGE,IRET)
            IF (IRET .NE. 0) THEN
              CALL JEVEUO(CHARGE,'L',JCHAR)
              CALL JEVEUO(INFOCH,'L',JINF)
              NCHAR = ZI(JINF)
              LCHAR = ZK24(JCHAR)
            ELSE
              NCHAR = 0
              LCHAR = K24BID
            ENDIF
            CALL VECHDE(TYPCAL,MODELE(1:8),NCHAR,LCHAR,MATE,
     &                  CARELE(1:8),R8BID,VAPRIN,K24BID,
     &                  K24BID,K24BID,LIGRMO,
     &                  NOPASE,VECHMP)
            VACHMP = K24BID
            CALL ASASVE(VECHMP,NUMEDD,VTYP,VACHMP)
            CALL JEVEUO(VACHMP,'L',IRET)
            CALL JEVEUO(ZK24(IRET)(1:19)//'.VALE','L',JDVEC)
          ENDIF

C -- LES CARACTERISTIQUES ELEMENTAIRES

          IF (TYPESE.EQ.4) THEN
            SECAL = .FALSE.
C NON TRAITE POUR L INSTANT
          ENDIF

C -- CHARGEMENTS DE NEUMANN

          IF (TYPESE.EQ.5) THEN
            SECAL = .FALSE.
C PAS DE CHARGEMENT DE NEUMANN DANS LES CALCULS MODAUX
          ENDIF

          IF (.NOT.SECAL) THEN
            CALL UTDEBM('A',NOMPRO,'TYPE DE SENSIBILITE NON TRAITE ')
            CALL UTIMPI('S','TYPESE : ',1,TYPESE)
            CALL UTFINM
            CALL UTMESS('F',NOMPRO,'CAS SENSIBILITE NON PREVU')
          ENDIF

          DO 124 IEQ = 1,NEQ
            ZR(JDVEC-1+IEQ) = -ZR(JDVEC-1+IEQ)
124       CONTINUE

C ALARME SI FORTE PROBABILITE MODES MULTIPLES

C EPSCR : SEUIL DE DETECTION DE MODES MULTIPLES
C         VALEUR A AFFINER SI BESOIN

          EPSCR = 1.D-8
          OMEGA2 = FREQ(NUMODE,2)
          MULT = 0
          DO 125 IMODE = 1,NBMODE
            IF (OMEGA2 .LT. EPSCR) THEN
              DIFF = ABS(OMEGA2-FREQ(IMODE,2))
            ELSE
              DIFF = ABS(OMEGA2-FREQ(IMODE,2))/OMEGA2
            ENDIF
            IF (DIFF .LT. EPSCR) MULT = MULT+1
125       CONTINUE
          IF (MULT .GT. 1) THEN
            CALL UTMESS('F',NOMPRO,'FORTE PROBABILITE PRESENCE '//
     &      'MODES PROPRES MULTIPLES. CALCUL SENSIBILITE LIMITE'//
     &      ' ACTUELLEMENT AUX MODES PROPRES SIMPLES')
          ENDIF

C CALCUL DE LA DERIVEE DE LA VALEUR PROPRE

          PSI = 0.D0
          DO 126 IEQ = 1,NEQ
            PSI = PSI+ZR(JDVEC-1+IEQ)*VECT(IEQ,NUMODE)
C SI DERIVATION MASSE, IL FAUT RAJOUTER :
C   -LAMBDA*PHItr*M'*PHI
126       CONTINUE
          ZR(LDVAL-1+MXRESF+NUMODE) = PSI/FREQ(NUMODE,5)
          ZR(LDVAL-1+NUMODE) = ZR(LDVAL-1+MXRESF+NUMODE)/
     &           (R8DEPI()*R8DEPI()*2.D0*FREQ(NUMODE,1))


C CALCUL DE LA DERIVEE DU VECTEUR PROPRE
C LA NORME DES MODES CHOISIE PAR CALCUL MODAL : COMPOSANTE MAX = 1

C CONSTRUCTION MATRICES DU SYSTEME : A*X = B
          MATA = BASENO//'_MAT_A'
          VECB = BASENO//'_VEC_B'
          CALL WKVECT(MATA,'V V R',NEQ*NEQ,JA)
          CALL WKVECT(VECB,'V V R',NEQ,JB)

C CREATION DE LA MATRICE A

          VCAN = BASENO//'_VEC_CAN'
          CALL WKVECT(VCAN,'V V R',NEQ,JCAN)

          DO 127 IEQ = 1,NEQ
            ZR(JCAN-1+IEQ) = 0.D0
127       CONTINUE

          DO 128 IEQ = 1,NEQ
            IRESU = JA+(IEQ-1)*NEQ
            ZR(JCAN-1+IEQ) = -OMEGA2
            CALL MRMULT('ZERO',LMASSE,ZR(JCAN),'R',ZR(IRESU),1)
            ZR(JCAN-1+IEQ) = 1.D0
            CALL MRMULT('CUMU',LRAIDE,ZR(JCAN),'R',ZR(IRESU),1)
            ZR(JCAN-1+IEQ) = 0.D0
128       CONTINUE

C CREATION DU VECTEUR B

          DO 129 IEQ = 1,NEQ
            ZR(JCAN-1+IEQ) = VECT(IEQ,NUMODE)
     &                       *ZR(LDVAL-1+MXRESF+NUMODE)
129       CONTINUE
          CALL MRMULT('ZERO',LMASSE,ZR(JCAN),'R',ZR(JB),1)
          DO 131 IEQ = 1,NEQ
            ZR(JB-1+IEQ) = -ZR(JDVEC-1+IEQ)+ZR(JB-1+IEQ)
C SI DERIVATION MASSE, IL FAUT RAJOUTER :
C   LAMBDA*M'*PHI
131       CONTINUE

          VTRAV = BASENO//'_VEC_TRAV'
          VALS = BASENO//'_VAL_SING'
          MATU = BASENO//'_U'
          MATV = BASENO//'_V'

          CALL WKVECT(VTRAV,'V V R',NEQ,JTRAV)
          CALL WKVECT(VALS,'V V R',NEQ,JVALS)
          CALL WKVECT(MATU,'V V R',NEQ*NEQ,JU)
          CALL WKVECT(MATV,'V V R',NEQ*NEQ,JV)

C L UTILISATION DES MULTIPLICATEURS DE LAGRANGE FAIT 
C QUE LA MATRICE A PEUT ETRE SINGULIERE => CALCUL PAR SVD
          EPS = 1.0D+02*R8PREM()
          CALL RSLSVD(NEQ,NEQ,NEQ,ZR(JA),ZR(JVALS),ZR(JU),ZR(JV),
     &            1,ZR(JB),EPS,IRET,ZR(JTRAV))

          IF (IRET.NE.0) THEN
            CALL UTMESS('F',NOMPRO,'PB A LA RESOLUTION DU SYSTEME')
          ENDIF

          DO 132 IEQ = 1,NEQ
            ZR(LDVEC-1+(NUMODE-1)*NEQ+IEQ) = ZR(JB-1+IEQ)
132       CONTINUE 

          CALL JEDETR(VTRAV)
          CALL JEDETR(MATA)
          CALL JEDETR(VECB)
          CALL JEDETR(VALS)
          CALL JEDETR(MATU)
          CALL JEDETR(MATV)
          CALL JEDETR(VCAN)
          CALL JEDETR(DVECT)

C FIN BOUCLE SUR LES MODES
120     CONTINUE

C CREATION DE LA STRUCTURE DE DONNEES RESULTATS

        CALL RSCRSD (RESULT,TYPCON,NBMODE)

        DO 140 NUMODE=1,NBMODE
          CALL RSEXCH(RESULT,NOMSY,NUMODE,CHAMNO,IRET)
          CALL CRCHNO(CHAMNO,PRCHNO,NOMGD,MAILLA,'G',
     &                VTYP,NBNO,NEQ)
140     CONTINUE

        CALL VPSTOR(INEG,VTYP,RESULT,NBMODE,NEQ,ZR(LDVEC),CBID,
     &              MXRESF,NBPARI,NPARR,NBPARK,NOPARA,'    ',
     &              ZI(LRESUI),ZR(LDVAL),ZK24(LRESUK),IPREC)

        CALL JEDETR(DVALPR)
        CALL JEDETR(DVECPR)
        CALL JEDETR(DRESUI)
        CALL JEDETR(DRESUK)

C FIN BOUCLE SUR PARAMETRES SENSIBLES
100   CONTINUE

      CALL JEDETC('V',BASENO,1)

      CALL JEDEMA()

      END
