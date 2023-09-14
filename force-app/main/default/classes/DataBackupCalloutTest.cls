@isTest
private class DataBackupCalloutTest {
	@isTest
    private static void testGetQueryObject(){
        
        List<String> objectApiNames = new List<String>{'Account'};
        String batchName = 'Batch';
        String fromDate = '2023-09-12';
        String toDate = '2023-09-12';
        
        Test.setMock(HttpCalloutMock.class,new mockResponseForDatabackupCallout());
        test.starttest();
        databackupcallout.getQueryJobIds(objectApiNames, 'batchName', null, null);
        test.stoptest();
        //System.assertEquals(1, [SELECT COUNT() FROM CronTrigger limit 1]);
    } 
    @isTest
    private static void testGetJobResults() {
        // Create test data as needed
        Map<String, String> objectWithJobIds = new Map<String, String>();
        objectWithJobIds.put('Object1', 'JobId1');
        objectWithJobIds.put('Object2', 'JobId2');
        objectWithJobIds.put('Object3', 'JobId3');
     
        String batchname = 'batch';
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new mockResponseForDatabackupCallout());
        DataBackupCallout.getJobResults(objectWithJobIds, batchname);
        Test.stopTest();
        
        
        Integer actual = [select count() from contentversion where title = 'batch'];
        Integer expected = 1;
        
        System.assertEquals(expected, actual);
    }
    
@isTest
static void testReadZipFiles() {
    Map<String, Object> testCredentials = new Map<String, Object>{
        'accessKey' => 'AccessKey',
        'SecretKey' => 'SecretKey',
        'Bucket' => 'Bucket',
        'awsRegion' => 'AwsRegion',
        'backupTos3' => false,
        'backupToLocal' => true
    };
    List<String> fileNames = new List<String>{ 'File1.txt', 'File2.txt' };
    String credentials = JSON.serialize(testCredentials);
	
    Blob attachmentBody = Blob.valueOf('test data');
    Account testAccount1 = new Account(Name = 'Test Account 1');
    insert testAccount1;
    
    ContentVersion testVersion1 = new ContentVersion();
    testVersion1.VersionData = Blob.valueOf('Test file content 1');
    testVersion1.PathOnClient = 'File1.txt';

    insert testVersion1;

    Test.startTest();
    DataBackupCallout.readZipFiles(fileNames, credentials);
    
    Test.stopTest();

    List<ContentDocument> deletedContentDocuments = [SELECT Id FROM ContentDocument WHERE Id IN :new Set<Id>{testVersion1.ContentDocumentId}];

    System.assertEquals(0, deletedContentDocuments.size());
}
    
    @istest
    private static void testReadZipFilesCustomNotification(){
        Map<String, Object> testCredentials = new Map<String, Object>{
        'accessKey' => 'AccessKey',
        'SecretKey' => 'SecretKey',
        'Bucket' => 'Bucket',
        'awsRegion' => 'AwsRegion',
        'backupTos3' => false,
        'backupToLocal' => true
    };
    List<String> fileNames = new List<String>{ 'File1.txt', 'File2.txt' };
    String credentials = JSON.serialize(testCredentials);
	
    Blob attachmentBody = Blob.valueOf('test data');
    Account testAccount1 = new Account(Name = 'Test Account 1');
    insert testAccount1;
    
    ContentVersion testVersion1 = new ContentVersion();
    testVersion1.VersionData = Blob.valueOf('Test file content 1');
    testVersion1.PathOnClient = 'File1.txt';

    insert testVersion1;

    Test.startTest();
    DataBackupCallout.readZipFiles(fileNames, credentials);
    Test.stopTest();
	
       // CustomNotificationtype customNotification = new customenotificationType(){id = '12313123123'};
      //  system.assertEquals(1, [select count() from CustomNotificationtype where id:= customNotification.id]);
    
   
    string emailStatus = emailandNotification.sendEmailToCurrentUser(attachmentBody, 'Data');
    
	System.assertEquals('Success', emailStatus);

    }
    @isTest
    private static void testReadZipFilesCustomNotificationforS3(){
        Map<String, Object> testCredentials = new Map<String, Object>{
        'accessKey' => 'AccessKey',
        'SecretKey' => 'SecretKey',
        'Bucket' => 'Bucket',
        'awsRegion' => 'AwsRegion',
        'backupTos3' => true,
        'backupToLocal' => false
    };
    List<String> fileNames = new List<String>{ 'File1.txt', 'File2.txt' };
    String credentials = JSON.serialize(testCredentials);
	
    Blob attachmentBody = Blob.valueOf('test data');
    Account testAccount1 = new Account(Name = 'Test Account 1');
    insert testAccount1;
    
    ContentVersion testVersion1 = new ContentVersion();
    testVersion1.VersionData = Blob.valueOf('Test file content 1');
    testVersion1.PathOnClient = 'File1.txt';

    insert testVersion1;

    Test.startTest();
    Test.setMock(HttpCalloutMock.class,new mockFilePutResponse());
    DataBackupCallout.readZipFiles(fileNames, credentials);
    Test.stopTest();
	
       // CustomNotificationtype customNotification = new customenotificationType(){id = '12313123123'};
      //  system.assertEquals(1, [select count() from CustomNotificationtype whexre id:= customNotification.id]);
    
   
    
    string response = awsS3Integration.filePUT('abc', 'AccessKey', 'SecretKey', 'Bucket', 'AwsRegion', attachmentBody);
    
	System.assertEquals('success', response);

    }
}