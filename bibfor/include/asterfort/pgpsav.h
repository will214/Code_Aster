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
    subroutine pgpsav(sd_pgp, param, lonvec, iobs, kscal,&
                      iscal, rscal, cscal, kvect, ivect,&
                      rvect, cvect, savejv)
        character(len=*)          , intent(in) :: sd_pgp
        character(len=*)          , intent(in) :: param
        integer                   , intent(in) :: lonvec
        integer,          optional, intent(in) :: iobs
        character(len=*), optional, intent(in) :: kscal
        integer,          optional, intent(in) :: iscal
        real(kind=8),     optional, intent(in) :: rscal
        complex(kind=8),  optional, intent(in) :: cscal   
        character(len=*), optional, intent(in) :: kvect(lonvec)
        integer,          optional, intent(in) :: ivect(lonvec)
        real(kind=8),     optional, intent(in) :: rvect(lonvec)
        complex(kind=8),  optional, intent(in) :: cvect(lonvec)
        character(len=24),optional, intent(out):: savejv
    end subroutine pgpsav
end interface
