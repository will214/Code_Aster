!
! COPYRIGHT (C) 1991 - 2015  EDF R&D                WWW.CODE-ASTER.ORG
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
interface
    subroutine nzcalc(crit, phasp, nz, fmel, seuil,&
                      dt, trans, rprim, deuxmu, eta,&
                      unsurn, dp, iret)
        real(kind=8) :: crit(3)
        real(kind=8) :: phasp(5)
        integer :: nz
        real(kind=8) :: fmel
        real(kind=8) :: seuil
        real(kind=8) :: dt
        real(kind=8) :: trans
        real(kind=8) :: rprim
        real(kind=8) :: deuxmu
        real(kind=8) :: eta(5)
        real(kind=8) :: unsurn(5)
        real(kind=8) :: dp
        integer :: iret
    end subroutine nzcalc
end interface
