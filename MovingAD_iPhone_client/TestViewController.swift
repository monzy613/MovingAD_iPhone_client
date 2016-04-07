
//
//  TestViewController.swift
//  MovingAD_iPhone_client
//
//  Created by 张逸 on 16/3/24.
//  Copyright © 2016年 MonzyZhang. All rights reserved.
//

import UIKit
import MBProgressHUD

class TestViewController: UIViewController, MAMapViewDelegate, AMapLocationManagerDelegate {
    let APIKEY = "595cbf3db246492dff2f101c937b0a7c"
    var mapView: MAMapView?
    var locationManager: AMapLocationManager?

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
        print("currentPosition: \(mapView?.userLocation.coordinate)")
        self.view.addSubview(mapView!)
    }

    //MARK: AMapLocationManagerDelegate Methods
    func amapLocationManager(manager: AMapLocationManager!, didUpdateLocation location: CLLocation!) {
        let amapcoord = MACoordinateConvert(location.coordinate, .GPS)
        print("GPS->: \(location.coordinate)")
        print("AMAP->: \(amapcoord)")
    }
}