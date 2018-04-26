//
//  Language.swift
//  MSRDemo
//
//  Created by coco on 19/08/2017.
//  Copyright © 2017 coco. All rights reserved.
//


class Language
{
    
    public var name:String!;
    public var code:String!;
    public var speechCode:String!;
    
    public init()
    {
    }
    
    public init(name:String, code:String, speechCode:String = "zh")
    {
        self.name = name;
        self.code = code;
        self.speechCode = speechCode;
    }
    
}
