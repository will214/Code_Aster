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
# person_in_charge: mickael.abbas at edf.fr
#
from code_aster.Cata.Syntax import *
from code_aster.Cata.DataStructure import *


def C_CONVERGENCE(COMMAND=None) :
    if COMMAND =='SIMU_POINT_MAT':
        mcfact =   FACT(statut='d',
                        RESI_GLOB_MAXI  =SIMP(statut='f',typ='R'),
                        RESI_GLOB_RELA  =SIMP(statut='f',typ='R'),
                        ITER_GLOB_MAXI  =SIMP(statut='f',typ='I',defaut=10)
        )
    else:
        mcfact =   FACT(statut='d',
                        regles=(PRESENT_ABSENT('RESI_REFE_RELA','RESI_GLOB_MAXI','RESI_GLOB_RELA','RESI_COMP_RELA'),),
                        b_refe_rela    =   BLOC(condition = """exists("RESI_REFE_RELA")""",
                                                    regles=(AU_MOINS_UN('SIGM_REFE','EPSI_REFE','FLUX_THER_REFE','EFFORT_REFE','MOMENT_REFE',
                                                                        'FLUX_HYD1_REFE','FLUX_HYD2_REFE','VARI_REFE','DEPL_REFE','LAGR_REFE','PI_REFE'),),
                                                    EFFORT_REFE     =SIMP(statut='f',typ='R', fr=tr("Force de référence pour les éléments de structure.")),
                                                    MOMENT_REFE     =SIMP(statut='f',typ='R', fr=tr("Moment de référence pour les éléments de structure.")),
                                                    SIGM_REFE       =SIMP(statut='f',typ='R'),
                                                    DEPL_REFE       =SIMP(statut='f',typ='R'),
                                                    EPSI_REFE       =SIMP(statut='f',typ='R'),
                                                    FLUX_THER_REFE  =SIMP(statut='f',typ='R'),
                                                    FLUX_HYD1_REFE  =SIMP(statut='f',typ='R'),
                                                    FLUX_HYD2_REFE  =SIMP(statut='f',typ='R'),
                                                    VARI_REFE       =SIMP(statut='f',typ='R'),
                                                    LAGR_REFE       =SIMP(statut='f',typ='R'),
                                                    PI_REFE         =SIMP(statut='f',typ='R')
                                                   ),
                        RESI_REFE_RELA  =SIMP(statut='f',typ='R'),
                        RESI_GLOB_MAXI  =SIMP(statut='f',typ='R'),
                        RESI_GLOB_RELA  =SIMP(statut='f',typ='R'),
                        RESI_COMP_RELA  =SIMP(statut='f',typ='R'),
                        ITER_GLOB_MAXI  =SIMP(statut='f',typ='I',defaut=10),
                        ITER_GLOB_ELAS  =SIMP(statut='f',typ='I',defaut=25),
                        ARRET           =SIMP(statut='f',typ='TXM',defaut="OUI",into=("OUI","NON"))
        )
    return mcfact
