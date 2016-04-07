//
//  MADMapViewController.swift
//  MovingAD_iPhone_client
//
//  Created by 张逸 on 16/4/7.
//  Copyright © 2016年 MonzyZhang. All rights reserved.
//

import UIKit

class MADMapViewController: UIViewController, MAMapViewDelegate, AMapLocationManagerDelegate {
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

    func addPolygon() {
        var coordinates = [CLLocationCoordinate2D]()
        coordinates.append(CLLocationCoordinate2DMake(31.2871821398, 121.2183711262))
        coordinates.append(CLLocationCoordinate2DMake(31.2872704151, 121.2193029046))
        coordinates.append(CLLocationCoordinate2DMake(31.2859471398, 121.2178861262))
        coordinates.append(CLLocationCoordinate2DMake(31.2855044151, 121.2189159046))

        mapView?.addOverlay(MAPolygon(coordinates: &coordinates, count: 4))
    }

    //MARK: MAMapViewDelegate Methods
    func mapView(mapView: MAMapView!, viewForOverlay overlay: MAOverlay!) -> MAOverlayView! {
        if overlay.isKindOfClass(MAPolygon) {
            let polygonView = MAPolygonView(polygon: overlay as! MAPolygon)
            polygonView.lineWidth = 5.0
            polygonView.strokeColor = UIColor.redColor()
            polygonView.lineJoin = .Miter

            return polygonView
        }
        return nil
    }

    //MARK: AMapLocationManagerDelegate Methods
    func amapLocationManager(manager: AMapLocationManager!, didUpdateLocation location: CLLocation!) {
        let amapcoord = MACoordinateConvert(location.coordinate, .GPS)
        print("GPS->: \(location.coordinate)")
        print("AMAP->: \(amapcoord)")
    }
    /*
     31.2871821398,121.2183711262
     31.2872704151,121.2193029046
     31.2859471398,121.2178861262
     31.2855044151, 121.2189159046
     
     31.2867034151,121.2187639046
     */
}
