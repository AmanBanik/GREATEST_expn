#include <algorithm>
#include <chrono>
#include <cstdint>
#include <iomanip>
#include <iostream>
#include <numeric>
#include <random>
#include <stdexcept>
#include <string>
#include <vector>

using Clock = std::chrono::steady_clock;
using u64 = std::uint64_t;
static volatile u64 result_sink = 0;

static std::size_t parse_positive(const char* s) {
    std::size_t used = 0;
    const std::string value(s);
    const auto parsed = std::stoull(value, &used);
    if (used != value.size() || parsed == 0)
        throw std::runtime_error("Expected a positive integer: " + value);
    return static_cast<std::size_t>(parsed);
}

static std::vector<u64> make_data(std::size_t n) {
    std::vector<u64> data(n);
    for (std::size_t i = 0; i < n; ++i)
        data[i] = static_cast<u64>(i) * 0x9e3779b97f4a7c15ULL + 1;
    return data;
}

static void make_cycle(std::vector<std::size_t>& next,
                       std::size_t begin, std::size_t length, u64 seed) {
    std::vector<std::size_t> order(length);
    std::iota(order.begin(), order.end(), begin);
    std::mt19937_64 rng(seed);
    std::shuffle(order.begin(), order.end(), rng);
    for (std::size_t i = 0; i < length; ++i)
        next[order[i]] = order[(i + 1) % length];
}

static u64 stream_kernel(const std::vector<u64>& data, std::size_t passes) {
    u64 sum = 0;
    for (std::size_t p = 0; p < passes; ++p)
        for (std::size_t i = 0; i < data.size(); ++i)
            sum += data[i];
    return sum;
}

static u64 random_kernel(const std::vector<u64>& data,
                         const std::vector<std::size_t>& order,
                         std::size_t accesses) {
    u64 sum = 0;
    for (std::size_t i = 0; i < accesses; ++i)
        sum += data[order[i % order.size()]];
    return sum;
}

static u64 chase_kernel(const std::vector<std::size_t>& next,
                        std::size_t accesses) {
    std::size_t p = 0;
    for (std::size_t i = 0; i < accesses; ++i)
        p = next[p];
    return static_cast<u64>(p);
}

static u64 chains_kernel(const std::vector<std::size_t>& next,
                         std::size_t chain_count,
                         std::size_t steps_per_chain) {
    std::vector<std::size_t> p(chain_count);
    const std::size_t segment = next.size() / chain_count;
    for (std::size_t c = 0; c < chain_count; ++c)
        p[c] = c * segment;

    for (std::size_t step = 0; step < steps_per_chain; ++step)
        for (std::size_t c = 0; c < chain_count; ++c)
            p[c] = next[p[c]];

    u64 sum = 0;
    for (auto value : p) sum += static_cast<u64>(value);
    return sum;
}

int main(int argc, char** argv) {
    try {
        if (argc < 5) {
            std::cerr << "Usage: " << argv[0]
                      << " MODE ELEMENTS WORK_COUNT REPEATS [CHAINS] [SEED]"
                      << std::endl
                      << "MODE: stream | random | chase | chains" << std::endl
                      << "ELEMENTS: uint64_t elements / pointer nodes" << std::endl
                      << "WORK_COUNT: stream passes; otherwise accesses or steps per chain"
                      << std::endl
                      << "REPEATS: timed repetitions" << std::endl
                      << "CHAINS: chains mode only; default 1" << std::endl
                      << "SEED: optional deterministic seed; default 12345"
                      << std::endl;
            return 2;
        }

        const std::string mode = argv[1];
        const std::size_t n = parse_positive(argv[2]);
        const std::size_t work = parse_positive(argv[3]);
        const std::size_t repeats = parse_positive(argv[4]);
        const std::size_t chains = (argc >= 6) ? parse_positive(argv[5]) : 1;
        const u64 seed = (argc >= 7)
            ? static_cast<u64>(parse_positive(argv[6])) : 12345ULL;

        if (n > static_cast<std::size_t>(-1) / sizeof(u64))
            throw std::runtime_error("Working-set byte count would overflow");
        if (mode == "chains" && (chains > n || n % chains != 0))
            throw std::runtime_error(
                "For chains mode, CHAINS must divide ELEMENTS and be <= ELEMENTS");

        // Setup is outside the timed region.
        std::vector<u64> data;
        std::vector<std::size_t> order;
        std::vector<std::size_t> next;

        if (mode == "stream" || mode == "random")
            data = make_data(n);

        if (mode == "random") {
            order.resize(n);
            std::iota(order.begin(), order.end(), 0);
            std::mt19937_64 rng(seed);
            std::shuffle(order.begin(), order.end(), rng);
        }

        if (mode == "chase") {
            next.resize(n);
            make_cycle(next, 0, n, seed);
        }

        if (mode == "chains") {
            next.resize(n);
            const std::size_t segment = n / chains;
            for (std::size_t c = 0; c < chains; ++c)
                make_cycle(next, c * segment, segment, seed + c);
        }

        auto kernel = [&]() -> u64 {
            if (mode == "stream") return stream_kernel(data, work);
            if (mode == "random") return random_kernel(data, order, work);
            if (mode == "chase") return chase_kernel(next, work);
            if (mode == "chains") return chains_kernel(next, chains, work);
            throw std::runtime_error("Unknown mode: " + mode);
        };

        // Warm-up makes this a repeated-use measurement, not a cold-start test.
        result_sink = kernel();

        std::cout << "mode,elements,working_set_bytes,work_count,chains,repeat,"
                     "seconds,operations,ns_per_operation,nominal_bytes,checksum"
                  << std::endl;

        for (std::size_t rep = 0; rep < repeats; ++rep) {
            const auto start = Clock::now();
            const u64 checksum = kernel();
            const double elapsed =
                std::chrono::duration<double>(Clock::now() - start).count();
            result_sink = checksum;

            double operations = 0.0;
            double nominal_bytes = 0.0;
            if (mode == "stream") {
                operations = static_cast<double>(n) * work;
                nominal_bytes = operations * sizeof(u64);
            } else if (mode == "random") {
                operations = static_cast<double>(work);
                nominal_bytes = operations * sizeof(u64);
            } else if (mode == "chase") {
                operations = static_cast<double>(work);
                nominal_bytes = operations * sizeof(std::size_t);
            } else {
                operations = static_cast<double>(work) * chains;
                nominal_bytes = operations * sizeof(std::size_t);
            }

            const double ns_per_op =
                elapsed * 1e9 / std::max(operations, 1.0);
            std::cout << mode << ',' << n << ',' << n * sizeof(u64) << ','
                      << work << ',' << ((mode == "chains") ? chains : 1)
                      << ',' << rep << ',' << std::setprecision(10) << elapsed
                      << ',' << operations << ',' << ns_per_op << ','
                      << nominal_bytes << ',' << checksum << std::endl;
        }
    } catch (const std::exception& e) {
        std::cerr << "Error: " << e.what() << std::endl;
        return 1;
    }
}
