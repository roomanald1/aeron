
# Use the official Julia image as the base image
FROM julia:1.11.4

# Copy the Julia script into the container
COPY julia_publisher.jl /app/julia_publisher.jl

# Install necessary Julia packages
RUN julia -e 'using Pkg; Pkg.add(url="https://github.com/New-Earth-Lab/Aeron.jl"); Pkg.add("Lazy"); Pkg.add("Aeron_jll"); Pkg.add("CEnum"); Pkg.add("CSyntax"); Pkg.add("Compat"); Pkg.add("StringEncodings");Pkg.activate("."); Pkg.instantiate()'
# Precompile the project
RUN julia -e 'using Pkg; Pkg.precompile()'

EXPOSE 50000
# Run the Julia script
CMD ["julia", "/app/julia_publisher.jl"]
