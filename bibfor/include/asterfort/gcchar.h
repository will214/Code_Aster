!
! COPYRIGHT (C) 1991 - 2013  EDF R&D                WWW.CODE-ASTER.ORG
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
    subroutine gcchar(ichar , iprec , time  , carteo, lfchar,&
                      lpchar, lformu, lfmult, lccomb, cartei,&
                      nomfct, newfct, oldfon)
        logical(kind=1) :: lfchar
        logical(kind=1) :: lpchar
        logical(kind=1) :: lformu
        logical(kind=1) :: lfmult
        logical(kind=1) :: lccomb
        character(len=24) :: oldfon
        character(len=8) ::  nomfct
        character(len=8) ::  newfct
        integer :: ichar
        integer :: iprec
        real(kind=8) :: time
        character(len=19) :: cartei
        character(len=19) :: carteo
    end subroutine gcchar
end interface
