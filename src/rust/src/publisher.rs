use std::ffi::CString;
use std::thread;
use std::time::Duration;
use aeron::aeron::Aeron;
use aeron::concurrent::atomic_buffer::{AlignedBuffer, AtomicBuffer};
use aeron::context::Context;
use crate::{error_handler,  str_to_c, TEST_CHANNEL, TEST_STREAM_ID};

pub fn start_publisher() -> Result<(), String> {

    println!("Starting Publisher");
    std::thread::sleep(std::time::Duration::from_secs(10));
    println!("After Delay");

    let mut context = Context::new();
    let path = "/dev/shm/aeron-root";
    println!("path , {path}");
    context.set_aeron_dir(path.to_string());
    context.set_pre_touch_mapped_memory(true);
    context.set_error_handler(Box::new(error_handler));
    context.set_new_publication_handler(Box::new(on_new_publication_handler));
    let mut aeron = Aeron::new(context).map_err(|e| e.to_string())?;

    println!("Setting up Aeron");
    let pub_id = aeron.add_publication(str_to_c(TEST_CHANNEL.to_string()), TEST_STREAM_ID).map_err(|e| e.to_string())?;

    println!("Publication ID {}", pub_id);
    let publication = loop {
        if let Ok(publication) = aeron.find_publication(pub_id) {
            println!("Publication found");
            break publication;
        }
        println!("Waiting for publication");
        std::thread::yield_now();
    };
    println!("Publication found");

    let channel_status = publication.lock().unwrap().channel_status();

    println!(
        "Publication channel status {} ",
        channel_status,
    );

    let mut count = 0;
    loop {
        count += 1;
        let message = format!("Message from Rust Publisher {}", count);
        println!("Sending data {}", message);
        let buffer = AlignedBuffer::with_capacity(256);
        let pub_buffer = AtomicBuffer::from_aligned(&buffer);

        let c_string =str_to_c(message);
        pub_buffer.put_bytes(0, c_string.as_bytes());

        let publisher = publication.lock().map_err(|e| e.to_string())?;

        if !publisher.is_connected() {
            println!("No Active Subscribers");
            continue;
        }

        let _ = publisher.offer(pub_buffer).map_err(|e| e.to_string())?;

        println!("Data Sent");

        thread::sleep(Duration::from_secs(1));
    }
}


fn on_new_publication_handler(channel: CString, stream_id: i32, session_id: i32, correlation_id: i64) {
    println!(
        "Publication: {} {} {} {}",
        channel.to_str().unwrap(),
        stream_id,
        session_id,
        correlation_id
    );
}
