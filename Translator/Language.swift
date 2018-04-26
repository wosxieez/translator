//
//  Language.swift
//  MSRDemo
//
//  Created by coco on 19/08/2017.
//  Copyright © 2017 coco. All rights reserved.
//


class Language
{
    
    var name: String!
    var streamCode: String?
    var recognitionCode: String?
    var ttsCode: String?
    var translateCode: String?
    var ocrCode: String?
    
    init(name: String, streamCode: String? = nil, recognitionCode: String? = nil, translateCode: String? = nil, ttsCode: String? = nil, ocrCode: String? = nil)
    {
        self.name = name;
        self.streamCode = streamCode
        self.recognitionCode = recognitionCode
        self.translateCode = translateCode
        self.ttsCode = ttsCode
        self.ocrCode = ocrCode
    }
    
}
