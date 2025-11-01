//
//  YandexGeoService.swift
//  GetWeather
//
//  Created by Яков Демиденко on 10/31/25.
//

import Foundation
import Combine

private let YANDEX_API_KEY = "acf81f7a-d5f8-4a0a-b0ce-240fc8722d7e"
private let BASE_HOST = "geocode-maps.yandex.ru"

protocol LocationServiceProtocol {
    func fetchLocations(query: String) -> AnyPublisher<[AddresLocation], Error>
}

class YandexGeoService: LocationServiceProtocol {
    

    func fetchLocations(query: String) -> AnyPublisher<[AddresLocation], Error> {
        
        guard let url = createGeocoderURL(for: query) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        return URLSession.shared.dataTaskPublisher(for: url)
                    // 3. Обработка ошибок HTTP и извлечение Data
                    .tryMap { data, response in
                        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                            // Обработка ошибок сервера (например, 403 Forbidden или 500 Internal Error)
                            throw URLError(.badServerResponse)
                        }
                        return data
                    }
                    // 4. Декодирование (парсинг) сырых данных в нашу корневую структуру
                    .decode(type: GeoResponse.self, decoder: JSONDecoder())
                    // 5. Преобразование сложной API-структуры в нашу простую модель AddresLocation
                    .tryMap { geoResponse in
                        return try YandexGeoService.mapToAddressLocations(geoResponse: geoResponse)
                    }
                    // 6. Стирание типа издателя, чтобы соответствовать протоколу
                    .eraseToAnyPublisher()

    }
    
    private func createGeocoderURL(for query: String) -> URL? {
            var components = URLComponents()
            components.scheme = "https"
            components.host = BASE_HOST
            components.path = "/1.x/"
            
            components.queryItems = [
                URLQueryItem(name: "apikey", value: YANDEX_API_KEY),
                URLQueryItem(name: "geocode", value: query),
                URLQueryItem(name: "format", value: "json"),
                URLQueryItem(name: "results", value: "10")
            ]
            
            return components.url
        }
        
        // Функция для преобразования декодированной структуры в AddresLocation
        private static func mapToAddressLocations(geoResponse: GeoResponse) throws -> [AddresLocation] {
            let geoObjects = geoResponse.response.GeoObjectCollection.featureMember.map { $0.GeoObject }
            
            // Если нечего парсить, возвращаем пустой массив
            guard !geoObjects.isEmpty else {
                return []
            }
            
            // Преобразуем массив GeoObject в массив AddresLocation, используя
            // инициализатор, который мы определили ранее (с разделением "pos")
            return try geoObjects.compactMap { try AddresLocation(from: $0) }
        }
}
