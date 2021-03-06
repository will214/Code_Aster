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
# person_in_charge: georges-cc.devesa at edf.fr
from code_aster.Cata.Syntax import *
from code_aster.Cata.DataStructure import *
from code_aster.Cata.Commons import *


def calc_char_seisme_prod(MATR_MASS,**args ):
  if AsType(MATR_MASS) == matr_asse_depl_r : return cham_no_sdaster
  raise AsException("type de concept resultat non prevu")

CALC_CHAR_SEISME=OPER(nom="CALC_CHAR_SEISME",op=  92,sd_prod=calc_char_seisme_prod,
                      reentrant='n',fr=tr("Calcul du chargement sismique"),
         regles=(UN_PARMI('MONO_APPUI','MODE_STAT' ),),
         MATR_MASS       =SIMP(statut='o',typ=matr_asse_depl_r,fr=tr("Matrice de masse") ),
         DIRECTION       =SIMP(statut='o',typ='R',max=6,fr=tr("Directions du séisme imposé")),
         MONO_APPUI      =SIMP(statut='f',typ='TXM',into=("OUI",) ),
         MODE_STAT       =SIMP(statut='f',typ=(mode_meca,) ),
         b_mode_stat     =BLOC ( condition = """exists("MODE_STAT")""",
           regles=(UN_PARMI('NOEUD','GROUP_NO' ),),
           NOEUD           =SIMP(statut='c',typ=no,validators=NoRepeat(),max='**'),
           GROUP_NO        =SIMP(statut='f',typ=grno,validators=NoRepeat(),max='**'),
         ),
         TITRE           =SIMP(statut='f',typ='TXM'),
)  ;
