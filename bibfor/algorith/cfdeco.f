      SUBROUTINE CFDECO(RESOCO)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 14/09/2010   AUTEUR ABBAS M.ABBAS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2010  EDF R&D                  WWW.CODE-ASTER.ORG
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
C RESPONSABLE ABBAS M.ABBAS
C
      IMPLICIT     NONE
      CHARACTER*24 RESOCO
C      
C ----------------------------------------------------------------------
C
C ROUTINE CONTACT (METHODE DISCRETE - POST-TRAITEMENT)
C
C GESTION DE LA REAC. GEOM. EN CAS DE DECOUPE
C
C ----------------------------------------------------------------------
C
C
C IN  RESOCO : SD DE TRAITEMENT NUMERIQUE DU CONTACT
C
C ------------- DEBUT DECLARATIONS NORMALISEES JEVEUX -----------------
C
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
C
C --------------- FIN  DECLARATIONS  NORMALISEES  JEVEUX ---------------
C 
      CHARACTER*24 APJEU,JEUINI
      INTEGER      JAPJEU,JJEUIN
      INTEGER      ILIAI
      INTEGER      CFDISD,NBLIAI
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
C
C --- LECTURE DES STRUCTURES DE DONNEES DE CONTACT
C 
      APJEU  = RESOCO(1:14)//'.APJEU'
      JEUINI = RESOCO(1:14)//'.JEUINI' 
      CALL JEVEUO(APJEU, 'L',JAPJEU)
      CALL JEVEUO(JEUINI,'E',JJEUIN)
C
C --- INITIALISATION
C
      NBLIAI = CFDISD(RESOCO,'NBLIAI' )     
C 
C --- ON SAUVEGARDE LE JEU DANS LA SD DE RESOLUTION DU CONTACT
C --- CECI POUR PERMETTRE LA SUBDIVISION DU PAS DE TEMPS
C --- EN GEOMETRIE INITIALE (REAC_GEOM='SANS')
C
      DO 10 ILIAI = 1,NBLIAI
        ZR(JJEUIN+ILIAI-1) = ZR(JAPJEU+ILIAI-1)
 10   CONTINUE 
C
      CALL JEDEMA()
C 
      END
