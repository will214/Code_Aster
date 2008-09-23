      SUBROUTINE CFCHNO(NOMA  ,DEFICO,NDIMG ,IZONE ,POSNOE,
     &                  TYPENM,NUMENM,LMAIT ,LESCL ,LMFIXE,
     &                  LEFIXE,TAU1M ,TAU2M ,TAU1E ,TAU2E ,
     &                  TAU1  ,TAU2)
C     
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 23/09/2008   AUTEUR ABBAS M.ABBAS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2008  EDF R&D                  WWW.CODE-ASTER.ORG
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
      CHARACTER*8   NOMA
      CHARACTER*4   TYPENM
      INTEGER       NDIMG 
      INTEGER       IZONE,POSNOE,NUMENM
      CHARACTER*24  DEFICO
      REAL*8        TAU1M(3),TAU2M(3)
      REAL*8        TAU1E(3),TAU2E(3)      
      REAL*8        TAU1(3),TAU2(3) 
      LOGICAL       LMFIXE,LEFIXE
      LOGICAL       LMAIT,LESCL
C
C ----------------------------------------------------------------------
C
C ROUTINE CONTACT (TOUTES METHODES - APPARIEMENT)
C
C CALCUL DES TANGENTES SUIVANT OPTION SUIVANT OPTION
C      
C ----------------------------------------------------------------------
C
C
C IN  NOMA   : NOM DU MAILLAGE
C IN  NDIMG  : DIMENSION DU MODELE
C IN  DEFICO : SD POUR LA DEFINITION DE CONTACT 
C IN  IZONE  : ZONE DE CONTACT ACTIVE
C IN  LMFIXE : .TRUE. SI LA NORMALE MAITRE EST FIXE OU VECT_Y
C IN  LEFIXE : .TRUE. SI LA NORMALE ESCLAVE EST FIXE OU VECT_Y
C IN  LMAIT  : .TRUE. SI LA NORMALE = MAITRE  / MAIT_ESCL
C IN  LESCL  : .TRUE. SI LA NORMALE = ESCLAVE / MAIT_ESCL
C IN  POSNOE : NOEUD ESCLAVE (NUMERO DANS SD CONTACT)
C IN  TYPENM : TYPE DE L'ENTITE MAITRE RECEVANT LA PROJECTION
C               'MAIL' UNE MAILLE
C               'NOEU' UN NOEUD
C IN  NUMENM : NUMERO ABSOLU ENTITE MAITRE QUI RECOIT LA PROJECTION
C IN  TAU1M  : PREMIERE TANGENTE SUR LA MAILLE MAITRE AU POINT ESCLAVE
C              PROJETE
C IN  TAU2M  : SECONDE TANGENTE SUR LA MAILLE MAITRE AU POINT ESCLAVE
C              PROJETE
C IN  TAU1E  : PREMIERE TANGENTE AU NOEUD ESCLAVE
C IN  TAU2E  : SECONDE TANGENTE AU NOEUD ESCLAVE
C OUT TAU1   : PREMIERE TANGENTE LOCALE AU POINT ESCLAVE PROJETE
C OUT TAU2   : SECONDE TANGENTE LOCALE AU POINT ESCLAVE PROJETE
C
C -------------- DEBUT DECLARATIONS NORMALISEES JEVEUX -----------------
C
      CHARACTER*32 JEXNUM
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
      INTEGER      I,NIVERR,CODRET
      CHARACTER*24 VALK(2)
      REAL*8       NOOR,R8PREM
      REAL*8       ENORM(3),MNORM(3),NORM(3)   
      CHARACTER*8  NOMNOE,NOMENM
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
C
C --- NOM DE L'ENTITE (NOEUD OU MAILLE)
C 
      IF (TYPENM.EQ.'MAIL') THEN
        CALL JENUNO(JEXNUM(NOMA//'.NOMMAI',NUMENM),NOMENM) 
      ELSEIF (TYPENM.EQ.'NOEU') THEN
        CALL JENUNO(JEXNUM(NOMA//'.NOMNOE',NUMENM),NOMENM)   
      ELSE
        CALL ASSERT(.FALSE.)
      ENDIF           
C
C --- NOM DU NOEUD ESCLAVE
C      
      IF (POSNOE.LE.0) THEN
        NOMNOE = 'PT CONT.'
      ELSE
        CALL CFNOMM(NOMA  ,DEFICO,'NOEU',POSNOE,NOMNOE,
     &              CODRET)  
        IF (CODRET.LT.0) THEN
          CALL ASSERT(.FALSE.)
        ENDIF  
      ENDIF 
      VALK(1) = NOMNOE
      VALK(2) = NOMENM                                        
C
C --- NORMALE AU NOEUD ESCLAVE: EXTERIEURE
C
      IF (LESCL) THEN
        CALL CFNORM(NDIMG,TAU1E,TAU2E,ENORM,NOOR)
        IF (NOOR.LE.R8PREM()) THEN
          CALL U2MESK('F','CONTACT3_26',1,NOMNOE)
        ENDIF
      ENDIF     
C
C --- NORMALE A LA MAILLE MAITRE: INTERIEURE
C
      IF (LMAIT) THEN            
        CALL MMNORM(NDIMG,TAU1M,TAU2M,MNORM,NOOR)
        IF (NOOR.LE.R8PREM()) THEN
          IF (TYPENM.EQ.'MAIL') THEN
            CALL U2MESK('F','CONTACT3_27',1,NOMENM)
          ELSEIF (TYPENM.EQ.'NOEU') THEN 
            CALL U2MESK('F','CONTACT3_26',1,NOMENM)
          ELSE
            CALL ASSERT(.FALSE.)
          ENDIF          
        ENDIF
      ENDIF           
C
C --- CALCUL DE LA NORMALE
C     
      IF (LMAIT.AND.(.NOT.LESCL)) THEN
        CALL DCOPY(3,MNORM,1,NORM,1)  
      ELSEIF (LMAIT.AND.LESCL) THEN
        DO 20 I = 1,3
          NORM(I) = (ENORM(I) + MNORM(I))/2.D0
 20     CONTINUE
      ELSEIF (LESCL) THEN  
        CALL DCOPY(3,ENORM,1,NORM,1)
      ELSE
        CALL ASSERT(.FALSE.)
      ENDIF
C
C --- RECOPIE DES TANGENTES SI NORMALE FIXE
C
      IF (LMFIXE) THEN
        IF (LMAIT.AND.(.NOT.LESCL)) THEN
          CALL DCOPY(3,TAU1M,1,TAU1,1)
          CALL DCOPY(3,TAU2M,1,TAU2,1)
        ELSE
          CALL ASSERT(.FALSE.)
        ENDIF  
      ENDIF
      IF (LEFIXE) THEN 
        IF (LESCL.AND.(.NOT.LMAIT)) THEN
          CALL DCOPY(3,TAU1E,1,TAU2,1)
          CALL DCOPY(3,TAU2E,1,TAU1,1)
        ELSE
          CALL ASSERT(.FALSE.)
        ENDIF 
      ENDIF
C
C --- RE-CALCUL DES TANGENTES SI NORMALE AUTO
C                   
      IF ((.NOT.LMFIXE).AND.(.NOT.LEFIXE)) THEN
        CALL MMMRON(NDIMG ,NORM  ,TAU1  ,TAU2)
      ENDIF  
C
C --- NORMALISATION DES TANGENTES
C
      CALL MMTANN(NDIMG ,TAU1  ,TAU2  ,NIVERR)
      IF (NIVERR.EQ.1) THEN  
        IF (TYPENM.EQ.'MAIL') THEN
          CALL U2MESK('F','CONTACT3_31',2,VALK)
        ELSEIF (TYPENM.EQ.'NOEU') THEN 
          CALL U2MESK('F','CONTACT3_35',2,VALK)
        ELSE
          CALL ASSERT(.FALSE.)
        ENDIF              
      ENDIF                 
C
      CALL JEDEMA()  
C
      END
