import UIKit

class MainViewController: UIViewController {
    
    private let tableView = UITableView()
    private var contentList: [Content] = []
    private var currentPage = 0
    private var totalPages = 1
    private var selectedContentID: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupTableView()
        loadInitialData()
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MainViewTableViewCell.self, forCellReuseIdentifier: "MainViewTableViewCell")
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }

    private func loadInitialData() {
        currentPage = 0
        contentList.removeAll()
        loadMoreData()
    }
    
    private func loadMoreData() {
        guard currentPage < totalPages else { return }
        
        let urlString = "https://junior.balinasoft.com/api/v2/photo/type?page=\(currentPage)"
        guard let url = URL(string: urlString) else { return }
        
        currentPage += 1
        
        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            if let data = data, let result = try? JSONDecoder().decode(GettingDataModel.self, from: data) {
                DispatchQueue.main.async {
                    self.totalPages = result.totalPages
                    self.contentList.append(contentsOf: result.content)
                    self.tableView.reloadData()
                }
            } else {
                print("Ошибка загрузки данных: \(error?.localizedDescription ?? "Неизвестная ошибка")")
            }
        }
        task.resume()
    }
    
    private func openCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            print("Камера недоступна")
            return
        }
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }

    private func sendPhotoRequest(with image: UIImage) {
        guard let selectedID = selectedContentID else { return }
        let urlString = "https://junior.balinasoft.com/api/v2/photo"
        guard let url = URL(string: urlString) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"typeId\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(selectedID)\r\n".data(using: .utf8)!)

        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"developerName\"\r\n\r\n".data(using: .utf8)!)
        body.append("DanielKlyshko\r\n".data(using: .utf8)!)

        if let imageData = image.jpegData(compressionQuality: 0.8) {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"photo\"; filename=\"photo.jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
        }

        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Ошибка отправки: \(error.localizedDescription)")
                return
            }
            print("Фото успешно отправлено")
            DispatchQueue.main.async {
                self.showSuccessAlert()
            }
        }
        task.resume()
    }
    
    private func showSuccessAlert() {
        let alert = UIAlertController(title: "Успех", message: "Фото и данные успешно отправлены!", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "ОК", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedContent = contentList[indexPath.row]
        selectedContentID = selectedContent.id
        openCamera()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let originalImage = info[.originalImage] as? UIImage {
            sendPhotoRequest(with: originalImage)
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contentList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MainViewTableViewCell", for: indexPath) as! MainViewTableViewCell
        let content = contentList[indexPath.row]
        cell.someID.text = "\(content.id)"
        cell.someText.text = content.name
        
        if let imageUrl = content.image, let url = URL(string: imageUrl) {
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        cell.someImage.image = image
                    }
                }
            }.resume()
        }
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if offsetY > contentHeight - scrollView.frame.height - 100 {
            loadMoreData()
        }
    }
}
