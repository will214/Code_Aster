subroutine trjeve(ific, nocc)
    implicit none
#include "asterf_types.h"
#include "asterfort/assert.h"
#include "asterfort/getvis.h"
#include "asterfort/getvr8.h"
#include "asterfort/getvtx.h"
#include "asterfort/tresu_tole.h"
#include "asterfort/tresu_read_refe.h"
#include "asterfort/tresu_ordgrd.h"
#include "asterfort/tresu_obj.h"
#include "asterfort/utmess.h"
    integer, intent(in) :: ific
    integer, intent(in) :: nocc
! ----------------------------------------------------------------------
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
! ----------------------------------------------------------------------
!     COMMANDE:  TEST_RESU
!                MOT CLE FACTEUR "OBJET"
! ----------------------------------------------------------------------
    integer :: iocc, refi, refir, n1, n2, n2r, iret
    real(kind=8) :: epsi, epsir, refr, refrr
    character(len=3) :: ssigne
    character(len=8) :: crit
    character(len=16) :: tbtxt(2), tbref(2)
    character(len=24) :: nomobj
    aster_logical :: lref
    aster_logical :: skip
    real(kind=8) :: ordgrd
!     ------------------------------------------------------------------
!
    do 100 iocc = 1, nocc
        call getvtx('OBJET', 'NOM', iocc=iocc, scal=nomobj, nbret=n1)
        call getvtx('OBJET', 'VALE_ABS', iocc=iocc, scal=ssigne, nbret=n1)
        call tresu_tole(epsi, mcf='OBJET', iocc=iocc)
        call getvtx('OBJET', 'CRITERE', iocc=iocc, scal=crit, nbret=n1)
!
        call tresu_read_refe('OBJET', iocc, tbtxt)
        lref=.false.
        call getvr8('OBJET', 'PRECISION', iocc=iocc, scal=epsir, nbret=iret)
        if (iret .ne. 0) then
            lref=.true.
            tbref(1)=tbtxt(1)
            tbref(2)=tbtxt(2)
            tbtxt(1)='NON_REGRESSION'
        endif
!
        write (ific,*) '---- OBJET '
        write (ific,*) '     ',nomobj
!
        call getvis('OBJET', 'VALE_CALC_I', iocc=iocc, scal=refi, nbret=n2)
        if (n2 .eq. 1) then
            call tresu_obj(nomobj, 'I', tbtxt, refi, refr,&
                           epsi, crit, .true._1, ssigne)
            if (lref) then
                call getvis('OBJET', 'VALE_REFE_I', iocc=iocc, scal=refir, nbret=n2r)
                ASSERT(n2.eq.n2r)
                call tresu_obj(nomobj, 'I', tbref, refir, refrr,&
                               epsir, crit, .false._1, ssigne)
            endif
        endif
!
        call getvr8('OBJET', 'VALE_CALC', iocc=iocc, scal=refr, nbret=n2)
        if (n2 .eq. 1) then
            call tresu_ordgrd(refr, skip, ordgrd, mcf='OBJET', iocc=iocc)
            if (skip .and. .not. lref) then
                call utmess('A', 'TEST0_11')
            endif
            call tresu_obj(nomobj, 'R', tbtxt, refi, refr,&
                           epsi, crit, .true._1, ssigne, ignore=skip,&
                           compare=ordgrd)
            if (lref) then
                call getvr8('OBJET', 'VALE_REFE', iocc=iocc, scal=refrr, nbret=n2r)
                ASSERT(n2.eq.n2r)
                call tresu_obj(nomobj, 'R', tbref, refir, refrr,&
                               epsir, crit, .false._1, ssigne)
            endif
        endif
        write (ific,*)' '
100 end do
!
!
end subroutine
