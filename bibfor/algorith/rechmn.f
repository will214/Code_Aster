      SUBROUTINE RECHMN(NOMA  ,NEWGEO,DEFICO,RESOCO,IZONE,
     &                  IESCL0)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 13/03/2007   AUTEUR ABBAS M.ABBAS 
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
C RESPONSABLE ABBAS M.ABBAS
C
      IMPLICIT     NONE
      INTEGER      IZONE
      CHARACTER*8  NOMA
      CHARACTER*24 DEFICO
      CHARACTER*24 RESOCO
      CHARACTER*24 NEWGEO
      INTEGER      IESCL0 
C      
C ----------------------------------------------------------------------
C
C ROUTINE CONTACT (METHODES DISCRETES - APPARIEMENT - MAIT/ESCL)
C
C RECHERCHE DU NOEUD MAITRE LE PLUS PROCHE DU NOEUD ESCLAVE
C
C ----------------------------------------------------------------------
C
C
C IN  NOMA   : NOM DU MAILLAGE
C IN  IZONE  : NUMERO DE LA ZONE DE CONTACT
C IN  NEWGEO : GEOMETRIE ACTUALISEE EN TENANT COMPTE DU CHAMP DE
C              DEPLACEMENTS COURANT
C IN  DEFICO : SD DE DEFINITION DU CONTACT (ISSUE D'AFFE_CHAR_MECA)
C IN  RESOCO : SD DE TRAITEMENT NUMERIQUE DU CONTACT
C IN  IESCL0 : PREMIER NOEUD ESCLAVE DE LA ZONE
C OUT NFESCL : NOMBRE DE NOEUDS ESCLAVES DE LA ZONE
C
C -------------- DEBUT DECLARATIONS NORMALISEES JEVEUX -----------------
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
C ---------------- FIN DECLARATIONS NORMALISEES JEVEUX -----------------
C
      INTEGER      CFMMVD,CFDISI,ZAPME,ZREAC,ZAPPA
      CHARACTER*24 NDIMCO,PZONE,PSURNO,CONTNO,SYMECO
      INTEGER      JDIM,JZONE,JSUNO,JNOCO,JSYME
      CHARACTER*24 PSANS,SANSNO,APMEMO,APPARI,PMANO
      INTEGER      JCOOR,JPSANS,JSANS,JAPMEM,JAPPAR,JPOMA
      CHARACTER*24 MANOCO,PNOMA,NOMACO,APREAC
      INTEGER      JMANO,JPONO,JNOMA,JREAC
      REAL*8       DMIN
      INTEGER      NBNOE,NSYME,NZOCO,NZOCP
      INTEGER      ISURFE,ISURFM,JDECE,OLDPOS
      INTEGER      POSESC,PROJ
      INTEGER      KE,IBID,IESCL
      INTEGER      POSMIN,SUPPOK,REAPPA
      INTEGER      IFM,NIV
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()      
      CALL INFDBG('CONTACT',IFM,NIV)    
C   
C --- AFFICHAGE
C
      CALL CFIMPE(IFM,NIV,'RECHMN',1)
C
C --- LECTURE DES STRUCTURES DE DONNEES DE CONTACT
C
      NDIMCO = DEFICO(1:16)//'.NDIMCO'
      SYMECO = DEFICO(1:16)//'.SYMECO'      
      PZONE  = DEFICO(1:16)//'.PZONECO'
      CONTNO = DEFICO(1:16)//'.NOEUCO'
      PSURNO = DEFICO(1:16)//'.PSUNOCO'
      SANSNO = DEFICO(1:16)//'.SSNOCO'
      PSANS  = DEFICO(1:16)//'.PSSNOCO'
      MANOCO = DEFICO(1:16)//'.MANOCO'
      PMANO  = DEFICO(1:16)//'.PMANOCO'
      NOMACO = DEFICO(1:16)//'.NOMACO'
      PNOMA  = DEFICO(1:16)//'.PNOMACO'
      APPARI = RESOCO(1:14)//'.APPARI'
      APMEMO = RESOCO(1:14)//'.APMEMO'
      APREAC = RESOCO(1:14)//'.APREAC'      
C
      CALL JEVEUO(NDIMCO,'E',JDIM  )
      CALL JEVEUO(PZONE, 'L',JZONE )
      CALL JEVEUO(SYMECO,'L',JSYME)     
      CALL JEVEUO(CONTNO,'L',JNOCO )
      CALL JEVEUO(PSURNO,'L',JSUNO )
      CALL JEVEUO(SANSNO,'L',JSANS )
      CALL JEVEUO(PSANS, 'L',JPSANS)
      CALL JEVEUO(MANOCO,'L',JMANO )
      CALL JEVEUO(PMANO, 'L',JPOMA )
      CALL JEVEUO(NOMACO,'L',JNOMA )
      CALL JEVEUO(PNOMA, 'L',JPONO )
      CALL JEVEUO(NEWGEO(1:19)//'.VALE','L',JCOOR)
      CALL JEVEUO(APPARI,'E',JAPPAR)
      CALL JEVEUO(APMEMO,'E',JAPMEM)
      CALL JEVEUO(APREAC,'L',JREAC )      
C
C --- INITIALISATION DE VARIABLES
C
      NZOCO  = CFDISI(DEFICO,'NZOCO'      ,IZONE)
      NSYME  = ZI(JSYME)
      ZAPME  = CFMMVD('ZAPME')
      ZAPPA  = CFMMVD('ZAPPA')      
      ZREAC  = CFMMVD('ZREAC')      
      NZOCP  = NZOCO - NSYME     
C
C --- TYPE DE RECHERCHE DU NOEUD
C
      REAPPA = ZI(JREAC+ZREAC*(IZONE-1)+0)    
C
C --- TYPE DE PROJECTION (LINAIRE/QUADRATIQUE)
C
      PROJ   = CFDISI(DEFICO,'PROJECTION',IZONE)          
C
C --- ISURFE : NUMERO DE LA SURFACE ESCLAVE
C --- ISURFM : NUMERO DE LA SURFACE MAITRE
C
      ISURFM = ZI(JZONE+IZONE-1) + 1
      ISURFE = ZI(JZONE+IZONE)
C
C --- NOMBRE DE NOEUDS DE LA SURFACE ESCLAVE
C
      NBNOE = ZI(JSUNO+ISURFE) - ZI(JSUNO+ISURFE-1)
C
C --- DECALAGE DANS CONTNO POUR TROUVER LES NOEUDS DE LA SURFACE ESCLAVE
C
      JDECE = ZI(JSUNO+ISURFE-1)
C
C --- NOMBRE DE NOEUDS ESCLAVES DE LA ZONE A PRIORI
C
      ZI(JDIM+8+IZONE) = NBNOE 
C
C --- PREMIER NOEUD ESCLAVE DE LA ZONE
C
      IESCL    = IESCL0      
C
C --- APPARIEMENT PAR METHODE "BRUTE FORCE"
C --- DOUBLE BOUCLE SUR LES NOEUDS
C
      IF (REAPPA.EQ.1) THEN

        DO 50 KE = 1,NBNOE
C
C --- POSITION DANS CONTNO DU NOEUD DE LA SURFACE ESCLAVE
C
          POSESC   = JDECE + KE
C
C --- ON REGARDE SI LE NOEUD EST INTERDIT COMME ESCLAVE
C
          IF (IZONE.LE.NZOCP) THEN
            CALL CFELSN(IZONE ,NOMA,  POSESC,JDIM  ,JAPMEM,
     &                  JNOCO ,JPSANS,JSANS ,SUPPOK)
            IF (SUPPOK.EQ.1) THEN
              GOTO 50
            ENDIF
          ENDIF
C
C --- RECHERCHE DU NOEUD MAITRE LE PLUS PROCHE PAR FORCE BRUTE
C
          CALL RECHP1(ZR(JCOOR),ZI(JSUNO),ZI(JNOCO),
     &                KE       ,ISURFE   ,ISURFM   ,POSMIN,IBID  ,
     &                DMIN)        
C
C --- STOCKAGE DU NOEUD ESCLAVE
C           
          ZI(JAPPAR+ZAPPA*(IESCL-1)+1)  = POSESC
C
C --- STOCKAGE DU NOEUD MAITRE LE PLUS PROCHE
C        
          ZI(JAPMEM+ZAPME*(POSESC-1)+1) = POSMIN
C
C --- TYPE DE PROJECTION
C          
          ZI(JAPPAR+ZAPPA*(IESCL-1)+3)  = PROJ 
C
C --- NOUVEAU NOEUD ESCLAVE
C
          IESCL = IESCL + 1
C                    
   50   CONTINUE
C
C --- APPARIEMENT PAR VOISINAGE
C --- ON CHERCHE UN NOEUD CONNECTE A L'ANCIEN NOEUD LE PLUS PROCHE
C --- PAR UNE MAILLE DE CONTACT
C
      ELSE IF (REAPPA.EQ.2) THEN

        DO 110 KE = 1,NBNOE
C
C --- POSITION DANS CONTNO DU NOEUD DE LA SURFACE ESCLAVE
C
          POSESC   = JDECE + KE
C
C --- ON REGARDE SI LE NOEUD EST INTERDIT COMME ESCLAVE
C
          IF (IZONE.LE.NZOCP) THEN
            CALL CFELSN(IZONE ,NOMA,  POSESC,JDIM  ,JAPMEM,
     &                  JNOCO ,JPSANS,JSANS ,SUPPOK)          
            IF (SUPPOK.EQ.1) THEN
              GOTO 110
            ENDIF
          ENDIF
C
C --- ANCIEN NOEUD MAITRE LE PLUS PROCHE
C
          OLDPOS = ZI(JAPMEM+ZAPME*(POSESC-1)+1)
C
C --- RECHERCHE DU NOEUD MAITRE LE PLUS PROCHE PAR VOISINAGE
C               
          CALL RECHP2(ZR(JCOOR),ZI(JSUNO),ZI(JNOCO),
     &                ZI(JMANO),ZI(JPOMA),ZI(JPONO),ZI(JNOMA),
     &                KE       ,ISURFE   ,OLDPOS   ,POSMIN,
     &                IBID     ,DMIN)                    
C
C --- STOCKAGE DU NOEUD ESCLAVE
C           
          ZI(JAPPAR+ZAPPA*(IESCL-1)+1)  = POSESC          
C
C --- STOCKAGE DU NOEUD MAITRE LE PLUS PROCHE
C        
          ZI(JAPMEM+ZAPME*(POSESC-1)+1) = POSMIN 
C
C --- TYPE DE PROJECTION
C          
          ZI(JAPPAR+ZAPPA*(IESCL-1)+3)  = PROJ 
C
C --- NOUVEAU NOEUD ESCLAVE
C
          IESCL = IESCL + 1                                   
  110   CONTINUE
      ELSE 
        CALL U2MESS('F','CONTACT_22')
      END IF        
C
      CALL JEDEMA()
      END
