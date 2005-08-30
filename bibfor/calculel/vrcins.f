      SUBROUTINE VRCINS(MODELE,CHMAT,CARELE,INST,CHVARC)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF CALCULEL  DATE 30/08/2005   AUTEUR VABHHTS J.PELLET 
C ======================================================================
C COPYRIGHT (C) 1991 - 2005  EDF R&D                  WWW.CODE-ASTER.ORG
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
      IMPLICIT   NONE
      CHARACTER*8 MODELE,CHMAT,CARELE,VARC1,VARC2,NOCMP1,NOCMP2
      CHARACTER*19 CHVARC
      REAL*8 INST
C ======================================================================
C   BUT : FABRIQUER LE CHAMP DE VARIABLES DE COMMANDE CORRESPONDANT A
C         UN INSTANT DONNE.
C   ARGUMENTS :
C   MODELE (K8)  IN/JXIN : SD MODELE
C   CHMAT  (K8)  IN/JXIN : SD CHAM_MATER
C   CARELE  (K8)  IN/JXIN : SD CARA_ELEM (SOUS-POINTS)
C   INST   (R)   IN      : VALEUR DE L'INSTANT
C   CHVARC (K19) IN/JXOUT: SD CHAM_ELEM/ELGA CONTENANT LES VARC
C ----------------------------------------------------------------------
C --- DEBUT DECLARATIONS NORMALISEES JEVEUX ----------------------------

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
C --- FIN DECLARATIONS NORMALISEES JEVEUX ------------------------------

      INTEGER IRET,ICHS,NBCHS,JLISSD,JLISCH ,JCESD,JCESV,JCESL
      INTEGER JCVCMP,JCVNOM,NBCVRC,JCESC,NBCMP,KCMP,KCVRC
      INTEGER NBMA,IMA,NBPT,NBSP,IPT,ISP,IAD,IAD1
      INTEGER JCVVAR,JCE1D,JCE1L,JCE1V,JCESVI,NNCP
      REAL*8 VALEUR
      CHARACTER*19 CHVARS ,LIGRMO,CHS
      CHARACTER*8 KBID
C ----------------------------------------------------------------------

      CALL JEMARQ()
      CHVARS=CHMAT//'.CHVARS'
      LIGRMO=MODELE//'.MODELE'
      CALL JEEXIN(CHMAT//'.CVRCVARC',IRET)
      IF (IRET.EQ.0) GO TO 9999


C     1. CALCUL DE  CHMAT.LISTE_CH(:) ET CHMAT.LISTE_SD(:)
C     -----------------------------------------------------
      CALL VRCIN1(MODELE,CHMAT,CARELE,INST)


C     2. ALLOCATION DU CHAMP_ELEM_S RESULTAT (CHVARS)
C        CALCUL DE CHMAT.CESVI
C        (CETTE ETAPE EST ECONOMISEE D'UN INSTANT A L'AUTRE)
C     -------------------------------------------------------------
      CALL JEEXIN(CHMAT//'.CESVI',IRET)
      IF (IRET.EQ.0) CALL VRCIN2(MODELE,CHMAT,CARELE,CHVARS)


C     3. RECOPIE DES VALEURS DANS CHVARS :
C     -----------------------------------------------------
      CALL JEVEUO(CHMAT//'.LISTE_CH','L',JLISCH)
      CALL JELIRA(CHMAT//'.LISTE_CH','LONMAX',NBCHS,KBID)
      CALL JEVEUO(CHMAT//'.LISTE_SD','L',JLISSD)
      CALL JEVEUO(CHMAT//'.CVRCVARC','L',JCVVAR)
      CALL JEVEUO(CHMAT//'.CVRCCMP','L',JCVCMP)
      CALL JEVEUO(CHMAT//'.CVRCNOM','L',JCVNOM)
      CALL JELIRA(CHMAT//'.CVRCCMP','LONMAX',NBCVRC,KBID)

      CALL JEVEUO(CHVARS//'.CESD','L',JCE1D)
      CALL JEVEUO(CHVARS//'.CESL','E',JCE1L)
      CALL JEVEUO(CHVARS//'.CESV','E',JCE1V)
      CALL JEVEUO(CHMAT//'.CESVI','L',JCESVI)

      DO 1, ICHS=1,NBCHS
        CHS=ZK24(JLISCH-1+ICHS)
        VARC1=ZK16(JLISSD-1+6*(ICHS-1)+4)(1:8)
        CALL JEVEUO(CHS//'.CESD','L',JCESD)
        CALL JEVEUO(CHS//'.CESL','L',JCESL)
        CALL JEVEUO(CHS//'.CESV','L',JCESV)
        CALL JEVEUO(CHS//'.CESC','L',JCESC)
        CALL JELIRA(CHS//'.CESC','LONMAX',NBCMP,KBID)

        DO 2,KCMP=1,NBCMP
          NOCMP1=ZK8(JCESC-1+KCMP)

C         -- CALCUL DE KCVRC :
          DO 3,KCVRC=1,NBCVRC
            VARC2=ZK8(JCVVAR-1+KCVRC)
            NOCMP2=ZK8(JCVCMP-1+KCVRC)
            IF ((VARC1.EQ.VARC2).AND.(NOCMP1.EQ.NOCMP2)) GO TO 4
3         CONTINUE
          CALL ASSERT(.FALSE.)

4         CONTINUE

          NBMA = ZI(JCESD-1+1)
          CALL ASSERT(NBMA.EQ.ZI(JCE1D-1+1))

          DO 70,IMA = 1,NBMA
            NBPT = ZI(JCESD-1+5+4* (IMA-1)+1)
            CALL ASSERT(NBPT.EQ.ZI(JCE1D-1+5+4* (IMA-1)+1))
            NBSP = MAX(1,ZI(JCESD-1+5+4* (IMA-1)+2))
            CALL ASSERT(NBSP.EQ.ZI(JCE1D-1+5+4* (IMA-1)+2))

            DO 60,IPT = 1,NBPT
              DO 50,ISP = 1,NBSP
                  CALL CESEXI('S',JCESD,JCESL,IMA,IPT,ISP,KCMP,IAD)
                  IF (IAD.GT.0) THEN
                    CALL CESEXI('S',JCE1D,JCE1L,IMA,IPT,ISP,
     &                            KCVRC,IAD1)
                    CALL ASSERT(IAD1.GT.0)
                    IF (ZI(JCESVI-1+IAD1).EQ.ICHS) THEN
                      VALEUR=ZR(JCESV-1+IAD)
                      ZL(JCE1L-1+IAD1)=.TRUE.
                      ZR(JCE1V-1+IAD1)=VALEUR
                    END IF
                  END IF
50            CONTINUE
60          CONTINUE
70        CONTINUE

2       CONTINUE
1     CONTINUE


C     4. RECOPIE DU CHAMP SIMPLE DANS LE CHAMP CHVARC
C     -----------------------------------------------------
      CALL CESCEL(CHVARS,LIGRMO,'RAPH_MECA','PVARCMR','NON',NNCP,
     &            'V',CHVARC)

9999  CONTINUE
      CALL JEDEMA()
      END
