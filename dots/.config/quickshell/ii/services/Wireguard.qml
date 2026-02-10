// Added in ChopOS dots

pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import QtQuick
import qs.modules.common

Singleton {
    id: root

    property bool wgenabled: Config.options.sidebar.vpn.enabled //if the connection is on

    property list<string> availableTunnels: [] //tunnels known by nmcli

    property list<string> wgActive: [] //active tunnels
    
    property string toDisplay: ""

    property string materialSymbol: wgenabled ? "vpn_key" : "vpn_key_off"

    onWgActiveChanged: {
        toDisplay = (wgActive.length > 0 && wgenabled) ? wgActive[0] : ""
    }

    // General control
    function toggleWg(): void {
        wgenabled && disconnectAll();
        wgenabled = !wgenabled;
        update()
    }

    function disconnectAll(): void {
        for (var i = 0; i < wgActive.length; i++) {
            wgTunnelDown(wgActive[i]);
        }
    }

    // Tunnel specific control
    function wgTunnelUp(wgname: string): void {
        if (availableTunnels.includes(wgname) && wgenabled) {
            Quickshell.execDetached(["nmcli", "connection", "up", wgname]);
            console.log("enabled vpn tunnel", wgname);
        }
        updateTimer.start();
    }

    function wgTunnelDown(wgname: string): void {
        if (wgActive.includes(wgname)) {
            Quickshell.execDetached(["nmcli", "connection", "down", wgname]);
            console.log("disabled vpn tunnel", wgname);
        }
        updateTimer.start();
    }

    function toggleWgTunnel(wgname: string): void {
        wgActive.includes(wgname) ? wgTunnelDown(wgname) : wgTunnelUp(wgname);
    }

    Process {
        id: getWGtunnels
        environment: ({
            LANG: "C",
            LC_ALL: "C"
        })
        stdout: SplitParser {
            onRead: line => {
                var info = line.split(":");
                if (info[2] != "wireguard") {
                    return;
                }
                if (!root.availableTunnels.includes(info[0])) {
                    root.availableTunnels.push(info[0])
                }
                if (info[1] === "yes") {
                    if (!root.wgActive.includes(info[0])) {
                        root.wgActive.push(info[0]);
                    }
                }
            }
        }
        stderr: SplitParser {
            onRead: line => console.log("wg list error:", line)
        }
        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0) console.log("Wireguard encountered no issues");
            else root.availableTunnels = []
        }
    }

    Timer {
        id: updateTimer
        interval: 200
        repeat: false
        running: false
        onTriggered: {
            root.update();
        }
    }

    // Status update
    function update() {
        wgActive = [];
        getWGtunnels.exec(["nmcli", "-t", "-f", "NAME,ACTIVE,TYPE", "connection", "show"])
    }

    Component.onCompleted: {
        update();
        var toStart = Config.options.sidebar.vpn.autostart
        toStart.forEach(name => {
            wgTunnelUp(name)
            console.log(name)
        })
    }
}
