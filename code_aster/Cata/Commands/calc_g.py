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
# person_in_charge: samuel.geniaut at edf.fr
from code_aster.Cata.Syntax import *
from code_aster.Cata.DataStructure import *
from code_aster.Cata.Commons import *


CALC_G=OPER(nom="CALC_G",op=100,sd_prod=table_sdaster,
            fr=tr("Calcul du taux de restitution d'énergie par la méthode theta en thermo-élasticité"
                  " et les facteurs d'intensité de contraintes."),
                    reentrant='f',

         reuse=SIMP(statut='c', typ=CO),
         THETA          =FACT(statut='o',
           FOND_FISS       =SIMP(statut='f',typ=fond_fiss,max=1),
           FISSURE         =SIMP(statut='f',typ=fiss_xfem,max=1),
           NB_POINT_FOND   =SIMP(statut='f',typ='I',val_min=2),
           regles=(
                   UN_PARMI('FOND_FISS','FISSURE'),
                   PRESENT_PRESENT('R_INF','R_SUP'),
                   PRESENT_PRESENT('R_INF_FO','R_SUP_FO'),
                   ),
           NUME_FOND       =SIMP(statut='f',typ='I',defaut=1),
           R_INF           =SIMP(statut='f',typ='R'),
           R_SUP           =SIMP(statut='f',typ='R'),
           MODULE          =SIMP(statut='f',typ='R',defaut=1.),
           DIRE_THETA      =SIMP(statut='f',typ=cham_no_sdaster ),
           DIRECTION       =SIMP(statut='f',typ='R',max=3,min=3),
           R_INF_FO        =SIMP(statut='f',typ=(fonction_sdaster,nappe_sdaster,formule)),
           R_SUP_FO        =SIMP(statut='f',typ=(fonction_sdaster,nappe_sdaster,formule)),
           MODULE_FO       =SIMP(statut='f',typ=(fonction_sdaster,nappe_sdaster,formule)),
            ),

         RESULTAT        =SIMP(statut='o',typ=(evol_elas,evol_noli,dyna_trans,mode_meca,mult_elas),),

         b_no_mult          =BLOC(condition="""(is_type("RESULTAT") != mult_elas)""",
         regles=(EXCLUS('TOUT_ORDRE','NUME_ORDRE','LIST_ORDRE','INST','LIST_INST',
                  'TOUT_MODE','NUME_MODE','LIST_MODE','FREQ','LIST_FREQ'),),

            TOUT_ORDRE      =SIMP(statut='f',typ='TXM',into=("OUI",) ),
            NUME_ORDRE      =SIMP(statut='f',typ='I',validators=NoRepeat(),max='**'),
            LIST_ORDRE      =SIMP(statut='f',typ=listis_sdaster),
            INST            =SIMP(statut='f',typ='R',validators=NoRepeat(),max='**'),
            LIST_INST       =SIMP(statut='f',typ=listr8_sdaster),
            TOUT_MODE       =SIMP(statut='f',typ='TXM',into=("OUI",) ),
            NUME_MODE       =SIMP(statut='f',typ='I',validators=NoRepeat(),max='**'),
            LIST_MODE       =SIMP(statut='f',typ=listis_sdaster),
            LIST_FREQ       =SIMP(statut='f',typ=listr8_sdaster),
            FREQ            =SIMP(statut='f',typ='R',validators=NoRepeat(),max='**'),

           b_acce_reel     =BLOC(condition="""(exists("INST"))or(exists("LIST_INST"))or(exists("FREQ"))or(exists("LIST_FREQ"))""",
              CRITERE         =SIMP(statut='f',typ='TXM',defaut="RELATIF",into=("RELATIF","ABSOLU") ),
                  b_prec_rela=BLOC(condition="""(equal_to("CRITERE", 'RELATIF'))""",
                      PRECISION       =SIMP(statut='f',typ='R',defaut= 1.E-6,),),
                  b_prec_abso=BLOC(condition="""(equal_to("CRITERE", 'ABSOLU'))""",
                      PRECISION       =SIMP(statut='o',typ='R'),),
            ),
         ),

         b_mult_elas     =BLOC(condition="""(is_type("RESULTAT") == mult_elas)""",
            NOM_CAS         =SIMP(statut='f',typ='TXM',validators=NoRepeat(),max='**' ),
         ),

         b_no_mult_elas  =BLOC(condition="""(is_type("RESULTAT") != mult_elas)""",
            EXCIT           =FACT(statut='f',max='**',
               CHARGE          =SIMP(statut='f',typ=(char_meca,char_cine_meca)),
               FONC_MULT       =SIMP(statut='f',typ=(fonction_sdaster,nappe_sdaster,formule)),
               TYPE_CHARGE     =SIMP(statut='f',typ='TXM',defaut="FIXE_CSTE",into=("FIXE_CSTE",) ),
                                 ),
         ),

         COMPORTEMENT       =FACT(statut='f',
               RELATION  =SIMP( statut='o',typ='TXM',into=C_RELATION('CALC_G')),
               DEFORMATION     =SIMP(statut='f',typ='TXM',defaut="PETIT",into=("PETIT","PETIT_REAC") ),
             regles=(PRESENT_ABSENT('TOUT','GROUP_MA','MAILLE'),),
               TOUT            =SIMP(statut='f',typ='TXM',into=("OUI",) ),
               GROUP_MA        =SIMP(statut='f',typ=grma,validators=NoRepeat(),max='**'),
               MAILLE          =SIMP(statut='c',typ=ma,validators=NoRepeat(),max='**'),
                        ),

         ETAT_INIT       =FACT(statut='f',
           SIGM           =SIMP(statut='o', typ=(cham_no_sdaster,cham_elem)),
#           DEPL            =SIMP(statut='f',typ=cham_no_sdaster),
         ),
         LISSAGE         =FACT(statut='d',
           LISSAGE_THETA   =SIMP(statut='f',typ='TXM',defaut="LEGENDRE",into=("LEGENDRE","LAGRANGE"),),
           LISSAGE_G       =SIMP(statut='f',typ='TXM',defaut="LEGENDRE",into=("LEGENDRE","LAGRANGE",
                                 "LAGRANGE_NO_NO"),),
                b_legen    =BLOC(condition="""(equal_to("LISSAGE_THETA", 'LEGENDRE')) or (equal_to("LISSAGE_G", 'LEGENDRE'))""",
                  DEGRE           =SIMP(statut='f',typ='I',defaut=5,into=(0,1,2,3,4,5,6,7) ),
                ),
         ),

         OPTION          =SIMP(statut='o',typ='TXM',max=1,defaut='CALC_G',
                               into=("CALC_G",
                                     "CALC_G_GLOB",
                                     "CALC_K_G",
                                     "CALC_GTP"),
                             ),

        b_cal_contrainte =BLOC(condition="""(exists("COMPORTEMENT") and (equal_to("OPTION", 'CALC_G') or equal_to("OPTION", 'CALC_GTP') or equal_to("OPTION", 'CALC_G_GLOB')))""",
          CALCUL_CONTRAINTE =SIMP(statut='f',typ='TXM',defaut="OUI",into=("OUI","NON",),),
         ),


         TITRE           =SIMP(statut='f',typ='TXM'),
         INFO            =SIMP(statut='f',typ='I',defaut=1,into=(1,2) ),
);
