        interface
          subroutine dktedg(xyzl,option,pgl,depl,edgl,multic)
            real(kind=8) :: xyzl(3,*)
            character(len=16) :: option
            real(kind=8) :: pgl(3,*)
            real(kind=8) :: depl(*)
            real(kind=8) :: edgl(*)
            integer :: multic
          end subroutine dktedg
        end interface
