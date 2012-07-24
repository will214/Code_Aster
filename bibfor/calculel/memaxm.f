      SUBROUTINE MEMAXM(TYPMX,CHAMP,NOCMP,NBCMP,LCMP,VR,NBMAIL,NUMAIL)
      IMPLICIT NONE
      INCLUDE 'jeveux.h'
      CHARACTER*(*) TYPMX
      CHARACTER*(*) CHAMP,NOCMP,LCMP(*)
      INTEGER NBCMP,NBMAIL,NUMAIL(*)
      REAL*8 VR(*)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF CALCULEL  DATE 24/07/2012   AUTEUR PELLET J.PELLET 
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
C   1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.         
C ======================================================================
C RESPONSABLE PELLET J.PELLET
C TOLE CRS_1404
C ----------------------------------------------------------------------
C BUT :  EXTRAIRE LE "MIN/MAX" DE COMPOSANTES
C        D'UN CHAMP (CHAM_ELEM OU CARTE) SUIVANT LA COMPOSANTE NOCMP
C
C EXEMPLE :
C   CONSIDERONS 2 MAILLES M1 ET M2 AVEC LES VALEURS D'UN CHAMP
C   (DX,DY,DZ):
C           SUR LA MAILLE M1 ---> (5,3,1)
C           SUR LA MAILLE M2 ---> (1,4,3)
C   SI LA COMPOSANTE CRITERE EST NOMCMP='DZ',ET QUE L'UTILISA-
C   TEUR DEMANDE LES VALEURS DES COMPOSANTES DX ET DY DU CHAMP
C   SUR L'ELEMENT OU LE MAX EST ATTEINT,LA FONCTION RETOURNERA:
C           VR=(1,4)
C   SI LA COMPOSANTE CRITERE EST NOMCMP='DZ',ET QUE L'UTILISA-
C   TEUR DEMANDE LA VALEUR DE LA COMPOSANTE DX DU CHAMP SUR
C   L'ELEMENT OU LE MIN EST ATTEINT,LA FONCTION RETOURNERA:
C           VR=5
C   SI LA COMPOSANTE CRITERE EST NOMCMP='DY',ET QUE L'UTILISA-
C   TEUR DEMANDE LA VALEUR DES COMPOSANTES DX,DY ET DZ DU CHAMP
C   SUR L'ELEMENT OU LE MAX EST ATTEINT,LA FONCTION RETOURNERA:
C           VR=(1,4,3)
C
C IN  : TYPMX  :  'MIN'/'MAX'/'MIN_ABS'/'MAX_ABS'
C IN  : CHAMP  :  NOM DU CHAMP A SCRUTER (VALEURS REELLES OU ENTIERES)
C IN  : NOCMP  :  NOM DE LA COMPOSANTE SUR LAQUELLE ON FAIT LE TEST
C IN  : NBCMP  :  NOMBRE DE COMPOSANTES DEMANDEES (=LONGUEUR DE VR)
C IN  : LICMP  :  NOM DES COMPOSANTES DEMANDEES PAR L'UTILISATEUR
C IN  : NBMAIL :  = 0   , COMPARAISON SUR TOUT LE MAILLAGE
C                 SINON , COMPARAISON SUR UNE PARTIE DU MAILLAGE
C IN  : NUMAIL :  NUMEROS DES MAILLES SUR LESQUELLES ON EFFECTUE LES
C                 COMPARAISONS (SI NBMAIL>0)
C OUT : VR     :  VECTEUR CONTENANT LES VALEURS DES COMPOSANTES DU CHAMP
C                 SUR L'ELEMENT (OU NOEUD OU POINT DE GAUSS) OU LE
C                 'MIN'/'MAX' EST ATTEINT
C ----------------------------------------------------------------------
C     ------------------------------------------------------------------
      INTEGER IBID,IRET
      INTEGER LONGT
      CHARACTER*8 KMPIC,TYP1,NOMGD,TSCA,TYCH
      INTEGER JCESD,JCESL,JCESC,JCESV,NEL,IEL,NBPT,NBSSPT,NCMP
      INTEGER IPT,ISP,ICMP,NCP,IICMP,IADR1,JCESK
      INTEGER IADR2,IEL1
      REAL*8 VALR,VMIMA
      REAL*8 R8MAEM,R8NNEM
      CHARACTER*19 CHAMS,CHAM19
      INTEGER TNCOMP(NBCMP)
      LOGICAL COPI,LMAX,LABS,LREEL
C     ------------------------------------------------------------------
C
      CALL JEMARQ()
C
      CHAM19=CHAMP
C
C     -- TRANSFORMATION DU CHAMP EN CHAMP SIMPLE :
C     --------------------------------------------
      CHAMS='&&MEMAXM.CES'
      CALL DISMOI('F','TYPE_CHAMP',CHAM19,'CHAMP',IBID,TYCH,IBID)
      IF (TYCH(1:2).EQ.'EL') THEN
        CALL CELCES(CHAM19,'V',CHAMS)
      ELSEIF (TYCH.EQ.'CART') THEN
        CALL CARCES(CHAM19,'ELEM',' ','V',CHAMS,' ',IRET)
        CALL ASSERT(IRET.EQ.0)
      ELSE
        CALL ASSERT(.FALSE.)
      ENDIF
      CALL JELIRA(CHAMS//'.CESV','TYPE',IBID,TYP1)
      CALL ASSERT(TYP1.EQ.'R')



      CALL JEVEUO(CHAMS//'.CESD','L',JCESD)
      CALL JEVEUO(CHAMS//'.CESL','L',JCESL)
      CALL JEVEUO(CHAMS//'.CESC','L',JCESC)
      CALL JEVEUO(CHAMS//'.CESK','L',JCESK)
      CALL JEVEUO(CHAMS//'.CESV','L',JCESV)

      NOMGD=ZK8(JCESK-1+2)
      CALL DISMOI('F','TYPE_SCA',NOMGD,'GRANDEUR',IBID,TSCA,IBID)
      CALL ASSERT(TSCA.EQ.'R'.OR.TSCA.EQ.'I')
      LREEL=TSCA.EQ.'R'



C     -- INITIALISATION DE VMIMA :
      CALL ASSERT(TYPMX(1:3).EQ.'MIN'.OR.TYPMX(1:3).EQ.'MAX')
      LMAX=TYPMX(1:3).EQ.'MAX'
      IF (.NOT.LMAX) VMIMA=+R8MAEM()
      IF (LEN(TYPMX).GT.3) THEN
         CALL ASSERT(LEN(TYPMX).EQ.7)
         CALL ASSERT(TYPMX(4:7).EQ.'_ABS')
         LABS=.TRUE.
         IF (LMAX) VMIMA=0.D0
      ELSE
         LABS=.FALSE.
         IF (LMAX) VMIMA=-R8MAEM()
      ENDIF


C     INITIALISATION DE TNCOMP CONTENANT LES INDICES
C     DES CMP
C     ----------------------------------
      DO 10,ICMP=1,NBCMP
        TNCOMP(ICMP)=0
   10 CONTINUE

      NCMP=ZI(JCESD-1+2)
      DO 30,ICMP=1,NCMP
        DO 20,IICMP=1,NBCMP
          IF (LCMP(IICMP).EQ.ZK8(JCESC-1+ICMP)) THEN
            TNCOMP(IICMP)=ICMP
          ENDIF
   20   CONTINUE
   30 CONTINUE


C     COMPARAISON NOCMP AVEC TTES LES
C     AUTRES AFIN DE RECUPERER LE NUM DE LA COMPOSANTE
C     RECUPERE L'INDEX DE LA COMPOSANTE A TESTER DANS LE CHAMP
      NCP=0
      DO 40,ICMP=1,NCMP
        IF (ZK8(JCESC-1+ICMP).EQ.NOCMP)NCP=ICMP
   40 CONTINUE

C     -- CAS : TOUTES LES MAILLES :
C     -----------------------------
      IF (NBMAIL.LE.0) THEN
C       NOMBRE D'ELEMENTS DU MAILLAGE
        NEL=ZI(JCESD-1+1)
C     -- CAS : LISTE DE MAILLES :
C     ---------------------------
      ELSE
        NEL=NBMAIL
      ENDIF


      DO 80,IEL=1,NEL

        IF (NBMAIL.LE.0) THEN
          IEL1=IEL
        ELSE
          IEL1=NUMAIL(IEL)
        ENDIF

C       NOMBRE DE PTS ET SSPTS POUR CHAQUE ELEMENT
        NBPT=ZI(JCESD-1+5+4*(IEL1-1)+1)
        NBSSPT=ZI(JCESD-1+5+4*(IEL1-1)+2)
        NCMP=ZI(JCESD-1+5+4*(IEL1-1)+3)

C
        DO 70,IPT=1,NBPT
          DO 60,ISP=1,NBSSPT
            CALL CESEXI('C',JCESD,JCESL,IEL1,IPT,ISP,NCP,IADR1)
            IF (IADR1.GT.0) THEN
              IF (LREEL) THEN
                VALR=ZR(JCESV-1+IADR1)
              ELSE
                VALR=ZI(JCESV-1+IADR1)
              ENDIF
              IF (LABS) VALR=ABS(VALR)
              COPI=.FALSE.
              IF ((LMAX) .AND. (VALR.GT.VMIMA))COPI=.TRUE.
              IF ((.NOT.LMAX) .AND. (VALR.LT.VMIMA))COPI=.TRUE.
              IF (COPI) THEN
                VMIMA=VALR
                DO 50,IICMP=1,NBCMP
                  CALL CESEXI('C',JCESD,JCESL,IEL1,IPT,ISP,
     &                        TNCOMP(IICMP),IADR2)
                  IF (IADR2.EQ.0) THEN
                    VR(IICMP)=R8NNEM()
                  ELSE
                    VR(IICMP)=ZR(JCESV-1+IADR2)
                  ENDIF
   50           CONTINUE
              ENDIF
            ENDIF
   60     CONTINUE
   70   CONTINUE
   80 CONTINUE


      CALL DETRSD('CHAMP',CHAMS)

C     -- IL FAUT PARFOIS COMMUNIQUER LE RESULTAT ENTRE LES PROCS :
      CALL DISMOI('F','MPI_COMPLET',CHAMP,'CHAMP',IBID,KMPIC,IBID)
      IF (KMPIC.EQ.'NON') THEN
        IF (LMAX) THEN
          CALL MPICM1('MPI_MAX','R',LONGT,IBID,VR)
        ELSE
          CALL MPICM1('MPI_MIN','R',LONGT,IBID,VR)
        ENDIF
      ENDIF

      CALL JEDEMA()
      END
