      SUBROUTINE GVER2D(NOMA,NOCC,OPTION,MOTFAZ,NOMNO,NOEUD,RINF,
     &                  RSUP,MODULE)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 22/01/2008   AUTEUR REZETTE C.REZETTE 
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
      IMPLICIT REAL*8 (A-H,O-Z)
C
C     ------------------------------------------------------------------
C
C FONCTION REALISEE:
C
C     MOT CLE FACTEUR THETA:
C
C     POUR LE NOEUD DU FOND DE FISSURE ON RECUPERE
C     LE TRIPLET ( MODULE(THETA), R_INF, R_SUP )
C
C     PUIS ON VERIFIE:
C                     QUE LE NOM DU GROUPE OU D'ELEMENTS (NOEUD)
C                     APPARTIENNENT BIEN AU MAILLAGE
C
C     ------------------------------------------------------------------
C ENTREE:
C
C     NOMA   : NOM DU MAILLAGE
C     NOCC   : NOMBRE D'OCCURENCES
C     NOMNO  : NOM DE L'OBJET CONTENANT LES NOMS DES NOEUDS
C
C SORTIE:
C
C     NOEUD      : NOEUD DU FOND DE FISSURE
C     R_INF       : RAYON INFERIEUR DE LA COURONNE
C     R_SUP       : RAYON SUPERIEUR DE LA COURONNE
C     MODULE     : MODULE THETA
C
C     ------------------------------------------------------------------
C
      CHARACTER*(*)     MOTFAZ
      CHARACTER*8       NOMA,NOEUD,MODELE,K8B,FOND,KFON
      CHARACTER*16      MOTFAC,NOMCMD,K16B
      CHARACTER*19      OPTION
      CHARACTER*24      OBJ1
      CHARACTER*24      TRAV
      CHARACTER*24      GRPNO,NOMNO,CHFOND
C
      INTEGER           JJJ,NGRO,NENT,NSOM,IOCC,NOCC,NDIM,IADR,I,L,N1
      INTEGER           IGR,NGR,INO,NNO,IRET,NBM,N2,LNOFF,NUMFON,IBID
C
      REAL*8            RINF,RSUP,MODULE
C
C---------------- COMMUNS NORMALISES  JEVEUX  --------------------------
      COMMON/IVARJE/ZI(1)
      COMMON/RVARJE/ZR(1)
      COMMON/CVARJE/ZC(1)
      COMMON/LVARJE/ZL(1)
      COMMON/KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
      INTEGER ZI
      REAL*8 ZR
      COMPLEX*16 ZC
      LOGICAL ZL
      CHARACTER*8  ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*24 VALK(2)
      CHARACTER*32 ZK32,JEXNOM,JEXNUM
      CHARACTER*80 ZK80
      CHARACTER*8  K8BID
      CHARACTER*1 K1BID
C---------------- FIN COMMUNS NORMALISES  JEVEUX  ----------------------
C
      CALL JEMARQ()

      CALL GETRES(K8B,K16B,NOMCMD)

      MOTFAC = MOTFAZ
      L      = LEN(MOTFAC)
C OBJET DEFINISSANT LES GROUP_NO DU MAILLAGE
C
      GRPNO = NOMA//'.GROUPENO'
C
      IF (OPTION.NE.'BANDE') THEN
       IF(NOMCMD.NE.'CALC_G')THEN
        DO 1 IOCC=1,NOCC
C
           CALL GETVEM(NOMA,'GROUP_NO',MOTFAC(1:L),'GROUP_NO',
     &                 IOCC,1,0,K8BID,NGRO)
           CALL GETVEM(NOMA,'NOEUD',MOTFAC(1:L),'NOEUD',
     &              IOCC,1,0,K8BID,NENT)
           NSOM = NGRO + NENT
           IF (NSOM.EQ.NGRO) THEN
              NGRO = -NGRO
           ELSE IF (NSOM.EQ.NENT) THEN
              NENT = -NENT
           ENDIF
C
1       CONTINUE
C
        NDIM = MAX(NGRO,NENT)
C
C ALLOCATION D'UN OBJET DE TRAVAIL
C
        TRAV = '&&GVER2D.'//MOTFAC(1:L)
        CALL WKVECT(TRAV,'V V K8',NDIM,JJJ)
C
       ENDIF
      ENDIF
      IF (OPTION.EQ.'BANDE'.OR.NOMCMD.EQ.'CALC_G') THEN
        NDIM = 1
      ENDIF
C
      DO 2 IOCC=1,NOCC
C
        CALL GETVR8(MOTFAC(1:L),'MODULE',IOCC,1,NDIM,MODULE,NBM)
        CALL GETVR8(MOTFAC(1:L),'R_INF',IOCC,1,NDIM,RINF,NBM)
        CALL GETVR8(MOTFAC(1:L),'R_SUP',IOCC,1,NDIM,RSUP,NBM)
        IF (RSUP .LE. RINF) THEN
           CALL U2MESS('F','RUPTURE1_6')
        ENDIF
C
       IF(NOMCMD.NE.'CALC_G')THEN
        IF (OPTION.NE.'BANDE') THEN
C
C MOT CLE GROUP_NO
C
C LE GROUP_NO DOIT APPARTENIR AU MAILLAGE
C
           CALL GETVEM(NOMA,'GROUP_NO',MOTFAC(1:L),'GROUP_NO',
     &                 IOCC,1,NDIM,ZK8(JJJ),NGR)
C
           DO 3 IGR=1,NGR
C
             CALL JEEXIN(JEXNOM(GRPNO,ZK8(JJJ+IGR-1)),IRET)
C
             IF(IRET.EQ.0) THEN
                VALK(1) = ZK8(JJJ+IGR-1)
                VALK(2) = NOMA
                CALL U2MESK('F','RUPTURE1_8', 2 ,VALK)
             ELSE
C
               CALL JELIRA (JEXNOM(GRPNO,ZK8(JJJ+IGR-1)),'LONMAX',
     &                      N1,K1BID)
               IF(N1.GT.1) THEN
                 CALL U2MESS('F','RUPTURE1_10')
              ELSE
                CALL JEVEUO (JEXNOM(GRPNO,ZK8(JJJ+IGR-1)),'L',IADR)
                CALL JENUNO(JEXNUM(NOMNO,ZI(IADR)),NOEUD)
              ENDIF
C
            ENDIF
3         CONTINUE
C
C MOT CLE NOEUD
C
        CALL GETVEM(NOMA,'NOEUD',MOTFAC(1:L),'NOEUD',
     &           IOCC,1,NDIM,ZK8(JJJ),NNO)
C
          DO 6 I=1,NNO
            IF(NNO.GT.1) THEN
              CALL U2MESS('F','RUPTURE1_10')
            ELSE
C
              CALL JENONU(JEXNOM(NOMNO,ZK8(JJJ+I-1)),IRET)
              IF(IRET.EQ.0) THEN
                  VALK(1) = ZK8(JJJ+I-1)
                  VALK(2) = NOMA
                  CALL U2MESK('F','RUPTURE0_14', 2 ,VALK)
              ELSE
                 CALL JENUNO(JEXNUM(NOMNO,IRET),NOEUD)
              ENDIF
C
            ENDIF
6         CONTINUE
        ENDIF
C
      ELSE
         CALL GETVID ( 'THETA','FOND_FISS',1,1,1,FOND,N1)
         IF (N1.NE.0) THEN
C          CAS CLASSIQUE         
           CHFOND = FOND//'.FOND      .NOEU'
           CALL JELIRA(CHFOND,'LONMAX',LNOFF,K8B)
           IF(LNOFF.NE.1)THEN
             CALL U2MESS('F','RUPTURE1_10')
           ELSE
             CALL JEVEUO(CHFOND,'L',N1)
             NOEUD=ZK8(N1)
           ENDIF
        ELSE
C         CAS X-FEM
          CALL GETVID ( 'THETA','FISSURE'  ,1,1,1,FOND,N2)
          IF (N2.EQ.0) CALL U2MESK('F','RUPTURE1_11',1,OPTION)
C         RECUPERATION DU NUMERO DU FOND DE FISSURE DEMANDE
          CALL GETVIS('THETA','NUME_FOND',1,1,1,NUMFON,IBID)
C         ON ECRIT 'NUM'+_i OU i=NUMFON 
C         A LA PLACE DU NOM DU NOEUD EN FOND DE FISSURE
          CALL CODENT(NUMFON,'G',KFON)
          NOEUD(1:8)='NUM_'//KFON
        ENDIF 

      ENDIF
2     CONTINUE
C
C DESTRUCTION DE L'OBJET DE TRAVAIL
C
      IF(NOMCMD.NE.'CALC_G' .AND. OPTION.NE.'BANDE') CALL JEDETR(TRAV)
C
      CALL JEDEMA()
      END
