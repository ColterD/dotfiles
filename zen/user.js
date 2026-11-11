// Added 2026-11-10: hardware video decode on NVIDIA (RTX 4090) via libva-nvidia-driver (NVDEC).
// Remove this file to return to Zen defaults. Companion env vars live in ~/.local/share/applications/zen.desktop.
user_pref("media.ffmpeg.vaapi.enabled", true);
user_pref("media.hardware-video-decoding.force-enabled", true);
user_pref("widget.dmabuf.force-enabled", true);
