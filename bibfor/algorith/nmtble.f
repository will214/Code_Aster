      SUBROUTINE NMTBLE(NIVEAU, 
     &                  MAILLA, DEFICO, OLDGEO, NEWGEO,
     &                  DEPMOI, DEPGEO, MAXB,   DEPLAM,
     &                  COMGEO, CSEUIL, COBCA, 
     &                  DEPPLU) 

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 06/04/2004   AUTEUR DURAND C.DURAND 
C ======================================================================
C COPYRIGHT (C) 1991 - 2003  EDF R&D                  WWW.CODE-ASTER.ORG
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
C RESPONSABLE PBADEL P.BADEL
      IMPLICIT NONE

      INTEGER      NIVEAU,MAXB(4),COMGEO,CSEUIL,COBCA
      CHARACTER*8  MAILLA
      CHARACTER*24 DEFICO,OLDGEO,NEWGEO,DEPMOI,DEPGEO,DEPLAM
      CHARACTER*24 DEPPLU
C ----------------------------------------------------------------------
C
C   STAT_NON_LINE : ROUTINE DE FIN DE BOUCLE DES ITERATIONS SE SITUANT
C                   ENTRE LES PAS DE TEMPS ET L'EQUILIBRE
C
C                   POUR LE MOMENT, SERT A LA METHODE CONTINUE DE
C                   CONTACT
C
C                   SERVIRA DANS L'AVENIR POUR LES CALCULS DE
C                   SENSIBILITE
C
C                   LES ITERATIONS ONT LIEU ENTRE CETTE ROUTINE
C                   (NMTBLE) ET SA COUSINE (NMIBLE) QUI COMMUNIQUENT
C                   POUR LE MOMENT PAR LA VARIABLE NIVEAU
C
C   IN
C
C   OUT
C -------------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ----------------
C
      CHARACTER*32       JEXNUM , JEXNOM , JEXATR
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
C
C -------------- FIN  DECLARATIONS  NORMALISEES  JEVEUX ----------------

      LOGICAL RGENCE,CGENCE
      INTEGER INCOCA

      NIVEAU=0

      CALL MMMBCA(MAILLA,DEFICO,OLDGEO,DEPPLU,DEPMOI,INCOCA)

      IF (COBCA.GE.MAXB(1)) THEN
        IF (MAXB(4).EQ.1) CALL UTMESS('F', 'NMTBLE','ECHEC DANS LE
     &     TRAITEMENT DU CONTACT, AUGMENTER ITER_MAXI_CONT')
        GOTO 140
      END IF
      IF (INCOCA.EQ.0) THEN
        NIVEAU=1
        GOTO 9999
      ENDIF
  140 CONTINUE

      CALL NMIMPR('IMPR','CNV_CTACT',' ',0.D0,COBCA)

C -- FIN BOUCLE SUR LES SEUILS (CONTACT ECP)

      IF (MAXB(4).EQ.1) GOTO 150
      CALL MMMCRI(DEPPLU,DEPLAM,CGENCE)
      CALL REACLM(MAILLA,DEPPLU,NEWGEO,DEFICO)
      IF ( CGENCE .OR. (CSEUIL.GE.MAXB(2)) ) GOTO 150
      CALL COPISD('CHAMP_GD','V',DEPPLU,DEPLAM)
      NIVEAU = 2
      GOTO 9999
  150 CONTINUE

      IF (MAXB(4).NE.1) CALL NMIMPR('IMPR','CNV_SEUIL',' ',0.D0,CSEUIL)

C -- FIN BOUCLE GEOMETRIQUE (CONTACT ECP)

       CALL MMMCRI(DEPPLU,DEPGEO,RGENCE)
       IF ( RGENCE .OR. (COMGEO.EQ.(MAXB(3)+1)) ) GOTO 160
       CALL COPISD('CHAMP_GD','V',DEPPLU,DEPGEO)
       NIVEAU=3
       GOTO 9999
160   CONTINUE

      CALL NMIMPR('IMPR','CNV_GEOME',' ',0.D0,COMGEO)
      
 9999 CONTINUE     

      END
