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
# person_in_charge: harinaivo.andriambololona at edf.fr
from code_aster.Cata.Syntax import *
from code_aster.Cata.DataStructure import *
from code_aster.Cata.Commons import *


DEFI_LIST_FREQ=MACRO(nom="DEFI_LIST_FREQ",
                    op=OPS('Macro.defi_list_freq_ops.defi_list_freq_ops'),
                    sd_prod=listr8_sdaster,
                    fr=tr("Définir une liste de fréquences strictement croissante"),
                    reentrant='n',
         regles=(UN_PARMI('VALE','DEBUT',),
                 EXCLUS('VALE','INTERVALLE'),
                 ENSEMBLE('DEBUT','INTERVALLE')),
         VALE            =SIMP(statut='f',typ='R',max='**'),
         DEBUT           =SIMP(statut='f',typ='R'),
         INTERVALLE      =FACT(statut='f',max='**',
           regles=(UN_PARMI('NOMBRE','PAS'),),
           JUSQU_A         =SIMP(statut='o',typ='R'),
           NOMBRE          =SIMP(statut='f',typ='I'),
           PAS             =SIMP(statut='f',typ='R'),
         ),
         RAFFINEMENT      =FACT(statut='f',
           LIST_RAFFINE    =SIMP(statut='o',typ='R',max='**'),
           NB_POINTS       =SIMP(statut='f',typ='I',defaut=5),
           PAS_MINI        =SIMP(statut='f',typ='R',defaut=0.001),
           CRITERE         =SIMP(statut='f',typ='TXM',defaut="RELATIF",into=("RELATIF","ABSOLU","LARGEUR_3DB")),
              b_crit_rela_abs=BLOC(condition="""(equal_to("CRITERE", 'RELATIF') or equal_to("CRITERE", 'ABSOLU'))""",
                 DISPERSION      =SIMP(statut='f',typ='R',defaut=0.01),),
              b_crit_larg=BLOC(condition="""(equal_to("CRITERE", 'LARGEUR_3DB'))""",
                    regles = UN_PARMI('AMOR_REDUIT','LIST_AMOR'),
                    AMOR_REDUIT     =SIMP(statut='f',typ='R',max='**'),
                    LIST_AMOR       =SIMP(statut='f',typ=listr8_sdaster ),),
             ),
         INFO            =SIMP(statut='f',typ='I',defaut=1,into=(1,2)),
         TITRE           =SIMP(statut='f',typ='TXM'),
)  ;
