# Samsung AC TLS Proxy Add-on

This local add-on bridges modern Home Assistant security requirements and legacy Samsung Air Conditioners using **TLSv1.0**.

## Source Code & Maintenance
The Docker container image template, build history, and scripts are hosted on GitHub:
👉 **GitHub Repository:** [https://github.com/Ivanszky/samsung-ac-tls-proxy](https://github.com/Ivanszky/samsung-ac-tls-proxy)

## Re-deployment / Restore Instructions
This add-on is completely backed up by native Home Assistant backups (`.tar`). If restoring:
1. Ensure your original `ac14k_m.pem` certificate file is dropped back into your `/config/` directory.
2. The Home Assistant Supervisor will read this folder's metadata, hit Docker Hub, and download the core image automatically.
