using Aeron
using StringEncodings


function run_publisher()
    conf = AeronConfig("aeron:udp?endpoint=localhost:50000", 2000, 10)
    ctx = AeronContext(dir = "/dev/shm/aeron-root")
    counter = 0
    Aeron.publisher(ctx, conf) do pub
        @info "Publisher started"
        while true
            @info "Sleeping"
            sleep(3)
            counter += 1    
            message = "Message $counter"
            @info "Sending message" message
            put!(pub, Vector{UInt8}(message))
        end
    end
end

run_publisher()