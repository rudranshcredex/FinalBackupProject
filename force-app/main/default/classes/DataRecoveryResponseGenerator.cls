public class DataRecoveryResponseGenerator implements HttpCalloutMock{
    
    Public HttpResponse respond(HttpRequest req){
        
        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        response.setHeader('Content-Type', 'application/json;charset=UTF-8');
        response.setBody(generatecreateResponse());
        return response;
            
    }
    
    private String generatecreateResponse(){
        return '{"id":"7505i00000LlN6kAAF","operation":"insert","object":"Account","createdById":"0055i00000Bc1pjAAB","createdDate":"2023-09-18T06:20:51.000+0000","systemModstamp":"2023-09-18T06:20:51.000+0000","state":"Open","concurrencyMode":"Parallel","contentType":"CSV","apiVersion":58.0,"contentUrl":"services/data/v58.0/jobs/ingest/7505i00000LlN6kAAF/batches","lineEnding":"LF","columnDelimiter":"COMMA"}';
    } 
}