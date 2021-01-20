//
//  File.swift
//  
//
//  Created by Marius Ilie on 19/01/2021.
//

import Vapor

struct GatewayController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get(.catchall, use: handle)
        routes.post(.catchall, use: handle)
        routes.put(.catchall, use: handle)
        routes.delete(.catchall, use: handle)
    }
}

private extension GatewayController {
    func handle(_ req: Request) throws -> EventLoopFuture<ClientResponse> {
        let nilRes = try Microservices.allCases
            .first(where: { req.url.string.contains($0.path) })
            .map { service -> EventLoopFuture<ClientResponse> in
                return try handle(req, targetHost: service.host, microserviceName: service.rawValue)
            }
        
        guard let response = nilRes else {
            throw Abort(.badGateway)
        }
        
        return response
    }
    
    func handle(_ req: Request, targetHost: String?, microserviceName: String) throws -> EventLoopFuture<ClientResponse> {
        guard let host = targetHost else {
            throw Abort(.failedDependency)
        }
        var url = URI(string: host)
        url.path = String(req.url.path.dropFirst(microserviceName.count + 1))
        url.query = req.url.query
        let request = ClientRequest(method: req.method, url: url, headers: req.headers, body: req.body.data)
        print("Sending request \(request.method.rawValue.uppercased()) \(request.url.string)")
        
        return req.client.send(request)
    }
}
