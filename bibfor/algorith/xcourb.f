      SUBROUTINE XCOURB(GRLT,GRLN,NOMA,MODELE,COURB) 

      IMPLICIT NONE
      CHARACTER*8     MODELE,NOMA     
      CHARACTER*19    GRLT,GRLN
      CHARACTER*24    COURB

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
C ----------------------------------------------------------------------
C FONCTION REALISEE:  CALCUL DE LA COURBURE (DERIV�E DE LA MATRICE 
C                       DE PASSAGE LOCAL-GLOBAL)
C
C    ENTREE
C      GRLT       :   GRADIENTS DE LA LEVEL-SET TANGENTE
C      GRLN       :   GRADIENTS DE LA LEVEL-SET NORMALE
C       MODELE    :   NOM DE L'OBJET MODELE
C       NOMA      :   NOM DE L'OBJET MAILLAGE
C
C    SORTIE
C       COURB     :   NOM DU TENSEUR DE COURBURE
C.......................................................................
C
      INTEGER        INO,I,J,NBNO,IBID,NCHIN
      INTEGER        JGT,JGN,JRSV,JRSL,JGL
      REAL*8         EL1(3),EL2(3),EL3(3),P(3,3),INVP(3,3),NORME
      CHARACTER*8    K8BID,LPAIN(2),LPAOUT(1),LICMP(9)
      CHARACTER*19   CNSGT,CNSGN,CNSR
      CHARACTER*24   LCHIN(2),LCHOUT(1),LIGRMO,MATPAS

C---------------- COMMUNS NORMALISES  JEVEUX  --------------------------
      COMMON /IVARJE/ZI(1)
      COMMON /RVARJE/ZR(1)
      COMMON /CVARJE/ZC(1)
      COMMON /LVARJE/ZL(1)
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
      INTEGER ZI
      REAL*8 ZR
      COMPLEX*16 ZC
      LOGICAL ZL
      CHARACTER*8 ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
C------------FIN  COMMUNS NORMALISES  JEVEUX  --------------------------
      
      CALL JEMARQ()
      
C     R�CUP�RATION DES GRADIENTS DE LST ET LSN
      CNSGT='&&XCOURB.CNSGT'     
      CNSGN='&&XCOURB.CNSGN'  
      CALL CNOCNS(GRLT,'V',CNSGT)
      CALL CNOCNS(GRLN,'V',CNSGN) 
      CALL JEVEUO(CNSGT//'.CNSV','L',JGT)
      CALL JEVEUO(CNSGT//'.CNSL','L',JGL)
      CALL JEVEUO(CNSGN//'.CNSV','L',JGN)

      CALL DISMOI('F','NB_NO_MAILLA',NOMA,'MAILLAGE',NBNO,K8BID,IBID)

C------------------------------------------------------------------ 
C     CREATION DU CHAM_NO SIMPLE MATPASS  (MATRICE INVP) 
C------------------------------------------------------------------ 
      CNSR='&&XCOURB.CNSLT'
      LICMP(1)  = 'X1'
      LICMP(2)  = 'X2'
      LICMP(3)  = 'X3'
      LICMP(4)  = 'X4'
      LICMP(5)  = 'X5'
      LICMP(6)  = 'X6'
      LICMP(7)  = 'X7'
      LICMP(8)  = 'X8'
      LICMP(9)  = 'X9'
      CALL CNSCRE(NOMA,'NEUT_R',9,LICMP,'V',CNSR)   
      CALL JEVEUO(CNSR//'.CNSV','E',JRSV)
      CALL JEVEUO(CNSR//'.CNSL','E',JRSL)
      
      DO 100 INO=1,NBNO
C       ON V�RIFIE QUE LE NOEUD A BIEN UNE VALEUR DE GRADLST ASSOCI�E
        IF (.NOT.ZL(JGL-1+3*(INO-1)+1)) GOTO 100
        DO 110 I=1,3
           EL1(I) = ZR(JGT-1+3*(INO-1)+I)
           EL2(I) = ZR(JGN-1+3*(INO-1)+I)
 110    CONTINUE
C       NORMALISATION DE LA BASE 
        CALL NORMEV(EL1,NORME) 
        CALL NORMEV(EL2,NORME)
        CALL PROVEC(EL1,EL2,EL3)
C       CALCUL DE LA MATRICE DE PASSAGE P TQ 'GLOBAL' = P * 'LOCAL'
        DO 120 I=1,3
          P(I,1)=EL1(I)
          P(I,2)=EL2(I)
          P(I,3)=EL3(I)
 120    CONTINUE
C       CALCUL DE L'INVERSE DE LA MATRICE DE PASSAGE : INV=TP
       DO 130 I=1,3
          DO 140 J=1,3
            INVP(I,J)=P(J,I)
 140      CONTINUE
 130    CONTINUE
        DO 150 I=1,3
            ZR(JRSV-1+9*(INO-1)+I)=INVP(I,1)
            ZL(JRSL-1+9*(INO-1)+I)=.TRUE.
            ZR(JRSV-1+9*(INO-1)+I+3)=INVP(I,2)
            ZL(JRSL-1+9*(INO-1)+I+3)=.TRUE.
            ZR(JRSV-1+9*(INO-1)+I+6)=INVP(I,3)
            ZL(JRSL-1+9*(INO-1)+I+6)=.TRUE.
 150    CONTINUE

 100  CONTINUE

      CALL CNSCNO(CNSR,' ','V',MATPAS)

C------------------------------------------------------------------ 
C     CALCUL DU GRADIENT DE MATPASS : CHAM_ELGA A 27 COMPOSANTES
C------------------------------------------------------------------ 

      LPAIN(1)='PGEOMER'
      LCHIN(1)=NOMA//'.COORDO'
      LPAIN(2)='PNEUTER'
      LCHIN(2)=MATPAS
      LPAOUT(1)='PGNEUTR'
      LCHOUT(1)=COURB
      LIGRMO=MODELE//'.MODELE'
      NCHIN=2
      CALL CALCUL('S','GRAD_NEUT9_R',LIGRMO,NCHIN,LCHIN,LPAIN,1,
     &                  LCHOUT,LPAOUT,'V')

      CALL JEDEMA()
      END
