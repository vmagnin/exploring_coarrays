# exploring_coarrays

Let's explore the modern Fortran coarrays features for parallel programming: coarrays, images, etc.

## Pi Monte Carlo

### The algorithm

Imagine a disk of radius R=1 inside a square of side 2*R. And draw N points inside the square. Count K, the number of points inside the disk. The bigger N, the closer `4*K/N` will be close to Pi. Because `K/N` will tend to be proportional to the ratio between the surface of the disk (`Pi*R**2`) and the surface of the square (`(2*R)**2`). The programming can be a little optimized by considering only a quarter disk inside a square of side 1. We will use that method.

The advantage of Monte Carlo algorithms are that they are naturally parallel ("embarrassingly parallel"), each point being independent of the others.

Warnings:

* this is an inefficient method to compute Pi, as one more precision digit requires 100 times more points!
* If the pseudo-random generator is biased, it can be a problem if our objective is really to compute precisely Pi. But our objective here is just to burn the CPU!

### The programs

In this repository, you will find:

* a serial version of the algorithm.
* A parallel version using OpenMP.
* A parallel version using Coarrays.
* Another coarrays version printing steadily intermediate results. **Bug: the intermediate results are not correct.**
* Versions using co_sum() instead of coarrays.

Concerning the pseudo-random number generator, we use a [Fortran implementation](https://github.com/jannisteunissen/xoroshiro128plus_fortran) (public domain) of the xoroshiro128+ algorithm. See also the page ["xoshiro / xoroshiro generators and the PRNG shootout"](https://prng.di.unimi.it/).


### Compilation

They will be compiled with the `-O3` flag for optimization, with GFortran and Intel compilers ifort and ifx (the new Intel compiler, based on LLVM). 

The OpenMP version will be compiled with the `-fopenmp` flag with gfortran or `-qopenmp` with ifort. The number of threads is set via the `OMP_NUM_THREADS` environment variable.

For gfortran, OpenCoarrays was installed with the MPICH library. The coarray versions will be compiled and run with commands like:

```bash
$ caf -O3 m_xoroshiro128plus.f90 pi_monte_carlo_coarrays.f90 && cafrun -n 2 ./a.out
```

And for ifort:

```bash
$ export FOR_COARRAY_NUM_IMAGES=2
$ ifort -O3 -coarray m_xoroshiro128plus.f90 pi_monte_carlo_coarrays.f90 && ./a.out
```

For ifx:

```bash
$ ifx -O3 -coarray=shared -coarray-num-images=2 m_xoroshiro128plus.f90 pi_monte_carlo_coarrays.f90
```

### Methodology

The values are the mean values obtained with 10 runs, computed by:

```bash
$ ./benchmark.sh
```

Warning: this benchmark is valid for those programs, on those machines, with those compilers and libraries versions, with those compilers options. The results can not be generalized easily to other situations. Just try and see with your own programs. 

### Results #1 (May 2021)

The compiler versions are:

* ifort 2021.2.0.
* ifx 2021.2.0 Beta (ifx does not yet support `-corray`).
* gfortran 10.2.0.

on an Intel(R) Core(TM) i7-5500U CPU @ 2.40GHz, under Ubuntu 20.10.


CPU time in seconds with 2 images/threads (except of course Serial):

| Version              | gfortran | ifort   | ifx     |
| -------------------- | -------- | ------- | ------- |
| Serial               |  10.77   | 18.77   | 14.66   |
| OpenMP               |   5.75   |  9.32   | 60.30   |
| Coarrays             |  13.21   |  9.79   |         |
| Coarrays steady      |  21.80   | 27.83   |         |
| Co_sum               |   5.58   |  9.98   |         |
| Co_sum steady        |   9.18   | 12.71   |         |

With 4 images/threads (except of course Serial):

| Version              | gfortran | ifort   | ifx     |
| -------------------- | -------- | ------- | ------- |
| Serial               |  10.77   | 18.77   | 14.66   |
| OpenMP               |   4.36   |  8.42   | 43.21   |
| Coarrays             |   9.47   |  9.12   |         |
| Coarrays steady      |  19.41   | 24.78   |         |
| Co_sum               |   4.16   |  9.29   |         |
| Co_sum steady        |   8.18   | 10.94   |         |


### Results #2 (January 2024)

The compiler versions are:
* gfortran 11.4.0
* ifort 2021.11.1
* ifx 2024.0.2

on a 13th Gen Intel(R) Core(TM) i5-13500, under Ubuntu 22.04.

With 2 images/threads (except of course Serial) with additional co_sum and openMP benchmark. The gfortran `co_sum` method includes the `-flto` flag as below.


| Version              | gfortran | ifort   | ifx     |
| -------------------- | -------- | ------- | ------- |
| Serial               |  11.11   | 28.02   | 14.26   |
| OpenMP               |  7.86    | 14.40   | 5.37    |
| Coarrays             |  8.06    | 10.42   | 7.29    |
| Coarrays steady      |  8.98    | 16.85   | 14.38   |
| Co_sum               |  2.12    | 10.45   | 6.99    |
| Co_sum steady        |  3.37    | 10.93   | 10.93   |
| Co_sum & openMP      |  1.12    | 7.59    | 2.72    |


### Further optimization

With gfortran, the `-flto` *([standard link-time optimizer](https://gcc.gnu.org/onlinedocs/gcc/Optimize-Options.html))* compilation option has a strong effect on this algorithm: for example, with the `co_sum` version the CPU time with 4 images falls from 4.16 s to 2.38 s (results #1)! 


# Bibliography

* Curcic, Milan. [Modern Fortran - Building efficient parallel applications](https://learning.oreilly.com/library/view/-/9781617295287/?ar), Manning Publications, 1st edition, novembre 2020, ISBN 978-1-61729-528-7.
* Metcalf, Michael, John Ker Reid, et Malcolm Cohen. *[Modern Fortran Explained: Incorporating Fortran 2018.](https://oxford.universitypressscholarship.com/view/10.1093/oso/9780198811893.001.0001/oso-9780198811893)* Numerical Mathematics and Scientific Computation. Oxford (England): Oxford University Press, 2018, ISBN 978-0-19-185002-8.
* Thomas Koenig, [coarray-tutorial](https://github.com/tkoenig1/coarray-tutorial/blob/main/tutorial.md).
