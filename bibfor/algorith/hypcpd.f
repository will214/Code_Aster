      SUBROUTINE HYPCPD(C11   ,C22   ,C33   ,C12   ,K     ,
     &                  C10   ,C01   ,C20   ,DSIDEP,CODRET)
C   
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 09/03/2010   AUTEUR ABBAS M.ABBAS 
C ======================================================================
C COPYRIGHT (C) 2005 UCBL LYON1 - T. BARANGER     WWW.CODE-ASTER.ORG
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
C RESPONSABLE ABBAS M.ABBAS
C TOLE CRP_20
C
      IMPLICIT NONE
      REAL*8      C11,C22,C33,C12
      REAL*8      K
      REAL*8      C10,C01,C20
      REAL*8      DSIDEP(6,6)
      INTEGER     CODRET
C
C ----------------------------------------------------------------------
C
C LOI DE COMPORTEMENT HYPERELASTIQUE DE SIGNORINI    
C 
C C_PLAN - CALCUL DE LA MATRICE TANGENTE
C
C ----------------------------------------------------------------------
C
C IN  C11,C22,C33,C12: ELONGATIONS
C IN  C10,C01,C20:     CARACTERISTIQUES MATERIAUX
C IN  K      : MODULE DE COMPRESSIBILITE
C OUT DSIDEP : MATRICE TANGENTE
C OUT CODRET : CODE RETOUR ERREUR INTEGRATION (1 SI PROBLEME, 0 SINON)
C
C ----------------------------------------------------------------------
C
      REAL*8      T1,T2,T3,T5,T6,T8,T10,T12,T13,T28,T45
      REAL*8      T17,T31,T36,T20,T15,T24,T42,T16,T18,T34,T35
      REAL*8      T14,T22,T47,T57,T48,T52,T33
      REAL*8      T60,T62,T55,T56,T59,T53,T54,T21,T25
      REAL*8      T19,T27,T38,T29,T30,T7,T37,T26,T43,T75,T77
      REAL*8      T78,T49,T66,T69,T58,T71,T74,T32,T72,T9,T68
      REAL*8      T41,T46,T76,T44,T23
      REAL*8      T79,T81,T82,T73
C
C ----------------------------------------------------------------------
C

      T1  = C11*C22
      T3  = C12**2
      T5  = T1*C33-T3*C33
      T6  = T5**(1.D0/3.D0)
      IF ((T5.LE.0.D0)) THEN
        CODRET=1
        GOTO 99
      ENDIF
      T8  = 1.D0/T6/T5
      T12 = C11+C22+C33
      T13 = T5**2
      T17 = C22**2
      T18 = C33**2
      T19 = T17*T18
      T22 = -2.D0/3.D0*T8*C22*C33+4.D0/9.D0*T12/T6/T13*T19
      T26 = T6**2
      T30 = C22*C33
      T43 = 1.D0/T6
      T48 = (T43-T12*T8*T30/3.D0)**2.D0
      T59 = SQRT(T5)
      T62 = T59**2
      DSIDEP(1,1) = 4.D0*C10*T22+4.D0*C01*
     &(-4.D0/3.D0*(C22+C33)/T26/T5*T30+10.D0
     &/9.D0*(T1+C11*C33+T30-T3)/T26/T13*T19)+8.D0*C20*T48+8.D0*C20*(T12*
     &T43-3.D0)*T22+K/T5*T19-K*(T59-1.D0)/T62/T59*T17*T18

      T1  = C11*C22
      T3 = C12**2
      T5   = T1*C33-T3*C33
      T6  = T5**(1.D0/3.D0)
      IF ((T5.LE.0.D0)) THEN
        CODRET=1
        GOTO 99
      ENDIF
      T8  = 1.D0/T6/T5
      T15 = C11+C22+C33
      T16 = T5**2
      T20 = C33**2
      T22 = C22*T20*C11
      T25 = T15*T8
      T28 = -T8*C11*C33/3.D0-T8*C22*C33/3.D0+4.D0/9.D0*T15/T6/T16*T22-T2
     &5*C33/3.D0
      T31 = T6**2
      T35 = 1.D0/T31/T5
      T37 = C11*C33
      T42 = C22*C33
      T45 = T1+T37+T42-T3
      T57 = 1.D0/T6
      T75 = SQRT(T5)
      T77 = K*(T75-1.D0)
      T78 = T75**2
      DSIDEP(1,2) = 4.D0*C10*T28+4.D0*C01*(1.D0/T31-2.D0/3.D0*
     &(C22+C33)*T35*T37-
     &2.D0/3.D0*(C11+C33)*T35*T42+10.D0/9.D0*T45/T31/T16*T22-2.D0/3.D0*T
     &45*T35*C33)+8.D0*C20*(T57-T25*T37/3.D0)*(T57-T25*T42/3.D0)+8.D0*C2
     &0*(T15*T57-3.D0)*T28+K/T5*T22-T77/T78/T75*T22+2.D0*T77/T75*C33

      T1 = C11*C22
      T3 = C12**2
      T5 = T1*C33-T3*C33
      T6 = T5**(1.D0/3.D0)
      IF ((T5.LE.0.D0)) THEN
        CODRET=1
        GOTO 99
      ENDIF
      T8 = 1.D0/T6/T5
      T9 = T1-T3
      T15 = C11+C22+C33
      T16 = T5**2
      T20 = C22*C33
      T21 = T20*T9
      T24 = T15*T8
      T27 = -T8*T9/3.D0-T8*C22*C33/3.D0+4.D0/9.D0*T15/T6/T16*T21-T24*C22
     &/3.D0
      T30 = T6**2
      T34 = 1.D0/T30/T5
      T43 = T1+C11*C33+T20-T3
      T55 = 1.D0/T6
      T73 = SQRT(T5)
      T75 = K*(T73-1.D0)
      T76 = T73**2
      DSIDEP(1,3) = 4.D0*C10*T27+4.D0*C01*(1.D0/T30-2.D0/3.D0*
     &(C22+C33)*T34*T9-2
     &.D0/3.D0*(C11+C22)*T34*T20+10.D0/9.D0*T43/T30/T16*T21-2.D0/3.D0*T4
     &3*T34*C22)+8.D0*C20*(T55-T24*T9/3.D0)*(T55-T24*T20/3.D0)+8.D0*C20*
     &(T15*T55-3.D0)*T27+K/T5*T21-T75/T73/T76*T21+2.D0*T75/T73*C22



      T1 = C11*C22
      T3 = C12**2
      T5 = T1*C33-T3*C33
      T6 = T5**(1.D0/3.D0)
      IF ((T5.LE.0.D0)) THEN
        CODRET=1
        GOTO 99
      ENDIF
      T8 = 1.D0/T6/T5
      T12 = C11+C22+C33
      T13 = T5**2
      T17 = C33**2
      T19 = C22*T17*C12
      T22 = 2.D0/3.D0*T8*C12*C33-8.D0/9.D0*T12/T6/T13*T19
      T26 = T6**2
      T28 = 1.D0/T26/T5
      T30 = C12*C33
      T34 = C22*C33
      T49 = 1.D0/T6
      T66 = SQRT(T5)
      T69 = T66**2
      DSIDEP(1,4) = 4.D0*C10*T22+4.D0*C01*(4.D0/3.D0*(C22+C33)*T28*
     &T30+4.D0/3.D0
     &*C12*T28*T34-20.D0/9.D0*(T1+C11*C33+T34-T3)/T26/T13*T19)+16.D0/3.D
     &0*C20*T12*T8*T30*(T49-T12*T8*T34/3.D0)+8.D0*C20*(T12*T49-3.D0)*T22
     &-2.D0*K/T5*T19+2.D0*K*(T66-1.D0)/T69/T66*T19

      T1 = C11*C22
      T3 = C12**2
      T5 = T1*C33-T3*C33
      T6 = T5**(1.D0/3.D0)
      IF ((T5.LE.0.D0)) THEN
        CODRET=1
        GOTO 99
      ENDIF
      T8 = 1.D0/T6/T5
      T15 = C11+C22+C33
      T16 = T5**2
      T20 = C33**2
      T22 = C22*T20*C11
      T25 = T15*T8
      T28 = -T8*C11*C33/3.D0-T8*C22*C33/3.D0+4.D0/9.D0*T15/T6/T16*T22-T2
     &5*C33/3.D0
      T31 = T6**2
      T35 = 1.D0/T31/T5
      T37 = C11*C33
      T42 = C22*C33
      T45 = T1+T37+T42-T3
      T57 = 1.D0/T6
      T75 = SQRT(T5)
      T77 = K*(T75-1.D0)
      T78 = T75**2
      DSIDEP(2,1) = 4.D0*C10*T28+4.D0*C01*(1.D0/T31-2.D0/3.D0*
     &(C22+C33)*T35*T37-
     &2.D0/3.D0*(C11+C33)*T35*T42+10.D0/9.D0*T45/T31/T16*T22-2.D0/3.D0*T
     &45*T35*C33)+8.D0*C20*(T57-T25*T37/3.D0)*(T57-T25*T42/3.D0)+8.D0*C2
     &0*(T15*T57-3.D0)*T28+K/T5*T22-T77/T78/T75*T22+2.D0*T77/T75*C33

      T1 = C11*C22
      T3 = C12**2
      T5 = T1*C33-T3*C33
      T6 = T5**(1.D0/3.D0)
      IF ((T5.LE.0.D0)) THEN
        CODRET=1
        GOTO 99
      ENDIF
      T8 = 1.D0/T6/T5
      T12 = C11+C22+C33
      T13 = T5**2
      T17 = C11**2
      T18 = C33**2
      T19 = T17*T18
      T22 = -2.D0/3.D0*T8*C11*C33+4.D0/9.D0*T12/T6/T13*T19
      T26 = T6**2
      T30 = C11*C33
      T43 = 1.D0/T6
      T48 = (T43-T12*T8*T30/3.D0)**2.D0
      T59 = SQRT(T5)
      T62 = T59**2
      DSIDEP(2,2) = 4.D0*C10*T22+4.D0*C01*
     &(-4.D0/3.D0*(C11+C33)/T26/T5*T30+10.D0
     &/9.D0*(T1+T30+C22*C33-T3)/T26/T13*T19)+8.D0*C20*T48+8.D0*C20*(T12*
     &T43-3.D0)*T22+K/T5*T19-K*(T59-1.D0)/T62/T59*T17*T18

      T1 = C11*C22
      T3 = C12**2
      T5 = T1*C33-T3*C33
      T6 = T5**(1.D0/3.D0)
      IF ((T5.LE.0.D0)) THEN
        CODRET=1
        GOTO 99
      ENDIF
      T8 = 1.D0/T6/T5
      T9 = T1-T3
      T15 = C11+C22+C33
      T16 = T5**2
      T20 = C11*C33
      T21 = T20*T9
      T24 = T15*T8
      T27 = -T8*T9/3.D0-T8*C11*C33/3.D0+4.D0/9.D0*T15/T6/T16*T21-T24*C11
     &/3.D0
      T30 = T6**2
      T34 = 1.D0/T30/T5
      T43 = T1+C22*C33+T20-T3
      T55 = 1.D0/T6
      T73 = SQRT(T5)
      T75 = K*(T73-1.D0)
      T76 = T73**2
      DSIDEP(2,3) = 4.D0*C10*T27+4.D0*C01*(1.D0/T30-2.D0/3.D0*
     &(C11+C33)*T34*T9-2
     &.D0/3.D0*(C11+C22)*T34*T20+10.D0/9.D0*T43/T30/T16*T21-2.D0/3.D0*T4
     &3*T34*C11)+8.D0*C20*(T55-T24*T9/3.D0)*(T55-T24*T20/3.D0)+8.D0*C20*
     &(T15*T55-3.D0)*T27+K/T5*T21-T75/T73/T76*T21+2.D0*T75/T73*C11



      T1 = C11*C22
      T3 = C12**2
      T5 = T1*C33-T3*C33
      T6 = T5**(1.D0/3.D0)
      IF ((T5.LE.0.D0)) THEN
        CODRET=1
        GOTO 99
      ENDIF
      T8 = 1.D0/T6/T5
      T12 = C11+C22+C33
      T13 = T5**2
      T17 = C33**2
      T19 = C11*T17*C12
      T22 = 2.D0/3.D0*T8*C12*C33-8.D0/9.D0*T12/T6/T13*T19
      T26 = T6**2
      T28 = 1.D0/T26/T5
      T30 = C12*C33
      T34 = C11*C33
      T49 = 1.D0/T6
      T66 = SQRT(T5)
      T69 = T66**2
      DSIDEP(2,4) = 4.D0*C10*T22+4.D0*C01*(4.D0/3.D0*
     &(C11+C33)*T28*T30+4.D0/3.D0
     &*C12*T28*T34-20.D0/9.D0*(T1+T34+C22*C33-T3)/T26/T13*T19)+16.D0/3.D
     &0*C20*T12*T8*T30*(T49-T12*T8*T34/3.D0)+8.D0*C20*(T12*T49-3.D0)*T22
     &-2.D0*K/T5*T19+2.D0*K*(T66-1.D0)/T69/T66*T19
      T1 = C11*C22
      T3 = C12**2
      T5 = T1*C33-T3*C33
      T6 = T5**(1.D0/3.D0)
      IF ((T5.LE.0.D0)) THEN
        CODRET=1
        GOTO 99
      ENDIF
      T8 = 1.D0/T6/T5
      T12 = T1-T3
      T15 = C11+C22+C33
      T16 = T5**2
      T21 = T12*C22*C33
      T24 = T15*T8
      T27 = -T8*C22*C33/3.D0-T8*T12/3.D0+4.D0/9.D0*T15/T6/T16*T21-T24*C2
     &2/3.D0
      T30 = T6**2
      T34 = 1.D0/T30/T5
      T36 = C22*C33
      T44 = T1+C11*C33+T36-T3
      T56 = 1.D0/T6
      T74 = SQRT(T5)
      T76 = K*(T74-1.D0)
      T77 = T74**2
      DSIDEP(3,1) = 4.D0*C10*T27+4.D0*C01*(1.D0/T30-2.D0/3.D0*
     &(C11+C22)*T34*T36-
     &2.D0/3.D0*(C22+C33)*T34*T12+10.D0/9.D0*T44/T30/T16*T21-2.D0/3.D0*T
     &44*T34*C22)+8.D0*C20*(T56-T24*T36/3.D0)*(T56-T24*T12/3.D0)+8.D0*C2
     &0*(T15*T56-3.D0)*T27+K/T5*T21-T76/T77/T74*T21+2.D0*T76/T74*C22

      T1 = C11*C22
      T3 = C12**2
      T5 = T1*C33-T3*C33
      T6 = T5**(1.D0/3.D0)
      IF ((T5.LE.0.D0)) THEN
        CODRET=1
        GOTO 99
      ENDIF
      T8 = 1.D0/T6/T5
      T12 = T1-T3
      T15 = C11+C22+C33
      T16 = T5**2
      T21 = T12*C11*C33
      T24 = T15*T8
      T27 = -T8*C11*C33/3.D0-T8*T12/3.D0+4.D0/9.D0*T15/T6/T16*T21-T24*C1
     &1/3.D0
      T30 = T6**2
      T34 = 1.D0/T30/T5
      T36 = C11*C33
      T44 = T1+T36+C22*C33-T3
      T56 = 1.D0/T6
      T74 = SQRT(T5)
      T76 = K*(T74-1.D0)
      T77 = T74**2
      DSIDEP(3,2) = 4.D0*C10*T27+4.D0*C01*(1.D0/T30-2.D0/3.D0*
     &(C11+C22)*T34*T36-
     &2.D0/3.D0*(C11+C33)*T34*T12+10.D0/9.D0*T44/T30/T16*T21-2.D0/3.D0*T
     &44*T34*C11)+8.D0*C20*(T56-T24*T36/3.D0)*(T56-T24*T12/3.D0)+8.D0*C2
     &0*(T15*T56-3.D0)*T27+K/T5*T21-T76/T77/T74*T21+2.D0*T76/T74*C11

      T1 = C11*C22
      T3 = C12**2
      T5 = T1*C33-T3*C33
      T6 = T5**(1.D0/3.D0)
      IF ((T5.LE.0.D0)) THEN
        CODRET=1
        GOTO 99
      ENDIF
      T8 = 1.D0/T6/T5
      T9 = T1-T3
      T12 = C11+C22+C33
      T13 = T5**2
      T17 = T9**2
      T20 = -2.D0/3.D0*T8*T9+4.D0/9.D0*T12/T6/T13*T17
      T24 = T6**2
      T41 = 1.D0/T6
      T46 = (T41-T8*T12*T9/3.D0)**2.D0
      T57 = SQRT(T5)
      T60 = T57**2
      DSIDEP(3,3) = 4.D0*C10*T20+4.D0*C01*(-4.D0/3.D0*(C11+C22)
     &/T24/T5*T9+10.D0/
     &9.D0*(T1+C11*C33+C22*C33-T3)/T24/T13*T17)+8.D0*C20*T46+8.D0*C20*(T
     &12*T41-3.D0)*T20+K/T5*T17-K*(T57-1.D0)/T60/T57*T17

      T1 = C11*C22
      T3 = C12**2
      T5 = T1*C33-T3*C33
      T6 = T5**(1.D0/3.D0)
      IF ((T5.LE.0.D0)) THEN
        CODRET=1
        GOTO 99
      ENDIF
      T8 = 1.D0/T6/T5
      T12 = C11+C22+C33
      T13 = T5**2
      T17 = T1-T3
      T19 = T17*C12*C33
      T22 = T8*T12
      T25 = 2.D0/3.D0*T8*C12*C33-8.D0/9.D0*T12/T6/T13*T19+2.D0/3.D0*T22*
     &C12
      T29 = T6**2
      T31 = 1.D0/T29/T5
      T33 = C12*C33
      T41 = T1+C11*C33+C22*C33-T3
      T55 = 1.D0/T6
      T71 = SQRT(T5)
      T73 = K*(T71-1.D0)
      T74 = T71**2
      DSIDEP(3,4) = 4.D0*C10*T25+4.D0*C01*(4.D0/3.D0*
     &(C11+C22)*T31*T33+4.D0/3.D0
     &*C12*T31*T17-20.D0/9.D0*T41/T29/T13*T19+4.D0/3.D0*T41*T31*C12)+16.
     &D0/3.D0*C20*T12*T8*T33*(T55-T22*T17/3.D0)+8.D0*C20*(T12*T55-3.D0)*
     &T25-2.D0*K/T5*T19+2.D0*T73/T74/T71*T19-4.D0*T73/T71*C12

      T1 = C11*C22
      T3 = C12**2
      T5 = T1*C33-T3*C33
      T6 = T5**(1.D0/3.D0)
      IF ((T5.LE.0.D0)) THEN
        CODRET=1
        GOTO 99
      ENDIF
      T8 = 1.D0/T6/T5
      T10 = C12*C33
      T13 = C11+C22+C33
      T15 = T5**2
      T17 = 1.D0/T6/T15
      T19 = C33**2
      T21 = C12*T19*C22
      T24 = T6**2
      T26 = 1.D0/T24/T5
      T28 = C22*C33
      T45 = 1.D0/T6
      T53 = T8*C12*C33
      T58 = C20*(T13*T45-3.D0)
      T71 = SQRT(T5)
      T74 = T71**2
      DSIDEP(4,1) = 8.D0/3.D0*C10*T8*T10-32.D0/9.D0*
     &C10*T13*T17*T21+4.D0*C01*(4.
     &D0/3.D0*C12*T26*T28+4.D0/3.D0*(C22+C33)*T26*T10-20.D0/9.D0*(T1+C11
     &*C33+T28-T3)/T24/T15*T21)+16.D0/3.D0*C20*(T45-T13*T8*T28/3.D0)*T13
     &*T53+16.D0/3.D0*T58*T53-64.D0/9.D0*T58*T13*T17*C12*T19*C22-2.D0*K/
     &T5*T21+2.D0*K*(T71-1.D0)/T74/T71*T21

      T1 = C11*C22
      T3 = C12**2
      T5 = T1*C33-T3*C33
      T6 = T5**(1.D0/3.D0)
      IF ((T5.LE.0.D0)) THEN
        CODRET=1
        GOTO 99
      ENDIF
      T8 = 1.D0/T6/T5
      T10 = C12*C33
      T13 = C11+C22+C33
      T15 = T5**2
      T17 = 1.D0/T6/T15
      T19 = C33**2
      T21 = C12*T19*C11
      T25 = T6**2
      T27 = 1.D0/T25/T5
      T32 = C11*C33
      T47 = 1.D0/T6
      T57 = C20*(T13*T47-3.D0)
      T72 = SQRT(T5)
      T75 = T72**2
      DSIDEP(4,2) = 8.D0/3.D0*C10*T8*T10-32.D0/9.D0*C10*T13*T17*
     &T21+4.D0*C01*(4.
     &D0/3.D0*(C11+C33)*T27*T10+4.D0/3.D0*C12*T27*T32-20.D0/9.D0*(T1+T32
     &+C22*C33-T3)/T25/T15*T21)+16.D0/3.D0*C20*T13*T8*T10*(T47-T13*T8*T3
     &2/3.D0)+16.D0/3.D0*T57*T8*C12*C33-64.D0/9.D0*T57*T13*T17*C12*T19*C
     &11-2.D0*K/T5*T21+2.D0*K*(T72-1.D0)/T75/T72*T21

      T1 = C11*C22
      T3 = C12**2
      T5 = T1*C33-T3*C33
      T6 = T5**(1.D0/3.D0)
      IF ((T5.LE.0.D0)) THEN
        CODRET=1
        GOTO 99
      ENDIF
      T8 = 1.D0/T6/T5
      T10 = C12*C33
      T13 = C11+C22+C33
      T14 = C10*T13
      T15 = T5**2
      T17 = 1.D0/T6/T15
      T19 = T1-T3
      T20 = T10*T19
      T23 = T8*C12
      T27 = T6**2
      T29 = 1.D0/T27/T5
      T38 = T1+C11*C33+C22*C33-T3
      T52 = 1.D0/T6
      T53 = T13*T8
      T62 = C20*(T13*T52-3.D0)
      T79 = SQRT(T5)
      T81 = K*(T79-1.D0)
      T82 = T79**2
      DSIDEP(4,3) = 8.D0/3.D0*C10*T8*T10-32.D0/9.D0*T14*T17*
     &T20+8.D0/3.D0*T14*T2
     &3+4.D0*C01*(4.D0/3.D0*(C11+C22)*T29*T10+4.D0/3.D0*C12*T29*T19-20.D
     &0/9.D0*T38/T27/T15*T20+4.D0/3.D0*T38*T29*C12)+16.D0/3.D0*C20*T13*T
     &8*T10*(T52-T53*T19/3.D0)+16.D0/3.D0*T62*T23*C33-64.D0/9.D0*T62*T13
     &*T17*C12*C33*T19+16.D0/3.D0*T62*T53*C12-2.D0*K/T5*T20+2.D0*T81/T82
     &/T79*T20-4.D0*T81/T79*C12

      T1  = C11+C22+C33
      T2  = C10*T1
      T3  = C11*C22
      T5  = C12**2
      T7  = T3*C33-T5*C33
      IF ((T7.LE.0.D0)) THEN
        CODRET=1
        GOTO 99
      ENDIF
      T8  = T7**2
      T9  = T7**(1.D0/3.D0)
      T13 = C33**2
      T14 = 1.D0/T9/T8*T5*T13
      T18 = 1.D0/T9/T7
      T22 = T9**2
      T26 = 1.D0/T22/T7
      T32 = T3+C11*C33+C22*C33-T5
      T34 = 1.D0/T22/T8
      T36 = T5*T13
      T45 = T1**2
      T54 = C20*(T1/T9-3.D0)
      T66 = SQRT(T7)
      T68 = K*(T66-1.D0)
      T69 = T66**2
      DSIDEP(4,4) = 64.D0/9.D0*T2*T14+8.D0/3.D0*T2*T18*C33+4.
     &D0*C01*(-2.D0/T22-1
     &6.D0/3.D0*T5*T26*C33+40.D0/9.D0*T32*T34*T36+4.D0/3.D0*T32*T26*C33)
     &+32.D0/9.D0*C20*T45*T34*T5*T13+128.D0/9.D0*T54*T1*T14+16.D0/3.D0*T
     &54*T1*T18*C33+4.D0*K/T7*T36-4.D0*T68/T69/T66*T5*T13-4.D0*T68/T66*C
     &33
 99   CONTINUE
      END
