//
//  SCQuestionTableViewCell.swift
//  StackoverflowClient
//
//  Created by Anugheerthi E S on 17/11/19.
//  Copyright © 2019 Anugheerthi E S. All rights reserved.
//

import UIKit

protocol SCQuestionTableViewCellDelegate: NSObjectProtocol {
    func pushToQuestionVCOnTagPress(_ tag: String)
}

class SCQuestionTableViewCell: UITableViewCell {

    private enum Constants {
        static let spacing: CGFloat = 10
        static let tagCellReuseID = "TagCell"
    }
    
    @IBOutlet weak var questionTitleLabel: UILabel!
    @IBOutlet weak var upvoteLabel: UILabel!
    @IBOutlet weak var upvoteWrapperView: UIView!
    @IBOutlet weak var timestampWithPosterNameLabel: UILabel!
    @IBOutlet weak var tagsCollectionView: UICollectionView!
    @IBOutlet weak var tagsCVHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var tagsCVFlowLayout: UICollectionViewFlowLayout! {
        didSet {
            tagsCVFlowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        }
    }
    
    var delegate: SCQuestionTableViewCellDelegate? = nil
    
    private var cellViewModel: SCQuestionCellViewModel? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tagsCollectionViewConfigure()
    }
    
    func configureQuestionCell(_ cellViewModel: SCQuestionCellViewModel) {
        self.cellViewModel = cellViewModel
        questionTitleLabel.text = cellViewModel.questionTitle
        upvoteLabel.text = cellViewModel.upvoteCount
        timestampWithPosterNameLabel.text = cellViewModel.timestampWithPosterName
        upvoteWrapperView.layer.cornerRadius = upvoteWrapperView.frame.height / 2
        tagsCollectionView.reloadData()
        tagsCVHeightConstraint.constant = tagsCollectionView.collectionViewLayout.collectionViewContentSize.height
    }
    
    private func tagsCollectionViewConfigure() {
        tagsCollectionView.dataSource = self
        tagsCollectionView.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension SCQuestionTableViewCell: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        cellViewModel?.tags.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let tagCell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.tagCellReuseID, for: indexPath) as? SCTagCollectionViewCell, let tags = cellViewModel?.tags else {
            return UICollectionViewCell()
        }
        tagCell.config(tags[indexPath.item])
        tagCell.maxWidth = collectionView.bounds.width - Constants.spacing
        
        return tagCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let tag = cellViewModel?.tags[indexPath.row] else {
            return
        }
        delegate?.pushToQuestionVCOnTagPress(tag)
    }
    
//    override func systemLayoutSizeFitting(_ targetSize: CGSize) -> CGSize {
//        tagsCollectionView.frame = .init(origin: .zero, size: CGSize(width: targetSize.width, height: CGFloat(MAXFLOAT)))
//        tagsCollectionView.layoutIfNeeded()
//
//        return tagsCollectionView.collectionViewLayout.collectionViewContentSize
//    }
    
}
