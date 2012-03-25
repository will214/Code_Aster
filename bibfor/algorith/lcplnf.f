      SUBROUTINE LCPLNF(LOI,VIND,NBCOMM,NMAT,CPMONO,
     &                  MATERD,MATERF,ITER,NVI,ITMAX,TOLER,
     &                  PGL,NFS,NSG,TOUTMS,HSR,DT,DY,YD,
     &                  YF,VINF,TAMPON,COMP,SIGD,SIGF,DEPS,
     &                  NR,MOD,CODRET)

C RESPONSABLE PROIX J-M.PROIX
        IMPLICIT NONE
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 26/03/2012   AUTEUR PROIX J-M.PROIX 
C ======================================================================
C COPYRIGHT (C) 1991 - 2012  EDF R&D                  WWW.CODE-ASTER.ORG
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
C TOLE CRP_21
C ----------------------------------------------------------------
C   POST-TRAITEMENTS SPECIFIQUES AUX LOIS
C
C   CORRESPONDANCE ENTRE LES VARIABLES INTERNES ET LES EQUATIONS
C          DU SYSTEME DIFFERENTIEL APRES INTEGRATION
C
C   CAS GENERAL :
C      COPIE DES YF DANS VINF
C      LA DERNIERE C'EST TOUJOURS L'INDICATEUR PLASTIQUE
C
C   CAS PARTICULIER DU  MONOCRISTAL  :
C       ON GARDE 1 VARIABLE INTERNE PAR SYSTEME DE GLISSEMENT SUR 3
C       DEFORMATION PLASTIQUE EQUIVALENTE CUMULEE MACROSCOPIQUE
C ----------------------------------------------------------------
C  IN
C     LOI    :  NOM DE LA LOI
C     VIND   :  VARIABLE INTERNES A T
C     MATERD :  COEF MATERIAU A T
C     MATERF :  COEF MATERIAU A T+DT
C     NBCOMM :  INCIDES DES COEF MATERIAU
C     NMAT   :  DIMENSION MATER ET DE NBCOMM
C     NVI    :  NOMBRE DE VARIABLES INTERNES
C     DT     : INCREMENT DE TEMPS
C     NR     : DIMENSION VECTEUR INCONNUES (YF/DY)
C     YF     : EQUATIONS DU COMPORTEMENT INTEGRES A T+DT
C     DY     : INCREMENT DES VARIABLES INTERNES
C  OUT
C     VINF   :  VARIABLES INTERNES A T+DT
C       ----------------------------------------------------------------
      INTEGER  NDT,NVI,NMAT,NDI,NBCOMM(NMAT,3),ITER,ITMAX,NR,CODRET
      INTEGER  NFS,NSG
      REAL*8   MATERD(NMAT,2),MATERF(NMAT,2)
      REAL*8   YD(*),VIND(*),TOLER,PGL(3,3),DT,TAMPON(*)
      REAL*8   TOUTMS(NFS,NSG,6),HSR(NSG,NSG),DY(*),YF(*),VINF(*)
      CHARACTER*16 LOI,CPMONO(5*NMAT+1),COMP(*)
      CHARACTER*8  MOD
      REAL*8       SIGF(6),DEPS(*),SIGD(6)

      COMMON /TDIM/   NDT  , NDI
C --- -------------------------------------------------------------
C
      IF (LOI(1:8).EQ.'MONOCRIS') THEN
C ---    DEFORMATION PLASTIQUE EQUIVALENTE CUMULEE MACROSCOPIQUE
         CALL LCDPEC(VIND,NBCOMM,NMAT,NDT,CPMONO,MATERF,
     &               ITER,NVI,ITMAX, TOLER,PGL,NFS,NSG,TOUTMS,HSR,
     &        DT,DY,YD,VINF,TAMPON,COMP,SIGF,DEPS,NR,MOD,CODRET)

      ELSEIF (LOI(1:7).EQ.'IRRAD3M') THEN
         CALL IRRLNF(NMAT,MATERF,YF(NDT+1),1.0D0,VINF)
      ELSEIF ( LOI(1:15) .EQ. 'BETON_BURGER_FP' ) THEN
         CALL BURLNF(NVI,VIND,NMAT,MATERD,MATERF,DT,
     &               NR,YD,YF,VINF,SIGF)
      ELSEIF ( LOI(1:4) .EQ. 'LETK' ) THEN
         CALL LKILNF(NVI,VIND,NMAT,MATERF,DT,SIGD,NR,YD,YF,
     &               DEPS,VINF)
      ELSE
C        CAS GENERAL :
         CALL LCEQVN( NVI-1 , YF(NDT+1) , VINF )
         VINF(NVI) = 1.D0
      ENDIF

      END
