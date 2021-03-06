/*
 * Copyright (c) 2018-2020 Meltytech, LLC
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.0
import QtQuick.Controls 2.12 as Controls2
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import Shotcut.Controls 1.0
import QtQml.Models 2.2

Item {
    width: 500
    height: 400

    property string _defaultStart: '00:00:00.000'
    property string _defaultDuration: '00:00:10.000'
    property string _defaultOffset: '00:00:00.000'

    Component.onCompleted: {
        filter.blockSignals = true
        filter.set(textFilterUi.middleValue, Qt.rect(0, 0, profile.width, profile.height))
        filter.set(textFilterUi.startValue, Qt.rect(0, 0, profile.width, profile.height))
        filter.set(textFilterUi.endValue, Qt.rect(0, 0, profile.width, profile.height))
        if (filter.isNew) {
            filter.set("start", _defaultStart)
            filter.set("duration", _defaultDuration)
            filter.set("offset", _defaultOffset)

            if (application.OS === 'Windows')
                filter.set('family', 'Verdana')
            filter.set('fgcolour', '#ffffffff')
            filter.set('bgcolour', '#00000000')
            filter.set('olcolour', '#ff000000')
            filter.set('weight', 10 * Font.Normal)
            filter.set('style', 'normal')
            filter.set(textFilterUi.useFontSizeProperty, false)
            filter.set('size', profile.height)

            filter.set(textFilterUi.rectProperty,   '0%/75%:25%x25%')
            filter.set(textFilterUi.valignProperty, 'bottom')
            filter.set(textFilterUi.halignProperty, 'left')
            filter.savePreset(preset.parameters, qsTr('Bottom Left'))

            filter.set(textFilterUi.rectProperty,   '75%/75%:25%x25%')
            filter.set(textFilterUi.valignProperty, 'bottom')
            filter.set(textFilterUi.halignProperty, 'right')
            filter.savePreset(preset.parameters, qsTr('Bottom Right'))

            // Add default preset.
            filter.set(textFilterUi.rectProperty, '0%/0%:100%x100%')
            filter.savePreset(preset.parameters)
        } else {
            filter.set(textFilterUi.middleValue, filter.getRect(textFilterUi.rectProperty, filter.animateIn + 1))
            if (filter.animateIn > 0)
                filter.set(textFilterUi.startValue, filter.getRect(textFilterUi.rectProperty, 0))
            if (filter.animateOut > 0)
                filter.set(textFilterUi.endValue, filter.getRect(textFilterUi.rectProperty, filter.duration - 1))
        }
        filter.blockSignals = false
        setControls()
        if (filter.isNew)
            filter.set(textFilterUi.rectProperty, filter.getRect(textFilterUi.rectProperty))
    }

    function setControls() {
        var formatIndex = 0;
        var format = filter.get('format')
        for (var i = 0; i < formatCombo.model.count; i++) {
            if (formatCombo.model.get(i).format === format) {
                formatIndex = i
                break
            }
        }
        formatCombo.currentIndex = formatIndex

        var directionIndex = 0;
        var direction = filter.get('direction')
        for (i = 0; i < directionCombo.model.count; i++) {
            if (directionCombo.model.get(i).direction === direction) {
                directionIndex = i
                break
            }
        }
        directionCombo.currentIndex = directionIndex

        startSpinner.timeStr = filter.get("start")
        durationSpinner.timeStr = filter.get("duration")
        offsetSpinner.timeStr = filter.get("offset")

        textFilterUi.setControls()
    }

    GridLayout {
        id: textGrid
        columns: 2
        anchors.fill: parent
        anchors.margins: 8

        Label {
            text: qsTr('Preset')
            Layout.alignment: Qt.AlignRight
        }
        Preset {
            id: preset
            parameters: textFilterUi.parameters.concat(['format', 'direction','start','duration'])
            onBeforePresetLoaded: {
                filter.resetProperty(textFilterUi.rectProperty)
            }
            onPresetSelected: {
                setControls()
                filter.blockSignals = true
                filter.set(textFilterUi.middleValue, filter.getRect(textFilterUi.rectProperty, filter.animateIn + 1))
                if (filter.animateIn > 0)
                    filter.set(textFilterUi.startValue, filter.getRect(textFilterUi.rectProperty, 0))
                if (filter.animateOut > 0)
                    filter.set(textFilterUi.endValue, filter.getRect(textFilterUi.rectProperty, filter.duration - 1))
                filter.blockSignals = false
            }
        }

        Label {
            text: qsTr('Format')
            Layout.alignment: Qt.AlignRight
        }
        Controls2.ComboBox {
            id: formatCombo
            model: ListModel {
                ListElement { text: QT_TR_NOOP('HH:MM:SS'); format: "HH:MM:SS" }
                ListElement { text: QT_TR_NOOP('HH:MM:SS.S'); format: "HH:MM:SS.S" }
                ListElement { text: QT_TR_NOOP('MM:SS'); format: "MM:SS" }
                ListElement { text: QT_TR_NOOP('MM:SS.SS'); format: "MM:SS.SS" }
                ListElement { text: QT_TR_NOOP('MM:SS.SSS'); format: "MM:SS.SSS" }
                ListElement { text: QT_TR_NOOP('SS'); format: "SS" }
                ListElement { text: QT_TR_NOOP('SS.S'); format: "SS.S" }
                ListElement { text: QT_TR_NOOP('SS.SS'); format: "SS.SS" }
                ListElement { text: QT_TR_NOOP('SS.SSS'); format: "SS.SSS" }
            }
            textRole: 'text'
            valueRole: 'format'
            onActivated: {
                filter.set('format', model.get(currentIndex).format)
            }
        }

        Label {
            text: qsTr('Direction')
            Layout.alignment: Qt.AlignRight
        }
        Controls2.ComboBox {
            id: directionCombo
            model: ListModel {
                ListElement { text: QT_TR_NOOP('Up'); direction: "up" }
                ListElement { text: QT_TR_NOOP('Down'); direction: "down" }
            }
            textRole: 'text'
            valueRole: 'direction'
            onActivated: {
                filter.set('direction', model.get(currentIndex).direction)
            }
        }

        Label {
            text: qsTr('Start Delay')
            Layout.alignment: Qt.AlignRight
        }
        RowLayout {
            spacing: 0
            ClockSpinner {
                id: startSpinner
                maximumValue: 24 * 60 * 60 // 24 hours
                onTimeStrChanged: {
                    filter.set('start', startSpinner.timeStr)
                }
                onSetDefaultClicked: {
                    startSpinner.timeStr = _defaultStart
                }
                ToolTip { text: "The timer will be frozen from the beginning of the filter until the Start Delay time has elapsed." }
            }
            Button {
                iconName: 'insert'
                iconSource: 'qrc:///icons/oxygen/32x32/actions/insert.png'
                tooltip: qsTr('Set start to begin at the current position')
                implicitWidth: 20
                implicitHeight: 20
                onClicked: startSpinner.setValueSeconds(producer.position / profile.fps)
            }
        }

        Label {
            text: qsTr('Duration')
            Layout.alignment: Qt.AlignRight
        }
        RowLayout {
            spacing: 0
            ClockSpinner {
                id: durationSpinner
                maximumValue: 24 * 60 * 60 // 24 hours
                onTimeStrChanged: {
                    filter.set('duration', durationSpinner.timeStr)
                }
                onSetDefaultClicked: {
                    durationSpinner.timeStr = _defaultDuration
                }
                ToolTip { text: "The timer will be frozen after the Duration has elapsed." }
            }
            Button {
                iconName: 'insert'
                iconSource: 'qrc:///icons/oxygen/32x32/actions/insert.png'
                tooltip: qsTr('Set duration to end at the current position')
                implicitWidth: 20
                implicitHeight: 20
                onClicked: {
                    var startTime = startSpinner.getValueSeconds()
                    var endTime = producer.position / profile.fps
                    if (endTime > startTime) {
                        durationSpinner.setValueSeconds(endTime - startTime)
                    }
                }
            }
        }


        Label {
            text: qsTr('Offset')
            Layout.alignment: Qt.AlignRight
        }
        RowLayout {
            spacing: 0
            ClockSpinner {
                id: offsetSpinner
                maximumValue: 24 * 60 * 60 // 24 hours
                onTimeStrChanged: {
                    filter.set('offset', offsetSpinner.timeStr)
                }
                onSetDefaultClicked: {
                    offsetSpinner.timeStr = _defaultOffset
                }
                ToolTip { text: "When the direction is Down, the timer will count down to Offset. When the Direction is up, the timer will count up starting from Offset." }
            }
        }

        TextFilterUi {
            id: textFilterUi
            Layout.columnSpan: 2
        }

        Item { Layout.fillHeight: true }
    }
}
