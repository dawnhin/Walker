//
//  Network.swift
//  Walker
//
//  Created by 黎铭轩 on 27/12/2020.
//

import Foundation
import HealthKit
class Network {
    //MARK: - 发送数据
    class func push(addedSamples: [HKObject]?=nil, deletedSamples: [HKDeletedObject]?=nil){
        if let samples = addedSamples, !samples.isEmpty {
            pushAddedSamples(samples)
        }
        if let deletedSamples = deletedSamples, !deletedSamples.isEmpty {
            pushDeletedSamples(deletedSamples)
        }
    }
    class func pushAddedSamples(_ objects: [HKObject]) {
        var statusDictionary: [String: Int]=[:]
        for object in objects {
            guard let sample = object as? HKSample else {
                print("我们不支持在这时拉非样本数据!")
                return
            }
            let identifier=sample.sampleType.identifier
            if let value = statusDictionary[identifier] {
                statusDictionary[identifier]=value+1
            }else{
                statusDictionary[identifier]=1
            }
        }
        print("拉\(objects.count)个新样本到伺服器!")
        print("样本:", statusDictionary)
    }
    class func pushDeletedSamples(_ samples: [HKDeletedObject]){
        print("拉\(samples.count)删除样本到伺服器!")
        print("样本:", samples)
    }
    //MARK: - 获取数据
    class func pull(completion: (ServerResponse) -> Void){
        print("从伺服器拉数据!")
        //从磁盘加载模仿伺服器响应模拟获取新数据
        print("加载模仿伺服器响应")
        let response=loadMockServerResponse()
        completion(response)
    }
    private class func loadMockServerResponse() -> ServerResponse{
        let pathName="MockServerResponse"
        guard
            let file = Bundle.main.url(forResource: pathName, withExtension: "json"),
            let data = try? Data(contentsOf: file)
        else { fatalError("不能加载文件\(pathName).json") }
        do{
            let decoder=JSONDecoder()
            decoder.dateDecodingStrategy=JSONDecoder.DateDecodingStrategy.iso8601
            let serverResponse=try decoder.decode(ServerResponse.self, from: data)
            return serverResponse
        }catch{
            fatalError("不能解码ServerResponse!")
        }
    }
}
