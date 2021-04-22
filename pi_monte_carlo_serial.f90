! Computes Pi with a Monte Carlo algorithm
! Serial version
! Vincent  Magnin, 2021-04-22
! MIT license
! $ gfortran -Wall -Wextra -std=f2008 -pedantic -O3 pi_monte_carlo_serial.f90 && time ./a.out

program pi_monte_carlo_serial
    use, intrinsic :: iso_fortran_env, only: wp=>real64, int64
    implicit none
    real(wp)        :: x, y     ! Coordinates
    integer(int64)  :: n        ! Total number of points
    integer(int64)  :: k = 0    ! Points into the circle
    integer(int64)  :: i

    n = 1000000000

    do i = 1, n, +1
        ! Computing a random point (x,y) into the square:
        call random_number(x)
        x = 2.0_wp * x - 1.0_wp
        call random_number(y)
        y = 2.0_wp * y - 1.0_wp

        ! Is it in the circle ?
        if ((x**2 + y**2) <= 1.0_wp) then
            k = k + 1    ! Yes
        end if

        ! Once in a while:
        if (mod(i, n/40) == 0) then 
            write(*, '(i12, 4x, i12, 4x, f17.15)') i, k, (4.0_wp * k) / i
        end if
    end do

    write(*, '(a, f17.15)') "Pi ~ ", (4.0_wp*k) / n

end program pi_monte_carlo_serial
