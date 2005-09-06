      SUBROUTINE  XCALFE(XYZ,BASLOG,FE,DGDGL)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 05/09/2005   AUTEUR VABHHTS J.PELLET 
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
C
       IMPLICIT NONE
C
       REAL*8        XYZ(3),BASLOG(9),FE(4),DGDGL(4,3)
C
C --------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ---------------------
C
      INTEGER  ZI
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
C --------- FIN  DECLARATIONS  NORMALISEES  JEVEUX ---------------------
C
C
C     BUT:  CALCUL DES FONCTIONS D'ENRICHISSEMENT EN UN POINT DE GAUSS
C
C IN  XYZ     : COORDONN�ES DU POINT DE GAUSS CONSID�R�
C IN  BASLOG  : BASE LOCALE AU FOND DE FISSURE AU POINT DE GAUSS
C OUT FE      : VALEURS DES FONCTIONS D'ENRICHISSEMENT
C OUT DGDGL   : D�RIV�ES DES FONCTIONS D'ENRICHISSEMENT
C
C----------------------------------------------------------------

      INTEGER   I,J,K
      REAL*8    A(3),E1(3),E2(3),E3(3),P(3,3),INVP(3,3),NORME,AG(3)
      REAL*8    VGL(3),XLG,YLG,RG,TG,DGDPO(4,2),DGDLO(4,3),R8PREM,DET

C     RECUPERATION DE LA BASE LOCALE ASSOCI�E AU PT
C     (A,E1=GRLT,E2=GRLN,E3=E1^E2)
      DO 123 I=1,3
         A(I)  = BASLOG(I)
         E1(I) = BASLOG(I+3)
         E2(I) = BASLOG(I+6)
 123  CONTINUE
C     NORMALISATION DE LA BASE
      CALL NORMEV(E1,NORME)
      CALL NORMEV(E2,NORME)
      CALL PROVEC(E1,E2,E3)
      
C     CALCUL DE LA MATRICE DE PASSAGE P TQ 'GLOBAL' = P * 'LOCAL'
      DO 124 I=1,3
        P(I,1)=E1(I)
        P(I,2)=E2(I)
        P(I,3)=E3(I)
 124  CONTINUE

C     V�RIFICATION QUE LE D�TERMINANT DE P VAUT BIEN 1
      DET = P(1,1)*P(2,2)*P(3,3) + P(2,1)*P(3,2)*P(1,3)
     +    + P(3,1)*P(1,2)*P(2,3) - P(3,1)*P(2,2)*P(1,3)
     +    - P(2,1)*P(1,2)*P(3,3) - P(1,1)*P(3,2)*P(2,3) 
     
      IF (ABS(DET-1.D0).GT.10.D0*R8PREM()) THEN            
        CALL UTMESS('F','XCALFE','LA BASE LOCALE SEMBLE FAUSSE')      
      ENDIF
     
C     CALCUL DE L'INVERSE DE LA MATRICE DE PASSAGE : INV=TRANSPOSE(P)
      DO 125 I=1,3
        DO 126 J=1,3
          INVP(I,J)=P(J,I)
 126    CONTINUE
 125  CONTINUE

C     COORDONN�ES DU POINT DANS LA BASE LOCALE
      AG(1)=XYZ(1)-A(1)
      AG(2)=XYZ(2)-A(2)
      AG(3)=XYZ(3)-A(3)
      CALL PMAVEC('ZERO',3,INVP,AG,VGL)
      XLG=VGL(1)
      YLG=VGL(2)
      IF (ABS(VGL(3)).GT.3.0D-2) THEN
        CALL UTDEBM('F','XCALFE','PB DE BASE LOCALE : ZG NON NUL. ')
        CALL UTIMPR('L',' ZG ',1,VGL )
        CALL UTFINM()
      ENDIF
C
C     COORDONN�ES POLAIRES DU POINT
      RG=SQRT(XLG*XLG+YLG*YLG)
C     ON V�RIFIE QUE LE POINT N'EST PAS SUR LE FOND
      IF (RG.GT.R8PREM()) THEN
        TG=ATAN2(YLG,XLG)
      ELSE 
C       L'ANGLE N'EST PAS D�FINI
        CALL UTMESS('F','XCALFE','LE CALCUL DES DERIVEES DES '//
     &  'FONCTIONS SINGULIERES EST IMPOSSIBLE SUR LE FOND DE '//
     &  'FISSURE')  
      ENDIF 
C
C     FONCTIONS D'ENRICHISSEMENT
      FE(1)=SQRT(RG)*SIN(TG/2.D0)
      FE(2)=SQRT(RG)*COS(TG/2.D0)
      FE(3)=SQRT(RG)*SIN(TG/2.D0)*SIN(TG)
      FE(4)=SQRT(RG)*COS(TG/2.D0)*SIN(TG)
C
C     CALCUL DES D�RIV�ES
C     -------------------

C     D�RIV�ES DES FONCTIONS D'ENRICHISSEMENT DANS LA BASE POLAIRE
      DGDPO(1,1)=1.D0/(2.D0*SQRT(RG))*SIN(TG/2.D0)
      DGDPO(1,2)=SQRT(RG)/2.D0*COS(TG/2.D0)
      DGDPO(2,1)=1.D0/(2.D0*SQRT(RG))*COS(TG/2.D0)
      DGDPO(2,2)=-SQRT(RG)/2.D0*SIN(TG/2.D0)
      DGDPO(3,1)=1.D0/(2.D0*SQRT(RG))*SIN(TG/2.D0)*SIN(TG)
      DGDPO(3,2)=SQRT(RG) *
     &          (COS(TG/2.D0)*SIN(TG)/2.D0 + SIN(TG/2.D0)*COS(TG))
      DGDPO(4,1)=1.D0/(2.D0*SQRT(RG))*COS(TG/2.D0)*SIN(TG)
      DGDPO(4,2)=SQRT(RG) *
     &          (-SIN(TG/2.D0)*SIN(TG)/2.D0 + COS(TG/2.D0)*COS(TG))

C     D�RIV�ES DES FONCTIONS D'ENRICHISSEMENT DANS LA BASE LOCALE
      DO 131 I=1,4
        DGDLO(I,1)=DGDPO(I,1)*COS(TG)-DGDPO(I,2)*SIN(TG)/RG
        DGDLO(I,2)=DGDPO(I,1)*SIN(TG)+DGDPO(I,2)*COS(TG)/RG
        DGDLO(I,3)=0.D0
 131  CONTINUE

C     D�RIV�ES DES FONCTIONS D'ENRICHISSEMENT DANS LA BASE GLOBALE
      DO 132 I=1,4
        DO 133 J=1,3
          DGDGL(I,J)=0.D0
          DO 134 K=1,3
            DGDGL(I,J)=DGDGL(I,J)+DGDLO(I,K)*INVP(K,J)
 134      CONTINUE
 133    CONTINUE
 132  CONTINUE

      END
