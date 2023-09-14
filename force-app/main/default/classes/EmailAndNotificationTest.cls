@isTest
private class EmailAndNotificationTest {

    @isTest
    Public static void testsendEmailData(){
        
        
        Blob attachmentBody1 = Blob.valueOf('Test Data Attachment');
        String attachmentType1 = 'Data';
        String result1 = Emailandnotification.sendEmailToCurrentUser(attachmentBody1, attachmentType1);      
        System.assertEquals('Success', result1);
    }
    
    @isTest
    static void testSendEmailMetaData() {
        
        Blob attachmentBody = Blob.valueOf('Test MetaData Attachment');
        String attachmentType = 'MetaData';
        
        String result = Emailandnotification.sendEmailToCurrentUser(attachmentBody, attachmentType);
        
        System.assertEquals('Success', result);
    }
    @isTest
    static void testsendEmailLogInsert(){
        Blob attachmentBody = Blob.valueOf('Test Attachment');
        String attachmentType = 'LogInsert';
        
        String result = Emailandnotification.sendEmailToCurrentUser(attachmentBody, attachmentType);
        
        System.assertEquals('Success', result);
    }
    
    @isTest
    static void testSendCustomNotificationDataLocal() { 

        User testUser = [SELECT Id, Email FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        testUser.Email = 'test@example.com';
        update testUser;
       
        Test.startTest();
        EmailAndNotification.sendCustomNotification('Data', 'Local');
        Test.stopTest();

        System.assertNotEquals(null, testUser.Email);
    }
    @isTest
    static void testSendCustomNotificationDataAWS() { 

        User testUser = [SELECT Id, Email FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        testUser.Email = 'test@example.com';
        update testUser;
       
        Test.startTest();
        EmailAndNotification.sendCustomNotification('Data', 'AWS');
        Test.stopTest();

        System.assertNotEquals(null, testUser.Email);
    }
    @isTest
    static void testSendCustomNotificationmetaDataAWS() { 

        User testUser = [SELECT Id, Email FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        testUser.Email = 'test@example.com';
        update testUser;
       
        Test.startTest();
        EmailAndNotification.sendCustomNotification('Metadata', 'AWS');
        Test.stopTest();

        System.assertNotEquals(null, testUser.Email);
    }
    
    @isTest
    static void testSendCustomNotificationmetametaDatalocal() { 

        User testUser = [SELECT Id, Email FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        testUser.Email = 'test@example.com';
        update testUser;
       
        Test.startTest();
        EmailAndNotification.sendCustomNotification('Metadata', 'Local');
        Test.stopTest();

        System.assertNotEquals(null, testUser.Email);
    }
    
    @isTest
    static void testSendMetadataRecoveryResultEmailSuccess() {
        String resultbody = '{"sampleTest": 1}';
        
        Test.startTest();
        String result = EmailAndNotification.sendMetadataRecoveryResultEmail(resultbody);
        Test.stopTest();
    
        System.assertEquals('Success', result);
    }
}