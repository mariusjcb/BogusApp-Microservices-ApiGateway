//
//  File.swift
//  
//
//  Created by Marius Ilie on 19/01/2021.
//

import Vapor

enum Microservices: String {
    case targets
}

typealias MicroserviceConfiguration = (path: String, host: String)

var AllowedMicroservices: [Microservices: MicroserviceConfiguration] = [
    .targets: (path: "targets", host: "USERS_HOST")
]

struct GatewayController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get("targets", use: handle)
    }
}

private extension GatewayController {
    func handle(_ req: Request) throws -> EventLoopFuture<ClientResponse> {
        let nilRes = try AllowedMicroservices
            .first(where: { req.url.string.contains($0.value.path) })
            .map { _ -> EventLoopFuture<ClientResponse> in
                guard let usersHost = Environment.get("USERS_HOST") else { throw Abort(.badRequest) }
                return try handle(req, host: usersHost)
            }
        guard let response = nilRes else {
            throw Abort(.badRequest)
        }
        return response
    }
    
    func handle(_ req: Request, host: String) throws -> EventLoopFuture<ClientResponse> {
        guard let url = URL(string: host + req.url.string) else {
            throw Abort(.internalServerError)
        }
        req.url = URI(string: url.absoluteString)
        req.headers.replaceOrAdd(name: "host", value: host)
        let request = ClientRequest(method: req.method, url: req.url, headers: req.headers, body: req.body.data)
        return req.client.send(request)
    }
}
