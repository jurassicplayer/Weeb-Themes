import QtQuick 2.7
import SddmComponents 2.0
import QtMultimedia 5.6
import QtQuick.Window 2.2
import Qt.labs.settings 1.0

Rectangle {
    id: container
    width: Screen.width
    height: Screen.height
    TextConstants { id: textConstants }

    Connections {
        target: sddm
        onLoginSucceeded: {
        }
        onLoginFailed: {
            txtMessage.text = textConstants.loginFailed
            listView.currentItem.password.text = ""
        }
    }
    
    Item {
		anchors.fill: parent
    }
}
