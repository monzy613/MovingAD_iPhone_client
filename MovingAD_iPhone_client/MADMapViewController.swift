//
//  MADMapViewController.swift
//  MovingAD_iPhone_client
//
//  Created by 张逸 on 16/4/7.
//  Copyright © 2016年 MonzyZhang. All rights reserved.
//

import UIKit
import Alamofire
import SDWebImage
import BabyBluetooth

// peripheral

private let adLength: NSTimeInterval = 8.0

class MADMapViewController: UIViewController, MAMapViewDelegate, AMapLocationManagerDelegate, AMapSearchDelegate {

    // MARK: map properties
    let APIKEY = AMAP_ApiKey
    var mapView: MAMapView?
    var locationManager: AMapLocationManager?
    var currentLocation: CLLocation!
    var search: AMapSearchAPI?
    var advIDPolygonDictionary = [MAPolygon: Int]()
    var advID_contentDictionary = [Int: String]()
    var advID_JSONDictionary = [Int: JSON]()
    var adArray: [MADAd]?
    var currentValidAd: MADAd?
    var adIDPolygonDictionary = [Int: UnsafeMutablePointer<MAMapPoint>]()
    var currentAdIndex = -1
    var advertisingTimer: NSTimer!
    var isInArea = false
    var cityName: String?
    var cityCode: String?
    var adView: MADAdView?

    var baby: BabyBluetooth!
    var adInfoCharacteristic: CBMutableCharacteristic?

    // MARK: bluetooth properties
    var discoveredPeripheral: CBPeripheral?
    var centralManager: CBCentralManager?
    var peripheralManager: CBPeripheralManager?
    var transferCharacteristic: CBMutableCharacteristic?
    var dataToSend: NSData?
    let dataIncoming = NSMutableData()
    var sendDataIndex: Int?
    var sendingEOM = false

    override func viewDidLoad() {
        super.viewDidLoad()
        //init bluetooth matters
        baby = BabyBluetooth.shareBabyBluetooth()
        setupDelegate()


//        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
//        centralManager = CBCentralManager(delegate: self, queue: nil)
        adArray = [MADAd]()

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
        adIDPolygonDictionary[adv_ID] = polygon.points
        mapView?.addOverlay(polygon)
    }

    func addCircle(location: CLLocation, radius: CLLocationDistance, adv_ID: Int) {
        let circle = MACircle(centerCoordinate: location.coordinate, radius: radius)
        mapView?.addOverlay(circle)
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
            return polygonView
        } else if overlay.isKindOfClass(MACircle) {
            let circle = overlay as! MACircle
            let circleView = MACircleView(circle: circle)
            circleView.lineWidth = 2.0
            circleView.strokeColor = UIColor.darkGrayColor()
            circleView.fillColor = UIColor(hex6: 0xACAAF3)
            circleView.alpha = 0.1
            circleView.lineJoin = .Miter
            return circleView
        }
        return nil
    }

    //MARK: AMapSearchDelegate Methods
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
            let url = MADURL.get_advs(meter: 30000, lng: currentLocation.coordinate.longitude, lat: currentLocation.coordinate.latitude)
            Alamofire.request(.GET, url, parameters: nil).responseJSON(completionHandler: { (res) in
                let json = JSON(res.result.value ?? [])
                if let adJSONArray = json.array {
                    for adJSON in adJSONArray {
                        let ad = MADAd(json: adJSON)
                        if ad.type == .Polygon {
                            self.addPolygon(ad.polygonPoints, adv_ID: ad.adv_ID)
                        } else {
                            for center in ad.centers {
                                self.addCircle(center, radius: CLLocationDistance(ad.range), adv_ID: ad.adv_ID)
                            }
                        }
                        self.adArray?.append(ad)
                    }
                    self.adArray?.sortInPlace{$0.money > $1.money}
                }
            })
        }
    }

    //MARK: AMapLocationManagerDelegate Methods
    func amapLocationManager(manager: AMapLocationManager!, didUpdateLocation location: CLLocation!) {
        currentLocation = location
        if self.cityName == nil {
            getCurrentCity()
        }
    }

    func next() {
        guard let adCount = adArray?.count else {
            return
        }
        if currentAdIndex >= adCount - 1 {
            currentAdIndex = 0
        } else {
            currentAdIndex += 1
        }
    }

    func nextAd(success: ((MADAd) -> ())?, failure: (() -> ())?) {
        guard let ads = adArray else {
            failure?()
            return
        }
        next()
        if currentAdIndex == -1 {
            failure?()
            return
        }
        let ad = ads[currentAdIndex]
        let userMapPoint = MAMapPointForCoordinate(self.mapView!.userLocation.coordinate)
        var contains = false
        switch ad.type{
        case .Polygon:
            let polygonPoints = adIDPolygonDictionary[ad.adv_ID]!
            contains = MAPolygonContainsPoint(userMapPoint, polygonPoints, UInt(ad.polygonPoints.count))
        case .Circles:
            for center in ad.centers {
                if MACircleContainsPoint(MAMapPointForCoordinate(center.coordinate), userMapPoint, Double(ad.range)) {
                    contains = true
                    break
                }
            }
        }
        if contains {
            postAdv(ad, success: success, failure: failure)
        } else {
            failure?()
        }
    }

    func postAdv(ad: MADAd, success: ((MADAd) -> ())?, failure: (() -> ())?) {
        let url = MADURL.post_adv(ad.adv_ID)
        Alamofire.request(.GET, url, parameters: nil).responseJSON{ (res) in
            let json = JSON(res.result.value ?? [])
            if let error = res.result.error {
                print(error)
                return
            }
            if let status = json["status"].string {
                if status == "400" || status == "420" {
                    print("right time")
                    success?(ad)
                    return
                }
                //failed
                print("wrong time")
                failure?()
            }
        }
    }



    // MARK: babybluetooth
    func setupDelegate() {
        baby.peripheralModelBlockOnPeripheralManagerDidUpdateState { (peripheralManager) in
            if peripheralManager.state == .PoweredOn {
                self.adInfoCharacteristic = CBMutableCharacteristic(type: CBUUID(string: MADADINFO_CHARACTERSTIC_UUID), properties: .Read, value: nil, permissions: .Readable)
                let madAdInfoService = CBMutableService(type: CBUUID(string: MADADINFO_SERVICE_UUID), primary: true)
                madAdInfoService.characteristics = [self.adInfoCharacteristic!]
                peripheralManager.addService(madAdInfoService)
            }
        }

        baby.peripheralModelBlockOnDidAddService { (peripheralManager, service, error) in
            peripheralManager.startAdvertising([
                "INFO": "StartAdvertising"
                ])
        }

        baby.peripheralModelBlockOnDidReceiveReadRequest { (peripheralManager, request) in
            print("read request")
            if request.characteristic == self.adInfoCharacteristic {
                self.nextAd({ (ad) in
                    request.value = ad.btJSON.dataUsingEncoding(NSUTF8StringEncoding)
                    peripheralManager.respondToRequest(request, withResult: .Success)
                    }, failure: { 
                        peripheralManager.respondToRequest(request, withResult: .AttributeNotFound)
                })
            } else {
                peripheralManager.respondToRequest(request, withResult: .AttributeNotFound)
            }
        }
    }
}
