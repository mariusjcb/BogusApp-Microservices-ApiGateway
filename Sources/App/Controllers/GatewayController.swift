//
//  File.swift
//  
//
//  Created by Marius Ilie on 19/01/2021.
//

import Vapor

struct GatewayController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        Microservices
            .allCases
            .map { PathComponent(stringLiteral: $0.rawValue) }
            .forEach { routes.get($0, use: handle) }
    }
}

private extension GatewayController {
    func handle(_ req: Request) throws -> EventLoopFuture<ClientResponse> {
        let nilRes = try Microservices.allCases
            .first(where: { req.url.string.contains($0.path) })
            .map { service -> EventLoopFuture<ClientResponse> in
                return try handle(req, targetHost: service.host)
            }
        
        guard let response = nilRes else {
            throw Abort(.failedDependency)
        }
        
        return response
    }
    
    func handle(_ req: Request, targetHost: String?) throws -> EventLoopFuture<ClientResponse> {
        guard let host = targetHost else {
            throw Abort(.failedDependency)
        }
        
        let request = ClientRequest(method: req.method, url: URI(string: host), headers: req.headers, body: req.body.data)
        print("Sending request \(request.method.rawValue.uppercased()) \(request.url.string)")
        
        return req.client.send(request)
    }
}
