      SUBROUTINE TE0154(OPTION,NOMTE)
C ======================================================================
C            CONFIGURATION MANAGEMENT OF EDF VERSION
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
      IMPLICIT  NONE
      CHARACTER*(*)     OPTION,NOMTE
C ----------------------------------------------------------------------
C MODIF ELEMENTS  DATE 21/02/2006   AUTEUR FLANDI L.FLANDI 
C     CALCUL
C       - DU VECTEUR ELEMENTAIRE EFFORT GENERALISE,
C       - DU VECTEUR ELEMENTAIRE CONTRAINTE
C       - DE L'ENERGIE DE DEFORMATION
C       - DE L'ENERGIE CINETIQUE
C     POUR LES ELEMENTS DE BARRE
C ----------------------------------------------------------------------
C IN  OPTION : K16 : NOM DE L'OPTION A CALCULER
C        'EFGE_ELNO_DEPL'   : CALCUL DU VECTEUR EFFORT GENERALISE
C        'SIGM_ELNO_DEPL'   : CALCUL DU VECTEUR CONTRAINTE
C        'SIEF_ELGA_DEPL'   : CALCUL DU VECTEUR EFFORT GENERALISE
C        'EPSI_ELNO_DEPL'   : CALCUL DU VECTEUR DEFORMATION
C        'EPOT_ELEM_DEPL'   : CALCUL DE L'ENERGIE DE DEFORMATION
C        'ECIN_ELEM_DEPL'   : CALCUL DE L'ENERGIE CINETIQUE
C IN  NOMTE  : K16 : NOM DU TYPE ELEMENT
C        'MECA_BARRE'   : BARRE
C        'MECA_2D_BARRE'   : BARRE
C
C --------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ---------------------
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
C --------- FIN  DECLARATIONS  NORMALISEES  JEVEUX ---------------------
C
      REAL*8       PGL(3,3), KLC(6,6), ENERTH,EPSGL(6)
      REAL*8       UGR(6),ULR(6),FLR(6),EPS(6)
      CHARACTER*2  BL2, CODRES
      CHARACTER*16 CH16
      LOGICAL      LTEIMP
      REAL*8       A,ALPHAT,E,R8BID,RHO,TEMP,XFL1,XFL4,XL,XMAS,XRIG
      INTEGER      I,IF,ITYPE,J,JDEPL,JEFFO,JENDE,JFREQ,JDEFO,KANL
      INTEGER      LMATER,LORIEN,LSECT,LTEMP,LTREF,LX,NC,NNO
C     ------------------------------------------------------------------
      LTEIMP = .FALSE.
      NNO = 2
      NC  = 3
C
      IF ( (NOMTE .NE. 'MECA_BARRE').AND.
     +      (NOMTE .NE. 'MECA_2D_BARRE'))  THEN
         CH16 = NOMTE
         CALL UTMESS('F','ELEMENTS DE BARRE (TE0154)',
     +                   '"'//CH16//'"    NOM D''ELEMENT INCONNU.')
      ENDIF
C
C     --- RECUPERATION DES CARACTERISTIQUES MATERIAUX ---
      BL2 = '  '
      CALL JEVECH ('PMATERC', 'L', LMATER)
      CALL RCVALA(ZI(LMATER),' ','ELAS',0,' ',R8BID,1,'E',E,
     &            CODRES, 'FM' )
      CALL RCVALA(ZI(LMATER),' ','ELAS',0,' ',R8BID,1,'ALPHA',ALPHAT,
     +            CODRES , BL2 )
      IF ( CODRES .EQ. 'OK' ) LTEIMP = .TRUE.
C
C     --- RECUPERATION DES COORDONNEES DES NOEUDS ---
      CALL JEVECH ('PGEOMER', 'L',LX)
      LX = LX - 1
C
      IF (NOMTE.EQ.'MECA_BARRE') THEN
C
        CALL LONELE( ZR(LX),3,XL)
C
      ELSE IF (NOMTE.EQ.'MECA_2D_BARRE') THEN
        CALL LONELE( ZR(LX),2,XL)
C
      ENDIF
C
      IF( XL .EQ. 0.D0 ) THEN
         CH16 = ' ?????????'
         CALL UTMESS('F','ELEMENTS DE BARRE (TE0154)',
     +                  'NOEUDS CONFONDUS POUR UN ELEMENT: '//CH16(:8))
      ENDIF
C
C     --- RECUPERATION DES CARACTERISTIQUES GENERALES DES SECTIONS ---
      IF (OPTION.NE.'EPSI_ELNO_DEPL') THEN
        CALL JEVECH ('PCAGNBA', 'L',LSECT)
        A = ZR(LSECT)
      ENDIF
C
C     --- RECUPERATION DES ORIENTATIONS ALPHA,BETA,GAMMA ---
      CALL JEVECH ('PCAORIE', 'L',LORIEN)
C     --- MATRICE DE ROTATION PGL
      CALL MATROT ( ZR(LORIEN) , PGL )
C
C     --- RECUPERATION DES DEPLACEMENTS ----
      DO 19 I=1,6
           UGR(I) =  0.D0
 19   CONTINUE
C
      CALL JEVECH ('PDEPLAR', 'L', JDEPL)
C
      IF (NOMTE.EQ.'MECA_BARRE') THEN
        DO 22 I = 1,6
           UGR(I) = ZR(JDEPL+I-1)
 22     CONTINUE
      ELSE IF (NOMTE.EQ.'MECA_2D_BARRE') THEN
         UGR(1) =  ZR(JDEPL+1-1)
         UGR(2) =  ZR(JDEPL+2-1)
         UGR(4) =  ZR(JDEPL+3-1)
         UGR(5) =  ZR(JDEPL+4-1)
      ENDIF

C

C     --- VECTEUR DEPLACEMENT LOCAL  ULR = PGL * UGR
C
      CALL UTPVGL ( NNO, NC, PGL, UGR, ULR )
C
C     --- RIGIDITE ELEMENTAIRE ---
      DO 30 I =1,6
         DO 32 J =1,6
            KLC(I,J) = 0.D0
 32      CONTINUE
 30   CONTINUE
C
C     --- ENERGIE DE DEFORMATION ----
      IF( OPTION .EQ. 'EPOT_ELEM_DEPL' ) THEN
         CALL JEVECH ('PENERDR', 'E', JENDE)
         XRIG = E * A / XL
         KLC(1,1) =  XRIG
         KLC(1,4) = -XRIG
         KLC(4,1) = -XRIG
         KLC(4,4) =  XRIG
         IF = 0
         CALL PTENPO(6,ULR,KLC,ZR(JENDE),IF,IF)
C
         IF ( LTEIMP ) THEN
           CALL PTENTH(ULR,XL,ALPHAT,6,KLC,IF,ENERTH)
           ZR(JENDE) = ZR(JENDE) - ENERTH
         ENDIF
C
      ELSEIF( OPTION .EQ. 'ECIN_ELEM_DEPL' ) THEN
         CALL RCVALA ( ZI(LMATER),' ','ELAS',0,' ',R8BID,1,'RHO',RHO,
     +                 CODRES , 'FM' )
         CALL JEVECH ('PENERCR', 'E', JENDE)
         CALL JEVECH ('PFREQR' , 'L', JFREQ)
         XMAS = RHO * A * XL / 6.D0
         KLC(1,1) =  XMAS * 2.D0
         KLC(1,4) =  XMAS
         KLC(4,1) =  XMAS
         KLC(4,4) =  XMAS * 2.D0
         IF = 0
         ITYPE = 50
         KANL = 1
         CALL PTENCI(6,ULR,KLC,ZR(JFREQ),ZR(JENDE),ITYPE,KANL,IF)

C
      ELSEIF( OPTION .EQ. 'EPSI_ELNO_DEPL' ) THEN
         CALL JEVECH('PDEFORR','E',JDEFO)
         ZR(JDEFO)=(ULR(4)-ULR(1))/XL
         ZR(JDEFO+1)=(ULR(4)-ULR(1))/XL
      ELSE
         XRIG = E * A / XL
         KLC(1,1) =  XRIG
         KLC(1,4) = -XRIG
         KLC(4,1) = -XRIG
         KLC(4,4) =  XRIG

C
C        --- VECTEUR EFFORT LOCAL  FLR = KLC * ULR
         CALL PMAVEC('ZERO',6,KLC,ULR,FLR)
C
C        --- TENIR COMPTE DES EFFORTS DUS A LA DILATATION ---
         IF ( LTEIMP ) THEN
C
C           TEMPERATURE DE REFERENCE
            CALL JEVECH('PTEREF','L',LTREF)
C
C           TEMPERATURE EFFECTIVE
            CALL JEVECH('PTEMPER','L',LTEMP)
C
            TEMP = 0.5D0*(ZR(LTEMP)+ZR(LTEMP+1)) - ZR(LTREF)
C
            IF ( TEMP .NE. 0.D0 ) THEN
C
C              --- CALCUL DES FORCES INDUITES ---
               XFL1 = -ALPHAT * TEMP * E * A
               XFL4 = -XFL1
               FLR(1) = FLR(1) - XFL1
               FLR(4) = FLR(4) - XFL4
            ENDIF
         ENDIF
C
         IF ( OPTION .EQ. 'EFFO_ELNO_DEPL' ) THEN
            CALL JEVECH('PEFFORR','E',JEFFO)
C           --- VECTEUR EFFORT GLOBAL  FG = MLG * FLR
            CALL UTPVLG ( NNO, NC, PGL, FLR, ZR(JEFFO) )
C
         ELSEIF ( OPTION .EQ. 'SIGM_ELNO_DEPL' ) THEN
            CALL JEVECH('PCONTRR','E',JEFFO)
            ZR(JEFFO  ) = -FLR(1) / A
            ZR(JEFFO+1) = FLR(4) / A
C
         ELSEIF ( OPTION .EQ. 'SIEF_ELGA_DEPL' ) THEN
            CALL JEVECH('PCONTRR','E',JEFFO)
            ZR(JEFFO  ) = -FLR(1)
C
         ELSEIF (OPTION .EQ. 'EFGE_ELNO_DEPL') THEN
            CALL JEVECH('PEFFORR','E',JEFFO)
            ZR(JEFFO  ) = -FLR(1)
            ZR(JEFFO+1) = FLR(4)
C
         ELSE
            CH16 = OPTION
            CALL UTMESS('F','ELEMENTS DE BARRE (TE0154)',
     +                          '"'//CH16//'"  NOM D''OPTION INCONNU.')
         ENDIF
      ENDIF
C
      END
