      SUBROUTINE NMFI3D(NNO,NDDL,NPG,LGPG,WREF,VFF,DFDE,
     &                  MATE,OPTION,GEOM,DEPLM,DDEPL,
     &                  SIGMA,FINT,KTAN,VIM,VIP,CRIT,
     &                  COMPOR,MATSYM,COOPG,TM,TP,CODRET)

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 28/06/2010   AUTEUR FLEJOU J-L.FLEJOU 
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C ======================================================================
C COPYRIGHT (C) 2007 NECS - BRUNO ZUBER   WWW.NECS.FR
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

      IMPLICIT NONE
      INTEGER NNO,NDDL,NPG,LGPG,MATE,CODRET
      REAL*8  WREF(NPG),VFF(NNO,NPG),DFDE(2,NNO,NPG),CRIT(*)
      REAL*8  GEOM(NDDL),DEPLM(NDDL),DDEPL(NDDL),TM,TP
      REAL*8  FINT(NDDL),KTAN(*),COOPG(4,NPG)
      REAL*8  SIGMA(3,NPG),VIM(LGPG,NPG),VIP(LGPG,NPG)
      CHARACTER*16 OPTION, COMPOR(*)
      LOGICAL MATSYM

C-----------------------------------------------------------------------
C  OPTIONS DE MECANIQUE NON LINEAIRE POUR LES JOINTS 3D (TE0206)
C-----------------------------------------------------------------------
C IN  NNO    NOMBRE DE NOEUDS DE LA FACE (*2 POUR TOUT L'ELEMENT)
C IN  NDDL   NOMBRE DE DEGRES DE LIBERTE EN DEPL TOTAL (3 PAR NOEUDS)
C IN  NPG    NOMBRE DE POINTS DE GAUSS
C IN  LGPG   NOMBRE DE VARIABLES INTERNES
C IN  WREF   POIDS DE REFERENCE DES POINTS DE GAUSS
C IN  VFF    VALEUR DES FONCTIONS DE FORME (DE LA FACE)
C IN  DFDE   DERIVEE DES FONCTIONS DE FORME (DE LA FACE)
C IN  MATE   MATERIAU CODE
C IN  OPTION OPTION DE CALCUL
C IN  GEOM   COORDONNEES DES NOEUDS
C IN  DEPLM  DEPLACEMENTS NODAUX AU DEBUT DU PAS DE TEMPS
C IN  DDEPL  INCREMENT DES DEPLACEMENTS NODAUX
C OUT SIGMA  CONTRAINTES LOCALES AUX POINTS DE GAUSS (SIGN, SITX, SITY)
C OUT FINT   FORCES NODALES
C OUT KTAN   MATRICE TANGENTE (STOCKEE EN TENANT COMPTE DE LA SYMETRIE)
C IN  VIM    VARIABLES INTERNES AU DEBUT DU PAS DE TEMPS
C OUT VIP    VARIABLES INTERNES A LA FIN DU PAS DE TEMPS
C IN  CRIT   VALEURS DE L'UTILISATEUR POUR LES CRITERES DE CONVERGENCE
C IN  COMPOR NOM DE LA LOI DE COMPORTEMENT
C IN  MATSYM INFORMATION SUR LA MATRICE TANGENTE : SYMETRIQUE OU PAS
C IN  COOPG  COORDONNEES GEOMETRIQUES DES PG + POIDS
C OUT CODRET CODE RETOUR DE L'INTEGRATION
C-----------------------------------------------------------------------
      LOGICAL RESI,RIGI
      INTEGER CODE(9),NI,MJ,KK,P,Q,KPG,IBID,N
      REAL*8  B(3,60),SUM(3),DSU(3),DSIDEP(3,3),POIDS
      REAL*8  RBID,R8VIDE,DDOT
      REAL*8  ANGMAS(3)

      CHARACTER*8  TYPMOD(2)
      DATA TYPMOD /'3D','ELEMJOIN'/
C-----------------------------------------------------------------------

      RESI = OPTION.EQ.'RAPH_MECA'      .OR. OPTION(1:9).EQ.'FULL_MECA'
      RIGI = OPTION(1:9).EQ.'FULL_MECA' .OR. OPTION(1:9).EQ.'RIGI_MECA'

C --- ANGLE DU MOT_CLEF MASSIF (AFFE_CARA_ELEM)
C --- INITIALISE A R8VIDE (ON NE S'EN SERT PAS)
      CALL R8INIR(3,  R8VIDE(), ANGMAS ,1)

      CALL R8INIR(3,0.D0,SUM,1)
      CALL R8INIR(3,0.D0,DSU,1)

      IF (RESI) CALL R8INIR(NDDL,0.D0,FINT,1)

      IF (RIGI) THEN
        IF (MATSYM) THEN
          CALL R8INIR((NDDL*(NDDL+1))/2,0.D0, KTAN,1)
        ELSE
          CALL R8INIR(NDDL*NDDL,0.D0, KTAN,1)
        ENDIF
      ENDIF


      DO 10 KPG=1,NPG

C CALCUL DE LA MATRICE B DONNANT LES SAUT PAR ELEMENTS A PARTIR DES
C DEPLACEMENTS AUX NOEUDS , AINSI QUE LE POIDS DES PG :

        CALL NMFICI(NNO,NDDL,WREF(KPG),VFF(1,KPG),
     &              DFDE(1,1,KPG),GEOM,POIDS,B)

C CALCUL DU SAUT DE DEPLACEMENT - : SUM, ET DE L'INCREMENT : DSU
C AU POINT DE GAUSS KPG

        SUM(1) = DDOT(NDDL,B(1,1),3,DEPLM,1)
        SUM(2) = DDOT(NDDL,B(2,1),3,DEPLM,1)
        SUM(3) = DDOT(NDDL,B(3,1),3,DEPLM,1)

        IF (RESI) THEN
          DSU(1) = DDOT(NDDL,B(1,1),3,DDEPL,1)
          DSU(2) = DDOT(NDDL,B(2,1),3,DDEPL,1)
          DSU(3) = DDOT(NDDL,B(3,1),3,DDEPL,1)
        ENDIF

C -   APPEL A LA LOI DE COMPORTEMENT

        RBID = R8VIDE()
        CODE(KPG) = 0

        CALL NMCOMP('RIGI',KPG,1,3,TYPMOD,MATE,COMPOR,CRIT,
     &                TM,TP,
     &                SUM,DSU,
     &                RBID,VIM(1,KPG),
     &                OPTION,ANGMAS,COOPG(1,KPG),
     &                SIGMA(1,KPG),VIP(1,KPG),DSIDEP,IBID)

C FORCES INTERIEURES

        IF (RESI) THEN
          DO 20 NI=1,NDDL
            FINT(NI) = FINT(NI) + POIDS*DDOT(3,B(1,NI),1,SIGMA(1,KPG),1)
 20       CONTINUE
        ENDIF

C MATRICE TANGENTE

        IF (RIGI) THEN

          IF (MATSYM) THEN

C           STOCKAGE SYMETRIQUE
            KK = 0
            DO 50 NI=1,NDDL
            DO 52 MJ=1,NI
              KK = KK+1
              DO 60 P=1,3
              DO 62 Q=1,3
                KTAN(KK) = KTAN(KK) + POIDS*B(P,NI)*DSIDEP(P,Q)*B(Q,MJ)
 62           CONTINUE
 60           CONTINUE
 52         CONTINUE
 50         CONTINUE

          ELSE

C           STOCKAGE COMPLET
            KK = 0
            DO 51 NI=1,NDDL
            DO 53 MJ=1,NDDL
              KK = KK+1
              DO 61 P=1,3
              DO 63 Q=1,3
                KTAN(KK) = KTAN(KK) + POIDS*B(P,NI)*DSIDEP(P,Q)*B(Q,MJ)
 63           CONTINUE
 61           CONTINUE
 53         CONTINUE
 51         CONTINUE

          ENDIF

        ENDIF

 10   CONTINUE

      IF (RESI) CALL CODERE(CODE,NPG,CODRET)
      END
