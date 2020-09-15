//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI
import SwiftUICollection

struct Shelf: View {
    typealias Row = CollectionRow<Int, String>
    
    var rows: [Row] = {
        var rows = [Row]()
        for i in 0..<100 {
            rows.append(Row(section: i, items: (0..<40).map { "\(i), \($0)" }))
        }
        return rows
    }()
    
    var body: some View {
        CollectionView(rows: rows) { sectionIndex, layoutEnvironment in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(320), heightDimension: .absolute(180))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 0, bottom: 20, trailing: 0)
            section.interGroupSpacing = 40
            section.orthogonalScrollingBehavior = .continuous
            return section
        } cell: { indexPath, item in
            GeometryReader { geometry in
                Button(action: {}) {
                    Text(item)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .background(Color.blue)
                }
                .buttonStyle(CardButtonStyle())
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(.all)
    }
}

struct Shelf_Previews: PreviewProvider {
    static var previews: some View {
        Shelf()
    }
}
