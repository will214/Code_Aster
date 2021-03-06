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

# person_in_charge: hassan.berro at edf.fr

from code_aster.Cata.Syntax import *
from code_aster.Cata.DataStructure import *
from code_aster.Cata.Commons import *


POST_GENE_PHYS  = OPER( nom="POST_GENE_PHYS",op=  58,sd_prod=table_sdaster,
                        fr="Post-traiter dans la base physique des résultats dyanmiques en coordonnées généralisées",
                        reentrant='n',
   
                  RESU_GENE   = SIMP(statut = 'o', typ = (tran_gene,harm_gene) ), 
                  MODE_MECA   = SIMP(statut = 'f', typ = mode_meca ),
   
                  OBSERVATION = FACT(statut = 'o', min = 1, max = '**',
                                     regles=(EXCLUS('INST','LIST_INST','TOUT_INST','NUME_ORDRE','TOUT_ORDRE','FREQ','LIST_FREQ'),
                                             EXCLUS('NOEUD','GROUP_NO','MAILLE','GROUP_MA'),
                                             AU_MOINS_UN('NOEUD','GROUP_NO','MAILLE','GROUP_MA'),),

                      NOM_CHAM   = SIMP(statut = 'o', typ = 'TXM', validators = NoRepeat(), max = 1, defaut = 'DEPL',
                                        into   = ('DEPL'      ,'VITE'      ,'ACCE'        , 
                                                 'DEPL_ABSOLU','VITE_ABSOLU','ACCE_ABSOLU', 
                                                 'FORC_NODA'  ,'EFGE_ELNO'  ,'SIPO_ELNO'  ,
                                                 'SIGM_ELNO'  ,'EFGE_ELGA'  ,'SIGM_ELGA'  ,),),
                      NOM_CMP    = SIMP(statut = 'f', typ = 'TXM', max = 20,),
 
                      INST       = SIMP(statut = 'f' , typ='R'           , validators = NoRepeat(), max = '**' ), 
                      TOUT_INST  = SIMP(statut = 'f' , typ='TXM'         , into = ("OUI",) ),
                      LIST_INST  = SIMP(statut = 'f' , typ=listr8_sdaster,),
                      NUME_ORDRE = SIMP(statut = 'f' , typ='I'           , validators = NoRepeat(), max = '**' ),  
                      TOUT_ORDRE = SIMP(statut = 'f' , typ='TXM'         , into = ("OUI",) ),
                      FREQ       = SIMP(statut = 'f' , typ='R'           , validators = NoRepeat(), max = '**' ),  
                      LIST_FREQ  = SIMP(statut = 'f' , typ=listr8_sdaster,),
                      b_prec     = BLOC(condition = """(exists("INST")) or (exists("LIST_INST")) or (exists("FREQ")) or (exists("LIST_FREQ"))""",
                          CRITERE = SIMP(statut = 'f', typ = 'TXM', defaut = 'RELATIF', into = ('ABSOLU','RELATIF') ),
                              b_prec_rela = BLOC(condition = """(equal_to("CRITERE", 'RELATIF'))""",
                              PRECISION   = SIMP(statut = 'f', typ='R', defaut= 1.E-6,),),
                              b_prec_abso = BLOC(condition = """(equal_to("CRITERE", 'ABSOLU'))""",
                              PRECISION   = SIMP(statut = 'o', typ='R',),),),

                      NOEUD      = SIMP(statut = 'c', typ=no  , validators = NoRepeat(), max = '**'),
                      GROUP_NO   = SIMP(statut = 'f', typ=grno, validators = NoRepeat(), max = '**'),
                      MAILLE     = SIMP(statut = 'c', typ=ma  , validators = NoRepeat(), max = '**'),
                      GROUP_MA   = SIMP(statut = 'f', typ=grma, validators = NoRepeat(), max = '**'),

                      b_acce_abs      = BLOC(condition = """(equal_to("NOM_CHAM", 'ACCE_ABSOLU'))""",
                                             regles    = (PRESENT_PRESENT('ACCE_MONO_APPUI','DIRECTION'),),
                      ACCE_MONO_APPUI = SIMP(statut = 'f', typ=(fonction_sdaster,nappe_sdaster,formule)),
                      DIRECTION       = SIMP(statut = 'f', typ='R', min=3, max = 3 ),),),

                  TITRE       = SIMP(statut = 'f', typ='TXM',),  
)  ;
