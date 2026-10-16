#include <iostream>
#include <vector>
#include <numeric>
#include <random>
#include <algorithm>
#include <cstdint>

// Standalone verification utility for EXP-20261016-01 checksum investigation.
// Replicates make_cycle exactly as implemented in src/memory_lab.cpp.
// Verifies cycle properties, terminal indices, and traversal divergence between 512 KiB and 1 MiB.

using u64 = std::uint64_t;

static void make_cycle(std::vector<std::size_t>& next,
                       std::size_t begin, std::size_t length, u64 seed) {
    std::vector<std::size_t> order(length);
    std::iota(order.begin(), order.end(), begin);
    std::mt19937_64 rng(seed);
    std::shuffle(order.begin(), order.end(), rng);
    for (std::size_t i = 0; i < length; ++i)
        next[order[i]] = order[(i + 1) % length];
}

int main() {
    const std::size_t n1 = 65536;   // 512 KiB
    const std::size_t n2 = 131072;  // 1 MiB
    const std::size_t work = 2000000;
    const u64 seed = 12345ULL;

    std::vector<std::size_t> next1(n1);
    make_cycle(next1, 0, n1, seed);

    std::vector<std::size_t> next2(n2);
    make_cycle(next2, 0, n2, seed);

    // Verify single cycle property
    std::size_t len1 = 0, curr1 = 0;
    do { curr1 = next1[curr1]; len1++; } while (curr1 != 0);

    std::size_t len2 = 0, curr2 = 0;
    do { curr2 = next2[curr2]; len2++; } while (curr2 != 0);

    std::cout << "=== CYCLE INTEGRITY VERIFICATION ===" << std::endl;
    std::cout << "512 KiB (n=" << n1 << "): Cycle Length = " << len1 << " [Single Cycle Valid: " << (len1 == n1) << "]" << std::endl;
    std::cout << "1 MiB   (n=" << n2 << "): Cycle Length = " << len2 << " [Single Cycle Valid: " << (len2 == n2) << "]" << std::endl;

    // Simulate walk
    curr1 = 0;
    curr2 = 0;
    std::size_t match_steps = 0;
    for (std::size_t step = 0; step < work; ++step) {
        if (curr1 == curr2) match_steps++;
        curr1 = next1[curr1];
        curr2 = next2[curr2];
    }

    std::cout << "\n=== TERMINAL INDEX VERIFICATION (WORK_COUNT = " << work << ") ===" << std::endl;
    std::cout << "512 KiB Terminal Index: " << curr1 << std::endl;
    std::cout << "1 MiB   Terminal Index: " << curr2 << std::endl;
    std::cout << "Indices Match: " << (curr1 == curr2) << " (Value: " << curr1 << ")" << std::endl;

    std::cout << "\n=== TRAVERSAL PATH DIVERGENCE ===" << std::endl;
    std::cout << "Step 0 (Start): 512 KiB = 0, 1 MiB = 0" << std::endl;
    std::cout << "Step 1:         512 KiB = " << next1[0] << ", 1 MiB = " << next2[0] << " (Diverged immediately)" << std::endl;
    std::cout << "Total coincident steps: " << match_steps << " / " << work 
              << " (" << (100.0 * match_steps / work) << "%)" << std::endl;

    std::size_t shared_edges = 0;
    for (std::size_t i = 0; i < n1; ++i) {
        if (next1[i] == next2[i]) shared_edges++;
    }
    std::cout << "Shared directed edges in permutation: " << shared_edges << " / " << n1 
              << " (" << (100.0 * shared_edges / n1) << "%)" << std::endl;

    return 0;
}
