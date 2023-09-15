import Combine

extension PassthroughSubject {
    public static func just(_ output: Output) -> PassthroughSubject<Output, Failure> {
        let subject = PassthroughSubject()
        subject.send(output)
        return subject
    }
    
    public static func fail(_ error: Failure) -> PassthroughSubject<Output, Failure> {
        let subject = PassthroughSubject()
        subject.send(completion: .failure(error))
        return subject
    }
}
