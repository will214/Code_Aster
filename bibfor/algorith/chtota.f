      SUBROUTINE CHTOTA(MODELE,NUMEDD,MATE,COMPOR,CARELE,COM,DEPMOI,
     &                  DEPLAS,DEPDEL,SIGMA,LISCHA,LONCH,VCHTOT,
     &                  VEFONO,VAFONO,VEBUDI,VABUDI,VECHTP,CNCHTP)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 06/04/2004   AUTEUR DURAND C.DURAND 
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
C TOLE CRP_21
      IMPLICIT REAL*8 (A-H,O-Z)
      LOGICAL FNOEVO
      CHARACTER*(*) MATE
      CHARACTER*19 LISCHA
      CHARACTER*24 MODELE,NUMEDD,CARELE,COMPOR
      CHARACTER*24 DEPMOI,DEPLAS,DEPDEL,SIGMA,COM
      REAL*8 R8BID(3)
      INTEGER LONCH
      REAL*8 VCHTOT(*)
C ----------------------------------------------------------------------
C     CALCUL DE LA CHARGE TOTALE ACTUELLE DE LA STRUCTURE, DEDUITE DE
C     SON ETAT DE DEPLACEMENT ET DE CONTRAINTE.

C --------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ---------------------
      CHARACTER*32 JEXNUM,JEXNOM,JEXR8,JEXATR
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
C --------- FIN  DECLARATIONS  NORMALISEES  JEVEUX ---------------------
      INTEGER IBID,JFO,JFONO,JBU,JBUDI,JTM,JCHTM
      CHARACTER*8 K8BID
      CHARACTER*24 VEFONO,VAFONO,VEBUDI,VABUDI,VECHTP,CNCHTP
      CHARACTER*24 TEMPER
      COMPLEX*16 CBID

      CALL JEMARQ()

      NH = 0
      VEBUDI = '&&VEBDEP.LISTE_RESU'
      CALL NMVCEX('TEMP',COM,TEMPER)
      FNOEVO=.FALSE.
      CALL VEFNME(MODELE,SIGMA,CARELE,DEPMOI,DEPDEL,VEFONO,MATE,
     &            COMPOR,NH,FNOEVO,R8BID,' ',TEMPER,' ')
      CALL ASASVE(VEFONO,NUMEDD,'R',VAFONO)

      CALL VEBUME(MODELE,DEPLAS,LISCHA,VEBUDI)
      CALL ASASVE(VEBUDI,NUMEDD,'R',VABUDI)

      CALL VECTME(MODELE,CARELE,MATE,COM,VECHTP)
      CALL ASASVE(VECHTP,NUMEDD,'R',CNCHTP)

      CALL JEVEUO(VAFONO,'L',JFO)
      CALL JEVEUO(ZK24(JFO) (1:19)//'.VALE','L',JFONO)

      CALL JEVEUO(VABUDI,'L',JBU)
      CALL JELIRA(VABUDI,'LONMAX',NBVEC,K8BID)
      IF (NBVEC.GT.1) THEN
        CALL WKVECT('&&CHTOTA.BUDI','V V R',LONCH,JBUDI)
        DO 20 J = 1,NBVEC
          CALL JEVEUO(ZK24(JBU+J-1) (1:19)//'.VALE','L',JBU2)
          DO 10 I = 1,LONCH
            ZR(JBUDI+I-1) = ZR(JBUDI+I-1) + ZR(JBU2+I-1)
   10     CONTINUE
   20   CONTINUE
      ELSE
        CALL JEVEUO(ZK24(JBU) (1:19)//'.VALE','L',JBUDI)
      END IF

      CALL JEVEUO(CNCHTP,'L',JTM)
      CALL JEVEUO(ZK24(JTM) (1:19)//'.VALE','L',JCHTM)

      DO 30 I = 1,LONCH
        VCHTOT(I) = ZR(JFONO+I-1) + ZR(JBUDI+I-1) + ZR(JCHTM+I-1)
   30 CONTINUE


      DO 40,I = 1,NBVEC
        CALL DETRSD('CHAMP_GD',ZK24(JBU-1+I) (1:19))
   40 CONTINUE
      CALL DETRSD('CHAMP_GD',ZK24(JFO) (1:19))
C     CALL DETRSD('CHAMP_GD',ZK24(JTM) (1:19))

      CALL JEDETR('&&CHTOTA.BUDI')
   50 CONTINUE

      CALL JEDEMA()
      END
