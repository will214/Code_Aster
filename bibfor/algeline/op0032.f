      SUBROUTINE OP0032 ( IER )
      IMPLICIT NONE
      INTEGER             IER
C     ------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGELINE  DATE 06/04/2004   AUTEUR DURAND C.DURAND 
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
C     VERIFICATION DU NOMBRE DE FREQUENCES DANS UNE BANDE DONNEE PAR LA
C     METHODE DITE DE STURM
C     ------------------------------------------------------------------
C
C     ----- DEBUT COMMUNS NORMALISES  JEVEUX  --------------------------
      INTEGER          ZI
      COMMON  /IVARJE/ ZI(1)
      REAL*8           ZR
      COMMON  /RVARJE/ ZR(1)
      COMPLEX*16       ZC
      COMMON  /CVARJE/ ZC(1)
      LOGICAL          ZL
      COMMON  /LVARJE/ ZL(1)
      CHARACTER*8      ZK8
      CHARACTER*16              ZK16
      CHARACTER*24                        ZK24
      CHARACTER*32                                  ZK32
      CHARACTER*80                                            ZK80
      COMMON  /KVARJE/ ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C     -----  FIN  COMMUNS NORMALISES  JEVEUX  --------------------------
C
      REAL*8       OMEGA2, OMGMIN, OMGMAX, OMIN, OMAX, FCORIG, OMECOR
      REAL*8       FMIN,   FMAX, PRECDC
      REAL*8       MANTIS
      REAL*8       FREQOM
      INTEGER      IUNIFI
      INTEGER      EXPO  , PIVOT1, PIVOT2, MXDDL, NPREC, NBRSS,IERD
      INTEGER      NBLAGR, NBCINE, NEQACT, NEQ
      INTEGER      LTYPRE, L, LPR, LBRSS, LMASSE, LRAIDE, LDDL, LDYNAM,
     &             LPROD, IFR, IRET, ICOMP, IERX, NBFREQ
      CHARACTER*19 MASSE , RAIDE
      CHARACTER*8  CBID
      CHARACTER*16 CONCEP, NOMCMD, TYPRES, FICHIE
      CHARACTER*19 DYNAM
      PARAMETER   ( MXDDL=1 )
C     ------------------------------------------------------------------
C
      CALL JEMARQ()
      CALL INFMAJ()
C
C
      FMIN = 0.D0
C     --- TYPE DE CALCUL : DYNAMIQUE OU FLAMBEMENT ---
C     TYPE_RESU : 'DYNAMIQUE' OU 'FLAMBEMENT'
      CALL GETVTX(' ','TYPE_RESU',1,1,1,TYPRES,LTYPRE)
      IF (TYPRES . EQ. 'DYNAMIQUE') THEN
        CALL GETVR8(' ','FREQ_MIN' ,1,1,1,FMIN,L)
        CALL GETVR8(' ','FREQ_MAX' ,1,1,1,FMAX,L)
        OMIN = OMEGA2(FMIN)
        OMAX = OMEGA2(FMAX)
      ELSE
        CALL GETVR8(' ','CHAR_CRIT_MIN' ,1,1,1,OMIN,L)
        CALL GETVR8(' ','CHAR_CRIT_MAX' ,1,1,1,OMAX,L)
      ENDIF
      CALL GETVR8(' ','SEUIL_FREQ',1,1,1,FCORIG,L)
      CALL GETVR8(' ','PREC_SHIFT',1,1,1,PRECDC,L)
C
C     --- RECUPERATION DES ARGUMENTS CONCERNANT LA FACTORISATION ---
      CALL GETVIS(' ','NPREC_SOLVEUR',1,1,1,NPREC,LPR)
C
C     --- RECUPERATION DES ARGUMENTS CONCERNANT LA NOMBRE DE SHIFT ---
      CALL GETVIS(' ','NMAX_ITER_SHIFT',1,1,1,NBRSS,LBRSS)
C
      IF (OMIN .GE. OMAX ) THEN
         CALL UTMESS('F','IMPR_STURM',
     +                   'LA VALEUR D''ENTREE MIN ET SUPERIEURE '//
     +                   'OU EGALE A LA VALEUR D''ENTREE SUP')
      ENDIF
C
C     --- FICHIER D'IMPRESSION ---
      FICHIE = 'RESULTAT'
      CALL GETVTX(' ','FICHIER' ,1,1,1,FICHIE,L)
      IFR = IUNIFI(FICHIE)
      IF ( IFR .EQ. 0 ) THEN
         CALL UTMESS('F','IMPR_STURM',
     +                   'LE FICHIER "'//FICHIE//'" N''EST PAS ACTIF.')
      ENDIF
C
      CALL GETRES( CBID , CONCEP , NOMCMD )
C
C     --- CONTROLE DES REFERENCES ---
      CALL GETVID(' ','MATR_A',1,1,1,RAIDE,L)
      CALL GETVID(' ','MATR_B',1,1,1,MASSE,L)
      CALL VRREFE(MASSE,RAIDE,IRET)
      IF ( IRET .NE. 0 ) THEN
         CALL UTMESS('F','IMPR_STURM',
     +                   'LES  MATRICES  "'//RAIDE//'"  ET  "'//MASSE//
     +                   '"  N''ONT PAS LE MEME DOMAINE DE DEFINITION.')
      ENDIF
C
C     CREATION DE LA MATRICE DYNAMIQUE
      DYNAM = '&&OP0032.MATR_DYNAM'
      CALL MTDEFS ( DYNAM, RAIDE, 'V', ' ' )
C
      CALL MTDSCR(MASSE)
      CALL JEVEUO(MASSE(1:19)//'.&INT','E',LMASSE)
      CALL MTDSCR(RAIDE)
      CALL JEVEUO(RAIDE(1:19)//'.&INT','E',LRAIDE)
      CALL MTDSCR(DYNAM)
      CALL JEVEUO(DYNAM(1:19)//'.&INT','E',LDYNAM)

C     CALCUL DU NOMBRE DE LAGRANGE
      NEQ = ZI(LRAIDE+2)
      CALL WKVECT('&&OP0032.POSITION.DDL','V V I',NEQ*MXDDL,LDDL)
      CALL WKVECT('&&OP0032.DDL.BLOQ.CINE','V V I',NEQ,LPROD)
      CALL VPDDL(RAIDE, MASSE, NEQ, NBLAGR, NBCINE, NEQACT, ZI(LDDL),
     &           ZI(LPROD),IERD)



C
      OMECOR = OMEGA2(FCORIG)

C     --- STURM AVEC LA BORNE MINIMALE ---
      OMGMIN = OMIN
      ICOMP = 0
  10  CONTINUE
         CALL VPSTUR(LRAIDE,OMGMIN,LMASSE,LDYNAM,NPREC,MANTIS,
     +               EXPO,PIVOT1,IERX)
         IF (IERX .NE. 0 ) THEN
           IF (ABS(OMGMIN) .LT. OMECOR) THEN
              OMGMIN=-OMECOR
              IF (TYPRES.EQ.'DYNAMIQUE') THEN
                WRITE(6,1600) FREQOM(OMGMIN)
              ELSE
                WRITE(6,3600) OMGMIN
              ENDIF
           ELSE
              IF (OMGMIN .GT. 0.D0) THEN
                  OMGMIN = (1.D0-PRECDC) * OMGMIN
              ELSE
                  OMGMIN = (1.D0+PRECDC) * OMGMIN
              ENDIF
           ENDIF
           ICOMP = ICOMP + 1
           IF (ICOMP.GT.NBRSS) THEN
              CALL UTMESS('A',NOMCMD,'TROP DE RE-AJUSTEMENT '//
     +        'DE LA BORNE MINIMALE.')
           ELSE
              IF (TYPRES.EQ.'DYNAMIQUE') THEN
                WRITE(6,1700) (PRECDC*100.D0),FREQOM(OMGMIN)
              ELSE
                WRITE(6,3700) (PRECDC*100.D0),OMGMIN
              ENDIF
              GOTO 10
           ENDIF
         ENDIF
C
C     --- STURM AVEC FREQ_MAX ---
      OMGMAX = OMAX
      ICOMP = 0
  20  CONTINUE
         CALL VPSTUR(LRAIDE,OMGMAX,LMASSE,LDYNAM,NPREC,MANTIS,
     +               EXPO,PIVOT2,IERX)
         IF (IERX .NE. 0 ) THEN
            IF (ABS(OMGMAX) .LT. OMECOR) THEN
                OMGMAX=OMECOR
                IF (TYPRES.EQ.'DYNAMIQUE') THEN
                  WRITE(6,1800) FREQOM(OMGMAX)
                ELSE
                  WRITE(6,3800) OMGMAX
                ENDIF
            ELSE
                IF (OMGMAX .GT. 0.D0 ) THEN
                   OMGMAX = (1.D0 + PRECDC) * OMGMAX
                ELSE
                   OMGMAX = (1.D0 - PRECDC) * OMGMAX
                ENDIF
            ENDIF
            ICOMP = ICOMP + 1
            IF (ICOMP.GT.NBRSS) THEN
               CALL UTMESS('A',NOMCMD,'TROP DE RE-AJUSTEMENT '//
     +         'DE LA BORNE MAXIMALE.')
            ELSE
               IF (TYPRES.EQ.'DYNAMIQUE') THEN
                WRITE(6,1900) (PRECDC*100.D0),FREQOM(OMGMAX)
               ELSE
                WRITE(6,3900) (PRECDC*100.D0),OMGMAX
               ENDIF
               GOTO 20
            ENDIF
         ENDIF
C
C     --- IMPRESSION DU NOMBRE DE FREQUENCE DANS LA BORNE ---
      CALL VPECST(IFR,TYPRES,OMGMIN,OMGMAX,PIVOT1,PIVOT2,
     +            NBFREQ,NBLAGR)
C
      CALL DETRSD('MATR_ASSE',DYNAM)

      CALL JEDETC('V','&&OP0032',1)
      CALL JEDEMA()

 1600 FORMAT('LA BORNE MINIMALE EST INFERIEURE A LA FREQUENCE ',
     +       'DE CORPS RIGIDE ON LA MODIFIE, ELLE DEVIENT',1PE12.5)
 1700 FORMAT('ON DIMINUE LA BORNE MINIMALE DE: ',1PE12.5,' POURCENTS',/,
     +        'LA BORNE MINIMALE DEVIENT: ',6X,1PE12.5)
 1800 FORMAT('LA BORNE MAXIMALE EST INFERIEURE A LA FREQUENCE ',
     +       'DE CORPS RIGIDE ON LA MODIFIE, ELLE DEVIENT: ',1PE12.5)
 1900 FORMAT('ON AUGMENTE LA BORNE MAXIMALE DE: ',1PE12.5,' POURCENTS',/
     +       ,'LA BORNE MAXIMALE DEVIENT:',8X,1PE12.5,/)
 3600 FORMAT('LA BORNE MINIMALE EST INFERIEURE A LA CHARGE CRITIQUE ',
     +       'NULLE ON LA MODIFIE, ELLE DEVIENT',1PE12.5)
 3700 FORMAT('ON DIMINUE LA BORNE MINIMALE DE: ',1PE12.5,' POURCENTS',/,
     +        'LA BORNE MINIMALE DEVIENT: ',6X,1PE12.5)
 3800 FORMAT('LA BORNE MAXIMALE EST INFERIEURE A LA CHARGE CRITIQUE ',
     +       'NULLE ON LA MODIFIE, ELLE DEVIENT: ',1PE12.5)
 3900 FORMAT('ON AUGMENTE LA BORNE MAXIMALE DE: ',1PE12.5,' POURCENTS',/
     +       ,'LA BORNE MAXIMALE DEVIENT:',8X,1PE12.5,/)
      END
