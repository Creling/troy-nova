#include <gtest/gtest.h>
#include "../test.cuh"
#include "../../src/utils/rns.cuh"
#include <vector>

using namespace std;
using namespace troy;
using namespace troy::utils;

namespace rns {

    bool test_compose_decompose_single(const RNSBase& base, vector<uint64_t> input, vector<uint64_t> output, bool device) {

        Array<uint64_t> x(input.size(), false);
        x.copy_from_slice(ConstSlice<uint64_t>(input.data(), input.size(), false));

        if (device) x.to_device_inplace();

        base.decompose_single(x.reference());

        if (device) x.to_host_inplace();
        for (size_t i = 0; i < input.size(); i++) {
            if (x[i] != output[i]) return false;
        }

        if (device) x.to_device_inplace();
        base.compose_single(x.reference());

        if (device) x.to_host_inplace();
        for (size_t i = 0; i < input.size(); i++) {
            if (x[i] != input[i]) return false;
        }

        return true;
    }

    TEST(RNS, ComposeDecomposeSingle) {

        bool device = false;
        
        {
            Array<Modulus> moduli(1, false);
            moduli[0] = Modulus(2);
            RNSBase base(moduli.const_reference());
            ASSERT_TRUE(test_compose_decompose_single(base, {0}, {0}, device));
            ASSERT_TRUE(test_compose_decompose_single(base, {1}, {1}, device));
        }
        
        {
            Array<Modulus> moduli(1, false);
            moduli[0] = Modulus(5);
            RNSBase base(moduli.const_reference());
            ASSERT_TRUE(test_compose_decompose_single(base, {0}, {0}, device));
            ASSERT_TRUE(test_compose_decompose_single(base, {1}, {1}, device));
            ASSERT_TRUE(test_compose_decompose_single(base, {4}, {4}, device));
        }

        {
            Array<Modulus> moduli(2, false);
            moduli[0] = Modulus(3);
            moduli[1] = Modulus(5);
            RNSBase base(moduli.const_reference());
            ASSERT_TRUE(test_compose_decompose_single(base, {0, 0}, {0, 0}, device));
            ASSERT_TRUE(test_compose_decompose_single(base, {1, 0}, {1, 1}, device));
            ASSERT_TRUE(test_compose_decompose_single(base, {2, 0}, {2, 2}, device));
            ASSERT_TRUE(test_compose_decompose_single(base, {3, 0}, {0, 3}, device));
            ASSERT_TRUE(test_compose_decompose_single(base, {4, 0}, {1, 4}, device));
            ASSERT_TRUE(test_compose_decompose_single(base, {8, 0}, {2, 3}, device));
            ASSERT_TRUE(test_compose_decompose_single(base, {12, 0}, {0, 2}, device));
            ASSERT_TRUE(test_compose_decompose_single(base, {14, 0}, {2, 4}, device));
        }

        {
            Array<Modulus> moduli(3, false);
            moduli[0] = Modulus(2);
            moduli[1] = Modulus(3);
            moduli[2] = Modulus(5);
            RNSBase base(moduli.const_reference());
            ASSERT_TRUE(test_compose_decompose_single(base, {0, 0, 0}, {0, 0, 0}, device));
            ASSERT_TRUE(test_compose_decompose_single(base, {1, 0, 0}, {1, 1, 1}, device));
            ASSERT_TRUE(test_compose_decompose_single(base, {2, 0, 0}, {0, 2, 2}, device));
            ASSERT_TRUE(test_compose_decompose_single(base, {3, 0, 0}, {1, 0, 3}, device));
            ASSERT_TRUE(test_compose_decompose_single(base, {4, 0, 0}, {0, 1, 4}, device));
            ASSERT_TRUE(test_compose_decompose_single(base, {10, 0, 0}, {0, 1, 0}, device));
            ASSERT_TRUE(test_compose_decompose_single(base, {29, 0, 0}, {1, 2, 4}, device));
        }

        {
            Array<Modulus> moduli(4, false);
            moduli[0] = Modulus(13);
            moduli[1] = Modulus(37);
            moduli[2] = Modulus(53);
            moduli[3] = Modulus(97);
            RNSBase base(moduli.const_reference());
            ASSERT_TRUE(test_compose_decompose_single(base, {  0, 0, 0, 0}, {0, 0, 0, 0}, device));
            ASSERT_TRUE(test_compose_decompose_single(base, {  1, 0, 0, 0}, {1, 1, 1, 1}, device));
            ASSERT_TRUE(test_compose_decompose_single(base, {  2, 0, 0, 0}, {2, 2, 2, 2}, device));
            ASSERT_TRUE(test_compose_decompose_single(base, { 12, 0, 0, 0}, {12, 12, 12, 12}, device));
            ASSERT_TRUE(test_compose_decompose_single(base, {321, 0, 0, 0}, {9, 25, 3, 30}, device));
        }

        {
            Array<Modulus> moduli = Array<Modulus>::from_vector(
                utils::get_primes(2048, 60, 4)
            );
            RNSBase base(moduli.const_reference());
            Array<uint64_t> input = Array<uint64_t>::from_vector({
                0xAAAAAAAAAAA, 0xBBBBBBBBBB, 0xCCCCCCCCCC, 0xDDDDDDDDDD
            });
            Array<uint64_t> output = Array<uint64_t>::from_vector({
                utils::modulo_uint(input.const_reference(), moduli[0]),
                utils::modulo_uint(input.const_reference(), moduli[1]),
                utils::modulo_uint(input.const_reference(), moduli[2]),
                utils::modulo_uint(input.const_reference(), moduli[3])
            });
            ASSERT_TRUE(test_compose_decompose_single(base, input.to_vector(), output.to_vector(), device));
        }

    }

    bool test_compose_decompose_array(const RNSBase& base, vector<uint64_t> input, vector<uint64_t> output, bool device) {

        Array<uint64_t> x(input.size(), false);
        x.copy_from_slice(ConstSlice<uint64_t>(input.data(), input.size(), false));

        if (device) x.to_device_inplace();

        base.decompose_array(x.reference());

        if (device) x.to_host_inplace();
        for (size_t i = 0; i < input.size(); i++) {
            if (x[i] != output[i]) return false;
        }

        if (device) x.to_device_inplace();
        base.compose_array(x.reference());

        if (device) x.to_host_inplace();
        for (size_t i = 0; i < input.size(); i++) {
            if (x[i] != input[i]) return false;
        }

        return true;
    }

    void test_body_compose_decompose_array(bool device) {
        
        {
            Array<Modulus> moduli(1, false);
            moduli[0] = Modulus(2);
            RNSBase base(moduli.const_reference());
            if (device) base.to_device_inplace();
            ASSERT_TRUE(test_compose_decompose_array(base, {0}, {0}, device));
            ASSERT_TRUE(test_compose_decompose_array(base, {1}, {1}, device));
        }
        
        {
            Array<Modulus> moduli(1, false);
            moduli[0] = Modulus(5);
            RNSBase base(moduli.const_reference());
            if (device) base.to_device_inplace();
            ASSERT_TRUE(test_compose_decompose_array(base, {0, 1, 2}, {0, 1, 2}, device));
        }

        {
            Array<Modulus> moduli(2, false);
            moduli[0] = Modulus(3);
            moduli[1] = Modulus(5);
            RNSBase base(moduli.const_reference());
            if (device) base.to_device_inplace();
            ASSERT_TRUE(test_compose_decompose_array(base, {7, 0}, {1, 2}, device));
            ASSERT_TRUE(test_compose_decompose_array(base, {7, 0, 8, 0}, {1, 2, 2, 3}, device));
        }

        {
            Array<Modulus> moduli(3, false);
            moduli[0] = Modulus(3);
            moduli[1] = Modulus(5);
            moduli[2] = Modulus(7);
            RNSBase base(moduli.const_reference());
            if (device) base.to_device_inplace();
            ASSERT_TRUE(test_compose_decompose_array(base, {7, 0, 0}, {1, 2, 0}, device));
            ASSERT_TRUE(test_compose_decompose_array(base, {7, 0, 0, 8, 0, 0}, {1, 2, 2, 3, 0, 1}, device));
            ASSERT_TRUE(test_compose_decompose_array(base, {7, 0, 0, 8, 0, 0, 9, 0, 0}, {1, 2, 0, 2, 3, 4, 0, 1, 2}, device));
        }

        {
            Array<Modulus> moduli = Array<Modulus>::from_vector(
                utils::get_primes(2048, 60, 2)
            );
            RNSBase base(moduli.const_reference());
            if (device) base.to_device_inplace();
            Array<uint64_t> input = Array<uint64_t>::from_vector({
                0xAAAAAAAAAAA, 0xBBBBBBBBBB, 0xCCCCCCCCCC, 0xDDDDDDDDDD,
                0xEEEEEEEEEE, 0xFFFFFFFFFF
            });
            Array<uint64_t> output = Array<uint64_t>::from_vector({
                utils::modulo_uint(input.const_slice(0, 2), moduli[0]),
                utils::modulo_uint(input.const_slice(2, 4), moduli[0]),
                utils::modulo_uint(input.const_slice(4, 6), moduli[0]),
                utils::modulo_uint(input.const_slice(0, 2), moduli[1]),
                utils::modulo_uint(input.const_slice(2, 4), moduli[1]),
                utils::modulo_uint(input.const_slice(4, 6), moduli[1])
            });
            ASSERT_TRUE(test_compose_decompose_array(base, input.to_vector(), output.to_vector(), device));
        }

    }

    TEST(RNS, HostComposeDecomposeArray) {
        test_body_compose_decompose_array(false);
    }

    TEST(RNS, DeviceComposeDecomposeArray) {
        test_body_compose_decompose_array(true);
    }

}