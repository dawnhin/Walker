//
//  DataTypeCollectionViewController.swift
//  Walker
//
//  Created by 黎铭轩 on 22/12/2020.
//

import UIKit
/// 一个带集合视图展示数据类型数据和用`DataTypeCollectionViewCell`视觉化它们图表根视图控制器
class DataTypeCollectionViewController: UIViewController {

    static let cellIdentifier="DataTypeCollectionViewCell"
    //MARK: - 属性
    lazy var collectionView: UICollectionView = {
        let collectionView=UICollectionView(frame: CGRect.zero, collectionViewLayout: makeLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints=false
        collectionView.dataSource=self
        collectionView.register(DataTypeCollectionViewCell.self, forCellWithReuseIdentifier: Self.cellIdentifier)
        collectionView.alwaysBounceVertical=true
        return collectionView
    }()
    var data: [(dataTypeIdentifier: String, value: [Double])] = []
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationController()
        setUpViews()
        title=tabBarItem.title
        view.backgroundColor=UIColor.systemBackground
        collectionView.backgroundColor=UIColor.systemBackground
        // Do any additional setup after loading the view.
    }
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        collectionView.setCollectionViewLayout(makeLayout(), animated: true)
    }
    func reloadData() {
        collectionView.reloadData()
    }
    //MARK: - 视图助手方法
    private func setupNavigationController(){
        navigationController?.navigationBar.prefersLargeTitles=true
    }
    private func setUpViews(){
        view.addSubview(collectionView)
        setUpConstraints()
    }
    private func setUpConstraints(){
        var constraints: [NSLayoutConstraint] = []
        constraints += createCollectionViewConstraints()
        NSLayoutConstraint.activate(constraints)
    }
    private func createCollectionViewConstraints() -> [NSLayoutConstraint]{
         [collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
         collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
         collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
         collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ]
    }
    func makeLayout() -> UICollectionViewLayout {
        let verticalMargin: CGFloat=8
        let horizontalMargin: CGFloat=20
        let interGroupSpacing: CGFloat=horizontalMargin
        let cellHeight=calculateCellHeight(horizontalMargin: horizontalMargin, verticalMargin: verticalMargin)
        let itemSize=NSCollectionLayoutSize(widthDimension: NSCollectionLayoutDimension.fractionalWidth(1), heightDimension: NSCollectionLayoutDimension.absolute(cellHeight))
        let item=NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize=NSCollectionLayoutSize(widthDimension: NSCollectionLayoutDimension.fractionalWidth(1), heightDimension: NSCollectionLayoutDimension.absolute(cellHeight))
        let group=NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        let section=NSCollectionLayoutSection(group: group)
        section.interGroupSpacing=interGroupSpacing
        section.contentInsets=NSDirectionalEdgeInsets(top: verticalMargin, leading: horizontalMargin, bottom: verticalMargin, trailing: horizontalMargin)
        let layout=UICollectionViewCompositionalLayout(section: section)
        return layout
    }

    ///返回一个集合视图单元格高度等于视图边界减去每一个边界尺寸
    private func calculateCellHeight(horizontalMargin: CGFloat, verticalMargin: CGFloat) -> CGFloat{
        let isLandscape=UIApplication.shared.isLandscape
        let widthInset=(horizontalMargin*2)+view.safeAreaInsets.left+view.safeAreaInsets.right
        var heightInset=(verticalMargin*2)//安全内边距已经计上tabBar边界
        heightInset+=navigationController?.navigationBar.bounds.height ?? 0
        heightInset+=tabBarController?.tabBar.bounds.height ?? 0
        let cellHeight=isLandscape ? view.bounds.height-heightInset : view.bounds.width-widthInset
        return cellHeight
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
extension DataTypeCollectionViewController: UICollectionViewDataSource, UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let content=data[indexPath.row]
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Self.cellIdentifier, for: indexPath) as? DataTypeCollectionViewCell else { return DataTypeCollectionViewCell() }
        cell.updateChartView(with: content.dataTypeIdentifier, values: content.value)
        return cell
    }
}
