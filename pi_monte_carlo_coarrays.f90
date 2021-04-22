! Computes Pi with a Monte Carlo algorithm
! Coarrays version
! Vincent  Magnin, 2021-04-22
! MIT license
! $ caf -Wall -Wextra -std=f2008 -pedantic -O3 pi_monte_carlo_coarrays.f90 && time cafrun -n 2 ./a.out


program pi_monte_carlo_coarrays
    use, intrinsic :: iso_fortran_env, only: wp=>real64, int64
    implicit none
    real(wp)        :: x, y     ! Coordinates
    integer(int64)  :: n        ! Total number of points
    integer(int64)  :: k[*]     ! Points into the circle
    integer(int64)  :: i, j, kt, it
    integer(int64)  :: n_im

    n = 1000000000
    k = 0

    print '(i2, a, i2, a)', this_image(), "/", num_images(), " images"
    n_im = n / num_images()
    print '(a, i11, a)', "Each image will compute", n_im, " points"

    do i = 1, n_im
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
        if (mod(i, n_im/40) == 0) then
            sync all
            if (this_image() == 1) then
                kt = 0
                do j = 1, num_images()
                    kt = kt + k[j]
                end do
                it = i*num_images()
                write(*, '(i12, 4x, i12, 4x, f17.15)') it, kt, (4.0_wp * kt) / it
            end if
        end if
    end do

end program pi_monte_carlo_coarrays
