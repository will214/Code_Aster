# coding=utf-8
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
# person_in_charge: josselin.delmas at edf.fr

# Messages pour les éléments discrets non-linéaires
cata_msg = {

    1: _(u"""
Pour l'élément discret %(k1)s .
Il n'y a pas de rotation non-linéaire possible.
"""),

    2: _(u"""
Pour l'élément discret %(k1)s .
Il n'y a pas de comportement non-linéaire possible suivant Z
ou en rotation autour de X,Y en 2D.
"""),

    3: _(u"""
Pour l'élément discret %(k1)s .
Il n'y a pas de comportement non-linéaire possible en rotation
ou suivant Z en 2D.
"""),

    4: _(u"""
Pour l'élément discret %(k5)s .
La raideur tangente est nulle ou trop petite.
Vérifier les caractéristiques : K1 K2 K3 UNSUR_K1 UNSUR_K2 UNSUR_K3

La raideur tangente : 1/K1 + 1/K3 + K2/(K1*K3) ne doit pas être nulle ou trop petite.

Pour information :
   Modèle   : <%(k1)s>, Option   : <%(k2)s>
   Comportement : <%(k3)s>, Relation : <%(k4)s>
   Maille   : <%(k5)s>
"""),

    5: _(u"""
Pour l'élément discret %(k5)s .
Les caractéristiques sont obligatoirement données dans le repère local du discret.

Pour information :
   Modèle   : <%(k1)s>, Option   : <%(k2)s>
   Comportement : <%(k3)s>, Relation : <%(k4)s>
   Maille   : <%(k5)s>
"""),

    6: _(u"""
Pour les éléments discrets il faut définir un repère dans AFFE_CARA_ELEM

Pour information :
   Modèle   : <%(k1)s>, Option   : <%(k2)s>
   Comportement : <%(k3)s>, Relation : <%(k4)s>
   Maille   : <%(k5)s>
"""),

    7 : _(u"""
Le Comportement <%(k4)s> affecté à un DISCRET est non valide.

Pour information :
   Modèle   : <%(k1)s>, Option   : <%(k2)s>
   Comportement : <%(k3)s>, Relation : <%(k4)s>
   Maille   : <%(k5)s>
"""),

    8 : _(u"""
Pour les discrets, le seul comportement élastique valide est ELAS.

Pour information :
   Modèle   : <%(k1)s>, Option   : <%(k2)s>
   Comportement : <%(k3)s>, Relation : <%(k4)s>
   Maille   : <%(k5)s>
"""),

    9 : _(u"""
Il ne faut pas demander TR derrière CARA si le type d'élément discret ne prend pas en compte la rotation.
"""),

    10 : _(u"""
Pour l'élément DISCRET de modèle <%(k1)s> la matrice de décharge est non développée.

Pour information :
   Modèle   : <%(k1)s>, Option   : <%(k2)s>
   Comportement : <%(k3)s>, Relation : <%(k4)s>
   Maille   : <%(k5)s>
"""),

    11 : _(u"""
La loi <%(k4)s> doit être utilisée avec des éléments du type DIS_TR_L : élément SEG2 + modélisation DIS_TR

Pour information :
   Modèle   : <%(k1)s>, Option   : <%(k2)s>
   Comportement : <%(k3)s>, Relation : <%(k4)s>
   Maille   : <%(k5)s>
"""),

    12 : _(u"""
La commande %(k4)s ne sait pas traiter les matrices non-symétriques, pour l'option %(k1)s.
Message de la routine %(k3)s, pour l'élément %(k2)s.
"""),

    13 : _(u"""
L'élément %(k1)s est inconnu pour la maille %(k3)s.
Message de la routine %(k2)s.
"""),

    14 : _(u"""
L'option %(k1)s est inconnue pour l'élément %(k2)s.
Message de la routine %(k3)s.
"""),

    15 : _(u"""
L'option %(k1)s ne sait pas traiter l'élément %(k2)s.
Message de la routine %(k3)s.
"""),

    16 : _(u"""
Il est interdit d'avoir des éléments discrets 2D et 3D dans un modèle.
"""),

    17 : _(u"""
Votre modélisation ne comporte pas d'élément discret.
"""),

    18 : _(u"""
Seul DEFORMATION ='PETIT' est possible pour les éléments discrets.
"""),

    20 : _(u"""
Votre modélisation doit être soit 2D soit 3D.
Il est interdit d'avoir des discrets sur une modélisation %(k1)s.
"""),

    21 : _(u"""
AFFE_CARA_ELEM/RIGI_PARASOL
  Le nombre de valeurs fournies sous VALE ne correspond pas au nombre attendu.
  Vous devez vérifier l'adéquation des dimensions des éléments sous CARA avec le nombre de valeur sous VALE.
"""),

    25 : _(u"""
Vous utilisez des discrets %(k1)s alors que vous n'avez pas affecté ses caractéristiques.
Il faut vérifier les affectations sous AFFE_CARA_ELEM/DISCRET OU DISCRET_2D.
"""),

    26 : _(u"""
Vous utilisez la matrice de MASSE pour un discret %(k1)s alors que vous n'avez pas affecté
les caractéristiques de masses. Par défaut la masse est nulle.
Il faut vérifier les affectations sous AFFE_CARA_ELEM/DISCRET.
"""),

    27 : _(u"""
Vous utilisez la matrice de RAIDEUR pour un discret %(k1)s alors que vous n'avez pas affecté
les caractéristiques de raideurs. Par défaut la raideur est nulle.
Il faut vérifier les affectations sous AFFE_CARA_ELEM/DISCRET.
"""),

    28 : _(u"""
Vous utilisez la matrice d'amortissement pour un discret %(k1)s alors que vous n'avez pas affecté
les caractéristiques d'amortissements. Par défaut l'amortissement est nul.
Il faut vérifier les affectations sous AFFE_CARA_ELEM/DISCRET.
"""),

    30 : _(u"""Informations :
   Maille de nom %(k1)s, de %(i1)d noeud(s).
   Nom et coordonnées des noeuds :
"""),
    31 : _(u"""      %(k1)8s   %(r1)12.5E   %(r2)12.5E   %(r3)12.5E
"""),

    32 : _(u"""
Erreur d'utilisation :
  Pour l'option %(k1)s, l'élément %(k2)s doit avoir des caractéristiques symétriques.
Risques et conseils :
  Dans la commande AFFE_CARA_ELEM, il ne faut pas utiliser le mot-clé DISCRET / SYME='NON'
  pour ces éléments.
"""),


    40 : _(u"""
L'utilisation des discrets non-symétriques n'est actuellement pas possible pour des calculs non-linéaires.
"""),

    41: _(u"""
DYNA_VIBRA : Pour l'élément discret de type DIS_VISC.
La raideur tangente est nulle ou trop petite.
Vérifier les caractéristiques : K1 K2 K3 UNSUR_K1 UNSUR_K2 UNSUR_K3

La raideur tangente : 1/K1 + 1/K3 + K2/(K1*K3) ne doit pas être nulle ou trop petite.
"""),

    42: _(u"""
DYNA_VIBRA : Pour l'élément discret de type DIS_VISC ou DIS_ECRO_TRAC

L'intégration de la loi de comportement du discret pose problème.
L'erreur est supérieure à RESI_INTE_RELA=%(r1)12.5E pour un nombre
d'itération maximum de ITER_INTE_MAXI=%(i1)d.

Conseils :
  Augmenter ITER_INTE_MAXI
  Augmenter le nombre de pas d'intégration.
  Modifier votre liste d'instant
"""),

    43: _(u"""
DYNA_VIBRA : Pour l'élément discret de type DIS_VISC ou DIS_ECRO_TRAC.

Sa longueur est nulle ou trop petite.
Il n'est pas possible de calculer le vecteur directeur de l'élément.

"""),

    50 : _(u"""
L'utilisation du comportement DIS_CHOC avec frottement (COULOMB !=0 dans DEFI_MATERIAU/DIS_CONTACT)
n'est pas encore développé pour l'élément %(k1)s
"""),

    52 : _(u"""
Dans le cas d'une analyse réalisée avec DYNA_NON_LINE, l'utilisation du comportement DIS_CHOC avec
le matériau DIS_CONTACT peut conduire à des résultats faux.
Le critère de Coulomb peut ne pas être respecté. On doit toujours avoir :
                Effort tangentiel <= Coefficient Coulomb * Effort Normal

Le cas identifié est :
  Analyse réalisée avec DYNA_NON_LINE
  et frottement de COULOMB <> 0
  et (AMOR_NOR <> 0 ou AMOR_TAN <> 0)

Dans ce cas particulier l'utilisateur doit vérifier le critère de Coulomb en post-traitant les
efforts sur le discret concerné par la loi de comportement.

Exemple de commandes :
# Coefficient de frottement de Coulomb
mu = 0.3
# Si Seuil <=0.0 le critère est vérifié
Seuil = FORMULE(NOM_PARA=('N','VY','VZ'), VALE="(VY**2+VZ**2)**0.5 - mu*N" )
#
TABLE=CREA_TABLE(RESU=_F(RESULTAT=RESU,GROUP_MA='Le discret',NOM_CHAM='SIEF_ELGA',),)
#
TABLE = CALC_TABLE(reuse=TABLE, TABLE=TABLE,
    ACTION= _F(OPERATION='OPER',NOM_PARA='SEUIL',FORMULE=Seuil,),
)

"""),

    61 : _(u"""
Le prolongement à droite étant exclu pour la fonction %(k1)s, il n'est pas
possible d'extrapoler la fonction au delà de %(r1)f
"""),

    62 : _(u"""
Le Comportement <%(k1)s> est non valide.
La définition de la fonction <%(k2)s> est incorrecte.
    - elle doit être définie avec DEFI_FONCTION
    - le premier point doit être (0.0, 0.0)
    - définie par au moins 3 points
    - le nom du paramètre est DX
    - interpolation linéaire entre les points
    - une fonction monotone croissante
    - dérivée de la fonction <= raideur initiale
Elle ne peut pas être :
    - une constante
    - une nappe
    - prolongée à gauche ou à droite
"""),

}
