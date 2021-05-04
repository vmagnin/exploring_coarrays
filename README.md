# exploring_coarrays

Let's explore the modern Fortran coarrays features for parallel programming: coarrays, images, etc.

## Pi Monte Carlo

### The algorithm

Imagine a disk of radius R=1 inside a square of side 2*R. And draw N points inside the square. Count K, the number of points inside the disk. The bigger N, the closer `4*K/N` will be close to Pi. Because `K/N` will tend to be proportional to the ratio between the surface of the disk (`Pi*R**2`) and the surface of the square (`(2*R)**2`). The programming can be a little optimized by considering only a quarter disk inside a square of side 1. We will use that method.

The advantage of Monte Carlo algorithms are that they are naturally parallel ("embarrassingly parallel"), each point being independent of the others.

Warnings:

* this is an inefficient method to compute Pi, as one more precision digit requires 100 times more points!
* If the pseudo-random generator is biased, it can be a problem if our objective is really to compute precisely Pi. But our objective here is rather to burn the CPU!

### The programs

In this repository, you will find:

* a serial version of the algorithm.
* A parallel version using OpenMP.
* A parallel version using Coarrays.
* Another coarrays version printing steadily intermediate results.

### Compilation

They will be compiled with the `-O3` flag for optimization, with gfortran and ifort. 

The OpenMP version will be compiled with the `-fopenmp` flag with gfortran or `-qopenmp` with ifort.

For gfortran, OpenCoarrays was installed with the MPICH library.

The coarray versions will be compiled and run with commands like:
```bash
$ caf -O3 pi_monte_carlo_coarrays.f90 && time cafrun -n 4 ./a.out
```

Or:
```bash
ifort -O3 -coarray pi_monte_carlo_coarrays.f90 && time ./a.out
```

### Results

CPU time in seconds computed with an Intel(R) Core(TM) i7-5500U CPU @ 2.40GHz with 2 cores / 4 threads (using 4 images for parallel versions), under Ubuntu 20.10:

| Version         | gfortran  | ifort   |
| --------------- | --------- | ------- |
| Serial          |    19.9 s |  34.8 s |
| OpenMP          |     9.9 s |  93.0 s |
| Coarrays        |    16.2 s |  14.4 s |
| Coarrays steady |    33.2 s |  35.9 s |
| Co_sum          |    13.0 s |  14.1 s |
| Co_sum steady   |    17.1 s |  17.1 s | 

The compiler versions are:

* ifort 2021.2.0
* gfortran 10.2.0

Warning: **work in progress! This benchmark is not definitive.**
	
# Bibliography

* Curcic, Milan. [Modern Fortran - Building efficient parallel applications](https://learning.oreilly.com/library/view/-/9781617295287/?ar), Manning Publications, 1st edition, novembre 2020, ISBN 978-1-61729-528-7.
* Metcalf, Michael, John Ker Reid, et Malcolm Cohen. *[Modern Fortran Explained: Incorporating Fortran 2018.](https://oxford.universitypressscholarship.com/view/10.1093/oso/9780198811893.001.0001/oso-9780198811893)* Numerical Mathematics and Scientific Computation. Oxford (England): Oxford University Press, 2018, ISBN 978-0-19-185002-8.