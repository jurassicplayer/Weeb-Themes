import QtQuick 2.7
import SddmComponents 2.0
import QtMultimedia 5.6
import QtQuick.Window 2.2
import QtGraphicalEffects 1.0
import Qt.labs.settings 1.0

Rectangle {
    id: container
    width: Screen.width
    height: Screen.height
    color: "white"
    
    
    //TextConstants { id: textConstants }
    // Meh, it might be good to keep at least one reference to it around so I at least know that SDDM provides
    // text constants somewhere in the event that I don't want to use my own words somewhere.
    // On that note, there are other SDDM components that are available...I could make my own.
    // TextConstants { id: textConstants }

    Timer {
        id: notificationResetTimer
        interval: 3000
        onTriggered: { passwordIncorrect.visible = false; passwordText.visible = true }
    }
    Connections {
        target: sddm
        onLoginSucceeded: {
        }
        onLoginFailed: {
            notificationResetTimer.restart()
            password.clear()
            passwordText.visible = false
            passwordIncorrect.visible = true
        }
    }

    // Regurgitate userModel information into a ListModel that I can actually grab information from.
    ListModel {
        id: userList
        property int lastIndex: userModel.lastIndex
        property string lastUser: userModel.lastUser
        property int currentIndex: userModel.lastIndex
        property bool complete: false
        function incrementCurrentIndex() {
            // Index and count are offset by 1 (index starts at zero, count starts at 1)
            if (userList.currentIndex == userList.count-1) {
                userList.currentIndex = 0;
            } else {
                userList.currentIndex += 1;
            }
        }
        function decrementCurrentIndex() {
            // Index and count are offset by 1 (index starts at zero, count starts at 1)
            if (userList.currentIndex == 0) {
                userList.currentIndex = userList.count-1;
            } else {
                userList.currentIndex -= 1;
            }
        }
        Component.onCompleted: { (userList.count == userModel.count) ? complete = true : complete = false }
    }
    ListView {
        model: userModel
        delegate: Item {
            Component.onCompleted: {
                userList.append({
                    "name": (model.realName === "") ? model.name : model.realName,
                    "realName": model.realName,
                    "homeDir": model.homeDir,
                    "icon": model.icon,
                    "needsPassword": model.needsPassword
                })
            }
        }
    }

    // Functions
    function nextTarget(current, step) {
        var targets = [prevUser, password, nextUser, suspendBorder, hibernateBorder, rebootBorder, shutdownBorder];
        for (var target in targets) {
            // Remove invisible targets
            if (!target.visible) {
                var index = targets.indexOf(target);
                if (index > -1) {
                    targets.splice(index, 1);
                }
            }
        }
        var index = targets.indexOf(current)
        if ( (index + step) > targets.length - 1 ) {
            return targets[0]
        } else if ( (index + step) == -1 ) {
            return targets[targets.length - 1]
        } else {
            return targets[index+step]
        }
    }

    // Background media
    Item {
        anchors.fill: parent
        /********* Image *********/
        Image {
            id: backgroundImage
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            property string imageID: (Math.floor(Math.random() * (8 - 1 + 1)) + 1);
            source: "resources/wallpapers/"+imageID
            MouseArea {
                anchors.fill: parent
                onClicked: backgroundImage.focus = true
            }
            Keys.onPressed: {
                if (event.key === Qt.Key_Backtab) shutdownBorder.focus = true;
                else if (event.key === Qt.Key_Tab) password.focus = true;
            }
        }
        /********* Video *********
        MediaPlayer {
            id: mediaPlayer
            source: "resources/vid.mp4"
            autoLoad: false
            loops: -1
        }
        VideoOutput {
            source: mediaPlayer
            anchors.fill: parent
            fillMode: VideoOutput.PreserveAspectCrop
        }
        ********* Audio *********
        Audio {
            id: musicPlayer
            autoLoad: false
            source: "resources/bgm.ogg"
            loops: -1
        }*/
    }

    // Login container
    Rectangle {
        id: root
        anchors.horizontalCenter: parent.horizontalCenter
        y: (parent.height - root.height) * 0.5
        width: 350
        height: 400
        color: "transparent"
        Rectangle {
            id: loginRectangleTemplate
            y: parent.height * 0.5 + avatarBorder.height * 0.3
            height: 80
            width: 150
            radius: 4
            visible: false
        }
        Rectangle {
            id: loginBorder
            x: (parent.width - loginBorder.width) * 0.5
            y: (parent.height - loginBorder.height) * 0.5
            width: avatarBorder.width
            height: loginBorder.width
            radius: loginBorder.width
            color: "white"
            MouseArea { anchors.fill: parent }
            Item {
                id: loginContainer
                visible: false
                anchors.fill: parent
                property int textMargin: 10
                Item {
                    id:loginUser
                    width: parent.width
                    height: parent.height * 0.5
                    Text {
                        id: userName
                        anchors.fill: parent
                        anchors.leftMargin: loginContainer.textMargin
                        anchors.rightMargin: loginContainer.textMargin
                        clip: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 20
                        text: if (userList.complete) (userList.get(userList.currentIndex).name == "" ? userList.get(userList.currentIndex).realName : userList.get(userList.currentIndex).name)
                    }
                }
                Item {
                    id: loginPassword
                    width: loginUser.width
                    height: loginUser.height
                    anchors.top: loginUser.bottom
                    TextInput {
                        id: password
                        anchors.fill: parent
                        anchors.leftMargin: loginContainer.textMargin
                        anchors.rightMargin: loginContainer.textMargin
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 13
                        clip: true
                        echoMode: TextInput.Password
                        Text {
                            id: passwordText
                            anchors.fill: parent
                            font.pixelSize: 13
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            text: password.text ? "" : "Password"
                            color: "#656565"
                        }
                        Text {
                            id: passwordIncorrect
                            anchors.fill: parent
                            visible: false
                            font.pixelSize: 13
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            text: password.text ? "" : "Incorrect password"
                            color: "#656565"
                        }
                        KeyNavigation.backtab: prevUser
                        KeyNavigation.tab: nextUser
                        Keys.onPressed: {
                            if (event.key === Qt.Key_Return || event.key == Qt.Key_Enter) {
                                sddm.login(userName.text, password.text, sessionModel.lastIndex)
                                event.accepted = true
                            }
                        }
                    }
                }
            }
        }
        // Avatar icon
        Item {
            anchors.fill: parent
            Rectangle {
                id: prevUser
                anchors.verticalCenter: avatarBorder.verticalCenter
                x: (parent.width * prevUser.iconX) - (prevUser.width / 2)  // Don't use this value for X placement
                width: avatarBorder.width * 0.35
                height: prevUser.width
                radius: prevUser.width
                property bool pUToggle: if (prevUser.focus) { pUWidth.running = true; pUX.running = true; true;} else { pUWidth.running = false; pUX.running = false; false; }
                property double iconX: 0.15  // Use this value for X placement (percentage of root.width)
                property double maxSize: 1.25
                property int animationDuration: 300
                SequentialAnimation on x {
                    id:pUX
                    running:false
                    loops: Animation.Infinite
                    alwaysRunToEnd: true
                    PropertyAnimation { from: ((root.width * prevUser.iconX) - (prevUser.width / 2)); to: ((root.width * prevUser.iconX) - (prevUser.width * prevUser.maxSize / 2)); duration: prevUser.animationDuration }
                    PropertyAnimation { from: ((root.width * prevUser.iconX) - (prevUser.width * prevUser.maxSize / 2)); to: ((root.width * prevUser.iconX) - (prevUser.width / 2)); duration: prevUser.animationDuration }
                }
                SequentialAnimation on width {
                    id: pUWidth
                    running: false
                    loops: Animation.Infinite
                    alwaysRunToEnd: true
                    PropertyAnimation { from: prevUser.width; to: prevUser.width * prevUser.maxSize; duration: prevUser.animationDuration }
                    PropertyAnimation { from: prevUser.width * prevUser.maxSize; to: prevUser.width; duration: prevUser.animationDuration }
                }
                MouseArea {
                    id: prevUserArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: { pUWidth.running = true; pUX.running = true }
                    onExited: { pUWidth.running = false; pUX.running = false }
                    onClicked: {
                        userList.decrementCurrentIndex()
                        password.clear()
                    }
                }
                KeyNavigation.backtab: shutdownBorder
                KeyNavigation.tab: password
                Keys.onPressed: {
                    if (event.key == Qt.Key_Return || event.key == Qt.Key_Enter || event.key == Qt.Key_Space) {
                        userList.decrementCurrentIndex()
                        password.clear()
                    }
                }
            }
            Rectangle {
                id: nextUser
                anchors.verticalCenter: avatarBorder.verticalCenter
                x: (parent.width * nextUser.iconX) - (nextUser.width / 2)  // Don't use this value for X placement
                width: avatarBorder.width * 0.35
                height: nextUser.width
                radius: nextUser.width
                property bool nUToggle: if (nextUser.focus) { nUWidth.running = true; nUX.running = true; true;} else { nUWidth.running = false; nUX.running = false; false; }
                property double iconX: 0.85  // Use this value for X placement (percentage of root.width)
                property double maxSize: prevUser.maxSize
                property int animationDuration: prevUser.animationDuration
                SequentialAnimation on x {
                    id:nUX
                    running:false
                    loops: Animation.Infinite
                    alwaysRunToEnd: true
                    PropertyAnimation { from: ((root.width * nextUser.iconX) - (nextUser.width / 2)); to: ((root.width * nextUser.iconX) - (nextUser.width * nextUser.maxSize / 2)); duration: nextUser.animationDuration }
                    PropertyAnimation { from: ((root.width * nextUser.iconX) - (nextUser.width * nextUser.maxSize / 2)); to: ((root.width * nextUser.iconX) - (nextUser.width / 2)); duration: nextUser.animationDuration }
                }
                SequentialAnimation on width {
                    id: nUWidth
                    running: false
                    loops: Animation.Infinite
                    alwaysRunToEnd: true
                    PropertyAnimation { from: nextUser.width; to: nextUser.width * nextUser.maxSize; duration: nextUser.animationDuration }
                    PropertyAnimation { from: nextUser.width * nextUser.maxSize; to: nextUser.width; duration: nextUser.animationDuration }
                }
                MouseArea {
                    id: nextUserArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: { nUWidth.running = true; nUX.running = true }
                    onExited: { nUWidth.running = false; nUX.running = false }
                    onClicked: {
                        userList.incrementCurrentIndex()
                        password.clear()
                    }
                }
                KeyNavigation.backtab: password
                KeyNavigation.tab: suspendBorder
                Keys.onPressed: {
                    if (event.key == Qt.Key_Return || event.key == Qt.Key_Enter || event.key == Qt.Key_Space) {
                        userList.incrementCurrentIndex()
                        password.clear()
                    }
                }
            }
            Rectangle {
                id: avatarBorder
                width: 150
                height: avatarBorder.width
                radius: avatarBorder.width
                color: "white"
                x: (parent.width - avatarBorder.width) * 0.5
                y: (parent.height - avatarBorder.height) * 0.5
                MouseArea {
                    id: avatarArea
                    anchors.fill: parent
                    onClicked: {
                        if (password.focus) {
                            backgroundImage.focus = true
                        } else {
                            password.focus = true
                        }
                    }
                }
            }
            Image {
                id: avatarImage
                width: avatarBorder.width * 0.95
                height: avatarImage.width
                anchors.centerIn: avatarBorder
                source: if (userList.complete) userList.get(userList.currentIndex).icon
                property bool rounded: true
                property bool adapt: true
                layer.enabled: rounded
                layer.effect: ShaderEffect {
                    property real adjustX: avatarImage.adapt ? Math.max(width / height, 1) : 1
                    property real adjustY: avatarImage.adapt ? Math.max(1 / (width / height), 1) : 1

                    fragmentShader: "
                    #ifdef GL_ES
                        precision lowp float;
                    #endif // GL_ES
                    varying highp vec2 qt_TexCoord0;
                    uniform highp float qt_Opacity;
                    uniform lowp sampler2D source;
                    uniform lowp float adjustX;
                    uniform lowp float adjustY;

                    void main(void) {
                        lowp float x, y;
                        x = (qt_TexCoord0.x - 0.5) * adjustX;
                        y = (qt_TexCoord0.y - 0.5) * adjustY;
                        float delta = adjustX != 1.0 ? fwidth(y) / 2.0 : fwidth(x) / 2.0;
                        gl_FragColor = texture2D(source, qt_TexCoord0).rgba
                            * step(x * x + y * y, 0.25)
                            * smoothstep((x * x + y * y) , 0.25 + delta, 0.25)
                            * qt_Opacity;
                    }"
                }
            }
        }
    }

    //Session Buttons
    Column {
        id: buttonContainer
        x: 15
        y: 15

        // Customizing properties
        width: 100
        height: 150
        spacing: buttonContainer.height * 0.04
        property double buttonOpacity: 0.70
        property string buttonColor: "white"
        property string iconColor: "grey"
        property string fontColor: "black"
        property int fontSize: 12
        Rectangle {
            id: suspend
            height: (buttonContainer.height - (3 * buttonContainer.spacing)) / 4
            width: suspend.height
            color: "transparent"
            //visible: sddm.canSuspend
            Rectangle {
                id: suspendBorder
                width: suspend.height
                height: suspend.height
                radius: suspend.height
                color: buttonContainer.buttonColor
                opacity: buttonContainer.buttonOpacity
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: sddm.suspend()
                    onEntered: suspendBorder.focus = true
                    onExited: backgroundImage.focus = true
                }
                KeyNavigation.backtab: container.nextTarget(suspendBorder, -1)
                KeyNavigation.tab: container.nextTarget(suspendBorder, 1)
                Keys.onPressed: {
                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        sddm.suspend()
                        event.accepted = true
                    }
                }
            }
            Image {
                id: suspendIcon
                height: suspend.height * 0.90
                width: suspendIcon.height
                x: (suspend.height - suspendIcon.width) / 2
                y: (suspend.height - suspendIcon.height) / 2
                source: "resources/session_button_template.svg"
                ColorOverlay {
                    anchors.fill: parent
                    source: parent
                    color: buttonContainer.iconColor
                }
            }
            Text {
                id: suspendText
                width: suspendBorder.height + suspendBorder.width
                height: suspend.height
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: buttonContainer.fontSize
                color: buttonContainer.fontColor
                text: "Suspend"
                visible: suspendBorder.focus
                opacity: 0
            }
        }
        Rectangle {
            id: hibernate
            height: (buttonContainer.height - (3 * buttonContainer.spacing)) / 4
            width: hibernate.height
            color: "transparent"
            //visible: sddm.canHibernate
            Rectangle {
                id: hibernateBorder
                width: hibernate.height
                height: hibernate.height
                radius: hibernate.height
                color: buttonContainer.buttonColor
                opacity: buttonContainer.buttonOpacity
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: sddm.hibernate()
                    onEntered: hibernateBorder.focus = true
                    onExited: backgroundImage.focus = true
                }
                KeyNavigation.backtab: container.nextTarget(hibernateBorder, -1)
                KeyNavigation.tab: container.nextTarget(hibernateBorder, 1)
                Keys.onPressed: {
                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        sddm.hibernate()
                        event.accepted = true
                    }
                }
            }
            Image {
                id: hibernateIcon
                height: hibernate.height * 0.90
                width: hibernateIcon.height
                x: (hibernate.height - hibernateIcon.width) / 2
                y: (hibernate.height - hibernateIcon.height) / 2
                source: "resources/session_button_template.svg"
                ColorOverlay {
                    anchors.fill: parent
                    source: parent
                    color: buttonContainer.iconColor
                }
            }
            Text {
                id: hibernateText
                width: hibernateBorder.height + hibernateBorder.width
                height: hibernate.height
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: buttonContainer.fontSize
                color: buttonContainer.fontColor
                text: "Hibernate"
                visible: hibernateBorder.focus
                opacity: 0
            }
        }
        Rectangle {
            id: reboot
            height: (buttonContainer.height - (3 * buttonContainer.spacing)) / 4
            width: reboot.height
            color: "transparent"
            //visible: sddm.canReboot
            Rectangle {
                id: rebootBorder
                width: reboot.height
                height: reboot.height
                radius: reboot.height
                color: buttonContainer.buttonColor
                opacity: buttonContainer.buttonOpacity
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: sddm.reboot()
                    onEntered: rebootBorder.focus = true
                    onExited: backgroundImage.focus = true
                }
                KeyNavigation.backtab: container.nextTarget(rebootBorder, -1)
                KeyNavigation.tab: container.nextTarget(rebootBorder, 1)
                Keys.onPressed: {
                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        sddm.reboot()
                        event.accepted = true
                    }
                }
            }
            Image {
                id: rebootIcon
                height: reboot.height * 0.90
                width: rebootIcon.height
                x: (reboot.height - rebootIcon.width) / 2
                y: (reboot.height - rebootIcon.height) / 2
                source: "resources/session_button_template.svg"
                ColorOverlay {
                    anchors.fill: parent
                    source: parent
                    color: buttonContainer.iconColor
                }
            }
            Text {
                id: rebootText
                width: rebootBorder.height + rebootBorder.width
                height: reboot.height
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: buttonContainer.fontSize
                color: buttonContainer.fontColor
                text: "Reboot"
                visible: rebootBorder.focus
                opacity: 0
            }
        }
        Rectangle {
            id: shutdown
            height: (buttonContainer.height - (3 * buttonContainer.spacing)) / 4
            width: shutdown.height
            color: "transparent"
            //visible: sddm.canPowerOff
            Rectangle {
                id: shutdownBorder
                width: shutdown.height
                height: shutdown.height
                radius: shutdown.height
                color: buttonContainer.buttonColor
                opacity: buttonContainer.buttonOpacity
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: sddm.powerOff()
                    onEntered: shutdownBorder.focus = true
                    onExited: backgroundImage.focus = true
                }
                KeyNavigation.backtab: container.nextTarget(shutdownBorder, -1)
                KeyNavigation.tab: container.nextTarget(shutdownBorder, 1)
                Keys.onPressed: {
                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        sddm.powerOff()
                        event.accepted = true
                    }
                }
            }
            Image {
                id: shutdownIcon
                height: shutdown.height * 0.90
                width: shutdownIcon.height
                x: (shutdown.height - shutdownIcon.width) / 2
                y: (shutdown.height - shutdownIcon.height) / 2
                source: "resources/session_button_template.svg"
                ColorOverlay {
                    anchors.fill: parent
                    source: parent
                    color: buttonContainer.iconColor
                }
            }
            Text {
                id: shutdownText
                width: shutdownBorder.height + shutdownBorder.width
                height: shutdown.height
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: buttonContainer.fontSize
                color: buttonContainer.fontColor
                text: "Shutdown"
                visible: shutdownBorder.focus
                opacity: 0
            }
        }
    }

    //Session Menu
    Column {
        id: sddmElements
        x: 150
        y: 200
        width: parent.width - sddmElements.x
        height: parent.height - sddmElements.y
        ComboBox {
            id: menu_session
            arrowIcon: "resources/session_button_template.svg"
            model: sessionModel
            index: sessionModel.lastIndex
        }
        Clock { id: clock }
        ImageButton { id: imageButton; source:"resources/session_button_template.svg";}
        LayoutBox {id: kbdlayout}
        PictureBox { id: pitureBox; name: userName.text; icon: avatarImage.source; password: password.text }
        TextBox { id: textBox }
        PasswordBox {id: passwordBox }

    }

    Component.onCompleted: {
        if ( userList.get(userList.currentIndex).needsPassword ) {
            password.focus = true
        }
        //mediaPlayer.play()
        //musicPlayer.play()
    }
    // States and Transitions
    states: [
        // Login box state
        State {
            when: (password.focus || prevUser.focus || nextUser.focus)
            PropertyChanges {
                target: loginBorder
                y: loginRectangleTemplate.y
                radius: loginRectangleTemplate.radius
                height: loginRectangleTemplate.height
                width: loginRectangleTemplate.width
                anchors.margins: 0
            }
            PropertyChanges {
                target: loginContainer
                visible: true
            }
            PropertyChanges {
                target: avatarBorder
                y: (root.height - avatarBorder.height) * 0.5 - (avatarBorder.height / 3)
            }
        },
        // Session button states
        State {
            when: suspendBorder.focus
            PropertyChanges { target: suspendBorder; width: buttonContainer.width; radius: 5; }
            PropertyChanges { target: suspendText; opacity: 1; }
        },
        State {
            when: hibernateBorder.focus
            PropertyChanges { target: hibernateBorder; width: buttonContainer.width; radius: 5; }
            PropertyChanges { target: hibernateText; opacity: 1; }
        },
        State {
            when: rebootBorder.focus
            PropertyChanges { target: rebootBorder; width: buttonContainer.width; radius: 5; }
            PropertyChanges { target: rebootText; opacity: 1; }
        },
        State {
            when: shutdownBorder.focus
            PropertyChanges { target: shutdownBorder; width: buttonContainer.width; radius: 5; }
            PropertyChanges { target: shutdownText; opacity: 1; }
        }
    ]
    transitions: [
        Transition {
            ParallelAnimation {
                id: animations
                property variant buttonEasing: Easing.OutExpo
                property variant textEasing: Easing.InExpo
                PropertyAnimation { target: loginBorder; properties: "y, radius, width, height, anchors.margins"; duration: 700; easing.type: Easing.OutElastic }
                PropertyAnimation { target: avatarBorder; properties: "y"; duration: 700; easing.type: Easing.OutElastic }
                PropertyAnimation { target: suspendBorder; properties: "radius, width, height"; duration: 300; easing.type: animations.buttonEasing }
                PropertyAnimation { target: hibernateBorder; properties: "radius, width, height"; duration: 300; easing.type: animations.buttonEasing  }
                PropertyAnimation { target: rebootBorder; properties: "radius, width, height"; duration: 300; easing.type: animations.buttonEasing  }
                PropertyAnimation { target: shutdownBorder; properties: "radius, width, height"; duration: 300; easing.type: animations.buttonEasing  }
                PropertyAnimation { target: suspendText; properties: "opacity"; duration: 200; easing.type: animations.textEasing }
                PropertyAnimation { target: hibernateText; properties: "opacity"; duration: 200; easing.type: animations.textEasing }
                PropertyAnimation { target: rebootText; properties: "opacity"; duration: 200; easing.type: animations.textEasing }
                PropertyAnimation { target: shutdownText; properties: "opacity"; duration: 200; easing.type: animations.textEasing }
            }
        }
    ]

    // For testing purposes
    Item {
        id: toss
        width: 100
        height: 400
        x: 200
        y: 60
        Column {
            Item {
                Text { color: "white"; text: "User: " }
                Text { x: 35; color: "white"; text: if (userList.complete) (userList.get(userList.currentIndex).name == "" ? userList.get(userList.currentIndex).realName : userList.get(userList.currentIndex).name) }
            }
            Text {
                id: tossText
                color: "white"
                property string userDir: if (userList.complete) userList.get(userList.currentIndex).homeDir
                property string userIcon: if (userList.complete) userList.get(userList.currentIndex).icon
                property bool userNeedsPassword: if (userList.complete) userList.get(userList.currentIndex).needsPassword
                text: "\nDir: " + userDir + "\nIcon: " + userIcon + "\nNeeds Password: " + userNeedsPassword
            }
            Text {
                color: (elementFocus != "none") ? "Green" : "Red"
                font.bold: Font.DemiBold
                property string elementFocus: if (suspendBorder.focus) "suspendBorder"; else if (hibernateBorder.focus) "hibernateBorder"; else if (rebootBorder.focus) "rebootBorder"; else if (shutdownBorder.focus) "shutdownBorder"; else if (prevUser.focus) "prevUser"; else if (password.focus) "password"; else if (nextUser.focus) "nextUser"; else if (backgroundImage.focus) "background"; else "none"
                text: "Focus: " + elementFocus
            }
        }
    }

}
