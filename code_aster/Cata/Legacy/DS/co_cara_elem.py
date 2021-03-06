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
# person_in_charge: mathieu.courtois at edf.fr


import aster
from code_aster.Cata.Syntax import ASSD


class cara_elem(ASSD):
    cata_sdj = "SD.sd_cara_elem.sd_cara_elem"

    def toEPX(self):

        # Raideurs
        ressorts = {}

        try:
           EPXnoeud = self.sdj.CARRIGXN.get()
           EPXval   = self.sdj.CARRIGXV.get()
           lenEPXval   = len(EPXval)
           lenEPXnoeud = len(EPXnoeud)*6
        except:
           # s'il y a un problème sur la structure de données ==> <F>
           from Utilitai.Utmess import UTMESS
           UTMESS('F','MODELISA9_98')
        # Vérification de la déclaration qui est faite dans 'acearp'
        if ( lenEPXval != lenEPXnoeud ):
           from Utilitai.Utmess import UTMESS
           UTMESS('F','MODELISA9_97')
        # Tout est OK
        i=0
        for no in EPXnoeud :
           ressorts[no] = EPXval[i:i+6]
           i+=6

        # Amortissements
        amorts = {}
        try:
           EPXnoeud = self.sdj.CARAMOXN.get()
           EPXval   = self.sdj.CARAMOXV.get()
           lenEPXval   = len(EPXval)
           lenEPXnoeud = len(EPXnoeud)*6
        except:
           # s'il y a un problème sur la structure de données ==> <F>
           from Utilitai.Utmess import UTMESS
           UTMESS('F','MODELISA9_98')
        # Vérification de la déclaration qui est faite dans 'acearp'
        if ( lenEPXval != lenEPXnoeud ):
           from Utilitai.Utmess import UTMESS
           UTMESS('F','MODELISA9_97')
        # Tout est OK
        i=0
        for no in EPXnoeud :
           amorts[no] = EPXval[i:i+6]
           i+=6

        return ressorts, amorts
