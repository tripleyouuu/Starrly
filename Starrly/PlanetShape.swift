enum PlanetShape: Int, Codable, CaseIterable {
    case one
    case two
    case three
    case four
    case five

    var assetName: String {
        switch self {
        case .one: "PlanetShapeOne"
        case .two: "PlanetShapeTwo"
        case .three: "PlanetShapeThree"
        case .four: "PlanetShapeFour"
        case .five: "PlanetShapeFive"
        }
    }
}