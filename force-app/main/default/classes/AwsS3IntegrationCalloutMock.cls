@isTest
global class AwsS3IntegrationCalloutMock implements HttpCalloutMock {
    Private string scenario;
    
    Public AwsS3IntegrationCalloutMock(String scenario){
        this.scenario = scenario;
    } 

    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse responseToTestClass;
        if(scenario == 'BucketsSuccess'){
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/xml');
            response.setBody('<ListAllMyBucketsResult xmlns="http://s3.amazonaws.com/doc/2006-03-01/"><Owner><ID>37f07ca52f79222310c73895c053a2c64c68cb7ce648adf74aec37b707b8f281</ID></Owner><Buckets><Bucket><Name>buctest143</Name><CreationDate>2023-05-25T09:30:23.000Z</CreationDate></Bucket><Bucket><Name>createtestbuk</Name><CreationDate>2023-06-20T10:40:30.000Z</CreationDate></Bucket></Buckets></ListAllMyBucketsResult>');
            response.setStatusCode(200);
            responseToTestClass = response;   
        }
        if(scenario == 'BucketsError'){
            HttpResponse response = new HttpResponse();
            //response.setHeader('Content-Type', 'application/xml');
            response.setBody('Internal Server Error');
            response.setStatusCode(500);
            responseToTestClass = response;   
        }
        
        if(scenario == 'FilesSuccess'){
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/xml');
            response.setBody('<ListBucketResult xmlns="http://s3.amazonaws.com/doc/2006-03-01/"><Name>createtestbuk</Name><Prefix></Prefix><Marker></Marker><MaxKeys>1000</MaxKeys><IsTruncated>false</IsTruncated><Contents><Key>Account.csv</Key><LastModified>2023-07-20T12:19:08.000Z</LastModified><ETag>&quot;f096aaa052f5691853b20dffea9c6e79&quot;</ETag><Size>17585</Size><Owner><ID>37f07ca52f79222310c73895c053a2c64c68cb7ce648adf74aec37b707b8f281</ID></Owner><StorageClass>STANDARD</StorageClass></Contents><Contents><Key>Case.csv</Key><LastModified>2023-07-18T12:56:19.000Z</LastModified><ETag>&quot;1856a92bccddfef3eba413aca41a58c8&quot;</ETag><Size>8663</Size><Owner><ID>37f07ca52f79222310c73895c053a2c64c68cb7ce648adf74aec37b707b8f281</ID></Owner><StorageClass>STANDARD</StorageClass></Contents><Contents><Key>Contact.csv</Key><LastModified>2023-07-19T10:03:56.000Z</LastModified><ETag>&quot;997581ccd79ee75db6514192960e957c&quot;</ETag><Size>23066</Size><Owner><ID>37f07ca52f79222310c73895c053a2c64c68cb7ce648adf74aec37b707b8f281</ID></Owner><StorageClass>STANDARD</StorageClass></Contents><Contents><Key>CredexData.csv</Key><LastModified>2023-07-18T12:37:48.000Z</LastModified><ETag>&quot;7c985e5d67867561319e6d9b53fd3f96&quot;</ETag><Size>14949</Size><Owner><ID>37f07ca52f79222310c73895c053a2c64c68cb7ce648adf74aec37b707b8f281</ID></Owner><StorageClass>STANDARD</StorageClass></Contents><Contents><Key>CredexData2.csv</Key><LastModified>2023-07-18T12:51:47.000Z</LastModified><ETag>&quot;7c985e5d67867561319e6d9b53fd3f96&quot;</ETag><Size>14949</Size><Owner><ID>37f07ca52f79222310c73895c053a2c64c68cb7ce648adf74aec37b707b8f281</ID></Owner><StorageClass>STANDARD</StorageClass></Contents><Contents><Key>OaxSchedule_00D5j000001uCc3EAE_not_enc-(Job-17613285)-20230614-101641.zip</Key><LastModified>2023-06-15T07:00:59.000Z</LastModified><ETag>&quot;507913a934401c6641a32dd3b43205d9&quot;</ETag><Size>2683966</Size><Owner><ID>37f07ca52f79222310c73895c053a2c64c68cb7ce648adf74aec37b707b8f281</ID></Owner><StorageClass>STANDARD</StorageClass></Contents><Contents><Key>Task.csv</Key><LastModified>2023-07-19T05:05:59.000Z</LastModified><ETag>&quot;68b329da9893e34099c7d8ad5cb9c940&quot;</ETag><Size>1</Size><Owner><ID>37f07ca52f79222310c73895c053a2c64c68cb7ce648adf74aec37b707b8f281</ID></Owner><StorageClass>STANDARD</StorageClass></Contents><Contents><Key>credex.csv</Key><LastModified>2023-07-09T15:35:16.000Z</LastModified><ETag>&quot;d41d8cd98f00b204e9800998ecf8427e&quot;</ETag><Size>0</Size><Owner><ID>37f07ca52f79222310c73895c053a2c64c68cb7ce648adf74aec37b707b8f281</ID></Owner><StorageClass>STANDARD</StorageClass></Contents><Contents><Key>example (1).zip</Key><LastModified>2023-07-24T06:58:38.000Z</LastModified><ETag>&quot;f62e269472a8e094b98bcdd1e1fc0986&quot;</ETag><Size>432</Size><Owner><ID>37f07ca52f79222310c73895c053a2c64c68cb7ce648adf74aec37b707b8f281</ID></Owner><StorageClass>STANDARD</StorageClass></Contents><Contents><Key>signature.jpg</Key><LastModified>2023-08-05T08:07:06.000Z</LastModified><ETag>&quot;af4cbf2d5f6cb613260811dae3e2d002&quot;</ETag><Size>54490</Size><Owner><ID>37f07ca52f79222310c73895c053a2c64c68cb7ce648adf74aec37b707b8f281</ID></Owner><StorageClass>STANDARD</StorageClass></Contents><Contents><Key>test.csv</Key><LastModified>2023-07-06T16:37:47.000Z</LastModified><ETag>&quot;88f4940cf866119372fa05bc65830e85&quot;</ETag><Size>12002</Size><Owner><ID>37f07ca52f79222310c73895c053a2c64c68cb7ce648adf74aec37b707b8f281</ID></Owner><StorageClass>STANDARD</StorageClass></Contents><Contents><Key>test.zip</Key><LastModified>2023-07-24T15:38:29.000Z</LastModified><ETag>&quot;28193ddf4d7b224e0ac196b09a2ab725&quot;</ETag><Size>8</Size><Owner><ID>37f07ca52f79222310c73895c053a2c64c68cb7ce648adf74aec37b707b8f281</ID></Owner><StorageClass>STANDARD</StorageClass></Contents><Contents><Key>testData.zip</Key><LastModified>2023-07-24T15:50:49.000Z</LastModified><ETag>&quot;99914b932bd37a50b983c5e7c90ae93b&quot;</ETag><Size>2</Size><Owner><ID>37f07ca52f79222310c73895c053a2c64c68cb7ce648adf74aec37b707b8f281</ID></Owner><StorageClass>STANDARD</StorageClass></Contents><Contents><Key>testData4.zip</Key><LastModified>2023-07-31T07:59:08.000Z</LastModified><ETag>&quot;e8f5354f65b17a1f4ecab696845cb26f&quot;</ETag><Size>130</Size><Owner><ID>37f07ca52f79222310c73895c053a2c64c68cb7ce648adf74aec37b707b8f281</ID></Owner><StorageClass>STANDARD</StorageClass></Contents><Contents><Key>testDataToday.zip</Key><LastModified>2023-07-28T12:09:01.000Z</LastModified><ETag>&quot;99914b932bd37a50b983c5e7c90ae93b&quot;</ETag><Size>2</Size><Owner><ID>37f07ca52f79222310c73895c053a2c64c68cb7ce648adf74aec37b707b8f281</ID></Owner><StorageClass>STANDARD</StorageClass></Contents><Contents><Key>testDataYes.zip</Key><LastModified>2023-07-29T10:44:38.000Z</LastModified><ETag>&quot;9b2e25a2113bd7e19db497382a5014c4&quot;</ETag><Size>17845</Size><Owner><ID>37f07ca52f79222310c73895c053a2c64c68cb7ce648adf74aec37b707b8f281</ID></Owner><StorageClass>STANDARD</StorageClass></Contents><Contents><Key>testDataYes2.zip</Key><LastModified>2023-07-29T10:51:14.000Z</LastModified><ETag>&quot;7ba99a423db44e77bb8eaf034d4c77d8&quot;</ETag><Size>17845</Size><Owner><ID>37f07ca52f79222310c73895c053a2c64c68cb7ce648adf74aec37b707b8f281</ID></Owner><StorageClass>STANDARD</StorageClass></Contents><Contents><Key>testDataYes3.zip</Key><LastModified>2023-07-29T10:56:44.000Z</LastModified><ETag>&quot;f247322a2f1c31993b4002245282553d&quot;</ETag><Size>17845</Size><Owner><ID>37f07ca52f79222310c73895c053a2c64c68cb7ce648adf74aec37b707b8f281</ID></Owner><StorageClass>STANDARD</StorageClass></Contents></ListBucketResult>');
            response.setStatusCode(200);
            responseToTestClass = response;
        }
        
        //if(scenario == 'FilesError'){
            
        //}
        
        if(scenario == 'awsS3Integration'){
            httpResponse response = new httpResponse();
            
            response.setBody('');
             
            response.setStatusCode(200);
            responseToTestClass = response;
        }
        
        return responseToTestClass;
    }
}