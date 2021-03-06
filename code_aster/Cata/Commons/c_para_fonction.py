# coding=utf-8
# person_in_charge: mathieu.courtois at edf.fr
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
# ce fichier contient la liste des PARA possibles pour les fonctions et les nappes
from code_aster.Cata.Syntax import *
from code_aster.Cata.DataStructure import *


def C_PARA_FONCTION() : return  ( #COMMUN#
                   "DX","DY","DZ","DRX","DRY","DRZ","TEMP","TSEC",
                   "INST","X","Y","Z","EPSI","META","FREQ","PULS","DSP",
                   "AMOR","ABSC","SIGM","HYDR","SECH","PORO","SAT",
                   "PGAZ","PCAP","PLIQ","PVAP","PAD","VITE","ENDO",
                   "NORM","EPAIS","NEUT1","NEUT2","XF","YF","ZF", "NUME_ORDRE")
