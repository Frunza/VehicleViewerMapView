import UIKit
import MapKit
import VehicleViewerCore

@available(iOS 13.0, *)
public class VehicleMapViewController: UIViewController {

    private let regionRadius: CLLocationDistance = 1000
    private let locationManager = CLLocationManager()

    private var mapView = MKMapView()
    private var userTrackingButton: MKUserTrackingButton!
    private var scaleView: MKScaleView!
    private var userCoordinate: CLLocationCoordinate2D?
    private var cars = [Car]()

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public init(cars: [Car]) {
        self.cars = cars
        super.init(nibName: nil, bundle: nil)
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        configureLocationManager()
        setupMapView()
        setupUserTrackingButtonAndScaleView()
        addCarAnnotations()
    }

    public func update(cars: [Car]) {
        self.cars = cars
    }
    
    private func addCarAnnotations() {
        let annotationsToRemove = mapView.annotations.filter { $0 !== mapView.userLocation }
        mapView.removeAnnotations(annotationsToRemove)
        cars.forEach { car in
            let annotation = MKPointAnnotation()
            annotation.title = car.name
            annotation.subtitle = car.licensePlate
            annotation.coordinate = CLLocationCoordinate2DMake(car.latitude, car.longitude)
            mapView.addAnnotation(annotation)
        }
    }

}

@available(iOS 13.0, *)
extension VehicleMapViewController: MKMapViewDelegate {

    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let _ = annotation as? CarMarkerAnnotationView else { return nil }
        return CarMarkerAnnotationView(annotation: annotation, reuseIdentifier: CarMarkerAnnotationView.reuseId)
    }

}

// Setup mapView
@available(iOS 13.0, *)
extension VehicleMapViewController {

    private func setupMapView() {
        mapView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
        mapView.mapType = MKMapType.standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        mapView.delegate = self
        mapView.showsCompass = false
        view.addSubview(mapView)
        registerAnnotationViewClasses()
    }
    
    private func registerAnnotationViewClasses() {
        mapView.register(CarMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        mapView.register(ClusterAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
    }

}

// Map buttons
@available(iOS 13.0, *)
extension VehicleMapViewController {

    private func setupUserTrackingButtonAndScaleView() {
        mapView.showsUserLocation = true
        let locationStatus = CLLocationManager.authorizationStatus()

        userTrackingButton = MKUserTrackingButton(mapView: mapView)
        userTrackingButton.layer.backgroundColor = UIColor.translucent.cgColor
        userTrackingButton.layer.borderColor = UIColor.white.cgColor
        userTrackingButton.layer.borderWidth = 1
        userTrackingButton.layer.cornerRadius = 5
        userTrackingButton.isHidden = !(locationStatus == .authorizedAlways || locationStatus == .authorizedWhenInUse)
        view.addSubview(userTrackingButton)

        scaleView = MKScaleView(mapView: mapView)
        scaleView.legendAlignment = .trailing
        view.addSubview(scaleView)

        let stackView = UIStackView(arrangedSubviews: [scaleView, userTrackingButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 10
        view.addSubview(stackView)

        NSLayoutConstraint.activate([stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10), stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10)])
    }

}

// Location manager configuration
@available(iOS 13.0, *)
extension VehicleMapViewController {

    func configureLocationManager() {
        locationManager.delegate = self
        let status = CLLocationManager.authorizationStatus()
        if status == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        } else if status == .authorizedAlways || status == .authorizedWhenInUse {
            beginLocationUpdates(locationManager: locationManager)
        }
    }

    func beginLocationUpdates(locationManager: CLLocationManager) {
        mapView.showsUserLocation = true
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }

}

@available(iOS 13.0, *)
extension VehicleMapViewController: CLLocationManagerDelegate {

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latestLocation = locations.first else { return }
        if userCoordinate == nil {
            zoomTo(coordinate: latestLocation.coordinate)
        }
        userCoordinate = latestLocation.coordinate
    }

    func zoomTo(coordinate: CLLocationCoordinate2D) {
        let zoomRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(zoomRegion, animated: false)
    }

    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            beginLocationUpdates(locationManager: manager)
            userTrackingButton.isHidden = false
        }
    }

}
