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
# person_in_charge: kyrylo.kazymyrenko at edf.fr
from code_aster.Cata.Syntax import *
from code_aster.Cata.DataStructure import *


def C_PILOTAGE() : return FACT(statut='f',
           regles=(EXCLUS('NOEUD','GROUP_NO'),PRESENT_ABSENT('TOUT','GROUP_MA','MAILLE'),),
           TYPE    =SIMP(statut='o',typ='TXM',into=("DDL_IMPO","LONG_ARC","PRED_ELAS","DEFORMATION",
                                                    "ANA_LIM","SAUT_IMPO","SAUT_LONG_ARC") ),
           COEF_MULT     =SIMP(statut='f',typ='R',defaut= 1.0E+0),
           EVOL_PARA     =SIMP(statut='f',typ='TXM',defaut="SANS", into=("SANS","CROISSANT","DECROISSANT") ),
           ETA_PILO_MAX  =SIMP(statut='f',typ='R'),
           ETA_PILO_MIN  =SIMP(statut='f',typ='R'),
           ETA_PILO_R_MAX=SIMP(statut='f',typ='R'),
           ETA_PILO_R_MIN=SIMP(statut='f',typ='R'),
           PROJ_BORNES   =SIMP(statut='f',typ='TXM',defaut="OUI",into=("OUI","NON")),
           SELECTION     =SIMP(statut='f',typ='TXM',defaut="NORM_INCR_DEPL",
                               into=("RESIDU","MIXTE","ANGL_INCR_DEPL","NORM_INCR_DEPL")),
           TOUT          =SIMP(statut='f',typ='TXM',into=("OUI",) ),
           GROUP_MA      =SIMP(statut='f',typ=grma ,validators=NoRepeat(),max='**'),
           FISSURE       =SIMP(statut='f',typ=fiss_xfem ,validators=NoRepeat(),max='**'),
           MAILLE        =SIMP(statut='f',typ=ma   ,validators=NoRepeat(),max='**'),
           NOEUD         =SIMP(statut='f',typ=no   ,validators=NoRepeat(),max='**'),
           GROUP_NO      =SIMP(statut='f',typ=grno ,validators=NoRepeat(),max='**'),
           NOM_CMP       =SIMP(statut='f',typ='TXM',max='**'),
           DIRE_PILO     =SIMP(statut='f',typ='TXM',max='**'),
         );
