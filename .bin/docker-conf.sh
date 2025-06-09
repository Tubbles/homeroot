#!/usr/bin/env bash

# CAUTION: The conf file handling have been fully vibe coded 🤡

# Find conf files starting in a directory and recurse upwards towards fs root
# Returns absolute paths to config files that should be sourced (without duplicates)
get_conf_files() {
    local conf_file_name="$1"
    local start_dirs=("${@:2}") # All directories as array
    local -A seen_files=()      # Track unique files by path
    local conf_files=()         # Files in reverse order

    # Process each starting directory
    for start_dir in "${start_dirs[@]}"; do
        local current="${start_dir}"

        # Traverse from start_dir up to filesystem root
        while true; do
            local conf_file="${current}/${conf_file_name}"
            local abs_path=""

            if [[ -r "${conf_file}" ]]; then
                abs_path="$(realpath "${conf_file}")"

                # Only add if we haven't seen this file before
                if [[ -z "${seen_files["${abs_path}"]:-}" ]]; then
                    # Add to our lists
                    seen_files["${abs_path}"]=1
                    conf_files+=("${abs_path}")
                fi
            fi

            # Exit loop after checking root
            if [[ "${current}" == "/" ]]; then
                break
            fi

            # Move to parent directory
            current="$(dirname "${current}")"
        done
    done

    # Reverse the array to get correct loading order
    # (most general first, most specific last)
    local reversed=()
    for ((index = ${#conf_files[@]} - 1; index >= 0; index--)); do
        reversed+=("${conf_files[${index}]}")
    done

    # Return the paths, space-delimited
    printf "%s\n" "${reversed[@]}"
}

# Source configuration files in the given order
source_conf_files() {
    local file
    for file in "$@"; do
        if [[ -r "${file}" ]]; then
            # shellcheck disable=SC1090
            source "${file}"
        fi
    done
}

# Find all conf files starting in multiple directories and source them in proper order
load_conf_files() {
    local conf_file_name="$1"
    shift
    local dirs=("$@") # All directories to search

    # Get all unique conf files in correct order - safely with mapfile
    local conf_files=()
    mapfile -t conf_files < <(get_conf_files "${conf_file_name}" "${dirs[@]}")

    # Source them
    source_conf_files "${conf_files[@]}"
}

# ===================================== TESTS =====================================

# Helper test function for get_conf_files
test_get_conf_files() {
    local test_root="$1"
    echo "Test 1: Testing get_conf_files finds files in correct order"

    local found_array=()
    mapfile -t found_array < <(get_conf_files ".dockerenv" "${test_root}/a/b/c")

    # Check array contents individually
    if [[ "${#found_array[@]}" -eq 4 &&
          "${found_array[0]}" == "${test_root}/.dockerenv" &&
          "${found_array[1]}" == "${test_root}/a/.dockerenv" &&
          "${found_array[2]}" == "${test_root}/a/b/.dockerenv" &&
          "${found_array[3]}" == "${test_root}/a/b/c/.dockerenv" ]]; then
        echo "✓ Test 1 passed"
    else
        echo "✗ Test 1 failed"
        echo "  Expected 4 files in specific order"
        echo "  Got ${#found_array[@]} files:"
        printf "    %s\n" "${found_array[@]}"
        return 1
    fi
    return 0
}

# Helper test function for source_conf_files
test_source_conf_files() {
    local test_root="$1"
    echo "Test 2: Testing source_conf_files loads variables correctly"

    # FIRST: Create the files with content we want to test
    echo "root_var=root_value_test" > "${test_root}/.dockerenv"
    echo "a_var=a_value_test" > "${test_root}/a/.dockerenv"
    echo "b_var=b_value_test" > "${test_root}/a/b/.dockerenv"
    echo "c_var=c_value_test" > "${test_root}/a/b/c/.dockerenv"

    # THEN: Get files with mapfile to properly handle paths with spaces
    local test2_files=()
    mapfile -t test2_files < <(get_conf_files ".dockerenv" "${test_root}/a/b/c")

    # Reset variables before sourcing
    root_var=""
    a_var=""
    b_var=""
    c_var=""

    # Pass array elements as separate arguments
    source_conf_files "${test2_files[@]}"

    # Check if variables were correctly set
    if [[ "${root_var}" == "root_value_test" &&
          "${a_var}" == "a_value_test" &&
          "${b_var}" == "b_value_test" &&
          "${c_var}" == "c_value_test" ]]; then
        echo "✓ Test 2 passed"
    else
        echo "✗ Test 2 failed"
        echo "  Expected: root_var=root_value_test, a_var=a_value_test, b_var=b_value_test, c_var=c_value_test"
        echo "  Got: root_var=${root_var}, a_var=${a_var}, b_var=${b_var}, c_var=${c_var}"
        return 1
    fi
    return 0
}

# Helper test function for variable override
test_variable_override() {
    local test_root="$1"
    echo "Test 3: Testing variable override behavior"

    echo "override_var=root_value" >"${test_root}/.dockerenv"
    echo "override_var=a_value" >"${test_root}/a/.dockerenv"
    echo "override_var=b_value" >"${test_root}/a/b/.dockerenv"
    echo "override_var=c_value" >"${test_root}/a/b/c/.dockerenv"

    local override_var=""
    local test3_files=()
    mapfile -t test3_files < <(get_conf_files ".dockerenv" "${test_root}/a/b/c")
    source_conf_files "${test3_files[@]}"

    if [[ "${override_var}" == "c_value" ]]; then
        echo "✓ Test 3 passed"
    else
        echo "✗ Test 3 failed"
        echo "  Expected: override_var=c_value"
        echo "  Got: override_var=${override_var}"
        return 1
    fi
    return 0
}

# Helper test function for load_conf_files
test_load_conf_files() {
    local test_root="$1"
    echo "Test 4: Testing load_conf_files"

    local special_var=""
    echo "special_var=test_value" >"${test_root}/a/b/.dockerenv"

    load_conf_files ".dockerenv" "${test_root}/a/b"

    if [[ "${special_var}" == "test_value" ]]; then
        echo "✓ Test 4 passed"
    else
        echo "✗ Test 4 failed"
        echo "  Expected: special_var=test_value"
        echo "  Got: special_var=${special_var}"
        return 1
    fi
    return 0
}

# Helper test function for multiple directories
test_multiple_directories() {
    local test_root="$1"
    echo "Test 5: Testing get_conf_files with multiple start directories"

    # Create additional directory structure
    mkdir -p "${test_root}/x/y"
    echo "x_var=x_value" >"${test_root}/x/.dockerenv"
    echo "y_var=y_value" >"${test_root}/x/y/.dockerenv"

    # Get the files using mapfile for proper handling
    local multi_files=()
    mapfile -t multi_files < <(get_conf_files ".dockerenv" "${test_root}/a" "${test_root}/x/y")

    # We expect 4 specific files in a specific order
    local expected_files=(
        "${test_root}/.dockerenv"
        "${test_root}/a/.dockerenv"
        "${test_root}/x/.dockerenv"
        "${test_root}/x/y/.dockerenv"
    )

    # Compare array sizes
    if [[ ${#multi_files[@]} -ne ${#expected_files[@]} ]]; then
        echo "✗ Test 5 failed"
        echo "  Expected ${#expected_files[@]} files but got ${#multi_files[@]}"
        echo "  Got files:"
        printf "    %s\n" "${multi_files[@]}"
        return 1
    fi

    # Check each file is in the expected array
    local all_found=1
    for expected in "${expected_files[@]}"; do
        local found=0
        for actual in "${multi_files[@]}"; do
            if [[ "${expected}" == "${actual}" ]]; then
                found=1
                break
            fi
        done
        if [[ ${found} -eq 0 ]]; then
            all_found=0
            echo "  Missing expected file: ${expected}"
        fi
    done

    if [[ ${all_found} -eq 1 ]]; then
        echo "✓ Test 5 passed"
        return 0
    else
        echo "✗ Test 5 failed"
        echo "  Missing some expected files"
        echo "  Got:"
        printf "    %s\n" "${multi_files[@]}"
        return 1
    fi
}

# Isolated test runner function
run_isolated_test() {
    local test_name="$1"
    local test_func="$2"
    shift 2

    echo "Running ${test_name} in isolated environment..."

    # Run the test in a subshell to isolate variables
    (
        # Any variables defined here will be local to this subshell
        ${test_func} "$@"
    )
    local status=$?

    if [[ ${status} -eq 0 ]]; then
        echo "✓ ${test_name} passed"
        return 0
    else
        echo "✗ ${test_name} failed with exit code ${status}"
        return "${status}"
    fi
}

# Main test function for configuration file handling
test_conf_file_handling() {
    echo "Testing configuration file handling functions..."

    # Create a temporary directory structure
    local test_root
    test_root=$(mktemp -d)

    # Set trap to clean up on exit, error, or interrupt
    trap 'echo "Cleaning up test directory ${test_root}"; rm -rf "${test_root}"' EXIT

    # Create nested directories
    mkdir -p "${test_root}/a/b/c"

    # Create test config files with unique content
    echo "root_var=root_value" >"${test_root}/.dockerenv"
    echo "a_var=a_value" >"${test_root}/a/.dockerenv"
    echo "b_var=b_value" >"${test_root}/a/b/.dockerenv"
    echo "c_var=c_value" >"${test_root}/a/b/c/.dockerenv"

    # Run all the tests individually to respect set -e
    run_isolated_test "get_conf_files test" test_get_conf_files "${test_root}"
    run_isolated_test "source_conf_files test" test_source_conf_files "${test_root}"
    run_isolated_test "variable override test" test_variable_override "${test_root}"
    run_isolated_test "load_conf_files test" test_load_conf_files "${test_root}"
    run_isolated_test "multiple directories test" test_multiple_directories "${test_root}"

    # No need for explicit cleanup - trap will handle it
    echo "All configuration file handling tests passed!"

    # Clear the trap before returning to avoid running it again
    trap - EXIT
    return 0
}

test_conf_file_handling_with_spaces() {
    echo "Testing handling of paths with spaces..."

    # Create a temporary directory with spaces in name
    local test_root
    test_root=$(mktemp -d -t "test dir with spaces XXXXXX")

    # Set trap to clean up on exit, error, or interrupt
    trap 'echo "Cleaning up test directory ${test_root}"; rm -rf "${test_root}"' EXIT

    # Create nested directory with spaces
    mkdir -p "${test_root}/folder with spaces"

    # Create test config file
    echo "space_var='value with spaces'" >"${test_root}/folder with spaces/.dockerenv"

    # Test using the main load_conf_files function, which now uses mapfile
    local space_var=""
    load_conf_files ".dockerenv" "${test_root}/folder with spaces"

    if [[ "${space_var}" == "value with spaces" ]]; then
        echo "✓ Path with spaces test passed"
    else
        echo "✗ Path with spaces test failed"
        echo "  Expected: space_var='value with spaces'"
        echo "  Got:      space_var='${space_var}'"
        return 1
    fi

    # Clean up
    rm -rf "${test_root}"

    echo "Path with spaces test passed!"

    # Clear the trap before returning
    trap - EXIT
    return 0
}

test_functions+=(
    test_conf_file_handling
    test_conf_file_handling_with_spaces
)
