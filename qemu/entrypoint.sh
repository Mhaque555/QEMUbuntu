#!/usr/bin/env bash
set -euo pipefail

RAM_MB="${RAM_MB:-12288}"
CPU_CORES="${CPU_CORES:-4}"
DISK_PATH="${DISK_PATH:-/storage/ubuntu.qcow2}"
DISK_SIZE="${DISK_SIZE:-1024G}"
ISO_URL="${ISO_URL:-https://releases.ubuntu.com/22.04.4/ubuntu-22.04.4-desktop-amd64.iso}"
ISO_PATH="${ISO_PATH:-/storage/ubuntu.iso}"
ISO_SHA256="${ISO_SHA256:-}"
BOOT_MODE="${BOOT_MODE:-install}"
VNC_ADDR="${VNC_ADDR:-0.0.0.0}"
VNC_PORT="${VNC_PORT:-5900}"
NOVNC_PORT="${NOVNC_PORT:-6080}"
DISPLAY_NUM="${DISPLAY_NUM:-0}"

log()  { echo "[INFO] $*"; }
warn() { echo "[WARN] $*"; }
err()  { echo "[ERROR] $*" >&2; }

log "Storage dir: /storage"
ls -al /storage || true

if [ ! -f "$DISK_PATH" ]; then
  log "Creating qcow2 disk at $DISK_PATH ($DISK_SIZE)"
  qemu-img create -f qcow2 "$DISK_PATH" "$DISK_SIZE"
fi

download_iso() {
  local url="$1" out="$2"
  log "Downloading ISO from $url -> $out"
  wget -c -O "$out" "$url"
}

verify_checksum() {
  local iso="$1" sum="$2"
  if [ -z "$sum" ]; then
    warn "ISO_SHA256 not set; skipping checksum verification."
    return 0
  fi
  log "Verifying SHA256 checksum..."
  local calc
  calc="$(sha256sum "$iso" | awk '{print $1}')"
  if [ "$calc" != "$sum" ]; then
    err "Checksum mismatch! Expected $sum, got $calc"
    return 1
  fi
  log "Checksum OK."
}

if [ "$BOOT_MODE" = "install" ]; then
  if [ ! -f "$ISO_PATH" ]; then
    log "ISO not found at $ISO_PATH; starting automatic download."
    download_iso "$ISO_URL" "$ISO_PATH"
    verify_checksum "$ISO_PATH" "$ISO_SHA256" || { rm -f "$ISO_PATH"; exit 1; }
  else
    log "ISO already present at $ISO_PATH; skipping download."
    verify_checksum "$ISO_PATH" "$ISO_SHA256" || { rm -f "$ISO_PATH"; exit 1; }
  fi
fi

log "Starting noVNC on port $NOVNC_PORT -> VNC 127.0.0.1:$VNC_PORT"
websockify --web /usr/share/novnc/ "$NOVNC_PORT" "127.0.0.1:$VNC_PORT" &

QEMU_CMD=(
  qemu-system-x86_64
  -m "$RAM_MB"
  -smp "$CPU_CORES"
  -vga virtio
  -hda "$DISK_PATH"
  -vnc "$VNC_ADDR:$DISPLAY_NUM"
  -netdev user,id=usernet,hostfwd=tcp::3389-:3389
  -device e1000,netdev=usernet

)

if [ -e /dev/kvm ]; then
  log "KVM found; enabling hardware acceleration"
  QEMU_CMD+=(-enable-kvm -cpu host)
else
  warn "/dev/kvm not found; running with software emulation (slower)"
fi

if [ "$BOOT_MODE" = "install" ]; then
  QEMU_CMD+=(-boot d -cdrom "$ISO_PATH")
else
  QEMU_CMD+=(-boot c)
fi

log "Launching QEMU: ${QEMU_CMD[*]}"
exec "${QEMU_CMD[@]}"
