      SUBROUTINE CFINIT(MAILLA,FONACT,DEFICO,RESOCO,NUMINS,
     &                  SDDYNA,VALMOI,VALPLU)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 10/08/2009   AUTEUR DESOZA T.DESOZA 
C ======================================================================
C COPYRIGHT (C) 1991 - 2005  EDF R&D                  WWW.CODE-ASTER.ORG
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
C RESPONSABLE MABBAS M.ABBAS
C
      IMPLICIT     NONE
      CHARACTER*8  MAILLA
      CHARACTER*24 DEFICO,RESOCO
      INTEGER      NUMINS
      LOGICAL      FONACT(*)
      CHARACTER*24 VALMOI(8),VALPLU(8)
      CHARACTER*19 SDDYNA
C      
C ----------------------------------------------------------------------
C
C ROUTINE MECA_NON_LINE (INITIALISATION CONTACT)
C
C INITIALISATION DES PARAMETRES DE CONTACT POUR LE NOUVEAU PAS DE
C TEMPS
C
C ----------------------------------------------------------------------
C
C
C IN  FONACT : FONCTIONNALITES ACTIVEES
C IN  DEFICO : SD DEFINITION DU CONTACT
C IN  RESOCO : SD RESOLUTION DU CONTACT
C IN  SDDYNA : SD DYNAMIQUE 
C IN  VALMOI : VARIABLE CHAPEAU POUR ETAT EN T-
C IN  VALPLU : VARIABLE CHAPEAU POUR ETAT EN T+
C IN  NUMINS : NUMERO INSTANT COURANT
C
C -------------- DEBUT DECLARATIONS NORMALISEES JEVEUX -----------------
C
      INTEGER            ZI
      COMMON  / IVARJE / ZI(1)
      REAL*8             ZR
      COMMON  / RVARJE / ZR(1)
      COMPLEX*16         ZC
      COMMON  / CVARJE / ZC(1)
      LOGICAL            ZL
      COMMON  / LVARJE / ZL(1)
      CHARACTER*8        ZK8
      CHARACTER*16                ZK16
      CHARACTER*24                          ZK24
      CHARACTER*32                                    ZK32
      CHARACTER*80                                              ZK80
      COMMON  / KVARJE / ZK8(1) , ZK16(1) , ZK24(1) , ZK32(1) , ZK80(1)
C
C ---------------- FIN DECLARATIONS NORMALISEES JEVEUX -----------------
C
      INTEGER      CFDISI,CFMMVD
      INTEGER      II,IBID,IZONE,NEQ,NTPC,IPC
      INTEGER      VECONT(2)
      LOGICAL      LREAC(3)
      CHARACTER*24 CLREAC,CIREAC
      INTEGER      JCLREA,JCIREA
      CHARACTER*24 AUTOC1,AUTOC2 
      INTEGER      JAUTO1,JAUTO2 
      CHARACTER*24 TABFIN,ETATCT
      INTEGER      JTABF ,JETAT
      INTEGER      ZTABF ,ZETAT
      REAL*8       R8BID 
      LOGICAL      ISFONC,NDYNLO,LCTCD,LCTCC,LCTCV,LXFCM,LTFCM,LDYNA
      CHARACTER*24 K24BID,K24BLA,DEPMOI,VITPLU,ACCPLU  
      CHARACTER*8  K8BID    
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ() 
C 
C --- FONCTIONNALITES ACTIVEES
C     
      LDYNA  = NDYNLO(SDDYNA,'DYNAMIQUE')
      LCTCD  = ISFONC(FONACT,'CONT_DISCRET')
      LCTCC  = ISFONC(FONACT,'CONT_CONTINU')
      LCTCV  = ISFONC(FONACT,'CONT_VERIF')
      LXFCM  = ISFONC(FONACT,'CONT_XFEM')
      LTFCM  = .FALSE.
      IF (LXFCM) THEN
        CALL MMINFP(0    ,DEFICO,K24BLA,'XFEM_GG',
     &              IBID ,R8BID ,K24BID,LTFCM)
      ENDIF        
      K24BLA = ' '
C
C --- DECOMPACTION VARIABLES CHAPEAUX
C       
      CALL DESAGG(VALMOI,DEPMOI,K24BID,K24BID,K24BID,
     &            K24BID,K24BID,K24BID,K24BID)
      CALL DESAGG(VALPLU,K24BID,K24BID,K24BID,K24BID,
     &            VITPLU,ACCPLU,K24BID,K24BID) 
      CALL JELIRA(DEPMOI(1:19)//'.VALE','LONMAX',NEQ,K8BID)      
C      
      IF (LCTCD) THEN 
C
C --- ACCES OBJETS
C          
        AUTOC1 = RESOCO(1:14)//'.REA1'
        AUTOC2 = RESOCO(1:14)//'.REA2'
        CLREAC = RESOCO(1:14)//'.REAL' 
        CIREAC = RESOCO(1:14)//'.REAI'                
        CALL JEVEUO(AUTOC1(1:19)//'.VALE','E',JAUTO1)
        CALL JEVEUO(AUTOC2(1:19)//'.VALE','E',JAUTO2)              
        CALL JEVEUO(CLREAC,'E',JCLREA)
        CALL JEVEUO(CIREAC,'E',JCIREA)     
        LREAC(1) = .FALSE.
        LREAC(2) = .FALSE.
        LREAC(3) = .FALSE.
C
C --- AUTORISATION DE DESTRUCTION DE LA MATRICE TANGENTE (VOIR NMASFR)
C
        IZONE    = 0     

C 
C --- PARAMETRES DE REACTUALISATION GEOMETRIQUE
C       
        VECONT(1) = CFDISI(DEFICO,'REAC_GEOM',IZONE)
        VECONT(2) = 0
        LREAC(1)  = .TRUE.
        DO 10 II = 1, NEQ
         ZR(JAUTO1-1+II) = 0.0D0
         ZR(JAUTO2-1+II) = 0.0D0
10      CONTINUE
C
C --- PAS DE REACTUALISATION GEOMETRIQUE
C
        IF (VECONT(1).EQ.0) THEN
          IF (NUMINS.NE.1) THEN
            LREAC(1) = .FALSE.
          ENDIF
        ENDIF
C
C --- METHODE VERIF: APPARIEMENT FORCE A CHAQUE ITERATION
C         
        IF (LCTCV) THEN
          LREAC(1) = .TRUE.
        ENDIF 
C
C --- SAUVEGARDE
C        
        ZL(JCLREA+1-1) = LREAC(1)
        ZL(JCLREA+2-1) = LREAC(2)
        ZL(JCLREA+3-1) = LREAC(3)
        ZI(JCIREA+1-1) = VECONT(1)
        ZI(JCIREA+2-1) = VECONT(2)                                 
      ENDIF 
C
C --- MISE A ZERO LAGRANGIENS POUR CONTACT CONTINU (LAMBDA TOTAUX)
C      
      IF (LCTCC) THEN
        IF (LTFCM) THEN
          CALL XMISZL(DEPMOI,DEFICO,MAILLA)
        ELSE
          IF (.NOT.LXFCM) THEN
            CALL MISAZL(DEPMOI,DEFICO)
          ENDIF  
        ENDIF

        IF (LDYNA) THEN
          CALL MISAZL(ACCPLU,DEFICO)
          CALL MISAZL(VITPLU,DEFICO)
        END IF 
C
C ---   RETABLISSEMENT DE L ETAT DE CONTACT DU DERNIER PAS CONVERGE
C ---   POUR PERMETTRE LE REDECOUPAGE (CF. MMMRES)
C

        IF (.NOT.LXFCM) THEN
          TABFIN = DEFICO(1:16)//'.TABFIN'
          ETATCT = RESOCO(1:14)//'.ETATCT'
          CALL JEVEUO(TABFIN,'E',JTABF)
          ZTABF = CFMMVD('ZTABF')
          CALL JEVEUO(ETATCT,'L',JETAT)
          ZETAT = CFMMVD('ZETAT')
          NTPC = NINT(ZR(JTABF-1+1))
          DO 100 IPC = 1,NTPC
            ZR(JTABF+ZTABF*(IPC-1)+13) = ZR(JETAT-1+ZETAT*(IPC-1)+1)
            ZR(JTABF+ZTABF*(IPC-1)+14) = ZR(JETAT-1+ZETAT*(IPC-1)+2)
            ZR(JTABF+ZTABF*(IPC-1)+21) = ZR(JETAT-1+ZETAT*(IPC-1)+3)
            ZR(JTABF+ZTABF*(IPC-1)+30) = ZR(JETAT-1+ZETAT*(IPC-1)+4)
100       CONTINUE
        ENDIF
      ENDIF          
C 
      CALL JEDEMA()

      END
