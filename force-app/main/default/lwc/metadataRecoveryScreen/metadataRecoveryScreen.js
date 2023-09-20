import { LightningElement, wire } from "lwc";
import local from "@salesforce/resourceUrl/LocalBackup";
import cloud from "@salesforce/resourceUrl/cloud";
import { getRecord } from "lightning/uiRecordApi";
import USER_ID from "@salesforce/user/Id";
import NAME_FIELD from "@salesforce/schema/User.Name";
import EMAIL_FIELD from "@salesforce/schema/User.Email";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import deployMetadata from '@salesforce/apex/MetadataRecovery.deployMetadata';
export default class MetadataRecoveryScreen extends LightningElement {
  recoveryAwsText = "Your data recovery from AWS is now in the queue and will be processed shortly. We're working diligently to ensure that your requested data is recovered accurately and securely.";
  lowertext = "You will receive an email notification once the recovery is completed, along with a custom notification .";
  recoveryLocaltext = "Your data recovery is now in the queue and will be processed shortly. We're working diligently to ensure that your requested data is recovered accurately and securely.";

  userEmail;
  local = local;
  cloud = cloud;
  date = Date();
  file;
  objectScreen = false;
  showScreen1 = true;
  showScreen2 = false;
  isModal = false;
  awsModal = false;
  isRecovery = true;
  retrievalLoading = false;
  RecoveryLocalScreen = false;
  RecoveryAwsScreen = false;
  isModal = false;
  awsModal = false;
  awsAccessKey = null;
  awsSecretKey = null;
  awsRegion = null;
  awsBucket = null;
  fileData = null;

  @wire(getRecord, {
    recordId: USER_ID,
    fields: [NAME_FIELD, EMAIL_FIELD]
  })
  wireUser({ error, data }) {
    if (data) {
      this.username = data.fields.Name.value;
      this.userEmail = data.fields.Email.value;
    } else if (error) {
      // Handle error
      console.error(error);
    }
  }

  awsScreen() {
    this.isModal = true;
    this.awsModal = true;
    this.template.querySelector('c-lightning-Modal').handleIsOpenModal();
  }

  handleUpload(event) {
    console.log(event);
    console.log(event.detail.files[0]);
    // this.file = event.detail.files[0];
    // console.log('file');
    // console.log(this.file);
    // this.showToast('Uploaded SuccessFully', this.file.name, 'success');

    let selectedFile = event.target.files[0];
    this.file = event.detail.files[0];
    this.fileName = selectedFile.name;
    const expectedName = 'Salesforce Data';
    if (!this.fileName.includes(expectedName)) {
      console.log('not uploaded')
      this.showToast('Error', 'Please Upload Files which includes name ' + expectedName, 'error');
      return;
    }
    else {
      console.log("inside file change function");
      this.showToast('Success', 'File Uploaded Successfully ' + this.fileName, 'success');
    }
  }
  handleRecovery() {
    this.retrievalLoading = true;
    const fileReader = new FileReader();
    fileReader.onload = () => {
      const file = fileReader.result.split(',')[1];
      console.log('files');
      console.log(file);
      deployMetadata({ zipContent: file })
        .then(data => {
          this.retrievalLoading = false;
          this.RecoveryLocalScreen = true;
          console.log('data');
          console.log(data);
        })
        .catch(error => {
          this.retrievalLoading = false;
          console.log('error');
          console.log(error);
        })
    };
    fileReader.readAsDataURL(this.file);
  }

  showToast(title, message, variant) {
    this.dispatchEvent(
      new ShowToastEvent({
        title: title,
        message: message,
        variant: variant
      })
    );
  }

  handleAWSCredentials(event) {
    console.log('handle aws creds');
    console.log(event);
    console.log(event.detail.value);
    console.log(JSON.stringify(event.detail));
    const parsedData = JSON.parse(JSON.stringify(event.detail));
    this.awsAccessKey = parsedData.accessKey;
    this.awsSecretKey = parsedData.secretKey;
    this.awsRegion = parsedData.regionName;
    this.awsBucket = parsedData.bucketName;
    this.fileData = parsedData.fileData;
  }

  recoverAwsFiles() {
    this.retrievalLoading = true;
    if (this.awsAccessKey == null && this.awsSecretKey == null && this.awsRegion == null && this.awsBucket == null && this.fileData == null) {
      this.showToast('Required', 'Please select atleast 1 file to recover', 'error');
      return;
    }

    deployMetadata({ zipContent: this.fileData })
      .then(data => {
        this.retrievalLoading = false;
        this.RecoveryLocalScreen = true;
        console.log('data');
        console.log(data);
      })
      .catch(error => {
        this.retrievalLoading = false;
        console.log('error');
        console.log(error);
      })
  }
}