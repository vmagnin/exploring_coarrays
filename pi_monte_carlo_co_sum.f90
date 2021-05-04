! Computes an approximation of Pi with a Monte Carlo algorithm
! Co_sum with final results
! Vincent Magnin, 2021-04-22
! and Brad Richardson
! Last modification: 2021-05-03
! MIT license
! $ caf -Wall -Wextra -std=f2018 -pedantic -O3 pi_monte_carlo_co_sum.f90 && time cafrun -n 4 ./a.out
! or with ifort :
! $ ifort -O3 -coarray pi_monte_carlo_co_sum.f90 && time ./a.out

program pi_monte_carlo_co_sum
    use, intrinsic :: iso_fortran_env, only: wp=>real64, int64
    implicit none
    real(wp)        :: x, y     ! Coordinates of a point
    integer(int64)  :: n        ! Total number of points
    integer(int64)  :: k        ! Points into the quarter disk
    integer(int64)  :: i        ! Loop counter
    integer(int64)  :: n_per_image     ! Number of parallel images

    n = 1000000000
    k = 0

    call random_init(repeatable=.true., image_distinct=.true.)
    print '(i2, a, i2, a)', this_image(), "/", num_images(), " images"
    n_per_image = n / num_images()
    print '(a, i11, a)', "I will compute", n_per_image, " points"

    do i = 1, n_per_image
        ! Computing a random point (x,y) into the square 0<=x<1, 0<=y<1:
        call random_number(x)
        call random_number(y)

        ! Is it in the quarter disk (R=1, center=origin) ?
        if ((x**2 + y**2) < 1.0_wp) k = k + 1
    end do

    ! At the end:
    call co_sum(k, result_image = 1)
    if (this_image() == 1) then
        write(*,*)
        write(*, '(a, i0, a, i0)') "4 * ", k, " / ", n
        write(*, '(a, f17.15)') "Pi ~ ", (4.0_wp * k) / n
    end if
end program pi_monte_carlo_co_sum
