//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

extension UIHostingController {
    convenience public init(rootView: Content, ignoreSafeArea: Bool) {
        self.init(rootView: rootView)
        
        if ignoreSafeArea {
            disableSafeArea()
        }
    }
    
    func disableSafeArea() {
        guard let viewClass = object_getClass(view) else { return }
        
        let viewSubclassName = String(cString: class_getName(viewClass)).appending("_IgnoreSafeArea")
        if let viewSubclass = NSClassFromString(viewSubclassName) {
            object_setClass(view, viewSubclass)
        }
        else {
            guard let viewClassNameUtf8 = (viewSubclassName as NSString).utf8String else { return }
            guard let viewSubclass = objc_allocateClassPair(viewClass, viewClassNameUtf8, 0) else { return }
            
            if let method = class_getInstanceMethod(UIView.self, #selector(getter: UIView.safeAreaInsets)) {
                let safeAreaInsets: @convention(block) (AnyObject) -> UIEdgeInsets = { _ in
                    return .zero
                }
                class_addMethod(viewSubclass, #selector(getter: UIView.safeAreaInsets), imp_implementationWithBlock(safeAreaInsets), method_getTypeEncoding(method))
            }
            
            objc_registerClassPair(viewSubclass)
            object_setClass(view, viewSubclass)
        }
    }
}

public struct CollectionRow<Section: Hashable, Item: Hashable>: Hashable {
    let section: Section
    let items: [Item]
    
    public init(section: Section, items: [Item]) {
        self.section = section
        self.items = items
    }
}

public struct CollectionView<Section: Hashable, Item: Hashable, Cell: View>: UIViewRepresentable {
    private class HostCell: UICollectionViewCell {
        private var hostController: UIHostingController<Cell>?
        
        override func prepareForReuse() {
            if let hostView = hostController?.view {
                hostView.removeFromSuperview()
            }
            hostController = nil
        }
        
        var hostedCell: Cell? {
            willSet {
                guard let view = newValue else { return }
                hostController = UIHostingController(rootView: view, ignoreSafeArea: true)
                if let hostView = hostController?.view {
                    hostView.frame = contentView.bounds
                    hostView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                    contentView.addSubview(hostView)
                }
            }
        }
    }
    
    public class Coordinator: NSObject, UICollectionViewDelegate {
        fileprivate typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
        
        fileprivate var dataSource: DataSource? = nil
        fileprivate var sectionLayoutProvider: ((Int, NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection)?
        fileprivate var rowsHash: Int? = nil
        fileprivate var isFocusable: Bool = false
        
        public func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> Bool {
            return isFocusable
        }
    }
    
    let rows: [CollectionRow<Section, Item>]
    let sectionLayoutProvider: (Int, NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection
    let cell: (IndexPath, Item) -> Cell
    
    public init(rows: [CollectionRow<Section, Item>],
         sectionLayoutProvider: @escaping (Int, NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection,
         @ViewBuilder cell: @escaping (IndexPath, Item) -> Cell) {
        self.rows = rows
        self.sectionLayoutProvider = sectionLayoutProvider
        self.cell = cell
    }
    
    private func layout(context: Context) -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            return context.coordinator.sectionLayoutProvider!(sectionIndex, layoutEnvironment)
        }
    }
    
    private func snapshot() -> NSDiffableDataSourceSnapshot<Section, Item> {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        for row in rows {
            snapshot.appendSections([row.section])
            snapshot.appendItems(row.items, toSection: row.section)
        }
        return snapshot
    }
    
    private func reloadData(in collectionView: UICollectionView, context: Context, animated: Bool = false) {
        let coordinator = context.coordinator
        coordinator.sectionLayoutProvider = self.sectionLayoutProvider
        
        guard let dataSource = coordinator.dataSource else { return }
        
        let rowsHash = rows.hashValue
        if coordinator.rowsHash != rowsHash {
            dataSource.apply(snapshot(), animatingDifferences: animated) {
                coordinator.isFocusable = true
                collectionView.setNeedsFocusUpdate()
                collectionView.updateFocusIfNeeded()
                coordinator.isFocusable = false
            }
            coordinator.rowsHash = rowsHash
        }
    }
    
    public func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
    
    public func makeUIView(context: Context) -> UICollectionView {
        let cellIdentifier = "hostCell"
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout(context: context))
        collectionView.delegate = context.coordinator
        collectionView.register(HostCell.self, forCellWithReuseIdentifier: cellIdentifier)
        
        context.coordinator.dataSource = Coordinator.DataSource(collectionView: collectionView) { collectionView, indexPath, item in
            let hostCell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? HostCell
            hostCell?.hostedCell = cell(indexPath, item)
            return hostCell
        }
        
        reloadData(in: collectionView, context: context)
        return collectionView
    }
    
    public func updateUIView(_ uiView: UICollectionView, context: Context) {
        reloadData(in: uiView, context: context, animated: true)
    }
}
