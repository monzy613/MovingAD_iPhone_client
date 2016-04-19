//
//  MADMapViewController.swift
//  MovingAD_iPhone_client
//
//  Created by 张逸 on 16/4/7.
//  Copyright © 2016年 MonzyZhang. All rights reserved.
//

import UIKit
import CoreBluetooth

class MADMapViewController: UIViewController, MAMapViewDelegate, AMapLocationManagerDelegate, AMapSearchDelegate, CBPeripheralManagerDelegate, CBCentralManagerDelegate, CBPeripheralDelegate  {

    // MARK: map properties
    let APIKEY = AMAP_ApiKey
    var mapView: MAMapView?
    var locationManager: AMapLocationManager?
    var search: AMapSearchAPI?
    var advIDPolygonDictionary = [MAPolygon: Int]()
    var advID_contentDictionary = [Int: String]()
    var advID_JSONDictionary = [Int: JSON]()
    var isInArea = false
    var cityName: String?
    var cityCode: String?

    // MARK: bluetooth properties
    var discoveredPeripheral: CBPeripheral?
    var centralManager: CBCentralManager?
    var peripheralManager: CBPeripheralManager?
    var transferCharacteristic: CBMutableCharacteristic?
    var adJson: JSON?
    var dataToSend: NSData?
    let dataIncoming = NSMutableData()
    var sendDataIndex: Int?
    var sendingEOM = false

    override func viewDidLoad() {
        super.viewDidLoad()
        //init bluetooth matters
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        centralManager = CBCentralManager(delegate: self, queue: nil)

        // init map matters
        if CLLocationManager.locationServicesEnabled() &&
            (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedAlways ||
                CLLocationManager.authorizationStatus() == CLAuthorizationStatus.NotDetermined)
        {
            locationManager = AMapLocationManager()
            locationManager?.delegate = self
            locationManager?.startUpdatingLocation()
            MAMapServices.sharedServices().apiKey = APIKEY
            AMapSearchServices.sharedServices().apiKey = APIKEY
            search = AMapSearchAPI()
            search?.delegate = self
            initMapView()
        } else {
            print("gps invalid")
        }
    }

    func getCurrentCity() {
        let regeoRequest = AMapReGeocodeSearchRequest()
        if let mapView = self.mapView {
            regeoRequest.location = AMapGeoPoint.locationWithLatitude(CGFloat(mapView.userLocation.coordinate.latitude), longitude: CGFloat(mapView.userLocation.coordinate.longitude))
            print("currentLocation: \(regeoRequest.location)")
            regeoRequest.radius = 10000
            regeoRequest.requireExtension = true
            self.search?.AMapReGoecodeSearch(regeoRequest)
        }
    }

    func initMapView() {
        mapView = MAMapView(frame: self.view.bounds)
        mapView?.delegate = self
        mapView?.showsUserLocation = true
        mapView?.userTrackingMode = .FollowWithHeading
        mapView?.setZoomLevel(15.0, animated: true)
        self.view.addSubview(mapView!)
    }

    func addPolygon(locations: [CLLocation], adv_ID: Int) {
        var coordinates = [CLLocationCoordinate2D]()
        for location in locations {
            coordinates.append(location.coordinate)
        }
        let polygon = MAPolygon(coordinates: &coordinates, count: UInt(coordinates.count))
        self.advIDPolygonDictionary[polygon] = adv_ID
        mapView?.addOverlay(polygon)
    }

    //MARK: MAMapViewDelegate Methods
    func mapView(mapView: MAMapView!, viewForOverlay overlay: MAOverlay!) -> MAOverlayView! {
        if overlay.isKindOfClass(MAPolygon) {
            let polygon = overlay as! MAPolygon
            let polygonView = MAPolygonView(polygon: polygon)
            polygonView.lineWidth = 3.0
            polygonView.strokeColor = UIColor.darkGrayColor()
            polygonView.fillColor = UIColor(hex6: 0xACAAF3)
            polygonView.alpha = 0.1
            polygonView.lineJoin = .Miter

            let userMapPoint = MAMapPointForCoordinate(self.mapView!.userLocation.coordinate)
            let polygonPoints = polygon.points
            let contains = MAPolygonContainsPoint(userMapPoint, polygonPoints, polygon.pointCount)
            let showAlert = (contains == true && self.isInArea == false)

            if showAlert {
                let adv_ID = self.advIDPolygonDictionary[polygon] ?? -1
                print("polygon's adv_ID: \(adv_ID)")
                adJson = advID_JSONDictionary[adv_ID]
                sendAdJson()
                self.isInArea = true
                let alert = UIAlertController(title: "adv_ID: \(adv_ID)", message: "city:\(self.cityName ?? "nil") \nadvContent:", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "ok", style: .Default) {
                    action in
                })
                self.presentViewController(alert, animated: true, completion: nil)
            }
            return polygonView
        }
        return nil
    }

    //MARK: AMapSearchDelegate Mathods
    func onReGeocodeSearchDone(request: AMapReGeocodeSearchRequest!, response: AMapReGeocodeSearchResponse!) {
        if let regeocode = response.regeocode {
            if (regeocode.addressComponent.city == nil || regeocode.addressComponent.city == "") {
                self.cityName = regeocode.addressComponent.province
                print("直辖市: \(self.cityName) code: \(cityCode)")
            } else {
                self.cityName = regeocode.addressComponent.city
                print("非直辖市: \(self.cityName) code: \(cityCode)")
            }
            if let cityCode = regeocode.addressComponent.citycode {
                if cityCode != "" {
                    self.cityCode = cityCode
                } else {
                    print("cityCode empty")
                    return
                }
            } else {
                print("no cityCode")
                return
            }
            _ = "\(MADURL.get_all_advs)/\(self.cityCode ?? "")"
            MADNetwork.getPoints(url: MADURL.get_all_advs, onSuccess: {
                advLocationDictionary, json in
                for (adv_ID, locationArray) in advLocationDictionary {
                    self.advID_JSONDictionary[adv_ID] = json
                    self.addPolygon(locationArray, adv_ID: adv_ID)
                }
                }, onFailure: nil)
        }
    }

    //MARK: AMapLocationManagerDelegate Methods
    func amapLocationManager(manager: AMapLocationManager!, didUpdateLocation location: CLLocation!) {
        //let amapcoord = MACoordinateConvert(location.coordinate, .GPS)
        //print("GPS->: \(location.coordinate)")
        //print("AMAP->: \(amapcoord)")
        if self.cityName == nil {
            getCurrentCity()
        }
    }




    // MARK: Bluetooth matters

    // peripheralmanagerDelegate delegate methods
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager) {
        switch peripheral.state {
        case .PoweredOn:
            print("peripheralManager PowerdOn")
            //add service
            let transferService = CBMutableService(type: transferServiceUUID, primary: true)
            transferCharacteristic = CBMutableCharacteristic(type: transferCharacteristicUUID, properties: .Notify, value: nil, permissions: .Readable)
            transferService.characteristics = [transferCharacteristic!]
            peripheralManager?.addService(transferService)
        default:
            print("peripheralManager changeState default")
        }
    }

    func peripheralManager(peripheral: CBPeripheralManager, central: CBCentral, didSubscribeToCharacteristic characteristic: CBCharacteristic) {
        print("Central subscribed to characteristic, Central: \(central)")
        // Get the data
        dataToSend = adJson?.rawString()?.dataUsingEncoding(NSUTF8StringEncoding)
        // Reset the index
        sendDataIndex = 0;
        // Start sending
        sendData()
    }

    func peripheralManager(peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFromCharacteristic characteristic: CBCharacteristic) {
        print("Central unsubscribed to characteristic")
    }

    func peripheralManagerDidStartAdvertising(peripheral: CBPeripheralManager, error: NSError?) {
        print(error)
    }

    func peripheralManagerIsReadyToUpdateSubscribers(peripheral: CBPeripheralManager) {
        // Start sending again
        sendData()
    }



    // centralManagerDelegate delegate methods
    func centralManagerDidUpdateState(central: CBCentralManager) {
        print("\(#line) \(#function)")

        if central.state != .PoweredOn {
            print("central powerOff")
            return
        }

        scan()
    }


    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        print("Discovered \(peripheral.name) at \(RSSI)")

        // Ok, it's in range - have we already seen it?

        if discoveredPeripheral != peripheral {
            // Save a local copy of the peripheral, so CoreBluetooth doesn't get rid of it
            discoveredPeripheral = peripheral

            // And connect
            print("Connecting to peripheral \(peripheral)")

            centralManager?.connectPeripheral(peripheral, options: nil)
        }
    }

    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        print("Failed to connect to \(peripheral). (\(error!.localizedDescription))")

        cleanUp()
    }

    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        print("Peripheral Connected")

        // Stop scanning
        centralManager?.stopScan()
        print("Scanning stopped")

        // Clear the data that we may already have
        dataIncoming.length = 0

        // Make sure we get the discovery callbacks
        peripheral.delegate = self

        // Search only for services that match our UUID
        peripheral.discoverServices([transferServiceUUID])
    }


    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        if let error = error {
            print("Error discovering services: \(error.localizedDescription)")
            cleanUp()
            return
        }

        // Discover the characteristic we want...

        // Loop through the newly filled peripheral.services array, just in case there's more than one.
        for service in peripheral.services as [CBService]! {
            peripheral.discoverCharacteristics([transferCharacteristicUUID], forService: service)
        }
    }

    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        // Deal with errors (if any)
        if let error = error {
            print("Error discovering services: \(error.localizedDescription)")
            cleanUp()
            return
        }

        // Again, we loop through the array, just in case.
        for characteristic in service.characteristics as [CBCharacteristic]! {
            // And check if it's the right one
            if characteristic.UUID.isEqual(transferCharacteristicUUID) {
                // If it is, subscribe to it
                peripheral.setNotifyValue(true, forCharacteristic: characteristic)
            }
        }
        // Once this is complete, we just need to wait for the data to come in.
    }


    /** This callback lets us know more data has arrived via notification on the characteristic
     */
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if let error = error {
            print("Error discovering services: \(error.localizedDescription)")
            return
        }

        // Have we got everything we need?
        if let stringFromData = NSString(data: characteristic.value!, encoding: NSUTF8StringEncoding) {
            if stringFromData.isEqualToString("EOM") {
                // Cancel our subscription to the characteristic
                peripheral.setNotifyValue(false, forCharacteristic: characteristic)

                // and disconnect from the peripehral
                centralManager?.cancelPeripheralConnection(peripheral)
            } else {
                //messageBox.text = "\(messageBox.text)\(stringFromData)\n"
            }

            // Otherwise, just add the data on to what we already have
            dataIncoming.appendData(characteristic.value!)

            // Log it
            print("Received: \(stringFromData)")
        } else {
            print("Invalid data")
        }
    }


    /** The peripheral letting us know whether our subscribe/unsubscribe happened or not
     */
    func peripheral(peripheral: CBPeripheral, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        print("Error changing notification state: \(error?.localizedDescription)")

        // Exit if it's not the transfer characteristic
        if !characteristic.UUID.isEqual(transferCharacteristicUUID) {
            return
        }

        // Notification has started
        if (characteristic.isNotifying) {
            print("Notification began on \(characteristic)")
        } else { // Notification has stopped
            print("Notification stopped on (\(characteristic))  Disconnecting")
            centralManager?.cancelPeripheralConnection(peripheral)
        }
    }

    /** Once the disconnection happens, we need to clean up our local copy of the peripheral
     */
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        print("Peripheral Disconnected")
        discoveredPeripheral = nil

        // We're disconnected, so start scanning again
        scan()
    }





    func cleanUp() {
        // Don't do anything if we're not connected
        // self.discoveredPeripheral.isConnected is deprecated
        if discoveredPeripheral?.state != CBPeripheralState.Connected { // explicit enum required to compile here?
            return
        }

        // See if we are subscribed to a characteristic on the peripheral
        if let services = discoveredPeripheral?.services as [CBService]? {
            for service in services {
                if let characteristics = service.characteristics as [CBCharacteristic]? {
                    for characteristic in characteristics {
                        if characteristic.UUID.isEqual(transferCharacteristicUUID) && characteristic.isNotifying {
                            discoveredPeripheral?.setNotifyValue(false, forCharacteristic: characteristic)
                            // And we're done.
                            return
                        }
                    }
                }
            }
        }

        // If we've got this far, we're connected, but we're not subscribed, so we just disconnect
        centralManager?.cancelPeripheralConnection(discoveredPeripheral!)
    }


    func scan() {
        centralManager?.scanForPeripheralsWithServices(
            [transferServiceUUID],
            options: [CBCentralManagerScanOptionAllowDuplicatesKey: NSNumber(bool: true)])
        print("Scanning started")
    }

    func sendAdJson() {
        peripheralManager?.startAdvertising([
            CBAdvertisementDataServiceUUIDsKey: [transferServiceUUID]
            ])
    }


    private func sendData() {

        if sendingEOM {
            // send it
            let didSend = peripheralManager?.updateValue(
                "EOM".dataUsingEncoding(NSUTF8StringEncoding)!,
                forCharacteristic: transferCharacteristic!,
                onSubscribedCentrals: nil
            )

            // Did it send?
            if (didSend == true) {

                // It did, so mark it as sent
                sendingEOM = false

                print("Sent: EOM")
            }

            // It didn't send, so we'll exit and wait for peripheralManagerIsReadyToUpdateSubscribers to call sendData again
            return
        }

        if sendDataIndex >= dataToSend?.length {
            return
        }

        var didSend = true

        while didSend {
            // Make the next chunk

            // Work out how big it should be
            var amountToSend = dataToSend!.length - sendDataIndex!;

            // Can't be longer than 20 bytes
            if (amountToSend > NOTIFY_MTU) {
                amountToSend = NOTIFY_MTU;
            }

            // Copy out the data we want
            let chunk = NSData(
                bytes: dataToSend!.bytes + sendDataIndex!,
                length: amountToSend
            )

            // Send it
            didSend = peripheralManager!.updateValue(
                chunk,
                forCharacteristic: transferCharacteristic!,
                onSubscribedCentrals: nil
            )

            // If it didn't work, drop out and wait for the callback
            if (!didSend) {
                return
            }

            let stringFromData = NSString(
                data: chunk,
                encoding: NSUTF8StringEncoding
            )

            print("Sent: \(stringFromData)")

            // It did send, so update our index
            sendDataIndex! += amountToSend;

            // Was it the last one?
            if (sendDataIndex! >= dataToSend!.length) {

                // It was - send an EOM

                // Set this so if the send fails, we'll send it next time
                sendingEOM = true

                // Send it
                let eomSent = peripheralManager!.updateValue(
                    "EOM".dataUsingEncoding(NSUTF8StringEncoding)!,
                    forCharacteristic: transferCharacteristic!,
                    onSubscribedCentrals: nil
                )

                if (eomSent) {
                    // It sent, we're all done
                    sendingEOM = false
                    print("Sent: EOM")
                }

                peripheralManager?.stopAdvertising()
                return
            }
        }
    }
}
