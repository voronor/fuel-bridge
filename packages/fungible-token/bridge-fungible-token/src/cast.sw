library;

use std::constants::ZERO_B256;

impl From<b256> for u256 {
    fn from(value: b256) -> Self {
        value.as_u256()
    }

    fn into(self) -> b256 {
        let result: b256 = asm(r1: self) { r1: b256 };
        result
    }
}

// Weird sway / rust sdk bug does not allow to compile the contract, when enabling this test,
// with error <<missing u256 type>>, 
// Disabling for now as it is not too important, it is just a wrapper for b256.as_u256()

// #[test]
// fn test_b256_from() {
//     // Test the boundary conditions: min, middle, max
//     let min = b256::min();
//     let middle = 0x000000000000000000000000000000000000000000000000000000000000000a;
//     let max = b256::max();

//     // Alternatively, compare each field of the U256
//     assert_eq(u256::from(min), u256::min());
//     assert_eq(u256::from(middle), 0x000000000000000000000000000000000000000000000000000000000000000a_u256);
//     assert_eq(u256::from(max), u256::max());
// }


#[test]
fn test_b256_into() {
    // Test the boundary conditions: min, middle, max
    let min = u256::min();
    let middle = 0x000000000000000000000000000000000000000000000000000000000000000a_u256;
    let max = u256::max();

    let min_into_b256: b256 = min.into();
    let middle_into_b256: b256 = middle.into();
    let max_into_b256: b256 = max.into();

    assert(min_into_b256 == b256::min());
    assert(middle_into_b256 == 0x000000000000000000000000000000000000000000000000000000000000000a);
    assert(max_into_b256 == b256::max());
}
