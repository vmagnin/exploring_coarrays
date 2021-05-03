! Computes an approximation of Pi with a Monte Carlo algorithm
! Serial version
! Vincent Magnin, 2021-04-22
! Last modification: 2021-05-03
! MIT license
! $ gfortran -Wall -Wextra -std=f2008 -pedantic -O3 pi_monte_carlo_serial.f90 && time ./a.out
! $ ifort -O3 pi_monte_carlo_serial.f90 && time ./a.out

program pi_monte_carlo_serial
    use, intrinsic :: iso_fortran_env, only: wp=>real64, int64
    implicit none
    real(wp)        :: x, y     ! Coordinates of a point
    integer(int64)  :: n        ! Total number of points
    integer(int64)  :: k = 0    ! Points into the quarter disk
    integer(int64)  :: i        ! Loop counter

    n = 1000000000

    do i = 1, n
        ! Computing a random point (x,y) into the square 0<=x<1, 0<=y<1:
        call random_number(x)
        call random_number(y)

        ! Is it in the quarter disk (R=1, center=origin) ?
        if ((x**2 + y**2) < 1.0_wp) k = k + 1
    end do

    write(*,*)
    write(*, '(a, i0, a, i0)') "4 * ", k, " / ", n
    write(*, '(a, f17.15)') "Pi ~ ", (4.0_wp * k) / n

end program pi_monte_carlo_serial
