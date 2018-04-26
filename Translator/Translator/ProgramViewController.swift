//
//  ProgramViewController.swift
//  Translator
//
//  Created by coco on 09/11/2017.
//  Copyright © 2017 coco. All rights reserved.
//

import UIKit

class ProgramViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    
    @IBOutlet weak var collectionView:UICollectionView!;
    
    override func viewDidLoad()
    {
        super.viewDidLoad();
        
        collectionView.dataSource = self;
        collectionView.delegate = self;
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning();
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1;
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 100;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell:ProgramCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cusCollectionViewCell", for: indexPath)
            as! ProgramCollectionViewCell;
        cell.textLabel.text = "我的程序\(indexPath.row)";
        cell.layer.cornerRadius = 10;
        cell.layer.masksToBounds = true;
        return cell;
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let size:CGFloat = (collectionView.bounds.width - 42) / 3;
        return CGSize(width: size, height: size);
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets
    {
        return UIEdgeInsetsMake(10, 10, 10, 10);
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat
    {
        return 10;
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat
    {
        return 10;
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        Toast.show(message: "功能开发中");
    }
    
}
