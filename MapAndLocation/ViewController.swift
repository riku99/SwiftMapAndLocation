import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation?
    var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView = MKMapView()
        // AutoLayoutでサイズを設定
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        mapView.showsUserLocation = true
        mapView.userTrackingMode = MKUserTrackingMode.followWithHeading
        mapView.delegate = self
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(mapTapped(_:)))
        mapView.addGestureRecognizer(tapGesture)
        view.addSubview(mapView)
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        }
        
    }
    
    @objc func mapTapped(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            let tapPoint = sender.location(in: mapView)
            let coordinate = mapView.convert(tapPoint, toCoordinateFrom: mapView)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
            
            let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            CLGeocoder().reverseGeocodeLocation(location, completionHandler: { placemarks, error in
                guard let placemark = placemarks?.first, error == nil else {return}
                print(placemark)
            })
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = locationManager.authorizationStatus
        switch status {
        case .notDetermined:
            break
        case .restricted:
            break
        case .denied:
            let alert = UIAlertController(title: "位置情報を使用できません", message: "アプリを使用するには設定から位置情報をオンにする必要があります", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            present(alert, animated: true)
            break
        case .authorizedAlways:
            break
        case .authorizedWhenInUse:
            let alert = UIAlertController(title: "アプリが適切に動かない可能性があります", message: "現在アプリがバックグラウンドの場合に位置情報を取得することができません。\n解決するには端末の設定から位置情報を「常に」に設定してください。", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            present(alert, animated: true)
            break
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("✋ tapped")
        if let annotation = view.annotation {
            mapView.addAnnotation(annotation)
        }
    }

}
