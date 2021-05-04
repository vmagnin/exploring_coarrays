! Computes an approximation of Pi with a Monte Carlo algorithm
! Coarrays version with steady results
! Vincent Magnin, 2021-04-22
! Last modification: 2021-05-03
! MIT license
! $ caf -Wall -Wextra -std=f2018 -pedantic -O3 pi_monte_carlo_coarrays_steady.f90 && time cafrun -n 4 ./a.out
! or with ifort :
! $ ifort -O3 -coarray pi_monte_carlo_coarrays_steady.f90 && time ./a.out

program pi_monte_carlo_coarrays_steady
    use, intrinsic :: iso_fortran_env, only: wp=>real64, int64
    implicit none
    real(wp)        :: x, y     ! Coordinates of a point
    integer(int64)  :: n        ! Total number of points
    integer(int64)  :: k        ! Points into the quarter disk
    integer(int64)  :: it, kt   ! for intermediate sum
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

        ! Once in a while (20 times):
        if (mod(i, n_per_image/20) == 0) then
            kt = k
            call co_sum(kt, result_image = 1)
            if (this_image() == 1) then
                it = i*num_images()
                write(*, '(a, i0, a, i0, a, F17.15)') "4 * ", kt, " / ", it, " = ", (4.0_wp * kt) / it
            end if
        end if
    end do

end program pi_monte_carlo_coarrays_steady
