! Computes an approximation of Pi with a Monte Carlo algorithm
! Coarrays version v2
! Vincent Magnin, 2021-04-22
! Last modification: 2021-05-02
! MIT license
! $ caf -Wall -Wextra -std=f2008 -pedantic -O3 pi_monte_carlo_coarrays_v2.f90 && time cafrun -n 4 ./a.out
! or with ifort :
! $ ifort -O3 -coarray pi_monte_carlo_coarrays_v2.f90 && time ./a.out

program pi_monte_carlo_coarrays
    use, intrinsic :: iso_fortran_env, only: wp=>real64, int64
    implicit none
    real(wp)        :: x, y     ! Coordinates of a point
    integer(int64)  :: n        ! Total number of points
    integer(int64)  :: k[*]     ! Points into the quarter disk
    integer(int64)  :: i        ! Loop counter
    integer(int64)  :: j, kt
    integer(int64)  :: n_per_image     ! Number of parallel images

    n = 1000000000
    k = 0

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
    sync all
    if (this_image() == 1) then
        kt = 0
        do j = 1, num_images()
            kt = kt + k[j]
        end do
        write(*, '(a,i0,a,i0,a,f17.15)') "4 * ", kt, " / ", n, " = ", (4.0_wp*kt)/n
    end if
end program pi_monte_carlo_coarrays
