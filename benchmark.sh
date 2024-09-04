#! /bin/bash
# Vincent Magnin, 2021-05-09
# Ryan Bignell, 2024-01-17
# Last modification: 2024-09-04
# Launch the Pi Monte Carlo benchmark
# MIT license
# Verified with shellcheck

# Strict mode:
set -uo pipefail

# Launches N times the a.out executable and copy the output in a file.
launch_N_times()
{
    # Input parameters:
    local readonly N="$1"
    local readonly filename="$2"
    local readonly executable="$3"

    for ((i = 1 ; i <= N ; i++)) ; do
        ${executable} | tee -a "$filename"
    done
}

# Compute the computation mean time using the times in the file.
mean_time()
{
    # Input parameters:
    local readonly testname="$1"
    # We grep real numbers with 3 decimals followed by a space (CPU times)
    # and we compute their mean value using awk:
    echo $(grep -oE '[0-9]+\.[0-9]{3} ' "${testname}.txt" | awk '{ total += $1 } END { printf "%5.2f", total/NR }')
}

#***************
# Main program:
#***************
readonly runs=10
readonly threads=2

# Environment variables for OpenMP and Coarrays (ifort):
export OMP_NUM_THREADS="${threads}"
export FOR_COARRAY_NUM_IMAGES="${threads}"

# Cleanup:
rm -f gfortran*.txt
rm -f ifort*.txt
rm -f ifx*.txt

# All examples are compiled and launched several times, and the results are
# copied into a txt file:

test_name="gfortran_serial"
echo "$test_name"
gfortran -O3 m_xoroshiro128plus.f90 pi_monte_carlo_serial.f90 && launch_N_times "$runs" "$test_name.txt" "./a.out"

test_name="ifort_serial"
echo "$test_name"
ifort -O3 m_xoroshiro128plus.f90 pi_monte_carlo_serial.f90 && launch_N_times "$runs" "$test_name.txt" "./a.out"

test_name="ifx_serial"
echo "$test_name"
ifx -O3 m_xoroshiro128plus.f90 pi_monte_carlo_serial.f90 && launch_N_times "$runs" "$test_name.txt" "./a.out"

test_name="gfortran_openmp"
echo "$test_name"
gfortran -O3 -fopenmp m_xoroshiro128plus.f90 pi_monte_carlo_openmp.f90 && launch_N_times "$runs" "$test_name.txt" "./a.out"

test_name="ifort_openmp"
echo "$test_name"
ifort -O3 -qopenmp m_xoroshiro128plus.f90 pi_monte_carlo_openmp.f90 && launch_N_times "$runs" "$test_name.txt" "./a.out"

test_name="ifx_openmp"
echo "$test_name"
ifx -O3 -qopenmp m_xoroshiro128plus.f90 pi_monte_carlo_openmp.f90 && launch_N_times "$runs" "$test_name.txt" "./a.out"

test_name="gfortran_coarrays"
echo "$test_name"
caf -O3 m_xoroshiro128plus.f90 pi_monte_carlo_coarrays.f90 && launch_N_times "$runs" "$test_name.txt" "cafrun -n ${threads} ./a.out"

test_name="ifort_coarrays"
echo "$test_name"
ifort -O3 -coarray m_xoroshiro128plus.f90 pi_monte_carlo_coarrays.f90 && launch_N_times "$runs" "$test_name.txt" "./a.out"

test_name="ifx_coarrays"
echo "$test_name"
ifx -O3 -coarray=shared -coarray-num-images=${threads} m_xoroshiro128plus.f90 pi_monte_carlo_coarrays.f90 && launch_N_times "$runs" "$test_name.txt" "./a.out"

test_name="gfortran_coarrays_steady"
echo "$test_name"
caf -O3 m_xoroshiro128plus.f90 pi_monte_carlo_coarrays_steady.f90 && launch_N_times "$runs" "$test_name.txt" "cafrun -n ${threads} ./a.out"

test_name="ifort_coarrays_steady"
echo "$test_name"
ifort -O3 -coarray m_xoroshiro128plus.f90 pi_monte_carlo_coarrays_steady.f90 && launch_N_times "$runs" "$test_name.txt" "./a.out"

test_name="ifx_coarrays_steady"
echo "$test_name"
ifx -O3 -coarray=shared -coarray-num-images=${threads} m_xoroshiro128plus.f90 pi_monte_carlo_coarrays_steady.f90 && launch_N_times "$runs" "$test_name.txt" "./a.out"

test_name="gfortran_co_sum"
echo "$test_name"
caf -O3 -flto m_xoroshiro128plus.f90 pi_monte_carlo_co_sum.f90 && launch_N_times "$runs" "$test_name.txt" "cafrun -n ${threads} ./a.out"

test_name="ifort_co_sum"
echo "$test_name"
ifort -O3 -coarray m_xoroshiro128plus.f90 pi_monte_carlo_co_sum.f90 && launch_N_times "$runs" "$test_name.txt" "./a.out"

test_name="ifx_co_sum"
echo "$test_name"
ifx -coarray=shared -coarray-num-images=${threads} -O3 -coarray m_xoroshiro128plus.f90 pi_monte_carlo_co_sum.f90 && launch_N_times "$runs" "$test_name.txt" "./a.out"


test_name="gfortran_co_sum_steady"
echo "$test_name"
caf -O3 m_xoroshiro128plus.f90 pi_monte_carlo_co_sum_steady.f90 && launch_N_times "$runs" "$test_name.txt" "cafrun -n ${threads} ./a.out"

test_name="ifort_co_sum_steady"
echo "$test_name"
ifort -O3 -coarray m_xoroshiro128plus.f90 pi_monte_carlo_co_sum_steady.f90 && launch_N_times "$runs" "$test_name.txt" "./a.out"

test_name="ifx_co_sum_steady"
echo "$test_name"
ifx -O3 -coarray=shared -coarray-num-images=${threads} m_xoroshiro128plus.f90 pi_monte_carlo_co_sum_steady.f90 && launch_N_times "$runs" "$test_name.txt" "./a.out"

test_name="gfortran_co_sum_openmp"
echo "$test_name"
caf -O3 -fopenmp -flto m_xoroshiro128plus.f90 pi_monte_carlo_co_sum_openmp.f90 && launch_N_times "$runs" "$test_name.txt" "cafrun -n ${threads} ./a.out"

test_name="ifort_co_sum_openmp"
echo "$test_name"
ifort -O3 -qopenmp -coarray m_xoroshiro128plus.f90 pi_monte_carlo_co_sum_openmp.f90 && launch_N_times "$runs" "$test_name.txt" "./a.out"

test_name="ifx_co_sum_openmp"
echo "$test_name"
ifx -coarray=shared -coarray-num-images=${threads} -qopenmp -O3 -coarray m_xoroshiro128plus.f90 pi_monte_carlo_co_sum_openmp.f90 && launch_N_times "$runs" "$test_name.txt" "./a.out"


# The CPU times mean values are computed with each txt file:
echo '****************************************'
echo ' STATISTICS (Markdown table)'
echo '****************************************'

echo '| Version              | gfortran | ifort   | ifx     |'
echo '| -------------------- | -------- | ------- | ------- |'
echo "| Serial               |  $(mean_time 'gfortran_serial')   | $(mean_time 'ifort_serial') | $(mean_time 'ifx_serial') |"
echo "| OpenMP               |  $(mean_time 'gfortran_openmp')  | $(mean_time 'ifort_openmp') | $(mean_time 'ifx_openmp') |"
echo "| Coarrays             |  $(mean_time 'gfortran_coarrays')  | $(mean_time 'ifort_coarrays') | $(mean_time 'ifx_coarrays')          |"
echo "| Coarrays steady      |  $(mean_time 'gfortran_coarrays_steady')  | $(mean_time 'ifort_coarrays_steady') | $(mean_time 'ifx_coarrays_steady')          |"
echo "| Co_sum               |  $(mean_time 'gfortran_co_sum')  | $(mean_time 'ifort_co_sum') | $(mean_time 'ifx_co_sum')          |"
echo "| Co_sum steady        |  $(mean_time 'gfortran_co_sum_steady')  | $(mean_time 'ifort_co_sum_steady')   | $(mean_time 'ifort_co_sum_steady')        |"
echo "| Co_sum & openMP      |  $(mean_time 'gfortran_co_sum_openmp')  | $(mean_time 'ifort_co_sum_openmp') | $(mean_time 'ifx_co_sum_openmp')          |"
echo

echo "Compilers versions:"
echo "-------------------"
gfortran --version
ifort --version
ifx --version
