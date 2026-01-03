import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.services
import qs.modules.common
import qs.modules.common.widgets

Item {
    id: root
    readonly property bool usePasswordChars: !PolkitService.flow?.responseVisible ?? true

    Keys.onPressed: event => { // Esc to close
        if (event.key === Qt.Key_Escape) {
            PolkitService.cancel();
        }
    }

    function submit() {
        PolkitService.submit(inputField.text);
    }
    Connections {
        target: PolkitService
        function onInteractionAvailableChanged() {
            if (!PolkitService.interactionAvailable) return;
            inputField.text = "";
            inputField.forceActiveFocus();
        }
    }

    Rectangle {
        id: bg
        anchors.fill: parent
        color: Appearance.colors.colScrim
        opacity: 0
        Component.onCompleted: {
            opacity = 1
        }
        Behavior on opacity {
            animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
        }
    }

    WindowDialog {
        anchors.centerIn: parent
        backgroundWidth: 450
        show: false
        Component.onCompleted: {
            show = true
        }

        MaterialSymbol {
            Layout.alignment: Qt.AlignHCenter
            iconSize: 26
            text: "security"
            color: Appearance.colors.colSecondary
        }

        WindowDialogTitle {
            id: titleText
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            text: Translation.tr("Authentication")
        }

        WindowDialogParagraph {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignLeft
            text: PolkitService.cleanMessage
        }

        MaterialTextField {
            id: inputField
            Layout.fillWidth: true
            focus: true
            enabled: PolkitService.interactionAvailable
            placeholderText: PolkitService.cleanPrompt
            echoMode: root.usePasswordChars ? TextInput.Password : TextInput.Normal
            onAccepted: root.submit();

            Keys.onPressed: event => { // Esc to close
                if (event.key === Qt.Key_Escape) {
                    PolkitService.cancel();
                }
            }
        }

        WindowDialogButtonRow {
            Layout.bottomMargin: 10 // I honestly don't know why this is necessary
            Item {
                Layout.fillWidth: true
            }
            DialogButton {
                buttonText: Translation.tr("Cancel")
                onClicked: PolkitService.cancel();
            }
            DialogButton {
                enabled: PolkitService.interactionAvailable
                buttonText: Translation.tr("OK")
                onClicked: root.submit();
            }
        }
    }


    // //I love fingering
    // function tryFingerUnlock() {
    //     if (root.fingerprintsConfigured) {
    //         fingerPam.start();
    //     }
    // }

    // function stopFingerPam() {
    //     if (fingerPam.active) {
    //         fingerPam.abort();
    //     }
    // }

    // Process {
    //     id: fingerprintCheckProc
    //     running: true
    //     command: ["bash", "-c", "fprintd-list $(whoami)"]
    //     stdout: StdioCollector {
    //         id: fingerprintOutputCollector
    //         onStreamFinished: {
    //             root.fingerprintsConfigured = fingerprintOutputCollector.text.includes("Fingerprints for user");
    //         }
    //     }
    //     onExited: (exitCode, exitStatus) => {
    //         if (exitCode !== 0) {
    //             // console.warn("[LockContext] fprintd-list command exited with error:", exitCode, exitStatus);
    //             root.fingerprintsConfigured = false;
    //         }
    //     }
    // }

    // PamContext {
    //     id: fingerPam

    //     configDirectory: "pam"
    //     config: "fprintd.conf"

    //     onCompleted: result => {
    //         if (result == PamResult.Success) {
    //             root.unlocked(root.targetAction);
    //             stopFingerPam();
    //         } else if (result == PamResult.Error) { // if timeout or etc..
    //             tryFingerUnlock()
    //         }
    //     }
    // }
}
