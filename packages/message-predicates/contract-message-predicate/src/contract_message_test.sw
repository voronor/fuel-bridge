contract;

use contract_message_receiver::MessageReceiver;
use std::bytes::Bytes;
use std::constants::ZERO_B256;
use std::inputs::{input_message_data, input_message_data_length};
use std::call_frames::{first_param, second_param, called_method};

storage {
    counter: u64 = 0,
    data1: ContractId = ContractId::from(ZERO_B256),
    data2: u64 = 0,
    data3: b256 = ZERO_B256,
    data4: Address = Address::from(ZERO_B256),
}

// Define verification abi
abi VerifyMessageData {
    #[storage(read)]
    fn test_counter() -> u64;
    #[storage(read)]
    fn test_data1() -> ContractId;
    #[storage(read)]
    fn test_data2() -> u64;
    #[storage(read)]
    fn test_data3() -> b256;
    #[storage(read)]
    fn test_data4() -> Address;
}

abi MyCallerContract {
    #[storage(read,write)]
    fn call_low_level_call(
        target: ContractId,
        function_selector: Bytes,
        calldata: Bytes,
    );
}

impl MyCallerContract for Contract {
    
    #[storage(read,write)]
    fn call_low_level_call(
        target: ContractId,
        function_selector: Bytes,
        calldata: Bytes,
    ) {
        let payload = create_payload(target, function_selector, calldata);

        log(function_selector);
        log(calldata);
        log(payload);

    }
    
}

fn create_payload(
    target: ContractId,
    function_selector: Bytes,
    call_data: Bytes,
) -> Bytes {
    /*
    packs args according to spec (https://github.com/FuelLabs/fuel-specs/blob/master/src/vm/instruction_set.md#call-call-contract) :

    bytes   type        value   description
    32	    byte[32]    to      Contract ID to call.
    8	    byte[8]	    param1  First parameter (function selector pointer)
    8	    byte[8]	    param2  Second parameter (encoded arguments pointer)
    */
    Bytes::from(encode((
        target,
        asm(a: function_selector.ptr()) {
            a: u64
        },
        asm(a: call_data.ptr()) {
            a: u64
        },
    )))
}

// Converts a Bytes type to u64
// TODO: remove once an [into(self) -> u64] is added for the Bytes type
fn into_u64(b: Bytes) -> u64 {
    asm(ptr: b.ptr(), r0) {
        lw r0 ptr i0;
        r0: u64
    }
}

// Implement the process_message function required to be a message receiver
impl MessageReceiver for Contract {
    #[storage(read, write)]
    #[payable]
    fn process_message(msg_idx: u64) {
        log(msg_idx);
        storage.counter.write(0); // Temporary fix for: https://github.com/FuelLabs/sway/issues/4634
        storage.counter.write(storage.counter.read() + 1);

        // Parse the message data
        let data_length = input_message_data_length(msg_idx);
        if (data_length >= 32u16) {
            let contract_id: b256 = input_message_data(msg_idx, 0).into();
            storage.data1.write(ContractId::from(contract_id));
        }
        if (data_length >= 32u16 + 8u16) {
            let num: u64 = into_u64(input_message_data(msg_idx, 32));
            storage.data2.write(num);
        }
        if (data_length >= 32u16 + 8u16 + 32u16) {
            let big_num: b256 = input_message_data(msg_idx, 32 + 8).into();
            storage.data3.write(big_num);
        }
        if (data_length >= 32u16 + 8u16 + 32u16 + 32u16) {
            let address: b256 = input_message_data(msg_idx, 32 + 8 + 32).into();
            storage.data4.write(Address::from(address));
        }
    }
}

// Implement simple getters for testing purposes
impl VerifyMessageData for Contract {
    #[storage(read)]
    fn test_counter() -> u64 {
        storage.counter.read()
    }

    #[storage(read)]
    fn test_data1() -> ContractId {
        storage.data1.read()
    }

    #[storage(read)]
    fn test_data2() -> u64 {
        storage.data2.read()
    }

    #[storage(read)]
    fn test_data3() -> b256 {
        storage.data3.read()
    }

    #[storage(read)]
    fn test_data4() -> Address {
        storage.data4.read()
    }
}

#[fallback, storage(read)]
fn fallback() {
    log(255u64);
    log(254u64);
    log(253u64);

    let first_param = first_param();
    log(first_param);

    let second_param = second_param();
    log(second_param);
    
    let called_method = called_method();

    log(called_method);
}