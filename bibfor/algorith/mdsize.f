      SUBROUTINE MDSIZE (NOMRES,NBSAUV,NBMODE,NBCHOC,NBREDE,NBREVI)
C
      IMPLICIT NONE
      CHARACTER*8   NOMRES
C-----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 27/08/2012   AUTEUR ALARCON A.ALARCON 
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
C     DIMINUTION DES OBJETS D'UN TRAN_GENE DE NOM NOMRES
C-----------------------------------------------------------------------
C IN  : NOMRES : NOM DU TRAN_GENE RESULTAT
C IN  : NBSAUV : NOMBRE DE RESULTATS ARCHIVES (SELON ARCHIVAGE DES PAS 
C                DE TEMPS).NOUVELLE TAILLE DE NOMRES
C IN  : NBMODE : NOMBRE DE MODES OU D'EQUATIONS GENERALISEES
C IN  : NBCHOC : NOMBRE DE CHOCS
C IN  : NBREDE : NOMBRE DE RELATION EFFORT DEPLACEMENT (RED)
C-----------------------------------------------------------------------
      CHARACTER*8   K8BID
C
C-----------------------------------------------------------------------
      INTEGER NBCHOC ,NBMODE ,NBREDE ,NBSAUV ,NBSTO1 ,NBSTOC ,NBREVI 
C-----------------------------------------------------------------------
      NBSTOC = NBSAUV * NBMODE
      CALL JEECRA(NOMRES//'           .DEPL' ,'LONUTI',NBSTOC,K8BID)
      CALL JEECRA(NOMRES//'           .VITE' ,'LONUTI',NBSTOC,K8BID)
      CALL JEECRA(NOMRES//'           .ACCE' ,'LONUTI',NBSTOC,K8BID)
      CALL JEECRA(NOMRES//'           .ORDR' ,'LONUTI',NBSAUV,K8BID)
      CALL JEECRA(NOMRES//'           .DISC' ,'LONUTI',NBSAUV,K8BID)
      CALL JEECRA(NOMRES//'           .PTEM' ,'LONUTI',NBSAUV,K8BID)
      
      IF (NBCHOC.GT.0) THEN
         NBSTOC = 3 * NBCHOC * NBSAUV
         NBSTO1 = NBCHOC * NBSAUV
         CALL JEECRA(NOMRES//'           .FCHO' ,'LONUTI',NBSTOC,K8BID)
         CALL JEECRA(NOMRES//'           .DLOC' ,'LONUTI',NBSTOC,K8BID)
         CALL JEECRA(NOMRES//'           .VCHO' ,'LONUTI',NBSTOC,K8BID)
         CALL JEECRA(NOMRES//'           .ICHO' ,'LONUTI',NBSTO1,K8BID)
      ENDIF
      IF (NBREDE.GT.0) THEN
         NBSTOC = NBREDE * NBSAUV
         CALL JEECRA(NOMRES//'           .REDC' ,'LONUTI',NBSTOC,K8BID)
         CALL JEECRA(NOMRES//'           .REDD' ,'LONUTI',NBSTOC,K8BID)
      ENDIF
C
      IF (NBREVI.GT.0) THEN
         NBSTOC = NBREVI * NBSAUV
         CALL JEECRA(NOMRES//'           .REVC' ,'LONUTI',NBSTOC,K8BID)
         CALL JEECRA(NOMRES//'           .REVD' ,'LONUTI',NBSTOC,K8BID)
      ENDIF
      END
