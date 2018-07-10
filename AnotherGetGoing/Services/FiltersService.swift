//
//  FiltersService.swift
//  AnotherGetGoing
//
//  Created by YIfan Yin on 2018-07-09.
//  Copyright © 2018 Alla Bondarenko. All rights reserved.
//

import Foundation
import UIKit

protocol FiltersServiceDelegate {
    func retrieveFilterParameters(controller: FiltersViewController, filters: FilterOptions?)
}
