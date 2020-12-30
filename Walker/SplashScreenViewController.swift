//
//  SplashScreenViewController.swift
//  Walker
//
//  Created by 黎铭轩 on 29/11/2020.
//

import UIKit
protocol SplashScreenViewControllerDelegate: class {
    func didSelectActionButton()
}
private extension CGFloat{
    static let inset: CGFloat=20
    static let padding: CGFloat=12
}
class SplashScreenViewController: UIViewController {
    lazy var containerView: UIView = {
        let view=UIView()
        view.translatesAutoresizingMaskIntoConstraints=false
        return view
    }()

    lazy var actionButton: UIButton = {
        let button=UIButton()
        button.translatesAutoresizingMaskIntoConstraints=false
        button.titleLabel?.font=UIFont.systemFont(ofSize: 18)
        button.titleLabel?.adjustsFontForContentSizeCategory=true
        button.setTitleColor(UIColor.systemBlue, for: UIControl.State.normal)
        button.setTitleColor(UIColor.systemBlue.withAlphaComponent(0.5), for: UIControl.State.highlighted)
        button.addTarget(self, action: #selector(didSelectActionButton), for: .touchUpInside)
        return button
    }()
    lazy var descriptionLabel: UILabel = {
        let label=UILabel()
        label.translatesAutoresizingMaskIntoConstraints=false
        label.font=UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.regular)
        label.textColor=UIColor.label
        label.numberOfLines=0
        label.textAlignment=NSTextAlignment.center
        label.adjustsFontForContentSizeCategory=true
        return label
    }()
    
    weak var splashScreenDelegate: SplashScreenViewControllerDelegate?
    
    //MARK: - 初始化
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //MARK: - 视图生命周期
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpViews()
    }
    private func setUpViews(){
        view.addSubview(containerView)
        containerView.addSubview(actionButton)
        containerView.addSubview(descriptionLabel)
        setUpConstraints()
    }
    private func setUpConstraints(){
        var constraints: [NSLayoutConstraint]=[]
        constraints += createContainerViewConstraints()
        constraints += createActionButtonConstraints()
        constraints += createDescriptionLabelConstraints()
        NSLayoutConstraint.activate(constraints)
    }
    private func createContainerViewConstraints() -> [NSLayoutConstraint]{
        let leading=containerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: .inset)
        let trailing=containerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -.inset)
        let centerY=containerView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        return [leading, trailing, centerY]
    }
    private func createActionButtonConstraints() -> [NSLayoutConstraint]{
        let top=actionButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: .padding)
        let centerX=actionButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
        return [top, centerX]
    }
    private func createDescriptionLabelConstraints() -> [NSLayoutConstraint]{
        let top=descriptionLabel.topAnchor.constraint(equalTo: actionButton.bottomAnchor, constant: .padding)
        let bottom=descriptionLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -.padding)
        let leading=descriptionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: .padding)
        let trailing=descriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -.padding)
        return [top, bottom, leading, trailing]
    }
    //MARK: - Selectors
     @objc private func didSelectActionButton() {
        splashScreenDelegate?.didSelectActionButton()
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
