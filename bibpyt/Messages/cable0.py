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
    1: _(u"""
INST_FIN plus petit que INST_INIT.
"""),

    2: _(u"""
Le mot-clé MAILLE est interdit, utilisez GROUP_MA.
"""),

    3: _(u"""
Parmi les occurrences de CABLE_BP, le mot-clé ADHERENT renseigné dans DEFI_CABLE_BP
est 'OUI' pour certaines et 'NON' pour d'autres.
CALC_PRECONT ne peut pas traiter ce type de cas
"""),

    4: _(u"""
La liste d’instant fournie n’a pas permis d’identifier l’instant initial et 
l’instant final de la mise en précontrainte. 

Si vous avez renseigné l'opérande INST_INIT du mot-clé facteur INCREMENT, alors
cette valeur est prise en compte comme instant initial.
Si reuse est activé, l'instant initial est alors le dernier instant présent dans
l'objet résultat renseigné dans reuse.
Dans les autres cas, l'instant initial est le premier instant de la liste fournie.

Si vous avez renseigné l'opérande INST_FIN du mot-clé facteur INCREMENT, alors
cette valeur est prise en compte comme instant final. Sinon l'instant final
est la dernière valeur de la liste d'instants fournie.

"""),

}
