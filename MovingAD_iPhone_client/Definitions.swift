//
//  Definitions.swift
//  Bluetooth
//
//  Created by Mick on 12/20/14.
//  Copyright (c) 2014 MacCDevTeam LLC. All rights reserved.
//

import CoreBluetooth

let AMAP_ApiKey = "595cbf3db246492dff2f101c937b0a7c"
let TRANSFER_SERVICE_UUID = "E20A39F4-73F5-4BC4-A12F-17D1AD666661"
let TRANSFER_CHARACTERISTIC_UUID = "08590F7E-DB05-467E-8757-72F6F66666D4"
let MADADINFO_CHARACTERSTIC_UUID = "08590F7E-DB05-467E-8757-72F6F66666E3"
let MADADINFO_SERVICE_UUID = "08590F7E-DB05-467E-8757-72F6F66666E0"
let NOTIFY_MTU = 20

let transferServiceUUID = CBUUID(string: TRANSFER_SERVICE_UUID)
let transferCharacteristicUUID = CBUUID(string: TRANSFER_CHARACTERISTIC_UUID)

struct MADSegues {
    static let loginSuccess = "LoginSuccessSegue"
    static let registerSuccess = "RegisterSuccessSegue"
    static let logout = "LogoutSegue"
}

struct MADBlueToothKeys {
    static let adInfo = "MAD.AdvertisementInfo"
}