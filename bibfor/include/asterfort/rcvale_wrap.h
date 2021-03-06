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
    subroutine rcvale(nommaz, phenom, nbpar, nompar, valpar,&
                      nbres, nomres, valres, icodre, iarret)
        integer, intent(in) :: nbres
        integer, intent(in) :: nbpar
        character(len=*), intent(in) :: nommaz
        character(len=*), intent(in) :: phenom
        character(len=8), intent(in) :: nompar(nbpar)
        real(kind=8), intent(in) :: valpar(nbpar)
        character(len=16), intent(in) :: nomres(nbres)
        real(kind=8), intent(out) :: valres(nbres)
        integer, intent(out) :: icodre(nbres)
        integer, intent(in) :: iarret
    end subroutine rcvale
end interface
