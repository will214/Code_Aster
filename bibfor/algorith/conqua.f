      SUBROUTINE CONQUA(MACOR,NBCOR,MACOC,NBCOC,
     &                  LFACE,LOMODI,LOCORR,LOREOR,MA)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 12/03/2007   AUTEUR LAVERNE J.LAVERNE 
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
C  ROUTINE CONQUA
C    TRAITEMENT DE KTYC = QUAD4, KTYR = QUAD4,TRIA3
C            ET DE KTYC = QUAD8, KTYR = QUAD9,QUAD8,TRIA6
C  DECLARATIONS
C    LOMODI : LOGICAL PRECISANT SI LA MAILLE EST UNE MAILLE MODIFIEE
C    MACOC  : TABLEAU DES NOMS DES NOEUDS   POUR UNE MAILLE FISSURE
C    MACOR  : TABLEAU DES NOMS DES NOEUDS   POUR UNE MAILLE REFERENCE
C    NBCOC  : NOMBRE DE CONNEX              POUR UNE MAILLE FISSURE
C    NBCOR  : NOMBRE DE CONNEX              POUR UNE MAILLE REFERENCE
C    NBLIC  : NOMBRE DE NOEUD TESTES        POUR UNE MAILLE FISSURE
C    NBLIR  : NOMBRE DE NOEUD TESTES        POUR UNE MAILLE REFERENCE
C    NBNOCO : NOMBRE DE NOEUD COMMUNS
C    NOCOC  : TABLEAU DE RANG DES NOEUDS    POUR UNE MAILLE FISSURE
C
C  MOT_CLEF : ORIE_FISSURE
C
      IMPLICIT REAL*8 (A-H,O-Z)
C
C     ------------------------------------------------------------------
C
      INTEGER      NBNOCO
      INTEGER      NBLIR,NBCOR
      INTEGER      NBLIC,NBCOC,NOCOC(4)
      INTEGER VALI
C
      CHARACTER*8  MACOR(NBCOR+2),MACOC(NBCOC+2),MA
C
      LOGICAL      LOMODI,LOCORR,LFACE,QUADRA,LOREOR
      LOGICAL      FACE
      FACE(I1,I2)=NOCOC(1).EQ.I1.AND.NOCOC(2).EQ.I2
C
C     ------------------------------------------------------------------
C
      QUADRA=NBCOC.EQ.8
      IF (QUADRA) THEN
        NBLIR  = NBCOR/2
      ELSE
        NBLIR  = NBCOR
      ENDIF
      NBLIC  = 4
      CALL CONCOM(MACOR,NBLIR,MACOC,NBLIC,NBNOCO,NOCOC)
C
      IF (NBNOCO.EQ.2) THEN
        IF      (FACE(1,2).OR.FACE(3,4)) THEN
          LOCORR=.TRUE.
          LFACE=FACE(1,2)
        ELSE IF (FACE(1,4).OR.FACE(2,3)) THEN
C     ------------------------------------------------------------------
C     MODIFICATION DE LA MAILLE DE FISSURE
C     ------------------------------------------------------------------
          LOMODI = .TRUE.
          LFACE=FACE(2,3)
          CALL CONPER(MACOC,1,2,3,4)
          IF (QUADRA) CALL CONPER(MACOC,5,6,7,8)
        ELSE
          CALL U2MESS('E','ALGORITH2_25')
        ENDIF
        IF (LFACE) THEN
          I1=1
          I2=2
        ELSE
          I1=3
          I2=4
        ENDIF
        CALL CONORS(I1,I2,0,MACOC,NBCOC,MACOR,NBCOR,LOREOR,MA)
        IF (LOREOR) THEN
          CALL CONECH(MACOC,1,4)
          CALL CONECH(MACOC,2,3)
          IF (QUADRA) CALL CONECH(MACOC,5,7)
        ENDIF
        CALL CONJAC(1,4,2,0,MACOC,NBCOC,MA)
        CALL CONJAC(2,1,3,0,MACOC,NBCOC,MA)
        CALL CONJAC(3,2,4,0,MACOC,NBCOC,MA)
        CALL CONJAC(4,3,1,0,MACOC,NBCOC,MA)

C
      ELSEIF (NBNOCO.GT.1) THEN
         VALI = NBNOCO
         CALL U2MESG('E', 'ALGORITH12_61',0,' ',1,VALI,0,0.D0)
      ENDIF
C
      END
