import Vapor
@testable import App
import FluentPostgreSQL
import Authentication
import RoasterHammer_Shared

extension Application {
    static func start(envArgs: [String]? = nil) throws -> Application {
        var config = Config.default()
        var services = Services.default()
        var env = Environment.testing

        if let environmentArgs = envArgs {
            env.arguments = environmentArgs
        }

        let environmentConfiguration = registerEnvironmentConfiguration(for: env, services: &services)

        try App.configure(&config, &env, &services, environmentConfiguration)
        let app = try Application(
            config: config,
            environment: env,
            services: services)
        try App.boot(app)

        return app
    }

    static func reset() throws {
        let revertEnvironment = ["vapor", "revert", "--all", "-y"]
        try Application.start(envArgs: revertEnvironment)
            .asyncRun()
            .wait()

        let migrateEnvironment = ["vapor", "migrate", "-y"]
        try Application.start(envArgs: migrateEnvironment)
            .asyncRun()
            .wait()
    }

    func sendRequest<T>(to path: String,
                        method: HTTPMethod,
                        headers: HTTPHeaders = .init(),
                        body: T? = nil,
                        loggedInRequest: Bool = false,
                        loggedInCustomer: Customer? = nil) throws -> Response where T: Content {
        var headers = headers

        if (loggedInRequest || loggedInCustomer != nil) {
            let email: String
            let password: String

            if let customer = loggedInCustomer {
                email = customer.email
                password = customer.password
            } else {
                email = "admin@test.com"
                password = "password"
            }

            let credentials = BasicAuthorization(username: email, password: password)
            var tokenHeaders = HTTPHeaders()

            tokenHeaders.basicAuthorization = credentials

            let tokenResponse = try self.sendRequest(to: "users/login",
                                                     method: .POST,
                                                     headers: tokenHeaders)
            let token = try tokenResponse.content.syncDecode(AuthTokenResponse.self)
            headers.add(name: .authorization,
                        value: "Bearer \(token.token)")
        }

        let responder = try self.make(Responder.self)
        let request = HTTPRequest(method: method,
                                  url: URL(string: path)!,
                                  headers: headers)
        let wrappedRequest = Request(http: request, using: self)

        if let body = body {
            try wrappedRequest.content.encode(body)
        }

        return try responder.respond(to: wrappedRequest).wait()
    }

    func sendRequest(to path: String,
                     method: HTTPMethod,
                     headers: HTTPHeaders = .init(),
                     loggedInRequest: Bool = false,
                     loggedInCustomer: Customer? = nil) throws -> Response {
        let emptyContent: EmptyContent? = nil

        return try sendRequest(to: path,
                               method: method,
                               headers: headers,
                               body: emptyContent,
                               loggedInRequest: loggedInRequest,
                               loggedInCustomer: loggedInCustomer)
    }

    func sendRequest<T>(to path: String,
                        method: HTTPMethod,
                        headers: HTTPHeaders,
                        data: T,
                        loggedInRequest: Bool = false,
                        loggedInCustomer: Customer? = nil) throws where T: Content {
        _ = try self.sendRequest(to: path,
                                 method: method,
                                 headers: headers,
                                 body: data,
                                 loggedInRequest: loggedInRequest,
                                 loggedInCustomer: loggedInCustomer)
    }

    func getResponse<C, T>(to path: String,
                           method: HTTPMethod = .GET,
                           headers: HTTPHeaders = .init(),
                           data: C? = nil,
                           decodeTo type: T.Type,
                           loggedInRequest: Bool = false,
                           loggedInCustomer: Customer? = nil) throws -> T where C: Content, T: Decodable {
        let response = try self.sendRequest(to: path,
                                            method: method,
                                            headers: headers,
                                            body: data,
                                            loggedInRequest: loggedInRequest,
                                            loggedInCustomer: loggedInCustomer)

        return try response.content.decode(type).wait()
    }

    func getResponse<T>(to path: String,
                        method: HTTPMethod = .GET,
                        headers: HTTPHeaders = .init(),
                        data: T? = nil,
                        decodeTo type: T.Type,
                        loggedInRequest: Bool = false,
                        loggedInCustomer: Customer? = nil) throws -> T where T: Decodable {
        let emptyContent: EmptyContent? = nil

        return try self.getResponse(to: path,
                                    method: method,
                                    headers: headers,
                                    data: emptyContent,
                                    decodeTo: type,
                                    loggedInRequest: loggedInRequest,
                                    loggedInCustomer: loggedInCustomer)
    }

    func createAndLogUser(request: CreateUserRequest = CreateUserRequest(email: "test@test.com",
                                                                         password: "password")) throws -> Customer {
        let user = try self.getResponse(to: "/users/register",
                                        method: .POST,
                                        data: request,
                                        decodeTo: Customer.Public.self)

        return Customer(customerId: user.customerId,
                        email: user.email,
                        password: request.password)
    }
}

struct EmptyContent: Content {}
