      SUBROUTINE MPTRAN (NOMBAS,NOMMES,NBMESU,NBMODE,
     &                    BASEPR,VNOEUD,VRANGE)
C
C     ------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 03/10/2005   AUTEUR NICOLAS O.NICOLAS 
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
C ALONG WITH THIS PROGRAM; IF NOT,      IMESU, II, IMODE, IRET
C      INTEGER  TO EDF R&D CODE_ASTER,       
C    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.      
C ======================================================================
C
C     PROJ_MESU_MODAL : CALCUL DES CONTRIBUTIONS MODALES ET CONSTRUCTION
C                       DU TRAN_GENE OU HARM_GENE
C
C     IN  : NOMBAS : NOM DE LA BASE DE PROJECTION
C     IN  : NOMMES : NOM DE LA SD MESURE
C     IN  : NBMESU : NOMBRE DE DDL DE MESURE
C     IN  : NBMODE : NOMBRE DE VECTEURS DE BASE
C     IN  : BASEPR : NOM BASE PROJETEE SUIVANT DIRECTION MESURE
C     IN  : VNOEUD : NOM RANGEMENT NOEUD MESURE
C     IN  : VRANGE : NOM CORRESPONDANCE ORIENTATION SUIVANT LNOEUD
C
      IMPLICIT NONE
C
C-------- DEBUT COMMUNS NORMALISES  JEVEUX  ----------------------------
C
      INTEGER          ZI
      COMMON  /IVARJE/ ZI(1)
      REAL*8           ZR
      COMMON  /RVARJE/ ZR(1)
      COMPLEX*16       ZC
      COMMON  /CVARJE/ ZC(1)
      LOGICAL          ZL
      COMMON  /LVARJE/ ZL(1)
      CHARACTER*8      ZK8
      CHARACTER*16              ZK16
      CHARACTER*24                        ZK24
      CHARACTER*32                                  ZK32
      CHARACTER*80                                            ZK80
      COMMON  /KVARJE/ ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C
C----------  FIN  COMMUNS NORMALISES  JEVEUX  --------------------------
C
      CHARACTER*8   NOMRES,NOMBAS,NOMMES
      CHARACTER*24  VRANGE,VNOEUD,BASEPR
      INTEGER       NBMESU,NBMODE
C
      CHARACTER*1   TYPVAL
      CHARACTER*6   NOMROU
      CHARACTER*8   K8BID,K8B,SCAL,SCALAI,KCMP,KREG
      CHARACTER*16  NOMCMD,TYPRES,K16BID,NOMCHA
      CHARACTER*19  CHS,CHAMNO

      CHARACTER*24  VABS,VMES

      LOGICAL       LPSTO,LFONCT,ZCMPLX
C
      INTEGER       I,J,JABS,JFCHO,JDCHO,JVCHO,JICHO,JREDC,JREDD
      INTEGER       JDEP,JVIT,JACC,JPASS,JORDR,LORD,IMES,IRET,GD
      INTEGER       LABS,LMESU,LCOEF,LRED,JCNSD,JCNSC,JCNSV
      INTEGER       NCOEF,NFONC,LFONC,NULL,IBID,JCNSL,NBCMP
      INTEGER       LVALE,LONMAX,IOCC,NUMORD,INO,ICMP,INDICE
      INTEGER       IDESC,JCNSK,LRANGE,LNOEUD,NBABS,JNUMO
C
      REAL*8        R8BID,DT,PAS,DIFF,RBID
C
      COMPLEX*16    CBID
C
C ----------------------------------------------------------------------
C
      DATA NOMCMD/'&PROJ_MESU_MODAL'/, K8B/'        '/, NULL/0/
      DATA NOMROU/'MPTRAN'/
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ ( )
C
C RECUPERATION DU NOM DU CONCEPT RESULTAT
      CALL GETRES (NOMRES, TYPRES, K16BID)
C RECUPERATION DU CHAMP MESURE : NOMMES
      CALL GETVTX ('MODELE_MESURE','NOM_CHAM',1,1,1,NOMCHA,IBID)
      CALL GETVID
     &      ('RESOLUTION', 'REGUL', 1, 1, 0, KREG, IBID)

C RECUPERATION DU NOMBRE D ABSCISSES : NBABS
      CALL RSORAC(NOMMES,'LONUTI',IBID,R8BID,K8BID,CBID,R8BID,'ABSOLU',
     &            NBABS,1,IBID)

      VABS = '&&ABSCISSES'
      CALL WKVECT (VABS, 'V V R', NBABS, LABS)

      VMES = '&&MESURE'

      CALL JEVEUO (VRANGE, 'L', LRANGE)
      CALL JEVEUO (VNOEUD, 'L', LNOEUD)
      
C RECUPERATION ADRESSE DES NUMEROS D'ORDRE ET DU NOM SYMBOLIQUE
C
      CALL JEVEUO ( NOMMES//'           .ORDR' , 'L' , LORD )

      CHS = '&&MESURE.CHS'

C BOUCLE SUR LES NUMEROS ORDRE

      DO 110 NUMORD = 1, NBABS
C        -> EXISTENCE DES CHAMPS DANS LA STRUCTURE DE DONNEES MESURE
        CALL RSEXCH (NOMMES,NOMCHA,ZI(LORD-1+NUMORD),CHAMNO,IRET)
        IF (NUMORD .LE. 1) THEN
          CALL JEVEUO(CHAMNO//'.DESC','L',IDESC)
          GD = ZI(IDESC-1 +1)
          SCAL = SCALAI(GD)
          TYPVAL = SCAL(1:1)
          IF (TYPVAL.EQ.'C') THEN
            ZCMPLX = .TRUE.
            CALL WKVECT (VMES, 'V V C', NBMESU*NBABS, LMESU)
          ELSE
            ZCMPLX = .FALSE.
            CALL WKVECT (VMES, 'V V R', NBMESU*NBABS, LMESU)
          ENDIF
        ENDIF

C RECUPERATION DE L ABSCISSE
        IF((TYPRES(1:9).EQ.'HARM_GENE').OR.
     &     (TYPRES(1:9).EQ.'MODE_GENE')) THEN
          CALL RSADPA(NOMMES,'L',1,'FREQ',NUMORD,0,JABS,K8BID)
        ELSEIF (TYPRES(1:9).EQ.'TRAN_GENE') THEN
          CALL RSADPA(NOMMES,'L',1,'INST',NUMORD,0,JABS,K8BID)
        ENDIF
        ZR(LABS-1 + NUMORD) = ZR(JABS)

C TRANSFORMATION DE CHAMNO EN CHAM_NO_S : CHS
        CALL DETRSD('CHAM_NO_S',CHS)
        CALL CNOCNS(CHAMNO,'V',CHS)
        CALL JEVEUO(CHS//'.CNSK','L',JCNSK)
        CALL JEVEUO(CHS//'.CNSD','L',JCNSD)
        CALL JEVEUO(CHS//'.CNSC','L',JCNSC)
        CALL JEVEUO(CHS//'.CNSV','L',JCNSV)
        CALL JEVEUO(CHS//'.CNSL','L',JCNSL)
       
        NBCMP = ZI(JCNSD-1 + 2)

        DO 120 IMES = 1,NBMESU
          INO = ZI(LNOEUD-1 +IMES)
          KCMP = ZK8(LRANGE-1 +IMES)
          DO 130 ICMP = 1,NBCMP
            INDICE = (INO-1)*NBCMP+ICMP
            IF (ZK8(JCNSC-1 +ICMP) .EQ. KCMP) THEN
              IF (ZCMPLX) THEN
                ZC(LMESU-1 +(NUMORD-1)*NBMESU+IMES) =
     &                 ZC(JCNSV-1 +INDICE)
              ELSE
                ZR(LMESU-1 +(NUMORD-1)*NBMESU+IMES) =
     &                 ZR(JCNSV-1 +INDICE)
              ENDIF
            ENDIF
 130      CONTINUE
 120    CONTINUE

C FIN BOUCLE SUR NUMERO ORDRE
 110   CONTINUE

C GESTION PARAMETRES DE REGULARISATION
      CALL GETVR8 ('RESOLUTION','COEF_PONDER',1,1,0, R8BID, NCOEF)
      CALL GETVID
     &      ('RESOLUTION', 'COEF_PONDER_F', 1, 1, 0, K8BID, NFONC)
      IOCC = ABS(NCOEF) + ABS(NFONC)
      IF ((NCOEF .EQ. 0) .AND. (NFONC .EQ. 0)) IOCC = 0

      IF ((IOCC .EQ. 0) .OR. (KREG .EQ. 'NON')) THEN
C CAS SANS REGULARISATION : PAR DEFAUT
        LFONCT = .FALSE.
        CALL WKVECT (NOMCMD//'.PONDER', 'V V R', NBMODE, LCOEF)
        DO 5 I = 1, NBMODE
          ZR(LCOEF-1 + I) = 0.D0
 5      CONTINUE
      ELSE
        CALL GETVR8 ('RESOLUTION','COEF_PONDER',1,1,0, R8BID, NCOEF)
        IF (-NCOEF .GT. 0) THEN
C CAS DE REGULARISATION SOUS FORME DE LISTE DE REELS
          LFONCT = .FALSE.
          IF (-NCOEF .GT. NBMODE) THEN
            CALL UTMESS ('F', NOMROU,
     &        'LE NOMBRE DES COEFFICIENTS DE PONDERATION EST '//
     &        'SUPERIEUR AU NOMBRE DE VECTEURS DE BASE' )
          ENDIF
          IF (-NCOEF .GT. 0) THEN
            CALL WKVECT (NOMCMD//'.PONDER', 'V V R', NBMODE, LCOEF)
            CALL GETVR8 ('RESOLUTION', 'COEF_PONDER',
     &        1, 1, -NCOEF, ZR(LCOEF), NCOEF)
          END IF
          IF (NCOEF .LT. NBMODE) THEN
            CALL UTMESS ('I', NOMROU,
     &        'LE NOMBRE DES COEFFICIENTS DE PONDERATION EST '//
     &        'INFERIEUR AU NOMBRE DE VECTEURS DE BASE , ' //
     &        'LE DERNIER COEFFICIENT EST AFFECTE AUX AUTRES' )
            DO 10 I = NCOEF + 1, NBMODE
               ZR(LCOEF-1 + I) = ZR(LCOEF-1 + NCOEF)
 10         CONTINUE
          ENDIF
        ELSE
C CAS DE REGULARISATION SOUS FORME DE LISTE DE FONCTIONS
          LFONCT = .TRUE.
          CALL GETVID
     &      ('RESOLUTION', 'COEF_PONDER_F', 1, 1, 0, K8BID, NFONC)
          IF (-NFONC .GT. NBMODE) CALL UTMESS ('F', NOMROU,
     &      'LE NOMBRE DES FONCTIONS DE PONDERATION EST '//
     &      'SUPERIEUR AU NOMBRE DE VECTEURS DE BASE' )
          IF (-NFONC .GT. 0) THEN
            CALL WKVECT (NOMCMD//'.FONC', 'V V K8', NBMODE, LFONC)
            CALL GETVID ('RESOLUTION', 'COEF_PONDER_F',
     &        1, 1, -NFONC, ZK8(LFONC), NFONC)
          END IF
          IF (NFONC .GT. 0 .AND. NFONC .LT. NBMODE) THEN
            CALL UTMESS ('I', NOMROU,
     &        'LE NOMBRE DES FONCTIONS DE PONDERATION EST '//
     &        'INFERIEUR AU NOMBRE DE VECTEURS DE BASE ' // 
     &        'LA DERNIERE FONCTION EST AFFECTEE AUX AUTRES' )
            DO 200 I = NFONC + 1 , NBMODE
              ZK8(LFONC-1 + I) = ZK8(LFONC-1 + NFONC)
 200        CONTINUE
          END IF
          CALL WKVECT (NOMCMD//'.PONDER', 'V V R', NBMODE*NBABS, LCOEF)
          DO 210 I = 1 , NBMODE
            CALL JELIRA (ZK8(LFONC-1 + I)//'           .VALE',
     &          'LONMAX', LONMAX, K8BID)
            IF (LONMAX .NE. 2*NBABS) CALL UTMESS ('F', NOMROU,
     &  'LE NOMBRE D ABSCISSES D UNE DES FONCTIONS D INTERPOLATION '//
     &  'N EST PAS IDENTIQUE AU NOMBRE D ABSCISSES DU PREMIER '// 
     &  'POINT DE MESURE EXPERIMENTAL '   )
C
            CALL JEVEUO 
     &        (ZK8(LFONC-1 + I)//'           .VALE', 'L', LVALE)
            DO 220 J = 1 , NBABS
              DIFF = ZR(LVALE-1 + J) - ZR(LABS-1 + J)
              IF (J . EQ . 1) THEN 
                PAS = ZR(LABS + 1) - ZR(LABS)
              ELSE 
                PAS = ZR(LABS-1 + J) - ZR(LABS-1 + J - 1)
              END IF
              IF (ABS(DIFF) .GT. PAS*1.D-4 )
     &            CALL UTMESS ('F', NOMROU,
     & ' LE CRITERE D EGALITE DE LA LISTE D ABSCISSES DU PREMIER ' //
     & ' DATASET 58 ET DE LA LISTE D ABSCISSES D UNE DES FONCTIONS ' // 
     & ' DE PONDERATION N EST PAS VERIFIE ' )
C
              ZR(LCOEF-1 + (J - 1)*NBMODE + I) = 
     &          ZR(LVALE-1 + (LONMAX/2) + J)
 220        CONTINUE
 210      CONTINUE
        ENDIF
C FIN TEST SUR TYPE DE PONDERATION : REELS / LISTE DE FONCTIONS
      ENDIF
C FIN GESTION PARAMETRES DE REGULARISATION 


C INITIALISATION POUR ALLOCATION DU TRAN_GENE
C
      LPSTO = .FALSE.
      DT = (ZR(LABS-1 +NBABS) - ZR(LABS))/NBABS
C
C RECUPERATION DE LA MATRICE MODALE PROJETEE 
C
      CALL JEVEUO (BASEPR, 'L', LRED)
C
C ALLOCATION DE TRAN_GENE OU HARM_GENE ET RESOLUTION DU SYSTEME
C
      IF (.NOT. ZCMPLX) THEN
C SECOND MEMBRE REEL
        IF (TYPRES(1:9).EQ.'HARM_GENE') 
     &      CALL UTMESS ('F', NOMROU,
     &        'INCOMPATIBILITE NOM_PARA ET DONNEES MESUREES ')
        IF (TYPRES(1:9).EQ.'TRAN_GENE') THEN
          CALL MDALLO
     &    (NOMRES, NOMBAS, K8B, K8B, K8B, NBMODE, DT, NBABS,
     &     NULL, K8BID, K8BID, NULL, K8BID, NULL, 
     &     JDEP, JVIT, JACC, JPASS, JORDR, JABS, JFCHO, JDCHO,
     &     JVCHO, JICHO, JREDC, JREDD, LPSTO, K8B)

          CALL MPINV2 (NBMESU, NBMODE, NBABS, 
     &              ZR(LRED), ZR(LMESU), ZR(LCOEF), ZR(LABS), 
     &              LFONCT, ZR(JDEP), ZR(JVIT), ZR(JACC))

         ELSEIF (TYPRES(1:9).EQ.'MODE_GENE') THEN
          CALL WKVECT (NOMCMD//'.RETA', 'V V R', NBMODE*NBABS, JDEP)
          CALL MPINVR (NBMESU, NBMODE, NBABS, 
     &              ZR(LRED), ZR(LMESU), ZR(LCOEF), ZR(LABS), 
     &              LFONCT, ZR(JDEP))
C
C On cree une sd de type mode_gene
           CALL RSCRSD (NOMRES, 'MODE_GENE', NBABS )           
C On remplie la sd de type mode_gene a partir de la base d'expansion 
           CALL MDALLR(NOMRES, NOMBAS,NBMODE,NBABS,ZR(JDEP),CBID,
     &                 ZR(LABS), ZCMPLX)
         ENDIF
C
      ELSE
C SECOND MEMBRE COMPLEXE
        IF (TYPRES(1:9).EQ.'HARM_GENE') THEN
        CALL MDALLC
     &    (NOMRES, NOMBAS, K8B, K8B, K8B, NBMODE,
     &     NBABS, NULL, 
     &     NULL, K8BID, NULL, 
     &    JDEP, JVIT, JACC, JORDR, JABS,
     &    JREDC, JREDD, K8B)

        CALL MPINVC (NBMESU, NBMODE, NBABS, 
     &              ZR(LRED), ZC(LMESU), ZR(LCOEF), ZR(LABS), 
     &              LFONCT, ZC(JDEP), ZC(JVIT), ZC(JACC))
       ELSEIF (TYPRES(1:9).EQ.'MODE_GENE') THEN
          CALL WKVECT (NOMCMD//'.RETA', 'V V C', NBMODE*NBABS, JDEP)
          CALL WKVECT (NOMCMD//'.RET1', 'V V C', NBMODE*NBABS, JVIT)
          CALL WKVECT (NOMCMD//'.RET2', 'V V C', NBMODE*NBABS, JACC)
          CALL MPINVC (NBMESU, NBMODE, NBABS,
     &              ZR(LRED), ZC(LMESU), ZR(LCOEF), ZR(LABS), 
     &              LFONCT, ZC(JDEP), ZC(JVIT), ZC(JACC))
C On cree une sd de type mode_gene
           CALL RSCRSD (NOMRES, 'MODE_GENE', NBABS )           
C On remplie la sd de type mode_gene a partir de la base d'expansion 
           CALL MDALLR(NOMRES, NOMBAS,NBMODE,NBABS,RBID,ZC(JDEP),
     &                 ZR(LABS),ZCMPLX)
       ELSE
        CALL UTMESS ('F', NOMROU,
     &        'INCOMPATIBILITE NOM_PARA ET DONNEES MESUREES ')
       ENDIF
C
      ENDIF
C
C REMPLISSAGE DES OBJETS MANQUANTS
C
      CALL JEVEUO (NOMRES//'           .ORDR', 'E', JORDR)
      IF (TYPRES(1:9).NE.'TRAN_GENE') THEN
        CALL JEVEUO (NOMRES//'           .FREQ', 'E', JABS)
        IF (TYPRES(1:9).EQ.'MODE_GENE') THEN
          CALL JEVEUO (NOMRES//'           .NUMO', 'E', JNUMO)          
        ENDIF
      ELSE
        CALL JEVEUO (NOMRES//'           .INST', 'E', JABS)
      ENDIF
C
      DO 400 I = 1 , NBABS 
        ZR(JABS-1 + I) = ZR(LABS-1 + I)
        IF (TYPRES(1:9).EQ.'MODE_GENE') THEN
          ZI(JNUMO-1 + I) = I
          ZI(JORDR-1 + I) = I
        ELSE  
          ZI(JORDR-1 + I) = I - 1
        ENDIF
 400  CONTINUE
C
      CALL JEDETR (VABS)
      CALL JEDETR (VMES)
      CALL JEDETR (VRANGE)
      CALL JEDETR (VNOEUD)
      CALL JEDETR (BASEPR)
      CALL DETRSD('CHAM_NO_S',CHS)

      CALL JEDEMA ()
C
      END
