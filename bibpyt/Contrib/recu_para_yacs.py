# -*- coding: utf-8 -*-
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
# person_in_charge: nicolas.greffet at edf.fr
#
# RECUPERATION DE PARAMETRES DE COUPLAGE VIA YACS
#

from code_aster.Cata.Syntax import *
from code_aster.Cata.DataStructure import *
from code_aster.Cata.Commons import *


RECU_PARA_YACS=OPER(nom="RECU_PARA_YACS",op=114,sd_prod=listr8_sdaster,
                   reentrant = 'n',
                   fr        = tr("Gestion des scalaires via YACS pour le coupleur IFS"),
          DONNEES = SIMP(statut='o',typ='TXM',into=("INITIALISATION","CONVERGENCE","FIN","PAS",) ),
          b_init   = BLOC(condition= "DONNEES=='INITIALISATION'",
                     PAS             = SIMP(statut='o',typ='R', ),),
          b_noinit = BLOC(condition= "(DONNEES=='CONVERGENCE')or(DONNEES=='FIN')",
                     NUME_ORDRE_YACS = SIMP(statut='o', typ='I',),
                     INST         = SIMP(statut='o',typ='R', ),
                     PAS             = SIMP(statut='o',typ='R', ),),
          b_pastps = BLOC(condition= "(DONNEES=='PAS')",
                     NUME_ORDRE_YACS = SIMP(statut='o', typ='I',),
                     INST         = SIMP(statut='o',typ='R', ),
                     PAS             = SIMP(statut='o',typ='R', ),),
         INFO            =SIMP(statut='f',typ='I',defaut=1,into=(1,2)),
         TITRE           =SIMP(statut='f',typ='TXM',max='**'),
);
