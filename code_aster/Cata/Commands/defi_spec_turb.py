# coding=utf-8
# ======================================================================
# COPYRIGHT (C) 1991 - 2017  EDF R&D                  WWW.CODE-ASTER.ORG
# THIS PROGRAM IS FREE SOFTWARE; YOU CAN REDISTRIBUTE IT AND/OR MODIFY
# IT UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICENSE AS PUBLISHED BY
# THE FREE SOFTWARE FOUNDATION; EITHER VERSION 2 OF THE LICENSE, OR
# (AT YOUR OPTION) ANY LATER VERSION.
#
# THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT
# WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF
# MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. SEE THE GNU
# GENERAL PUBLIC LICENSE FOR MORE DETAILS.
#
# YOU SHOULD HAVE RECEIVED A COPY OF THE GNU GENERAL PUBLIC LICENSE
# ALONG WITH THIS PROGRAM; IF NOT, WRITE TO EDF R&D CODE_ASTER,
#    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
# ======================================================================
# person_in_charge: hassan.berro at edf.fr
from code_aster.Cata.Syntax import *
from code_aster.Cata.DataStructure import *
from code_aster.Cata.Commons import *


DEFI_SPEC_TURB=OPER(nom="DEFI_SPEC_TURB",op= 145,sd_prod=spectre_sdaster,
                    fr=tr("Definition d'un spectre d'excitation turbulente"),
                    reentrant='n',
         regles=(UN_PARMI('SPEC_LONG_COR_1','SPEC_LONG_COR_2','SPEC_LONG_COR_3',
                          'SPEC_LONG_COR_4','SPEC_CORR_CONV_1','SPEC_CORR_CONV_2',
                          'SPEC_CORR_CONV_3','SPEC_FONC_FORME','SPEC_EXCI_POINT'),),
         SPEC_LONG_COR_1 =FACT(statut='f',
           LONG_COR        =SIMP(statut='o',typ='R' ),
           PROF_VITE_FLUI  =SIMP(statut='o',typ=(fonction_sdaster,nappe_sdaster,formule) ),
           VISC_CINE       =SIMP(statut='o',typ='R' ),
         ),
         SPEC_LONG_COR_2 =FACT(statut='f',
           regles=(ENSEMBLE('FREQ_COUP','PHI0','BETA' ),),
           LONG_COR        =SIMP(statut='o',typ='R' ),
           PROF_VITE_FLUI  =SIMP(statut='o',typ=(fonction_sdaster,nappe_sdaster,formule) ),
           FREQ_COUP       =SIMP(statut='f',typ='R',defaut= 0.1 ),
           PHI0            =SIMP(statut='f',typ='R',defaut= 1.5E-3 ),
           BETA            =SIMP(statut='f',typ='R',defaut= 2.7 ),
         ),
         SPEC_LONG_COR_3 =FACT(statut='f',
           regles=(ENSEMBLE('PHI0_1','BETA_1','PHI0_2','BETA_2','FREQ_COUP'),),
           LONG_COR        =SIMP(statut='o',typ='R' ),
           PROF_VITE_FLUI  =SIMP(statut='o',typ=(fonction_sdaster,nappe_sdaster,formule) ),
           FREQ_COUP       =SIMP(statut='f',typ='R',defaut= 0.2 ),
           PHI0_1          =SIMP(statut='f',typ='R',defaut= 5.E-3 ),
           BETA_1          =SIMP(statut='f',typ='R',defaut= 0.5 ),
           PHI0_2          =SIMP(statut='f',typ='R',defaut= 4.E-5 ),
           BETA_2          =SIMP(statut='f',typ='R',defaut= 3.5 ),
         ),
         SPEC_LONG_COR_4 =FACT(statut='f',
           regles=(ENSEMBLE('BETA','GAMMA'),),
           LONG_COR        =SIMP(statut='o',typ='R' ),
           PROF_VITE_FLUI  =SIMP(statut='o',typ=(fonction_sdaster,nappe_sdaster,formule) ),
           TAUX_VIDE       =SIMP(statut='o',typ='R' ),
           BETA            =SIMP(statut='f',typ='R',defaut= 2. ),
           GAMMA           =SIMP(statut='f',typ='R',defaut= 4. ),
         ),
         SPEC_CORR_CONV_1=FACT(statut='f',
           LONG_COR_1      =SIMP(statut='o',typ='R' ),
           LONG_COR_2      =SIMP(statut='f',typ='R' ),
           VITE_FLUI       =SIMP(statut='o',typ='R' ),
           RHO_FLUI        =SIMP(statut='o',typ='R' ),
           FREQ_COUP       =SIMP(statut='f',typ='R' ),
           K               =SIMP(statut='f',typ='R',defaut= 5.8E-3 ),
           D_FLUI          =SIMP(statut='o',typ='R' ),
           COEF_VITE_FLUI_A=SIMP(statut='f',typ='R' ),
           COEF_VITE_FLUI_O=SIMP(statut='f',typ='R' ),
           METHODE         =SIMP(statut='f',typ='TXM',defaut="GENERALE",
                                 into=("AU_YANG","GENERALE","CORCOS") ),
         ),
         SPEC_CORR_CONV_2=FACT(statut='f',
           FONCTION        =SIMP(statut='o',typ=(fonction_sdaster,nappe_sdaster,formule) ),
           VITE_FLUI       =SIMP(statut='o',typ='R' ),
           FREQ_COUP       =SIMP(statut='f',typ='R' ),
           METHODE         =SIMP(statut='f',typ='TXM',defaut="GENERALE",
                                 into=("AU_YANG","GENERALE","CORCOS",) ),
           COEF_VITE_FLUI_A=SIMP(statut='f',typ='R' ),
           COEF_VITE_FLUI_O=SIMP(statut='f',typ='R' ),
         ),
         SPEC_CORR_CONV_3=FACT(statut='f',
           TABLE_FONCTION  =SIMP(statut='o',typ=(table_fonction) ),
         ),
         SPEC_FONC_FORME =FACT(statut='f',
           regles=(UN_PARMI('INTE_SPEC','GRAPPE_1'),
                   ENSEMBLE('INTE_SPEC','FONCTION'),
                   UN_PARMI('NOEUD','GROUP_NO'),
                   EXCLUS('NOEUD','GROUP_NO'),),
           INTE_SPEC       =SIMP(statut='f',typ=interspectre),
           FONCTION        =SIMP(statut='f',typ=(table_fonction),max='**'),
           GRAPPE_1        =SIMP(statut='f',typ='TXM',into=("DEBIT_180","DEBIT_300",) ),
           NOEUD           =SIMP(statut='c',typ=no),
           GROUP_NO        =SIMP(statut='f',typ=grno),
           CARA_ELEM       =SIMP(statut='o',typ=cara_elem ),
           MODELE          =SIMP(statut='o',typ=modele_sdaster ),
         ),
         SPEC_EXCI_POINT =FACT(statut='f',
           regles=(UN_PARMI('INTE_SPEC','GRAPPE_2'),),
           INTE_SPEC       =SIMP(statut='f',typ=interspectre),
           GRAPPE_2        =SIMP(statut='f',typ='TXM',
                                 into=("ASC_CEN","ASC_EXC","DES_CEN","DES_EXC",) ),
#  Quels sont les statuts des mots cles a l interieur des deux blocs qui suivent
           b_inte_spec =BLOC(condition = """exists("INTE_SPEC")""",
             regles=(UN_PARMI('NOEUD','GROUP_NO'),
                     EXCLUS('NOEUD','GROUP_NO'),),
             NATURE          =SIMP(statut='o',typ='TXM',max='**',into=("FORCE","MOMENT",) ),
             ANGLE           =SIMP(statut='o',typ='R',max='**'),
             NOEUD           =SIMP(statut='c',typ=no,max='**'),
             GROUP_NO        =SIMP(statut='f',typ=grno,max='**'),
           ),
           b_grappe_2      =BLOC(condition = """exists("GRAPPE_2")""",
             regles=(UN_PARMI('NOEUD','GROUP_NO'),
                     EXCLUS('NOEUD','GROUP_NO'),),
             RHO_FLUI        =SIMP(statut='o',typ='R' ),
             NOEUD           =SIMP(statut='c',typ=no),
             GROUP_NO        =SIMP(statut='f',typ=grno),
           ),
           CARA_ELEM       =SIMP(statut='o',typ=cara_elem ),
           MODELE          =SIMP(statut='o',typ=modele_sdaster ),
         ),
         TITRE           =SIMP(statut='f',typ='TXM'),
);
