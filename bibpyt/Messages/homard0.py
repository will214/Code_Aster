#@ MODIF homard0 Messages  DATE 31/01/2011   AUTEUR NICOLAS G.NICOLAS 
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

def _(x) : return x

cata_msg={
1: _("""
Cette macro commande est inconnue.
"""),

2: _("""
Erreur : %(k1)s
"""),

3: _("""
Impossible de tuer le fichier %(k1)s
"""),

4: _("""
Impossible de cr�er le r�pertoire de travail pour HOMARD : %(k1)s
"""),

5: _("""
Impossible de d�truire le fichier :%(k1)s
"""),

6: _("""
La v�rification de l'interp�n�tration peut etre tr�s longue.
Il ne faut l'utiliser que volontairement. Voir la documentation.
"""),

7: _("""
D�s que le nombre de mailles est important, la v�rification de l'interp�n�tration peut devenir tr�s longue.
En principe, on ne devrait l'utiliser que dans les cas suivants :
  . Informations sur un maillage avec MACR_INFO_MAIL
  . Debogage sur une adaptation avec MACR_ADAP_MAIL
Conseil :
Pour un usage courant de l'adaptation, il est recommand� de passer � NON toutes les
options de controle ; autrement dit, laisser les options par d�faut.
"""),

8: _("""
Impossible de trouver le r�pertoire de travail pour HOMARD : %(k1)s
Certainement un oubli dans le lancement de la poursuite.
"""),

9: _("""
Vous demandez une adaptation du maillage %(k1)s vers %(k2)s
Auparavant, vous aviez d�j� fait une adaptation qui a produit le maillage %(k3)s
Ce maillage %(k3)s est le r�sultat de %(i1)d adaptation(s) � partir du maillage initial %(k4)s

Les arguments que vous avez donn�s � MACR_ADAP_MAIL ne permettront pas de tenir compte
de l'historique d'adaptation. Est-ce volontaire ?
Pour poursuivre la s�quence, il faudrait partir maintenant de %(k3)s.

"""),

}
