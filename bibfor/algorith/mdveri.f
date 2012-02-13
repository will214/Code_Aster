      SUBROUTINE MDVERI ()
      IMPLICIT REAL*8 (A-H,O-Z)
C ----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 13/02/2012   AUTEUR BODEL C.BODEL 
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
C    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================
C
C     VERIFICATION DE PREMIER NIVEAU

C     ----- DEBUT COMMUNS NORMALISES  JEVEUX  --------------------------

      INTEGER ZI
      COMMON /IVARJE/ZI(1)
      REAL*8 ZR
      COMMON /RVARJE/ZR(1)
      COMPLEX*16 ZC
      COMMON /CVARJE/ZC(1)
      LOGICAL ZL
      COMMON /LVARJE/ZL(1)
      CHARACTER*8    ZK8
      CHARACTER*16          ZK16
      CHARACTER*24                  ZK24
      CHARACTER*32                          ZK32
      CHARACTER*80                                  ZK80
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
      CHARACTER*32     JEXNOM

C     ----- FIN COMMUNS NORMALISES  JEVEUX  ----------------------------
C
      INTEGER       I,NBCHOC,NBREDE,NBREVI,IBID,JREF1,JREF2
      REAL*8        R8BID
      CHARACTER*8   NOMRES,METHOD,AMOGEN,K8BID,OUINON,CHANNO
      CHARACTER*8   MATR1,MATR2,BASEMO
      CHARACTER*24  REF1,REF2
      CHARACTER*16  TYPRES,NOMCMD
      INTEGER       IARG
C
C-----------------------------------------------------------------------
C
      CALL GETRES(NOMRES,TYPRES,NOMCMD)
      CALL GETVTX('SCHEMA_TEMPS','SCHEMA' ,1,IARG,1,METHOD,N1)
C
      CALL GETVID(' ','MATR_AMOR',0,IARG,1,AMOGEN,NAGEN)
      CALL GETVR8('AMOR_MODAL','AMOR_REDUIT',1,IARG,0,R8BID,NARED)
      IF (NAGEN.NE.0 .AND. METHOD.EQ.'DEVOGE') THEN
         CALL U2MESS('E','ALGORITH5_67')
      ENDIF
      IF (NAGEN.EQ.0 .AND. NARED.EQ.0 .AND. METHOD(1:4).EQ.'ITMI') THEN
         CALL U2MESS('E','ALGORITH5_68')
      ENDIF
C
      IF (METHOD(1:4).EQ.'ITMI') THEN
        CALL GETVID('SCHEMA_TEMPS','BASE_ELAS_FLUI',1,IARG,0,
     &              K8BID,NBASFL)
        IF (NBASFL.EQ.0)   CALL U2MESS('E','ALGORITH5_69')

        CALL GETVR8('INCREMENT','PAS',1,IARG,0,R8BID,NPAS)
        IF (NPAS.EQ.0)  CALL U2MESS('E','ALGORITH5_70')

        CALL GETVTX('SCHEMA_TEMPS','ETAT_STAT',1,IARG,1,OUINON,IBID)
        IF (OUINON(1:3).EQ.'OUI') THEN
          CALL GETVR8('SCHEMA_TEMPS','TS_REG_ETAB',1,IARG,0,R8BID,NTS)
          IF (NTS.EQ.0)   CALL U2MESS('E','ALGORITH5_71')
        ENDIF

        CALL GETVTX('CHOC','SOUS_STRUC_1',1,IARG,0,K8BID,N1)
        IF (N1.NE.0)  CALL U2MESS('E','ALGORITH5_72')

        CALL GETVTX('CHOC','NOEUD_2',1,IARG,0,K8BID,N1)
        IF (N1.NE.0)  CALL U2MESS('E','ALGORITH5_73')

        CALL GETVTX('CHOC','SOUS_STRUC_2',1,IARG,0,K8BID,N1)
        IF (N1.NE.0)  CALL U2MESS('E','ALGORITH5_74')
      ENDIF
C
      CALL GETFAC('RELA_EFFO_DEPL',NBREDE)
      IF ( NBREDE .NE. 0 ) THEN
        IF ( METHOD .EQ. 'NEWMARK' )
     +      CALL U2MESK('E','ALGORITH5_75',1,'RELA_EFFO_DEPL')
      ENDIF
C
      CALL GETFAC('RELA_EFFO_VITE',NBREVI)
      IF ( NBREVI .NE. 0 ) THEN
         IF ( METHOD .EQ. 'NEWMARK' )
     +      CALL U2MESK('E','ALGORITH5_75',1,'RELA_EFFO_VITE')
      ENDIF
C
      CALL GETFAC('CHOC',NBCHOC)
      IF (NBCHOC.NE.0) THEN
         IF (METHOD.EQ.'NEWMARK')
     +      CALL U2MESK('E','ALGORITH5_75',1,'CHOC')
      ENDIF
C
      CALL GETFAC('EXCIT',NBEXC)
      KF = 0
      DO 20 I=1,NBEXC
        CALL GETVID('EXCIT','VECT_ASSE',I,IARG,0,K8BID,NM)
        IF (NM .NE. 0) THEN
          KF = KF+1
        ENDIF
 20   CONTINUE
      IF (KF.NE.0 .AND. METHOD(1:4).EQ.'ITMI') THEN
         CALL U2MESS('E','ALGORITH5_78')
      ENDIF
C
C     COHERENCE MATRICES
      CALL GETVID(' ','MATR_MASS',0,IARG,1,MATR1,IBID)
      CALL GETVID(' ','MATR_RIGI',0,IARG,1,MATR2,IBID)
      CALL JEVEUO(MATR1//'           .REFA','L',JREF1)
      CALL JEVEUO(MATR2//'           .REFA','L',JREF2)
      REF1=ZK24(JREF1)
      REF2=ZK24(JREF2)
      IF (REF1(1:8).NE.REF2(1:8)) THEN
        CALL U2MESS('E','ALGORITH5_42')
      ENDIF
C
C     COHERENCE EXCITATIONS SOUS LE MC EXCIT/VECT_ASSE ET LES MATRICES
      BASEMO=REF1(1:8)
      DO 21 I=1,NBEXC
        CALL GETVID('EXCIT','VECT_ASSE',I,IARG,IBID,CHANNO,NM)
        IF (NM .NE. 0) THEN
          CALL JEVEUO(CHANNO//'           .REFE','L',JREF1)
          REF1=ZK24(JREF1)
          IF (REF1(1:8).NE.BASEMO) THEN
            CALL U2MESS('E','ALGORITH5_42')
          ENDIF
        ENDIF
  21  CONTINUE
        
      

      END
