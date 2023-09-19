@isTest
public With sharing class DataRecoveryCalloutTest {
    
    @isTest
    static void testCreateInsertJob(){
        string JSON ='{"id":"7505i00000LlN6kAAF","operation":"insert","object":"Account","createdById":"0055i00000Bc1pjAAB","createdDate":"2023-09-18T06:20:51.000+0000","systemModstamp":"2023-09-18T06:20:51.000+0000","state":"Open","concurrencyMode":"Parallel","contentType":"CSV","apiVersion":58.0,"contentUrl":"services/data/v58.0/jobs/ingest/7505i00000LlN6kAAF/batches","lineEnding":"LF","columnDelimiter":"COMMA"}';
        test.startTest();
        Test.setMock(HttpCalloutMock.class,new DataRecoveryResponseGenerator());
        Map<String,blob> objectsToInsert = new Map<String,blob>();
        objectsToInsert.put('Account',createZipData());
        
        DataRecoveryCallout.createInsertJob(objectsToInsert);
        
        test.stopTest();
    }
    
    
    @testSetup
    static void createTestData(){
        
        try{
            List<Account> accounts = new List<Account>();
            for (Integer i = 0; i < 5; i++)
            {
                Account acc = new Account(Name = 'Test Account ' + i);
                accounts.add(acc);
            }
            insert accounts;
        }
        catch(Exception ex){
            system.debug(ex.getMessage());
        }
        
    }
    
    private static blob createZipData(){
        List<Account> accounts = [select id,name from account limit 10];
        String csvData = 'Name\n';
        for (Account acc : accounts) {
            csvData += acc.Name + '\n';
        }
        
        Zippex sampleZip = new Zippex();
        Blob fileData = Blob.valueOf(csvData);
        sampleZip.addFile('Account.csv', fileData, null);
        Blob zipData = sampleZip.getZipArchive();
        return zipData;
    }
  
}