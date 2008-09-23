      SUBROUTINE CFADU (RESOCO,DEPDEL,NEQ   ,NDIM  ,NBLIAC,
     &                  LLF   ,LLF1  ,LLF2  ,NESMAX)
C 
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 23/09/2008   AUTEUR ABBAS M.ABBAS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2003  EDF R&D                  WWW.CODE-ASTER.ORG
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
       IMPLICIT      NONE
       INTEGER       NEQ,NDIM
       INTEGER       NBLIAC,LLF,LLF1,LLF2
       INTEGER       NESMAX
       CHARACTER*24  RESOCO
       CHARACTER*(*) DEPDEL
C      
C ----------------------------------------------------------------------
C
C ROUTINE CONTACT (METHODES DISCRETES - RESOLUTION)
C
C ROUTINE MERE POUR LE CALCUL DU SECOND MEMBRE
C
C ----------------------------------------------------------------------
C
C
C IN  RESOCO : SD DE TRAITEMENT NUMERIQUE DU CONTACT
C                'E': RESOCO(1:14)//'.MU'
C IN  DEPDEL : INCREMENT DE DEPLACEMENT CUMULE
C IN  NEQ    : NOMBRE D'EQUATIONS
C IN  NDIM   : DIMENSION DU PROBLEME
C IN  NBLIAC : NOMBRE DE LIAISONS ACTIVES
C IN  LLF    : NOMBRE DE LIAISONS DE FROTTEMENT (EN 2D)
C              NOMBRE DE LIAISONS DE FROTTEMENT SUIVANT LES DEUX 
C               DIRECTIONS SIMULTANEES (EN 3D)
C IN  LLF1   : NOMBRE DE LIAISONS DE FROTTEMENT SUIVANT LA 
C               PREMIERE DIRECTION (EN 3D)
C IN  LLF2   : NOMBRE DE LIAISONS DE FROTTEMENT SUIVANT LA 
C               SECONDE DIRECTION (EN 3D)
C IN  NESMAX : NOMBRE MAXI DE NOEUDS ESCLAVES
C              SERT AU DECALAGE DANS LES ROUTINES DE FROTTEMENT 3D
C              (VAUT DONC ZERO SI SANS FROTTEMENT OU FROTTEMENT 2D)
C 
C
C -------------- DEBUT DECLARATIONS NORMALISEES JEVEUX -----------------
C
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
C
C ---------------- FIN DECLARATIONS NORMALISEES JEVEUX -----------------
C
      INTEGER       ILIAC,NBDDL,POSIT 
      INTEGER       LLIAC,JDECAL,JDEPDE,DEKLAG
      REAL*8        VAL,VAL1,VAL2
      CHARACTER*19  LIAC,MU,DELT0
      INTEGER       JLIAC,JMU,JDELT0
      CHARACTER*24  APPOIN,APDDL,APCOEF,APCOFR,APJEU
      INTEGER       JAPPTR,JAPDDL,JAPCOE,JAPCOF,JAPJEU
C      
C ----------------------------------------------------------------------
C
      CALL JEMARQ ()
C 
      APPOIN = RESOCO(1:14)//'.APPOIN'
      APDDL  = RESOCO(1:14)//'.APDDL'
      LIAC   = RESOCO(1:14)//'.LIAC'
      APCOEF = RESOCO(1:14)//'.APCOEF'
      APCOFR = RESOCO(1:14)//'.APCOFR'
      APJEU  = RESOCO(1:14)//'.APJEU'
      MU     = RESOCO(1:14)//'.MU'
      DELT0  = RESOCO(1:14)//'.DEL0'
C
      CALL JEVEUO(APPOIN,'L',JAPPTR)
      CALL JEVEUO(APDDL, 'L',JAPDDL)
      CALL JEVEUO(LIAC,  'L',JLIAC )
      CALL JEVEUO(APCOEF,'L',JAPCOE)
      CALL JEVEUO(APJEU, 'L',JAPJEU)
      CALL JEVEUO(DELT0, 'L',JDELT0)
      CALL JEVEUO(MU,    'E',JMU   )
      IF ((LLF+LLF1+LLF2).NE.0) THEN
         CALL JEVEUO (DEPDEL(1:19)//'.VALE', 'L', JDEPDE)
         CALL JEVEUO (APCOFR,'L',JAPCOF)
      ENDIF
C ======================================================================
      DEKLAG = 0
C ======================================================================
      DO 10 ILIAC = 1, NBLIAC + LLF + LLF1 + LLF2
         LLIAC  = ZI(JLIAC-1+ILIAC)
         JDECAL = ZI(JAPPTR+LLIAC-1)
         NBDDL  = ZI(JAPPTR+LLIAC) - ZI(JAPPTR+LLIAC-1)
         CALL CFTYLI(RESOCO, ILIAC, POSIT)
         GOTO (1000, 2000, 3000, 4000) POSIT
C ======================================================================
C --- CALCUL DE MU_C ---------------------------------------------------
C ======================================================================
 1000    CONTINUE
         CALL CALADU (NEQ,NBDDL,ZR(JAPCOE+JDECAL),
     &                                 ZI(JAPDDL+JDECAL),ZR(JDELT0),VAL)
         ZR(JMU+ILIAC+DEKLAG-1) = ZR(JAPJEU+LLIAC-1) - VAL
         GOTO 10
C ======================================================================
C --- CALCUL DE MU_SG SUIVANT LES DEUX DIRECTIONS (3D) -----------------
C --- OU SUIVANT LA DIRECTION (2D)                     -----------------
C --- DEPUIS LE DEBUT DU PAS DE TEMPS ----------------------------------
C ======================================================================
 2000     CONTINUE
          CALL CALADU (NEQ,NBDDL,ZR(JAPCOF+JDECAL),
     +                                ZI(JAPDDL+JDECAL),ZR(JDELT0),VAL1)
          CALL CALADU (NEQ,NBDDL,ZR(JAPCOF+JDECAL),
     +                                ZI(JAPDDL+JDECAL),ZR(JDEPDE),VAL2)
          VAL = VAL1 + VAL2
          ZR(JMU+ILIAC+DEKLAG-1) = ZR(JMU+ILIAC+DEKLAG-1) - VAL
          IF (NDIM.EQ.3) THEN
             DEKLAG = DEKLAG + 1
             CALL CALADU (NEQ,NBDDL,ZR(JAPCOF+JDECAL+30*NESMAX),
     +                                ZI(JAPDDL+JDECAL),ZR(JDELT0),VAL1)
             CALL CALADU (NEQ,NBDDL,ZR(JAPCOF+JDECAL+30*NESMAX),
     +                                ZI(JAPDDL+JDECAL),ZR(JDEPDE),VAL2)
             VAL = VAL1 + VAL2
             ZR(JMU+ILIAC+DEKLAG-1) = ZR(JMU+ILIAC+DEKLAG-1) - VAL
          ENDIF
          GOTO 10
C ======================================================================
C --- CALCUL DE MU_SG SUIVANT LA PREMIERE DIRECTION --------------------
C --- DEPUIS LE DEBUT DU PAS DE TEMPS ----------------------------------
C ======================================================================
 3000     CONTINUE
          CALL CALADU (NEQ,NBDDL,ZR(JAPCOF+JDECAL),
     +                                ZI(JAPDDL+JDECAL),ZR(JDELT0),VAL1)
          CALL CALADU (NEQ,NBDDL,ZR(JAPCOF+JDECAL),
     +                                ZI(JAPDDL+JDECAL),ZR(JDEPDE),VAL2)
          VAL = VAL1 + VAL2
          ZR(JMU+ILIAC+DEKLAG-1) = ZR(JMU+ILIAC+DEKLAG-1) - VAL
          GOTO 10
C ======================================================================
C --- CALCUL DE MU_SG SUIVANT LA SECONDE DIRECTION --------------------
C --- DEPUIS LE DEBUT DU PAS DE TEMPS ----------------------------------
C ======================================================================
 4000     CONTINUE
          CALL CALADU (NEQ,NBDDL,ZR(JAPCOF+JDECAL+30*NESMAX),
     +                                ZI(JAPDDL+JDECAL),ZR(JDELT0),VAL1)
          CALL CALADU (NEQ,NBDDL,ZR(JAPCOF+JDECAL+30*NESMAX),
     +                                ZI(JAPDDL+JDECAL),ZR(JDEPDE),VAL2)
          VAL = VAL1 + VAL2
          ZR(JMU+ILIAC+DEKLAG-1) = ZR(JMU+ILIAC+DEKLAG-1) - VAL
 10    CONTINUE
C ======================================================================
       CALL JEDEMA ()
C ======================================================================
       END
