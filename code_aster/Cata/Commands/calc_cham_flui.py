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


CALC_CHAM_FLUI = OPER(nom="CALC_CHAM_FLUI",op= 116,sd_prod=evol_ther,
                      fr="Calculer le champ de vitesses et de pression fluides",
         # Mot-clés obligatoires
         RIGI_THER   = SIMP(statut='o',typ=matr_asse_temp_r ),
         EXCIT       = FACT(statut='o',max='**',
                       CHARGE    = SIMP(statut='o',typ=(char_ther,char_cine_ther)),
                       FONC_MULT = SIMP(statut='f',typ=(fonction_sdaster,nappe_sdaster,formule))),
         POTENTIEL   = SIMP(statut='o',typ='TXM',defaut="DEPL",into=("DEPL","VITE","PRES")),
         DIST_REFE   = SIMP(statut='o',typ='R',defaut= 1.E-2 ),
         MODE_MECA   = SIMP(statut='o',typ=mode_meca),
         b_coefmult       = BLOC(condition  = """exists("MODE_MECA")""",
                                COEF_MULT    =SIMP(statut='o',typ='R',defaut=(1.0),max='**'),
                               ),   
                      )
