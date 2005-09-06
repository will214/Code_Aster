      subroutine REACLM(NOMA,DEPPLU,NEWGEO,DEFICO)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 06/09/2005   AUTEUR TORKHANI M.TORKHANI 
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
C ALONG WITH THIS PROGRAM; IF NOT, WRITE TO EDF R&D CODE_ASTER,       
C    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.      
C ======================================================================
      implicit none
      character*8 NOMA
      character*24 DEPPLU,NEWGEO,DEFICO
C.......................................................................
C
C BUT : REACTUALISATION DES SEUILS DE FROTTEMENT PAR LES MULTIPLUCATEURS
C       DE CONTACT
C ...............................................................
C   DECLARATION JEVEUX
C.......................................................................
C
      integer ZI
      common /IVARJE/ ZI(1)
      real*8 ZR
      common /RVARJE/ ZR(1)
      complex*16 ZC
      common /CVARJE/ ZC(1)
      logical ZL
      common /LVARJE/ ZL(1)
      character*8 ZK8
      character*16 ZK16
      character*24 ZK24
      character*32 ZK32
      character*80 ZK80
      common /KVARJE/ ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C
C.......................................................................
C FIN DECLARATION JEVEUX
C.......................................................................
C
      integer JMACO,JMAESC,JTABF,NTMA,NTPC,IMA,POSMA,NBN,INI
      INTEGER JDEC,JDEC0,POSNOE,NUMNOE,NSANS,NUMSAN
      INTEGER IZONE,INO,JNOMA,JPONO,JPSANS,JSANS,JNOCO
      real*8 LAMBDA,LAMBD1,XPG,YPG
      character*24 CONTMA,MAESCL,TABFIN,CONTNO,PNOMA,NOMACO
      CHARACTER*24 PSANS,SANSNO
C----------------------------------------------------------------------
C
      call JEMARQ
C
C --- RECUPERATION DES QCQS DONNEES
C
      CONTMA = DEFICO(1:16) // '.MAILCO'
      MAESCL = DEFICO(1:16) // '.MAESCL'
      TABFIN = DEFICO(1:16) // '.TABFIN'
      CONTNO = DEFICO(1:16) // '.NOEUCO'
      SANSNO = DEFICO(1:16) // '.SSNOCO'
      PSANS  = DEFICO(1:16) // '.PSSNOCO'
      NOMACO = DEFICO(1:16) // '.NOMACO'
      PNOMA  = DEFICO(1:16) // '.PNOMACO'
C
      call JEVEUO(CONTMA,'L',JMACO)
      call JEVEUO(MAESCL,'L',JMAESC)
      call JEVEUO(TABFIN,'E',JTABF)
      CALL JEVEUO(CONTNO,'L',JNOCO)
      CALL JEVEUO(SANSNO,'L',JSANS)
      CALL JEVEUO(PSANS,'L',JPSANS)
      CALL JEVEUO(NOMACO,'L',JNOMA)
      CALL JEVEUO(PNOMA,'L',JPONO)
C
C   BOUCLE SUR LES POINTS DE CONTACT
C
      NTMA = ZI(JMAESC)
      NTPC = 0.d0
      do 20 IMA = 1,NTMA
        POSMA = ZI(JMAESC+3*(IMA-1)+1)
        IZONE = ZI(JMAESC+3*(IMA-1)+2)
        NBN = ZI(JMAESC+3*(IMA-1)+3)
        do 10 INI = 1,NBN
          XPG = ZR(JTABF+21*NTPC+21*(INI-1)+3)
          YPG = ZR(JTABF+21*NTPC+21*(INI-1)+12)
C ---- MODIF POUR SUPPRIMER DES NOEUDS
          JDEC0  = ZI(JPONO+POSMA-1)
          POSNOE = ZI(JNOMA+JDEC0+INI-1)
          NUMNOE = ZI(JNOCO+POSNOE-1)
          NSANS  = ZI(JPSANS+IZONE) - ZI(JPSANS+IZONE-1)
          JDEC   = ZI(JPSANS+IZONE-1)
          DO 50 INO = 1,NSANS
C _____ NUMERO ABSOLU DU NOEUD DANS SANS_GROUP_NO OU SANS_NOEUD
            NUMSAN = ZI(JSANS+JDEC+INO-1)
            IF (NUMNOE .EQ. NUMSAN) THEN
               GOTO 40
            END IF
 50       CONTINUE 
 40       CONTINUE 
C --- FIN MODIF          
          call CALBET(NOMA,POSMA,DEPPLU,XPG,YPG,LAMBDA,NEWGEO,DEFICO)
          ZR(JTABF+21*NTPC+21*(INI-1)+14) = LAMBDA
 10     continue
        NTPC = NTPC + NBN
 20   continue
      call JEDEMA
      end
