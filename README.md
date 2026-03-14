
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>NextExplorer Enterprise Manager</title>
  <style>
    :root{
      --bg:#0f172a;
      --bg2:#020617;
      --card:#111827;
      --card2:#1e293b;
      --line:#334155;
      --text:#e2e8f0;
      --muted:#94a3b8;
      --blue:#38bdf8;
      --green:#22c55e;
      --yellow:#facc15;
      --orange:#f59e0b;
      --red:#ef4444;
      --purple:#a78bfa;
      --cyan:#06b6d4;
    }

    *{box-sizing:border-box}

    body{
      margin:0;
      font-family:Arial, Helvetica, sans-serif;
      background:linear-gradient(180deg, var(--bg2), var(--bg));
      color:var(--text);
      line-height:1.6;
    }

    .container{
      max-width:1200px;
      margin:auto;
      padding:24px;
    }

    .hero{
      background:linear-gradient(135deg, #1d4ed8, #06b6d4, #16a34a);
      border-radius:22px;
      padding:40px;
      box-shadow:0 12px 32px rgba(0,0,0,.35);
      margin-bottom:24px;
    }

    .hero h1{
      margin:0 0 12px 0;
      font-size:42px;
      color:#fff;
    }

    .hero p{
      margin:0;
      font-size:18px;
      color:#e0f2fe;
      max-width:950px;
    }

    .badges{
      margin-top:18px;
      display:flex;
      flex-wrap:wrap;
      gap:10px;
    }

    .badge{
      display:inline-block;
      padding:8px 14px;
      border-radius:999px;
      background:rgba(255,255,255,.16);
      color:#fff;
      font-weight:bold;
      font-size:14px;
      border:1px solid rgba(255,255,255,.20);
    }

    .grid{
      display:grid;
      grid-template-columns:repeat(auto-fit,minmax(280px,1fr));
      gap:20px;
      margin-bottom:20px;
    }

    .card{
      background:var(--card);
      border:1px solid #1f2937;
      border-radius:18px;
      padding:24px;
      box-shadow:0 8px 24px rgba(0,0,0,.22);
      margin-bottom:20px;
    }

    h2{
      color:var(--blue);
      margin-top:0;
      border-bottom:2px solid #1f2937;
      padding-bottom:10px;
    }

    h3{
      color:var(--green);
      margin-top:22px;
      margin-bottom:10px;
    }

    p{margin:10px 0}
    .muted{color:var(--muted)}
    .highlight{color:var(--yellow); font-weight:bold}

    .tag{
      display:inline-block;
      margin:4px 6px 4px 0;
      padding:6px 10px;
      border-radius:8px;
      background:#1e293b;
      color:#93c5fd;
      border:1px solid #334155;
      font-size:13px;
    }

    .code{
      background:#020617;
      color:#93c5fd;
      border-left:4px solid #3b82f6;
      padding:14px;
      border-radius:10px;
      overflow:auto;
      white-space:pre-wrap;
      font-family:Consolas, monospace;
      font-size:14px;
    }

    .code-green{
      background:#052e16;
      color:#bbf7d0;
      border-left:4px solid #22c55e;
      padding:14px;
      border-radius:10px;
      overflow:auto;
      white-space:pre-wrap;
      font-family:Consolas, monospace;
      font-size:14px;
    }

    .code-yellow{
      background:#3f2a00;
      color:#fde68a;
      border-left:4px solid #f59e0b;
      padding:14px;
      border-radius:10px;
      overflow:auto;
      white-space:pre-wrap;
      font-family:Consolas, monospace;
      font-size:14px;
    }

    .info{
      background:#0b1220;
      border-left:5px solid var(--blue);
      border-radius:12px;
      padding:14px;
      color:#cbd5e1;
    }

    .warn{
      background:#3f1d1d;
      border-left:5px solid var(--red);
      border-radius:12px;
      padding:14px;
      color:#fecaca;
    }

    .success{
      background:#052e16;
      border-left:5px solid var(--green);
      border-radius:12px;
      padding:14px;
      color:#bbf7d0;
    }

    table{
      width:100%;
      border-collapse:collapse;
      margin-top:12px;
    }

    th,td{
      border:1px solid var(--line);
      padding:12px;
      text-align:left;
      vertical-align:top;
    }

    th{
      background:var(--card2);
      color:#7dd3fc;
    }

    td{
      background:#0b1220;
    }

    ul{
      padding-left:22px;
    }

    li{
      margin-bottom:8px;
    }

    .menu-list{
      padding-left:0;
      list-style:none;
    }

    .menu-list li{
      margin-bottom:10px;
      padding:10px 12px;
      border-radius:10px;
      background:#0b1220;
      border:1px solid #1f2937;
    }

    .footer{
      text-align:center;
      color:var(--muted);
      margin-top:28px;
      padding:18px;
      font-size:14px;
    }

    a{
      color:var(--blue);
      text-decoration:none;
    }

    a:hover{
      text-decoration:underline;
    }

    .two-col{
      display:grid;
      grid-template-columns:repeat(auto-fit,minmax(320px,1fr));
      gap:20px;
    }
  </style>
</head>
<body>
  <div class="container">

    <section class="hero">
      <h1>NextExplorer Enterprise Manager</h1>
      <p>
        PowerShell-based deployment and management tool for <strong>NextExplorer</strong>
        on <strong>Windows 11</strong> using <strong>Docker Desktop</strong>.
        This script helps you configure storage paths, manage server IP and port,
        start and stop the application, and perform cleanup or full uninstall operations.
      </p>

      <div class="badges">
        <span class="badge">Windows 11</span>
        <span class="badge">PowerShell</span>
        <span class="badge">Docker Desktop</span>
        <span class="badge">External HDD</span>
        <span class="badge">NAS Share</span>
        <span class="badge">LAN File Sharing</span>
        <span class="badge">Menu Driven</span>
      </div>
    </section>

    <section class="grid">
      <div class="card">
        <h2>Overview</h2>
        <p>
          This project creates a browser-based file portal using
          <span class="highlight">NextExplorer</span>. It supports publishing files from:
        </p>
        <ul>
          <li>Local folders</li>
          <li>External HDD / USB drives</li>
          <li>Mapped network drives</li>
          <li>NAS / UNC paths</li>
        </ul>
        <p>
          It also supports server IP and port configuration, adding and removing storage paths,
          firewall rule creation, Docker-based deployment, and full cleanup options.
        </p>
      </div>

      <div class="card">
        <h2>Main Features</h2>
        <div class="tag">Install / Reconfigure</div>
        <div class="tag">Start / Stop</div>
        <div class="tag">Add Storage Path</div>
        <div class="tag">Delete Storage Path</div>
        <div class="tag">IP / Port Setup</div>
        <div class="tag">Show Compose File</div>
        <div class="tag">Docker Cleanup</div>
        <div class="tag">Full Uninstall</div>
      </div>
    </section>

    <section class="card">
      <h2>Project Structure</h2>
      <div class="code">NextExplorer-Enterprise/
├── README.html
├── README.md
├── LICENSE
├── .gitignore
└── NextExplorer-Enterprise-Manager.ps1</div>
    </section>

    <section class="card">
      <h2>Requirements</h2>
      <table>
        <tr>
          <th>Component</th>
          <th>Requirement</th>
        </tr>
        <tr>
          <td>Operating System</td>
          <td>Windows 11</td>
        </tr>
        <tr>
          <td>Shell</td>
          <td>PowerShell 5.1 or later</td>
        </tr>
        <tr>
          <td>Container Runtime</td>
          <td>Docker Desktop</td>
        </tr>
        <tr>
          <td>Permissions</td>
          <td>Run script as Administrator</td>
        </tr>
        <tr>
          <td>Optional</td>
          <td>WSL2 backend for Docker Desktop</td>
        </tr>
      </table>
    </section>

    <section class="card">
      <h2>How to Run</h2>

      <h3>1. Create the folder</h3>
      <div class="code">New-Item -ItemType Directory -Path C:\NextExplorer1 -Force</div>

      <h3>2. Save the script file</h3>
      <p>Save your PowerShell script as:</p>
      <div class="code-green">C:\NextExplorer1\NextExplorer-Enterprise-Manager.ps1</div>

      <h3>3. Run the command in PowerShell as Administrator</h3>
      <div class="code-yellow">powershell -ExecutionPolicy Bypass -File "C:\NextExplorer1\NextExplorer-Enterprise-Manager.ps1"</div>

      <h3>4. Menu will appear</h3>
      <div class="code-green">1. Install / Configure / Reconfigure
2. Start NextExplorer
3. Stop NextExplorer
4. Show current server IP and port
5. Configure server IP and port
6. Add new storage path
7. Delete storage path
8. Show current docker-compose.yml
9. Delete configuration / stop / uninstall / full dependency cleanup
10. Show configured storage paths
11. Exit</div>

      <div class="info" style="margin-top:15px;">
        After configuration, open the application in your browser using:<br><br>
        <strong>http://SERVER-IP:PORT</strong>
      </div>
    </section>

    <section class="card">
      <h2>Main Menu</h2>
      <ul class="menu-list">
        <li><strong>1.</strong> Install / Configure / Reconfigure</li>
        <li><strong>2.</strong> Start NextExplorer</li>
        <li><strong>3.</strong> Stop NextExplorer</li>
        <li><strong>4.</strong> Show current server IP and port</li>
        <li><strong>5.</strong> Configure server IP and port</li>
        <li><strong>6.</strong> Add new storage path</li>
        <li><strong>7.</strong> Delete storage path</li>
        <li><strong>8.</strong> Show current docker-compose.yml</li>
        <li><strong>9.</strong> Delete configuration / stop / uninstall / full dependency cleanup</li>
        <li><strong>10.</strong> Show configured storage paths</li>
        <li><strong>11.</strong> Exit</li>
      </ul>
    </section>

    <section class="card">
      <h2>Delete Menu</h2>
      <ul class="menu-list">
        <li><strong>1.</strong> Delete configuration only</li>
        <li><strong>2.</strong> Stop only</li>
        <li><strong>3.</strong> Delete complete docker image and uninstall Docker Desktop</li>
        <li><strong>4.</strong> Delete all NextExplorer dependent application software files complete all</li>
        <li><strong>5.</strong> Back</li>
      </ul>

      <div class="warn">
        <strong>Important:</strong> Delete option 4 can remove Docker Desktop data and other Docker-related files from the system.
        Use it only when you want a full cleanup.
      </div>
    </section>

    <section class="card">
      <h2>Storage Path Examples</h2>

      <h3>Input examples</h3>
      <div class="code-yellow">E:\CompanyFiles
D:\Public
Z:\DepartmentShare
\\192.168.1.20\SharedData</div>

      <h3>Container mount examples</h3>
      <div class="code-green">E:\CompanyFiles        -> /mnt/CompanyFiles
D:\Public              -> /mnt/Public
Z:\DepartmentShare     -> /mnt/DepartmentShare
\\192.168.1.20\SharedData -> /mnt/NASData</div>
    </section>

    <section class="two-col">
      <div class="card">
        <h2>Server IP and Port</h2>
        <p>
          The script allows you to:
        </p>
        <ul>
          <li>Show current configured IP and port</li>
          <li>Show detected server LAN IP</li>
          <li>Configure server IP for PUBLIC_URL</li>
          <li>Configure custom port</li>
          <li>Update firewall rule automatically</li>
        </ul>
      </div>

      <div class="card">
        <h2>Access URL</h2>
        <div class="code-green">Local:
http://localhost:3000

LAN:
http://SERVER-IP:3000

Example:
http://192.168.1.100:3000</div>
      </div>
    </section>

    <section class="card">
      <h2>Generated Docker Compose Example</h2>
      <div class="code">services:
  nextexplorer:
    image: nxzai/explorer:latest
    container_name: nextexplorer
    restart: unless-stopped
    ports:
      - "3000:3000"
    volumes:
      - "./config:/config"
      - "./cache:/cache"
      - "E:/CompanyFiles:/mnt/CompanyFiles"
      - "D:/Public:/mnt/Public"
    environment:
      NODE_ENV: production
      PUBLIC_URL: "http://192.168.1.100:3000"</div>
    </section>

    <section class="card">
      <h2>Configuration Flow</h2>
      <div class="code">1. Run the script as Administrator
2. Select "Install / Configure / Reconfigure"
3. Configure server IP and port
4. Add one or more storage paths
5. Script builds docker-compose.yml
6. Firewall rule is created or updated
7. Docker container starts
8. Access the file portal from browser</div>
    </section>

    <section class="card">
      <h2>Firewall Rule</h2>
      <p>The script creates or updates a Windows Firewall rule for the selected port.</p>
      <div class="code">New-NetFirewallRule -DisplayName "NextExplorer" -Direction Inbound -Protocol TCP -LocalPort 3000 -Action Allow</div>
    </section>

    <section class="card">
      <h2>Troubleshooting</h2>

      <h3>Docker engine not running</h3>
      <div class="code">docker version
docker info</div>

      <h3>Storage path not visible</h3>
      <ul>
        <li>Check the folder path exists</li>
        <li>Check Docker Desktop has access to the drive</li>
        <li>Verify the generated docker-compose.yml</li>
        <li>Restart NextExplorer after changes</li>
      </ul>

      <h3>UNC path issue</h3>
      <p>Mapped drives are usually more reliable than direct UNC paths.</p>
      <div class="code">net use Z: \\192.168.1.20\SharedData /persistent:yes</div>
    </section>

    <section class="card">
      <h2>Recommended Use Cases</h2>
      <ul>
        <li>Internal file portal</li>
        <li>Department file sharing</li>
        <li>External HDD browser sharing</li>
        <li>NAS folder publishing through browser</li>
        <li>Lightweight LAN file access portal</li>
      </ul>
    </section>

    <section class="card">
      <h2>Security Note</h2>
      <div class="warn">
        This setup publishes files over HTTP on the configured port. For production use,
        place it behind HTTPS, a reverse proxy, VPN, or access control as needed.
      </div>
    </section>

    <section class="card">
      <h2>Author</h2>
      <p><strong>Ajith A</strong></p>
    </section>

    <section class="card">
      <h2>License</h2>
      <div class="success">
        This project can be distributed under the MIT License.
      </div>
    </section>

    <div class="footer">
      NextExplorer Enterprise Manager • Complete HTML README • Ready for GitHub or portfolio documentation
    </div>

  </div>
</body>
</html>
