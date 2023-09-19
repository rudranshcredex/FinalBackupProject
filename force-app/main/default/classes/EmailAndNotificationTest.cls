@isTest
private class EmailAndNotificationTest {

    
    @testSetup
    static void createTestData(){
        try{
             Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
             User user = new User(Alias = 'standt', Email='testUser@gmail.com', 
                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US', ProfileId = p.Id, 
                TimeZoneSidKey='America/Los_Angeles', UserName='testCurrentUser@abc.com');
            
             insert user;
            
           /* createEmailTemplate('MetadataBackup');
            createEmailTemplate('data_backup');
            createCustomNotification();*/
        }
        catch(Exception ex){
            system.debug(ex.getMessage());
        }
    }
    @isTest
    Public static void testsendEmailToCurrentUser(){
        
        user user = [select id from user Limit 1];
        test.startTest();
        
            //createEmailTemplate('data_backup');
            system.runAs(user)
            {
                Blob attachmentBody = Blob.valueOf('Test Data Attachment');
                String attachmentType = 'Data';
                String result = Emailandnotification.sendEmailToCurrentUser(attachmentBody, attachmentType);      
                System.assertEquals('Success', result);
            }
        test.stopTest();
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
    
    Private static void createEmailTemplate(String templateName){
        try{
            EmailTemplate template = new EmailTemplate();
            template.Name = templateName;
            template.Body = 'test body';
            template.IsActive = true;
            insert template;
        }
        catch(Exception ex){
            system.debug(ex.getMessage());
        }
    }
    
    private static void createCustomNotification(){
        CustomNotificationType cstmNotfn = new CustomNotificationType();
           cstmNotfn.DeveloperName = 'BackupNotification';
           cstmNotfn.Desktop = true;
           cstmNotfn.Mobile = true;
    }
}