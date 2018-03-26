//
//  ViewController.swift
//  ParallaxAnimation
//
//  Created by 向辉 on 2018/3/26.
//  Copyright © 2018年 JaniXiang. All rights reserved.
//

import UIKit
import Kingfisher
import NVActivityIndicatorView

class ViewController: UIViewController {
    
    static let cellIndentifier = "collectionViewCell"
    
    let image_rate_speed: CGFloat = 0.6
    
    var collectionView: UICollectionView?
    
    let urlsArray = [
                     "https://wallpapers.wallhaven.cc/wallpapers/full/wallhaven-637438.jpg",
                     "https://wallpapers.wallhaven.cc/wallpapers/full/wallhaven-637430.jpg",
                     "https://wallpapers.wallhaven.cc/wallpapers/full/wallhaven-637403.jpg",
                     "https://wallpapers.wallhaven.cc/wallpapers/full/wallhaven-637390.jpg",
                     "https://goo.gl/vHmVQn",
                     "https://goo.gl/m763c7",
                     "https://goo.gl/b9qGQ2",
                     "https://goo.gl/qf2ZsM"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initView()
    }
    
    func initView() {
        let layout = UICollectionViewFlowLayout.init()
        layout.itemSize = CGSize(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.height)
        layout.minimumLineSpacing = 0.0
        layout.scrollDirection = .horizontal
        
        collectionView = UICollectionView.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.height), collectionViewLayout: layout)
        
        collectionView?.isPagingEnabled = true
        collectionView?.backgroundColor = UIColor.black
        
        collectionView?.register(UINib.init(nibName: "MyCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: ViewController.cellIndentifier)
        
        collectionView?.delegate = self
        collectionView?.dataSource = self
        
        if #available(iOS 10, *) {
            collectionView?.prefetchDataSource = self
        }
        
        if let myCollectionView = collectionView {
            view.addSubview(myCollectionView)
        }
    }
}

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let myCell = cell as? MyCollectionViewCell {
            myCell.imageView.backgroundColor = UIColor.lightGray
            let url = URL(string: urlsArray[indexPath.row])
            _ = myCell.imageView.kf.setImage(with: url,
                                             placeholder: nil,
                                             options: [.transition(ImageTransition.fade(1))],
                                             progressBlock: { receiveSize, totalSize in
                                                let str = String(format: "%.2f", receiveSize / totalSize)
                                                print("\(indexPath.row + 1): \(str)")
                                                },
                                             completionHandler: { (image, error, cacheType, imageUrl) in
                                                print("\(indexPath.row) + 1: Finished")
            })
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let myCell = cell as? MyCollectionViewCell {
            // cancel all unfinished downloading task when the cell disappearing.
            myCell.imageView.kf.cancelDownloadTask()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        for cell in collectionView!.visibleCells {
            let myCell = cell as! MyCollectionViewCell
            
            // Different offset  ->  Different speed  -> ParallaxAnimation
            // When image_rate_speed = 1 what will happen, you can have a try.
            let xOffset = (collectionView!.contentOffset.x - cell.frame.origin.x) * image_rate_speed
            myCell.imageOffset = CGPoint(x: xOffset, y: 0.0)
        }
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ViewController.cellIndentifier, for: indexPath) as! MyCollectionViewCell
        
        // set loading indicator
        cell.imageView.kf.indicatorType = .custom(indicator: MyInditor())
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return urlsArray.count
    }
}

struct MyInditor: Indicator {
    func startAnimatingView() {
        (view as! NVActivityIndicatorView).startAnimating()
    }
    
    func stopAnimatingView() {
        (view as! NVActivityIndicatorView).stopAnimating()
    }
    
    var view: IndicatorView = NVActivityIndicatorView.init(frame: CGRect.init(x: 0, y: 0, width: 60, height: 60), type: NVActivityIndicatorType.ballRotateChase, color: .white, padding: 5.0)
}

// 预取数据，只会在数据上进行预处理，并不会在界面上进行展示
extension ViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        let urls = indexPaths.flatMap {
            URL(string: urlsArray[$0.row])
        }
        // 提前下载并且做好缓存
        ImagePrefetcher(urls: urls).start()
    }
}
