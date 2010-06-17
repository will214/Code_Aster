      SUBROUTINE XBSIGR (NDIM,NNOP,DDLH,NFE,DDLC,DDLM,IGEOM,JPINTT,
     &                   CNSET,HEAVT,LONCH,BASLOC,SIGMA,NBSIG,
     &                   LSN,LST,DDLS,IVECTU,JPMILT)
      
       IMPLICIT NONE
C
       INTEGER       NDIM,NNOP,DDLH,NFE,DDLC,DDLM,IGEOM,NBSIG,DDLS
       INTEGER       CNSET(4*32),HEAVT(36),LONCH(10)
       INTEGER       IVECTU,JPINTT,JPMILT
       REAL*8        BASLOC(*),SIGMA,LSN(NNOP),LST(NNOP)
C

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 16/06/2010   AUTEUR CARON A.CARON 
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
C RESPONSABLE GENIAUT S.GENIAUT

C
C                 CALCUL DES FORCES INTERNES B*SIGMA AUX NOEUDS 
C                 DE L'ELEMENT DUES AU CHAMP DE CONTRAINTES SIGMA 
C                 DEFINI AUX POINTS D'INTEGRATION DANS LE CADRE DE
C                 LA M�THODE X-FEM, POUR L'OPTION REFE_FORC_NODA
C
C IN  NDIM    : DIMENSION DE L'ESPACE
C IN  NNOP    : NOMBRE DE NOEUDS DE L'ELEMENT PARENT
C IN  DDLH    : NOMBRE DE DDLS HEAVYSIDE (PAR NOEUD)
C IN  NFE     : NOMBRE DE FONCTIONS SINGULI�RES D'ENRICHISSEMENT 
C IN  DDLC    : NOMBRE DE DDLS DE CONTACT (PAR NOEUD)
C IN  IGEOM   : COORDONEES DES NOEUDS
C IN  PINTT   : COORDONN�ES DES POINTS D'INTERSECTION
C IN  CNSET   : CONNECTIVITE DES SOUS-ELEMENTS
C IN  HEAVT   : VALEURS DE L'HEAVISIDE SUR LES SS-ELTS
C IN  LONCH   : LONGUEURS DES CHAMPS UTILIS�ES
C IN  BASLOC  : BASE LOCALE AU FOND DE FISSURE
C IN  SIGMA   : CONTRAINTES DE REFERENCE
C IN  NBSIG   : NOMBRE DE CONTRAINTES ASSOCIE A L'ELEMENT
C IN  LSN     : VALEUR DE LA LEVEL SET NORMALE AUX NOEUDS PARENTS
C IN  LST     : VALEUR DE LA LEVEL SET TANGENTE AUX NOEUDS PARENTS
C IN  DDLS    : NOMBRE DE DDL (DEPL+CONTACT) � CHAQUE NOEUD SOMMET
C IN  PMILT   : COORDONNEES DES POINTS MILIEUX

C OUT IVECTU  : ADRESSE DU VECTEUR BT.SIGMA REFE
C
C --------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ---------------------
      INTEGER  ZI
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
C --------- FIN  DECLARATIONS  NORMALISEES  JEVEUX ---------------------
C
C     VARIABLES LOCALES
      REAL*8        HE,SIGTMP(15*6),BSIGMA(DDLS*NNOP)
      CHARACTER*8   ELREFP,ELRESE(6),FAMI(6)
      CHARACTER*24  COORSE
      INTEGER       NSE
      INTEGER       IT,ISE,IN,INO,NIT,NSEMAX(3),CPT,NPG,JCOORS,I,J
      INTEGER       IRESE,NNO,NNOPS,IBID
      LOGICAL       ISMALI

      DATA          NSEMAX / 2 , 3 , 6 /
      DATA    ELRESE /'SE2','TR3','TE4','SE3','TR6','T10'/
      DATA    FAMI   /'BID','XINT','XINT','BID','XINT','XINT'/
C.========================= DEBUT DU CODE EXECUTABLE ==================
C
      CALL ELREF1(ELREFP)

C     RECUPERATION DU NOMBRE DE NOEUDS SOMMETS DE L'ELEMENT PARENT
      CALL ELREF4(' ','RIGI',IBID,IBID,NNOPS,IBID,IBID,IBID,IBID,IBID)

C     SOUS-ELEMENT DE REFERENCE : RECUP DE NPG
      IF (ISMALI(ELREFP)) THEN
        IRESE=0
      ELSEIF (.NOT.ISMALI(ELREFP)) THEN
        IRESE=3
      ENDIF
      CALL ELREF5(ELRESE(NDIM+IRESE),FAMI(NDIM+IRESE),I,NNO,I,
     &     NPG,I,I,I,I,I,I)

C     R�CUP�RATION DE LA SUBDIVISION L'�L�MENT PARENT EN NIT TETRAS 
      NIT=LONCH(1)

      CPT=0
C     BOUCLE SUR LES NIT TETRAS
      DO 100 IT=1,NIT
C       R�CUP�RATION DU D�COUPAGE EN NSE SOUS-�L�MENTS 
        NSE=LONCH(1+IT)

C       BOUCLE SUR LES NSE SOUS-�L�MENTS
        DO 110 ISE=1,NSE
          CPT=CPT+1

C         COORD DU SOUS-�LT EN QUESTION
          COORSE='&&XBSIGR.COORSE'
          CALL WKVECT(COORSE,'V V R',NDIM*NNO,JCOORS)

C         BOUCLE SUR LES 4/3 SOMMETS DU SOUS-TETRA/TRIA
          DO 112 IN=1,NNO
            INO=CNSET(NNO*(CPT-1)+IN)
            DO 113 J=1,NDIM
              IF (INO.LT.1000) THEN
                ZR(JCOORS-1+NDIM*(IN-1)+J)=ZR(IGEOM-1+NDIM*(INO-1)+J)
              ELSEIF (INO.GT.1000 .AND. INO.LT.2000) THEN
                ZR(JCOORS-1+NDIM*(IN-1)+J)=
     &                               ZR(JPINTT-1+NDIM*(INO-1000-1)+J)
              ELSEIF (INO.GT.2000 .AND. INO.LT.3000) THEN
                ZR(JCOORS-1+NDIM*(IN-1)+J)=
     &                               ZR(JPMILT-1+NDIM*(INO-2000-1)+J)
              ELSEIF (INO.GT.3000) THEN
                ZR(JCOORS-1+NDIM*(IN-1)+J)=
     &                               ZR(JPMILT-1+NDIM*(INO-3000-1)+J)
              ENDIF
 113        CONTINUE
 112      CONTINUE


C         FONCTION HEAVYSIDE CSTE SUR LE SS-ELT
          HE=HEAVT(NSEMAX(NDIM)*(IT-1)+ISE)

          CALL R8INIR(NBSIG*NPG,0.D0,SIGTMP,1)

C         BOUCLE SUR LES SIG TESTS : SIGTMP = {0 0 0  SIGMA 0 0 0 0 0}
          DO 200 I=1,NBSIG*NPG

            SIGTMP(I)=SIGMA

            IF (NDIM .EQ. 3) THEN
              CALL XBSIG3(ELREFP,NDIM,COORSE,IGEOM,HE,DDLH,DDLC,NFE,
     &                    BASLOC,NNOP,NPG,SIGTMP,LSN,LST,BSIGMA)
            ELSE
              CALL XBSIG2(ELREFP,ELRESE(NDIM+IRESE),NDIM,COORSE,IGEOM,
     &                    HE,DDLH,DDLC,DDLM,NFE,
     &                    BASLOC,NNOP,NPG,SIGTMP,LSN,LST,IVECTU)
            ENDIF

            DO 210 J=1,DDLS*NNOPS+DDLM*(NNOP-NNOPS)
              ZR(IVECTU-1+J) = ZR(IVECTU-1+J)+ABS(ZR(IVECTU-1+J))/NPG
 210        CONTINUE

            SIGTMP(I)=0.D0

 200      CONTINUE

          CALL JEDETR(COORSE)

 110    CONTINUE

 100  CONTINUE

C.============================ FIN DE LA ROUTINE ======================
      END
