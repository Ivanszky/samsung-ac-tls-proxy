# Samsung AC Proxy Home Assistant Add-on

A secure, lightweight TLS/SSL proxy bridge designed specifically for older Generation 1 Samsung Air Conditioners (which use non-standard or legacy TLSv1 handshakes). This add-on allows modern integrations like **Climate IP** to communicate seamlessly with your AC unit by handling the complex encryption wrapping and port routing automatically.

## How It Works


```

[Climate IP Integration] ---> (Port 2878 via local TLS) ---> [Stunnel (Decrypts)]
|
v
[Samsung AC Unit] <--- (Port 8888 via legacy TLS1) <--- [Socat (Re-encrypts)]

```

1. **Inbound Connection**: The add-on uses `stunnel` to accept an incoming local SSL connection from Climate IP on port `2878`.
2. **Internal Bridge**: It strips the modern SSL layer and passes the raw traffic locally to `socat`.
3. **Outbound Connection**: `socat` re-encrypts the stream using the specific legacy `ac14k_m.pem` certificate and establishes a TLSv1 handshake with your physical AC unit on port `8888`.

---

## Installation & Production Setup

1. In your Home Assistant interface, navigate to **Settings** -> **Add-ons** -> **Add-on Store**.
2. Click the three dots (top right menu) and select **Repositories**.
3. Paste the URL of your GitHub repository and click **Add**:
   ```text
   [https://github.com/gaborivanszky/samsung-ac-proxy](https://github.com/gaborivanszky/samsung-ac-proxy)

```

4. Close the popup, refresh your browser page, and locate **Samsung AC Proxy** under the new repository section.
5. Click **Install**.

### Configuration

Once installed, navigate to the **Configuration** tab in the Add-on interface and set your AC's IP:

```yaml
ac_ip: "192.168.0.70"

```

Click **Save** and then return to the **Info** tab to **Start** the add-on.

### Climate IP Integration Settings

Configure your **Climate IP** integration with these parameters to route its traffic through the proxy:

* **IP Address / Host**: `127.0.0.1`
* **Port**: `2878`

---

## Developer Documentation (Maintenance & Changes)

This section outlines how to check out, modify, test locally on your build machine, and push updates back to HAOS.

### 1. Repository Management & Checkout

To make changes to the source files, clone the repository to your local development/build machine:

```bash
# Clone the repository
git clone [https://github.com/gaborivanszky/samsung-ac-proxy.git](https://github.com/gaborivanszky/samsung-ac-proxy.git)
cd samsung-ac-proxy

```

The repository structure looks like this:

```text
samsung_ac_proxy/       
├── samsung-ac-addon/   <-- Add-on slug folder containing HA OS configs
│   ├── config.yaml     <-- HAOS Add-on Configuration & Versioning
│   ├── Dockerfile      <-- Image environment (installs jq, stunnel, socat)
│   ├── run.sh          <-- Engine startup script (parses options.json via jq)
│   └── ac14k_m.pem     <-- Legacy Samsung TLS token certificate
└── README.md

```

### 2. Local Testing Workflow (Simulating HAOS)

Before pushing updates to GitHub, you can build and run the container locally on your build environment. Because the production script dynamically reads from HAOS GUI options, you must mock the `/data/options.json` file.

**Step A: Build the local image**

```bash
docker build -t gaborivanszky/samsung-ac-proxy:1.0.0 ./samsung-ac-addon

```

**Step B: Set up local mock configuration data**
Create a local folder structure to simulate the Home Assistant storage volume:

```bash
mkdir -p ./data
echo '{"ac_ip": "192.168.0.70"}' > ./data/options.json

```

*(Note: If you run docker commands before creating this directory, Docker might auto-create it as root. Fix host ownership if needed using `sudo chown -R $(id -u):$(id -g) ./data`)*

**Step C: Execute the container using the data mount**
Run the container by passing the local file structure as a volume mount, exposing the inbound port:

```bash
docker run -it --rm \
  -v "$(pwd)/data:/data" \
  -p 2878:2878 \
  gaborivanszky/samsung-ac-proxy:1.0.0 \
  /run.sh

```

### 3. Deploying Changes & Triggering HAOS Updates

When you are satisfied with your local code modifications, you must increment the version number to force HAOS to recognize the update.

1. Open `samsung-ac-addon/config.yaml`.
2. Increment the `version` block (e.g., bump from `1.1.0` to `1.2.0`).
3. Commit and push the changes to GitHub:
```bash
git add .
git commit -m "Fix/Feat: Describe your modifications here and bump version"
git push origin main

```


4. Go to **Home Assistant** -> **Settings** -> **Add-ons** -> **Add-on Store**.
5. Click the three dots in the top right, select **Check for updates**.
6. Return to your Add-on page, and click **Update** to build the fresh code.
