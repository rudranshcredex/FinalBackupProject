public class mockResponseForDatabackupCallout implements httpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
            
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody(generateResponseForQuery()); 
            return res;
        }
    
    Public static String generateResponseForQuery(){
        return '{"id":"7505i00000Lkbu7AAB","operation":"query","object":"Account","createdById":"0055i00000Bc1pjAAB","createdDate":"2023-09-12T09:54:54.000+0000","systemModstamp":"2023-09-12T09:54:54.000+0000","state":"UploadComplete","concurrencyMode":"Parallel","contentType":"CSV","apiVersion":58.0,"lineEnding":"LF","columnDelimiter":"COMMA"}';
    }

}