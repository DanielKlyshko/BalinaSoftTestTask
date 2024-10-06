struct GettingDataModel: Codable {
    let page, pageSize, totalPages, totalElements: Int
    let content: [Content]
}

struct Content: Codable {
    let id: Int
    let name: String
    let image: String?
}

