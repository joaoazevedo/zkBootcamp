%lang starknet
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import (
    Uint256,
    uint256_le,
    uint256_unsigned_div_rem,
    uint256_sub,
)
from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.math import unsigned_div_rem, assert_le_felt
from starkware.cairo.common.math import (
    assert_not_zero,
    assert_not_equal,
    assert_nn,
    assert_le,
    assert_lt,
    assert_in_range,
)
from exercises.contracts.erc20.ERC20_base import (
    ERC20_name,
    ERC20_symbol,
    ERC20_totalSupply,
    ERC20_decimals,
    ERC20_balanceOf,
    ERC20_allowance,
    ERC20_mint,
    ERC20_initializer,
    ERC20_transfer,
    ERC20_burn,
)

@constructor
func constructor{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    name: felt, symbol: felt, initial_supply: Uint256, recipient: felt
) {
    ERC20_initializer(name, symbol, initial_supply, recipient);
    admin.write(recipient);
    return ();
}

// Storage
//#########################################################################################

@storage_var
func admin() -> (name: felt) {
}

@storage_var
func whitelist(account: felt) -> (status: felt) {
}

// View functions
//#########################################################################################

@view
func name{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (name: felt) {
    let (name) = ERC20_name();
    return (name,);
}

@view
func get_admin{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    admin_address: felt
) {
    let (admin_address) = admin.read();
    return (admin_address,);
}
@view
func symbol{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (symbol: felt) {
    let (symbol) = ERC20_symbol();
    return (symbol,);
}

@view
func totalSupply{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    totalSupply: Uint256
) {
    let (totalSupply: Uint256) = ERC20_totalSupply();
    return (totalSupply,);
}

@view
func decimals{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    decimals: felt
) {
    let (decimals) = ERC20_decimals();
    return (decimals,);
}

@view
func balanceOf{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(account: felt) -> (
    balance: Uint256
) {
    let (balance: Uint256) = ERC20_balanceOf(account);
    return (balance,);
}

@view
func allowance{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    owner: felt, spender: felt
) -> (remaining: Uint256) {
    let (remaining: Uint256) = ERC20_allowance(owner, spender);
    return (remaining,);
}

// Externals
//###############################################################################################

@external
func transfer{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    recipient: felt, amount: Uint256
) -> (success: felt) {
    with_attr error_message("Amount must be even. Got: {amount}."){
        let (_, rem) = uint256_unsigned_div_rem(amount, Uint256(2, 0));
        assert rem = Uint256(0,0);
    }
    
    ERC20_transfer(recipient, amount);
    return (1,);
}

@external
func faucet{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(amount: Uint256) -> (
    success: felt
) {
    with_attr error_message("Amount must less than 10000. Got: {amount}."){
        let (res) = uint256_le(amount, Uint256(10000, 0));
        assert res = 1;
    }

    let (caller) = get_caller_address();
    ERC20_mint(caller, amount);
    return (1,);
}

@external
func burn{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(amount: Uint256) -> (
    success: felt
) {
    alloc_locals;

    let (local caller) = get_caller_address();
    let (local admin) = get_admin();
    assert_not_zero(caller);
    assert_not_zero(admin);

    let (fee, _) = uint256_unsigned_div_rem(amount, Uint256(10,0));

    ERC20_transfer(admin, fee);
    let (burn_amount) = uint256_sub(amount, fee);
    ERC20_burn(caller, burn_amount);

    return (1,);
}

@external
func request_whitelist{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    level_granted: felt
) {
    let (caller) = get_caller_address();
    assert_not_zero(caller);

    whitelist.write(caller, 1);
    return (1,);
}

@external
func check_whitelist{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    account: felt
) -> (allowed_v: felt) {
    with_attr error_message("Account must be an address. Got: {account}."){
        assert_not_zero(account);
    }

    let (allowed_v) = whitelist.read(account);
    return (allowed_v,);
}

@external
func exclusive_faucet{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    amount: Uint256
) -> (success: felt) {
    let (caller) = get_caller_address();

    with_attr error_message("Account is not whitelisted."){
        let (status) = check_whitelist(caller);
        assert status = 1;
    }

    ERC20_mint(caller, amount);
    return (success=1);
}

