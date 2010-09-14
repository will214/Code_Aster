      SUBROUTINE NMELCV(PHASE ,MODELE,DEFICO,RESOCO,MATE  ,DEPMOI,
     &                  DEPDEL,VITMOI,VITPLU,ACCMOI,VECTCE)
C     
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 14/09/2010   AUTEUR ABBAS M.ABBAS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2009  EDF R&D                  WWW.CODE-ASTER.ORG
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
C RESPONSABLE ABBAS M.ABBAS
C
      IMPLICIT NONE
      CHARACTER*4   PHASE      
      CHARACTER*19  VECTCE
      CHARACTER*24  MODELE,DEFICO,RESOCO
      CHARACTER*19  DEPMOI,DEPDEL,ACCMOI,VITMOI,VITPLU
      CHARACTER*(*)  MATE
C      
C ----------------------------------------------------------------------
C
C ROUTINE MECA_NON_LINE (CALCUL - VECTEURS ELEMENTAIRES)
C             
C CALCUL DES VECTEURS ELEMENTAIRES DES ELEMENTS DE CONTACT 
C      
C ----------------------------------------------------------------------
C 
C
C IN  PHASE  : CONTACT OU FROTTEMENT
C IN  DEFICO : SD POUR LA DEFINITION DU CONTACT
C IN  RESOCO : SD POUR LA RESOLUTION DU CONTACT
C IN  DEPMOI : CHAM_NO DES DEPLACEMENTS A L'INSTANT PRECEDENT
C IN  MODELE : NOM DU MODELE
C IN  DEPDEL : INCREMENT DE DEPLACEMENT CUMULE
C IN  ACCMOI : CHAM_NO DES ACCELERATIONS A L'INSTANT PRECEDENT
C IN  VITMOI : CHAM_NO DES VITESSES A L'INSTANT PRECEDENT
C IN  VITPLU : CHAM_NO DES VITESSES A L'INSTANT SUIVANT
C OUT VECTCE : VECT_ELEM DE CONTACT 
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
      INTEGER      NBOUT,NBIN
      PARAMETER    (NBOUT=1, NBIN=25)
      CHARACTER*8  LPAOUT(NBOUT),LPAIN(NBIN)
      CHARACTER*19 LCHOUT(NBOUT),LCHIN(NBIN)
C
      CHARACTER*19 CHGEOM,USUPLU
      LOGICAL      EXIGEO
      CHARACTER*1  BASE      
      INTEGER      IFM,NIV
      LOGICAL      DEBUG
      INTEGER      IFMDBG,NIVDBG        
      CHARACTER*19 LIGREL
      CHARACTER*19 CHMLCF
      CHARACTER*16 OPTION
      CHARACTER*19 CPOINT,CPINTE,CAINTE,CCFACE
      CHARACTER*19 LNNO,LTNO,STANO
      CHARACTER*19 PINTER,AINTER,CFACE,FACLON,BASECO
      CHARACTER*19 XDONCO,XINDCO,XSEUCO,XCOHES      
      LOGICAL      CFDISL,LCTCC,LXFCM,LTFCM,LALLV
      CHARACTER*24 NOSDCO
      INTEGER      JNOSDC   
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
      CALL INFDBG('CONTACT',IFM,NIV)
      CALL INFDBG('PRE_CALCUL',IFMDBG,NIVDBG) 
C
C --- TYPE DE CONTACT      
C
      LALLV  = CFDISL(DEFICO,'ALL_VERIF') 
      IF (LALLV) THEN
        GOTO 99
      ENDIF             
C
C --- AFFICHAGE
C
      IF (NIV.GE.2) THEN
        WRITE (IFM,*) '<CONTACT> CALCUL DES SECDS MEMBRES ELEMENTAIRES'
      ENDIF
C
C --- INITIALISATIONS
C       
      IF (NIVDBG.GE.2) THEN
        DEBUG  = .TRUE.
      ELSE
        DEBUG  = .FALSE.
      ENDIF      
      BASE   = 'V' 
      IF (PHASE.EQ.'CONT') THEN
        OPTION = 'CHAR_MECA_CONT'
      ELSEIF (PHASE.EQ.'FROT') THEN
        OPTION = 'CHAR_MECA_FROT'       
      ELSE    
        CALL ASSERT(.FALSE.)
      ENDIF 
C
C --- TYPE DE CO NTACT
C      
      LCTCC  = CFDISL(DEFICO,'FORMUL_CONTINUE') 
      LXFCM  = CFDISL(DEFICO,'FORMUL_XFEM')
      LTFCM  = CFDISL(DEFICO,'CONT_XFEM_GG')
C
C --- RECUPERATION DE LA GEOMETRIE
C
      CALL MEGEOM(MODELE,' ',EXIGEO,CHGEOM)
      IF (.NOT.EXIGEO) THEN
        CALL ASSERT(.FALSE.)
      ENDIF
C
C --- INITIALISATION DES CHAMPS POUR CALCUL
C
      CALL INICAL(NBIN  ,LPAIN ,LCHIN ,
     &            NBOUT ,LPAOUT,LCHOUT) 
C
C --- CHOIX DU LIGREL
C
      NOSDCO = RESOCO(1:14)//'.NOSDCO'
      CALL JEVEUO(NOSDCO,'L',JNOSDC)
      IF (LCTCC) THEN
        LIGREL = ZK24(JNOSDC+2-1)(1:19)
      ELSEIF (LXFCM) THEN 
        IF (LTFCM) THEN 
          LIGREL = ZK24(JNOSDC+3-1)(1:19)
        ELSE  
          LIGREL = MODELE(1:8)//'.MODELE' 
        ENDIF
      ELSE
        CALL ASSERT(.FALSE.)
      ENDIF
C
C --- INITIALISATIONS DES CHAMPS
C
      CPOINT = ' '
      CPINTE = ' '
      CAINTE = ' '
      CCFACE = ' '          
      LNNO   = ' '    
      LTNO   = ' '
      PINTER = ' '
      AINTER = ' '
      CFACE  = ' '
      FACLON = ' '
      BASECO = ' '
      STANO  = ' '
      XINDCO = ' '
      XDONCO = ' '  
      XSEUCO = ' '
      CHMLCF = ' '
      USUPLU = ' '
      XCOHES = ' '
C
C --- CHAMPS METHODE CONTINUE
C
      IF (LCTCC) THEN
C ----- CHAM_ELEM POUR ELEMENTS TARDIFS DE CONTACT/FROTTEMENT
        CHMLCF = RESOCO(1:14)//'.CHML'
C ----- CARTE USURE
        USUPLU = RESOCO(1:14)//'.USUP'      
      ENDIF
C
C --- CHAMPS METHODE XFEM (PETITS GLISSEMENTS)
C
      IF (LXFCM) THEN
        XINDCO = RESOCO(1:14)//'.XFIN'
        XDONCO = RESOCO(1:14)//'.XFDO'      
        XSEUCO = RESOCO(1:14)//'.XFSE' 
        XCOHES = RESOCO(1:14)//'.XCOH'       
        LNNO   = MODELE(1:8)//'.LNNO'     
        LTNO   = MODELE(1:8)//'.LTNO'
        PINTER = MODELE(1:8)//'.TOPOFAC.OE'
        AINTER = MODELE(1:8)//'.TOPOFAC.AI'
        CFACE  = MODELE(1:8)//'.TOPOFAC.CF'
        FACLON = MODELE(1:8)//'.TOPOFAC.LO'
        BASECO = MODELE(1:8)//'.TOPOFAC.BA'
        STANO  = MODELE(1:8)//'.STNO'     
      ENDIF 
C
C --- CHAMPS METHODE XFEM (GRANDS GLISSEMENTS)
C
      IF (LTFCM) THEN
        CPOINT = RESOCO(1:14)//'.XFPO'
        CPINTE = RESOCO(1:14)//'.XFPI'
        CAINTE = RESOCO(1:14)//'.XFAI'
        CCFACE = RESOCO(1:14)//'.XFCF'  
      ENDIF                  
C
C --- CREATION DES LISTES DES CHAMPS IN ET OUT
C --- GEOMETRIE ET DEPLACEMENTS
C
      LPAIN(1)  = 'PGEOMER'
      LCHIN(1)  = CHGEOM(1:19)
      LPAIN(2)  = 'PDEPL_M'
      LCHIN(2)  = DEPMOI(1:19)
      LPAIN(3)  = 'PDEPL_P'
      LCHIN(3)  = DEPDEL(1:19)
      LPAIN(4)  = 'PVITE_M'
      LCHIN(4)  = VITMOI(1:19)
      LPAIN(5)  = 'PACCE_M'
      LCHIN(5)  = ACCMOI(1:19)
      LPAIN(6)  = 'PVITE_P'
      LCHIN(6)  = VITPLU(1:19)    
C
C --- AUTRES CHAMPS IN ET OUT
C
      LPAIN(7)  = 'PCONFR'
      LCHIN(7)  = CHMLCF
      LPAIN(8)  = 'PUSULAR'
      LCHIN(8)  = USUPLU
      LPAIN(9)  = 'PCAR_PT'
      LCHIN(9)  = CPOINT
      LPAIN(10) = 'PCAR_PI'
      LCHIN(10) = CPINTE
      LPAIN(11) = 'PCAR_AI'
      LCHIN(11) = CAINTE
      LPAIN(12) = 'PCAR_CF'
      LCHIN(12) = CCFACE
      LPAIN(13) = 'PINDCOI'
      LCHIN(13) = XINDCO
      LPAIN(14) = 'PDONCO'
      LCHIN(14) = XDONCO
      LPAIN(15) = 'PLSN'
      LCHIN(15) = LNNO
      LPAIN(16) = 'PLST'
      LCHIN(16) = LTNO
      LPAIN(17) = 'PPINTER'
      LCHIN(17) = PINTER
      LPAIN(18) = 'PAINTER'
      LCHIN(18) = AINTER
      LPAIN(19) = 'PCFACE'
      LCHIN(19) = CFACE
      LPAIN(20) = 'PLONCHA'
      LCHIN(20) = FACLON
      LPAIN(21) = 'PBASECO'
      LCHIN(21) = BASECO
      LPAIN(22) = 'PSEUIL'
      LCHIN(22) = XSEUCO
      LPAIN(23) = 'PSTANO'
      LCHIN(23) = STANO
      LPAIN(24) = 'PCOHES'
      LCHIN(24) = XCOHES
      LPAIN(25) = 'PMATERC'
      LCHIN(25) = MATE
C
C --- ON DETRUIT LES VECTEURS ELEMENTAIRES S'ILS EXISTENT
C
      CALL DETRSD('VECT_ELEM',VECTCE)  
C
C --- PREPARATION DES VECTEURS ELEMENTAIRES 
C
      CALL MEMARE('V',VECTCE,MODELE,' ',' ','CHAR_MECA')
C
C --- CHAMPS DE SORTIE
C
      LPAOUT(1) = 'PVECTUR'
      LCHOUT(1) = VECTCE
C
C --- APPEL A CALCUL
C
      IF (DEBUG) THEN
        CALL DBGCAL(OPTION,IFMDBG,
     &              NBIN  ,LPAIN ,LCHIN ,
     &              NBOUT ,LPAOUT,LCHOUT)
      ENDIF
      CALL CALCUL('S',OPTION,LIGREL,NBIN  ,LCHIN ,LPAIN ,
     &                              NBOUT ,LCHOUT,LPAOUT,BASE)
      CALL REAJRE(VECTCE,LCHOUT(1),BASE)    
C
  99  CONTINUE      
C
      CALL JEDEMA()
C
      END
