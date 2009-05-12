      SUBROUTINE XMLIGR(NOMA,DEFICO,RESOCO)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 12/05/2009   AUTEUR MAZET S.MAZET 
C ======================================================================
C COPYRIGHT (C) 1991 - 2006  EDF R&D                  WWW.CODE-ASTER.ORG
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
      IMPLICIT     NONE
      CHARACTER*8  NOMA
      CHARACTER*24 DEFICO,RESOCO
C
C ----------------------------------------------------------------------
C ROUTINE APPELLEE PAR : XCONLI
C ----------------------------------------------------------------------
C ROUTINE SPECIFIQUE A L'APPROCHE <<GRANDS GLISSEMENTS AVEC XFEM>>,
C TRAVAIL EFFECTUE EN COLLABORATION AVEC I.F.P.
C ----------------------------------------------------------------------
C CREATION DU LIGREL POUR LES ELEMENTS X-FEM TARDIFS DE CONTACT
C
C 
C IN  NOMA   : NOM DU MAILLAGE
C IN  RESOCO : SD POUR LA RESOLUTION DE CONTACT
C IN  DEFICO : SD POUR LA DEFINITION DE CONTACT
C
C -------------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ----------------
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
      CHARACTER*32 JEXNOM,JEXNUM,JEXATR
C
C -------------- FIN  DECLARATIONS  NORMALISEES  JEVEUX ----------------
C
      INTEGER NBTYP
      PARAMETER (NBTYP=15)
      INTEGER ICO,JCO,NBGREL,IPC,NBPC,K,INO,NBNOM,NBNOE,IBID
      INTEGER JECPD
      INTEGER JNOMA,JTYMAI,JTYNMA,JTABF,IACNX1,ILCNX1,JCMCF
      INTEGER NUMAM,NUMAE,ITYMAM,ITYMAE
      INTEGER JNBNO,LONG,JAD,ITYTE,ITYMA
      INTEGER JDIM,NDIM,JJSUP
      INTEGER NNDEL,IORDR,NUMTYP
      INTEGER COMPT(NBTYP)
      INTEGER      CFMMVD,ZTABF
      CHARACTER*8  K8BID,NTYMAE,NTYMAM
      CHARACTER*16 NOMTE(NBTYP),NOMTM(NBTYP)
      CHARACTER*19 LIGRCF
      INTEGER      IFM,NIV
C
      DATA (NOMTE(K),K=1,NBTYP) /
     &      'MECPQ8Q4_XH','MECPT6T3_XH','MECPQ4Q4_XH','MECPT3T3_XH',
     &      'MECPQ4T3_XH','MECPT3Q4_XH',
     &      'MEDPQ8Q4_XH','MEDPT6T3_XH','MEDPQ4Q4_XH','MEDPT3T3_XH',
     &      'MEDPQ4T3_XH','MEDPT3Q4_XH',
     &      'MEH8H8_XH','MEP6P6_XH','MET4T4_XH'/
      DATA (NOMTM(K),K=1,NBTYP) /
     &      'QU8QU4','TR6TR3','QU4QU4','TR3TR3','QU4TR3','TR3QU4',
     &      'QU8QU4','TR6TR3','QU4QU4','TR3TR3','QU4TR3','TR3QU4',
     &      'HE8HE8','PE6PE6','TE4TE4'/
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
      CALL INFDBG('CONTACT',IFM,NIV)
C
C --- AFFICHAGE
C      
      IF (NIV.GE.2) THEN
        WRITE (IFM,*) '<CONTACT> CREATION DU LIGREL DES'//
     &        ' ELEMENTS DE CONTACT' 
      ENDIF 
C      
C --- LIGREL DES ELEMENTS TARDIFS DE CONTACT/FROTTEMENT    
C
      LIGRCF = RESOCO(1:14)//'.LIGR'   
C
C --- INITIALISATIONS
C
      DO 10,K = 1,NBTYP
        COMPT(K) = 0
   10 CONTINUE

      CALL JEVEUO(DEFICO(1:16)//'.NDIMCO','L',JDIM)
      CALL JEVEUO(DEFICO(1:16)//'.TABFIN','L',JTABF)
      CALL JEVEUO(NOMA//'.TYPMAIL','L',JTYMAI)
C
      ZTABF = CFMMVD('ZTABF')
      NBPC  = NINT(ZR(JTABF-1+1))   
C      NDIM  = ZI(JDIM)
C
C
C --- DESTRUCTION DU LIGREL S'IL EXISTE
C
      CALL DETRSD('LIGREL',LIGRCF)
C
C --- CREATION DE .NOMA
C      
      CALL WKVECT(LIGRCF//'.LGRF','V V K8',1,JNOMA)
      ZK8(JNOMA-1+1) = NOMA
      CALL JEVEUO(NOMA//'.CONNEX','L',IACNX1)
      CALL JEVEUO(JEXATR(NOMA//'.CONNEX','LONCUM'),'L',ILCNX1)
C
C --- VECTEUR DE TYPES DE MAILLE DU LIGREL
C --- DEUX ENTIERS PAR NOUVELLE MAILLE :
C       * NUMERO DU TYPE DE MAILLE
C       * NOMBRE DE NOEUDS DU TYPE DE MAILLE
C
      CALL WKVECT('&&XMLIGR.TYPNEMA','V V I',2*NBPC,JTYNMA)
C
      DO 20,IPC = 1,NBPC
C       -- TYPE MAILLES MAITRE/ESCLAVE
C
        NUMAE  = NINT(ZR(JTABF+ZTABF*(IPC-1)+1))
        NUMAM  = NINT(ZR(JTABF+ZTABF*(IPC-1)+2))
        ITYMAE = ZI(JTYMAI-1+NUMAE)
        ITYMAM = ZI(JTYMAI-1+NUMAM)
C
        CALL JENUNO(JEXNUM('&CATA.TM.NOMTM',ITYMAE),NTYMAE)
        CALL JENUNO(JEXNUM('&CATA.TM.NOMTM',ITYMAM),NTYMAM)
C
C       -- TYPE MAILLE DE CONTACT CREEE
        CALL XMELEL(0,NTYMAE,NTYMAM,IORDR,NNDEL)
        CALL JENONU(JEXNOM('&CATA.TM.NOMTM',NOMTM(IORDR)),NUMTYP)
        ZI(JTYNMA-1+2*(IPC-1)+1) = NUMTYP
        ZI(JTYNMA-1+2*(IPC-1)+2) = NNDEL
C
C
C       -- COMPTEUR DE CE TYPE D'ELEMENT DE CONTACT
        COMPT(IORDR) = COMPT(IORDR) + 1
C
   20 CONTINUE
C
C --- PAS DE NOEUDS TARDIFS
C
      CALL WKVECT(LIGRCF//'.NBNO','V V I',1,JNBNO)
      ZI(JNBNO-1+1) = 0
C
C --- ON COMPTE LE NOMBRE DE NOEUDS A STOCKER AU TOTAL
C
      LONG = 0
      DO 170 K = 1,NBTYP
        CALL XMELEL(K,K8BID,K8BID,IBID,NNDEL)
        LONG = LONG + COMPT(K)*(NNDEL+1)
  170 CONTINUE
C
C --- CREATION DE L'OBJET .NEMA
C
      CALL JECREC(LIGRCF//'.NEMA','V V I','NU','CONTIG','VARIABLE',NBPC)
      CALL JEECRA(LIGRCF//'.NEMA','LONT',LONG,K8BID)
      DO 50,IPC = 1,NBPC
C
C       -- NOMBRE DE NOEUDS SUR ELEMENT DE CONTACT
C
        NNDEL = ZI(JTYNMA-1+2*(IPC-1)+2)
        NUMAE = NINT(ZR(JTABF+ZTABF*(IPC-1)+1))
        NUMAM = NINT(ZR(JTABF+ZTABF*(IPC-1)+2))
        NBNOE = ZI(ILCNX1+NUMAE) - ZI(ILCNX1-1+NUMAE)
C
C-------LE NOMBRE DE NOEUDS POUR LA MAILLE MA�TRE EST REDUIT � MOITI�
C       SI QUADRATIQUE
        ITYMAM = ZI(JTYMAI-1+NUMAM)
        CALL JENUNO(JEXNUM('&CATA.TM.NOMTM',ITYMAM),NTYMAM)
        IF ((NTYMAM.EQ.'QUAD8').OR.(NTYMAM.EQ.'TRIA6')) THEN
C-------DANS LE CAS QUADRATIQUE 
          NBNOM = (ZI(ILCNX1+NUMAM) - ZI(ILCNX1-1+NUMAM))/2
        ELSE
C-------DANS LE CAS LINEAIRE
          NBNOM = ZI(ILCNX1+NUMAM) - ZI(ILCNX1-1+NUMAM) 
        ENDIF
        CALL ASSERT(NNDEL.EQ.(NBNOM+NBNOE))

C       -- CREATION DE L'ELEMENT DE CONTACT DANS LE LIGREL
        CALL JECROC(JEXNUM(LIGRCF//'.NEMA',IPC))
        CALL JEECRA(JEXNUM(LIGRCF//'.NEMA',IPC),'LONMAX',NNDEL+1,K8BID)
        CALL JEVEUO(JEXNUM(LIGRCF//'.NEMA',IPC),'E',JAD)
        ZI(JAD-1+NNDEL+1) = ZI(JTYNMA-1+2* (IPC-1)+1)

C       -- RECOPIE DES NUMEROS DE NOEUDS DE LA MAILLE ESCLAVE
        DO 30,INO = 1,NBNOE
          ZI(JAD-1+INO) = ZI(IACNX1+ZI(ILCNX1-1+NUMAE)-2+INO)
   30   CONTINUE

C       -- RECOPIE DES NUMEROS DE NOEUDS DE LA MAILLE MAITRE
        DO 40,INO = 1,NBNOM
          ZI(JAD-1+NBNOE+INO) = ZI(IACNX1+ZI(ILCNX1-1+NUMAM)-2+INO)
   40   CONTINUE
   50 CONTINUE
C
C --- CREATION DE L'OBJET .LIEL
C
      NBGREL = 0
      DO 60,K = 1,NBTYP
        IF (COMPT(K).GT.0) THEN
          NBGREL = NBGREL + 1
        ENDIF
   60 CONTINUE
      CALL ASSERT(NBGREL.NE.0)
      CALL JECREC(LIGRCF//'.LIEL','V V I','NU','CONTIG','VARIABLE',
     &            NBGREL)

      LONG = NBGREL
      DO 70,K = 1,NBTYP
        LONG = LONG + COMPT(K)
   70 CONTINUE

      CALL JEECRA(LIGRCF//'.LIEL','LONT',LONG,K8BID)
      ICO = 0
      DO 90,K = 1,NBTYP
        IF (COMPT(K).NE.0) THEN
          ICO = ICO + 1
          CALL JECROC(JEXNUM(LIGRCF//'.LIEL',ICO))
          CALL JEECRA(JEXNUM(LIGRCF//'.LIEL',ICO),'LONMAX',COMPT(K)+1,
     &                K8BID)
          CALL JEVEUO(JEXNUM(LIGRCF//'.LIEL',ICO),'E',JAD)

          CALL JENONU(JEXNOM('&CATA.TE.NOMTE',NOMTE(K)),ITYTE)
          CALL JENONU(JEXNOM('&CATA.TM.NOMTM',NOMTM(K)),ITYMA)
          ZI(JAD-1+COMPT(K)+1) = ITYTE

          JCO = 0
          DO 80,IPC = 1,NBPC
            IF (ZI(JTYNMA-1+2* (IPC-1)+1).EQ.ITYMA) THEN
              JCO = JCO + 1
              ZI(JAD-1+JCO) = -IPC
            ENDIF
   80     CONTINUE
        ENDIF
   90 CONTINUE
C
C --- IMPRESSIONS
C
      IF (NIV.GE.2) THEN
        CALL MMIMP2(IFM,NOMA,LIGRCF,JTABF)
      ENDIF
C
C --- INITIALISATION DU LIGREL
C      
      CALL JEECRA(LIGRCF//'.LGRF','DOCU',IBID,'MECA')
      CALL INITEL(LIGRCF)
C
C --- MENAGE
C
      CALL JEDETR('&&XMLIGR.TYPNEMA')
C
      CALL JEDEMA()
      END
