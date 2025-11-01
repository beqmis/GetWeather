//
//  WeatherModel.swift
//  GetWeather
//
//  Created by Яков Демиденко on 10/30/25.
//

import Foundation

// Вспомогательные структуры для парсинга GeoObject Яндекса
struct GeoResponse: Decodable {
    let response: GeoObjectCollectionContainer
}

struct GeoObjectCollectionContainer: Decodable {
    let GeoObjectCollection: GeoObjectCollection
}

struct GeoObjectCollection: Decodable {
    let featureMember: [FeatureMember]
}

struct FeatureMember: Decodable {
    let GeoObject: GeoObject
}

struct GeoObject: Decodable {
    // 1. Поле для адреса (text/formatted)
    let metaDataProperty: MetaDataProperty
    
    // 2. Поле для координат (pos)
    let Point: Point
}

struct MetaDataProperty: Decodable {
    let GeocoderMetaData: GeocoderMetaData
}

struct GeocoderMetaData: Decodable {
    // Это наш адрес, который станет currentAddress
    let text: String
}

struct Point: Decodable {
    // Это наша строка с координатами (долгота широта)
    let pos: String
}


struct AddresLocation:Decodable
{
    let currentAddress:String
    let lat:Double
    let lon:Double
    
    init(from geoObject: GeoObject) throws {
            // 1. Извлекаем адрес
            self.currentAddress = geoObject.metaDataProperty.GeocoderMetaData.text
            
            // 2. Извлекаем и преобразуем координаты
            let posString = geoObject.Point.pos // Строка "37.617698 55.755864"
            let components = posString.components(separatedBy: " ")
            
            // Яндекс возвращает Долготу (lon) первым, а Широту (lat) вторым
            guard components.count == 2,
                  let lonValue = Double(components[0]),
                  let latValue = Double(components[1])
            else {
                // Если строка pos неправильная, выбрасываем ошибку
                throw NSError(domain: "YandexGeoParsing", code: 1,
                              userInfo: [NSLocalizedDescriptionKey: "Не удалось распарсить координаты"])
            }
            
            // Присваиваем значения
            self.lon = lonValue
            self.lat = latValue
        }
}

struct Weather:Decodable
{
    let temp:Double
    let windspeed:Double
    
    let pressure:Int
    
    let localtime:String
    //let yesturdayTemperature:Double
}
