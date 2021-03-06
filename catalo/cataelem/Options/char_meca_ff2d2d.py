# coding=utf-8
# person_in_charge: xavier.desroches at edf.fr


# ======================================================================
# COPYRIGHT (C) 1991 - 2015  EDF R&D                  WWW.CODE-ASTER.ORG
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

from cataelem.Tools.base_objects import InputParameter, OutputParameter, Option, CondCalcul
import cataelem.Commons.physical_quantities as PHY
import cataelem.Commons.parameters as SP
import cataelem.Commons.attributes as AT


CHAR_MECA_FF2D2D = Option(
    para_in=(
        SP.PFF2D2D,
        SP.PGEOMER,
        SP.PTEMPSR,
    ),
    para_out=(
        SP.PVECTUR,
    ),
    condition=(
        CondCalcul(
            '+', ((AT.PHENO, 'ME'), (AT.BORD, '0'), (AT.DIM_TOPO_MODELI, '2'),)),
        CondCalcul(
            '-', ((AT.PHENO, 'ME'), (AT.BORD, '0'), (AT.INTERFACE, 'OUI'),)),
    ),
    comment=""" CHAR_MECA_FF2D2D (MOT-CLE : FORCE_INTERNE): CALCUL DU SECOND
           MEMBRE ELEMENTAIRE CORRESPONDANT A DES FORCES INTERNES APPLIQUEES
           A UN DOMAINE 2D. LES FORCES SONT DONNEES SOUS FORME DE FONCTION """,
)
