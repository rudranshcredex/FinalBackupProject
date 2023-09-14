@isTest
public WITH SHARING class AwsS3IntegrationTest {

    @isTest
    static void testS3Buckets(){
            Test.setMock(HttpCalloutMock.class, new AwsS3IntegrationCalloutMock('BucketsSuccess')); 
        	test.startTest();
        	List<String> buckets = AwsS3Integration.getBuckets('access', 'secretKey', 'north-1');
        	test.stopTest();
        	//system.assert(buckets.size());
        	system.assertEquals(2, buckets.size());
    }
    
    @isTest
    static void testS3BucketsWithErrors(){
            Test.setMock(HttpCalloutMock.class, new AwsS3IntegrationCalloutMock('BucketsError')); 
        	test.startTest();
        	List<String> buckets = AwsS3Integration.getBuckets('access', 'secretKey', 'north-1');
        	test.stopTest();
        	//system.assert(buckets.size());
        	system.assertEquals(0, buckets.size());
    }
    
    @isTest
    static void getFiles(){
        Test.setMock(HttpCalloutMock.class, new AwsS3IntegrationCalloutMock('FilesSuccess')); 
        	test.startTest();
        	List<String> files = AwsS3Integration.getFiles('access', 'secretKey', 'north-1','bucket');
        	test.stopTest();
        	system.assertEquals(18, files.size());
    }
    
 /* @istest
    static void testCreateAuthHeaderForFileKey(){
    String fileKey = 'exampleFileKey';
    String formattedDateString = '20230913T123456Z'; 
    String longDate = '20230913T123456Z'; 
    String dateStamp = '20230913'; 
    String methodName = 'GET'; 
    String bucketName = 'exampleBucketName'; 
    String RegionName = 'us-east-1'; 
    String algorithm = 'AWS4-HMAC-SHA256'; 
    String awsSecret = 'yourSecretKey'; 
    String awsKey = 'yourAccessKey'; 
        
        test.startTest();
        string actual = awsS3Integration.CreateAuthHeaderForFileKey(filekey, formattedDateString, longDate, dateStamp);
        test.stopTest();
        
        string expected = '';    
}*/
    /*@istest
    static void testGetFile(){
        string accessKey='AKIAXBC2OOIM4NKWKX4D';
        String secretKey = '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';
        String awsRegion = 'eu-north-1';
        String bucket = 'buctest143';
        string filekey = 'testdata1';
        
        Test.setMock(HttpCalloutMock.class, new AwsS3IntegrationMockResponse()); 
        test.startTest();
        string filedata = awsS3integration.getFile(accessKey, secretKey, awsRegion, bucket, FileKey);
        test.stopTest();
        
        System.assertEquals(null, fileData); 
    }*/
    
  /*  @isTest
    static void testgetSessionId(){
        
        test.startTest();
        string actual = awsS3Integration.getSessionId();
        test.stopTest();
        
        system.assertEquals('', actual);
        
    }
    @istest
    static void testgetBuckets(){
        
        string accessKey='AKIAXBC2OOIM4NKWKX4D';
        String secretKey='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';
        String awsRegion='eu-north-1';
        string bucket = 'buctest143';
        string filekey = 'salesforcemetadata_2023-09-08.zip';
              
        test.startTest();
        string response = awsS3Integration.getFile(accessKey, secretkey, awsRegion, bucket, filekey);
		test.stopTest();
        
    }
    @isTest
    static void testCreateRemoteSite() {
        
        String fullName = 'test101';
        String url = 'https://test.com';
        String description = 'test remote site';
        
        test.startTest();
        awsS3integration.createRemoteSite(fullName, url, description);
        test.stopTest();
              
    }*/
    


    @isTest
    static void testFilePUT() {
        
        String fileName = 'TestFile.zip';
        String accessKey = 'access-key';
        String secretKey = 'secret-key';
        String awsRegion = 'aws-region';
        String bucket = 'bucket-name';
        Blob zipData = Blob.valueOf('Test zip data'); 
        
        
        Test.setMock(HttpCalloutMock.class, new AwsS3IntegrationCalloutMock('awsS3Integration'));
        test.starttest();
        string result = awsS3Integration.filePUT(fileName, accessKey, secretKey, awsRegion, bucket, zipData);
        test.stoptest();
        
        system.assertEquals('success', result);

    }
}