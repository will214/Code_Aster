#@ MODIF prepost3 Messages  DATE 12/10/2011   AUTEUR COURTOIS M.COURTOIS 
# -*- coding: iso-8859-1 -*-
#            CONFIGURATION MANAGEMENT OF EDF VERSION
# ======================================================================
# COPYRIGHT (C) 1991 - 2011  EDF R&D                  WWW.CODE-ASTER.ORG
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
# RESPONSABLE DELMAS J.DELMAS

cata_msg = {

4 : _(u"""
  le nombre de noeuds selectionnes est superieur au nombre de noeuds du maillage. on va tronquer la liste.
"""),

5 : _(u"""
 chaine de caracteres trop longues : imprimer moins de champs
"""),

6 : _(u"""
 type inconnu" %(k1)s "
"""),

7 : _(u"""
 le maillage  %(k1)s  a deja ete ecrit au format ensight: le contenu du fichier  %(k2)s  sera ecrase.
"""),

8 : _(u"""
 probleme a l'ouverture du fichier " %(k1)s " pour impression du maillage  %(k2)s  au format ensight
"""),

9 : _(u"""
 type de base inconnu:  %(k1)s 
"""),

10 : _(u"""
 soit le fichier n'existe pas, soit c'est une mauvaise version de hdf (utilise par med).
"""),


31 : _(u"""
 on n'a pas trouv� le num�ro d'ordre � l'adresse indiqu�e
"""),

32 : _(u"""
 on n'a pas trouv� l'instant � l'adresse indiqu�e
"""),

33 : _(u"""
 on n'a pas trouv� la fr�quence � l'adresse indiqu�e
"""),

34 : _(u"""
 on n'a pas trouv� dans le fichier UNV le type de champ
"""),

35 : _(u"""
 on n'a pas trouv� dans le fichier UNV le nombre de composantes � lire
"""),

36 : _(u"""
 on n'a pas trouv� dans le fichier UNV la nature du champ
 (r�el ou complexe)
"""),

37 : _(u"""
 le type de champ demand� est diff�rent du type de champ � lire
"""),

38 : _(u"""
 le champ demande n'est pas de m�me nature que le champ � lire
 (r�el/complexe)
"""),

39 : _(u"""
 le mot cle MODELE est obligatoire pour un CHAM_ELEM
"""),

40 : _(u"""
 pb correspondance noeud IDEAS
"""),

41 : _(u"""
 le champ de type ELGA n'est pas support�
"""),

63 : _(u"""
 on attend 10 ou 12 secteurs
"""),

64 : _(u"""
 ******* percement tube *******
"""),

65 : _(u"""
 pour la variable d'acces "noeud_cmp", il faut un nombre pair de valeurs.
"""),

66 : _(u"""
 le mod�le et le maillage introduits ne sont pas coh�rents
"""),

67 : _(u"""
 il faut donner le maillage pour une impression au format "CASTEM".
"""),

68 : _(u"""
 vous voulez imprimer sur un m�me fichier le maillage et un champ
 ce qui est incompatible avec le format GMSH
"""),

69 : _(u"""
 L'impression d'un champ complexe n�cessite l'utilisation du mot-cl� PARTIE.
 Ce mot-cl� permet de choisir la partie du champ � imprimer (r�elle ou imaginaire).
"""),

70 : _(u"""
 Vous avez demand� une impression au format ASTER sans pr�ciser de MAILLAGE.
 Aucune impression ne sera r�alis�e car IMPR_RESU au format ASTER n'imprime qu'un MAILLAGE.
"""),

72 : _(u"""
 l'impression avec selection sur des entites topologiques n'a pas de sens au format ensight : les valeurs de tous les noeuds du maillage seront donc imprimees.
"""),

73 : _(u"""
 l'impression avec selection sur des entites topologiques n'a pas de sens au format castem  : toutes les valeurs sur tout le maillage seront donc imprimees.
"""),

74 : _(u"""
 Le maillage %(k1)s n'est pas coherent avec le maillage %(k2)s portant le resultat %(k3)s
"""),

75 : _(u"""
 fichier GIBI cr�� par SORT FORMAT non support� dans cette version
"""),

76 : _(u"""
 version de GIBI non support�e, la lecture peut �chouer
"""),

77 : _(u"""
 fichier GIBI erron�
"""),

78 : _(u"""
 le fichier maillage GIBI est vide
"""),

79 : _(u"""
 cette commande ne fait que compl�ter un r�sultat compos� d�j� existant.
 il faut donc que le r�sultat de la commande :  %(k1)s
 soit identique � l'argument "RESULTAT" :  %(k2)s 
"""),

80 : _(u"""
 pour un r�sultat de type " %(k1)s ", on ne traite que l'option ..._NOEU_...
"""),

81 : _(u"""
 lmat =0
"""),

84 : _(u"""
 il faut autant de composantes en i et j
"""),

85 : _(u"""
 il faut autant de composantes que de noeuds
"""),

92 : _(u"""
 mot cl� "TEST_NOOK" non valid� avec le mot cl� facteur "INTE_SPEC".
"""),

93 : _(u"""
 la fonction n'existe pas.
"""),

94 : _(u"""
 il faut d�finir deux param�tres pour une nappe.
"""),

95 : _(u"""
 pour le param�tre donn� on n'a pas trouv� la fonction.
"""),


}
