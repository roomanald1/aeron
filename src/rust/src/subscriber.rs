use std::ffi::CString;
use std::slice;
use aeron::aeron::Aeron;
use aeron::concurrent::atomic_buffer::AtomicBuffer;
use aeron::concurrent::logbuffer::header::Header;
use aeron::context::Context;
use aeron::concurrent::strategies::{BusySpinIdleStrategy, Strategy};
use crate::{error_handler, str_to_c, TEST_CHANNEL, TEST_STREAM_ID};

pub fn start_subscriber() -> Result<(), String>{

    println!("Starting Subscriber");
    std::thread::sleep(std::time::Duration::from_secs(10));
    println!("After Delay");

    println!("Creating Aeron Context");
    let mut context = Context::new();
    let path = "/dev/shm/aeron-root";
    println!("path , {path}");
    context.set_aeron_dir(path.to_string());
    context.set_pre_touch_mapped_memory(true);
    context.set_error_handler(Box::new(error_handler));
    context.set_new_subscription_handler(Box::new(|channel: CString, stream_id: i32, correlation_id: i64| {
        println!("Subscription: {} {} {}", channel.to_str().unwrap(), stream_id, correlation_id)
    }));
    println!("Setting up Aeron");
    let mut aeron = Aeron::new(context).map_err(|e| e.to_string())?;


    println!("Adding Subscription");
    let sub_id = aeron.add_subscription(str_to_c(TEST_CHANNEL.to_string()), TEST_STREAM_ID).map_err(|e| e.to_string())?;
    println!("Subscription ID {}", sub_id);

    let subscription = loop {
        if let Ok(publication) = aeron.find_subscription(sub_id) {
            println!("Subscription found");
            break publication;
        }
        println!("Waiting for Subscription");
    };

    println!("Subscription found");
    let mut subscription = subscription.lock().map_err(|e|{ e.to_string()})?;

    println!("Subscription channel status {}", subscription.channel_status());
    let idle: BusySpinIdleStrategy = Default::default();
    idle.reset();
    println!("Polling for messages");


    let mut handler_f = |buffer: &AtomicBuffer, offset, length, header: &Header| {
        unsafe {
            let slice_msg = slice::from_raw_parts_mut(buffer.buffer().offset(offset as isize), length as usize);
            let msg = String::from_utf8_lossy(slice_msg).to_string();
            println!(
                "Message to stream {} from session {} ({}@{}): {}",
                header.stream_id(),
                header.session_id(),
                length,
                offset,
                msg
            );
        }
    };

    loop {
        let fragments = subscription.poll(&mut handler_f, 10);
        idle.idle_opt(fragments);
    }
}

