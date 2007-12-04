      SUBROUTINE CALPRC(NOMRES,CLASSE,BASMOD,NOMMAT)
      IMPLICIT NONE
      CHARACTER*24 NOMRES
      CHARACTER*1  CLASSE
      CHARACTER*8  BASMOD
      CHARACTER*19 NOMMAT
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 08/11/2007   AUTEUR SALMONA L.SALMONA 
C ======================================================================
C COPYRIGHT (C) 1991 - 2007  EDF R&D                  WWW.CODE-ASTER.ORG
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
C  BUT : < PROJECTION MATRICE SUR BASE QUELCONQUE >
C
C        CONSISTE A PROJETER UNE MATRICE ASSSEMBLEE COMPLEXE 
C        SUR UNE BASE QUELCONQUE (PAS DE PROPRIETE D'ORTHOGONALITE)
C
C        LA MATRICE RESULTAT EST SYMETRIQUE ET STOCKEE TRIANGLE SUP
C
C-----------------------------------------------------------------------
C
C NOMRES /O/ : NOM K19 DE LA MATRICE CARREE RESULTAT
C CLASSE /I/ : CLASSE DE LA BASE JEVEUX DE L'OBJET RESULTAT
C BASMOD /I/ : NOM UTILISATEUR DE LA BASE MODALE DE PROJECTION
C NOMMAT /I/ : NOM UTITISATEUR DE LA MATRICE A PROJETER (RAIDEUR,MASSE)
C
C-------- DEBUT COMMUNS NORMALISES  JEVEUX  ----------------------------
C
      INTEGER ZI
      COMMON /IVARJE/ZI(1)
      REAL*8 ZR
      COMMON /RVARJE/ZR(1)
      COMPLEX*16 ZC
      COMMON /CVARJE/ZC(1)
      LOGICAL ZL
      COMMON /LVARJE/ZL(1)
      CHARACTER*8 ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C
C----------  FIN  COMMUNS NORMALISES  JEVEUX  --------------------------
C
      CHARACTER*6  PGC
      CHARACTER*8  K8BID
      CHARACTER*16 TYPO
      CHARACTER*14 NUM
      CHARACTER*24 VALK
      CHARACTER*24 CHAVAL, NOMCH1
      COMPLEX*16   XPROD,DCMPLX
      INTEGER      LDREF,NBDEF,NTAIL,LDRES,IER,LMAT,NEQ,IRET,IBID
      INTEGER      IDDEEQ,IDBASE,LTVEC1,LTVEC2,I,J,K,IAD,LDDES
      
C
C-----------------------------------------------------------------------
      DATA PGC/'CALPRC'/
C-----------------------------------------------------------------------
C
C --- CREATION DU .REFE
C
      CALL JEMARQ()
      CALL WKVECT(NOMRES(1:18)//'_REFE','G V K24',2,LDREF)
      ZK24(LDREF) = BASMOD
      ZK24(LDREF+1) = NOMMAT(1:8)
C
C --- RECUPERATION DES DIMENSIONS DE LA BASE MODALE
C
      CALL BMNBMD(BASMOD,'TOUT',NBDEF)
C
C --- ALLOCATION DE LA MATRICE RESULTAT
C
      NTAIL = NBDEF* (NBDEF+1)/2
      CALL WKVECT(NOMRES(1:18)//'_VALE',CLASSE//' V C',NTAIL,LDRES)
C
C --- CONTROLE D'EXISTENCE DE LA MATRICE
C
      CALL MTEXIS(NOMMAT(1:8),IER)
      IF (IER.EQ.0) THEN
        VALK = NOMMAT(1:8)
        CALL U2MESG('E', 'ALGORITH12_39',1,VALK,0,0,0,0.D0)
      ENDIF
C
C --- ALLOCATION DESCRIPTEUR DE LA MATRICE
C
      CALL MTDSCR(NOMMAT(1:8))
      CALL JEVEUO(NOMMAT(1:19)//'.&INT','E',LMAT)
C
C --- RECUPERATION NUMEROTATION ET NB EQUATIONS
C
      CALL DISMOI('F','NB_EQUA',NOMMAT(1:8),'MATR_ASSE',NEQ,K8BID,IRET)
      CALL DISMOI('F','NOM_NUME_DDL',NOMMAT(1:8),'MATR_ASSE',IBID,NUM,
     +            IRET)
      CALL JEVEUO(NUM//'.NUME.DEEQ','L',IDDEEQ)
C
      CALL WKVECT('&&'//PGC//'.BASEMO','V V R',NBDEF*NEQ,IDBASE)
      CALL COPMO2(BASMOD,NEQ,NUM,NBDEF,ZR(IDBASE))
C
C
C --- ALLOCATION VECTEUR DE TRAVAIL
C
      CALL WKVECT('&&'//PGC//'.VECT1','V V C',NEQ,LTVEC1)
      CALL WKVECT('&&'//PGC//'.VECT2','V V C',NEQ,LTVEC2)
C
C --- PROJECTION SUR DEFORMEES
C
      DO 10 I=1,NBDEF
C
C ----- CALCUL PRODUIT MATRICE DEFORMEE
C
        DO 20 J = 1 , NEQ
          ZC(LTVEC1+J-1)=DCMPLX(ZR(IDBASE+(I-1)*NEQ+J-1),0.D0)
 20     CONTINUE
        CALL MCMULT('ZERO',LMAT,ZC(LTVEC1),'C',ZC(LTVEC2),1)
        CALL ZECLAG(ZC(LTVEC2),NEQ,ZI(IDDEEQ))
        DO 21 J = 1 , NEQ
 21     CONTINUE
C
C ----- PRODUIT AVEC LA DEFORMEE COURANTE
C
        XPROD=DCMPLX(0.D0,0.D0)
        DO 30 J=1,NEQ
          XPROD=XPROD+
     &          ZC(LTVEC2-1+J)*DCMPLX(ZR(IDBASE+(I-1)*NEQ-1+J),0.D0)
30      CONTINUE

        IAD = I*(I+1)/2
        ZC(LDRES+IAD-1) = XPROD
C
C ----- PRODUIT AVEC DEFORMEES D'ORDRE SUPERIEURE
C
        IF (I.LT.NBDEF) THEN
          DO 40 J=I+1,NBDEF
            XPROD=DCMPLX(0.D0,0.D0)
            DO 50 K=1,NEQ
              XPROD=XPROD+
     &          ZC(LTVEC2-1+K)*DCMPLX(ZR(IDBASE+(J-1)*NEQ-1+K),0.D0)
50          CONTINUE
            IAD = I+(J-1)*J/2
            ZC(LDRES+IAD-1) = XPROD
40        CONTINUE
        ENDIF
C
10    CONTINUE
C
      CALL JEDETR('&&'//PGC//'.VECT1')
      CALL JEDETR('&&'//PGC//'.VECT2')
      CALL JEDETR('&&'//PGC//'.BASEMO')
C
C --- CREATION DU .DESC
C
      CALL WKVECT(NOMRES(1:18)//'_DESC','G V I',3,LDDES)
      ZI(LDDES) = 2
      ZI(LDDES+1) = NBDEF
      ZI(LDDES+2) = 2
C
      CALL JEDEMA()
      END
