//
//  WeatherManager.swift
//  Clima
//
//  Created by Louis on 21/1/2024.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, _ weather: WeatherModel)
    func didFailWithError(error: Error)
}

struct WeatherManager {
    var delegate: WeatherManagerDelegate?
    var weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=14d6486d883a1757887e1d099db006b8&units=metric"

    func fetchWeather(_ cityName: String) {
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRequest(urlString)
    }
    
    func fetchWeather(_ lat: CLLocationDegrees, _ lon: CLLocationDegrees) {
        let urlString = "\(weatherURL)&lat=\(lat)&lon=\(lon)"
        performRequest(urlString)
    }
    
    
    func performRequest(_ urlString: String) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url, completionHandler: handler(data:response:error:))
            task.resume()
        }
    }
    
    func handler(data: Data?, response: URLResponse?, error: Error?) {
        if error != nil {
            self.delegate?.didFailWithError(error: error!)
            return
        }
        if let safeData = data {
            if let weather = parseJSON(safeData) {
                self.delegate?.didUpdateWeather(self, weather)
            }
        }
    }
    
    func parseJSON(_ weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            let weather = WeatherModel(weatherId: id, cityName: name, temp: temp)
            return weather
        } catch {
            self.delegate?.didFailWithError(error: error)
        }
        return nil
    }
}
