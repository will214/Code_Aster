      SUBROUTINE NMDIRE(NOEU1,NOEU2,NDIM,CNSLN,GRLN,GRLT,
     &                  COMPO,VECT)
      
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 01/02/2011   AUTEUR MASSIN P.MASSIN 
C ======================================================================
C COPYRIGHT (C) 1991 - 2011  EDF R&D                  WWW.CODE-ASTER.ORG
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
      IMPLICIT NONE
      INTEGER       NOEU1,NOEU2,NDIM
      CHARACTER*19  CNSLN,GRLN,GRLT
      CHARACTER*8   COMPO
      REAL*8        VECT(3)
C
C ----------------------------------------------------------------------
C CALCUL DIRECTION DE PILOTAGE DNOR, DTAN OU DTAN2
C FORMULATION XFEM
C ----------------------------------------------------------------------
C
C
C IN  NOEU1  : EXTREMITE 1 ARETE PILOTEE
C IN  NOEU1  : EXTREMITE 2 ARETE PILOTEE
C IN  NDIM   : DIMENSION PROBLEME
C IN  CNSLSN : NOM CHAM_NO_S LEVEL SET NORMALE
C IN  GRLN   : NOM CHAM_NO_S GRADIENT LEVEL SET NORMALE
C IN  GRLT   : NOM CHAM_NO_S GRADIENT LEVEL SET TANGENTIELLE
C IN  COMPO  : DIRECTION A PILOTER
C OUT  VECT  : VECTEUR NORME DE CETTE DIRECTION DANS LA BASE FIXE
C
C -------------- DEBUT DECLARATIONS NORMALISEES JEVEUX -----------------

      CHARACTER*32       JEXNOM
      INTEGER VALI(2)
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
C -------------- FIN  DECLARATIONS  NORMALISEES  JEVEUX ----------------

      INTEGER    JGRNNO,JLSN,JGRTNO,I
      REAL*8     NORM(3),TANG(3),NORMN
      REAL*8     TANG2(3),NORMT
      REAL*8     LSN1,LSN2,EPS,R8PREM
      LOGICAL    ISDT,ISDN

      
      CALL JEVEUO(CNSLN//'.CNSV','E',JLSN)
      CALL JEVEUO(GRLN//'.CNSV','E',JGRNNO)
      CALL JEVEUO(GRLT//'.CNSV','E',JGRTNO)       
      LSN1 = ZR(JLSN-1+NOEU1)
      LSN2 = ZR(JLSN-1+NOEU2)
      EPS=R8PREM()
      NORM(1)=0.D0
      NORM(2)=0.D0
      NORM(3)=0.D0
      TANG(1)=0.D0
      TANG(2)=0.D0
      TANG(3)=0.D0

      IF((ABS(LSN1).LE.EPS).AND.(ABS(LSN2).LE.EPS)) THEN
         DO 95 I=1,NDIM 
            NORM(I) = NORM(I)+
     &          ZR(JGRNNO-1+NDIM*(NOEU1-1)+I)
95       CONTINUE
      ELSE
         DO 91 I=1,NDIM 
            NORM(I) = NORM(I)+
     &         ABS(LSN1)*ZR(JGRNNO-1+NDIM*(NOEU2-1)+I)+
     &         ABS(LSN2)*ZR(JGRNNO-1+NDIM*(NOEU1-1)+I)
91       CONTINUE     
      ENDIF
      NORMN=SQRT(NORM(1)**2+NORM(2)**2+NORM(3)**2)
      NORM(1)=NORM(1)/NORMN
      NORM(2)=NORM(2)/NORMN
      NORM(3)=NORM(3)/NORMN

      IF(COMPO(1:4).EQ.'DTAN') THEN
         IF (NDIM.EQ.2)THEN 
            TANG(1)=NORM(2)
            TANG(2)=-NORM(1)
         ELSEIF (NDIM.EQ.3)THEN 
            TANG2(1)=1.D0
            TANG2(2)=0.D0
            TANG2(3)=0.D0
            CALL PROVEC(NORM,TANG2,TANG)
            NORMT=SQRT(TANG(1)**2+TANG(2)**2+TANG(3)**2)
            IF(NORMT.LE.EPS) THEN
               TANG(1)=0.D0
               TANG(2)=1.D0
               TANG(3)=0.D0            
            ELSE
               TANG(1)=TANG(1)/NORMT
               TANG(2)=TANG(2)/NORMT
               TANG(3)=TANG(3)/NORMT             
            ENDIF 
            CALL PROVEC(NORM,TANG,TANG2)
          ENDIF                       
       ENDIF

       DO 92 I=1,NDIM
          IF(COMPO.EQ.'DNOR') THEN
             VECT(I)=NORM(I)
          ELSE IF(COMPO.EQ.'DTAN2') THEN
             VECT(I)=TANG2(I)
          ELSE IF(COMPO.EQ.'DTAN') THEN
             VECT(I)=TANG(I)            
          ENDIF        
92     CONTINUE
       END
