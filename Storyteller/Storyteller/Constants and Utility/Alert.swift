//
//  Alert.swift
//  Storyteller
//
//  Created by TFang on 2/4/21.
//

import UIKit

class Alert {
    static func presentAtLeastOneLayerAlert(controller: UIViewController) {
        presentAlert(controller: controller,
                     title: Constants.errorTitle, message: Constants.atLeastOneLayerMessage)
    }

    static func presentRenameLayerAlert(at index: Int,
                                        controlloer: LayerTableController) {
        let alertController = UIAlertController(
            title: "Rename",
            message: "",
            preferredStyle: .alert
        )
        alertController.addTextField { textField in
            textField.text = controlloer.shot.layers[index].name
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let newLayerName = alertController.textFields?[0].text else {
                return
            }
            controlloer.delegate?.didChangeLayerName(at: index, newName: newLayerName)
        }
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        controlloer.present(alertController, animated: true, completion: nil)
    }

    private static func presentAlert(controller: UIViewController, title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Constants.okTitle, style: .default, handler: nil))
        controller.present(alert, animated: true)
    }
}
