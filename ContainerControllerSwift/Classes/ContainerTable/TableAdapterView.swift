//
//  BlockTableView.swift
//  PatternsSwift
//
//  Created by Рустам Мотыгуллин on 16/04/2020.
//  Copyright © 2020 mrusta. All rights reserved.
//

import UIKit

class TableAdapterView: UITableView {
    
    @IBInspectable var separatorClr: UIColor?
    
    var countCallback: TableAdapterCountCallback?
    var cellIndexCallback: TableAdapterCellIndexCallback?
    var heightIndexCallback: TableAdapterHeightIndexCallback?
    var selectIndexCallback: TableAdapterSelectIndexCallback?
    var deleteIndexCallback: TableAdapterDeleteIndexCallback?
    var didScrollCallback: TableAdapterDidScrollCallback?
    
    
    var items: [TableAdapterItem] = []
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        update()
    }
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        update()
    }
    
    override func draw(_ rect: CGRect) {
        if let color = separatorClr {
            separatorColor = color
        }
    }
    
    func update() {
        delegate = self
        dataSource = self
        
        tableFooterView = UIView()
        backgroundColor = .clear
    }
    
    func set(items: [TableAdapterItem], animated: Bool = false, reload: Bool = true) {
        self.clear()
        items.forEach {
            self.unsafeAdd(item: $0)
            // $0.cellHandler?.delegate = self
        }
        if reload { reloadData(animated: animated) }
    }
    
    public func clear() {
        items.removeAll()
    }
    
    public func reloadData(animated: Bool = false) {
        if animated {
            self.reloadSections(IndexSet(integer: 0), with: .automatic)
        } else {
            self.reloadData()
        }
    }
    

    public func scrollToTop() {
        self.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
    
    public func unsafeAdd(item: TableAdapterItem) {
        items.append(item)
        registerNibIfNeeded(for: item)
    }
    
    public func registerNibIfNeeded(for item: TableAdapterItem) {
        let nib = UINib(nibName: item.cellReuseIdentifier, bundle: nil)
        self.register(nib, forCellReuseIdentifier: item.cellReuseIdentifier)
    }
    
    
    private func cellAt(_ indexPath: IndexPath) -> TableAdapterCell? {
        let item = items[indexPath.row]
        let cellIdentifier = item.cellReuseIdentifier
        let cell = self.dequeueReusableCell(withIdentifier: cellIdentifier) as? TableAdapterCell
        cell?.cellData = item.cellData
        return cell
    }
}

// MARK: DataSource

extension TableAdapterView: UITableViewDataSource {
    
    /// колличество
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !items.isEmpty {
            return items.count
        }
        if let countCallback = countCallback {
            return countCallback()
        }
        return 0
    }
    
    /// ячейка
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if !items.isEmpty {
            let item = items[indexPath.row]
            let cell = cellAt(indexPath)
            cell?.fill(data: item.cellData)
            return cell ?? UITableViewCell()
        }
        if let cellIndexCallback = cellIndexCallback {
            return cellIndexCallback(indexPath.row)
        }
        return UITableViewCell()
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if !items.isEmpty {
            let item = items[indexPath.row]
            return item.canEditing()
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            items.remove(at: indexPath.row)
            self.beginUpdates()
            self.deleteRows(at: [indexPath], with: .automatic)
            self.endUpdates()
            
            deleteIndexCallback?(indexPath.row)
        }
    }
}

// MARK: Delegate

extension TableAdapterView: UITableViewDelegate {
    
    /// высота
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if !items.isEmpty {
            return items[indexPath.row].height()
        }
        if let heightIndexCallback = heightIndexCallback {
            return heightIndexCallback(indexPath.row)
        }
        return 0
    }
    
    /// нажал
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectIndexCallback?(indexPath.row)
    }
    
}

extension TableAdapterView: UIScrollViewDelegate {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        didScrollCallback?()
    }
    
    
}
