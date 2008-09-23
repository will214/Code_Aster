      SUBROUTINE NMVCPR(MODELZ,LISCHA,NUMEDD,MATE  ,CARELE,
     &                  COMREF,COMPOR,VALMOI,VALPLU,CNVCPR)
C
C MODIF ALGORITH  DATE 23/09/2008   AUTEUR ABBAS M.ABBAS 
C ======================================================================
C            CONFIGURATION MANAGEMENT OF EDF VERSION
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
C RESPONSABLE MABBAS M.ABBAS
C
      IMPLICIT NONE
      CHARACTER*(*) MODELZ
      CHARACTER*19  LISCHA
      CHARACTER*24  NUMEDD,MATE  ,COMREF,CARELE,COMPOR
      CHARACTER*24  CNVCPR
      CHARACTER*24  VALMOI(8),VALPLU(8)
C
C ----------------------------------------------------------------------
C
C ROUTINE MECA_NON_LINE (CALCUL)
C
C CALCUL DU VECTEUR ASSEMBLE DE LA VARIATION DES VARIABLES DE
C COMMANDE
C
C ----------------------------------------------------------------------
C
C
C IN  MODELE : NOM DU MODELE
C IN  LISCHA : LISTE DES CHARGEMENTS
C IN  NUMEDD : NUMEROTATION
C IN  CARALE : CARACTERISTIQUES ELEMENTAIRES
C IN  MATE   : CHAMP DE MATERIAU
C IN  COMREF : VARI_COM DE REFERENCE
C IN  COMPOR : COMPORTEMENT
C IN  VALMOI : ETAT EN T-
C IN  VALPLU : ETAT EN T+
C OUT CNVCPR : VECTEUR ASSEMBLE DE LA VARIATION F_INT PAR RAPPORT
C              AUX VARIABLES DE COMMANDE
C
C -------------- DEBUT DECLARATIONS NORMALISEES JEVEUX -----------------
C
      INTEGER ZI
      COMMON /IVARJE/ ZI(1)
      REAL*8 ZR
      COMMON /RVARJE/ ZR(1)
      COMPLEX*16 ZC
      COMMON /CVARJE/ ZC(1)
      LOGICAL ZL
      COMMON /LVARJE/ ZL(1)
      CHARACTER*8 ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
      COMMON /KVARJE/ ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C
C ---------------- FIN DECLARATIONS NORMALISEES JEVEUX -----------------
C
      INTEGER      NBOUT,NBIN
      PARAMETER    (NBOUT=1, NBIN=18)
      CHARACTER*8  LPAOUT(NBOUT),LPAIN(NBIN)
      CHARACTER*19 LCHOUT(NBOUT),LCHIN(NBIN)
C
      LOGICAL      EXITEM,EXIHYD,EXISEC,EXIEPA,EXIPHA
      LOGICAL      LBID,EXIPH1,EXIPH2
      INTEGER      IRET
      REAL*8       X(2)
      CHARACTER*19 VECEL(2),VECELP,VECELM
      CHARACTER*8  MODELE
      CHARACTER*24 DEPMOI,SIGMOI, VARMOI, COMMOI,COMPLU
      CHARACTER*24 VRCPLU,INSPLU
      CHARACTER*24 VRCMOI,INSMOI
      CHARACTER*24 CHGEOM,CHCARA(15), CHVREF
      CHARACTER*24 K24BID
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
C
C --- INITIALISATIONS
C
      CHVREF = '&&NMVCPR.VREF'
      MODELE = MODELZ
      VECELM = '&&VEVCOM           '
      VECELP = '&&VEVCOP           '
C
C --- DECOMPACTION DES VARIABLES CHAPEAUX
C
      CALL DESAGG(VALMOI,DEPMOI,SIGMOI,VARMOI,COMMOI,
     &            K24BID,K24BID,K24BID,K24BID)
      CALL DESAGG(VALPLU,K24BID,K24BID,K24BID,COMPLU,
     &            K24BID,K24BID,K24BID,K24BID)
C
C --- INITIALISATION DES CHAMPS POUR CALCUL
C
      CALL INICAL(NBIN  ,LPAIN ,LCHIN ,
     &            NBOUT ,LPAOUT,LCHOUT)
C
C --- LECTURE DES VARIABLES DE COMMANDE EN T- ET T+ ET VAL. DE REF
C
      CALL NMVCEX('TOUT',COMREF,CHVREF)
      CALL NMVCEX('TOUT',COMPLU,VRCPLU)
      CALL NMVCEX('INST',COMPLU,INSPLU)
      CALL NMVCEX('TOUT',COMMOI,VRCMOI)
      CALL NMVCEX('INST',COMMOI,INSMOI)
C
C --- VARIABLES DE COMMANDE PRESENTES
C
      CALL NMVCD2('HYDR'      ,MATE,EXIHYD,LBID)
      CALL NMVCD2('SECH'      ,MATE,EXISEC,LBID)
      CALL NMVCD2('EPSA'      ,MATE,EXIEPA,LBID)
      CALL NMVCD2('META_ZIRC' ,MATE,EXIPH1,LBID)
      CALL NMVCD2('META_ACIER',MATE,EXIPH2,LBID)
      CALL NMVCD2('TEMP',MATE,EXITEM,LBID)
      EXIPHA = EXITEM .AND. (EXIPH1.OR.EXIPH2)
C
C --- CHAMP DE GEOMETRIE
C
      CALL MEGEOM(MODELE,' ' ,LBID  ,CHGEOM)
C
C --- CHAMP DE CARACTERISTIQUES ELEMENTAIRES
C
      CALL MECARA(CARELE(1:8),LBID  ,CHCARA)
C
C --- PREPARATION DES VECT_ELEM  (CINQ VARIABLES DE COMM EN DUR !)
C
      CALL JEEXIN(VECELM//'.RELR',IRET)
      IF (IRET.EQ.0) THEN
        CALL MEMARE('V',VECELM,MODELE,MATE,CARELE,'CHAR_MECA')
        CALL MEMARE('V',VECELP,MODELE,MATE,CARELE,'CHAR_MECA')
      END IF
      CALL JEDETR(VECELM//'.RELR')
      CALL JEDETR(VECELP//'.RELR')
      CALL REAJRE(VECELM,' ','V')
      CALL REAJRE(VECELP,' ','V')

C
C --- REMPLISSAGE DES CHAMPS D'ENTREE
C
      LPAIN(1)  = 'PVARCRR'
      LCHIN(1)  =  CHVREF
      LPAIN(2)  = 'PGEOMER'
      LCHIN(2)  =  CHGEOM
      LPAIN(3)  = 'PMATERC'
      LCHIN(3)  =  MATE
      LPAIN(4)  = 'PCACOQU'
      LCHIN(4)  =  CHCARA(7)
      LPAIN(5)  = 'PCAGNPO'
      LCHIN(5)  =  CHCARA(6)
      LPAIN(6)  = 'PCADISM'
      LCHIN(6)  =  CHCARA(3)
      LPAIN(7)  = 'PCAORIE'
      LCHIN(7)  =  CHCARA(1)
      LPAIN(8)  = 'PCAGNBA'
      LCHIN(8)  =  CHCARA(11)
      LPAIN(9)  = 'PCAARPO'
      LCHIN(9)  =  CHCARA(9)
      LPAIN(10) = 'PCAMASS'
      LCHIN(10) =  CHCARA(12)
      LPAIN(11) = 'PCAGEPO'
      LCHIN(11) =  CHCARA(5)
      LPAIN(12) = 'PCONTMR'
      LCHIN(12) =  SIGMOI
      LPAIN(13) = 'PVARIPR'
      LCHIN(13) =  VARMOI
      LPAIN(14) = 'PCOMPOR'
      LCHIN(14) =  COMPOR
      LPAIN(17) =  'PNBSP_I'
      LCHIN(17) =  CHCARA(1) (1:8)//'.CANBSP'
      LPAIN(18) = 'PFIBRES'
      LCHIN(18) =  CHCARA(1) (1:8)//'.CAFIBR'
C
C --- REMPLISSAGE DU CHAMP DE SORTIE
C
      LPAOUT(1) = 'PVECTUR'
C
C --- CALCUL DES OPTIONS EN T+
C
      LPAIN(15) = 'PTEMPSR'
      LCHIN(15) =  INSPLU
      LPAIN(16) = 'PVARCPR'
      LCHIN(16) =  VRCPLU
      CALL NMVCCC(MODELE,NBIN  ,NBOUT ,LPAIN ,LCHIN ,
     &            LPAOUT,LCHOUT,EXITEM,EXIHYD,EXISEC,
     &            EXIEPA,EXIPHA,VECELP)
C
C --- CALCUL DES OPTIONS EN T-
C
C --- CALCUL DES PHASES DEJA INCREMENTAL !
C
      EXIPHA    = .FALSE.
      LPAIN(15) = 'PTEMPSR'
      LCHIN(15) =  INSMOI
      LPAIN(16) = 'PVARCPR'
      LCHIN(16) =  VRCMOI
      CALL NMVCCC(MODELE,NBIN  ,NBOUT ,LPAIN ,LCHIN ,
     &            LPAOUT,LCHOUT,EXITEM,EXIHYD,EXISEC,
     &            EXIEPA,EXIPHA,VECELM)
C
C --- ASSEMBLAGE
C
      X(1) =  1
      X(2) = -1
      VECEL(1) = VECELP
      VECEL(2) = VECELM
      CALL ASSVEC ('V',CNVCPR,2,VECEL,X,NUMEDD,' ','ZERO',1)
C
      CALL JEDEMA()
      END
