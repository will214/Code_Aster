      SUBROUTINE XGRAEL (GRLT,GRLN,BASLO,NOMA,MODELE,BASLOC)
      IMPLICIT NONE

      CHARACTER*8     NOMA,MODELE
      CHARACTER*19    GRLT,GRLN
      CHARACTER*24    BASLO,BASLOC


C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 30/03/2004   AUTEUR CIBHHLV L.VIVAN 
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
C RESPONSABLE CIBHHLV L.VIVAN

C     FONCTION REALISEE : DANS LE CADRE DE X-FEM
C                         CREATION D'UN CHAM_EL QUI CONTIENT LA BASE
C                         LOCALE AU POINT DU FOND DE FISSURE ASSOCIE
C ----------------------------------------------------------------------
C ENTREE:
C      GRLT    : GRADIENTS DE LA LEVEL-SET TANGENTE
C      GRLN    : GRADIENTS DE LA LEVEL-SET NORMALE
C      BASLO   : NOM DE L'OBJET CONTENANT LES ELEMENTS DE LA BASE LOCALE
C      NOMA    : NOM DE L'OBJET MAILLAGE
C      MODELE  : NOM DE L'OBJET MODELE
C
C SORTIE:
C      BASLOC  : CHAM_EL BASE LOCALE DE FONFIS
C ----------------------------------------------------------------------
C
C --------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ---------------------
C
      CHARACTER*32       JEXNUM , JEXNOM , JEXR8 , JEXATR
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
      CHARACTER*1 K1BID
C --------- FIN  DECLARATIONS  NORMALISEES  JEVEUX ---------------------
C
      CHARACTER*19      CHS,CELMOD,CESMOD,CES,MNOGA,LIGREL
      CHARACTER*19      CNSGT,CNSGN
      CHARACTER*8       LICMP(9),K8BID

      INTEGER           IBALO,JGSV,JGSL,NBNO,IRET,INO,J,JGT,JGN
C
      CALL JEMARQ()

C     RECUPERATION DES GRADIENTS DES LEVEL SETS
      CNSGT='&&XGRAEL.CNSGT'
      CNSGN='&&XGRAEL.CNSGN'
      CALL CNOCNS(GRLT,'V',CNSGT)
      CALL CNOCNS(GRLN,'V',CNSGN)
      CALL JEVEUO(CNSGT//'.CNSV','L',JGT)
      CALL JEVEUO(CNSGN//'.CNSV','L',JGN)

C     BASE LOCALE
      CALL JEVEUO(BASLO,'L',IBALO)

C     CR�ATION DU CHAMP AUX NOEUDS SIMPLE
      CHS='&&XGRAEL.CHS'
      LICMP(1)  = 'X1'
      LICMP(2)  = 'X2'
      LICMP(3)  = 'X3'
      LICMP(4)  = 'X4'
      LICMP(5)  = 'X5'
      LICMP(6)  = 'X6'
      LICMP(7)  = 'X7'
      LICMP(8)  = 'X8'
      LICMP(9)  = 'X9'
      CALL CNSCRE(NOMA,'NEUT_R',9,LICMP,'V',CHS)
      CALL JEVEUO(CHS//'.CNSV','E',JGSV)
      CALL JEVEUO(CHS//'.CNSL','E',JGSL)
      CALL DISMOI('F','NB_NO_MAILLA',NOMA,'MAILLAGE',NBNO,K8BID,IRET)
      DO 100 INO=1,NBNO
        DO 200 J=1,3
          ZR(JGSV-1+9*(INO-1)+J)=ZR(IBALO-1+3*(INO-1)+J)
          ZL(JGSL-1+9*(INO-1)+J)=.TRUE.
          ZR(JGSV-1+9*(INO-1)+J+3)=ZR(JGT-1+3*(INO-1)+J)
          ZL(JGSL-1+9*(INO-1)+J+3)=.TRUE.
          ZR(JGSV-1+9*(INO-1)+J+6)=ZR(JGN-1+3*(INO-1)+J)
          ZL(JGSL-1+9*(INO-1)+J+6)=.TRUE.
 200    CONTINUE
 100  CONTINUE

C     PASSAGE DU CHAMP AUX NOEUDS SIMPLE AU
C     CHAMP PAR �L�MENTS AUX POINTS DE GAUSS
      CELMOD = '&&XGRAEL.CELMOD'
      CESMOD = '&&XGRAEL.CESMOD'
      CES = '&&XGRAEL.CES'
      MNOGA = '&&XGRAEL.MANOGA'
      LIGREL = ' '
      LIGREL = MODELE//'.MODELE'
      CALL MANOPG(LIGREL,MNOGA)
      CALL ALCHML(LIGREL,'CALC_K_G','PBASLOR','V',CELMOD,IRET,' ')
      CALL CELCES(CELMOD,'V',CESMOD)
      CALL CNSCES(CHS,'ELGA',CESMOD,MNOGA,'V',CES)
      CALL DETRSD('CHAM_NO_S',CHS)
      CALL DETRSD('CHAM_ELEM_S',MNOGA)
      CALL CESCEL(CES,LIGREL,'CALC_K_G','PBASLOR','NON','V',BASLOC)
      CALL DETRSD('CHAM_ELEM_S',CES)

      CALL JEDEMA()
      END
