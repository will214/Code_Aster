       SUBROUTINE FOCMAX ( NOMFON,LTINI,LTFIN,CRIT,EPSI,NOMOPE,COEF,
     &                     TINI,TFIN,NBVALU,AMAX,VMAX,DMAX,BASE,IER)
       IMPLICIT NONE
       INTEGER        NBMAX, NBPTS,NBVAL,LTEMP,IER,LVAR
       INTEGER        LTINI,LTFIN,NBVALU      
       REAL*8         TINI,TFIN,COEF,AMAX,VMAX,DMAX,EPSI
       CHARACTER*1    BASE
       CHARACTER*8    CRIT
       CHARACTER*19   NOMFON
       CHARACTER*16   NOMOPE
       CHARACTER*24   VALE
C      -----------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF UTILITAI  DATE 08/03/2004   AUTEUR REZETTE C.REZETTE 
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
C
C           ROUTINE APPELEE PAR FONOCI
C      CALCUL DE L ACCELERATION, DE LA VITESSE ET DU DEPLACEMENT MAX
C      IN : NOMFON  NOM DE LA FONCTION 
C      IN :  TINI TEMP DEBUT
C      IN :  LTINI  VAUT 1 
C                    L UTILISATEUR RENSEINE  INST_INIT
C                  SINON LTINI DIFFERENT DE 0
C      IN :  TFIN TEMP FIN
C      IN :  LTFIN  VAUT 1 
C                   L UTILISATEUR A RENSEIGNE INST_FIN
C                  SINON LTFIN DIFFERENT DE 0
C      IN :  CRIT : CRITERE DE POSITION DANS L INTERVALLE ABSOLU OU REL
C           ATIVE
C      IN :  EPSI :TOLERANCE D ERREUR
C      OUT : NBVALU NOMBRE DE VALEUR A CONSIDERE
C      OUT  : AMAX ACCELERATION MAXIMALE
C      OUT  : VMAX VITESSE MAXIMALE
C      OUT  : DMAX DEPLACEMENT MAXIMAL
C      -----------------------------------------------------------------
C        ----- DEBUT COMMUNS NORMALISES  JEVEUX  ----------------------
       INTEGER          ZI
       COMMON  /IVARJE/ ZI(1)
       REAL*8           ZR
       COMMON  /RVARJE/ ZR(1)
       COMPLEX*16       ZC
       COMMON  /CVARJE/ ZC(1)
       LOGICAL          ZL
       COMMON  /LVARJE/ ZL(1)
       CHARACTER*8      ZK8
       CHARACTER*16            ZK16
       CHARACTER*24                    ZK24
       CHARACTER*32                            ZK32
       CHARACTER*80                                    ZK80
       COMMON  /KVARJE/ ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C     -----  FIN  COMMUNS NORMALISES  JEVEUX -------------------------- 
       INTEGER        LDEPM,LVITM
       CHARACTER*1    K1BID
       CHARACTER*19   NOMVIT,NOMDEP
C      -----------------------------------------------------------------
C
       CALL JEMARQ()
C
C      ---  NOMBRE DE POINTS ----
       VALE = NOMFON//'.VALE'
       CALL JELIRA ( VALE, 'LONUTI', NBVAL, K1BID )
       CALL JEVEUO ( VALE, 'L', LVAR )
       NBPTS = NBVAL/2
C       
      CALL WKVECT ( '&&FOCAMA.VALE', 'V V R', NBVAL, LTEMP )
      CALL FOVIMA ( NOMFON, TINI, LTINI, TFIN, LTFIN, CRIT, EPSI,
     &                            NBVALU, ZR(LTEMP), ZR(LTEMP+NBPTS) )
C
      AMAX = ABS ( ZR(LTEMP+NBPTS) )
C
C        
C --- CALCUL DE VMAX :
C     ----------------            
C
       CALL FOVECA(NOMOPE,NOMFON,IER)
C
       IF (IER .NE. 0 ) GOTO 9999
 
C      --- AINSI ON OBTIENT PAR INTEGRATION V(T) ("NOMVIT") ---
         
      NOMVIT = '&&FOCMAX.VIT'
      CALL FOCAIN('TRAPEZE',NOMFON,COEF,NOMVIT,BASE)

C     ---CALCUL DE LA VITESSE MAX
      CALL WKVECT ( '&&FOVIMA.VALE', 'V V R', NBVAL, LVITM )
      CALL FOVIMA ( NOMVIT, TINI, LTINI, TFIN, LTFIN, CRIT, EPSI,
     &                            NBVALU, ZR(LVITM), ZR(LVITM+NBPTS) )
      VMAX = ABS(ZR(LVITM+NBPTS))
C
 
C        
C --- CALCUL DE DMAX :
C     ----------------            
C              
      CALL FOVECA(NOMOPE,NOMVIT,IER)
      IF (IER .NE. 0 ) GOTO 9999
C
C     --- AINSI ON OBTIENT PAR INTEGRATION X(T) ("NOMDEP") ---

      NOMDEP = '&&FOCMAX.DEP'
      CALL FOCAIN('TRAPEZE',NOMVIT,COEF,NOMDEP,BASE)
           
C     --- CALCUL DU DEPLACEMENT MAX
      CALL WKVECT ( '&&FODEMA.VALE', 'V V R', NBVAL, LDEPM )
      CALL FOVIMA ( NOMDEP, TINI, LTINI, TFIN, LTFIN, CRIT, EPSI,
     &                            NBVALU, ZR(LDEPM), ZR(LDEPM+NBPTS) )
      DMAX = ABS( ZR(LDEPM+NBPTS) )
C
      CALL JEDETR ( '&&FOCAMA.VALE' )
C
      CALL JEDETR ( '&&FOVIMA.VALE' )
      CALL JEDETR ( '&&FOCMAX.VIT       .PROL' )
      CALL JEDETR ( '&&FOCMAX.VIT       .VALE' )
C
      CALL JEDETR ( '&&FODEMA.VALE' )
      CALL JEDETR ( '&&FOCMAX.DEP       .PROL' ) 
      CALL JEDETR ( '&&FOCMAX.DEP       .VALE' ) 
C
 9999 CONTINUE 
      CALL JEDEMA() 
C   
      END
