using Aeron
using StringEncodings


conf = AeronConfig("aeron:udp?endpoint=localhost:50000", 2000, 10)

# Subscriber function
function subscriber()
    ctx = AeronContext(dir = "/var/folders/zc/xcb_h6vn4j54dm55bz9sy68w0000gn/T/aeron-ronnieday")
    Aeron.subscriber(ctx, conf; verbose=true) do sub
        println("Subscribed to $(conf.uri), stream $(conf.stream)")
        for message in sub
            result = decode(message.buffer, "UTF-8")
            @info "Message received" result
        end
    end
end

subscriber()