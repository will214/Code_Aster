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


def C_SUIVI_DDL() : return FACT(statut='f',max=4,
           regles   =(UN_PARMI('NOM_CMP','NOM_VARI',),),

           NOM_CHAM        =SIMP(statut='o',typ='TXM',max=1,
                                   into=("DEPL","VITE","ACCE",
                                         "FORC_NODA",
                                         "SIEF_ELGA","VARI_ELGA","EPSI_ELGA",)),

           EVAL_CHAM       =SIMP(statut='f',typ='TXM',max=1,defaut='VALE',
                                   into=("MIN","MAX","MOY","MAXI_ABS","MINI_ABS","VALE",),),

           NOM_CMP         =SIMP(statut='f',typ='TXM',max=20),
           NOM_VARI        =SIMP(statut='f',typ='TXM',max=20),

           EVAL_CMP        =SIMP(statut='f',typ='TXM',max=1,defaut='VALE',
                                   into=("VALE","FORMULE",),),

           b_formule       =BLOC(condition="""(equal_to("EVAL_CMP", 'FORMULE'))""",
                                   FORMULE = SIMP(statut='o',typ=formule,max=1),
                                ),

           b_cham_no       =BLOC(condition="""is_in("NOM_CHAM", ('DEPL','VITE','ACCE','FORC_NODA','CONT_NOEU'))""",
                                 regles   =(UN_PARMI('NOEUD','GROUP_NO','GROUP_MA','MAILLE','TOUT')),
                                 TOUT            =SIMP(statut='f',typ='TXM',into=("OUI",) ),
                                 NOEUD           =SIMP(statut='f',typ=no  ,validators=NoRepeat(),max='**'),
                                 GROUP_NO        =SIMP(statut='f',typ=grno,validators=NoRepeat(),max='**'),
                                 MAILLE          =SIMP(statut='f',typ=ma  ,validators=NoRepeat(),max='**'),
                                 GROUP_MA        =SIMP(statut='f',typ=grma,validators=NoRepeat(),max='**'),
                                ),

           b_cham_elga     =BLOC(condition="""is_in("NOM_CHAM", ('SIEF_ELGA','EPSI_ELGA','VARI_ELGA'))""",
                                 regles          =(UN_PARMI('GROUP_MA','MAILLE','TOUT')),
                                 TOUT            =SIMP(statut='f',typ='TXM',into=("OUI",) ),
                                 MAILLE          =SIMP(statut='f',typ=ma   ,validators=NoRepeat(),max='**'),
                                 GROUP_MA        =SIMP(statut='f',typ=grma ,validators=NoRepeat(),max='**'),
                                 EVAL_ELGA       =SIMP(statut='f',typ='TXM',max=1,defaut='VALE',
                                                        into=("MIN","MAX","VALE",),),
                                 b_elga_vale     =BLOC(condition="""(equal_to("EVAL_ELGA", 'VALE'))""",
                                   POINT           =SIMP(statut='o',typ='I'  ,validators=NoRepeat(),max='**'),
                                   SOUS_POINT      =SIMP(statut='f',typ='I'  ,validators=NoRepeat(),max='**'),
                                 ),
                                ),
           # a decommenter quand un champ ELEM sera disponible
           #b_cham_elem    =BLOC(condition="(NOM_CHAM=='XXXX_ELEM')",
                                 #regles          =(UN_PARMI('GROUP_MA','MAILLE','TOUT')),
                                 #TOUT            =SIMP(statut='f',typ='TXM',into=("OUI",) ),
                                 #MAILLE          =SIMP(statut='f',typ=ma   ,validators=NoRepeat(),max='**'),
                                 #GROUP_MA        =SIMP(statut='f',typ=grma ,validators=NoRepeat(),max='**'),
                                #),

           TITRE           =  SIMP(statut='f',typ='TXM',max=3),


       );
