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
    
    let image_offset_speed: CGFloat = 100.0
    let image_height = UIScreen.main.bounds.size.width
    
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
    // 在即将显示的时候，对cell上进行图片展示的操作
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let myCell = cell as? MyCollectionViewCell {
//            myCell.imageView.backgroundColor = UIColor.randomColor
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
    
    // 在结束的时候就不去显示了
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let myCell = cell as? MyCollectionViewCell {
            myCell.imageView.kf.cancelDownloadTask()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        for cell in collectionView!.visibleCells {
            let myCell = cell as! MyCollectionViewCell
            
            // 每一个cell.frame.origin.x 都是固定的，不会发生改变
            //let xOffset = (collectionView!.contentOffset.x - cell.frame.origin.x)  // 如果想要背景不动的换页的效果，这是可以的
            let xOffset = (collectionView!.contentOffset.x - cell.frame.origin.x) * 0.6
            
            //  其实说白了就是让imageView和collectionView的的移动速度不一致 -> 让他们的偏移量不一致 -> 拥有不同的比例即可
            //  都是在向右移动
            
            // cell 在滑动的时候；imageview并不是在跟着一起滑动的，而是会向和CollectionView移动的相反的方向滑动
            // 即cell向左移动的时候，imageView应该是向右移动的
            
            myCell.imageOffset = CGPoint(x: xOffset, y: 0.0)
            print("collectionOffSet_x: \(collectionView!.contentOffset.x) cell.frame.origin.x: \(cell.frame.origin.x)")
        }
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ViewController.cellIndentifier, for: indexPath) as! MyCollectionViewCell
        
        // 设置指示器
        cell.imageView.kf.indicatorType = .custom(indicator: MyInditor())
//
//        let xOffset = ((collectionView.contentOffset.x - cell.frame.origin.x) / image_height) * image_offset_speed
//        cell.imageOffset = CGPoint(x: xOffset, y: 0.0)
        
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



extension UIColor {
    class var randomColor: UIColor {
        get {
            let red = CGFloat(arc4random()%256)/255.0
            let green = CGFloat(arc4random()%256)/255.0
            let blue = CGFloat(arc4random()%256)/255.0
            return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
        }
    }
}
