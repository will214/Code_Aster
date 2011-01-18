      SUBROUTINE NMEXTL(NOMA  ,NOMO  ,MOTFAC,IOCC  ,NOMCHA,
     &                  TYPCHA,LISTNO,LISTMA,NBNO  ,NBMA  ,
     &                  EXTRCH)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 17/01/2011   AUTEUR ABBAS M.ABBAS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2011  EDF R&D                  WWW.CODE-ASTER.ORG
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
      IMPLICIT      NONE
      CHARACTER*8   NOMA,NOMO
      CHARACTER*16  MOTFAC
      INTEGER       IOCC
      CHARACTER*16  NOMCHA
      CHARACTER*4   TYPCHA    
      INTEGER       NBNO,NBMA
      CHARACTER*24  LISTNO,LISTMA
      CHARACTER*8   EXTRCH
C
C ----------------------------------------------------------------------
C
C ROUTINE *_NON_LINE (EXTRACTION - LECTURE)
C
C LECTURE TOPOLOGIE (NOEUD OU MAILLE)
C
C ----------------------------------------------------------------------
C
C
C IN  NOMA   : NOM DU MAILLAGE
C IN  NOMO   : NOM DU MODELE
C IN  MOTFAC : MOT-FACTEUR POUR LIRE 
C IN  IOCC   : OCCURRENCE DU MOT-CLEF FACTEUR MOTFAC
C IN  TYPCHA : TYPE DU CHAMP 'NOEU'/'ELGA'
C IN  NOMCHA : NOM DU CHAMP
C IN  LISTNO : LISTE CONTENANT LES NOEUDS
C IN  LISTMA : LISTE CONTENANT LES MAILLES
C OUT NBNO   : LONGUEUR DE LA LISTE DES NOEUDS
C OUT NBMA   : LONGUEUR DE LA LISTE DES MAILLES
C OUT EXTRCH : TYPE D'EXTRACTION SUR LE CHAMP
C                'MIN'  VALEUR MINI SUR TOUTES LES MAILLES/NOEUDS
C                'MAX'  VALEUR MAXI SUR TOUTES LES MAILLES/NOEUDS
C                'MOY'  VALEUR MOYENNE TOUTES LES MAILLES/NOEUDS
C                'VALE' VALEUR TOUTES LES MAILLES/NOEUDS 
C
C ----------------------------------------------------------------------
C
      CHARACTER*8  K8BID,OUI
      INTEGER      N1,N2,N3,N4,N5,N6
      CHARACTER*16 VALK(1)
      INTEGER      NBMOCL
      CHARACTER*16 LIMOCL(5),TYMOCL(5)     
C
C ----------------------------------------------------------------------
C
C
C --- INITIALISATIONS
C
      N1     = 0
      N2     = 0
      N3     = 0
      N4     = 0
      N5     = 0
      NBNO   = 0
      NBMA   = 0
      EXTRCH = 'VALE'
C
C --- LECTURE DE L'ENDROIT POUR EXTRACTION
C
      VALK(1) = NOMCHA
      IF (TYPCHA.EQ.'NOEU') THEN
        CALL GETVTX(MOTFAC,'NOEUD'    ,IOCC,1,0,K8BID,N1    )
        CALL GETVTX(MOTFAC,'GROUP_NO' ,IOCC,1,0,K8BID,N2    )
        CALL GETVTX(MOTFAC,'MAILLE'   ,IOCC,1,0,K8BID,N3    )
        CALL GETVTX(MOTFAC,'GROUP_MA' ,IOCC,1,0,K8BID,N4    )
        CALL GETVTX(MOTFAC,'TOUT'     ,IOCC,1,1,OUI  ,N5    )
        IF ((N1.EQ.0).AND.(N2.EQ.0).AND.
     &      (N3.EQ.0).AND.(N4.EQ.0).AND.
     &      (N5.EQ.0)) THEN
          CALL U2MESK('F', 'EXTRACTION_1',1,VALK)
        ENDIF
      ELSEIF (TYPCHA.EQ.'ELGA') THEN
        CALL GETVTX(MOTFAC,'MAILLE'   ,IOCC,1,0,K8BID,N3    )
        CALL GETVTX(MOTFAC,'GROUP_MA' ,IOCC,1,0,K8BID,N4    )
        CALL GETVTX(MOTFAC,'TOUT'     ,IOCC,1,1,OUI  ,N5    )
        IF ((N3.EQ.0).AND.(N4.EQ.0).AND.(N5.EQ.0)) THEN
          CALL U2MESK('F', 'EXTRACTION_2',1,VALK)
        ENDIF
      ELSE
        CALL ASSERT(.FALSE.)
      ENDIF   
C
C --- TYPE D'EXTRACTION
C
      CALL GETVTX(MOTFAC,'EVAL_CHAM' ,IOCC,1,1,EXTRCH,N6    )
      IF (N6.EQ.0) THEN
        EXTRCH = 'VALE'
        CALL U2MESK('A', 'EXTRACTION_5',1,VALK)
      ENDIF
C
C --- EXTRACTION DES NOEUDS - ILS DOIVENT APPARTENIR AU MODELE -
C
      IF (TYPCHA.EQ.'NOEU') THEN
        NBMOCL    = 5
        TYMOCL(1) = 'GROUP_NO'
        TYMOCL(2) = 'NOEUD'
        TYMOCL(3) = 'GROUP_MA'
        TYMOCL(4) = 'MAILLE'
        TYMOCL(5) = 'TOUT'
        LIMOCL(1) = 'GROUP_NO'
        LIMOCL(2) = 'NOEUD'
        LIMOCL(3) = 'GROUP_MA'
        LIMOCL(4) = 'MAILLE'
        LIMOCL(5) = 'TOUT'
        CALL RELIEM(NOMO  ,NOMA  ,'NU_NOEUD',MOTFAC,IOCC  ,
     &              NBMOCL,LIMOCL,TYMOCL    ,LISTNO,NBNO  )
        IF (NBNO.EQ.0) THEN
          CALL U2MESK('F', 'EXTRACTION_3',1,VALK)
        ENDIF
      ENDIF
C
C --- EXTRACTION DES MAILLES - ILS DOIVENT APPARTENIR AU MODELE -
C
      IF (TYPCHA.EQ.'ELGA') THEN
        NBMOCL    = 3
        TYMOCL(1) = 'GROUP_MA'
        TYMOCL(2) = 'MAILLE'
        TYMOCL(3) = 'TOUT'
        LIMOCL(1) = 'GROUP_MA'
        LIMOCL(2) = 'MAILLE'
        LIMOCL(3) = 'TOUT'
        CALL RELIEM(NOMO  ,NOMA  ,'NU_MAILLE',MOTFAC,IOCC  ,
     &              NBMOCL,LIMOCL,TYMOCL     ,LISTMA,NBMA  )
        IF (NBMA.EQ.0) THEN
          CALL U2MESK('F', 'EXTRACTION_4',1,VALK)
        ENDIF
      ENDIF
C
      END
