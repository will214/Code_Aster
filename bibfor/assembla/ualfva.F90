subroutine ualfva(mataz, basz)
    implicit none
#include "asterf_types.h"
#include "jeveux.h"
!
#include "asterfort/assert.h"
#include "asterfort/crsmos.h"
#include "asterfort/jecrec.h"
#include "asterfort/jecroc.h"
#include "asterfort/jedema.h"
#include "asterfort/jedetr.h"
#include "asterfort/jeecra.h"
#include "asterfort/jeexin.h"
#include "asterfort/jelibe.h"
#include "asterfort/jelira.h"
#include "asterfort/jemarq.h"
#include "asterfort/jeveuo.h"
#include "asterfort/jexnum.h"
    character(len=*) :: mataz, basz
!     ------------------------------------------------------------------
! ======================================================================
! COPYRIGHT (C) 1991 - 2016  EDF R&D                  WWW.CODE-ASTER.ORG
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
!     creation de l'objet mataz.VALM a partir de l'objet mataz.UALF
!     l'objet .UALF doit contenir la matrice initiale non factorisee :
!       - on cree l'objet.valm
!       - on detruit .ualf (a la fin de la routine)
!       - on cree le stockage morse dans le nume_ddl s'il n'existe pas.
!
!     cette routine ne devrait etre utilisee que rarement :
!        lorsque la matr_asse a ete cree sous la forme .ualf pour des
!        raisons historiques.
!
! ---------------------------------------------------------------------
! in  jxvar k19 mataz     : nom d'une s.d. matr_asse
! in        k1  basz      : base de creation pour .VALM
!                  si basz=' ' on prend la meme base que celle de .ualf
!     remarque : on detruit l'objet .UALF
!
!-----------------------------------------------------------------------
!     VARIABLES LOCALES
    character(len=1) :: base, tyrc
    character(len=14) :: nu
    character(len=19) :: stomor, matas
    integer :: neq, nbloc, nblocm, iret
    integer :: jsmhc
    integer :: itbloc, ieq, ibloc, jualf, jvale, kterm, nbterm, ilig
    integer :: ismdi, ismdi0, ibloav, iscdi, kblocm, nblocl
    integer, pointer :: smde(:) => null()
    integer, pointer :: smdi(:) => null()
    character(len=24), pointer :: refa(:) => null()
!   ------------------------------------------------------------------


    call jemarq()
    matas=mataz
    base=basz
    if (base .eq. ' ') call jelira(matas//'.UALF', 'CLAS', cval=base)

!   -- .VALM ne doit pas exister :
    call jeexin(matas//'.VALM', iret)
    ASSERT(iret.eq.0)

    call jeveuo(matas//'.REFA', 'L', vk24=refa)
    nu=refa(2)(1:14)
    stomor=nu//'.SMOS'

!   -- On ne sait traiter que les matrices generalisees :
    ASSERT(refa(10).eq.'GENE')

    call jeveuo(stomor//'.SMDE', 'L', vi=smde)
    neq=smde(1)
    nbloc= smde(3)
    call jeveuo(stomor//'.SMDI', 'L', vi=smdi)
    call jeveuo(stomor//'.SMHC', 'L', jsmhc)
    itbloc= smde(2)

    call jelira(matas//'.UALF', 'NMAXOC', nblocl)
    ASSERT(nblocl.eq.nbloc .or. nblocl.eq.2*nbloc)
    nblocm=1
    if (nblocl .eq. 2*nbloc) nblocm=2

!   -- reel ou complexe ?
    call jelira(matas//'.UALF', 'TYPE', cval=tyrc)
    ASSERT(tyrc.eq.'R' .or. tyrc.eq.'C')


!     1. Allocation de .VALM :
!     ----------------------------------------
    call jecrec(matas//'.VALM', base//' V '//tyrc, 'NU', 'DISPERSE', 'CONSTANT',&
                nblocm)
    call jeecra(matas//'.VALM', 'LONMAX', itbloc)
    do kblocm = 1, nblocm
        call jecroc(jexnum(matas//'.VALM', kblocm))
    enddo


!     2. Remplissage de .VALM :
!     ----------------------------------------
    do kblocm = 1, nblocm
        call jeveuo(jexnum(matas//'.VALM', kblocm), 'E', jvale)
        ibloav=0+nbloc*(kblocm-1)
        ismdi0=0
        do 1 ieq = 1, neq
            iscdi=smdi(ieq)         
            ibloc=1+nbloc*(kblocm-1)

!          -- on ramene le bloc en memoire si necessaire:
            if (ibloc .ne. ibloav) then
                call jeveuo(jexnum(matas//'.UALF', ibloc), 'L', jualf)
                if (ibloav .ne. 0) then
                    call jelibe(jexnum(matas//'.UALF', ibloav))
                endif
                ibloav=ibloc
            endif

            ismdi=smdi(ieq)
            nbterm=ismdi-ismdi0

            do 2 kterm = 1, nbterm
                ilig=zi4(jsmhc-1+ismdi0+kterm)
                if (tyrc .eq. 'R') then
                    zr(jvale-1+ismdi0+kterm)=zr(jualf-1+ iscdi +ilig-&
                    ieq)
                else
                    zc(jvale-1+ismdi0+kterm)=zc(jualf-1+ iscdi +ilig-&
                    ieq)
                endif
  2         continue
            ASSERT(ilig.eq.ieq)

            ismdi0=ismdi
  1     continue
    end do



    call jedetr(matas//'.UALF')

    call jedema()
!     CALL CHEKSD('sd_matr_asse',MATAS,IRET)
end subroutine
