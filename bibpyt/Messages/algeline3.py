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

cata_msg = {




    2: _(u"""
 Le mot-clé MAILLAGE est obligatoire avec le mot-clé CREA_GROUP_MA.
"""),

    3: _(u"""
 Le mot-clé MAILLAGE est obligatoire avec le mot-clé CREA_POI1.
"""),

    4: _(u"""
 Le mot-clé MAILLAGE est obligatoire avec le mot-clé REPERE.
"""),

    5: _(u"""
 Sous le mot-clé "NOM_ORIG" du mot-clé facteur "REPERE",
 on ne peut donner que les mots "CDG" ou "TORSION".
"""),

    6: _(u"""
 Maille non créée  %(k1)s
"""),

    7: _(u"""
 Le groupe de mailles '%(k1)s' existe déjà.

 Conseil :
    Si vous souhaitez utiliser un nom de groupe existant, il suffit
    de le détruire avec DEFI_GROUP / DETR_GROUP_MA.
"""),




    9: _(u"""
 Mode non compatible.
"""),

    10: _(u"""
 Masses effectives unitaires non calculées par NORM_MODE
"""),

    11: _(u"""
 L'extraction des modes a échoué.
 La structure de données MODE_MECA est vide ou aucun mode ne remplit le critère d'extraction.
 Conseils & solution :
   Vérifiez le résultat de votre calcul modal et/ou modifiez votre filtre d'extraction"
"""),

    12: _(u"""
 Le nombre de noeuds sur le contour est insuffisant pour déterminer correctement
 les ordres de coque.
"""),

    13: _(u"""
 L'azimut n'est pas défini pour un des noeuds de la coque.
"""),

    14: _(u"""
 ordre de coque nul pour l'un des modes pris en compte pour le couplage.
 Le modèle de résolution ne supporte pas une telle valeur.
"""),

    15: _(u"""
 détermination du déphasage pour le mode  %(k1)s  :
 le déterminant du système issu du moindre carré est nul
Ce message est un message d'erreur développeur.
Contactez le support technique.
"""),

    16: _(u"""
 détermination du déphasage pour le mode  %(k1)s  :
Ce message est un message d'erreur développeur.
Contactez le support technique.
"""),

    17: _(u"""
 Pivot nul dans la résolution du système complexe
"""),

    18: _(u"""
 Annulation du numérateur dans l'expression d'un coefficient donnant
 la solution du problème fluide instationnaire
"""),

    19: _(u"""
 Détermination des valeurs propres de l'opérateur différentiel :
 existence d'une racine double
"""),

    20: _(u"""
 La %(k1)s ème valeur propre est trop petite.
"""),

    21: _(u"""
 La MATR_ASSE  %(k1)s  n'est pas stockée "morse" :
 le GCPC est donc impossible.
"""),

    22: _(u"""
 Conflit : une matrice stockée morse ne peut avoir qu'un bloc
"""),

    23: _(u"""
Problème :
  Le préconditionnement LDLT_INC d'une matrice complexe n'est pas implémenté
Conseils & solution :
  Il faut choisir un autre solveur que GCPC
"""),

    24: _(u"""
 Résolution LDLT : erreur de programmation.
"""),

    25: _(u"""
 Les effets de couplage fluide-élastique n'ont pas été calculés pour la vitesse
 fluide demandée : (%(r1)f).

 Conseil :
  Vérifier la liste de vitesses renseignée lors du calcul des propriétés vibratoires
  de la structure en écoulement avec l'opérateur CALC_FLUI_STRU.
"""),







    30: _(u"""
 Matrices A et B incompatibles pour l'opération *
"""),

    31: _(u"""
 La section de la poutre doit être constante.
"""),

    32: _(u"""
 Structure non tubulaire
"""),

    33: _(u"""
 On ne traite pas ce type de CHAM_ELEM
Ce message est un message d'erreur développeur.
Contactez le support technique.
"""),

    34: _(u"""
 Le CHAM_NO %(k1)s  n'existe pas
"""),

    35: _(u"""
Le solveur linéaire MULT_FRONT factorise une matrice généralisée.
Il a détecté l'existence d'au moins une liaison entre degrés de liberté.
Ceci est hors de son périmètre standard et cela peut conduire à un arrêt prochain du code.

Conseil :
  Sur ces cas de figures, utiliser la prochaine fois, plutôt les autres solveurs linéaires directs,
  par exemple, MUMPS (cf. mot-clé SOLVEUR/METHODE) ou LDLT (si le problème est de petite taille).
 """),

    37: _(u"""
  GCPC n"est pas prévu pour une matrice complexe
"""),

    38: _(u"""
 Pas de matrice de préconditionnement : on s'arrête
"""),

    40: _(u"""
Ce message est un message d'erreur développeur.
Contactez le support technique.
"""),

    41: _(u"""
La matrice possède des ddls imposés éliminés: il faut un chargement de type AFFE_CHAR_CINE
"""),

    42: _(u"""
La matrice et le vecteur cinématique ne contiennent pas des valeurs de même type
"""),

    43: _(u"""
Attention :
  La pile des matrices frontales a une longueur (%(i1)d) qui, en octets, sera supérieure à l'entier maximum pour cette machine (%(i2)d).
  Vous aurez un problème dans une allocation ultérieure.
Conseil :
  Utilisez une machine 64 bits. Si vous y êtes déjà votre étude est vraiment trop volumineuse !
"""),


    44: _(u"""
La méthode de résolution:  %(k1)s  est inconnue. on attend LDLT,GCPC, MULT_FRONT
"""),

    45: _(u"""
 méthode de BATHE et WILSON : convergence non atteinte
"""),


    48: _(u"""
Cet opérateur a besoin du "procédé de STURM" pour tester la validité de modes propres ou
pour nourrir un algorithme de recherche de modes propres (dichotomie...). Or celui-ci
ne fonctionne, pour l'instant, que sur des matrices réelles et symétriques.
  --> La matrice utilisée ici, %(k1)s ne répond pas a ces critères !
"""),


    51: _(u"""
Le tableau B est insuffisamment dimensionné pour l'opération *
"""),

    52: _(u"""
Attention :
  Le bloc %(i1)d a une longueur (%(i2)d) qui, en octets, sera supérieure à l'entier maximum pour cette machine (%(i3)d).
  Vous aurez un problème dans une allocation ultérieure.
Conseil :
  Utilisez une machine 64 bits. Si vous y êtes déjà votre étude est vraiment trop volumineuse.
"""),

    53: _(u"""
Toutes les fréquences sont des fréquences de corps rigide
"""),

    54: _(u"""
Calcul des NUME_MODE : matrice non inversible pour la fréquence considérée
"""),

    55: _(u"""
Problème à la résolution du système réduit.
"""),

    56: _(u"""
Valeur propre infinie trouvée
"""),

    57: _(u"""
Méthode QR : problème de convergence
"""),

    58: _(u"""
Il y a des valeurs propres très proches
"""),

    60: _(u"""
La matrice : %(k1)s a une numérotation incohérente avec le NUME_DDL.
"""),

    61: _(u"""
Le concept "%(k1)s" a été créé avec les matrices
 MATR_RIGI (ou MATR_A) :                   %(k2)s
 MATR_MASS (ou MATR_RIGI_GEOM ou MATR_B) : %(k3)s
 MATR_AMOR (ou MATR_C) :                   %(k4)s
 et non avec celles passées en arguments.
"""),

    62: _(u"""
Le concept "%(k1)s" a été créé avec les matrices
 MATR_RIGI (ou MATR_A) :                   %(k2)s
 MATR_MASS (ou MATR_RIGI_GEOM ou MATR_B) : %(k3)s
 et non avec celles passées en arguments.
"""),

    63: _(u"""
Le système à résoudre n'a pas de DDL actif.

Conseil :
vérifier que les DDL ne sont pas tous encastrés.
"""),

    64: _(u"""
On trouve plus de 9999 valeurs propres dans la bande demandée
"""),






    69: _(u"""
Option  %(k1)s non reconnue.
"""),

    70: _(u"""
Le type des valeurs varie d'un mode à l'autre, récupération impossible.
"""),

    71: _(u"""
Le nombre d'équations est variable d'un mode à l'autre, récupération impossible.
"""),

    72: _(u"""
Problème interne ARPACK
Ce message est un message d'erreur développeur.
Contactez le support technique.
"""),

    73: _(u"""
Problème, augmenter DIM_SOUS_ESPACE
Ce message est un message d'erreur développeur.
Contactez le support technique.
"""),

    74: _(u"""
Problème interne LAPACK
Ce message est un message d'erreur développeur.
Contactez le support technique.
"""),

    75: _(u"""
Problème de construction du vecteur initial.

Conseil :
si possible, diminuer NMAX_FREQ (ou NMAX_CHAR_CRIT selon le type d'étude).
"""),

    76: _(u"""
Problème interne LAPACK
Ce message est un message d'erreur développeur.
Contactez le support technique.
"""),

    77: _(u"""
Problème interne LAPACK
Ce message est un message d'erreur développeur.
Contactez le support technique.
"""),

    78: _(u"""
Aucune valeur propre à la précision requise.

Conseils :
augmenter PREC_SOREN ou NMAX_ITER_SOREN
ou augmenter DIM_SOUS_ESPACE.
"""),

    79: _(u"""
La position modale d'une des fréquences est négative ou nulle
votre système matriciel est sûrement fortement singulier
(ceci correspond généralement à un problème dans la modélisation).
"""),

    80: _(u"""
MODE à créer avant appel
Ce message est un message d'erreur développeur.
Contactez le support technique.
"""),

    81: _(u"""
  Le shift=%(r1)g
  utilisé pour construire la matrice dynamique coïncide avec une valeur propre !
  Avec l'option 'CENTRE', ce shift vaut %(k1)s,
  Avec l'option 'BANDE', c'est le milieu de la bande sélectionnée,
  Avec l'option 'PLUS_PETITE' ou 'TOUT', il prend la valeur 0.

  Malgré la stratégie de décalage du shift, cette matrice dynamique reste
  numériquement singulière.

  -> Risque :
  Cette matrice étant abondamment utilisée pour résoudre des systèmes linéaires
  à chaque itération du processus modal, cette quasi singularité peut fausser les résultats
  (mauvais conditionnement matriciel).

  -> Conseils :
  La structure analysée présente probablement des modes de corps rigide.

    * si aucun mode de corps rigide n'était attendu :
  Vous pouvez modifier les paramètres du solveur linéaire (par exemple METHODE ou NPREC),
  ou ceux de l'algorithme de décalage (PREC_SHIFT, NMAX_ITER_SHIFT et %(k2)s)
  pour vérifier qu'il s'agit bien d'une singularité et non d'un problème numérique ponctuel.
  Si c'est une singularité, vérifiez la mise en donnée du problème :
  conditions aux limites, maillage (présence de noeuds / mailles orphelin(e)s), unités, ...

   * si ces modes étaient attendus et que vous ne voulez pas les calculer :
  Utilisez l'option 'BANDE' avec une borne inférieure suffisamment positive (par exemple 1.e-1).
   * si ces modes étaient attendus et que vous voulez les calculer :
  - utilisez l'option 'BANDE' avec une borne inférieure légèrement négative (par exemple -1.e-1).
  - utilisez la méthode 'TRI_DIAG' avec OPTION='MODE_RIGIDE'.
"""),

    82: _(u"""
  Cette borne minimale de la bande de recherche est une valeur propre !
"""),

    83: _(u"""
  Cette borne maximale de la bande de recherche est une valeur propre !
"""),

    84: _(u"""
  Malgré la stratégie de décalage, la matrice dynamique reste numériquement
  singulière.

  -> Risque :
  Le test de Sturm qui sert à évaluer le nombre de modes présents dans l'intervalle
  peut être faussé.

  -> Conseils :
  Vous pouvez modifier les paramètres du solveur linéaire (par exemple METHODE ou NPREC),
  ou ceux de l'algorithme de décalage (PREC_SHIFT, NMAX_ITER_SHIFT et %(k1)s) pour
  vérifiez qu'il s'agit bien d'une singularité et non d'un problème numérique ponctuel.

  S'il ne s'agit pas d'un test de vérification ('VERIFICATION A POSTERIORI DES MODES'),
  vous pouvez aussi relancer un autre calcul en décalant les bornes de l'intervalle de
  recherche pour éviter cette fréquence.
"""),

    85: _(u"""
  La borne inférieure de l'intervalle a été décalée plusieurs fois car elle est trop proche
  d'une valeur propre. En raison de ces décalages, elle est devenue plus grande que la borne
  supérieure !

  -> Conseils :
  Relancez votre calcul en espaçant suffisamment les bornes de l'intervalle (en tenant compte
  des valeurs des paramètres de décalage NMAX_ITER_SHIFT et PREC_SHIFT).
"""),



    90: _(u"""
Objet inexistant.
Ce message est un message d'erreur développeur.
Contactez le support technique.
"""),







    93: _(u"""
Les CHAM_NO  %(k1)s  et  %(k2)s  sont de type inconnu  %(k3)s
"""),

    94: _(u"""
Le CHAM_NO  %(k1)s  de type  %(k2)s  ne peut être copié dans le CHAM_NO  %(k3)s  de type  %(k4)s
"""),

    95: _(u"""
Champ à représentation constante : cas non traité.
"""),



    97: _(u"""
Type de tri inconnu
"""),

    98: _(u"""
Problème interne LAPACK
Ce message est un message d'erreur développeur.
Contactez le support technique.
"""),

    99: _(u"""
Problème interne LAPACK
Ce message est un message d'erreur développeur.
Contactez le support technique.
"""),
}
