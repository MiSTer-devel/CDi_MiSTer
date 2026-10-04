#pragma once

#include <type_traits>
#include <verilated_save.h>

// Verilator 5.048 emits save calls for packed SystemVerilog structs but does
// not emit their operators. All generated structs in this design are plain
// value types, so serialize their object representation.
template <typename T, std::enable_if_t<std::is_trivially_copyable_v<T>, int> = 0>
inline VerilatedSerialize &operator<<(VerilatedSerialize &os, T &value) {
    return os.write(&value, sizeof(value));
}

template <typename T, std::enable_if_t<std::is_trivially_copyable_v<T>, int> = 0>
inline VerilatedDeserialize &operator>>(VerilatedDeserialize &os, T &value) {
    return os.read(&value, sizeof(value));
}
