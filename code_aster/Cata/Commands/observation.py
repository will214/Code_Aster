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


def observation_prod(self, RESULTAT, **args):
    if  AsType(RESULTAT) == mode_meca :
        return mode_meca
    elif AsType(RESULTAT) == evol_elas :
        return evol_elas
    elif AsType(RESULTAT) == dyna_harmo :
        return dyna_harmo
    elif AsType(RESULTAT) == dyna_trans :
        return dyna_trans
    else :
        return None

OBSERVATION=MACRO(nom="OBSERVATION",
                  op=OPS('Macro.observation_ops.observation_ops'),
                  sd_prod=observation_prod,
                  fr=tr("Calcul de l'observabilite d'un champ aux noeuds "),
#
         MODELE_1        =SIMP(statut='o',typ=modele_sdaster),
         MODELE_2        =SIMP(statut='o',typ=modele_sdaster),
         RESULTAT        =SIMP(statut='o',typ=(mode_meca,evol_elas,dyna_harmo,dyna_trans,) ),
         NOM_CHAM        =SIMP(statut='o',typ='TXM',validators=NoRepeat(),max='**',into=C_NOM_CHAM_INTO(),),

#        ------------------------------------------------------------------

         regles=(UN_PARMI('TOUT_ORDRE','NUME_ORDRE','FREQ','LIST_FREQ','NUME_MODE','INST','LIST_INST' ),),
         TOUT_ORDRE      =SIMP(statut='f',typ='TXM',into=("OUI",) ),
         NUME_ORDRE      =SIMP(statut='f',typ='I',validators=NoRepeat(),max='**' ),
         FREQ            =SIMP(statut='f',typ='R',validators=NoRepeat(),max='**' ),
         LIST_FREQ       =SIMP(statut='f',typ=listr8_sdaster),
         NUME_MODE       =SIMP(statut='f',typ='I',validators=NoRepeat(),max='**' ),
         LIST_ORDRE      =SIMP(statut='f',typ=listis_sdaster),
         INST            =SIMP(statut='f',typ='R',validators=NoRepeat(),max='**' ),
         LIST_INST       =SIMP(statut='f',typ=listr8_sdaster),
         NOEUD_CMP       =SIMP(statut='f',typ='TXM',validators=NoRepeat(),max='**'),

#        ------------------------------------------------------------------
#        OPTIONS DE PROJ_CHAMP (SANS MC FACTEUR PARTICULIER)
#        ------------------------------------------------------------------
         PROJECTION     =SIMP(statut='f',max=1,typ='TXM',into=("OUI","NON"),defaut="OUI"),
         CAS_FIGURE      =SIMP(statut='f',typ='TXM',into=("2D","3D","2.5D","1.5D",) ),
         DISTANCE_MAX    =SIMP(statut='f',typ='R',
                fr=tr("Distance maximale entre le noeud et l'élément le plus proche, lorsque le noeud n'est dans aucun élément.")),
         DISTANCE_ALARME =SIMP(statut='f',typ='R'),
         ALARME          =SIMP(statut='f',typ='TXM',defaut="OUI",into=("OUI","NON") ),

         TYPE_CHAM       =SIMP(statut='f',typ='TXM',into=("NOEU",),
                fr=tr("Pour forcer le type des champs projetés. NOEU -> cham_no")),

#           PROL_ZERO       =SIMP(statut='f',typ='TXM',into=("OUI","NON"),defaut="NON",
#                fr=tr("Si le résultat est un mode_xxx ou une base_xxx, on peut prolonger")
#                   +" les champs par zéro la ou la projection ne donne pas de valeurs."),

         MATR_RIGI       =SIMP(statut='f',typ=(matr_asse_depl_r) ),
         MATR_MASS       =SIMP(statut='f',typ=(matr_asse_depl_r) ),
         VIS_A_VIS       =FACT(statut='f',max='**',
             regles=(AU_MOINS_UN('TOUT_1','GROUP_MA_1','MAILLE_1','GROUP_NO_1','NOEUD_1'),
                     AU_MOINS_UN('TOUT_2','GROUP_MA_2','MAILLE_2','GROUP_NO_2','NOEUD_2'),),
             TOUT_1          =SIMP(statut='f',typ='TXM',into=("OUI",) ),
             GROUP_MA_1      =SIMP(statut='f',typ=grma,validators=NoRepeat(),max='**'),
             MAILLE_1        =SIMP(statut='c',typ=ma  ,validators=NoRepeat(),max='**'),
             GROUP_NO_1      =SIMP(statut='f',typ=grno,validators=NoRepeat(),max='**'),
             NOEUD_1         =SIMP(statut='c',typ=no  ,validators=NoRepeat(),max='**'),
             TOUT_2          =SIMP(statut='f',typ='TXM',into=("OUI",) ),
             GROUP_MA_2      =SIMP(statut='f',typ=grma,validators=NoRepeat(),max='**'),
             MAILLE_2        =SIMP(statut='c',typ=ma  ,validators=NoRepeat(),max='**'),
             GROUP_NO_2      =SIMP(statut='f',typ=grno,validators=NoRepeat(),max='**'),
             NOEUD_2         =SIMP(statut='c',typ=no  ,validators=NoRepeat(),max='**'),
             CAS_FIGURE      =SIMP(statut='f',typ='TXM',into=("2D","3D","2.5D","1.5D",) ),
             ),

#        ------------------------------------------------------------------
#        MODI_REPERE
#        ------------------------------------------------------------------
         MODI_REPERE     =FACT(statut='f',max='**',
         regles=(UN_PARMI('REPERE'),
                 AU_MOINS_UN('TOUT','GROUP_MA','MAILLE','GROUP_NO','NOEUD'),),
           GROUP_MA        =SIMP(statut='f',typ=grma,validators=NoRepeat(),max='**'),
           GROUP_NO        =SIMP(statut='f',typ=grno,validators=NoRepeat(),max='**'),
           MAILLE          =SIMP(statut='c',typ=ma  ,validators=NoRepeat(),max='**'),
           NOEUD           =SIMP(statut='c',typ=no  ,validators=NoRepeat(),max='**'),
           TOUT            =SIMP(statut='f',typ='TXM',into=("OUI",) ),
#
           TYPE_CHAM       =SIMP(statut='f',typ='TXM',
                                 into=("VECT_2D","VECT_3D","TENS_2D","TENS_3D"),
                                       defaut="VECT_3D"),
           b_vect_2d       =BLOC(condition = """equal_to("TYPE_CHAM", 'VECT_2D')""",
              NOM_CMP         =SIMP(statut='o',typ='TXM',min=2,max=2 ),),
           b_vect_3d       =BLOC(condition = """equal_to("TYPE_CHAM", 'VECT_3D')""",
              NOM_CMP         =SIMP(statut='f',typ='TXM',min=3,max=3,defaut=('DX','DY','DZ') ),),
           b_tens_2d       =BLOC(condition = """equal_to("TYPE_CHAM", 'TENS_2D')""",
              NOM_CMP         =SIMP(statut='f',typ='TXM',min=4,max=4,defaut=('EPXX','EPYY','EPZZ','EPXY',) ),),
           b_tens_3d       =BLOC(condition = """equal_to("TYPE_CHAM", 'TENS_3D')""",
              NOM_CMP         =SIMP(statut='f',typ='TXM',min=6,max=6,defaut=('EPXX','EPYY','EPZZ','EPXY','EPXZ','EPYZ',),),),

           REPERE          =SIMP(statut='o',typ='TXM',
                                 into=("UTILISATEUR","CYLINDRIQUE","NORMALE","DIR_JAUGE"),),
           b_normale       =BLOC(condition = """equal_to("REPERE", 'NORMALE')""",
             regles=(UN_PARMI('VECT_X','VECT_Y')),
             VECT_X          =SIMP(statut='f',typ='R',min=3,max=3),
             VECT_Y          =SIMP(statut='f',typ='R',min=3,max=3), ),
           b_utilisateur   =BLOC(condition = """equal_to("REPERE", 'UTILISATEUR')""",
             ANGL_NAUT       =SIMP(statut='o',typ='R',max=3)),
           b_cylindrique   =BLOC(condition = """equal_to("REPERE", 'CYLINDRIQUE')""",
             ORIGINE         =SIMP(statut='o',typ='R',min=2,max=3),
             AXE_Z           =SIMP(statut='o',typ='R',min=3,max=3)),
           b_dir_jauge       =BLOC(condition = """equal_to("REPERE", 'DIR_JAUGE')""",
             VECT_X          =SIMP(statut='f',typ='R',min=3,max=3),
             VECT_Y          =SIMP(statut='f',typ='R',min=3,max=3), ),
         ),

#        ------------------------------------------------------------------
#        EPSI_MOYENNE
#        ------------------------------------------------------------------
         EPSI_MOYENNE     =FACT(statut='f',max='**',
                       regles=(AU_MOINS_UN('GROUP_MA','MAILLE','GROUP_NO','NOEUD'),),
           NOEUD       = SIMP(statut='c',typ=no  ,validators=NoRepeat(),max='**'),
           GROUP_NO     = SIMP(statut='f',typ=grno,validators=NoRepeat(),max='**'),
           MAILLE          =SIMP(statut='c',typ=ma  ,validators=NoRepeat(),max='**'),
           GROUP_MA        =SIMP(statut='f',typ=grma,validators=NoRepeat(),max='**'),
           SEUIL_VARI      =SIMP(statut='f',typ='R',validators=NoRepeat(),defaut=0.1,),
           MASQUE          =SIMP(statut='f',typ='TXM',max=6),
         ),

#        ------------------------------------------------------------------
#        FILTRE DES DDL
#        ------------------------------------------------------------------
         FILTRE     =FACT(statut='f',max='**',
           regles=(UN_PARMI('DDL_ACTIF'),
#                           'MASQUE'),
           AU_MOINS_UN('TOUT','GROUP_MA','MAILLE','GROUP_NO','NOEUD'),),
           GROUP_MA        =SIMP(statut='f',typ=grma,validators=NoRepeat(),max='**'),
           GROUP_NO        =SIMP(statut='f',typ=grno,validators=NoRepeat(),max='**'),
           MAILLE          =SIMP(statut='c',typ=ma  ,validators=NoRepeat(),max='**'),
           NOEUD           =SIMP(statut='c',typ=no  ,validators=NoRepeat(),max='**'),
           TOUT            =SIMP(statut='f',typ='TXM',into=("OUI",) ),
           NOM_CHAM        =SIMP(statut='o',typ='TXM',validators=NoRepeat(),into=C_NOM_CHAM_INTO(),),

#
           DDL_ACTIF       =SIMP(statut='f',typ='TXM',max=6),
# TODO : mettre en place le systeme de masques
#           MASQUE          =SIMP(statut='f',typ='TXM',max=6),
         ),
#        ------------------------------------------------------------------

         TITRE           =SIMP(statut='f',typ='TXM' ),
         INFO            =SIMP(statut='f',typ='I',defaut=1,into=(1,2)),
      )  ;
