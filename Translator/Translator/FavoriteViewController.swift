//
//  FavoriteViewController.swift
//  Translator
//
//  Created by coco on 08/11/2017.
//  Copyright © 2017 coco. All rights reserved.
//

import UIKit

class FavoriteViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout
{
    
    @IBOutlet weak var collectionView: UICollectionView!;
    
    override func viewDidLoad()
    {
        super.viewDidLoad();
        
        collectionView.delegate = self;
        collectionView.dataSource = self;
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return 1;
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return 10;
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell:FavoriteCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCell",
                                                                                 for: indexPath)
            as! FavoriteCollectionViewCell;
        cell.textLabel.text = "我的收藏\(indexPath.row)";
        cell.layer.cornerRadius = 10;
        cell.layer.masksToBounds = true;
        return cell;
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize 
    {
        // 一行3列
        let size:CGFloat = (collectionView.bounds.width - 42) / 3;
        return CGSize(width: size, height: size);
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets
    {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10);
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat
    {
        return 10;
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat
    {
        return 10;
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        print(Thread.isMainThread);
        Toast.show(message: "功能开发中");
    }
    
}
