using Aeron
using StringEncodings


function run_publisher()
    conf = AeronConfig("aeron:udp?endpoint=localhost:50000", 2000, 10)
    ctx = AeronContext(dir = "/var/folders/zc/xcb_h6vn4j54dm55bz9sy68w0000gn/T/aeron-ronnieday")
    Aeron.publisher(ctx, conf) do pub
        @info "Publisher started"
        while true
            println(">")
            message = readline()
            put!(pub, Vector{UInt8}(message))
        end
    end
end

run_publisher()