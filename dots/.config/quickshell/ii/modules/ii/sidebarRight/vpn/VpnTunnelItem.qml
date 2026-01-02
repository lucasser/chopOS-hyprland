import qs
import qs.modules.common
import qs.modules.common.widgets
import qs.services
import QtQuick
import QtQuick.Layouts

DialogListItem {
    id: root
    required property string name
    active: Wireguard.wgActive.includes(name)
    enabled: true
    onClicked: {
        Wireguard.toggleWgTunnel(name);
    }

    contentItem: ColumnLayout {
        anchors {
            fill: parent
            topMargin: root.verticalPadding
            bottomMargin: root.verticalPadding
            leftMargin: root.horizontalPadding
            rightMargin: root.horizontalPadding
        }
        spacing: 0

        //[TODO]: add handshake info??
        RowLayout {
            // Name
            spacing: 10
            MaterialSymbol {
                iconSize: Appearance.font.pixelSize.larger
                text: root.active ? "vpn_key" : "vpn_key_off"
                color: Appearance.colors.colOnSurfaceVariant
            }
            StyledText {
                Layout.fillWidth: true
                color: Appearance.colors.colOnSurfaceVariant
                elide: Text.ElideRight
                text: name
            }
        }

        //[TODO]: dropdown with file contents

        Item {
            Layout.fillHeight: true
        }
    }
    Component.onCompleted: console.log(name)
}
