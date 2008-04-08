      SUBROUTINE MECALC(OPTION,MODELE,CHDEPL,CHGEOM,CHMATE,CHCARA,
     &                  CHTEMP,CHTREF,CHTIME,CHNUMC,CHHARM,CHSIG,CHEPS,
     &                  CHFREQ,CHMASS,CHMETA,CHARGE,TYPCOE,ALPHA,CALPHA,
     &                  CHDYNR,SUROPT,CHELEM,LIGREL,BASE,CH1,CH2,
     &                  CHVARI,COMPOR,CHTESE,CHDESE,NOPASE,
     &                  TYPESE,CHACSE,CODRET)
C ----------------------------------------------------------------------
C MODIF CALCULEL  DATE 08/04/2008   AUTEUR MEUNIER S.MEUNIER 
C TOLE CRP_20 CRP_21
C ======================================================================
C COPYRIGHT (C) 1991 - 2001  EDF R&D                  WWW.CODE-ASTER.ORG
C THIS PROGRAM IS FREE SOFTWARE; YOU CAN REDISTRIBUTE IT AND/OR MODIFY
C IT UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICENSE AS PUBLISHED BY
C THE FREE SOFTWARE FOUNDATION; EITHER VERSION 2 OF THE LICENSE, OR
C (AT YOUR OPTION) ANY LATER VERSION.

C THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT
C WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF
C MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. SEE THE GNU
C GENERAL PUBLIC LICENSE FOR MORE DETAILS.

C YOU SHOULD HAVE RECEIVED A COPY OF THE GNU GENERAL PUBLIC LICENSE
C ALONG WITH THIS PROGRAM; IF NOT, WRITE TO EDF R&D CODE_ASTER,
C    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================
C     - FONCTION REALISEE : APPEL A "CALCUL"
C                           CALCUL DES CONTRAINTES ELEMENTAIRES
C                           CALCUL DES EFFORTS ELEMENTAIRES
C                           CALCUL DES ENERGIES ELEMENTAIRES
C ----------------------------------------------------------------------
C IN  : OPTION : OPTION DE CALCUL
C IN  : MODELE : NOM DU MODELE
C IN  : CH...  : NOM DES CHAMPS ...
C IN  : CHARGE : NOM D'UNE CHARGE
C IN  : TYPCOE : TYPE DU COEFFICIENT MULTIPLICATIF DE LA CHARGE
C                SI TYPCOE = R ALORS ALPHA  EST CE COEFFICIENT
C                SI TYPCOE = C ALORS C'EST CALPHA LE COEFFICIENT
C IN  : BASE   : BASE OU EST CREE LE CHAMELEM
C IN  : COMPOR : NOM DE LA CARTE DE COMPORTEMENT
C IN  : CHTESE : CHAMP DE LA TEMPERATURE SENSIBLE
C IN  : CHDESE : CHAMP DU DEPLACEMENT SENSIBLE
C IN  : NOPASE : NOM DU PARAMETRE SENSIBLE
C IN  : TYPESE : TYPE DE PARAMETRE SENSIBLE
C OUT : CHELEM : CHAMELEM RESULTAT
C OUT : CODRET : CODE DE RETOUR (0 SI TOUT VA BIEN)
C   -------------------------------------------------------------------
C     ASTER INFORMATIONS:
C       15/05/02 (OB): CALCUL DE LA SENSIBILITE DU FLUX THERMIQUE +
C                      MODIFS FORMELLES (INDENTATION...)
C----------------------------------------------------------------------
C CORPS DU PROGRAMME
      IMPLICIT NONE

C PARAMETRES D'APPELS
      CHARACTER*(*) OPTION,MODELE,CHDEPL,CHDYNR,SUROPT,CHELEM,COMPOR,
     &              CHGEOM,CHMATE,CHCARA(*),CHFREQ,CHMASS,CHSIG,CHTEMP,
     &              CHTREF,CHTIME,CHNUMC,CHHARM,CHARGE,CHEPS,CHMETA,
     &              TYPCOE,LIGREL,BASE,CH1,CH2,CHVARI,CHACSE,
     &              CHDESE,CHTESE,NOPASE
      REAL*8 ALPHA,R8B
      COMPLEX*16 CALPHA,C16B
      INTEGER TYPESE,CODRET
      CHARACTER*6 NOMPRO
      PARAMETER (NOMPRO='MECALC')

      INTEGER MAXIN
      PARAMETER (MAXIN=62)

      CHARACTER*1 BASE2
      CHARACTER*8 POUX,NOMODE,LPAIN(MAXIN),LPAOUT(1),NOMGD,CAREL,MATERI,
     &            MATERS,NOMA
      CHARACTER*16 OPTIO2,VARI
      CHARACTER*19 CANBSP,CANBVA
      CHARACTER*24 VALK
      CHARACTER*24 LCHIN(MAXIN),LCHOUT(1),CHDEP2,CHELE2,CHC,CHTHET,
     &             MATSEN,CHNOVA
      INTEGER IAUX,IBID,IRET1,IRET2,IER,NB,NBIN,IFM,NIV,IRET
      INTEGER I1,I2,INDIK8
      LOGICAL INDMEC

      CHDEP2 = CHDEPL
      CHELE2 = CHELEM
      CODRET = 0

      BASE2 = BASE
      NOMODE = MODELE
      OPTIO2 = OPTION
      CHNOVA = '&&MECALC.NOVARI'
      CALL INFNIV(IFM,NIV)
      DO 10,IAUX = 1,MAXIN
        LPAIN(IAUX) = ' '
        LCHIN(IAUX) = ' '
   10 CONTINUE


      NBIN = 1
      LCHIN(1) = CHDEP2
      LCHOUT(1) = CHELE2
      POUX = 'NON'

      IF (TYPESE.EQ.-1) THEN
        IAUX = 0
        CALL RSEXC2(1,1,NOPASE,'THETA',IAUX,CHTHET,OPTIO2,CODRET)
      END IF

      IF (CODRET.EQ.0) THEN

C     -- ON DONNE LES INFOS NECESSAIRES POUR CREER UN CHAM_ELEM
C        AYANT DES SOUS-POINTS ET/OU DES CMPS DYN. DE VARI_R
C     ---------------------------------------------------------
        CAREL = CHCARA(1)
        IF (OPTIO2.EQ.'VARI_ELNO_ELGA') THEN
          CALL EXISD('CARTE',COMPOR,IRET2)
          IF (IRET2.NE.1) THEN
            CALL U2MESS('A','CALCULEL2_86')
            GO TO 40
          END IF
          CANBVA = '&&'//NOMPRO//'.NBVAR'
C         LA CARTE COMPOR PEUT CHANGER ENTRE DEUX INSTANTS
C         IL FAUT DONC APPELER CESVAR SYSTEMATIQUEMENT
          CALL CESVAR(CAREL,COMPOR,LIGREL,CANBVA)
          CALL COPISD('CHAM_ELEM_S','V',CANBVA,CHELE2)
          CALL DETRSD('CHAM_ELEM_S',CANBVA)

        ELSE IF (OPTIO2.EQ.'VARI_ELNO_TUYO') THEN
          CALL EXISD('CARTE',COMPOR,IRET2)
          IF (IRET2.NE.1) THEN
            CALL U2MESS('A','CALCULEL2_86')
            GO TO 40
          END IF
          CANBVA = '&&'//NOMPRO//'.NBVARI'
C         LA CARTE COMPOR PEUT CHANGER ENTRE DEUX INSTANTS
C         IL FAUT DONC APPELER CESVAR SYSTEMATIQUEMENT
          CALL CESVAR(' ',COMPOR,LIGREL,CANBVA)
          CALL COPISD('CHAM_ELEM_S','V',CANBVA,CHELE2)
          CALL DETRSD('CHAM_ELEM_S',CANBVA)

         ELSE IF (OPTIO2.EQ.'VARI_ELNO_COQU') THEN
          CALL EXISD('CARTE',COMPOR,IRET2)
          IF (IRET2.NE.1) THEN
            CALL U2MESS('A','CALCULEL2_86')
            GO TO 40
          END IF
          CANBVA = '&&'//NOMPRO//'.NBVARI'
C         LA CARTE COMPOR PEUT CHANGER ENTRE DEUX INSTANTS
C         IL FAUT DONC APPELER CESVAR SYSTEMATIQUEMENT
          CALL CESVAR(' ',COMPOR,LIGREL,CANBVA)
          CALL COPISD('CHAM_ELEM_S','V',CANBVA,CHELE2)
          CALL DETRSD('CHAM_ELEM_S',CANBVA)

        ELSE IF ((OPTIO2.EQ.'EPSI_ELGA_DEPL') .OR.
     &           (OPTIO2.EQ.'SIEF_ELGA_DEPL')) THEN
          CANBSP = '&&'//NOMPRO//'.NBSP'
          CALL EXISD('CHAM_ELEM_S',CANBSP,IRET1)
          IF (IRET1.NE.1) CALL CESVAR(CAREL,' ',LIGREL,CANBSP)
          CALL COPISD('CHAM_ELEM_S','V',CANBSP,CHELE2)

        ELSE IF ((OPTIO2.EQ.'EQUI_ELGA_SIGM') .OR.
     &           (OPTIO2.EQ.'EQUI_ELGA_EPSI')) THEN
          CANBSP = '&&'//NOMPRO//'.NBSP'
          CALL EXISD('CHAM_ELEM_S',CANBSP,IRET1)
          IF (IRET1.NE.1) CALL CESVAR(CAREL,' ',LIGREL,CANBSP)
          CALL COPISD('CHAM_ELEM_S','V',CANBSP,CHELE2)

        END IF


C     -- SI CHDEPL EST UN CHAMP DE VARI_R, ON VERIFIE SA
C        COHERENCE AVEC COMPOR.
C     ---------------------------------------------------------
        CALL EXISD('CHAMP_GD',CHDEPL,IRET1)
        IF (IRET1.EQ.1) THEN
          CALL DISMOI('F','NOM_GD',CHDEPL,'CHAMP',IBID,NOMGD,IER)
          IF (NOMGD.EQ.'VARI_R') THEN
            CALL EXISD('CHAM_ELEM_S',COMPOR,IRET2)
            IF (IRET2.NE.1) CALL CESVAR(CAREL,COMPOR,LIGREL,COMPOR)
            CALL VRCOMP(' ',COMPOR,CHDEPL)
          END IF
        END IF


C -------------------
        INDMEC = .TRUE.
C ----------------------------------------------------------------------
        IF (OPTIO2.EQ.'VARI_ELNO_ELGA') THEN
          LPAIN(1) = 'PVARIGR'
          LPAOUT(1) = 'PVARINR'
        ELSE IF (OPTIO2.EQ.'INDI_LOCA_ELGA') THEN
           CALL AJCHCA('PMATERC',CHMATE,LPAIN,LCHIN,NBIN,MAXIN,'N')
           CALL AJCHCA('PCOMPOR',COMPOR,LPAIN,LCHIN,NBIN,MAXIN,'N')
           CALL AJCHCA('PVARIPR',CHDEPL,LPAIN,LCHIN,NBIN,MAXIN,'N')
           CALL AJCHCA('PCONTPR',CHSIG, LPAIN,LCHIN,NBIN,MAXIN,'N')
           LPAOUT(1) = 'PINDLOC'
        ELSE IF (OPTIO2.EQ.'CRIT_ELNO_RUPT') THEN
          LPAIN(1) = 'PCONCOR'
          LPAOUT(1) = 'PCRITER'
        ELSE IF (OPTIO2.EQ.'VARI_ELNO_TUYO') THEN
          LPAIN(1) = 'PVARIGR'
          LPAOUT(1) = 'PVARINR'
        ELSE IF (OPTIO2.EQ.'VARI_ELNO_COQU') THEN
          LPAIN(1) = 'PVARIGR'
          LPAOUT(1) = 'PVARINR'
        ELSE IF (OPTIO2.EQ.'SIGM_ELNO_CART') THEN
          LPAIN(1) = 'PCONTRR'
          LPAOUT(1) = 'PCONTGL'
        ELSE IF (OPTIO2.EQ.'VNOR_ELEM_DEPL') THEN
          LPAIN(1) = 'PDEPLAC'
          LPAOUT(1) = 'PVITNOR'
        ELSE IF (OPTIO2.EQ.'EFGE_ELNO_CART') THEN
CJMP    LPAIN(1) = 'PCONTRR'
CJMP    IL VAUDRAIT MIEUX HOMOGENEISER LE NOM DU PARAMETRE POUR
CJMP    LE CHAMP DE CONTRAINTES EN PSIEFNOR ET PASSER CELUI-CI
CJMP    DANS CHSIG. CELA IMPLIQUE DE MODIFIER LES CATALOGUES
CJMP    DES ELEMETNS DE POUTRE ET DES DISCRETS POUR FAIRE COMME
CJMP    LES CABLES QUI SONT CORRECTS
CJMP    POUR LE MOMENT ON PASSE A LA FOIS LE CHAMP DEPL CI-DESSOUS
CJMP    PUIS LE CHAMPS CHSIG ASSOCIE A LA FOIS A PCONTRR ET PSIEFNOR
          LPAIN(1) = 'PDEPLAR'
          LPAOUT(1) = 'PEFFORR'
        ELSE IF (OPTIO2.EQ.'DETE_ELNO_DLTE') THEN
          LPAIN(1) = 'PTEMPER'
          LPAOUT(1) = 'PDETENO'
          INDMEC = .FALSE.
        ELSE IF (OPTIO2.EQ.'DEDE_ELNO_DLDE') THEN
          LPAIN(1) = 'PDEPLAR'
          LPAOUT(1) = 'PDEDENO'
        ELSE IF (OPTIO2.EQ.'DLSI_ELGA_DEPL') THEN
          LPAIN(1) = 'PDEPLAR'
          LPAOUT(1) = 'PDLAGSG'
        ELSE IF (OPTIO2.EQ.'DESI_ELNO_DLSI') THEN
          LPAIN(1) = 'PDLAGSI'
          LPAOUT(1) = 'PDESINO'
        ELSE IF (OPTIO2.EQ.'ENEL_ELGA' .OR.
     &           OPTIO2.EQ.'ENEL_ELNO_ELGA') THEN
          LPAOUT(1) = 'PENERDR'
        ELSE IF (OPTIO2.EQ.'EQUI_ELNO_SIGM' .OR.
     &           OPTIO2.EQ.'EQUI_ELGA_SIGM' .OR.
     &           OPTIO2.EQ.'PMPB_ELGA_SIEF' .OR.
     &           OPTIO2.EQ.'PMPB_ELNO_SIEF') THEN
          LPAOUT(1) = 'PCONTEQ'
        ELSE IF (OPTIO2.EQ.'EQUI_ELNO_EPSI' .OR.
     &           OPTIO2.EQ.'EQUI_ELGA_EPSI' .OR.
     &           OPTIO2.EQ.'EQUI_ELNO_EPME' .OR.
     &           OPTIO2.EQ.'EQUI_ELGA_EPME') THEN
          LPAIN(1) = 'PDEFORR'
          LCHIN(1) = CHEPS
          LPAOUT(1) = 'PDEFOEQ'
        ELSE IF (OPTIO2.EQ.'ARCO_ELNO_SIGM') THEN
          LPAIN(1) = 'PSIG3D'
          LCHIN(1) = CHSIG
          LPAIN(2) = 'PCAMASS'
          LCHIN(2) = CHEPS
          LPAIN(3) = 'PGEOMER'
          LCHIN(3) = CHGEOM
          NBIN = 3
          LPAOUT(1) = 'PARCCON'
        ELSE
          LPAIN(1) = 'PDEPLAR'
          IF (OPTIO2.EQ.'SIGM_ELNO_COQU') THEN
            LPAIN(1) = 'PVARINR'
            LPAOUT(1) = 'PSIGNOD'
          ELSE IF (OPTIO2.EQ.'SIGM_ELNO_TUYO') THEN
            LPAIN(1) = 'PVARINR'
            LPAOUT(1) = 'PSIGNOD'
          ELSE IF (OPTIO2.EQ.'SIEF_ELNO_ELGA') THEN
            LPAIN(1) = 'PDEPLPR'
            LPAOUT(1) = 'PSIEFNOR'
          ELSE IF (OPTIO2.EQ.'DEGE_ELNO_DEPL') THEN
            LPAOUT(1) = 'PDEFOGR'
          ELSE IF (OPTIO2.EQ.'EPSI_ELNO_DEPL' .OR.
     &             OPTIO2.EQ.'EPSI_ELGA_DEPL' .OR.
     &             OPTIO2.EQ.'EPSG_ELNO_DEPL' .OR.
     &             OPTIO2.EQ.'EPSG_ELGA_DEPL' .OR.
     &             OPTIO2.EQ.'EPME_ELNO_DEPL' .OR.
     &             OPTIO2.EQ.'EPME_ELGA_DEPL' .OR.
     &             OPTIO2.EQ.'EPMG_ELNO_DEPL' .OR.
     &             OPTIO2.EQ.'EPMG_ELGA_DEPL' .OR.
     &             OPTIO2.EQ.'EPFP_ELGA'      .OR.
     &             OPTIO2.EQ.'EPFP_ELNO'      .OR.
     &             OPTIO2.EQ.'EPFD_ELGA'      .OR.
     &             OPTIO2.EQ.'EPFD_ELNO'      ) THEN
            LPAOUT(1) = 'PDEFORR'
          ELSE IF (OPTIO2.EQ.'EPSP_ELNO' .OR.
     &             OPTIO2.EQ.'EPSP_ELGA') THEN
            LPAOUT(1) = 'PDEFOPL'
          ELSE IF (OPTIO2.EQ.'EPVC_ELNO' .OR.
     &             OPTIO2.EQ.'EPVC_ELGA') THEN
            LPAOUT(1) = 'PDEFOVC'
          ELSE IF (OPTIO2.EQ.'EPOT_ELEM_DEPL' .OR.
     &             OPTIO2.EQ.'EPOT_ELEM_TEMP') THEN
            LPAOUT(1) = 'PENERDR'
          ELSE IF (OPTIO2.EQ.'ECIN_ELEM_DEPL') THEN
            LPAOUT(1) = 'PENERCR'
          ELSE IF (OPTIO2.EQ.'EPSI_ELNO_TUYO') THEN
            LPAIN(1) = 'PDEFORR'
            LCHIN(1) =  CHEPS
            LPAOUT(1) = 'PDEFONO'
          ELSE IF (OPTIO2.EQ.'EPEQ_ELNO_TUYO') THEN
            LPAIN(1) = 'PDEFOEQ'
            LCHIN(1) =  CH2
            LPAOUT(1) = 'PDENOEQ'
          ELSE IF (OPTIO2.EQ.'SIEQ_ELNO_TUYO') THEN
            LPAIN(1) = 'PCONTEQ'
            LCHIN(1) =  CH1
            LPAOUT(1) = 'PCOEQNO'
          ELSE IF (OPTIO2.EQ.'FLUX_ELNO_TEMP' .OR.
     &             OPTIO2.EQ.'FLUX_ELGA_TEMP') THEN
            LPAOUT(1) = 'PFLUX_R'
            INDMEC = .FALSE.
          ELSE IF (OPTIO2.EQ.'SOUR_ELGA_ELEC') THEN
            LPAOUT(1) = 'PSOUR_R'
          ELSE IF (OPTIO2.EQ.'DURT_ELGA_META' .OR.
     &             OPTIO2.EQ.'DURT_ELNO_META') THEN
            LPAIN(1) = 'PPHASIN'
            LCHIN(1) = CHMETA
            LPAOUT(1) = 'PDURT_R'
          ELSE IF (OPTIO2.EQ.'EPME_ELNO_DPGE' .OR.
     &             OPTIO2.EQ.'EPSI_ELNO_DPGE') THEN
            LPAOUT(1) = 'PDEFORR'
          ELSE IF (OPTIO2.EQ.'SIGM_ELNO_DPGE' .OR.
     &             OPTIO2.EQ.'SIEF_ELGA_DPGE') THEN
            LPAOUT(1) = 'PCONTRR'
          ELSE IF (OPTIO2.EQ.'VALE_NCOU_MAXI') THEN
            LPAIN(1) = 'PCONTRR'
            LPAIN(2) = 'PDEFORR'
            LPAIN(3) = 'PCONTEQ'
            LPAIN(4) = 'PDEFOEQ'
            LPAIN(5) = 'PNOMCMP'
            LCHIN(1) = CHSIG
            LCHIN(2) = CHEPS
            LCHIN(3) = CH1
            LCHIN(4) = CH2
            LCHIN(5) = CHNUMC
            NBIN = 5
            LPAOUT(1) = 'PMINMAX'
          ELSE IF (OPTIO2.EQ.'EXTR_ELGA_VARI') THEN
             NOMA=CHGEOM(1:8)
             CALL GETVTX(' ','NOM_VARI',0,1,1,VARI,IBID)
             CALL MECACT('V',CHNOVA,'MAILLA',NOMA,'NEUT_K24',1,'Z1',
     &                                             IBID,R8B,C16B,VARI )

            LPAIN(1) = 'PVARIGR'
            LPAOUT(1) = 'PVARIGS'
            LPAIN(2) = 'PNOVARI'
            LCHIN(2) = CHNOVA
            NBIN =2
          ELSE IF (OPTIO2.EQ.'EXTR_ELNO_VARI') THEN
             NOMA=CHGEOM(1:8)
             CALL GETVTX(' ','NOM_VARI',0,1,1,VARI,IBID)
             CALL MECACT('V',CHNOVA,'MAILLA',NOMA,'NEUT_K24',1,'Z1',
     &                                             IBID,R8B,C16B,VARI )
            LPAIN(1) = 'PVARINR'
            LPAOUT(1) = 'PVARINS'
            LPAIN(2) = 'PNOVARI'
            LCHIN(2) = CHNOVA
            NBIN =2
          ELSE


C ----------------------------------------------------------------------
C                      --- RAJOUT DES POUTRES POUX ---
C ----------------------------------------------------------------------
            CALL DISMOI('F','EXI_POUX',NOMODE,'MODELE',IBID,POUX,IER)
C ----------------------------------------------------------------------
            IF (OPTIO2.EQ.'SIGM_ELNO_DEPL' .OR.
     &          OPTIO2.EQ.'SIPO_ELNO_DEPL' .OR.
     &          OPTIO2.EQ.'SIRE_ELNO_DEPL' .OR.
     &          OPTIO2.EQ.'SIEF_ELGA_DEPL' .OR.
     &          OPTIO2.EQ.'SIGM_ELNO_SIEF' .OR.
     &          OPTIO2.EQ.'SIPO_ELNO_SIEF') THEN
              LPAOUT(1) = 'PCONTRR'
              IF (POUX.EQ.'OUI') THEN
                CALL MECHPO('&&MECHPO',CHARGE,MODELE,CHDEP2,
     &                      CHDYNR,SUROPT,LPAIN(NBIN+1),LCHIN(NBIN+1),
     &                      NB,TYPCOE,ALPHA,CALPHA)
                NBIN = NBIN + NB
                IF (OPTIO2.EQ.'SIPO_ELNO_DEPL' .OR.
     &              OPTIO2.EQ.'SIPO_ELNO_SIEF') THEN
                  LPAOUT(1) = 'PCONTPO'
                END IF
              END IF
            ELSE IF (OPTIO2.EQ.'SIPO_ELNO_DEPL') THEN
              LPAIN(1) = 'PDEPLAR'
              LPAOUT(1) = 'PCONTRR'
              IF (POUX.EQ.'OUI') THEN
                CALL MECHPO('&&MECHPO',CHARGE,MODELE,CHDEP2,
     &                      CHDYNR,SUROPT,LPAIN(NBIN+1),LCHIN(NBIN+1),
     &                      NB,TYPCOE,ALPHA,CALPHA)
                NBIN = NBIN + NB
                LPAOUT(1) = 'PCONTPC'
              END IF
            ELSE IF (OPTIO2.EQ.'SIGM_ELNO_DEPL') THEN
              LPAIN(1) = 'PDEPLAR'
              LPAOUT(1) = 'PCONTRR'
              IF (POUX.EQ.'OUI') THEN
                CALL MECHPO('&&MECHPO',CHARGE,MODELE,CHDEP2,
     &                      CHDYNR,SUROPT,LPAIN(NBIN+1),LCHIN(NBIN+1),
     &                      NB,TYPCOE,ALPHA,CALPHA)
                NBIN = NBIN + NB
              END IF
            ELSE IF (OPTIO2.EQ.'EFGE_ELNO_DEPL') THEN
              LPAOUT(1) = 'PEFFORR'
              IF (POUX.EQ.'OUI') THEN
                CALL MECHPO('&&MECHPO',CHARGE,MODELE,CHDEP2,
     &                      CHDYNR,SUROPT,LPAIN(NBIN+1),LCHIN(NBIN+1),
     &                      NB,TYPCOE,ALPHA,CALPHA)
                NBIN = NBIN + NB
              END IF
            ELSE IF (OPTIO2.EQ.'EFGE_ELNO_DEPL') THEN
              LPAIN(1) = 'PDEPLAR'
              LPAOUT(1) = 'PEFFORR'
              IF (POUX.EQ.'OUI') THEN
                CALL MECHPO('&&MECHPO',CHARGE,MODELE,CHDEP2,
     &                      CHDYNR,SUROPT,LPAIN(NBIN+1),LCHIN(NBIN+1),
     &                      NB,TYPCOE,ALPHA,CALPHA)
                NBIN = NBIN + NB
              END IF
            ELSE
              VALK = OPTIO2
              CALL U2MESG('F', 'CALCULEL6_10',1,VALK,0,0,0,0.D0)
            END IF
          END IF
        END IF
        CHC = CHGEOM(1:8)//'.ABS_CURV'
        CALL AJCHCA('PABSCUR',CHC,LPAIN,LCHIN,NBIN,MAXIN,'N')
        CALL AJCHCA('PNBSP_I',CAREL//'.CANBSP',LPAIN,LCHIN,NBIN,MAXIN,
     &              'N')
        CALL AJCHCA('PFIBRES',CAREL//'.CAFIBR',LPAIN,LCHIN,NBIN,MAXIN,
     &              'N')

        CALL AJCHCA('PCAARPO',CHCARA(9),LPAIN,LCHIN,NBIN,MAXIN,'N')
        CALL AJCHCA('PCACOQU',CHCARA(7),LPAIN,LCHIN,NBIN,MAXIN,'N')
        CALL AJCHCA('PCADISK',CHCARA(2),LPAIN,LCHIN,NBIN,MAXIN,'N')
        CALL AJCHCA('PCADISM',CHCARA(3),LPAIN,LCHIN,NBIN,MAXIN,'N')
        CALL AJCHCA('PCAGEPO',CHCARA(5),LPAIN,LCHIN,NBIN,MAXIN,'N')
        CALL AJCHCA('PCAGNBA',CHCARA(11),LPAIN,LCHIN,NBIN,MAXIN,'N')
        CALL AJCHCA('PCAGNPO',CHCARA(6),LPAIN,LCHIN,NBIN,MAXIN,'N')
        CALL AJCHCA('PCAMASS',CHCARA(12),LPAIN,LCHIN,NBIN,MAXIN,'N')
        CALL AJCHCA('PCAORIE',CHCARA(1),LPAIN,LCHIN,NBIN,MAXIN,'N')
        CALL AJCHCA('PCAORIR',CHTEMP,LPAIN,LCHIN,NBIN,MAXIN,'N')
        CALL AJCHCA('PCASECT',CHCARA(8),LPAIN,LCHIN,NBIN,MAXIN,'N')
        CALL AJCHCA('PCOMPOR',COMPOR,LPAIN,LCHIN,NBIN,MAXIN,'N')
        CALL AJCHCA('PCONCOR',CHFREQ,LPAIN,LCHIN,NBIN,MAXIN,'N')
        CALL AJCHCA('PCONTRR',CHSIG,LPAIN,LCHIN,NBIN,MAXIN,'N')
C         ON RECUPERE LE NUME_ORDRE DANS LE NOM DU CHAMP
C         DE DEPLACEMENT : 'NOMUTILI.C00.000000'
        CHC = '&&MEGENE.DEF.'//LCHIN(1) (14:19)
        CALL AJCHCA('PDEFORM',CHC,LPAIN,LCHIN,NBIN,MAXIN,'N')
        CALL AJCHCA('PDEFORR',CHEPS,LPAIN,LCHIN,NBIN,MAXIN,'N')
        CALL AJCHCA('PDEPPLU',CHDEP2,LPAIN,LCHIN,NBIN,MAXIN,'N')
        IF (OPTIO2.EQ.'SIGM_ELNO_COQU') CALL AJCHCA('PDEPLAR',CHEPS,
     &      LPAIN,LCHIN,NBIN,MAXIN,'N')
        CALL AJCHCA('PFREQR',CHFREQ,LPAIN,LCHIN,NBIN,MAXIN,'N')
        CALL AJCHCA('PGEOMER',CHGEOM,LPAIN,LCHIN,NBIN,MAXIN,'N')
        CALL AJCHCA('PHARMON',CHHARM,LPAIN,LCHIN,NBIN,MAXIN,'N')
        CALL AJCHCA('PMASDIA',CHMASS,LPAIN,LCHIN,NBIN,MAXIN,'N')
        CALL AJCHCA('PMATERC',CHMATE,LPAIN,LCHIN,NBIN,MAXIN,'N')
        CALL AJCHCA('PNUMCOR',CHNUMC,LPAIN,LCHIN,NBIN,MAXIN,'N')
        CALL AJCHCA('PPHASIN',CHMETA,LPAIN,LCHIN,NBIN,MAXIN,'N')
        CALL AJCHCA('PSIEFNOR',CHSIG,LPAIN,LCHIN,NBIN,MAXIN,'N')
        CALL AJCHCA('PVARCRR',CH2,LPAIN,LCHIN,NBIN,MAXIN,'N')
        CALL AJCHCA('PVARCPR',CH1,LPAIN,LCHIN,NBIN,MAXIN,'N')
        CALL AJCHCA('PVARIGR',CHVARI,LPAIN,LCHIN,NBIN,MAXIN,'N')
        CALL AJCHCA('PVARIGS',CHVARI,LPAIN,LCHIN,NBIN,MAXIN,'N')

        IF (CHTEMP.NE.' ') THEN
            CALL AJCHCA('PTEMPER',CHTEMP,LPAIN,LCHIN,NBIN,MAXIN,'N')
        END IF
        CALL AJCHCA('PTEMPSR',CHTIME,LPAIN,LCHIN,NBIN,MAXIN,'N')
        CALL AJCHCA('PTEREF',CHTREF,LPAIN,LCHIN,NBIN,MAXIN,'N')


        IF (TYPESE.EQ.-1) THEN
C         -- DERIVEE LAGRANGIENNE
          CALL AJCHCA('PDLAGDE',CHDESE,LPAIN,LCHIN,NBIN,MAXIN,'N')
          IF (OPTION.EQ.'DLSI_ELGA_DEPL') THEN
            CALL AJCHCA('PVARCMR',CHTESE,LPAIN,LCHIN,NBIN,MAXIN,'N')
          ELSEIF (OPTION.EQ.'DLSI_ELNO_DLDE') THEN
            CALL AJCHCA('PVARCMR',CHTESE,LPAIN,LCHIN,NBIN,MAXIN,'N')
          ELSE
            CALL AJCHCA('PDLAGTE',CHTESE,LPAIN,LCHIN,NBIN,MAXIN,'N')
          ENDIF
          CALL AJCHCA('PVECTTH',CHTHET,LPAIN,LCHIN,NBIN,MAXIN,'N')

        ELSE IF (TYPESE.EQ.3) THEN
          IF (OPTIO2(1:4).EQ.'EPSI') GO TO 20
          IF (OPTIO2(11:14).EQ.'ELGA') GO TO 20
C         -- SENSIBILITE PAR RAPPORT A UNE CARACTERISTIQUE MATERIAU
C            DETERMINATION DU CHAMP MATERIAU A PARTIR DE LA CARTE CODEE
          MATERI = CHMATE(1:8)
C         -- DETERMINATION DU CHAMP MATERIAU DERIVE NON CODE MATSEN
          CALL PSGENC(MATERI,NOPASE,MATERS,IRET)
          IF (IRET.NE.0) THEN
            CALL U2MESK('A','CALCULEL2_87',1,MATERI)
            GO TO 40
          END IF
C         -- TRANSFORMATION EN CHAMP MATERIAU DERIVE CODE
          MATSEN = ' '
          MATSEN(1:24) = MATERS(1:8)//CHMATE(9:24)
C         -- ON RAJOUTE LPAIN LIES AU MATERIAU ET AU CHAMP DERIVES
          CALL AJCHCA('PMATSEN',MATSEN,LPAIN,LCHIN,NBIN,MAXIN,'N')
          IF (INDMEC) THEN
            CALL AJCHCA('PDEPSEN',CHDESE,LPAIN,LCHIN,NBIN,MAXIN,'N')
            CALL AJCHCA('PACCSEN',CHACSE,LPAIN,LCHIN,NBIN,MAXIN,'N')
          ELSE
            CALL AJCHCA('PTEMSEN',CHTESE,LPAIN,LCHIN,NBIN,MAXIN,'N')
          END IF
C         -- REDEFINITION DE L'OPTION
          OPTIO2(1:14) = OPTIO2(1:10)//'SENS'
          IF (OPTIO2(1:4).NE.'FLUX') THEN
C           -- GLUTE MECALM.F : IL FAUT PERMUTER PDEPLAR ET PDEPSEN
            I1=INDIK8(LPAIN,'PDEPSEN',1,NBIN)
            CALL ASSERT(I1.GT.0 .AND. I1.LE.NBIN)
            I2=INDIK8(LPAIN,'PDEPLAR',1,NBIN)
            CALL ASSERT(I2.GT.0 .AND. I2.LE.NBIN)
            LPAIN(I1)='PDEPLAR'
            LPAIN(I2)='PDEPSEN'
          ENDIF
   20     CONTINUE
        END IF

        CALL MECEUC('C',POUX,OPTIO2,LIGREL,NBIN,LCHIN,LPAIN,1,
     &              LCHOUT,LPAOUT,BASE2)
        CALL EXISD('CHAMP_GD',LCHOUT(1),IRET)
        IF (IRET.EQ.0) THEN
          CODRET = 1
          CALL U2MESK('A','CALCULEL2_88',1,OPTIO2)
        END IF
C     MENAGE :
C     -------
        IF (POUX.EQ.'OUI') CALL JEDETC('V','&&MECHPO',1)
        CALL DETRSD('CHAM_ELEM_S',CHELE2)
        CALL JEDETC ('V',CHNOVA,1)

      END IF
   40 CONTINUE
      END
