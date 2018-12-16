//
//  EurekaFormExtension.swift
//  EventApp
//
//  Created by Pascal on 16.12.18.
//  Copyright © 2018 2noobs. All rights reserved.
//

import Foundation
import Eureka

extension Form {
    
    static func installDefaultValidationHandlers() {
        TextRow.defaultCellUpdate = highlightCellLabelIfValidationFailed
        TextRow.defaultOnRowValidationChanged = showValidationErrors
    }
    
    private static func highlightCellLabelIfValidationFailed(cell: BaseCell, row: BaseRow) {
        if !row.isValid {
            cell.textLabel?.textColor = .red
        }
    }
    
    private static func showValidationErrors(cell: BaseCell, row: BaseRow) {
        row.removeValidationErrorRows()
        row.addValidationErrorRows()
    }
}

extension BaseRow {
    
    fileprivate func removeValidationErrorRows() {
        let rowIndex = indexPath!.row
        while section!.count > rowIndex + 1 && section?[rowIndex  + 1] is LabelRow {
            _ = section?.remove(at: rowIndex + 1)
        }
    }
    
    fileprivate func addValidationErrorRows() {
        for (index, validationMsg) in validationErrors.map({ $0.msg }).enumerated() {
            let labelRow = LabelRow {
                $0.title = validationMsg
                $0.cell.height = { 30 }
            }
            section?.insert(labelRow, at: indexPath!.row + index + 1)
        }
    }
}
