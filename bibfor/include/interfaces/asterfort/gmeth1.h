        interface
          subroutine gmeth1(nnoff,ndeg,gthi,gs,objcur,xl,gi)
            integer :: nnoff
            integer :: ndeg
            real(kind=8) :: gthi(1)
            real(kind=8) :: gs(1)
            character(len=24) :: objcur
            real(kind=8) :: xl
            real(kind=8) :: gi(1)
          end subroutine gmeth1
        end interface
