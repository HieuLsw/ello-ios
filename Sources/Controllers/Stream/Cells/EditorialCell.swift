////
///  EditorialCell.swift
//

import SnapKit


class EditorialCell: UICollectionViewCell {

    struct Size {
        static let aspect: CGFloat = 1
        static let topMargin: CGFloat = 54
        static let smallTopMargin: CGFloat = 48
        static let defaultMargin: CGFloat = 40
        static let textFieldMargin: CGFloat = 10
        static let arrowMargin: CGFloat = 17
        static let subtitleButtonMargin: CGFloat = 36
        static let bgMargins = UIEdgeInsets(bottom: 1)
        static let buttonsMargin: CGFloat = 30
    }

    struct Config {
        var title: String?
        var subtitle: String?
        init() {}
    }

    var config = Config() {
        didSet {
            updateConfig()
        }
    }

    fileprivate let bg = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        style()
        bindActions()
        arrange()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func style() {
        bg.backgroundColor = .black
    }

    func bindActions() {
    }

    func updateConfig() {
    }

    func arrange() {
        contentView.addSubview(bg)

        bg.snp.makeConstraints { make in
            make.edges.equalTo(contentView).inset(Size.bgMargins)
        }
    }

}

extension EditorialCell {
    override func prepareForReuse() {
        config = Config()
    }
}


extension Editorial.Kind {
    var reuseIdentifier: String {
        switch self {
        case .post: return "EditorialPostCell"
        case .external: return "EditorialExternalCell"
        case .postStream: return "EditorialPostStreamCell"
        case .invite: return "EditorialInviteCell"
        case .join: return "EditorialJoinCell"
        }
    }

    var classType: UICollectionViewCell.Type {
        switch self {
        case .post: return EditorialPostCell.self
        case .external: return EditorialExternalCell.self
        case .postStream: return EditorialPostStreamCell.self
        case .invite: return EditorialInviteCell.self
        case .join: return EditorialJoinCell.self
        }
    }
}
