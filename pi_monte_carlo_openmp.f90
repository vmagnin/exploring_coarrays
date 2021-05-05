! Computes an approximation of Pi with a Monte Carlo algorithm
! OpenMP version
! Vincent Magnin, 2021-04-22
! Last modification: 2021-05-05
! MIT license
! $ gfortran -Wall -Wextra -std=f2018 -pedantic -O3 -fopenmp pi_monte_carlo_openmp.f90 && time ./a.out

program pi_monte_carlo_openmp
    use, intrinsic :: iso_fortran_env, only: wp=>real64, int64
    implicit none
    real(wp)        :: x, y         ! Coordinates of a point
    integer(int64)  :: n            ! Total number of points
    integer(int64)  :: k = 0        ! Points into the quarter disk
    integer(int64)  :: i            ! Loop counter
    integer         :: t1, t2       ! Clock ticks
    real            :: count_rate   ! Clock ticks per second

    n = 1000000000
    call random_init(repeatable=.true., image_distinct=.true.)

    call system_clock(t1, count_rate)
    !$OMP PARALLEL DO DEFAULT(NONE) SCHEDULE(STATIC) &
    !$OMP SHARED(n) PRIVATE(i, x, y) REDUCTION(+: k)
    do i = 1, n
        ! Computing a random point (x,y) into the square 0<=x<1, 0<=y<1:
        call random_number(x)
        call random_number(y)

        ! Is it in the quarter disk (R=1, center=origin) ?
        if ((x**2 + y**2) < 1.0_wp) k = k + 1
    end do
    !$OMP END PARALLEL DO

    write(*,*)
    write(*, '(a, i0, a, i0)') "4 * ", k, " / ", n
    write(*, '(a, f17.15)') "Pi ~ ", (4.0_wp * k) / n

    call system_clock(t2)
    write(*,'(a, f6.3, a)') "Execution time: ", (t2 - t1) / count_rate, " s"
end program pi_monte_carlo_openmp
