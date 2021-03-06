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
# person_in_charge: nicolas.greffet at edf.fr


from code_aster.Cata.Syntax import *
from code_aster.Cata.DataStructure import *
from code_aster.Cata.Commons import *


def calc_transfert_prod(self,SIGNAL,**args):
#   self.type_sdprod(tabfrf,table_sdaster)
   if SIGNAL !=None:
      for sign in SIGNAL:
          self.type_sdprod(sign['TABLE_RESU'],table_sdaster)
   return table_sdaster


CALC_TRANSFERT=MACRO(nom="CALC_TRANSFERT",
                      op=OPS('Macro.calc_transfert_ops.calc_transfert_ops'),
                      sd_prod=calc_transfert_prod,
                      fr=tr("Calcul des fonctions de transfert et des signaux deconvolues "),

         NOM_CHAM   =SIMP(statut='o',typ='TXM',max=1,into=("DEPL","VITE","ACCE") ),
         ENTREE     =FACT(statut='o',max=1,
            regles=(UN_PARMI('GROUP_NO','NOEUD',),),
              GROUP_NO        =SIMP(statut='f',typ=grno,max=1),
              NOEUD           =SIMP(statut='c',typ=no  ,max=1),),

        SORTIE      =FACT(statut='o',max=1,
                      regles=(UN_PARMI('GROUP_NO','NOEUD',),),
              GROUP_NO        =SIMP(statut='f',typ=grno,max=1),
              NOEUD           =SIMP(statut='c',typ=no  ,max=1),),

        REPERE      =SIMP(statut='f',typ='TXM',defaut="RELATIF",into=("RELATIF","ABSOLU") ),

        b_repere  = BLOC( condition = """equal_to("REPERE", 'RELATIF')""",
              ENTRAINEMENT   =FACT(statut='o',max=1,
                        DX            =SIMP(statut='o',typ=(fonction_sdaster,fonction_c)),
                        DY            =SIMP(statut='o',typ=(fonction_sdaster,fonction_c)),
                        DZ            =SIMP(statut='f',typ=(fonction_sdaster,fonction_c)),),),

        RESULTAT_X  =SIMP(statut='o',typ=(harm_gene,tran_gene,dyna_harmo,dyna_trans,),),
        RESULTAT_Y  =SIMP(statut='o',typ=(harm_gene,tran_gene,dyna_harmo,dyna_trans,),),
        RESULTAT_Z  =SIMP(statut='f',typ=(harm_gene,tran_gene,dyna_harmo,dyna_trans,),),

        SIGNAL      =FACT(statut='f',max=1,
              MESURE_X      =SIMP(statut='o',typ=(fonction_sdaster,fonction_c)),
              MESURE_Y      =SIMP(statut='o',typ=(fonction_sdaster,fonction_c)),
              MESURE_Z      =SIMP(statut='f',typ=(fonction_sdaster,fonction_c)),
              TABLE_RESU    =SIMP(statut='o',typ=CO),
              TYPE_RESU     =SIMP(statut='o',typ='TXM',defaut="HARMONIQUE",into=("HARMONIQUE","TEMPOREL")),
              ),

)
