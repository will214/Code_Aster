!
! COPYRIGHT (C) 1991 - 2016  EDF R&D                WWW.CODE-ASTER.ORG
!
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
! 1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
!
#include "asterf_types.h"
!
interface 
    subroutine xpoajd(elrefp, ino, nnop, lsn, lst,&
                      ninter, iainc, ncompa, typma, co, igeom,&
                      jdirno, nfiss, jheavn, ncompn, he, ndime,&
                      ndim, cmp, nbcmp, nfh, nfe,&
                      ddlc, ima, jconx1, jconx2, jcnsv1,&
                      jcnsv2, jcnsl2, nbnoc, inntot, inn,&
                      nnn, contac, lmeca, pre1, heavno,&
                      nlachm, lacthm, jbaslo, &
                      jlsn, jlst, jstno, ka, mu)
        integer :: nbcmp
        integer :: nfiss
        integer :: nnop
        character(len=8) :: elrefp
        integer :: ino
        real(kind=8) :: lsn(nfiss)
        real(kind=8) :: lst(nfiss)
        integer :: ninter(4)
        integer :: iainc
        character(len=8) :: typma
        real(kind=8) :: co(3)
        integer :: igeom
        integer :: jdirno
        integer :: jfisno
        integer :: jheavn
        integer :: ncompn
        integer :: he(nfiss)
        integer :: ndime
        integer :: ndim
        integer :: cmp(*)
        integer :: nfh
        integer :: nfe
        integer :: ddlc
        integer :: ima
        integer :: jconx1
        integer :: jconx2
        integer :: jcnsv1
        integer :: jcnsv2
        integer :: jcnsl2
        integer :: nbnoc
        integer :: inntot
        integer :: inn
        integer :: nnn
        integer :: contac
        aster_logical :: lmeca
        aster_logical :: pre1
        integer :: ncompa
        integer :: heavno(20, 3)
        integer :: nlachm(2)
        integer :: lacthm(16)
        integer :: jbaslo
        integer :: jlsn
        integer :: jlst
        integer :: jstno
        real(kind=8) :: ka
        real(kind=8) :: mu
    end subroutine xpoajd
end interface 
