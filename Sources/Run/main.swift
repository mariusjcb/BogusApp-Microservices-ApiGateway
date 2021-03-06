import Gateway
import Vapor

var env = try Environment.detect()
try LoggingSystem.bootstrap(from: &env)
let app = Application(env)
app.http.server.configuration.port = Int(Environment.get("PORT") ?? "8180" ) ?? 8180
defer { app.shutdown() }
try configure(app)
try app.run()
