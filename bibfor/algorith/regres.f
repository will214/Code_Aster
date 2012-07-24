      SUBROUTINE REGRES(NOMRES,MAILSK,RESULT,PFCHN2)
      IMPLICIT NONE
      INCLUDE 'jeveux.h'
      CHARACTER*8         NOMRES, MAILSK,         RESULT
C***********************************************************************
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 24/07/2012   AUTEUR PELLET J.PELLET 
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
C-----------------------------------------------------------------------
C  BUT : < PROJECTION D'UNE RESTITUTION SUR UN SQUELETTE ENRICHI >
C
C SUITE A UNE RESTITUTION GLOBALE GENERALISEE ON PROJETE LES CHAMPS SUR
C UN SQUELETTE DONT ON A FUSIONNE LES NOEUDS D'INTERFACE DYNAMIQUE
C
C NOMRES  /I/ : NOM K8 DU CONCEPT MODE_MECA RESULTAT
C MAILSK  /I/ : NOM K8 DU MAILLAGE SQUELETTE SUPPORT
C RESULT  /O/ : NOM K8 DU MODE_MECA QUE L'ON VEUT PROJETER
C
C-----------------------------------------------------------------------
C
      INTEGER VALI
C
C
      CHARACTER*8  K8BID
      CHARACTER*24 VALK(2)
      CHARACTER*19 PFCHN1, PFCHN2
      CHARACTER*24 OBJET
      CHARACTER*19 CHEXIN, CHEXOU, CHAMNO
C-----------------------------------------------------------------------
C
C-----------------------------------------------------------------------
      INTEGER I ,IADNEW ,IADOLD ,IBID ,IEQ ,IERD ,IGD
      INTEGER IOLD ,IORD ,IRET ,J ,K ,LCORR ,LDEEQ
      INTEGER LNEQU ,LNUNEW ,LNUOLD ,LORD ,LPRNEW ,LPROLD ,LREFE
      INTEGER LVNEW ,LVOLD ,NBORD ,NBVAL ,NCMP ,NDDL ,NDEEQ
      INTEGER NDI ,NEC ,NNODES,NBEC
C-----------------------------------------------------------------------
      CALL JEMARQ()

      CALL RSEXCH('F',RESULT,'DEPL',1,CHAMNO,IRET)
      CALL DISMOI('F','PROF_CHNO',CHAMNO,'CHAM_NO',IBID,PFCHN1,IERD)


      CALL COPISD('PROF_CHNO','G',PFCHN1,PFCHN2)
      CALL COPISD('RESULTAT','G',RESULT,NOMRES)


      CALL JEVEUO(MAILSK//'.CORRES','L',LCORR)
      CALL JELIRA(MAILSK//'.CORRES','LONUTI',NNODES,K8BID)
      CALL JEVEUO(JEXNUM(PFCHN1//'.PRNO',1),'L',LPROLD)
      CALL JEVEUO(PFCHN1//'.NUEQ','L',LNUOLD)
      CALL JELIRA(NOMRES//'           .ORDR','LONUTI',NBORD,K8BID)
      CALL JEVEUO(NOMRES//'           .ORDR','L',LORD)

      CALL DISMOI('F','NUM_GD',CHAMNO,'CHAM_NO',IGD,
     &            K8BID,IERD)

      NEC = NBEC(IGD)
      NDI = NEC + 2
C
C --- CALCUL DU NOMBRE DE DDL ---
      NDDL = 0
      DO 10 I=1,NNODES
         IOLD = ZI(LCORR-1+I)
         NDDL = NDDL + ZI(LPROLD+(IOLD-1)*NDI+1)
 10   CONTINUE



C --- MISE A JOUR DES OBJETS .NUEQ ET .PRNO
      OBJET = PFCHN2//'.NUEQ'
      CALL JEEXIN(OBJET,IRET)
      IF (IRET.NE.0) THEN
         CALL JEDETR(OBJET)
         CALL WKVECT(OBJET,'G V I',NDDL,LNUNEW)
      ELSE
         VALK(1) = OBJET
         CALL U2MESG('F', 'ALGORITH14_30',1,VALK,0,0,0,0.D0)
      ENDIF

      OBJET = PFCHN2//'.NEQU'
      CALL WKVECT(OBJET,'V V I',2,LNEQU)
      ZI(LNEQU) = NDDL

      OBJET = PFCHN2//'.PRNO'
      CALL JEEXIN(JEXNUM(OBJET,1),IRET)
      IF (IRET.NE.0) THEN
          CALL JEVEUO(JEXNUM(OBJET,1),'E',LPRNEW)
          CALL JELIRA(JEXNUM(OBJET,1),'LONMAX',NBVAL,K8BID)
          DO 15 I=1,NBVAL
             ZI(LPRNEW-1+I) = 0
 15       CONTINUE
          CALL JEECRA(JEXNUM(OBJET,1),'LONUTI',NNODES*NDI,' ')
      ELSE
         VALK(1) = OBJET
         CALL U2MESG('F', 'ALGORITH14_30',1,VALK,0,0,0,0.D0)
      ENDIF



      DO 60 IORD=1,NBORD
         CALL RSEXCH('F',RESULT, 'DEPL', ZI(LORD-1+IORD), CHEXIN, IRET)
         CALL RSEXCH('F',NOMRES, 'DEPL', ZI(LORD-1+IORD), CHEXOU, IRET)
C
C     --- MISE A JOUR DU .REFE
         CALL JEVEUO ( CHEXOU//'.REFE', 'E', LREFE )
         ZK24(LREFE)   = MAILSK
         CALL DETRSD('PROF_CHNO',ZK24(LREFE+1))
         ZK24(LREFE+1) = NOMRES//'.PROFC.NUME'
C
         IEQ = 1
         DO 30 I=1,NNODES
            IOLD = ZI(LCORR-1+I)
            NCMP = ZI(LPROLD+(IOLD-1)*NDI+1)
            ZI(LPRNEW+(I-1)*NDI) = IEQ
            ZI(LPRNEW+(I-1)*NDI+1) = NCMP
            ZI(LPRNEW+(I-1)*NDI+2) = ZI(LPROLD+(IOLD-1)*NDI+2)
            DO 20 K=1,NCMP
               ZI(LNUNEW-1+IEQ) = IEQ
               IEQ = IEQ + 1
 20         CONTINUE
 30      CONTINUE
C
C     --- MISE A JOUR DU .VALE (DEPL_R) ---
         CALL JEEXIN(CHEXOU//'.VALE',IRET)
         IF (IRET .NE. 0 ) THEN
            CALL JEDETR ( CHEXOU//'.VALE' )
            CALL WKVECT ( CHEXOU//'.VALE', 'G V R', NDDL, LVNEW )
            CALL JEVEUO ( CHEXIN//'.VALE', 'L', LVOLD )
            DO 50 I=1,NNODES
               IOLD = ZI(LCORR-1+I)
               NCMP = ZI(LPROLD+(IOLD-1)*NDI+1)
               IADOLD = ZI(LNUOLD-1+ZI(LPROLD+(IOLD-1)*NDI))
               IADNEW = ZI(LNUNEW-1+ZI(LPRNEW+(I-1)*NDI))
               DO 40 J=1,NCMP
                  ZR(LVNEW-1+IADNEW+J-1)=ZR(LVOLD-1+IADOLD+J-1)
 40            CONTINUE
 50         CONTINUE
         ENDIF
 60   CONTINUE
C
C  --- MISE A JOUR DU .PROFC.NUME.DEEQ ---
      OBJET = PFCHN2//'.DEEQ'
      CALL JEEXIN(OBJET,IRET)
      IF (IRET.NE.0) THEN
         CALL JEDETR(OBJET)
         CALL WKVECT(OBJET,'G V I',NDDL*2,LDEEQ)
      ELSE
         VALK(1) = OBJET
         CALL U2MESG('F', 'ALGORITH14_30',1,VALK,0,0,0,0.D0)
      ENDIF
      NDEEQ = 0
      DO 70 I=1,NNODES
         NCMP = ZI(LPRNEW-1+(I-1)*NDI+2)
         DO 70 J =1,NCMP
            NDEEQ = NDEEQ + 1
            ZI(LDEEQ-1+NDEEQ) = I
            NDEEQ = NDEEQ + 1
            ZI(LDEEQ-1+NDEEQ) = J
 70      CONTINUE
C
      CALL JEDEMA()
      END
