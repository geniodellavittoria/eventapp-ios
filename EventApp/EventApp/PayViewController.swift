//
//  PayViewController.swift
//  EventApp
//
//  Created by Pascal on 30.11.18.
//  Copyright © 2018 2noobs. All rights reserved.
//

import UIKit
import PassKit


class PayViewController: UIViewController, PKPaymentAuthorizationViewControllerDelegate, PKAddPassesViewControllerDelegate {

    
    
    private let applePayMerchantId = "merchant.com.innovationm.applepaydemo"
    let supportedPaymentNetworks = [PKPaymentNetwork.visa, PKPaymentNetwork.masterCard]

    //var passControler = PKAddPaymentPassViewController()
    var addPassController = PKAddPassesViewController()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addPassController.delegate = self
        
        addApplePayPaymentButtonToView()
    }
    
    // MARK: - Apple Pay
    
    private func addApplePayPaymentButtonToView() {
        let paymentButton = PKPaymentButton(paymentButtonType: .buy, paymentButtonStyle: .black)
        paymentButton.translatesAutoresizingMaskIntoConstraints = false
        paymentButton.addTarget(self, action: #selector(applePayButtonTapped(sender:)), for: .touchUpInside)
        view.addSubview(paymentButton)
        
        view.addConstraint(NSLayoutConstraint(item: paymentButton, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: paymentButton, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0))
    }
    
    
    @objc private func applePayButtonTapped(sender: UIButton) {
        let paymentNetworks:[PKPaymentNetwork] = [.amex,.masterCard,.visa]
        
        if PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: paymentNetworks) {
            let request = PKPaymentRequest()
            
            request.merchantIdentifier = "merchant.com.shiningdevelopers"
            request.countryCode = "CA"
            request.currencyCode = "CAD"
            request.supportedNetworks = paymentNetworks
            request.requiredShippingContactFields = [.name, .postalAddress]
            // This is based on using Stripe
            request.merchantCapabilities = .capability3DS
            
            let tshirt = PKPaymentSummaryItem(label: "T-shirt", amount: NSDecimalNumber(decimal:1.00), type: .final)
            let shipping = PKPaymentSummaryItem(label: "Shipping", amount: NSDecimalNumber(decimal:1.00), type: .final)
            let tax = PKPaymentSummaryItem(label: "Tax", amount: NSDecimalNumber(decimal:1.00), type: .final)
            let total = PKPaymentSummaryItem(label: "Total", amount: NSDecimalNumber(decimal:3.00), type: .final)
            request.paymentSummaryItems = [tshirt, shipping, tax, total]
            
            let authorizationViewController = PKPaymentAuthorizationViewController(paymentRequest: request)
            
            if let viewController = authorizationViewController {
                viewController.delegate = self
                
                present(viewController, animated: true, completion: nil)
            }
        }
    }

    
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        // Let the Operating System know that the payment was accepted successfully
        completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
    }
    
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        // Dismiss the Apple Pay UI
        dismiss(animated: true, completion: nil)
        // add apple pass
    }
    
    // MARK: - Apple Wallet
    func addPaymentPassViewController(_ controller: PKAddPaymentPassViewController, generateRequestWithCertificateChain certificates: [Data], nonce: Data, nonceSignature: Data, completionHandler handler: @escaping (PKAddPaymentPassRequest) -> Void) {
        print("generateRequest")
    }
    
    func addPaymentPassViewController(_ controller: PKAddPaymentPassViewController, didFinishAdding pass: PKPaymentPass?, error: Error?) {
        print("didFinishAdding")
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
