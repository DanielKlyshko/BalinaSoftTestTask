import UIKit

class MainViewTableViewCell: UITableViewCell {
    
    let someView = UIView()
    let someImage = UIImageView()
    let someID = UILabel()
    let someText = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: "MainViewTableViewCell")
        
        contentView.addSubview(someView)
        someView.addSubview(someImage)
        someView.addSubview(someID)
        someView.addSubview(someText)
        
        setupCellConstraints()
        setupCellUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCellConstraints() {
        
        someView.translatesAutoresizingMaskIntoConstraints = false
        someView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20).isActive = true
        someView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20).isActive = true
        someView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        someView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        
        someImage.translatesAutoresizingMaskIntoConstraints = false
        someImage.topAnchor.constraint(equalTo: someView.topAnchor, constant: 20).isActive = true
        someImage.leadingAnchor.constraint(equalTo: someView.leadingAnchor, constant: 20).isActive = true
        someImage.trailingAnchor.constraint(equalTo: someView.trailingAnchor, constant: -20).isActive = true
        
        someID.translatesAutoresizingMaskIntoConstraints = false
        someID.topAnchor.constraint(equalTo: someImage.bottomAnchor, constant: 10).isActive = true
        someID.leadingAnchor.constraint(equalTo: someView.leadingAnchor, constant: 20).isActive = true
        
        someText.translatesAutoresizingMaskIntoConstraints = false
        someText.topAnchor.constraint(equalTo: someID.bottomAnchor, constant: 10).isActive = true
        someText.bottomAnchor.constraint(equalTo: someView.bottomAnchor, constant: -20).isActive = true
        someText.leadingAnchor.constraint(equalTo: someView.leadingAnchor, constant: 20).isActive = true
        someText.trailingAnchor.constraint(equalTo: someView.trailingAnchor, constant: -20).isActive = true
    }
    
    private func setupCellUI() {
        someView.backgroundColor = .systemGray6
        someView.layer.cornerRadius = 20
    
        someImage.clipsToBounds = true
        someImage.layer.cornerRadius = 18
        someImage.contentMode = .scaleAspectFill
        
        someID.font = UIFont.systemFont(ofSize: 15)
        someID.textColor = .gray
        
        someText.font = UIFont.systemFont(ofSize: 30)
        someID.textColor = .systemBlue
    }
}
