// Added in ChopOS dots

pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import QtQuick
import qs.modules.common

/**
 * Assume all wireguard config files are in ~/.config/wireguard/ because im too lazy to do otherwise
 */
Singleton {
    id: root

    property bool wgenabled: Config.options.sidebar.vpn.enabled //if the connection is on

    property list<string> availableTunnels: [] //tunnel configs found in ~/.config/wireguard

    property var wgActive: Config.options.sidebar.vpn.autostart //tunnels we want to enable
    
    property string toDisplay: ""

    property int tunnelAmount: 0

    property string materialSymbol: wgenabled ? "vpn_key" : "vpn_key_off"

    // General control
    function toggleWg(): void {
        wgenabled ? disconnectAll() : connectAll();
        wgenabled = !wgenabled;
        update()
    }

    function connectAll(): void {
        for (var i = 0; i < wgActive.length; i++) {
            var tunnel = makeWireguardConfUrl(wgActive[i]) + ".conf"
            console.log("[WG] started", tunnel)
            Quickshell.execDetached(["bash", Quickshell.shellPath("scripts/network/wg-utils.sh"), "up", tunnel]);
        }
    }

    function disconnectAll(): void {
        for (var i = 0; i < wgActive.length; i++) {
            var tunnel = makeWireguardConfUrl(wgActive[i]) + ".conf"
            Quickshell.execDetached(["bash", Quickshell.shellPath("scripts/network/wg-utils.sh"), "down", tunnel]);
        }
    }

    // Tunnel specific control
    function addWgTunnel(wgname: string): void {
        if (!wgActive.includes(wgname)) {
            wgActive.push(wgname);
            reloadWg();
        }
        console.log("added vpn tunnel", wgname);
    }

    function removeWgTunnel(wgname: string): void {
        if (wgActive.includes(wgname)) {
            if (wgenabled) {
                var tunnel = makeWireguardConfUrl(wgname) + ".conf"
                Quickshell.execDetached(["bash", Quickshell.shellPath("scripts/network/wg-utils.sh"), "down", tunnel]);
            }
            wgActive = wgActive.filter(t => t !== wgname)
            reloadWg()
        }
    }

    function toggleWgTunnel(wgname: string): void {
        wgActive.includes(wgname) ? removeWgTunnel(wgname) : addWgTunnel(wgname);
    }

    function makeWireguardConfUrl(name: string): string {
        return `${Directories.config.slice(7)}/wireguard/${name}`;
    }

    function reCacheWg() {
        reCache.exec(["sh", "-c", "ls " + makeWireguardConfUrl("") + "*.conf"])
    }

    function reloadWg(): void {
        update();
        if (wgenabled) {
            connectAll();
        }
    }

    Process {
        id: reCache
        environment: ({
            LANG: "C",
            LC_ALL: "C"
        })
        stdout: SplitParser {
            onRead: line => {
                if (line.trim() !== "") {
                    console.log(line)
                    var name = line.split("/").pop().replace(/\.conf$/, "");
                    if (!root.availableTunnels.includes(name)) {
                        root.availableTunnels.push(name)
                    }
                }
            }
        }
        stderr: SplitParser {
            onRead: line => console.log("wg recache error:", line)
        }
        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0) console.log("WireGuard recache finished:", root.availableTunnels)
            else root.availableTunnels = []
        }
    }

    // Status update
    function update() {
        toDisplay = wgActive.length > 0 && wgenabled ? wgActive[0] : ""
        tunnelAmount = wgActive.length
    }

    Component.onCompleted: reloadWg()
}
