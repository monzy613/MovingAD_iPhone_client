//
//  MADMapViewController.swift
//  MovingAD_iPhone_client
//
//  Created by 张逸 on 16/4/7.
//  Copyright © 2016年 MonzyZhang. All rights reserved.
//

import UIKit

class MADMapViewController: UIViewController, MAMapViewDelegate, AMapLocationManagerDelegate {
    let APIKEY = "APIKEY"
    var mapView: MAMapView?
    var locationManager: AMapLocationManager?
    var advLocationDictionary = [Int: [CLLocation]]()
    var isInArea = false

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
            initMapView()
        } else {
            print("gps invalid")
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

    func addPolygon(locations: [CLLocation]) {
        var coordinates = [CLLocationCoordinate2D]()
        for location in locations {
            coordinates.append(location.coordinate)
        }
        mapView?.addOverlay(MAPolygon(coordinates: &coordinates, count: UInt(coordinates.count)))
    }

    //MARK: MAMapViewDelegate Methods
    func mapView(mapView: MAMapView!, viewForOverlay overlay: MAOverlay!) -> MAOverlayView! {
        if overlay.isKindOfClass(MAPolygon) {
            let polygon = overlay as! MAPolygon
            let polygonView = MAPolygonView(polygon: polygon)
            polygonView.lineWidth = 3.0
            polygonView.strokeColor = UIColor.redColor()
            polygonView.lineJoin = .Miter

            let userMapPoint = MAMapPointForCoordinate(self.mapView!.userLocation.coordinate)
            let polygonPoints = polygon.points
            let contains = MAPolygonContainsPoint(userMapPoint, polygonPoints, polygon.pointCount)
            print("contains: \(contains)")
            let showAlert = (contains == true && self.isInArea == false)


            if showAlert {
                let alert = UIAlertController(title: "stepped in area", message: "stepped in area", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "ok", style: .Default) {
                    action in
                })
                self.presentViewController(alert, animated: true, completion: nil)
            }

            self.isInArea = contains
            return polygonView
        }
        return nil
    }

    func mapView(mapView: MAMapView!, mapDidZoomByUser wasUserAction: Bool) {
    }

    //MARK: AMapLocationManagerDelegate Methods
    func amapLocationManager(manager: AMapLocationManager!, didUpdateLocation location: CLLocation!) {
        //let amapcoord = MACoordinateConvert(location.coordinate, .GPS)
        //print("GPS->: \(location.coordinate)")
        //print("AMAP->: \(amapcoord)")
        MADNetwork.getPoints(url: MADURL.get_all_advs, onSuccess: {
            advLocationDictionary in
            self.advLocationDictionary = advLocationDictionary
            for (adv_ID, locationArray) in advLocationDictionary {
                if adv_ID > 4 {
                    self.addPolygon(locationArray)
                }
            }
            }, onFailure: nil)
    }
}
