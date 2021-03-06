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


MAC_MODES=OPER(nom="MAC_MODES",op=  141,sd_prod=table_sdaster,
               fr=tr("Critere orthogonalite de modes propres"),
               reentrant='n',
               regles=(PRESENT_PRESENT('IERI','MATR_ASSE'),),
         BASE_1     =SIMP(statut='o',typ=(mode_meca,mode_meca_c,mode_flamb) ),
         BASE_2     =SIMP(statut='o',typ=(mode_meca,mode_meca_c,mode_flamb) ),
         MATR_ASSE  =SIMP(statut='f',typ=(matr_asse_depl_r,matr_asse_depl_c) ),
         IERI       =SIMP(statut='f',typ='TXM',into=("OUI",),),
         TITRE      =SIMP(statut='f',typ='TXM'),
         INFO       =SIMP(statut='f',typ='I',defaut= 1,into=( 1 , 2) ),
)  ;
