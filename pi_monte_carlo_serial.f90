! Computes an approximation of Pi with a Monte Carlo algorithm
! Serial version
! Vincent Magnin, 2021-04-22
! Last modification: 2021-05-09
! MIT license
! $ gfortran -Wall -Wextra -std=f2018 -pedantic -O3 m_xoroshiro128plus.f90 pi_monte_carlo_serial.f90
! $ ifx -O3 m_xoroshiro128plus.f90 pi_monte_carlo_serial.f90

program pi_monte_carlo_serial
    use, intrinsic :: iso_fortran_env, only: wp=>real64, int64
    use m_xoroshiro128plus
    implicit none
    type(rng_t)     :: rng          ! xoroshiro128+ pseudo-random number generator
    real(wp)        :: x, y         ! Coordinates of a point
    integer(int64)  :: n            ! Total number of points
    integer(int64)  :: k = 0        ! Points into the quarter disk
    integer(int64)  :: i            ! Loop counter
    integer         :: t1, t2       ! Clock ticks
    real            :: count_rate   ! Clock ticks per second

    n = 1000000000

    ! Set the seed of the RNG:
    call rng%seed([ -1337_i8, 9812374_i8 ])
    x = rng%U01()

    call system_clock(t1, count_rate)

    do i = 1, n
        ! Computing a random point (x,y) into the square 0<=x<1, 0<=y<1:
        x = rng%U01()
        y = rng%U01()

        ! Is it in the quarter disk (R=1, center=origin) ?
        if ((x**2 + y**2) < 1.0_wp) k = k + 1
    end do

    write(*,*)
    write(*, '(a, i0, a, i0)', advance='no') "4 * ", k, " / ", n
    write(*, '(a, f17.15)') " = ", (4.0_wp * k) / n

    call system_clock(t2)
    write(*,'(a, f6.3, a)') "Execution time: ", (t2 - t1) / count_rate, " s"
    write(*,'(a)') "---------------------------------------------------"
end program pi_monte_carlo_serial
