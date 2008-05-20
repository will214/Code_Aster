      SUBROUTINE CFFROT(MAF1  ,MAF2  ,MAFROT)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 19/05/2008   AUTEUR ABBAS M.ABBAS 
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
C RESPONSBALE
C
      IMPLICIT     NONE
      CHARACTER*19 MAF1
      CHARACTER*19 MAF2
      CHARACTER*19 MAFROT
C      
C ----------------------------------------------------------------------
C
C ROUTINE CONTACT (METHODES DISCRETES - FROTTEMENT)
C
C CALCUL DE LA MATRICE DE FROTTEMENT
C
C ----------------------------------------------------------------------
C
C
C IN  MAF1   : PARTIE 1 DE LA MATRICE FROTTEMENT
C IN  MAF2   : PARTIE 2 DE LA MATRICE FROTTEMENT
C OUT MAFROT : MATRICE GLOBALE TANGENTE AVEC FROTTEMENT RESULTANTE
C
C --- DEBUT DECLARATIONS NORMALISEES JEVEUX ---------------------------
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
C ---------- FIN  DECLARATIONS  NORMALISEES  JEVEUX --------------------
C
      INTEGER       IBID, IER
      REAL*8        COEFMU(2)
      CHARACTER*1   TYPCST(2)
      CHARACTER*14  NUMEF1, NUMEF2
      CHARACTER*24  LIMAT(2)
C ----------------------------------------------------------------------
C
C --- DESTRUCTION ANCIENNE MATRICE FROTTEMENT
C
      CALL DETRSD('MATR_ASSE',MAFROT)
C
C --- PREPARATION COMBINAISON LINEAIRE MAFROT=MAF1-MAF2
C
      LIMAT(1)  = MAF1
      LIMAT(2)  = MAF2
      COEFMU(1) =  1.0D0
      COEFMU(2) = -1.0D0
      TYPCST(1) = 'R'
      TYPCST(2) = 'R'
C
C --- COMBINAISON LINEAIRE MAFROT=MAF1-MAF2
C
      CALL MTDEFS(MAFROT,MAF1,'V','R')
      CALL MTCMBL(2,TYPCST,COEFMU,LIMAT,MAFROT,' ',' ','ELIM=')
C
C --- DESTRUCTION DES NUME_DDL
C
      CALL DISMOI('F','NOM_NUME_DDL',MAF1,'MATR_ASSE',IBID,NUMEF1,IER)
      CALL DISMOI('F','NOM_NUME_DDL',MAF2,'MATR_ASSE',IBID,NUMEF2,IER)
      CALL DETRSD('NUME_DDL',NUMEF1)
      CALL DETRSD('NUME_DDL',NUMEF2)
C
C --- DESTRUCTION DES MATRICES DE CONSTRUCTION
C
      CALL DETRSD('MATR_ASSE',MAF2  )
      CALL DETRSD('MATR_ASSE',MAF1  )
C
      END
