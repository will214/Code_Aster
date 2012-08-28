      SUBROUTINE RETREC(NOMRES,RESGEN,NOMSST)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 27/08/2012   AUTEUR ALARCON A.ALARCON 
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
C***********************************************************************
      IMPLICIT NONE
C  C. VARE     DATE 16/11/94
C-----------------------------------------------------------------------
C
C  BUT : < RESTITUTION TRANSITOIRE ECLATEE >
C
C        RESTITUER EN BASE PHYSIQUE SUR UNE SOUS-STRUCTURE LES RESULTATS
C        ISSUS D'UN CALCUL TRANSITOIRE PAR SOUS-STRUCTURATION CLASSIQUE
C
C        LE CONCEPT RESULTAT EST UN RESULTAT COMPOSE "DYNA_TRANS"
C
C-----------------------------------------------------------------------
C
C NOMRES /I/ : NOM K8 DU CONCEPT DYNA_TRANS RESULTAT
C RESGEN /I/ : NOM K8 DU TRAN_GENE AMONT
C NOMSST /I/ : NOM K8 DE LA SOUS-STRUCTURE SUR LAQUELLE ON RESTITUE
C
C
C
      INCLUDE 'jeveux.h'
C
C
      REAL*8       EPSI
      CHARACTER*8  CHMP(3),K8REP,CRIT,INTERP,K8B,NOMRES,BASMOD,MAILLA
      CHARACTER*8  LINT,NOMSST,MODGEN,RESGEN,SOUTR
      CHARACTER*19 NUMDDL,NUMGEN,KNUME,KINST,TRANGE
      CHARACTER*24 CREFE(2),CHAMBA,CHAMNO,SELIAI,SIZLIA,SST
      CHARACTER*24 VALK(2)
      INTEGER      ITRESU(3),ELIM,IRET
      CHARACTER*8  K8BID,KBID
      INTEGER      IARG
C
C-----------------------------------------------------------------------
C-----------------------------------------------------------------------
      INTEGER I ,I1 ,IAD ,IARCHI ,IBID ,ICH ,IDINSG 
      INTEGER IDRESU ,IDVECG ,IEQ ,IER ,IRE1 ,IRE2 ,IRE3 
      INTEGER IRETOU ,J ,JINST ,JNUME ,K ,K1 ,LDNEW 
      INTEGER LINST ,LLCHAB ,LLNEQU ,LLNUEQ ,LLORS ,LLPRS ,LLREF1 
      INTEGER LLREF2 ,LLREFE ,LMAPRO ,LMOET ,LREFE ,LSILIA ,LSST 
      INTEGER N1 ,NBCHAM ,NBDDG ,NBINSG ,NBINST ,NBSST ,NEQ 
      INTEGER NEQET ,NEQGEN ,NEQRED ,NUSST ,NUTARS 
C-----------------------------------------------------------------------
      DATA SOUTR  /'&SOUSSTR'/
C-----------------------------------------------------------------------
C
C --- ECRITURE DU TITRE
C
      CALL JEMARQ()
      CALL TITRE
C
C --- DETERMINATION DES CHAMPS A RESTITUER, PARMI DEPL, VITE ET ACCE
C
      TRANGE = RESGEN
      CALL JEEXIN(RESGEN//'           .DEPL',IRE1)
      CALL JEEXIN(RESGEN//'           .VITE',IRE2)
      CALL JEEXIN(RESGEN//'           .ACCE',IRE3)
C
      IF (IRE1.EQ.0.AND.IRE2.EQ.0.AND.IRE3.EQ.0) THEN
        VALK (1) = RESGEN
        CALL U2MESG('F', 'ALGORITH14_35',1,VALK,0,0,0,0.D0)
      ENDIF
C
      CALL GETVTX(' ','TOUT_CHAM',0,IARG,1,K8REP,N1)
      IF (K8REP(1:3).EQ.'OUI') THEN
        IF (IRE1.EQ.0) THEN
          CALL U2MESS('F','ALGORITH10_44')
        ENDIF
        IF (IRE2.EQ.0) THEN
          CALL U2MESS('F','ALGORITH10_45')
        ENDIF
        IF (IRE3.EQ.0) THEN
          CALL U2MESS('F','ALGORITH10_46')
        ENDIF
        NBCHAM = 3
        CHMP(1) = 'DEPL'
        CHMP(2) = 'VITE'
        CHMP(3) = 'ACCE'
        CALL JEVEUO(TRANGE//'.DEPL','L',ITRESU(1))
        CALL JEVEUO(TRANGE//'.VITE','L',ITRESU(2))
        CALL JEVEUO(TRANGE//'.ACCE','L',ITRESU(3))
      ELSE
        CALL GETVTX(' ','NOM_CHAM',0,IARG,1,K8REP,N1)
        IF (K8REP(1:4).EQ.'DEPL'.AND.IRE1.EQ.0) THEN
          CALL U2MESS('F','ALGORITH10_44')
        ELSEIF (K8REP(1:4).EQ.'DEPL'.AND.IRE1.NE.0) THEN
          NBCHAM = 1
          CHMP(1) = 'DEPL'
          CALL JEVEUO(TRANGE//'.DEPL','L',ITRESU(1))
        ELSEIF (K8REP(1:4).EQ.'VITE'.AND.IRE2.EQ.0) THEN
          CALL U2MESS('F','ALGORITH10_45')
        ELSEIF (K8REP(1:4).EQ.'VITE'.AND.IRE2.NE.0) THEN
          NBCHAM = 1
          CHMP(1) = 'VITE'
          CALL JEVEUO(TRANGE//'.VITE','L',ITRESU(1))
        ELSEIF (K8REP(1:4).EQ.'ACCE'.AND.IRE3.EQ.0) THEN
          CALL U2MESS('F','ALGORITH10_46')
        ELSEIF (K8REP(1:4).EQ.'ACCE'.AND.IRE3.NE.0) THEN
          NBCHAM = 1
          CHMP(1) = 'ACCE'
          CALL JEVEUO(TRANGE//'.ACCE','L',ITRESU(1))
        ENDIF
      ENDIF
C
C --- RECUPERATION DE LA NUMEROTATION ET DU MODELE GENERALISE
C
      CALL JEVEUO(TRANGE//'.REFD','L',LLREF1)
      NUMGEN(1:14) = ZK24(LLREF1+4)(1:14)
      CALL JELIBE(TRANGE//'.REFD')
      NUMGEN(15:19) = '.NUME'
      CALL JEVEUO(NUMGEN//'.REFN','L',LLREF2)
      MODGEN = ZK24(LLREF2)(1:8)
      CALL JELIBE(NUMGEN//'.REFN')
      CALL JEVEUO(NUMGEN//'.NEQU','L',LLNEQU)
      NEQGEN = ZI(LLNEQU)
      CALL JELIBE(NUMGEN//'.NEQU')
      
C
C --- RECUPERATION NUMERO DE LA SOUS-STRUCTURE
C
      CALL JENONU(JEXNOM(MODGEN//'      .MODG.SSNO',NOMSST),NUSST)
      IF (NUSST.EQ.0) THEN
        VALK (1) = MODGEN
        VALK (2) = NOMSST
        CALL U2MESG('F', 'ALGORITH14_25',2,VALK,0,0,0,0.D0)
      ENDIF

C
C-- ON TESTE SI ON A EU RECOURS A L'ELIMINATION
C
      SELIAI=NUMGEN(1:14)//'.ELIM.BASE'
      SIZLIA=NUMGEN(1:14)//'.ELIM.TAIL'
      SST=   NUMGEN(1:14)//'.ELIM.NOMS'

      CALL JEEXIN(SELIAI,ELIM)
      
      IF (ELIM .EQ. 0) THEN
            
        CALL JENONU(JEXNOM(NUMGEN//'.LILI',SOUTR),IBID)
        CALL JEVEUO(JEXNUM(NUMGEN//'.ORIG',IBID),'L',LLORS)
        CALL JENONU(JEXNOM(NUMGEN//'.LILI',SOUTR),IBID)
        CALL JELIRA(JEXNUM(NUMGEN//'.ORIG',IBID),'LONMAX',NBSST,KBID)
C
        NUTARS=0
        DO 20 I=1,NBSST
          IF(ZI(LLORS+I-1).EQ.NUSST) NUTARS=I
  20    CONTINUE
C
C
C --- NOMBRE DE MODES ET NUMERO DU PREMIER DDL DE LA SOUS-STRUCTURE
        CALL JENONU(JEXNOM(NUMGEN//'.LILI',SOUTR),IBID)
        CALL JEVEUO(JEXNUM(NUMGEN//'.PRNO',IBID),'L',LLPRS)
        NBDDG=ZI(LLPRS+(NUTARS-1)*2+1)
        IEQ=ZI(LLPRS+(NUTARS-1)*2)

      ELSE
      
        NEQET=0
        IEQ=0
        CALL JELIRA(MODGEN//'      .MODG.SSNO','NOMMAX',NBSST,KBID)
        CALL JEVEUO(NUMGEN//'.NEQU','L',IBID)
        NEQRED=ZI(IBID)
        CALL JEVEUO(SELIAI,'L',LMAPRO)
        CALL JEVEUO(SIZLIA,'L',LSILIA)
        CALL JEVEUO(SST,'L',LSST)
        IBID=1
        DO 11 I=1,NBSST
          NEQET=NEQET+ZI(LSILIA+I-1)
  11    CONTINUE

        IEQ=0
        DO 41 I1=1,NUSST-1
            IEQ=IEQ+ZI(LSILIA+I1-1)
  41    CONTINUE
        
        CALL WKVECT('&&MODE_ETENDU_REST_ELIM','V V R',NEQET,LMOET)    
      ENDIF
C
C --- RECUPERATION D'INFORMATIONS SUR LA SOUS-STRUCTURE
C
      CALL MGUTDM(MODGEN,NOMSST,IBID,'NOM_BASE_MODALE',IBID,BASMOD)
      IF (ELIM .NE. 0) THEN
        CALL DISMOI('F','NB_MODES_TOT',BASMOD,'RESULTAT',NBDDG,KBID,
     &              IER)
      ENDIF
      
      CALL JEVEUO(BASMOD//'           .REFD','L',LLREFE)
C -->AAC-->NORMALEMENT CE .REFD EST INCOHERENT AVEC CELUI DE DYNA_GENE
      LINT = ZK24(LLREFE+4)(1:8)
      CALL DISMOI('F','NOM_MAILLA',LINT,'INTERF_DYNA',IBID,
     &            MAILLA,IRET)
      CALL DISMOI('F','NOM_NUME_DDL',LINT,'INTERF_DYNA',IBID,
     &            NUMDDL,IRET)
      CALL DISMOI('F','NB_EQUA',NUMDDL,'NUME_DDL',NEQ,K8BID,IRET)
C
      CREFE(1) = MAILLA
      CREFE(2) = NUMDDL
C
C --- RECUPERATION DES INSTANTS
C
      CALL GETVTX(' ','CRITERE'  ,0,IARG,1,CRIT,N1)
      CALL GETVR8(' ','PRECISION',0,IARG,1,EPSI,N1)
      CALL GETVTX(' ','INTERPOL' ,0,IARG,1,INTERP,N1)
C
      KNUME = '&&RETREC.NUM_RANG'
      KINST = '&&RETREC.INSTANT'
      CALL RSTRAN(INTERP,TRANGE,' ',1,KINST,KNUME,NBINST,IRETOU)
      IF (IRETOU.NE.0) THEN
        CALL U2MESS('F','ALGORITH10_47')
      ENDIF
      CALL JEEXIN(KINST,IRET)
      IF (IRET.GT.0) THEN
        CALL JEVEUO(KINST,'E',JINST)
        CALL JEVEUO(KNUME,'E',JNUME)
      END IF
C
C --- ALLOCATION DE LA STRUCTURE DE DONNEES RESULTAT-COMPOSE
C
      CALL RSCRSD('G',NOMRES,'DYNA_TRANS',NBINST)
C
C -------------------------------------
C --- RESTITUTION SUR BASE PHYSIQUE ---
C -------------------------------------
C
      CALL JEVEUO(NUMGEN//'.NUEQ','L',LLNUEQ)
C
      IARCHI = 0
      IF (INTERP(1:3).NE.'NON') THEN
        CALL JEVEUO(TRANGE//'.DISC','L',IDINSG)
        CALL JELIRA(TRANGE//'.DISC','LONMAX',NBINSG,K8B)
        
        IF (ELIM .EQ. 0) THEN 
          CALL WKVECT('&&RETREC.VECTGENE','V V R',NEQGEN,IDVECG)
        ELSE
          CALL WKVECT('&&RETREC.VECTGENE','V V R',NEQGEN,IDVECG)
        ENDIF
C
        DO 30 I=0,NBINST-1
          IARCHI = IARCHI + 1
C
          DO 32 ICH=1,NBCHAM
            IDRESU = ITRESU(ICH)
            CALL RSEXCH(' ',NOMRES,CHMP(ICH),IARCHI,CHAMNO,IRET)
            IF (IRET.EQ.0) THEN
              CALL U2MESK('A','ALGORITH2_64',1,CHAMNO)
            ELSEIF (IRET.EQ.100) THEN
              CALL VTCREA(CHAMNO,CREFE,'G','R',NEQ)
            ELSE
              CALL ASSERT(.FALSE.)
            ENDIF
            CHAMNO(20:24) = '.VALE'
            CALL JEVEUO(CHAMNO,'E',LDNEW)
            CALL EXTRAC(INTERP,EPSI,CRIT,NBINSG,ZR(IDINSG),
     &                  ZR(JINST+I),ZR(IDRESU),NEQGEN,ZR(IDVECG),IER)
     
            IF (ELIM .NE. 0) THEN
              DO 21 I1=1,NEQET
                ZR(LMOET+I1-1)=0.D0
                DO 31 K1=1,NEQRED
                  ZR(LMOET+I1-1)=ZR(LMOET+I1-1)+
     &              ZR(LMAPRO+(K1-1)*NEQET+I1-1)*
     &              ZR(IDVECG+K1-1)
  31            CONTINUE
  21          CONTINUE                
            ENDIF          
C
C --- BOUCLE SUR LES MODES PROPRES DE LA BASE
C
            DO 50 J=1,NBDDG
              CALL DCAPNO(BASMOD,'DEPL',J,CHAMBA)
              CALL JEVEUO(CHAMBA,'L',LLCHAB)
              
              IF (ELIM .NE. 0) THEN
                IAD=LMOET+IEQ+J-1
              ELSE
                IAD=IDVECG+ZI(LLNUEQ+IEQ+J-2)-1
              ENDIF                                    
C
C --- BOUCLE SUR LES EQUATIONS PHYSIQUES
C
              DO 60 K = 1,NEQ
                ZR(LDNEW+K-1)=ZR(LDNEW+K-1)+ZR(LLCHAB+K-1)*ZR(IAD)
60            CONTINUE
              CALL JELIBE(CHAMBA)
50          CONTINUE
            CALL JELIBE(CHAMNO)
            CALL RSNOCH(NOMRES,CHMP(ICH),IARCHI)
32        CONTINUE
          CALL RSADPA(NOMRES,'E',1,'INST',IARCHI,0,LINST,K8B)
          ZR(LINST) = ZR(JINST+I)
30      CONTINUE
C
      ELSE
        CALL JEEXIN(TRANGE//'.ORDR',IRET)
        IF (IRET.NE.0.AND.ZI(JNUME).EQ.1) IARCHI=-1
C
        DO 40 I=0,NBINST-1
          IARCHI = IARCHI + 1

          DO 42 ICH=1,NBCHAM
            IDRESU = ITRESU(ICH)
                        
C-- SI ELIMINATION, ON RESTITUE D'ABORD LES MODES GENERALISES       
            IF (ELIM .NE. 0) THEN      
              DO 22 I1=1,NEQET
                ZR(LMOET+I1-1)=0.D0
                DO 33 K1=1,NEQRED
                  ZR(LMOET+I1-1)=ZR(LMOET+I1-1)+
     &              ZR(LMAPRO+(K1-1)*NEQET+I1-1)*
     &              ZR(IDRESU+K1-1+(ZI(JNUME+I)-1)*NEQRED)
  33            CONTINUE
  22          CONTINUE             
            ENDIF
            
            CALL RSEXCH(' ',NOMRES,CHMP(ICH),IARCHI,CHAMNO,IRET)
            IF (IRET.EQ.0) THEN
              CALL U2MESK('A','ALGORITH2_64',1,CHAMNO)
            ELSEIF (IRET.EQ.100) THEN
              CALL VTCREA(CHAMNO,CREFE,'G','R',NEQ)
            ELSE
              CALL ASSERT(.FALSE.)
            ENDIF
            CHAMNO(20:24) = '.VALE'
            CALL JEVEUO(CHAMNO,'E',LDNEW)
C
C --- BOUCLE SUR LES MODES PROPRES DE LA BASE
C
            DO 70 J=1,NBDDG
              CALL DCAPNO(BASMOD,'DEPL',J,CHAMBA)
              CALL JEVEUO(CHAMBA,'L',LLCHAB)
              
              IF (ELIM .NE. 0) THEN
                IAD=LMOET+IEQ+J-1
              ELSE
                IAD=IDRESU+(ZI(JNUME+I)-1)*NEQGEN+
     &              ZI(LLNUEQ+IEQ+J-2)-1
              ENDIF
C
C --- BOUCLE SUR LES EQUATIONS PHYSIQUES
C
              DO 80 K = 1,NEQ
                ZR(LDNEW+K-1)=ZR(LDNEW+K-1)+ZR(LLCHAB+K-1)*ZR(IAD)
80            CONTINUE
              CALL JELIBE(CHAMBA)
70          CONTINUE
            CALL JELIBE(CHAMNO)
            CALL RSNOCH(NOMRES,CHMP(ICH),IARCHI)
42        CONTINUE
          CALL RSADPA(NOMRES,'E',1,'INST',IARCHI,0,LINST,K8B)
          ZR(LINST) = ZR(JINST+I)
40      CONTINUE
C
      ENDIF
C
      CALL WKVECT(NOMRES//'           .REFD','G V K24',7,LREFE)
C -->AAC-->NORMALEMENT CE .REFD EST INCOHERENT AVEC CELUI DE DYNA_GENE
      ZK24(LREFE  ) = ZK24(LLREFE)
      ZK24(LREFE+1) = ZK24(LLREFE+1)
      ZK24(LREFE+2) = ZK24(LLREFE+2)
      ZK24(LREFE+3) = ZK24(LLREFE+3)
      ZK24(LREFE+4) = ZK24(LLREFE+4)
      ZK24(LREFE+5) = ZK24(LLREFE+5)
      ZK24(LREFE+6) = ZK24(LLREFE+6)
      CALL JELIBE(NOMRES//'           .REFD')
      CALL JELIBE(BASMOD//'           .REFD')
C
      CALL JELIBE(NUMGEN//'.NUEQ')
      CALL JEDETC(' ','&&RETREC',1)
C
      GOTO 9999
C
 9999 CONTINUE
      CALL JEDEMA()
      END
