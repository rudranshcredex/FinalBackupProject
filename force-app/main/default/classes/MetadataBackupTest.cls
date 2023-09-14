@isTest
public With Sharing class MetadataBackupTest {

    Private static String AsyncResultId ='09S5i00000DWAYfEAP';
    //OBJECT TT = { accessKey: 'AKIAXBC2OOIM4NKWKX4D', SecretKey: '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', Bucket: 'buctest143', awsRegion: 'eu-north-1', backupTos3: false, backupToLocal: true };
    //Private static String  Credentials=  JSON.serialize();
    Private static String Credentials = '{ "accessKey": "abc", "SecretKey": "abc", "Bucket": "abc", "awsRegion": "abc", "backupTos3": false, "backupToLocal": true }';
    @isTest
    static void testRetrieveMetadata(){
        test.startTest();
            Test.setMock(HttpCalloutMock.class, new MetadataBackupResponseGenerator('retrieve'));
            MetadataBackup.retrieveMetadata(new List<String>{'CustomLabel'},'credentials');
        test.stopTest();
    }
    
    @isTest
    static void testCheckRetrieveStatus(){
        test.startTest();
            Test.setMock(HttpCalloutMock.class, new MetadataBackupResponseGenerator('checkRetrieveStatus'));
            MetadataBackup.CheckRetrieveStatus(AsyncResultId,Credentials);
        test.stopTest();
    }
    
    
}