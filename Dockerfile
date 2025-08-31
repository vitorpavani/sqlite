# --- Stage 1: Build sqlite binary with Nix ---
FROM nixos/nix:latest AS builder

WORKDIR /build
COPY . .
# Build our Nix environment
RUN nix \
    --extra-experimental-features "nix-command flakes" \
    --option filter-syscalls false \
    build

# Copy the full Nix store closure for sqlite
RUN mkdir -p /tmp/nix-store-closure && \
    cp -R $(nix-store -qR result-bin/) /tmp/nix-store-closure && \
    DDB_PATH=$(readlink -f result-bin/bin/sqlite3) && \
    mkdir -p /tmp/bin && \
    ln -s "$DDB_PATH" /tmp/bin/sqlite3

# --- Stage 2: Minimal SCRATCH image with sqlite binary and all dependencies ---
FROM scratch
# Copy the full Nix store closure
COPY --from=builder /tmp/nix-store-closure /nix/store
# Copy the /bin/sqlite symlink
COPY --from=builder /tmp/bin/sqlite3 /bin/sqlite3

ENTRYPOINT ["/bin/sqlite3"]
CMD ["--help"]