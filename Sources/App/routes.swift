import Vapor

enum Microservices: String, CaseIterable {
    case benefits
    case channels
    case targets
}

extension Microservices {
    var path: String {
        return rawValue
    }
    
    var host: String? {
        return Environment.get(self.rawValue.uppercased() + "_HOST")
    }
}

func routes(_ app: Application) throws {
    try app.register(collection: GatewayController())
}
