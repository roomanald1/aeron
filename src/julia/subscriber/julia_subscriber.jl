using Aeron
using StringEncodings


conf = AeronConfig("aeron:udp?endpoint=localhost:50000", 2000, 10)

# Subscriber function
function subscriber()
    ctx = AeronContext(dir = "/dev/shm/aeron-root")
    Aeron.subscriber(ctx, conf; verbose=true) do sub
        println("Subscribed to $(conf.uri), stream $(conf.stream)")
        for message in sub
            result = replace(decode(message.buffer, "UTF-8"), "\0" => "")
            @info "Message received" result
        end
    end
end

subscriber()