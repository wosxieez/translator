//
//  LocationViewController.swift
//  Translator
//
//  Created by coco on 23/10/2017.
//  Copyright © 2017 coco. All rights reserved.
//

import UIKit
import CoreLocation

class LocationViewController: UIViewController, CLLocationManagerDelegate
{
    
    var label:UITextView!;
    var locationManager:CLLocationManager!;
    
    override func viewDidLoad()
    {
        super.viewDidLoad();
        
        view.backgroundColor = UIColor.white;
        
        label = UITextView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height));
        label.isEditable = false;
        label.text = "";
        view.addSubview(label);
        
        locationManager = CLLocationManager();
        locationManager.delegate = self;  // 设置定位代理
        locationManager.desiredAccuracy = kCLLocationAccuracyBest; // 设置定位精度 最佳
        locationManager.distanceFilter = 100; // 更新距离 100m
        
        print("请求权限");
        locationManager.requestWhenInUseAuthorization();
        
        print("开始定位");
        locationManager.startUpdatingLocation();
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let currentLocation:CLLocation? = locations.last;
        if (currentLocation != nil)
        {
            print(currentLocation!);
            label.text = currentLocation!.altitude.description + "\r" +
                currentLocation!.coordinate.latitude.description + "\r" +
                currentLocation!.coordinate.longitude.description + "\r" +
                currentLocation!.speed.description;
        }
    }
    @IBAction func startLocation(_ sender: Any)
    {
        locationManager.startUpdatingLocation();
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("定位错误", error.localizedDescription);
    }
    
}
