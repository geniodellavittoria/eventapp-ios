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
    let decoder = JSONEncoder()
    
    var defaultHeader: HTTPHeaders = [
        "Content-Type": "application/json",
        "charset": "UTF-8"
    ]
    
    init(resource: String) {
        endpointUrl = Config.backendUrl
        self.resource = resource
        sessionManager.adapter = accessTokenAdapter
    }
    
    /*func getAll<T>(resource: String) {
        
    }*/
    
    func getAll() throws -> DataRequest {
        guard let url = URL(string: endpointUrl + resource) else {
            throw RESTError.InvalidUrlError("Invalid Url: " + endpointUrl + resource)
        }
        return Alamofire.request(url, method: .get)
    }
    
    func get<T, R>(resource: String, response: R.Type, doOnSuccess: @escaping (T) -> Void, doOnError: @escaping (Error) -> Void) throws -> DataRequest {
        guard let url = URL(string: endpointUrl + resource) else {
            throw RESTError.InvalidUrlError("Invalid Url: " + endpointUrl + resource)
        }
        return Alamofire.request(url, method: .get)
            /*.validate()
            .responseJSON(completionHandler: { response in
                if let json = response.result.value {
                    print("JSON: \(json)") // serialized json response
                }
                
                if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                    print("Data: \(utf8Text)") // original server data as UTF8 string
                }
            })*/
    }
    
    /*func get<T>(id: String) {
        return get<T>(resource: self.resource + "/" + id)
    }*/
    
    /*func post(body: T) {
        post(resource: resource, body: body)
    }*/
    
    func post<Req: Encodable, Res: Codable>(resource: String, _ body: Req, response: Res.Type, onSuccess: @escaping (_ response: Res) -> Void, onError: @escaping (_ err: Error) -> Void) {
        guard let url = URL(string: endpointUrl + resource) else {
            onError(RESTError.InvalidUrlError("Invalid Url: " + endpointUrl + resource))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! encoder.encode(body)

        Alamofire.request(request)
            .responseObject(completionHandler: { (response: DataResponse<JwtToken>) in
                onSuccess(response.value as! Res)
        })
        print("restcontroller")
        
    }
    
    func put<T: Encodable>(resource: String, _ body: T) throws -> DataRequest {
        guard let url = URL(string: endpointUrl + resource) else {
            throw RESTError.InvalidUrlError("Invalid Url: " + endpointUrl + resource)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.put.rawValue
        request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! encoder.encode(body)
        
        return Alamofire.request(request)
    }
    
    /*func put(body: T) {
        put(resource: resource, body: body)
    }*/
    
    func delete(resource: String) throws -> DataRequest {
        guard let url = URL(string: endpointUrl + resource) else {
            throw RESTError.InvalidUrlError("Invalid Url: " + endpointUrl + resource)
        }
        return Alamofire.request(url, method: .delete)
    }
    
    func setHeaders(request: URLRequest) {
        
    }
}

enum RESTError: Error {
    case InvalidUrlError(_ error: String)
    case DeserializingError()
}
