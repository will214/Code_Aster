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
# person_in_charge: jean-luc.flejou at edf.fr


from code_aster.Cata.Syntax import *
from code_aster.Cata.DataStructure import *
from code_aster.Cata.Commons import *


MACR_CARA_POUTRE=MACRO(nom="MACR_CARA_POUTRE",
                       op=OPS('Macro.macr_cara_poutre_ops.macr_cara_poutre_ops'),
                       sd_prod=table_sdaster,
                       reentrant='n',
                       fr=tr("Calculer les caractéristiques d'une section transversale de "
                            "poutre à partir d'un maillage 2D de la section"),
         regles=(
            EXCLUS('SYME_Y','GROUP_MA_BORD'),
            EXCLUS('SYME_Z','GROUP_MA_BORD'),
         ),

         MAILLAGE    =SIMP(statut='f',typ=maillage_sdaster, fr=tr("Nom du concept maillage")),
         b_maillage  =BLOC(
            condition = """not exists("MAILLAGE")""",
            regles=( PRESENT_PRESENT('FORMAT','UNITE') ),
            FORMAT   =SIMP(statut='f',typ='TXM',defaut="MED",into=("ASTER","MED"),
                           fr=tr("Format du fichier")),
            UNITE    =SIMP(statut='f',typ=UnitType(),defaut= 20, inout='in',
                           fr=tr("Unite correspondant au format du fichier maillage")),
         ),

         ORIG_INER      =SIMP(statut='f',typ='R',max=3,defaut=(0.E+0,0.E+0),
                              fr=tr("Point par rapport auquel sont calculées les inerties")),
         INFO           =SIMP(statut='f',typ='I',defaut=1,into=(1,2)),

         TABLE_CARA     =SIMP(statut='f',typ='TXM',into=("OUI","NON"),defaut="NON",),

         SYME_Y         =SIMP(statut='f',typ='TXM',into=("OUI",), fr=tr("demi maillage par rapport a y=0")),
         SYME_Z         =SIMP(statut='f',typ='TXM',into=("OUI",), fr=tr("demi maillage par rapport a z=0")),

         GROUP_MA       =SIMP(statut='f',typ=grma,validators=NoRepeat(),max='**',
                              fr=tr("Calcul des caractéristiques équivalentes à plusieurs sections disjointes")),

         GROUP_MA_BORD  =SIMP(statut='f',typ=grma,validators=NoRepeat(),max='**',
                              fr=tr("Groupe(s) de mailles linéiques, bord(s) de(s) section(s)")),

         b_nom =BLOC(
            condition = """(equal_to("TABLE_CARA", 'OUI')) and (not exists("GROUP_MA"))""",
            NOM   =SIMP(statut='f',typ='TXM',max=1,validators=LongStr(1,8),
                        fr=tr("Nom de la section, 8 caractères maximum."))
         ),

         b_gma_bord  =BLOC(
            condition = """exists("GROUP_MA_BORD")""",
            fr=tr(" calcul des carac. mecaniques"),
            regles=(UN_PARMI('NOEUD','GROUP_NO')),
            NOEUD          =SIMP(statut='c',typ=no,max='**',
                                 fr=tr("Simplement pour empecher des pivots nuls le cas echeant. "
                                      "Fournir un noeud quelconque")),
            GROUP_NO       =SIMP(statut='f',typ=grno,max='**',
                                 fr=tr("Simplement pour empecher des pivots nuls le cas echeant. "
                                      "Fournir un noeud quelconque par GROUP_MA")),
            GROUP_MA_INTE  =SIMP(statut='f',typ=grma,validators=NoRepeat(),max='**',
                                 fr=tr("groupes de mailles linéiques bordant des trous dans la section")),
          ),

         b_reseau = BLOC(
            condition ="""(exists("GROUP_MA_BORD")) and (exists("GROUP_MA"))""",
            fr=tr(" calcul des coef de cisaillement équivalents a un reseau de poutres"),
            regles=(ENSEMBLE('LONGUEUR','LIAISON','MATERIAU') ,),
            LONGUEUR =SIMP(statut='f',typ='R',
                           fr=tr("Longueur du réseau de poutres")),
            MATERIAU =SIMP(statut='f',typ=mater_sdaster,
                           fr=tr("Materiau elastique lineaire du reseau")),
            LIAISON  =SIMP(statut='f',typ='TXM',into=("ROTULE","ENCASTREMENT"),
                           fr=tr("type de conditions aux limites sur le plancher supérieur") ),
         ),
)
