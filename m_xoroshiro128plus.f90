! Written in 2016 by David Blackman and Sebastiano Vigna (vigna@acm.org)
! Translated to Fortran 2008 by Jannis Teunissen

! To the extent possible under law, the author has dedicated all copyright
! and related and neighboring rights to this software to the public domain
! worldwide. This software is distributed without any warranty.

! See <http://creativecommons.org/publicdomain/zero/1.0/>.

! This is the successor to xorshift128+. It is the fastest full-period
! generator passing BigCrush without systematic failures, but due to the
! relatively short period it is acceptable only for applications with a
! mild amount of parallelism; otherwise, use a xorshift1024* generator.

! Beside passing BigCrush, this generator passes the PractRand test suite
! up to (and included) 16TB, with the exception of binary rank tests,
! which fail due to the lowest bit being an LFSR; all other bits pass all
! tests. We suggest to use a sign test to extract a random Boolean value.

! Note that the generator uses a simulated rotate operation, which most C
! compilers will turn into a single instruction. In Java, you can use
! Long.rotateLeft(). In languages that do not make low-level rotation
! instructions accessible xorshift128+ could be faster.

! The state must be seeded so that it is not everywhere zero. If you have
! a 64-bit seed, we suggest to seed a splitmix64 generator and use its
! output to fill s.

! Usage example:
!
! use m_xoroshiro128plus
!
! type(rng_t) :: rng
! call rng%seed((/1337_i8, 31337_i8/))
!
! print *, rng%next()
! print *, rng%U01()

module m_xoroshiro128plus
  implicit none
  private

  ! This defines a 64 bit integer type
  integer, parameter :: i8 = selected_int_kind(18)

  ! This defines a 64 bit floating point type (Double Precision)
  integer, parameter :: dp = kind(0.0d0)

  ! A type/class to store the RNG state
  type rng_t
     ! The default seed (arbitrarily chosen)
     integer(i8)                :: s(2) = (/123456789_i8, 987654321_i8/)
   contains                             ! Methods:
     procedure, non_overridable :: next ! Get next random number
     procedure, non_overridable :: U01  ! Get next random float [0,1)
     procedure, non_overridable :: seed ! Seed the generator
     procedure, non_overridable :: jump ! Jump function (see below)
  end type rng_t

  ! List of public types
  public :: i8, dp
  public :: rng_t

contains

  ! For internal use
  pure function rotl(x, k) result(res)
    integer(i8), intent(in) :: x
    integer, intent(in)     :: k
    integer(i8)             :: res

    res = ior(shiftl(x, k), shiftr(x, 64 - k))
  end function rotl

  ! Get the next value (returned as 64 bit signed integer)
  function next(self) result(res)
    class(rng_t), intent(inout) :: self
    integer(i8)                 :: res
    integer(i8)                 :: t(2)

    t         = self%s
    res       = t(1) + t(2)
    t(2)      = ieor(t(1), t(2))
    self%s(1) = ieor(ieor(rotl(t(1), 55), t(2)), shiftl(t(2), 14))
    self%s(2) = rotl(t(2), 36)
  end function next

  ! Get a uniform [0,1) random real (double precision)
  function U01(self) result(res)
    class(rng_t), intent(inout) :: self
    real(dp)                    :: res
    integer(i8)                 :: x

    x   = self%next()
    x   = ior(shiftl(1023_i8, 52), shiftr(x, 12))
    res = transfer(x, res) - 1.0_dp
  end function U01

  ! Set a seed for the RNG
  subroutine seed(self, the_seed)
    class(rng_t), intent(inout) :: self
    integer(i8), intent(in)     :: the_seed(2)

    self%s = the_seed
  end subroutine seed

  ! This is the jump function for the generator. It is equivalent
  ! to 2^64 calls to next(); it can be used to generate 2^64
  ! non-overlapping subsequences for parallel computations.
  subroutine jump(self)
    class(rng_t), intent(inout) :: self
    integer                     :: i, b
    integer(i8)                 :: t(2), dummy

    ! The signed equivalent of the unsigned constants
    integer(i8), parameter      :: jmp_c(2) = &
         (/-4707382666127344949_i8, -2852180941702784734_i8/)

    t = 0
    do i = 1, 2
       do b = 0, 63
          if (iand(jmp_c(i), shiftl(1_i8, b)) /= 0) then
             t = ieor(t, self%s)
          end if
          dummy = self%next()
       end do
    end do

    self%s = t
  end subroutine jump

end module m_xoroshiro128plus
