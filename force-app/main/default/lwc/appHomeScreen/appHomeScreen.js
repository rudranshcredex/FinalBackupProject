import { LightningElement, api, track, wire } from "lwc";
import LOGO_URL from "@salesforce/resourceUrl/credexLogo";
import { getRecord } from "lightning/uiRecordApi";
import USER_ID from "@salesforce/user/Id";
import NAME_FIELD from "@salesforce/schema/User.Name";

export default class appHomeScreen extends LightningElement {
  @api
  logo = LOGO_URL;
  HomePage = true;
  backupScreen = false;
  recoveryScreen = false;
  username;
  value = 'backup is clicked';

  @wire(getRecord, {
    recordId: USER_ID,
    fields: [NAME_FIELD]
  })
  wireUser({ error, data }) {
    if (data) {
      this.userName = data.fields.Name.value;
    } else if (error) {
      // Handle error
      console.error(error);
    }
  }
  handleHomepage() {
    this.HomePage = true;
    this.backupScreen = false;
    this.recoveryScreen = false;
  }
  handleBackup() {
    this.backupScreen = true;
    this.HomePage = false;
    this.recoveryScreen = false;
    this.template.querySelector('c-backup-screen').handleReturnBackup();
  }
  handleRecovery() {
    console.log("Inside recovery");
    this.recoveryScreen = true;
    this.backupScreen = false;
    this.HomePage = false;
    this.template.querySelector('c-recovery-screen').handleReturnRecovery();
  }
  
}