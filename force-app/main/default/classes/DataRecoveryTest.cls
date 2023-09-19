@isTest
public With Sharing class DataRecoveryTest {

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
    @isTest
    Public static void testuploadZipFile(){
        List<Account> accounts = [select id,name from account limit 10];
        String csvData = 'Name\n';
        for (Account acc : accounts) {
            csvData += acc.Name + '\n';
        }
        
        /*String csv1Content = 'Name,Email\nJohn Doe,john@example.com';
    	String csv2Content = 'Name,Email\nJane Doe,jane@example.com';*/
        
        Zippex sampleZip = new Zippex();
        Blob fileData = Blob.valueOf(csvData);
        sampleZip.addFile('Account.csv', fileData, null);
        Blob zipData = sampleZip.getZipArchive();
       // system.debug('zipData');
        //system.debug(zipData);
        
       /* String base64Data = EncodingUtil.base64Encode(zipData);
        Attachment attach = new Attachment();
        attach.Body = zipData;
        attach.Name ='test Data';
        attach.ParentId = '0015i00000oYvsvAAC';
        insert attach;*/
        //BulkApiQueryExample.testMethods(encodingUtil.base64Encode(zipData));
        BulkApiQueryExample.uploadZipFile(encodingUtil.base64Encode(createZipData()));
    }
    
    @isTest
    static void testPerformInsert(){
        test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new DataRecoveryResponseGenerator());
        Map<String,string> objectsToInsert = new Map<String,string>();
        objectsToInsert.put('objectName','Account');
        objectsToInsert.put('CsvData',encodingUtil.base64Encode(createZipData()));
        
        BulkApiQueryExample.performInsert(JSON.serialize(new List<Map<String,string>>{objectsToInsert}));
        
        test.stopTest();
        
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