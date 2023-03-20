from starkware.cairo.common.bitwise import bitwise_and, bitwise_xor
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin, HashBuiltin

// Implement a function that sums even numbers from the provided array
func sum_even{bitwise_ptr: BitwiseBuiltin*}(arr_len: felt, arr: felt*, run: felt, idx: felt) -> (
    sum: felt
) {
    if (idx == arr_len) {
        return (0,);
    }

    let (r) = sum_even(arr_len, arr, run, idx + 1);

    let (x_and_y) = bitwise_and(arr[idx], 0x1);
    if (x_and_y == 0) {
        return (sum =  r + arr[idx]);
    } else {
        return (sum =  r);
    }
}
