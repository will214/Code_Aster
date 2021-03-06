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
# person_in_charge: mickael.abbas at edf.fr
from code_aster.Cata.Syntax import *
from code_aster.Cata.DataStructure import *
from code_aster.Cata.Commons import *


THER_NON_LINE_MO=OPER(nom="THER_NON_LINE_MO",op= 171,sd_prod=evol_ther,
                     fr=tr("Résoudre un problème thermique non linéaire (conditions limites ou comportement matériau)"
                        " stationnaire avec chargement mobile"),
                     reentrant='n',
         MODELE          =SIMP(statut='o',typ=modele_sdaster ),
         CHAM_MATER      =SIMP(statut='o',typ=cham_mater ),
         CARA_ELEM       =SIMP(statut='c',typ=cara_elem ),
         EXCIT           =FACT(statut='o',max='**',
           CHARGE          =SIMP(statut='o',typ=char_ther ),
           FONC_MULT       =SIMP(statut='c',typ=(fonction_sdaster,nappe_sdaster,formule) ),
         ),
         ETAT_INIT       =FACT(statut='f',
           EVOL_THER       =SIMP(statut='f',typ=evol_ther ),
           NUME_ORDRE      =SIMP(statut='f',typ='I',defaut= 0 ),
         ),
         CONVERGENCE     =FACT(statut='d',
           CRIT_TEMP_RELA  =SIMP(statut='f',typ='R',defaut= 1.E-3 ),
           CRIT_ENTH_RELA  =SIMP(statut='f',typ='R',defaut= 1.E-2 ),
           ITER_GLOB_MAXI  =SIMP(statut='f',typ='I',defaut= 10 ),
           ARRET           =SIMP(statut='c',typ='TXM',defaut="OUI",into=("OUI","NON") ),
         ),
#-------------------------------------------------------------------
#        Catalogue commun SOLVEUR
         SOLVEUR         =C_SOLVEUR('THER_NON_LINE_MO'),
#-------------------------------------------------------------------
         TITRE           =SIMP(statut='f',typ='TXM' ),
         INFO            =SIMP(statut='f',typ='I',into=(1,2) ),
)  ;
