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


LIRE_MAILLAGE=OPER(nom="LIRE_MAILLAGE",op=   1,sd_prod=maillage_sdaster,
                   fr=tr("Crée un maillage par lecture d'un fichier au format Aster ou Med"),
                   
                   reentrant='n',

         UNITE           =SIMP(statut='f',typ=UnitType(),defaut= 20 , inout='in'),

         FORMAT          =SIMP(statut='f',typ='TXM',defaut="MED",into=("ASTER","MED"),
                            fr=tr("Format du fichier : ASTER ou MED."),
                            ),

         VERI_MAIL       =FACT(statut='d',
               VERIF         =SIMP(statut='f',typ='TXM',defaut="OUI",into=("OUI","NON") ),
               APLAT         =SIMP(statut='f',typ='R',defaut= 1.0E-3 ),
         ),

         b_format_med =BLOC( condition = """ ( equal_to("FORMAT", 'MED') ) """ ,
                             fr=tr("Informations complémentaires pour la lecture MED."),
                             

# Pour une lecture dans un fichier MED, on peut préciser le nom sous lequel
# le maillage y a été enregistré. Par défaut, on va le chercher sous le nom du concept à créer.
            NOM_MED    = SIMP(statut='f',typ='TXM',
                              fr=tr("Nom du maillage dans le fichier MED."),
                              ),
            INFO_MED   = SIMP(statut='f',typ='I',defaut= 1,into=(1,2,3) ),

         ),

         INFO            =SIMP(statut='f',typ='I',defaut= 1,into=(1,2) ),
         translation={
            "LIRE_MAILLAGE": "Read a mesh",
            "FORMAT": "Mesh file format",
            "UNITE": "Mesh file location",
            "VERI_MAIL": "Mesh check",
            "VERIF": "Check",
            "APLAT": "Flat criterion",
         }
)  ;
