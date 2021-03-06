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
# person_in_charge: sam.cuvilliez at edf.fr

from code_aster.Cata.Syntax import *
from code_aster.Cata.DataStructure import *
from code_aster.Cata.Commons import *


def calc_essai_geomeca_prod(self, **args):
    for key, fact in args.items():
        if not key.startswith('ESSAI_'):
            continue
        if not fact:
            continue
        for occurrence in fact:
            res = occurrence.get('TABLE_RESU')
            if not res:
                continue
            for table in res:
                self.type_sdprod(table, table_sdaster)
    return None


CALC_ESSAI_GEOMECA = MACRO(nom="CALC_ESSAI_GEOMECA",
                     op=OPS('Macro.calc_essai_geomeca_ops.calc_essai_geomeca_ops'),
                     sd_prod=calc_essai_geomeca_prod,
                     reentrant='n',
                     MATER       = SIMP(statut='o',typ=mater_sdaster),
                     COMPORTEMENT   = C_COMPORTEMENT('CALC_ESSAI_GEOMECA'),
                     CONVERGENCE = C_CONVERGENCE('SIMU_POINT_MAT'),
                     regles=(AU_MOINS_UN('COMPORTEMENT'), # car COMPORTEMENT est facultatif dans C_COMPORTEMENT
                             AU_MOINS_UN(
                                         'ESSAI_TD'    ,
                                         'ESSAI_TND'   ,
                                         'ESSAI_CISA_C',
                                         'ESSAI_TND_C' ,
                                         'ESSAI_TD_A' ,
                                         'ESSAI_TD_NA' ,
                                         'ESSAI_OEDO_C' ,
                                         'ESSAI_ISOT_C' ,
                                         #'ESSAI_XXX'   ,
                                         ),),
                     # ---
                     # Essai Triaxial Monotone Draine ('TD')
                     # ---
                     ESSAI_TD = FACT(statut='f',max='**',

                          PRES_CONF   = SIMP(statut='o',typ='R',max='**',),
                          EPSI_IMPOSE = SIMP(statut='o',typ='R',max='**',),
                          NB_INST     = SIMP(statut='f',typ='I',val_min=100,defaut=100),
                          KZERO      = SIMP(statut='f',typ='R',defaut=1.,),

                          TABLE_RESU  = SIMP(statut='f',typ=CO,max='**',validators=NoRepeat(),),
                          GRAPHIQUE   = SIMP(statut='f',typ='TXM',max='**',validators=NoRepeat(),
                                             into=  ('P-Q','EPS_AXI-Q','EPS_AXI-EPS_VOL','P-EPS_VOL',),
                                             defaut=('P-Q','EPS_AXI-Q','EPS_AXI-EPS_VOL','P-EPS_VOL',),),
                          TABLE_REF   = SIMP(statut='f',typ=table_sdaster,max='**',),

                                      ),

                     # ---
                     #  Essai Triaxial Monotone Non Draine ('TND')
                     # ---
                     ESSAI_TND = FACT(statut='f',max='**',

                          PRES_CONF   = SIMP(statut='o',typ='R',max='**',),
                          EPSI_IMPOSE = SIMP(statut='o',typ='R',max='**',),
                          BIOT_COEF   = SIMP(statut='f',typ='R',defaut=1.,),
                          KZERO      = SIMP(statut='f',typ='R',defaut=1.,),
                          NB_INST     = SIMP(statut='f',typ='I',val_min=100,defaut=100),

                          TABLE_RESU  = SIMP(statut='f',typ=CO,max='**',validators=NoRepeat(),),
                          GRAPHIQUE   = SIMP(statut='f',typ='TXM',max='**',validators=NoRepeat(),
                                             into=  ('P-Q','EPS_AXI-Q','EPS_AXI-PRE_EAU',),
                                             defaut=('P-Q','EPS_AXI-Q','EPS_AXI-PRE_EAU',),),
                          TABLE_REF   = SIMP(statut='f',typ=table_sdaster,max='**',),

                                      ),

                     # ---
                     #  Essai de Cisaillement Cyclique Draine ('CISA_C')
                     # ---
                     ESSAI_CISA_C = FACT(statut='f',max='**',

                          PRES_CONF    = SIMP(statut='o',typ='R',max='**',),
                          GAMMA_IMPOSE = SIMP(statut='o',typ='R',max='**',),
                          GAMMA_ELAS   = SIMP(statut='f',typ='R',defaut=1.E-7,val_max=1.E-7),
                          NB_CYCLE     = SIMP(statut='o',typ='I',val_min=1),
                          KZERO        = SIMP(statut='f',typ='R',defaut=1.,),
                          NB_INST      = SIMP(statut='f',typ='I',val_min=25,defaut=25),

                          TABLE_RESU   = SIMP(statut='f',typ=CO,max='**',validators=NoRepeat(),),
                          GRAPHIQUE    = SIMP(statut='f',typ='TXM',max='**',validators=NoRepeat(),
                                             into=  ('GAMMA-SIGXY','GAMMA-G','GAMMA-D','G-D',),
                                             defaut=('GAMMA-SIGXY','GAMMA-G','GAMMA-D','G-D',),),
                          TABLE_REF    = SIMP(statut='f',typ=table_sdaster,max='**',),

                                      ),

                     # ---
                     #  Essai Triaxial Non Draine Cyclique ('TND_C')
                     # ---
                     ESSAI_TND_C = FACT(statut='f',max='**',

                          PRES_CONF   = SIMP(statut='o',typ='R',max='**',),
                          SIGM_IMPOSE = SIMP(statut='o',typ='R',max='**',),
                          BIOT_COEF   = SIMP(statut='f',typ='R',defaut=1.,),
                          KZERO      = SIMP(statut='f',typ='R',defaut=1.,),
                          UN_SUR_K    = SIMP(statut='o',typ='R',),
                          RU_MAX      = SIMP(statut='f',typ='R',defaut=0.8,),
                          NB_CYCLE    = SIMP(statut='o',typ='I',val_min=1),
                          NB_INST     = SIMP(statut='f',typ='I',val_min=25,defaut=25),

                          TABLE_RESU  = SIMP(statut='f',typ=CO,max='**',validators=NoRepeat(),),
                          GRAPHIQUE   = SIMP(statut='f',typ='TXM',max='**',validators=NoRepeat(),
                                             into=  ('NCYCL-DSIGM','P-Q','SIG_AXI-PRE_EAU','EPS_AXI-PRE_EAU','EPS_AXI-Q',),
                                             defaut=('NCYCL-DSIGM','P-Q','SIG_AXI-PRE_EAU','EPS_AXI-PRE_EAU','EPS_AXI-Q',),),
                          TABLE_REF   = SIMP(statut='f',typ=table_sdaster,max='**',),

                                      ),

                     # ---
                     # Essai Triaxial Draine Cylique Alterné ('TD_A')
                     # ---
                     ESSAI_TD_A = FACT(statut='f',max='**',

                          PRES_CONF   = SIMP(statut='o',typ='R',max='**',),
                          EPSI_IMPOSE = SIMP(statut='o',typ='R',max='**',),
                          EPSI_ELAS   = SIMP(statut='f',typ='R',defaut=1.E-7,val_max=1.E-7),
                          NB_INST     = SIMP(statut='f',typ='I',val_min=25,defaut=25),
                          NB_CYCLE    = SIMP(statut='o',typ='I',val_min=1),
                          KZERO       = SIMP(statut='f',typ='R',defaut=1.,),

                          TABLE_RESU  = SIMP(statut='f',typ=CO,max='**',validators=NoRepeat(),),
                          GRAPHIQUE   = SIMP(statut='f',typ='TXM',max='**',validators=NoRepeat(),
                                             into=  ('P-Q','EPS_AXI-Q','EPS_VOL-Q','EPS_AXI-EPS_VOL','P-EPS_VOL','EPSI-E'),
                                             defaut=('P-Q','EPS_AXI-Q','EPS_VOL-Q','EPS_AXI-EPS_VOL','P-EPS_VOL','EPSI-E'),),
                          TABLE_REF   = SIMP(statut='f',typ=table_sdaster,max='**',),

                                      ),

                     # ---
                     # Essai Triaxial Draine Cylique non Alterné ('TD_NA')
                     # ---
                     ESSAI_TD_NA = FACT(statut='f',max='**',

                          PRES_CONF   = SIMP(statut='o',typ='R',max='**',),
                          EPSI_IMPOSE = SIMP(statut='o',typ='R',max='**',),
                          EPSI_ELAS   = SIMP(statut='f',typ='R',defaut=1.E-7,val_max=1.E-7),
                          NB_INST     = SIMP(statut='f',typ='I',val_min=25,defaut=25),
                          NB_CYCLE    = SIMP(statut='o',typ='I',val_min=1),
                          KZERO       = SIMP(statut='f',typ='R',defaut=1.,),

                          TABLE_RESU  = SIMP(statut='f',typ=CO,max='**',validators=NoRepeat(),),
                          GRAPHIQUE   = SIMP(statut='f',typ='TXM',max='**',validators=NoRepeat(),
                                             into=  ('P-Q','EPS_AXI-Q','EPS_VOL-Q','EPS_AXI-EPS_VOL','P-EPS_VOL','EPSI-E'),
                                             defaut=('P-Q','EPS_AXI-Q','EPS_VOL-Q','EPS_AXI-EPS_VOL','P-EPS_VOL','EPSI-E'),),
                          TABLE_REF   = SIMP(statut='f',typ=table_sdaster,max='**',),

                                      ),

                     # ---
                     #  Essai Oedometrique Draine Cyclique  ('OEDO_C')
                     # ---
                     ESSAI_OEDO_C = FACT(statut='f',max='**',

                          PRES_CONF   = SIMP(statut='o',typ='R',max='**',),
                          SIGM_IMPOSE = SIMP(statut='o',typ='R',max='**',),
                          SIGM_DECH   = SIMP(statut='o',typ='R',max='**',),
                          KZERO       = SIMP(statut='f',typ='R',defaut=1.,),
                          NB_INST     = SIMP(statut='f',typ='I',val_min=25,defaut=25),

                          TABLE_RESU  = SIMP(statut='f',typ=CO,max='**',validators=NoRepeat(),),
                          GRAPHIQUE   = SIMP(statut='f',typ='TXM',max='**',validators=NoRepeat(),
                                             into=  ('P-EPS_VOL','SIG_AXI-EPS_VOL'),
                                             defaut=('P-EPS_VOL','SIG_AXI-EPS_VOL'),),
                          TABLE_REF   = SIMP(statut='f',typ=table_sdaster,max='**',),

                                      ),

                     # ---
                     #  Essai De Comsolidation Isotrope Drainee Cyclique  ('ISOT_C')
                     # ---
                     ESSAI_ISOT_C = FACT(statut='f',max='**',

                          PRES_CONF    = SIMP(statut='o',typ='R',max='**',),
                          SIGM_IMPOSE = SIMP(statut='o',typ='R',max='**',),
                          SIGM_DECH   = SIMP(statut='o',typ='R',max='**',),
                          KZERO      = SIMP(statut='f',typ='R',defaut=1.,),
                          NB_INST     = SIMP(statut='f',typ='I',val_min=25,defaut=25),

                          TABLE_RESU = SIMP(statut='f',typ=CO,max='**',validators=NoRepeat(),),
                          GRAPHIQUE  = SIMP(statut='f',typ='TXM',max='**',validators=NoRepeat(),
                                             into=  ('P-EPS_VOL', ),
                                             defaut='P-EPS_VOL',),
                          TABLE_REF  = SIMP(statut='f',typ=table_sdaster,max='**',),

                                      ),



                     # ---
                     #  Essai ... ('XXX')
                     # ---
                     #ESSAI_XXX = FACT(statut='f',max='**',
                     #
                     #     PRES_CONF  = SIMP(statut='o',typ='R',max='**',),
                     #     ...
                     #
                     #     TABLE_RESU = SIMP(statut='f',typ=CO,max='**',validators=NoRepeat(),),
                     #     GRAPHIQUE  = SIMP(statut='f',typ='TXM',max='**',validators=NoRepeat(),
                     #                        into=  ('XXX','XXX','XXX',),
                     #                        defaut=('XXX','XXX','XXX',),),
                     #     TABLE_REF  = SIMP(statut='f',typ=table_sdaster,max='**',),
                     #
                     #                 ),

                    INFO = SIMP(statut='f',typ='I',defaut= 1,into=(1,2) ),)
