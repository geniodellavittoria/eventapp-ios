//
//  RestController.swift
//  EventApp
//
//  Created by Pascal on 24.11.18.
//  Copyright © 2018 2noobs. All rights reserved.
//

import Alamofire
import Foundation

class RestController {
    
    let sessionManager = Alamofire.SessionManager.default
    
    var endpointUrl : String;
    var resource : String;
    
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    
    var defaultHeader: HTTPHeaders = [
        "Content-Type": "application/json",
        "charset": "UTF-8"
    ]
    
    init(resource: String) {
        endpointUrl = Config.backendUrl
        self.resource = resource
        sessionManager.adapter = accessTokenAdapter
        
        decoder.dateDecodingStrategy = .iso8601
    }
    
    /*func getAll<T>(resource: String) {
        
    }*/
    
    func getAll<Res: Decodable>(resource: String, response: Res.Type, onSuccess: @escaping ([Res]) -> Void, onError: @escaping (Error) -> Void) {
        guard let url = URL(string: endpointUrl + resource) else {
            onError(RESTError.InvalidUrlError("Invalid Url: " + endpointUrl + resource))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        
        Alamofire.request(request)
            .responseCollection(completionHandler: { (response: DataResponse<[Res]>) in
                print(response.result)
                switch response.result {
                case .failure(let error):
                    onError(error)
                    
                case .success(let resArr):
                    onSuccess(resArr as [Res])
                }
            })
    }
    
    func getAll<Res: Decodable>(response: Res.Type, onSuccess: @escaping ([Res]) -> Void, onError: @escaping (Error) -> Void) {
        getAll(resource: self.resource, response: response, onSuccess: onSuccess, onError: onError)
    }
    
    func get<Res: Decodable>(resource: String, response: Res.Type, onSuccess: @escaping (Res) -> Void, onError: @escaping (Error) -> Void) {
        guard let url = URL(string: endpointUrl + resource) else {
            onError(RESTError.InvalidUrlError("Invalid Url: " + endpointUrl + resource))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        
        Alamofire.request(request)
            .responseObject(completionHandler: { (response: DataResponse<Res>) in
                onSuccess(response.value! as Res)
            })

    }
    
    func get<Res: Decodable>(response: Res.Type, onSuccess: @escaping (Res) -> Void, onError: @escaping (Error) -> Void) {
        get(resource: self.resource, response: response, onSuccess: onSuccess, onError: onError)
    }
    
    /*func get<T>(id: String) {
        return get<T>(resource: self.resource + "/" + id)
    }*/
    
    /*func post(body: T) {
        post(resource: resource, body: body)
    }*/
    
    func post<Req: Encodable, Res: Decodable>(resource: String, _ body: Req, response: Res.Type, onSuccess: @escaping (Res) -> Void, onError: @escaping (Error) -> Void) {
        guard let url = URL(string: endpointUrl + resource) else {
            onError(RESTError.InvalidUrlError("Invalid Url: " + endpointUrl + resource))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! encoder.encode(body)

        Alamofire.request(request)
            .responseObject(completionHandler: { (response: DataResponse<Res>) in
                onSuccess(response.value! as Res)
        })
        
    }
    
    func post<Req: Encodable>(resource: String, _ body: Req, onSuccess: @escaping () -> Void, onError: @escaping (Error) -> Void) {
        guard let url = URL(string: endpointUrl + resource) else {
            onError(RESTError.InvalidUrlError("Invalid Url: " + endpointUrl + resource))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! encoder.encode(body)
        
        Alamofire.request(request)
        .response(completionHandler: { response in
            print(response)
            onSuccess()
        })
        
    }
    
    func put<Req: Encodable>(resource: String, _ body: Req, onSuccess: @escaping () -> Void, onError: @escaping (Error) -> Void) {
        guard let url = URL(string: endpointUrl + resource) else {
            onError(RESTError.InvalidUrlError("Invalid Url: " + endpointUrl + resource))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.put.rawValue
        request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! encoder.encode(body)
        
        Alamofire.request(request)
            .response(completionHandler: { response in
                print(response)
                onSuccess()
            })
    }
    
    func put<Req: Encodable, Res: Decodable>(_ resource: String, _ body: Req, response: Res.Type, onSuccess: @escaping (Res) -> Void, onError: @escaping (Error) -> Void) {
        guard let url = URL(string: endpointUrl + resource) else {
            onError(RESTError.InvalidUrlError("Invalid Url: " + endpointUrl + resource))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.put.rawValue
        request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! encoder.encode(body)
        
        Alamofire.request(request)
            .responseObject(completionHandler: { (response: DataResponse<Res>) in
                onSuccess(response.value! as Res)
            })
    }
    
    func delete(resource: String, onSuccess: @escaping () -> Void, onError: @escaping(Error) -> Void) {
        guard let url = URL(string: endpointUrl + resource) else {
            onError(RESTError.InvalidUrlError("Invalid Url: " + endpointUrl + resource))
            return
        }
        Alamofire.request(url, method: .delete)
            .response(completionHandler: { response in
                onSuccess()
            })
    }
    
    func delete<Res: Decodable>(resource: String, onSuccess: @escaping (Res) -> Void, onError: @escaping(Error) -> Void) {
        guard let url = URL(string: endpointUrl + resource) else {
            onError(RESTError.InvalidUrlError("Invalid Url: " + endpointUrl + resource))
            return
        }
        Alamofire.request(url, method: .delete)
            .responseObject(completionHandler: { (response: DataResponse<Res>) in
                onSuccess(response.value! as Res)
            })
    }
    
    func setHeaders(request: URLRequest) {
        
    }
}

enum RESTError: Error {
    case InvalidUrlError(_ error: String)
    case DeserializingError()
}
