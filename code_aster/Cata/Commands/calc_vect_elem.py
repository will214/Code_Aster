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
# person_in_charge: jacques.pellet at edf.fr
from code_aster.Cata.Syntax import *
from code_aster.Cata.DataStructure import *
from code_aster.Cata.Commons import *


def calc_vect_elem_prod(OPTION,**args):
  if OPTION == "CHAR_MECA" :      return vect_elem_depl_r
  if OPTION == "CHAR_THER" :      return vect_elem_temp_r
  if OPTION == "CHAR_ACOU" :      return vect_elem_pres_c
  raise AsException("type de concept resultat non prevu")

CALC_VECT_ELEM=OPER(nom="CALC_VECT_ELEM",op=8,sd_prod=calc_vect_elem_prod,reentrant='n',
                    fr=tr("Calcul des seconds membres élémentaires"),
         OPTION          =SIMP(statut='o',typ='TXM',into=("CHAR_MECA","CHAR_THER","CHAR_ACOU") ),
         b_char_meca     =BLOC(condition = """equal_to("OPTION", 'CHAR_MECA')""",
           regles=(AU_MOINS_UN('CHARGE','MODELE'),),
           CHARGE          =SIMP(statut='f',typ=char_meca,validators=NoRepeat(),max='**'),
           MODELE          =SIMP(statut='f',typ=modele_sdaster),
           b_charge     =BLOC(condition = """exists("CHARGE")""", fr=tr("modèle ne contenant pas de sous-structure"),
              CHAM_MATER   =SIMP(statut='f',typ=cham_mater),
              CARA_ELEM    =SIMP(statut='f',typ=cara_elem),
              INST         =SIMP(statut='f',typ='R',defaut= 0.E+0 ),
              MODE_FOURIER =SIMP(statut='f',typ='I',defaut= 0 ),
           ),
           b_modele     =BLOC(condition = """(exists("MODELE"))""",fr=tr("modèle contenant une sous-structure"),
              SOUS_STRUC      =FACT(statut='o',min=01,
                regles=(UN_PARMI('TOUT','SUPER_MAILLE'),),
                CAS_CHARGE  =SIMP(statut='o',typ='TXM' ),
                TOUT        =SIMP(statut='f',typ='TXM',into=("OUI",) ),
                SUPER_MAILLE=SIMP(statut='f',typ=ma,validators=NoRepeat(),max='**',),
              ),
           ),
         ),
         b_char_ther     =BLOC(condition = """equal_to("OPTION", 'CHAR_THER')""",
           CARA_ELEM        =SIMP(statut='f',typ=cara_elem),
           CHARGE           =SIMP(statut='o',typ=char_ther,validators=NoRepeat(),max='**'),
           INST             =SIMP(statut='f',typ='R',defaut= 0.E+0 ),
         ),

         b_char_acou     =BLOC(condition = """equal_to("OPTION", 'CHAR_ACOU')""",
           CHAM_MATER        =SIMP(statut='o',typ=cham_mater),
           CHARGE            =SIMP(statut='o',typ=char_acou,validators=NoRepeat(),max='**'),
         ),
) ;
