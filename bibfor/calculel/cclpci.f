      SUBROUTINE CCLPCI(OPTION,MODELE,RESUIN,RESUOU,MATECO,
     &                  CARAEL,LIGREL,NUMORD,NBPAIN,LIPAIN,
     &                  LICHIN,CODRET)
      IMPLICIT NONE
C     --- ARGUMENTS ---
      INTEGER      NBPAIN,NUMORD,CODRET
      CHARACTER*8  MODELE,RESUIN,RESUOU,MATECO,CARAEL
      CHARACTER*8  LIPAIN(*)
      CHARACTER*16 OPTION
      CHARACTER*24 LICHIN(*),LIGREL
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF CALCULEL  DATE 13/02/2012   AUTEUR SELLENET N.SELLENET 
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
C ----------------------------------------------------------------------
C  CALC_CHAMP - DETERMINATION LISTE DE PARAMETRES ET LISTE DE CHAMPS IN
C  -    -                     -        -                      -      -
C ----------------------------------------------------------------------
C
C IN  :
C   OPTION  K16  NOM DE L'OPTION A CALCULER
C   MODELE  K8   NOM DU MODELE
C   RESUIN  K8   NOM DE LA STRUCUTRE DE DONNEES RESULTAT IN
C   RESUOU  K8   NOM DE LA STRUCUTRE DE DONNEES RESULTAT OUT
C   MATECO  K8   NOM DU MATERIAU CODE
C   CARAEL  K8   NOM DU CARAELE
C   LIGREL  K24  NOM DU LIGREL
C   NUMORD  I    NUMERO D'ORDRE COURANT
C
C OUT :
C   NBPAIN  I    NOMBRE DE PARAMETRES IN
C   LIPAIN  K8*  LISTE DES PARAMETRES IN
C   LICHIN  K8*  LISTE DES CHAMPS IN
C   CODRET  I    CODE RETOUR (0 SI OK, 1 SINON)
C ----------------------------------------------------------------------
C RESPONSABLE SELLENET N.SELLENET
C     ----- DEBUT DECLARATIONS NORMALISEES  JEVEUX ---------------------
      INTEGER        ZI
      COMMON /IVARJE/ZI(1)
      REAL*8         ZR
      COMMON /RVARJE/ZR(1)
      COMPLEX*16     ZC
      COMMON /CVARJE/ZC(1)
      LOGICAL        ZL
      COMMON /LVARJE/ZL(1)
      CHARACTER*8    ZK8
      CHARACTER*16          ZK16
      CHARACTER*24                  ZK24
      CHARACTER*32                          ZK32
      CHARACTER*80                                  ZK80
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C     ----- FIN  DECLARATIONS  NORMALISEES  JEVEUX ---------------------
      
      INTEGER      OPT,IAOPDS,IAOPLO,IAPARA,NPARIN,IPARA,OPT2,IERD,IBID
      INTEGER      DECAL
      CHARACTER*8  NOMA
      CHARACTER*16 OPTIO2
      CHARACTER*19 NOCHIN
      CHARACTER*32 JEXNUM,JEXNOM
      
      CALL JEMARQ()
      
      CODRET = 0
      
      IF ( OPTION(6:9).EQ.'NOEU' ) THEN
        NPARIN = 0
      ELSE
        CALL JENONU(JEXNOM('&CATA.OP.NOMOPT',OPTION),OPT)
        CALL JEVEUO(JEXNUM('&CATA.OP.DESCOPT',OPT),'L',IAOPDS)
        CALL JEVEUO(JEXNUM('&CATA.OP.LOCALIS',OPT),'L',IAOPLO)
        CALL JEVEUO(JEXNUM('&CATA.OP.OPTPARA',OPT),'L',IAPARA)
        
        NPARIN = ZI(IAOPDS-1+2)
        NBPAIN = 0
      ENDIF

C     BOUCLE SUR LES PARAMETRES DE L'OPTION
      DO 10 IPARA = 1,NPARIN
        NOCHIN = ' '
        
        NBPAIN = NBPAIN + 1
        LIPAIN(NBPAIN) = ZK8(IAPARA+IPARA-1)
        
        OPTIO2 = ZK24(IAOPLO+3*IPARA-2)(1:16)
        
C       CAS OU CE PARAM EST UNE OPTION OU UN CHAMP DANS LA
C       SD RESULTAT
        CALL JENONU(JEXNOM('&CATA.OP.NOMOPT',OPTIO2),OPT2)
        IF ( (OPT2.NE.0).OR.
     &       (ZK24(IAOPLO+3*IPARA-3).EQ.'RESU') ) THEN
          IF ( ZK24(IAOPLO+3*IPARA-1).EQ.'NP1' ) THEN
            DECAL = 1
          ELSEIF ( ZK24(IAOPLO+3*IPARA-1)(1:3).EQ.'NM1' ) THEN
            DECAL = -1
          ELSE
            DECAL = 0
          ENDIF
          CALL RSEXCH(RESUIN,OPTIO2,NUMORD+DECAL,NOCHIN,IERD)
          IF ( IERD.NE.0 ) THEN
            CALL RSEXCH(RESUOU,OPTIO2,NUMORD+DECAL,NOCHIN,IERD)
          ENDIF
          
          IF ( IERD.NE.0 ) THEN
            IF ( (OPTION.EQ.OPTIO2) ) THEN
C             CAS OU UN CHAMP DEPEND DE LUI MEME A L'INSTANT N-1
C             EXEMPLE : ENDO_ELGA
              IF ( ZK24(IAOPLO+3*IPARA-1).EQ.'NM1T' ) THEN
                NOCHIN='&&CALCOP.INT_0'
                CALL ALCHML(LIGREL,OPTIO2,LIPAIN(NBPAIN),
     &                      'V',NOCHIN,IERD,' ')
                IF (IERD.GT.0) THEN
                  CALL U2MESK('A','CALCULEL3_19',1,OPTION)
                  GO TO 10
                ENDIF
              ELSE
                CALL RSEXCH(RESUOU,OPTIO2,NUMORD+DECAL,NOCHIN,IERD)
                CALL ALCHML(LIGREL,OPTIO2,LIPAIN(NBPAIN),
     &                      'G',NOCHIN,IERD,' ')
                IF (IERD.GT.0) THEN
                  CALL U2MESK('A','CALCULEL3_19',1,OPTION)
                  GO TO 10
                ENDIF
                CALL RSNOCH(RESUOU,OPTIO2,NUMORD+DECAL,' ')
              ENDIF
            ELSE
              NOCHIN = ' '
            ENDIF
          ENDIF
C       CAS OU CE PARAM EST UN OBJET DU MAILLAGE
        ELSEIF ( ZK24(IAOPLO+3*IPARA-3).EQ.'MAIL' ) THEN
          CALL DISMOI('F','NOM_MAILLA',MODELE,'MODELE',IBID,NOMA,IERD)
          NOCHIN = NOMA//ZK24(IAOPLO+3*IPARA-2)
C       CAS OU CE PARAM EST UN OBJET DU MODELE
        ELSEIF ( ZK24(IAOPLO+3*IPARA-3).EQ.'MODL' ) THEN
          NOCHIN = MODELE//ZK24(IAOPLO+3*IPARA-2)
C       CAS OU CE PARAM EST UN OBJET DU CARA_ELEM
        ELSEIF ( ZK24(IAOPLO+3*IPARA-3).EQ.'CARA' ) THEN
          NOCHIN = CARAEL//ZK24(IAOPLO+3*IPARA-2)
C       CAS OU CE PARAM EST UN OBJET PARTICULIER SUR LA VOLATILE
        ELSEIF ( ZK24(IAOPLO+3*IPARA-3).EQ.'VOLA' ) THEN
          NOCHIN = ZK24(IAOPLO+3*IPARA-2)
C       CAS OU CE PARAM EST UN OBJET DU CHAMMAT
        ELSEIF ( ZK24(IAOPLO+3*IPARA-3).EQ.'CHMA' ) THEN
          NOCHIN = MATECO//ZK24(IAOPLO+3*IPARA-2)
        ENDIF
        LICHIN(NBPAIN) = NOCHIN
   10 CONTINUE
      
      CALL JEDEMA()
      
      END
