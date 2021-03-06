subroutine mefsma(matm, mata, matr, nugene, masgen,&
                  amogen, riggen)
    implicit   none
#include "jeveux.h"
!
#include "asterfort/jedema.h"
#include "asterfort/jemarq.h"
#include "asterfort/jeveuo.h"
#include "asterfort/mefsm1.h"
    real(kind=8) :: matm(*), mata(*), matr(*)
    character(len=19) :: masgen, amogen, riggen
!-----------------------------------------------------------------------
! ======================================================================
! COPYRIGHT (C) 1991 - 2015  EDF R&D                  WWW.CODE-ASTER.ORG
! THIS PROGRAM IS FREE SOFTWARE; YOU CAN REDISTRIBUTE IT AND/OR MODIFY
! IT UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICENSE AS PUBLISHED BY
! THE FREE SOFTWARE FOUNDATION; EITHER VERSION 2 OF THE LICENSE, OR
! (AT YOUR OPTION) ANY LATER VERSION.
!
! THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT
! WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF
! MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. SEE THE GNU
! GENERAL PUBLIC LICENSE FOR MORE DETAILS.
!
! YOU SHOULD HAVE RECEIVED A COPY OF THE GNU GENERAL PUBLIC LICENSE
! ALONG WITH THIS PROGRAM; IF NOT, WRITE TO EDF R&D CODE_ASTER,
!   1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
! ======================================================================
!-----------------------------------------------------------------------
!
    integer ::   nbmode, nterm, nbloc
    character(len=1) :: base
    character(len=14) :: nugene
    character(len=19) :: nomnum, nomsto
    character(len=24), pointer :: refn(:) => null()
    integer, pointer :: scde(:) => null()
! DEB------------------------------------------------------------------
!
    call jemarq()
!
    nomnum = nugene//'.NUME'
    nomsto = nugene//'.SLCS'
!
    call jeveuo(nomsto//'.SCDE', 'L', vi=scde)
    nbmode = scde(1)
    nterm = scde(2)
    nbloc = scde(3)
!
    call jeveuo(nomnum//'.REFN', 'L', vk24=refn)
    base = refn(1)
!
    call mefsm1(matm, masgen, base, nomnum, nomsto,&
                nbmode, nbloc, nterm)
!
    call mefsm1(mata, amogen, base, nomnum, nomsto,&
                nbmode, nbloc, nterm)
!
    call mefsm1(matr, riggen, base, nomnum, nomsto,&
                nbmode, nbloc, nterm)
!
    call jedema()
!
end subroutine
