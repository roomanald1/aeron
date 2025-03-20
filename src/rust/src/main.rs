mod publisher;
mod subscriber;
use std::{env};
use std::ffi::CString;
use aeron::utils::errors::AeronError;
use crate::publisher::start_publisher;
use crate::subscriber::start_subscriber;

fn main() -> Result<(), String> {
    let mode = env::var("MODE").unwrap_or("subscriber".to_string());
    match mode.as_ref() {
        "subscriber" => start_subscriber(),
        "publisher" => start_publisher(),
        other => Err(format!("Invalid Mode {}", other))
    }
}

pub const TEST_CHANNEL: &str = "aeron:udp?endpoint=localhost:50000";
pub const TEST_STREAM_ID: i32 = 2000;

fn error_handler(error: AeronError){
    println!("Error {}", error);
}


fn str_to_c(val: String) -> CString {
    CString::new(val).expect("Error converting str to CString")
}