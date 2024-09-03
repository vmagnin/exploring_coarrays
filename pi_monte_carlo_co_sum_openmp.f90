! Computes an approximation of Pi with a Monte Carlo algorithm
! Co_sum with final results
! Vincent Magnin, 2021-04-22
! and Brad Richardson
! and Ryan Bignell
! Last modification: 2024-01-17
! MIT license
! $ caf -Wall -Wextra -std=f2018 -pedantic -O3 -fopenmp m_xoroshiro128plus.f90 pi_monte_carlo_co_sum_openmp.f90
! $ cafrun -n 4 ./a.out
! or with ifx :
! $ ifx -O3 -qopenmp -coarray m_xoroshiro128plus.f90 pi_monte_carlo_co_sum.f90

program pi_monte_carlo_co_sum_openmp
     use, intrinsic :: iso_fortran_env, only: wp=>real64, int64
    use m_xoroshiro128plus
    use omp_lib, only: omp_get_thread_num
    implicit none
    type(rng_t)     :: rng          ! xoroshiro128+ pseudo-random number generator
    real(wp)        :: x, y         ! Coordinates of a point
    integer(int64)  :: n            ! Total number of points
    integer(int64)  :: k            ! Points into the quarter disk
    integer(int64)  :: i            ! Loop counter
    integer(int64)  :: n_per_image  ! Number of parallel images
    integer         :: t1, t2       ! Clock ticks
    real            :: count_rate   ! Clock ticks per second
    integer         :: thread       ! OpenMP thread number    
    
    n = 1000000000
    k = 0

    call system_clock(t1, count_rate)
    
    !$OMP PARALLEL DEFAULT(NONE) SHARED(n_per_image,n) PRIVATE(thread, i, x, y, rng) REDUCTION(+: k)
    thread = omp_get_thread_num()
    
    ! Each image will have its own RNG seed:
    call rng%seed([ -1337_i8, 9812374_i8 ] + 10*this_image() + 10 * thread)
    x = rng%U01()

    n_per_image = n / num_images()
    write(*, '(a, i3, a, i3)', advance='no') "Image ", this_image(), "/", num_images()
    write(*, '(a, i11, a)') " will compute", n_per_image, " points"

    !$OMP DO SCHEDULE(STATIC) 
    do i = 1, n_per_image
        ! Computing a random point (x,y) into the square 0<=x<1, 0<=y<1:
        x = rng%U01()
        y = rng%U01()

        ! Is it in the quarter disk (R=1, center=origin) ?
        if ((x**2 + y**2) < 1.0_wp) k = k + 1
     end do
     !$OMP END DO
     !$OMP END PARALLEL

    ! At the end:
    call co_sum(k, result_image = 1)
    if (this_image() == 1) then
        write(*,*)
        write(*, '(a, i0, a, i0)', advance='no') "4 * ", k, " / ", n
        write(*, '(a, f17.15)') " = ", (4.0_wp * k) / n

        call system_clock(t2)
        write(*,'(a, f6.3, a)') "Execution time: ", (t2 - t1) / count_rate, " s"
        write(*,'(a)') "---------------------------------------------------"
    end if

  end program pi_monte_carlo_co_sum_openmp
