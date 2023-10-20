//
//  File.swift
//  
//
//  Created by Colbyn Wadman on 10/17/23.
//

import Foundation

extension Html: ToPrettyTree {
    var prettyTree: PrettyTree {
        fatalError("TODO")
    }
}
extension Html.Element.Attribute: ToPrettyTree {
    var prettyTree: PrettyTree {
        PrettyTree.value("\(self.key.value): \(self.value.value)")
    }
}
//extension HTML.Element: ToPrettyTree {
//    var prettyTree: PrettyTree {
//        PrettyTree.branch(.init(name: "\()", children: <#T##[PrettyTree]#>))
//    }
//}

