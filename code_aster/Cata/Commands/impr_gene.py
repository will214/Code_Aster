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
# person_in_charge: harinaivo.andriambololona at edf.fr
from code_aster.Cata.Syntax import *
from code_aster.Cata.DataStructure import *
from code_aster.Cata.Commons import *


IMPR_GENE=PROC(nom="IMPR_GENE",op= 157,
            fr=tr("Imprimer le résultat d'un calcul dynamique en variables généralisées au format RESULTAT"),
         FORMAT          =SIMP(statut='f',typ='TXM',defaut="RESULTAT",into=("RESULTAT",) ),
         UNITE           =SIMP(statut='f',typ=UnitType(),defaut=8, inout='out'),
         GENE            =FACT(statut='o',max='**',
           regles=(EXCLUS('TOUT_ORDRE','NUME_ORDRE','INST','FREQ','NUME_MODE',
                          'LIST_INST','LIST_FREQ','TOUT_MODE','TOUT_INST','LIST_ORDRE'),
                   EXCLUS('TOUT_MODE','NUME_ORDRE','INST','FREQ','NUME_MODE',
                          'LIST_INST','LIST_FREQ','TOUT_ORDRE','TOUT_INST','LIST_ORDRE'),
                   EXCLUS('TOUT_INST','NUME_ORDRE','INST','FREQ','NUME_MODE',
                          'LIST_INST','LIST_FREQ','TOUT_ORDRE','LIST_ORDRE'),
                   EXCLUS('TOUT_CMP_GENE','NUME_CMP_GENE'),
                   EXCLUS('TOUT_CHAM','NOM_CHAM'),
                   EXCLUS('TOUT_PARA','NOM_PARA'),),
#  faut-il faire des blocs selon le type de RESU_GENE
           RESU_GENE       =SIMP(statut='o',typ=(vect_asse_gene, tran_gene, mode_gene, harm_gene)),
           TOUT_ORDRE      =SIMP(statut='f',typ='TXM',into=("OUI",) ),
           NUME_ORDRE      =SIMP(statut='f',typ='I',validators=NoRepeat(),max='**'),
           LIST_ORDRE      =SIMP(statut='f',typ=listis_sdaster ),
           INST            =SIMP(statut='f',typ='R',validators=NoRepeat(),max='**'),
           LIST_INST       =SIMP(statut='f',typ=listr8_sdaster ),
           TOUT_INST       =SIMP(statut='f',typ='TXM',into=("OUI",) ),
           FREQ            =SIMP(statut='f',typ='R',validators=NoRepeat(),max='**'),
           LIST_FREQ       =SIMP(statut='f',typ=listr8_sdaster ),
           TOUT_MODE       =SIMP(statut='f',typ='TXM',into=("OUI",) ),
           NUME_MODE       =SIMP(statut='f',typ='I',validators=NoRepeat(),max='**'),
           CRITERE         =SIMP(statut='f',typ='TXM',defaut="RELATIF",into=("RELATIF","ABSOLU",),),
           b_prec_rela=BLOC(condition="""(equal_to("CRITERE", 'RELATIF'))""",
              PRECISION       =SIMP(statut='f',typ='R',defaut= 1.E-6,),),
           b_prec_abso=BLOC(condition="""(equal_to("CRITERE", 'ABSOLU'))""",
              PRECISION       =SIMP(statut='o',typ='R',),),
           TOUT_CMP_GENE   =SIMP(statut='f',typ='TXM',into=("OUI","NON") ),
           NUME_CMP_GENE   =SIMP(statut='f',typ='I',max='**'),
           TOUT_CHAM       =SIMP(statut='f',typ='TXM',into=("OUI","NON") ),
           NOM_CHAM        =SIMP(statut='f',typ='TXM',validators=NoRepeat(),max='**',into=C_NOM_CHAM_INTO(),),
           TOUT_PARA       =SIMP(statut='f',typ='TXM',into=("OUI","NON") ),
           NOM_PARA        =SIMP(statut='f',typ='TXM',max='**'),
           SOUS_TITRE      =SIMP(statut='f',typ='TXM'),
           INFO_CMP_GENE   =SIMP(statut='f',typ='TXM',into=("OUI","NON") ),
           INFO_GENE       =SIMP(statut='f',typ='TXM',into=("OUI","NON") ),
         ),
)  ;
