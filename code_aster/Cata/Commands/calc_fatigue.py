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
# person_in_charge: sarah.plessis at edf.fr
from code_aster.Cata.Syntax import *
from code_aster.Cata.DataStructure import *
from code_aster.Cata.Commons import *


def calc_fatigue_prod(TYPE_CALCUL,OPTION,**args):
  if TYPE_CALCUL == "CUMUL_DOMMAGE" : return cham_elem
  if TYPE_CALCUL == "FATIGUE_MULTI" and OPTION == "DOMA_ELGA": return cham_elem
  if TYPE_CALCUL == "FATIGUE_MULTI" and OPTION == "DOMA_NOEUD": return cham_no_sdaster
  if TYPE_CALCUL == "FATIGUE_VIBR" : return cham_elem
  raise AsException("type de calcul non prevu")

CALC_FATIGUE=OPER(nom="CALC_FATIGUE",op= 151,sd_prod=calc_fatigue_prod,reentrant='n',
                  fr=tr("Calculer un champ de dommage de fatigue subit par une structure et déterminer le plan critique"
                        " dans lequel le cisaillement est maximal."),

         TYPE_CALCUL = SIMP(statut='o',typ='TXM',
                               into=("CUMUL_DOMMAGE","FATIGUE_MULTI","FATIGUE_VIBR") ),

         b_cumul_domma   =BLOC(condition = """equal_to("TYPE_CALCUL", 'CUMUL_DOMMAGE')""",
                               fr=tr("Calcul d un champ de dommage subi par une structure."),
           regles=(PRESENT_PRESENT('DOMMAGE','MATER', ),),
           OPTION          =SIMP(statut='o',typ='TXM',
                                 into=("DOMA_ELNO_SIGM","DOMA_ELGA_SIGM",
                                       "DOMA_ELNO_EPSI","DOMA_ELGA_EPSI",
                                       "DOMA_ELNO_EPME","DOMA_ELGA_EPME") ),

             b_sigm   =BLOC(condition = """equal_to("OPTION", 'DOMA_ELNO_SIGM') or equal_to("OPTION", 'DOMA_ELGA_SIGM')""",
                               fr=tr("Calcul a partir d un champ de contraintes."),
               HISTOIRE        =FACT(statut='o',
               RESULTAT        =SIMP(statut='o',typ=(evol_elas,dyna_trans,
                                                   evol_noli) ),
               EQUI_GD         =SIMP(statut='f',typ='TXM',defaut="VMIS_SG",
                                 into=("VMIS_SG",) ),
                                   ),
                           ),
             b_epsi   =BLOC(condition = """not equal_to("OPTION", 'DOMA_ELNO_SIGM') and not equal_to("OPTION", 'DOMA_ELGA_SIGM')""",
                               fr=tr("Calcul a partir d un champ de déformations."),
               HISTOIRE        =FACT(statut='o',
               RESULTAT        =SIMP(statut='o',typ=(evol_elas,dyna_trans,
                                                   evol_noli) ),
               EQUI_GD         =SIMP(statut='o',typ='TXM',defaut="INVA_2_SG",
                                 into=("INVA_2_SG",) ),
                                    ),
                           ),
           DOMMAGE         =SIMP(statut='o',typ='TXM',
                               into=("WOHLER","MANSON_COFFIN","TAHERI_MANSON",
                                     "TAHERI_MIXTE",) ),
           MATER           =SIMP(statut='o',typ=(mater_sdaster) ),
           TAHERI_NAPPE    =SIMP(statut='f',typ=(nappe_sdaster,formule) ),
           TAHERI_FONC     =SIMP(statut='f',typ=(fonction_sdaster,nappe_sdaster,formule) ),
         ),

         b_domma_moda   =BLOC(condition = """equal_to("TYPE_CALCUL", 'FATIGUE_VIBR')""",
                               fr=tr("Calcul d un champ de dommage en dynamique vibratoire"),
           regles=(PRESENT_PRESENT('DOMMAGE','MATER', ),),
           OPTION          =SIMP(statut='o',typ='TXM',
                                 into=("DOMA_ELNO_SIGM","DOMA_ELGA_SIGM",) ),
           CORR_SIGM_MOYE = SIMP(statut='o',typ='TXM',into=("GOODMAN","GERBER")),
           HISTOIRE        =FACT(statut='o',
             RESULTAT  =SIMP(statut='o',typ=(evol_elas, evol_noli) ),
             MODE_MECA        =SIMP(statut='o',typ=(mode_meca) ),
             NUME_MODE        =SIMP(statut='o',typ='I',min=1 ,max='**'),
             FACT_PARTICI        =SIMP(statut='o',typ='R',min=1, max='**',defaut=1. ),
             EQUI_GD         =SIMP(statut='f',typ='TXM',defaut="VMIS_SG",
                                 into=("VMIS_SG",) ),
           ),
           DOMMAGE         =SIMP(statut='o',typ='TXM',
                               into=("WOHLER",) ),
           MATER           =SIMP(statut='o',typ=(mater_sdaster) ),
         ),

         b_fatigue_multi   =BLOC(condition = """equal_to("TYPE_CALCUL", 'FATIGUE_MULTI')""",
                                 fr=tr("Plan critique dans le cas de la fatigue multiaxiale à grand nombre de cycles."),
           TYPE_CHARGE   =SIMP(statut='o',typ='TXM',into=("PERIODIQUE","NON_PERIODIQUE") ),
           OPTION        =SIMP(statut='o',typ='TXM',into=("DOMA_ELGA","DOMA_NOEUD") ),
           RESULTAT      =SIMP(statut='o',typ=(evol_elas, evol_noli) ),
           CHAM_MATER    =SIMP(statut='f',typ=(cham_mater) ),
           MAILLAGE      =SIMP(statut='o',typ=maillage_sdaster ),
           regles=(UN_PARMI('GROUP_NO','NOEUD','GROUP_MA','MAILLE'),),
           GROUP_MA      =SIMP(statut='f',typ=grma,validators=NoRepeat(),max='**' ),
           MAILLE        =SIMP(statut='c',typ=ma  ,validators=NoRepeat(),max='**' ),
           GROUP_NO      =SIMP(statut='f',typ=grno,validators=NoRepeat(),max='**' ),
           NOEUD         =SIMP(statut='c',typ=no  ,validators=NoRepeat(),max='**' ),
           COEF_PREECROU =SIMP(statut='f',typ='R',defaut= 1.0E+0),
           b_period       =BLOC(condition = """equal_to("TYPE_CHARGE", 'PERIODIQUE')""",
               CRITERE       =SIMP(statut='o',typ='TXM',into=("MATAKE_MODI_AC",
                                                              "DANG_VAN_MODI_AC","VMIS_TRESCA","FORMULE_CRITERE") ),
               b_fati_p  =BLOC(condition = """(equal_to("CRITERE", 'MATAKE_MODI_AC') or equal_to("CRITERE", 'DANG_VAN_MODI_AC'))""",
                   METHODE       =SIMP(statut='o',typ='TXM',into=("CERCLE_EXACT",) ),
               ),

               b_fati_pf  =BLOC(condition = """(equal_to("CRITERE", 'FORMULE_CRITERE'))""",
                   FORMULE_GRDEQ   = SIMP(statut='o',typ=(fonction_sdaster,formule) ),
                   COURBE_GRD_VIE  = SIMP(statut='o',typ='TXM',into=("WOHLER","MANSON_COFFIN","FORM_VIE") ),
                   FORMULE_CRITIQUE = SIMP(statut='f',typ=(fonction_sdaster,formule) ),
                   b_fati_pfvie  = BLOC(condition = """(equal_to("COURBE_GRD_VIE", 'FORM_VIE'))""",
                        FORMULE_VIE   =SIMP(statut='o',typ=(fonction_sdaster,formule) ),
                  ),
               ),

               INST_INIT_CYCL =SIMP(statut='f',typ='R',min=1, max=1),
               INST_CRIT      =SIMP(statut='f',typ='TXM',into=("RELATIF","ABSOLU",) ),
               regles=(PRESENT_PRESENT('INST_INIT_CYCL','INST_CRIT', ),),
                  b_prec_rela=BLOC(condition="""(equal_to("INST_CRIT", 'RELATIF'))""",
                        PRECISION       =SIMP(statut='f',typ='R',defaut= 1.E-6),),
                  b_prec_abso=BLOC(condition="""(equal_to("INST_CRIT", 'ABSOLU'))""",
                        PRECISION       =SIMP(statut='o',typ='R'),),
           ),
           b_non_period   =BLOC(condition = """equal_to("TYPE_CHARGE", 'NON_PERIODIQUE')""",
               CRITERE       =SIMP(statut='o',typ='TXM',
                                   into=("MATAKE_MODI_AV","DANG_VAN_MODI_AV","FATESOCI_MODI_AV","FORMULE_CRITERE","VMIS_TRESCA") ),
               b_fati_np  =BLOC(condition = """(not equal_to("CRITERE", 'VMIS_TRESCA'))""",
                   PROJECTION    =SIMP(statut='o',typ='TXM',into=("UN_AXE", "DEUX_AXES") ),
                   DELTA_OSCI    =SIMP(statut='f',typ='R',defaut= 0.0E+0),
               ),
               b_fati_npf  =BLOC(condition = """(equal_to("CRITERE", 'FORMULE_CRITERE'))""",
                   FORMULE_GRDEQ   =SIMP(statut='o',typ=(fonction_sdaster,formule) ),
                   COURBE_GRD_VIE  = SIMP(statut='o',typ='TXM',into=("WOHLER","MANSON_COFFIN","FORM_VIE") ),
                   b_fati_npfvie  = BLOC(condition = """(equal_to("COURBE_GRD_VIE", 'FORM_VIE'))""",
                        FORMULE_VIE   =SIMP(statut='o',typ=(fonction_sdaster,formule) ),
                  ),
               ),
           ),
         ),

         INFO            =SIMP(statut='f',typ='I',defaut= 1,into=(1,2) ),
)  ;
