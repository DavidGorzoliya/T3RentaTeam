//
//  PicturesViewController.swift
//  RentaTeam
//
//  Created by Давид Горзолия on 10/13/21.
//

import UIKit

private let cellIdentifier = "cell"

final class PicturesViewController: UIViewController {

    private let activityIndicator = UIActivityIndicatorView()
    private var results: [Result] = [] {
        didSet {
            imageUrls = results.map { URL(string: $0.urls.small)! }
            collectionView.reloadData()
        }
    }
    private var imageUrls = [URL]()
    private var images = [UIImage?]()
    private var currentCount: Int = 0
    private var page: Int = 1
    private var isLoading = false {
        didSet {
            if isLoading {
                activityIndicator.startAnimating()
            } else {
                activityIndicator.stopAnimating()
            }
        }
    }

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: view.frame.size.width/2, height: view.frame.size.width/2)

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white

        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        style()
        layout()
        setupCollectionView()
        getData()
    }

    private func style() {
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .white
        navigationController?.navigationBar.topItem?.titleView = activityIndicator
        collectionView.backgroundColor = .black
    }

    private func getData() {
        isLoading = true
        NetworkManager.shared.fetchPhotos(page: page) { [weak self] result in
            self?.isLoading = false
            switch result {
            case .success(let data):
                self?.results += data
            case .failed(let error):
                print(error)
            }
        }
    }

    private func layout() {
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        collectionView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    }

    private func setupCollectionView() {
        collectionView.register(PicturesCollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
    }

}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension PicturesViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return results.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! PicturesCollectionViewCell

        if currentCount <= 30 * page {
            NetworkManager.shared.fetchImage(with: imageUrls[indexPath.row]) { result in
                switch result {
                case .success(let image):
                    self.images.append(image)
                    if let cell = collectionView.cellForItem(at: indexPath) as? PicturesCollectionViewCell {
                        cell.configureImage(with: image)
                        cell.configureLikesNumber(with: self.results[indexPath.row].likes)
                    }
                case .failed(let error):
                    print(error)
                }
            }
            currentCount += 1
        } else {
            if images.indices.contains(indexPath.row), let image = images[indexPath.row] {
                cell.configureImage(with: image)
                cell.configureLikesNumber(with: results[indexPath.row].likes)
            }
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? PicturesCollectionViewCell,
              let image = cell.picImageView.image else {
            return
        }

        let vc = PicturesDetalisViewController()
        vc.configureWith(image: image, title: results[indexPath.row].created_at)
        vc.modalPresentationStyle = .pageSheet
        navigationController?.pushViewController(vc, animated: true)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        if !isLoading,
           position > collectionView.contentSize.height-100-scrollView.frame.size.height {
            page += 1
            isLoading = true
            NetworkManager.shared.fetchPhotos(page: page) { [weak self] result in
                self?.isLoading = false
                switch result {
                case .success(let data):
                    self?.results += data
                case .failed(let error):
                    print(error)
                }
            }
        }
    }
}
