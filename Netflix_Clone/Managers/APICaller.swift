//
//  APICaller.swift
//  Netflix_Clone
//
//  Created by mohamed reda oumahdi on 04/03/2024.
//

import Foundation

struct Constants {
    static let API_KEY = "2758db7be33f5f2c077dc91357743490"
    static let base_URL = "https://api.themoviedb.org"
    static let headers = [
        "accept": "application/json",
        "Authorization": "Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIyNzU4ZGI3YmUzM2Y1ZjJjMDc3ZGM5MTM1Nzc0MzQ5MCIsInN1YiI6IjY1ZTVjNGZhYTY3MjU0MDE4NWFkYmFhZSIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.r3k3JNMDFgViJk30ByfW47jyWfyOAt-GPCkz-P2Z6G8"
      ]
    static let Youtube_API_KEY = "AIzaSyCERrft97Cc9g0KLybOwVBgyaREuZuuNbA"
    static let youtube_urlBase = "https://youtube.googleapis.com/youtube/v3/search?"
}

enum APIError : Error {
     case failedToGetData
}

class APICller {
    static let shared = APICller()
    
    
    func getTrendingMovies(completing: @escaping (Result<[Title], Error>) -> Void){
        
        let request = NSMutableURLRequest(url: NSURL(string: "https://api.themoviedb.org/3/trending/movie/day?language=en-US")! as URL,
                                                cachePolicy: .useProtocolCachePolicy,
                                            timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = Constants.headers

        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
          if (error != nil) {
            print(error as Any)
          } else {
              do{
                  let results = try JSONDecoder().decode(TrendingTitleResponse.self, from: data!)
                  completing(.success(results.results))
              } catch{
                  completing(.failure(APIError.failedToGetData))
              }
          }
        })

        dataTask.resume()
    }
    
    func getPopularMovies(completing: @escaping (Result<[Title], Error>) -> Void){

        let request = NSMutableURLRequest(url: NSURL(string: "https://api.themoviedb.org/3/movie/popular?language=en-US&page=1")! as URL,
                                                cachePolicy: .useProtocolCachePolicy,
                                            timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = Constants.headers

        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
          if (error != nil) {
            print(error as Any)
          } else {
              do{
                  let results = try JSONDecoder().decode(TrendingTitleResponse.self, from: data!)
                  completing(.success(results.results))
              } catch{
                  completing(.failure(APIError.failedToGetData))
              }
          }
        })

        dataTask.resume()
    }
    
    func getTrendingTVShows(completing: @escaping (Result<[Title], Error>) -> Void){
        
        let request = NSMutableURLRequest(url: NSURL(string: "https://api.themoviedb.org/3/trending/tv/day?language=en-US")! as URL,
                                                cachePolicy: .useProtocolCachePolicy,
                                            timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = Constants.headers

        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
          if (error != nil) {
            print(error as Any)
          } else {
              do{
                  let results = try JSONDecoder().decode(TrendingTitleResponse.self, from: data!)
                  completing(.success(results.results))
              } catch{
                  completing(.failure(APIError.failedToGetData))
              }
          }
        })

        dataTask.resume()
    }
    
    
    func getUPComingMovies(completing: @escaping (Result<[Title], Error>) -> Void){

        let request = NSMutableURLRequest(url: NSURL(string: "https://api.themoviedb.org/3/movie/upcoming?language=en-US&page=1")! as URL,
                                                cachePolicy: .useProtocolCachePolicy,
                                            timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = Constants.headers

        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
          if (error != nil) {
            print(error as Any)
          } else {
              do{
                  let results = try JSONDecoder().decode(TrendingTitleResponse.self, from: data!)
                  completing(.success(results.results))
              } catch{
                  completing(.failure(APIError.failedToGetData))
              }
          }
        })

        dataTask.resume()
    }
    
    func getTopRatedMovies(completing: @escaping (Result<[Title], Error>) -> Void){

        let request = NSMutableURLRequest(url: NSURL(string: "https://api.themoviedb.org/3/movie/top_rated?language=en-US&page=1")! as URL,
                                                cachePolicy: .useProtocolCachePolicy,
                                            timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = Constants.headers

        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
          if (error != nil) {
            print(error as Any)
          } else {
              do{
                  let results = try JSONDecoder().decode(TrendingTitleResponse.self, from: data!)
                  completing(.success(results.results))
              } catch{
                  completing(.failure(APIError.failedToGetData))
              }
          }
        })

        dataTask.resume()
    }
    
    func searchForMovieByName(with movieName : String? = nil, completing: @escaping (Result<[Title], Error>) -> Void) {
        var movieNameWithoutSpace = ""
        if let query = movieName {
            movieNameWithoutSpace = replaceSpaces(query)
        } else {
            movieNameWithoutSpace = replaceSpaces("The Walking Dead")
        }
        let request = NSMutableURLRequest(url: NSURL(string: "https://api.themoviedb.org/3/search/movie?query=\(movieNameWithoutSpace)&include_adult=false&language=en-US&page=1")! as URL,
                                                cachePolicy: .useProtocolCachePolicy,
                                            timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = Constants.headers

        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
          if (error != nil) {
            print(error as Any)
          } else {
              do{
                  let results = try JSONDecoder().decode(TrendingTitleResponse.self, from: data!)
                  completing(.success(results.results))
              } catch{
                  completing(.failure(APIError.failedToGetData))
              }
          }
        })

        dataTask.resume()
    }
    
    func replaceSpaces(_ input: String) -> String {
        var result = ""
        for char in input {
            if char == " " {
                result += "%20"
            } else {
                result.append(char)
            }
        }
        return result
    }
    
    func getMovie(with query: String, completing: @escaping (Result<VideoElement, Error>) -> Void) {
        
        guard let query = query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {return}
        guard let url = URL(string: "\(Constants.youtube_urlBase)q=\(query)&key=\(Constants.Youtube_API_KEY)") else {return}
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, _, error in
            guard let data = data, error == nil else {
                return
            }
            
            do {
                let results = try JSONDecoder().decode(YoutubeSearchResponse.self, from: data)
                
                completing(.success(results.items[0]))
                
                
            } catch {
                completing(.failure(error))
                print(error.localizedDescription)
            }
            
            
        }
        task.resume()
    }
    
        
}
