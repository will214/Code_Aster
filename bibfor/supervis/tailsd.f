      SUBROUTINE TAILSD(NOM, NOMSD, VAL, NBVAL)
      
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF SUPERVIS  DATE 22/11/2004   AUTEUR DURAND C.DURAND 
C ======================================================================
C COPYRIGHT (C) 1991 - 2002  EDF R&D                  WWW.CODE-ASTER.ORG
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
      
      IMPLICIT NONE
      INTEGER NBVAL, NBNOM, VAL(NBVAL)
      CHARACTER*(*) NOM, NOMSD
      
C ---------------------------------------------------------------
C  DETERMINE LE NOMBRE DE VALEURS DANS UNE STRUCTURE DE DONNES
C ---------------------------------------------------------------
C IN  NOM     K*  NOM IDENTIFIANT A LA FOIS LA SD ET LA METHODE
C IN  NOMSD   I   NOM DE LA SD A INTERROGER
C OUT VAL     I   VECTEUR D'ENTIERS DE TAILLE NBVAL CONTENANT LES
C                 DIFFERENTES TAILLES
C OUT NBVAL   I   TAILLE DU VECTEUR D'ENTIERS VAL
C ---------------------------------------------------------------
C
      CHARACTER*1   K1BID
      CHARACTER*8   SD8,K8BID
      CHARACTER*19  SD19
      CHARACTER*24  SD
      INTEGER       IRET,IBID
      REAL*8        RBID
      COMPLEX*16    CBID
C
C
C
C  DETERMINE LE NOMBRE MAXIMUM DE CHAMPS ET DE PARAMETRES
C  AINSI QUE LE NOMBRE EFFECTIF DE NUMEROS D'ORDRE POUR UNE SD RESULTAT
C ---------------------------------------------------------------------
      IF ( NOM.EQ.'LIST_RESULTAT') THEN
        VAL(1) = 0
        VAL(2) = 0
        VAL(3) = 0
C   
        SD19 = NOMSD
        CALL JELIRA(SD19 // '.DESC','NOMMAX',VAL(1),K8BID)
        CALL JELIRA(SD19 // '.NOVA','NOMMAX',VAL(2),K8BID)
        CALL RSORAC(SD19,'LONUTI',IBID,RBID,K8BID,CBID,RBID,' ',
     &              VAL(3),1,IBID)

C
C  DETERMINE LE NOMBRE D OBJETS SIMPLES DANS UNE COLECTION
C ---------------------------------------------------------------------
      ELSE IF ( NOM.EQ.'LIST_COLLECTION') THEN
        VAL(1) = 0
C   
        SD = NOMSD
        CALL JEEXIN(SD,IRET)
        IF (IRET.NE.0) THEN
           CALL JELIRA(SD,'NUTIOC',VAL(1),K8BID)
           IF (VAL(1).EQ.0) CALL JELIRA(SD,'NMAXOC',VAL(1),K8BID)
        ENDIF
      ENDIF

      END
