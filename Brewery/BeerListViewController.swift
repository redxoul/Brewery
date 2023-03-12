//
//  BeerListViewController.swift
//  Brewery
//
//  Created by Cody on 2022/08/26.
//

import UIKit
import SwiftUI
import Then

class BeerListViewController: UITableViewController {
    
    var beerList = [Beer]()
    var dataTasks = [URLSessionTask]()
    var currentPage = 1

    override func viewDidLoad() {
        super.viewDidLoad()

        // UINavigationBar
        
        title = "Cody Brewery"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        tableView.register(BeerListCell.self, forCellReuseIdentifier: "BeerListCell")
        tableView.rowHeight = 150 // delegate 설정 없이 이렇게 설정 가능
        tableView.prefetchDataSource = self
        
        fetchBeer(of: currentPage)
    }

}

// MARK: - Table view datasource, delegate
extension BeerListViewController: UITableViewDataSourcePrefetching {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return beerList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("Row: \(indexPath.row)")
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BeerListCell", for: indexPath) as? BeerListCell else { return UITableViewCell() }
        
        let beer = beerList[indexPath.row]
        cell.configure(with: beer)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedBeer = beerList[indexPath.row]
        let detailViewController = BeerDetailViewController().then {
            $0.beer = selectedBeer
        }
        
        self.show(detailViewController, sender: nil)
    }
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        guard currentPage != 1 else { return }
        
        indexPaths.forEach {
            if ($0.row + 1)/25 + 1 == currentPage {
                fetchBeer(of: currentPage)
            }
        }
    }
}

// Data Fetching
private extension BeerListViewController {
    func fetchBeer(of page: Int) {
        guard let url = URL(string: "https://api.punkapi.com/v2/beers?page=\(page)"),
        dataTasks.firstIndex(where: { $0.originalRequest?.url == url }) == nil else { return }
        
        var request = URLRequest(url:url)
        request.httpMethod = "GET"
        
        let dataTask = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard error == nil,
                  let self = self,
                  let response = response as? HTTPURLResponse,
                  let data = data,
                  let beers = try? JSONDecoder().decode([Beer].self, from: data) else {
                print("Error: \(error?.localizedDescription ?? "")")
                return
            }
            
            switch response.statusCode {
            case 200...299: // 성공
                self.beerList += beers
                self.currentPage += 1
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case 400...499: // 클라이언트 에러
                print("""
                      Client Error: \(response.statusCode)
                      Response: \(response)
                      """)
            case 500...599: // 서버 에러
                print("""
                      Server Error: \(response.statusCode)
                      Response: \(response)
                      """)
            default:
                print("""
                      Error: \(response.statusCode)
                      Response: \(response)
                      """)
            }
        }
        dataTask.resume()
        dataTasks.append(dataTask)
    }
}



// For Preview
struct BeerListViewControllerContainer: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UINavigationController {
        let viewController = UINavigationController(rootViewController: BeerListViewController())
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) { }
    
    typealias UIViewControllerType = UINavigationController
}

struct BeerListViewController_Previews: PreviewProvider {
    static var previews: some View {
        BeerListViewControllerContainer()
    }
}
