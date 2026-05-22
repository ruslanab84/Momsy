import Foundation

enum LoadingState<T> {
    case idle
    case loading
    case loaded(T)
    case error(String)

    var value: T? {
        if case .loaded(let v) = self { return v }
        return nil
    }

    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }

    var errorMessage: String? {
        if case .error(let m) = self { return m }
        return nil
    }
}
