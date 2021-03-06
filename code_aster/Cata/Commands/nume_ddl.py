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
# person_in_charge: nicolas.sellenet at edf.fr
from code_aster.Cata.Syntax import *
from code_aster.Cata.DataStructure import *
from code_aster.Cata.Commons import *


NUME_DDL=OPER(nom="NUME_DDL",op=11,sd_prod=nume_ddl_sdaster,reentrant='n',
              fr=tr("Etablissement de la numérotation des ddl avec ou sans renumérotation et du stockage de la matrice"),
                  regles=(UN_PARMI('MATR_RIGI','MODELE'),),
         MATR_RIGI       =SIMP(statut='f',validators=NoRepeat(),max=100,
                               typ=(matr_elem_depl_r ,matr_elem_depl_c,matr_elem_temp_r ,matr_elem_pres_c) ),
         MODELE          =SIMP(statut='f',typ=modele_sdaster ),
         b_modele        =BLOC(condition = """exists("MODELE")""",
           CHARGE     =SIMP(statut='f',validators=NoRepeat(),max='**',typ=(char_meca,char_ther,char_acou, ),),
         ),
         INFO            =SIMP(statut='f',typ='I',into=(1,2)),
)  ;
