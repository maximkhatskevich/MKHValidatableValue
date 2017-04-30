//
//  Helpers.swift
//  MKHValidatableValue
//
//  Created by Maxim Khatskevich on 12/6/16.
//  Copyright © 2016 Maxim Khatskevich. All rights reserved.
//

extension ValidatableValue
{
    func validate(_ input: Value?) -> Bool
    {
        guard
            let input = input
        else
        {
            return false
        }
        
        //===
        
        guard
            requirements
                .reduce(true,
                        { $0 && $1.isFulfilled(with: input) })
        else
        {
            return false
        }
        
        //===
        
        return true
    }
}
