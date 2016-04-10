//
//  MADMapViewController.swift
//  MovingAD_iPhone_client
//
//  Created by 张逸 on 16/4/7.
//  Copyright © 2016年 MonzyZhang. All rights reserved.
//

import UIKit

class MADMapViewController: UIViewController, MAMapViewDelegate, AMapLocationManagerDelegate, AMapSearchDelegate {
    let APIKEY = AMAP_ApiKey
    var mapView: MAMapView?
    var locationManager: AMapLocationManager?
    var search: AMapSearchAPI?
    var advIDPolygonDictionary = [MAPolygon: Int]()
    var advID_contentDictionary = [Int: String]()
    var isInArea = false
    var cityName: String?
    var cityCode: String?

    override func viewDidLoad() {
        super.viewDidLoad()
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
                    return
                }
            } else {
                return
            }
            let url = "\(MADURL.get_all_advs)/\(self.cityCode ?? "")"
            MADNetwork.getPoints(url: MADURL.get_all_advs, onSuccess: {
                advLocationDictionary in
                for (adv_ID, locationArray) in advLocationDictionary {
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
}
