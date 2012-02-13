      SUBROUTINE CCLODR(NUOPLO,NBORDR,LISORD,NOBASE,MINORD,
     &                  MAXORD,RESUIN,RESUOU,LACALC)
      IMPLICIT NONE
C     --- ARGUMENTS ---
      INTEGER      NUOPLO,NBORDR,MINORD,MAXORD
      CHARACTER*8  RESUIN,RESUOU,NOBASE
      CHARACTER*19 LISORD
      CHARACTER*24 LACALC
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
C  CALC_CHAMP - DETERMINATION LISTE OPTIONS AVEC DEPENDANCE REDUITE
C  -    -                     -     -            -          -
C ----------------------------------------------------------------------
C
C  MODIFICATION DE LACALC EN METTANT DES 0 LORSQUE L'OPTION NE DOIT
C   PAS ETRE CALCULEE
C
C  IN  :
C   NUOPLO  I    INDICE DE L'OPTION POUR LAQUELLE ON SOUHAITE OBTENIR
C                LA LISTE DE NUMEROS D'ORDRE
C   NBORDR  I    NOMBRE DE NUMEROS D'ORDRE
C   LISORD  K19  LISTE DE NUMEROS D'ORDRE
C   NOBASE  K8   BASE DU NOM A PARTIR DE LAQUELLE LE NOM DES OBJETS DE
C                CCLIOP SERONT CONSTRUITS
C   MINORD  I    NUMERO D'ORDRE MIN
C   MAXORD  I    NUMERO D'ORDRE MAX
C   RESUIN  K8   NOM DE LA STRUCTURE DE DONNEES RESULTAT IN
C   RESUOU  K8   NOM DE LA STRUCTURE DE DONNEES RESULTAT OUT
C
C  IN/OUT :
C   LACALC  K24  NOM DE LA LISTE D'ENTIER QUI SERA MODIFIE
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
C
      INTEGER      JLISOP,JLIORI,JLIDEP,IERD,INDDEB,INDFIN
      INTEGER      IORDR,CURMAX,CURMIN,ITER,DECAL,NUMORD,JLNOIN
      INTEGER      JORDO2,JLISDE,JORDR,JACALC
C
      CHARACTER*1  ISODEP
      CHARACTER*16 OPTION
      CHARACTER*19 NOSYOU
      CHARACTER*24 NOLIOP,NOLORI,NOLDEP,NOLIIN,NOLISD
C
      LOGICAL      EXITOR
C
      CALL JEMARQ()
C
      CALL JEVEUO(LISORD,'L',JORDR)
C
      ISODEP = ' '
      NOLIOP = NOBASE//'.LISOPT'
      NOLORI = NOBASE//'.LISORI'
      NOLDEP = NOBASE//'.LISDEP'
      NOLIIN = NOBASE//'.LNOINS'
      NOLISD = NOBASE//'.ISODEP'
C
      CALL JEVEUO(NOLIOP,'L',JLISOP)
      CALL JEVEUO(NOLORI,'L',JLIORI)
      CALL JEVEUO(NOLDEP,'L',JLIDEP)
      CALL JEVEUO(NOLIIN,'L',JLNOIN)
      CALL JEVEUO(NOLISD,'L',JLISDE)
      CALL JEVEUO(LACALC,'E',JACALC)
C
      OPTION = ZK24(JLISOP+NUOPLO-1)
      INDDEB = ZI(JLIORI+2*NUOPLO-2)
      INDFIN = ZI(JLIORI+2*NUOPLO-1)
      ISODEP = ZK8(JLISDE+NUOPLO-1)
C
      IF ( INDDEB.NE.0 ) THEN
C       CAS 1 : CETTE OPTION DEPEND D'AUTRES OPTIONS A CALCULER
C               AUQUEL CAS, IL FAUT REGARDER COMMENT ELLE EN DEPEND
C               ET LA LISTE DES NUMEROS D'ORDRE DE SES PARENTS
        CALL JEVEUO(NOLIIN,'L',JLNOIN)
        CURMAX = MAXORD
        CURMIN = MINORD
        DO 10 ITER = INDDEB,INDFIN
          CALL JEVEUO(ZK24(JLNOIN+ITER-1),'L',JORDO2)

          IF ( ZK8(JLIDEP+ITER-1).EQ.'NP1' ) THEN
            DECAL = -1
          ELSEIF ( ZK8(JLIDEP+ITER-1).EQ.'NM1' ) THEN
            DECAL = +1
          ELSE
            DECAL = 0
          ENDIF
C
C         LA LISTE DE NUMEROS D'ORDRE PROVIENT DE OP0058
C         ELLE EST DONC CROISSANTE
          CURMAX = MIN(CURMAX,ZI(JORDO2+2)+DECAL)
          CURMIN = MAX(CURMIN,ZI(JORDO2+1)+DECAL)
   10   CONTINUE
C
        EXITOR = .TRUE.
        IF ( ZI(JACALC+NUOPLO-1).EQ.1 ) THEN
          DO 30 IORDR = 1,NBORDR
            NUMORD = ZI(JORDR-1+IORDR)
            IF ( (ISODEP.EQ.'-').AND.(NUMORD.EQ.MINORD) ) THEN
              GOTO 30
            ELSEIF ( (ISODEP.EQ.'+').AND.(NUMORD.EQ.MAXORD) ) THEN
              GOTO 30
            ENDIF
            IF ( NUMORD.GE.CURMIN ) THEN
              IF ( NUMORD.GT.CURMAX ) GOTO 40
              NOSYOU = ' '
              CALL RSEXCH(RESUIN,OPTION,NUMORD,NOSYOU,IERD)
              IF ( IERD.NE.0 ) THEN
                CALL RSEXCH(RESUOU,OPTION,NUMORD,NOSYOU,IERD)
              ENDIF
C
              IF ( IERD.NE.0 ) THEN
                EXITOR = .FALSE.
              ENDIF
            ENDIF
   30     CONTINUE
        ENDIF
C
   40   CONTINUE
C
        IF ( EXITOR ) THEN
          DO 50 ITER = INDDEB,INDFIN
            ZI(JACALC+ITER-1) = 0
   50     CONTINUE
        ENDIF
      ENDIF
C
      CALL JEDEMA()
C
      END
