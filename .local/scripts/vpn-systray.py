#!/usr/bin/env python3
import pystray
from PIL import Image, ImageDraw, ImageFont
import subprocess
import time
import threading
import os

class VPNSystray:
    def __init__(self):
        self.systray = None
        self.is_connected = False
        
    def create_image(self, color):
        """Create a VPN icon using Font Awesome glyph"""
        image = Image.new('RGBA', (24, 24), (0, 0, 0, 0))
        draw = ImageDraw.Draw(image)
        
        try:
            font = ImageFont.truetype("/usr/share/fonts/opentype/font-awesome/FontAwesome.otf", 22)
        except:
            try:
                font = ImageFont.truetype("/usr/share/fonts/truetype/font-awesome/fontawesome-webfont.ttf", 22)
            except:
                font = ImageFont.load_default()
        
        glyph = '\uf132'  # Shield icon
        
        bbox = draw.textbbox((0, 0), glyph, font=font)
        text_width = bbox[2] - bbox[0]
        text_height = bbox[3] - bbox[1]
        
        x = (24 - text_width) // 2
        y = (24 - text_height) // 2
        
        draw.text((x, y), glyph, fill=color, font=font)
        
        return image
        
    def check_vpn_status(self):
        """Check if VPN is connected by looking for tun0 interface"""
        try:
            result = subprocess.run(['ip', 'link', 'show', 'tun0'], 
                                  capture_output=True, text=True)
            return result.returncode == 0
        except:
            return False
            
    def update_display(self):
        """Update the systray display based on VPN status"""
        self.is_connected = self.check_vpn_status()
        
        if self.is_connected:
            color = '#00FF00'  # Green
        else:
            color = '#666666'  # Grey
            
        image = self.create_image(color)
        
        if self.systray:
            self.systray.icon = image
            
    def on_click(self, systray, query):
        """Open terminal and show VPN help file"""
        script_path = os.path.expanduser('~/.local/scripts/vpn-terminal.sh')
        subprocess.Popen(['terminator'])
        
    def monitor_vpn(self):
        """Background thread to monitor VPN status"""
        while True:
            self.update_display()
            time.sleep(5)
            
    def run(self):
        """Start the systray application"""
        self.systray = pystray.Icon(
            "vpn-monitor",
            self.create_image('#666666'),
            "VPN Status",
            pystray.Menu(
                pystray.MenuItem("Open VPN Terminal", self.on_click),
                pystray.MenuItem("Quit", lambda: self.systray.stop())
            )
        )
        
        monitor_thread = threading.Thread(target=self.monitor_vpn, daemon=True)
        monitor_thread.start()
        
        self.systray.run()

if __name__ == "__main__":
    app = VPNSystray()
    app.run()
