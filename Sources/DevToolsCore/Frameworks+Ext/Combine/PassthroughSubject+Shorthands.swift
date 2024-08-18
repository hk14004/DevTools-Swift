import Combine

public extension PassthroughSubject {
    static func just(_ output: Output) -> PassthroughSubject<Output, Failure> {
        let subject = PassthroughSubject()
        subject.send(output)
        return subject
    }
    
    static func fail(_ error: Failure) -> PassthroughSubject<Output, Failure> {
        let subject = PassthroughSubject()
        subject.send(completion: .failure(error))
        return subject
    }
}
