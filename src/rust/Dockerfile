
# Use the official Rust image as the build stage
FROM rust:1.65.0 AS builder

# Create a new directory for the application source code
WORKDIR /usr/src/aeron_test

# Copy the Cargo.toml and source code to the container
COPY Cargo.toml ./
COPY src ./src

# Build the application in release mode
RUN cargo build --release

# Use a minimal image for the final stage
FROM debian:buster-slim

# Set the working directory
WORKDIR /usr/local/bin

# Copy the compiled binary from the builder stage
COPY --from=builder /usr/src/aeron_test/target/release/aeron_test .

# Set the environment variable to run the publisher
ENV MODE=publisher

EXPOSE 50000

# Run the Rust publisher binary
CMD ["./aeron_test"]