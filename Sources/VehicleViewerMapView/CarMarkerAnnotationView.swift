import MapKit
import VehicleViewerCore

@available(iOS 13.0, *)
class CarMarkerAnnotationView: MKMarkerAnnotationView {

    static let reuseId = "carMarkerAnnotation"
    let clusteringId = "cars"

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        clusteringIdentifier = clusteringId
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForDisplay() {
        super.prepareForDisplay()
        markerTintColor = UIColor.lightBlue
        glyphImage = SFSymbols.car
    }
    
}
