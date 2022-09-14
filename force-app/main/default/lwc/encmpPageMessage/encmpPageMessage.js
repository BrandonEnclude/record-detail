import { LightningElement, api } from "lwc";

const VARIANT_MAP = {
  info: "",
  warning: "slds-alert_warning",
  error: "slds-alert_error"
};

export default class EncmpPageMessage extends LightningElement {
  @api variant = "error";
  get alertClasses() {
    const baseClasses = "slds-notify slds-notify_alert";
    const variantClass = VARIANT_MAP[this.variant] || "";
    return `${baseClasses} ${variantClass}`;
  }

  handleClose() {
    this.dispatchEvent(new CustomEvent("close"));
  }
}