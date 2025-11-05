//
//  WeatherViewMode.swift
//  GetWeather
//
//  Created by Яков Демиденко on 10/30/25.
//

import Foundation
import Combine


class WeatherViewModel
{
    
    @Published var text:String = ""
    @Published var locations: [AddresLocation] = []
    
    private var cancellables: Set<AnyCancellable> = []
    
    private let locationService: LocationServiceProtocol
    
    init(locationService: LocationServiceProtocol = YandexGeoService())
    {
        self.locationService = locationService
        setupBindings()
        //locationService.fetchLocations(query: text)
    }
    
    private func setupBindings()
    {
        $text
            .filter { $0.count >= 3 }
            .debounce(for: .seconds(0.6), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .flatMap { [unowned self] query -> AnyPublisher<[AddresLocation], Never> in
                self.locationService
                    .fetchLocations(query: query)
                    .replaceError(with: [])
                    .eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] locations in
                self?.locations = locations
            }
            .store(in: &cancellables)
    }
}
