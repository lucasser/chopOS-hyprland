import QtQuick
import qs.services
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets

QuickToggleModel {
    name: "VPN"
    statusText: Wireguard.toDisplay
    tooltipText: ("%1 Tunnel(s) | Right-click to configure").arg(Wireguard.tunnelAmount)
    icon: Wireguard.materialSymbol

    toggled: Wireguard.wgenabled
    mainAction: () => Wireguard.toggleWg()
    hasMenu: true

    Component.onCompleted: console.log(Wireguard.toDisplay)
}
