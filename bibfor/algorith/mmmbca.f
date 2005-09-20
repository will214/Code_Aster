      SUBROUTINE MMMBCA(NOMA,DEFICO,OLDGEO,DEPPLU,DEPMOI,
     &                  INCOCA,INST,DECOL)
C ======================================================================
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 19/09/2005   AUTEUR MABBAS M.ABBAS 
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
C
      IMPLICIT NONE
C
      INTEGER INCOCA,NDIM,I,J
      CHARACTER*8 NOMA
      CHARACTER*24  DEFICO,OLDGEO
      CHARACTER*24  DEPPLU,DEPMOI
      REAL*8 INST(3)
C
C ----------------------------------------------------------------------
C ROUTINE APPELEE PAR : OP0070
C ----------------------------------------------------------------------

C BOUCLE DU CA :

C  POUR LES POINTS POSTULES CONTACTANTS ON REGARDE LE SIGNE DE LAMBDA
C  POUR LES POINTS POSTULES NON CONTACTANTS ON REGARDE L'INTEPENETRATION
C  OUT   INCOCA   : INDICE DE CONVERGENCE DU CA : 1 CONVERGENCE, 0 NON

C  IN/OUT  DEFICO : TABFIN : ON REAJUSTE LES STATUTS
C  IN/OUT  DEFICO : JEUCON : ON CALCULE LE JEU EN CHAQUE POINT ESCLAVE
C  IN      OLDGEO : GEOMETRIE :POUR LE CALCUL DE JEU
C  IN      DEPPLU : DEPLACEMENT APRES CONVERGENCE DE NEWTON
C   IL FAUT METTRE LE NDIM
C -------------- DEBUT DECLARATIONS NORMALISEES JEVEUX -----------------

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

C ---------------- FIN DECLARATIONS NORMALISEES JEVEUX -----------------

      INTEGER JMACO,JMAESC,JTABF,JCMCF,JCOOR1,JCOOR2,JDEPP
      INTEGER JMETH
      INTEGER NTMA,K,JDIM,JDEPM,JECPD,JJEU,XA,XS,INDCOM
      INTEGER NTPC,IMA,POSMA,NBN,INI,POSMM,IZONE,IFORM
      REAL*8 XI,YI,TAU1(3),TAU2(3),GEOMM(3),GEOME(3),LAMBDA,LAMBD1
      REAL*8 ALPHA,JEU,VNORM(3),M(3,3),MM1(3,3),LAMBD2,XPG,YPG
      REAL*8 GEOLDM(3),GEOLDE(3),JEUVIT,DT,R8PREM,ASP,TOL    
      CHARACTER*24 COTAMA,MAESCL,CARACF,ECPDON
      CHARACTER*24 TABFIN,GEOACT,NDIMCO,JEUCON
      CHARACTER*24 METHCO
      LOGICAL      DECOL      

C ----------------------------------------------------------------------

C     LE TABLEAU  MAESCL = DEFICO(1:16)//.'MAESCL' CONTIENT LES NUMEROS
C     ABSOLUS DES MAILLES ESCLAVES ( CE NUMERO EST RECUPERE DE CONTAMA)
C     ET POUR CHAQUE MAILLE ESCLAVE LE NUMERO DE LA SA ZONE ET L'INDICE
C     DE SURFACE
C
      CALL JEMARQ()
      
      DT= INST(2)

C   RECUPERATION DE QUELQUES DONNEES
      CALL JEVEUO (DEPPLU(1:19)//'.VALE','E',JDEPP )
      CALL JEVEUO (DEPMOI(1:19)//'.VALE','E',JDEPM )
      COTAMA = DEFICO(1:16)//'.MAILCO'
      NDIMCO = DEFICO(1:16)//'.NDIMCO'
      MAESCL = DEFICO(1:16)//'.MAESCL'
      TABFIN = DEFICO(1:16)//'.TABFIN'
      CARACF = DEFICO(1:16)//'.CARACF'
      ECPDON = DEFICO(1:16)//'.ECPDON'      
      JEUCON = DEFICO(1:16)//'.JEUCON'
      METHCO = DEFICO(1:16)//'.METHCO'
C
      CALL JEVEUO(COTAMA,'L',JMACO)
      CALL JEVEUO(MAESCL,'L',JMAESC)
      CALL JEVEUO(TABFIN,'E',JTABF)
      CALL JEVEUO(CARACF,'L',JCMCF)
      CALL JEVEUO(NDIMCO,'L',JDIM)
      CALL JEVEUO(ECPDON,'L',JECPD)
      CALL JEVEUO(JEUCON,'E',JJEU)
      CALL JEVEUO(METHCO,'L',JMETH)

C   REACTUALISATION DE LA GEOMETRIE AVEC DEPPLU

      INCOCA = 1
      OLDGEO = NOMA//'.COORDO'
      GEOACT = '&&MMMBCA.ACTUGEO'
      ALPHA = 1.0D0
C
      NDIM = ZI(JDIM)
      CALL VTGPLD(OLDGEO,ALPHA,DEPPLU,'V',GEOACT)
C
      CALL JEVEUO(OLDGEO(1:19)//'.VALE','L',JCOOR1)
      CALL JEVEUO(GEOACT(1:19)//'.VALE','L',JCOOR2)
      NTMA = ZI(JMAESC)
      NTPC = 0
      INCOCA = 1
C
C   BOUCLE SUR LES POINTS DE CONTACT
C
      DO 30 IMA = 1,NTMA
        POSMA = ZI(JMAESC+3*(IMA-1)+1)
        IZONE = ZI(JMAESC+3*(IMA-1)+2)
        NBN   = ZI(JMAESC+3* (IMA-1)+3)
        IFORM = ZI(JECPD +6*(IZONE-1)+6)
        INDCOM = NINT(ZR(JCMCF+10*(IZONE-1)+7))     
        ASP = ZR(JCMCF+10*(IZONE-1)+8) 
        DO 20 INI = 1,NBN


C     CALCUL DE LA GEOMETRIE ACTUALISEE DU PC : GEOME()
            XPG=ZR(JTABF+21*NTPC+21* (INI-1)+3)
            YPG=ZR(JTABF+21*NTPC+21* (INI-1)+12)
C DEBUT
            XA = NINT(ZR(JTABF+21*NTPC+21* (INI-1)+21))
            XS = NINT(ZR(JTABF+21*NTPC+21* (INI-1)+13)) 
            JEU = 0.D00
            CALL COPCOS(NOMA,POSMA,XPG,YPG,GEOACT,GEOME,DEFICO)

            XI = ZR(JTABF+21*NTPC+21* (INI-1)+4)
            YI = ZR(JTABF+21*NTPC+21* (INI-1)+5)
            POSMM=ZR(JTABF+21*NTPC+21* (INI-1)+2)

            CALL MCOPCO(NOMA,POSMM,XI,YI,GEOACT,GEOMM,DEFICO)

C     CALCUL DE LA NORMALE
            TAU1(1) = ZR(JTABF+21*NTPC+21* (INI-1)+6)
            TAU1(2) = ZR(JTABF+21*NTPC+21* (INI-1)+7)
            TAU1(3) = ZR(JTABF+21*NTPC+21* (INI-1)+8)
            TAU2(1) = ZR(JTABF+21*NTPC+21* (INI-1)+9)
            TAU2(2) = ZR(JTABF+21*NTPC+21* (INI-1)+10)
            TAU2(3) = ZR(JTABF+21*NTPC+21* (INI-1)+11)

            IF (NDIM.EQ.2) THEN
                 VNORM(1) = -TAU1(2)
                 VNORM(2) = TAU1(1)
                 VNORM(3) = 0.D0
            ELSE IF (NDIM.EQ.3) THEN

                CALL PROVEC(TAU2,TAU1,VNORM)

            END IF

C    CALCUL DE JEU DU PC
            DO 10 K = 1,3
              JEU = JEU + (GEOME(K)-GEOMM(K))*VNORM(K)
   10       CONTINUE
            ZR(JJEU-1+NTPC+INI)=-JEU
C            
         IF ((XA.EQ.0) .AND. (XS.EQ.0)) THEN           

            IF (JEU.GT.ASP) THEN

                 IF (JEU.LE.0.D00) THEN
                   ZR(JTABF+21*NTPC+21* (INI-1)+21) = 1.D00
                   ZR(JTABF+21*NTPC+21* (INI-1)+13) = 0.D00
                   INCOCA = 0
                 ELSE IF (JEU.GT.0.D00) THEN
                   ZR(JTABF+21*NTPC+21* (INI-1)+21) = 1.D00
                   ZR(JTABF+21*NTPC+21* (INI-1)+13) = 1.D00
                   INCOCA = 0
                 END IF

            END IF
C   ON REGARDE LE JEU DES LES POINTS SUPPOSES NON CONTACTANT

         ELSE IF ((XA.EQ.1) .AND. (XS.EQ.0)) THEN

C ---- QUAND LA ZONE DE CONTACT IZONE EST STIPULEE GLISSIERE
C      ON FORCE LE CONTACT EN TOUS POINTS NON CONTACTANT
C      ET ON REBOUCLE

            IF(ZI(JMETH+8* (IZONE-1)+6).EQ.8) THEN
              ZR(JTABF+21*NTPC+21* (INI-1)+13) = 1.D0
              INCOCA=0
            ENDIF
            IF (IFORM .EQ. 2) THEN
              CALL COPCOS(NOMA,POSMA,XPG,YPG,OLDGEO,GEOLDE,DEFICO)
            ENDIF

C     CALCUL DE LA GEOMETRIE ACTUALISEE DU VIS A VIS GEOMM()

C IFORM=2 ==> FORMULATION EN VITESSE  
            IF (IFORM .EQ. 2) THEN
              CALL MCOPCO(NOMA,POSMM,XI,YI,OLDGEO,GEOLDM,DEFICO)
            ENDIF            
            
            TOL=1.D-8

            IF (JEU .GT. TOL) THEN
C            IF (JEU .GT. R8PREM()) THEN
                
C CALCUL DU GAP DES VITESSES NORMALES (FORMUL. EN VITESSE)

             IF (IFORM .EQ. 2) THEN
                   JEUVIT=0.D0
                   DO 11 K=1,3
                    JEUVIT= JEUVIT +((GEOME(K)-GEOLDE(K))-
     &                  (GEOMM(K)-GEOLDM(K)))*VNORM(K)/DT
   11              CONTINUE                

            
               IF (JEUVIT .GT. 0.D00) THEN
                 ZR(JTABF+21*NTPC+21* (INI-1)+13) = 1.D00
                 INCOCA = 0
               END IF
             ELSE
C ---- LE JEU EST NUL: POINT CONTACTANT, ON REBOUCLE (INCOCA=0)
C      (SAUF SI ON EST EN GLISSIERE)             
               ZR(JTABF+21*NTPC+21* (INI-1)+13) = 1.D00
               ZR(JTABF+21*NTPC+21* (INI-1)+21) = 1.D00
               INCOCA = 0
               IF (ZI(JMETH+8* (IZONE-1)+6).EQ.8) INCOCA=1
             END IF 
            ELSEIF (JEU.LT.ASP .AND. INDCOM.EQ.1) THEN
               ZR(JTABF+21*NTPC+21* (INI-1)+13) = 0.D00
               ZR(JTABF+21*NTPC+21* (INI-1)+21) = 0.D00 
            ENDIF           


C     POUR LES POINTS STUPILES CONTACTANT : ON REGARDE
C     LA REACTION

       ELSE IF ((XA.EQ.1) .AND. (XS.EQ.1)) THEN

             DECOL =.TRUE.

C     ON CALCULE LA REACTION LAMBDA

       CALL CALLAM(NOMA,POSMA,DEPPLU,XPG,YPG,LAMBDA,GEOACT,DEFICO)

C
           IF(LAMBDA.GT.0 .AND. ZI(JMETH+8* (IZONE-1)+6).NE.8) THEN
             INCOCA = 0
             ZR(JTABF+21*NTPC+21* (INI-1)+13) = 0.D00
           END IF
        ELSE
            CALL UTMESS('F','MMMBCA','ETAT DE CONTACT INCONNU')
        END IF
        
CC FIN

        
   20   CONTINUE
        NTPC = NTPC + NBN
   30 CONTINUE
      CALL JEDEMA()
      END
