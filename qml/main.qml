import QtQuick 2.6
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Window 2.0
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2
import QtQml 2.2


ApplicationWindow {
    id: mainApp
    visible: false
    width: 800
    height: 900
    style: ApplicationWindowStyle {
        background: Rectangle {
            anchors.fill: parent
            color: themes.current.appBackground
        }
    }

    Shortcut {
        sequence: StandardKey.Save
        context: Qt.ApplicationShortcut
        onActivated: saveCurrentNote();
    }

    Shortcut {
        sequence: StandardKey.Save
        context: Qt.ApplicationShortcut
        onActivated: { saveCurrentNote(); Qt.quit(); }
    }

    Shortcut {
        sequence: StandardKey.New
        context: Qt.ApplicationShortcut
        onActivated: notesModel.addNote(notebooksView.currentNotebookId, qsTr("New note"), "");
    }

    Dialog{
        id: passwordDialog
        visible: true;
        title: qsTr("Password")
        standardButtons: StandardButton.Ok
        RowLayout{
            anchors.fill: parent
            Text{ text: qsTr("Password: ") }
            TextField{
                id: password
                focus: true
                Layout.fillWidth: true
                Layout.minimumHeight: 10
                echoMode: TextInput.Password
            }
        }
        onAccepted: {
            if(settings.checkPassword(password.text)){
                mainApp.visible = true;
            }else{
                wrongPasswordDialog.visible = true;
            }
        }
        Component.onCompleted: {
            password.forceActiveFocus()
            if(settings.hasPassword === false){
                passwordDialog.visible = false;
                mainApp.visible = true;
            }
        }
        onVisibleChanged: password.forceActiveFocus()
    }
    MessageDialog {
        id: wrongPasswordDialog
        visible: false
        title: qsTr("Wrong password")
        text: qsTr("Wrong password. Try again")
        onRejected: passwordDialog.visible = true
        onAccepted: {
            passwordDialog.open();
            password.text = ""
        }
    }

    Dialog{
        id: setPasswordDialog
        visible: false
        title: qsTr("Set password")
        standardButtons: StandardButton.Ok
        ColumnLayout{
            anchors.fill: parent
            RowLayout{


                Text { text: qsTr("Password: ") }
                TextField {
                    id: passwordField
                    Layout.fillWidth: true
                    Layout.minimumHeight: 10
                    echoMode: TextInput.Password
                    Keys.onReleased: {
                        if (passwordField.text === confirmPasswordField.text){
                            passwordMatch.text = qsTr("Ok. Passwords are the same")
                            setPasswordDialog.standardButtons = StandardButton.Ok
                        }else{
                            passwordMatch.text = qsTr("Passwords do not match");
                            setPasswordDialog.standardButtons = StandardButton.Cancel;
                        }
                    }
                }
            }
            RowLayout{
                Text { text: qsTr("Confirm password: ")}
                TextField {
                    id: confirmPasswordField
                    Layout.fillWidth: true;
                    Layout.minimumHeight: 10
                    echoMode: TextInput.Password
                    Keys.onReleased: {
                        if (passwordField.text === confirmPasswordField.text){
                            passwordMatch.text = qsTr("Ok. Passwords are the same")
                            setPasswordDialog.standardButtons = StandardButton.Ok
                        }else{
                            passwordMatch.text = qsTr("Passwords do not match")
                            setPasswordDialog.standardButtons = StandardButton.Cancel;
                        }
                    }
                }
            }
            Text {id: passwordMatch }
        }
        onAccepted: settings.setPassword(passwordField.text)
        Component.onCompleted: passwordField.forceActiveFocus()
    }


    Item{
        id: themes
        property Item current: Item{}
        Item{
            id: whiteTheme
            property string themeName: "white"
            property color appBackground: "white"
            property color listTextColor: "black"
            property color listHighlightColor: "#d6dfdf"
            property color listHighlightBorderColor: "grey"
            property color calendarDayHighlight: "lightblue"
            property int listHighlightBorderWidth: 1
            property color textAreaBackgroundColor: "white"
            property color textAreaTextColor: "black"
        }

        Item{
            id: blackTheme
            property string themeName: "black"
            property color appBackground: "#111111"
            property color listTextColor: "white"
            property color listHighlightColor: "#313131"
            property color listHighlightBorderColor: "#626262"
            property color calendarDayHighlight: "lightblue"
            property int listHighlightBorderWidth: 1
            property color textAreaBackgroundColor: "#111111"
            property color textAreaTextColor: "#dddddd"
        }

        Item{
            id: lightRedTheme
            property string themeName: "white"
            property color appBackground: "white"
            property color listTextColor: "black"
            property color listHighlightColor: "#f6dfdf"
            property color listHighlightBorderColor: "grey"
            property color calendarDayHighlight: "lightblue"
            property int listHighlightBorderWidth: 1
            property color textAreaBackgroundColor: "#f6dfdf"
            property color textAreaTextColor: "black"
        }

        Component.onCompleted: {
            //apply theme from settings
            if (settings.theme == "black"){
                themes.current = blackTheme;
            }else if (settings.theme == "white"){
                themes.current = whiteTheme;
            }else{
                themes.current = lightRedTheme;
            }
        }
    }


    Timer {
        interval: 5000; running: true; repeat: true
        onTriggered: { saveCurrentNote(); }
    }

    menuBar: MenuBar{
        Menu{
            title: qsTr("&File")
            MenuItem { text: qsTr("&New note"); onTriggered: notesModel.addNote(notebooksView.currentNotebookId, qsTr("New note"), "") }
            MenuItem { text: qsTr("New no&tebook"); onTriggered: createNotebookDialog.visible = true; }
            MenuItem { text: qsTr("&Delete note"); onTriggered: deleteNoteDialog.visible = true; }
            MenuItem { text: qsTr("De&lete Notebook"); onTriggered: deleteNotebookDialog.visible = true; }
            MenuItem { text: qsTr("&Quit"); onTriggered: Qt.quit(); }
        }
        Menu{
            title: qsTr("View")
            MenuItem { text: qsTr("&Show sidebar"); checkable: true; checked: true; onTriggered: leftSidebar.visible = checked;}
            MenuItem { text: qsTr("&Fullscreen"); checkable: true; checked: false; onTriggered: {
                    checked ? mainApp.visibility = "FullScreen" : mainApp.visibility = "Windowed" } }
            MenuItem { text: qsTr("S&ort by date descending"); checkable: true; checked: notesModel.sortDescending; onTriggered: notesModel.sortDescending = checked }
            Menu {
                title: qsTr("&Themes")
                MenuItem { text: qsTr("&White"); onTriggered: { themes.current = whiteTheme; settings.theme = "white"; } }
                MenuItem { text: qsTr("&Black"); onTriggered: { themes.current = blackTheme; settings.theme = "black"; }}
                MenuItem { text: qsTr("&Light red"); onTriggered: { themes.current = lightRedTheme; settings.theme = "lightRed"; }}
            }
            Menu {
                id: fontMenu
                title: qsTr("Font")
                Instantiator {
                    id: fontMenuInstantiator
                    model: Qt.fontFamilies()
                    MenuItem {
                        text: modelData
                        checkable: true;
                        //ugly, should be resolved somehow by property binding
                        Component.onCompleted: {
                            if (settings.fontFamily == modelData){
                                checked = true;
                            }else{
                                checked = false;
                            }
                        }
                        onTriggered: {
                            noteView.font.family = text;
                            settings.fontFamily = text;
                            for(var i=0; i<fontMenuInstantiator.count; i++){
                                if(settings.fontFamily != fontMenuInstantiator.objectAt(i).text){
                                    fontMenuInstantiator.objectAt(i).checked = false;
                                }
                            }
                        }
                    }
                    onObjectAdded: fontMenu.insertItem(index, object)
                }
            }

        }
        Menu{
            title: qsTr("Settings")
            MenuItem { text: qsTr("Set/change password"); onTriggered: setPasswordDialog.visible = true }
        }
    }
    Dialog{
        id: createNotebookDialog
        visible: false
        title: qsTr("New notebook")
        onAccepted: notebooksModel.addNotebook(0, newNotebookNameField.text)

        RowLayout{
            width: parent.width
            Text{ text: qsTr("Name: ") }
            TextField{
                Layout.fillWidth: true
                id: newNotebookNameField
                width: parent.width
                height: 20
            }
        }
    }

    Dialog {
        id: deleteNotebookDialog
        visible: false
        title: qsTr("Deleting notebook")
        standardButtons: StandardButton.Ok | StandardButton.Cancel
        onAccepted: notebooksModel.deleteNotebook(notebooksView.currentNotebookId)
        Text{
            text: qsTr("Are you sure about deleting this notebook? It has ") + notebooksModel.countNotes(notebooksView.currentNotebookId) + qsTr("notes (notes will not be deleted however)")
        }

    }

    Dialog { //Delete note confirmation
        id: deleteNoteDialog
        visible: false
        title: qsTr("Are you sure?")
        standardButtons: StandardButton.Ok | StandardButton.Cancel
        onAccepted: notesModel.deleteNote(notesView.currentNoteId)
        ListView{
            Layout.fillWidth: true
            height: 100
            model: notesModel
            delegate: Component{ Item{ Text{ text: id } } }
        }

        Text {
            text: qsTr("Are you sure that you want to delete this note? There is no going back");
        }
    }
    RowLayout{
        anchors.fill: parent
        spacing: 5
        ColumnLayout{
            id: leftSidebar
            Layout.minimumWidth: 250
            Layout.preferredWidth: 200
            Layout.maximumWidth: 300
            Layout.minimumHeight: 150
            Layout.fillHeight: true
            Layout.fillWidth: true
            Component{
                id: toolbarButtonStyle
                ButtonStyle{
                    background: Rectangle{ color: "transparent" }
                }
            }
            Component{
                id: toolbarActiveButtonStyle
                ButtonStyle{
                    background: Rectangle{ color: "grey" }
                }
            }

            RowLayout{
                Button { iconSource: "images/accessories-text-editor.png";
                    width: 10; height: 10; onClicked: notebooksView.visible = !notebooksView.visible;
                    style: notebooksView.visible ? toolbarActiveButtonStyle : toolbarButtonStyle}
                Button { iconSource: "images/office-calendar.png";
                    onClicked: {calendar.visible = !calendar.visible}
                    style: calendar.visible ? toolbarActiveButtonStyle : toolbarButtonStyle
                }
                Button { iconSource: "images/system-search.png";
                    onClicked: {searchFieldRow.visible = !searchFieldRow.visible;}
                    style: searchFieldRow.visible ? toolbarActiveButtonStyle : toolbarButtonStyle
                }
//                Button { iconSource: "images/tags.png"; width: 10; height: 10; onClicked: {tagsView.visible = !tagsView.visible} style:ButtonStyle{ background: Rectangle{color: "black";}}}
                Button { iconSource: "images/list-add.png";
                    style: toolbarButtonStyle
                    onClicked: notesModel.addNote(notebooksView.currentNotebookId, qsTr("New note"), ""); }
            }

            Calendar{id: calendar; Layout.fillWidth: true; visible: false; style: CalendarStyle{
                    dayDelegate: Rectangle{
                        id: calendarDay
                        property bool haveNotes : notebooksModel.doesDayHaveNote(notebooksView.currentNotebookId, styleData.date) ? true : false
                        color: haveNotes ? "#bbbb00" : "white"
                        border.color: styleData.selected ? "lightblue" : "grey"
                        border.width: styleData.selected ? 2 : 0
                        Text{
                            font.bold: calendarDay.haveNotes
                            color: styleData.visibleMonth ? "black" : "grey"
                            text: styleData.date.getDate()
                            anchors.centerIn: parent
                        }
                    }


                }
            }
            ListView{
                id: notebooksView;
                property int currentNotebookId: notesModel.currentNotebookId
                Layout.fillWidth: true;
                height: 200;
                model: notebooksModel;

                delegate:
                    Component{
                    Item {
                        id: notebookDelegate
                        width: parent.width
                        height: 24
                        Layout.fillWidth: true;
                        Rectangle{
                            width: parent.width
                            height: parent.height
                            color: "transparent"
                            border.color: themes.current.listHighlightBorderColor
                            border.width: notebookMouseArea.containsMouse ? 1 : 0
                            Text{ text: name; color: themes.current.listTextColor; font.pointSize: 13}
                        }
                        MouseArea{
                            id: notebookMouseArea;
                            anchors.fill: parent;
                            hoverEnabled: true;
                            onClicked: {
                                notebooksView.currentIndex = index
                                notebooksView.currentNotebookId = id
                                notesModel.currentNotebookId = id
                            }

                        }

                    }
                }
                highlight: Rectangle { color: themes.current.listHighlightColor;}
            }
            ListView{
                id: tagsView
                visible: false
                Layout.fillWidth: true;
                height: 100

                model: ListModel{
                    ListElement { tag: "Tag1" }
                    ListElement { tag: "Tag2" }
                    ListElement { tag: "Tag3" }
                    ListElement { tag: "Tag3" }
                    ListElement { tag: "Tag3" }
                    ListElement { tag: "Tag3" }
                }

                delegate: Text{ text: tag; font.pointSize: 9; horizontalAlignment: Text.AlignHCenter}
            }

            Row{
                id: searchFieldRow
                Layout.fillWidth: true
                visible: false
                TextField { id: searchField; width:parent.width-40; Keys.onReturnPressed: notesModel.setSearch(searchField.text); }
                Button { text: qsTr("Search"); width: 40; onClicked: notesModel.setSearch(searchField.text)}
            }



            ListView{
                id: notesView
                property int currentNoteId: 0
                property string currentNoteText: ""
                property string currentNoteTitle: ""
                clip: true
                model: notesModel
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumWidth: 50
                Layout.preferredWidth: 200
                Layout.maximumWidth: 300
                Layout.minimumHeight: 150
                delegate: Component{
                    id: mydelegate
                    Item{
                        id: itemElem
                        width: parent.width
                        height: 60

                        Rectangle{
                            width: parent.width
                            height: parent.height
                            color: mouseArea.containsMouse ? "#050000ff" : "#00000000"
                            border.color: "grey";
                            border.width: mouseArea.containsMouse ? 1 : 0
                            Column{
                                Column{
                                    anchors.leftMargin: 3
                                    anchors.rightMargin: 3
                                    anchors.topMargin: 3
                                    anchors.bottomMargin: 3
                                    Text { text: title.trim(); color: themes.current.listTextColor; font.bold: true; font.pointSize: 11 }
                                    Text { text: created.trim(); color: themes.current.listTextColor; }
                                    Text { id: myText; wrapMode: Text.Wrap; width: itemElem.width; clip: true; height: 30; text: text_data; color: themes.current.listTextColor; }
                                }
                            }
                        }

                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            onClicked: {
                                //ugly, but for some reason I have to call update at the end
                                var pId = notesView.currentNoteId;
                                var pText = noteView.text;
                                var pTitle = noteTitle.text;
                                notesView.currentIndex = index;
                                notesView.currentNoteText = text_data;
                                notesView.currentNoteTitle = title;
                                notesView.currentNoteId = id;
                                if(noteView.needSaving){
                                    notesModel.update(pId, pTitle, pText);
                                }
                            }
                            hoverEnabled: true
                        }
                    }
                }

                highlight: Rectangle { id: listb; color: themes.current.listHighlightColor; border.color: themes.current.listHighlightBorderColor; border.width: 1; }
            }
        }

        ColumnLayout{ //Note
            Layout.fillHeight: true
            Layout.fillWidth: true
            TextField{
                id: noteTitle;
                text: notesView.currentNoteTitle;
                font.pointSize: 15;
                Layout.fillWidth: true;
                onEditingFinished: noteView.needSaving = true
                style: TextFieldStyle{
                    textColor: themes.current.textAreaTextColor
                    background: Rectangle{
                        color: themes.current.textAreaBackgroundColor
                    }
                }
            }
        TextArea{
                id: noteView
                property bool needSaving: false
                font.family: settings.fontFamily
                font.pointSize: 14
                text: notesView.currentNoteText
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredWidth: 500
                style: TextAreaStyle{
                    backgroundColor: themes.current.textAreaBackgroundColor
                    textColor: themes.current.textAreaTextColor
                }
                onEditingFinished: saveCurrentNote();
                Keys.onPressed: { noteView.needSaving = true; }
            }
        }
    }

    function saveCurrentNote(){
        if(noteView.needSaving){
            notesModel.update(notesView.currentNoteId, noteTitle.text, noteView.text);
            noteView.needSaving = false;
        }
    }
    SystemPalette { id: palette; colorGroup: SystemPalette.Active }
}

