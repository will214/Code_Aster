# coding=utf-8
# person_in_charge: mickael.abbas at edf.fr


# ======================================================================
# COPYRIGHT (C) 1991 - 2016  EDF R&D                  WWW.CODE-ASTER.ORG
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




PLSN     = InputParameter(phys=PHY.NEUT_R,
comment=""" XFEM """)


PLST     = InputParameter(phys=PHY.NEUT_R,
comment=""" XFEM """)


PPINTER  = InputParameter(phys=PHY.N816_R,
comment=""" XFEM """)


PAINTER  = InputParameter(phys=PHY.N1360R,
comment=""" XFEM """)


PCFACE   = InputParameter(phys=PHY.N720_I,
comment=""" XFEM """)


PLONGCO  = InputParameter(phys=PHY.N120_I,
comment=""" XFEM - NBRE DE TETRAEDRES ET DE SOUS-ELEMENTS  """)


PBASECO  = InputParameter(phys=PHY.N2448R,
comment=""" XFEM """)


PSEUIL   = InputParameter(phys=PHY.NEUT_R,
comment=""" XFEM """)


PSTANO   = InputParameter(phys=PHY.N120_I,
comment=""" XFEM """)


PFISNO   = InputParameter(phys=PHY.NEUT_I,
comment=""" XFEM """)


PHEA_NO  = InputParameter(phys=PHY.N120_I,
comment=""" XFEM """)


PHEA_FA  = InputParameter(phys=PHY.N240_I,
comment=""" XFEM """)


PCOHESO  = OutputParameter(phys=PHY.NEUT_R, type='ELEM')


PCOMPOR  = InputParameter(phys=PHY.COMPOR,
comment=""" UTILE POUR HM-XFEM """)


PBASLOR  = InputParameter(phys=PHY.NEUT_R)

PBASLOC  = InputParameter(phys=PHY.N480_R)

PLSNGG     = InputParameter(phys=PHY.NEUT_R,
comment=""" XFEM """)

RIGI_CONT = Option(
    para_in=(
        SP.PACCE_M,
           PAINTER,
           PBASECO,
        SP.PCAR_AI,
        SP.PCAR_CF,
        SP.PCAR_PI,
        SP.PCAR_PT,
           PCFACE,
        SP.PCOHES,
        SP.PCONFR,
        SP.PDEPL_M,
        SP.PDEPL_P,
        SP.PDONCO,
           PFISNO,
        SP.PGEOMER,
        SP.PSNO,
        SP.PHEAVNO,
           PHEA_FA,
           PHEA_NO,
        SP.PINDCOI,
           PLONGCO,
           PLSN,
           PLST,
        SP.PMATERC,
           PPINTER,
           PSEUIL,
           PSTANO,
        SP.PVITE_M,
        SP.PVITE_P,
        SP.PINSTMR,
        SP.PINSTPR,
           PCOMPOR,
        SP.PCARCRI,
        SP.PFISCO,
           PBASLOR,
           PBASLOC,
           PLSNGG,
    ),
    para_out=(
           PCOHESO,
        SP.PMATUNS,
        SP.PMATUUR,
    ),
    condition=(
      CondCalcul('+', ((AT.CONTACT,'OUI'),)),
    ),
    comment=""" RIGI_CONT: CALCUL DE LA MATRICE
           ELEMENTAIRE DE CONTACT AVEC LA METHODE CONTINUE ET XFEM """,
)
