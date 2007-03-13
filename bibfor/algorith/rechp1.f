      SUBROUTINE RECHP1(COORD ,LISSUR,LISNOE,
     &                  INO1  ,ISURF1,ISURF2,POSMIN,NUMMIN,
     &                  DMIN)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 13/03/2007   AUTEUR ABBAS M.ABBAS 
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
C RESPONSABLE ABBAS M.ABBAS
C
      IMPLICIT  NONE
      REAL*8    COORD(*)
      INTEGER   LISSUR(*),LISNOE(*)
      INTEGER   INO1,ISURF1,ISURF2
      REAL*8    DMIN      
      INTEGER   POSMIN,NUMMIN
C      
C ----------------------------------------------------------------------
C
C ROUTINE CONTACT (METHODES DISCRETES - APPARIEMENT)
C
C RECHERCHE DANS UNE SURFACE(2) DU NOEUD(2) LE PLUS PROCHE 
C DU NOEUD(1) DANS UNE SURFACE(1) PAR FORCE BRUTE
C
C ----------------------------------------------------------------------
C
C  
C IN  COORD  : VECTEUR DES COORDONNEES DE TOUS LES NOEUDS
C IN  LISSUR : INDICE DES NOEUDS CONSTITUANT LES SURFACES
C IN  LISNOE : LISTE DES NUMEROS ABSOLUS DES NOEUDS 
C IN  INO1   : INDICE DU NOEUD(1) DANS LISNOE
C IN  ISURF1 : NUMERO DE LA SURFACE(1)
C IN  ISURF2 : NUMERO DE LA SURFACE(2)
C OUT DMIN   : VALEUR DE LA DISTANCE MINIMALE ENTRE NOEUD(1) ET LE 
C                NOEUD(2) APPARTENANT A LA SURFACE(2)
C OUT NUMMIN : NUMERO ABSOLU DU NOEUD (2) DANS LE MAILLAGE 
C OUT POSMIN : POSITION DANS LISNOE DU NOEUD (2)
C
C
C ----------------------------------------------------------------------
C
      REAL*8  R8GAEM,COOR1(3),COOR2(3),PADIST,DIST
      INTEGER INO2,NBNO2,POSNO1,POSNO2,NUMNO1,NUMNO2
      INTEGER JDEC1,JDEC2
C
C ----------------------------------------------------------------------
C
      DMIN     = R8GAEM()   
      POSMIN   = 0   
C
C --- POINTEURS SUR LE DEBUT DES LISTES DES NOEUDS DES DEUX SURFACES
C
      JDEC1    = LISSUR(ISURF1)
      JDEC2    = LISSUR(ISURF2)    
C
C --- NOMBRE DE NOEUDS DE LA SURFACE (2)
C
      NBNO2    = LISSUR(ISURF2+1) - LISSUR(ISURF2)               
C
C --- INDICE DANS LISNOE DU NOEUD (1)
C     
      POSNO1   = JDEC1+INO1
C
C --- NUMERO ABSOLU DU NOEUD (1) DANS LE MAILLAGE
C       
      NUMNO1   = LISNOE(POSNO1)    
C
C --- COORDONNEES DU NOEUD (1)
C      
      COOR1(1) = COORD(3*(NUMNO1-1)+1)
      COOR1(2) = COORD(3*(NUMNO1-1)+2)
      COOR1(3) = COORD(3*(NUMNO1-1)+3)     
C
C --- BOUCLE SUR LES NOEUDS DE LA SURFACE (2)
C
      DO 20 INO2 = 1,NBNO2 
C
C --- INDICE DANS LISNOE DU NOEUD (2)
C            
        POSNO2   = JDEC2+INO2
C
C --- NUMERO ABSOLU DU NOEUD (2) DANS LE MAILLAGE
C                    
        NUMNO2   = LISNOE(POSNO2)
C
C --- COORDONNEES DU NOEUD (2)
C 
        COOR2(1) = COORD(3*(NUMNO2-1)+1)
        COOR2(2) = COORD(3*(NUMNO2-1)+2)
        COOR2(3) = COORD(3*(NUMNO2-1)+3)
        DIST     = PADIST(3,COOR1,COOR2) 
      
        IF (DIST.LT.DMIN) THEN
          DMIN   = DIST
          NUMMIN = NUMNO2
          POSMIN = POSNO2
        END IF

   20 CONTINUE
C   
      IF (POSMIN.EQ.0) THEN
        CALL U2MESS('F','CONTACT_27')
      ENDIF

      END
