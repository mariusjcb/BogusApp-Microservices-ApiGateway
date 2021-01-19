import Vapor

func routes(_ app: Application) throws {
    let gatewayController = GatewayController()
    try app.register(collection: gatewayController)
}
