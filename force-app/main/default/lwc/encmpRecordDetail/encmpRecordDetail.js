import { LightningElement, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import create from "@salesforce/apex/EncmpRecordApi.create";
import edit from "@salesforce/apex/EncmpRecordApi.edit";

export default class EncmpRecordDetail extends NavigationMixin(
  LightningElement
) {
  @api objectApiName;
  @api recordId;
  @api readOnly = false;
  loading = false;
  sections = [];
  pageError = "";
  _editMode = false;

  get editMode() {
    return !this.recordId || this._editMode;
  }
  get showEdit() {
    return !this.editMode && !this.readOnly;
  }

  handleLoad(e) {
    const sections =
      e.detail.layout?.sections ||
      e.detail.layouts[this.objectApiName][
        Object.keys(e.detail.layouts[this.objectApiName])[0]
      ].Full.View.sections;
    this.sections = this.processFields(sections);
    this.loading = false;
  }

  processFields(sections) {
    return sections.map((section) => mapSection(section));
  }

  handleSubmit(e) {
    e.preventDefault();
    this.loading = true;
    this.pageError = "";
    const submitFunction = this.recordId ? edit : create;
    const fields = e.detail.fields;
    submitFunction({
      objectApiName: this.objectApiName,
      fields: fields,
      recordId: this.recordId
    })
      .then((recordId) => {
        this[NavigationMixin.Navigate]({
          type: "standard__recordPage",
          attributes: {
            recordId: recordId,
            objectApiName: this.objectApiName,
            actionName: "view"
          }
        });
      })
      .catch((err) => this.addPageError(err));
  }

  handleCancel() {
    const state = this.recordId ? { recordId: this.recordId } : {};
    if (this.recordId) {
      this[NavigationMixin.Navigate]({
        type: "standard__recordPage",
        attributes: {
          recordId: this.recordId,
          objectApiName: this.objectApiName,
          actionName: "view"
        }
      });
    } else {
      this[NavigationMixin.Navigate]({
        type: "standard__recordPage",
        attributes: {
          objectApiName: this.objectApiName,
          actionName: "list"
        }
      });
    }
  }

  handleSuccess(e) {
    const recordId = e.detail.id;
    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        recordId: recordId,
        objectApiName: this.objectApiName,
        actionName: "view"
      }
    });
  }

  addPageError(err) {
    this.pageError = err?.body?.message || "An unexpected error occurred";
    this.loading = false;
  }

  handleErrorClose() {
    this.pageError = "";
  }

  handleEdit() {
    this._editMode = true;
  }
}

const mapSection = (section) => {
  return {
    ...section,
    layoutRows: section.layoutRows.map((row, idx) =>
      mapRow(row, idx, section.columns)
    )
  };
};

const mapRow = (row, idx, numCols) => {
  return {
    id: idx,
    styleClass:
      numCols === 2
        ? "slds-col slds-size_1-of-1 slds-large-size_6-of-12"
        : "slds-col slds-size_1-of-1",
    layoutItems: row.layoutItems.map((item) => mapItem(item))
  };
};

const mapItem = (item) => {
  return {
    ...item,
    disabledForNew: !item.editableForNew,
    disabledForUpdate: !item.editableForUpdate,
    useHeading: item.layoutComponents.length > 1,
    layoutComponents: item.layoutComponents.map((cmp) =>
      mapComponent(cmp, item.required)
    )
  };
};

const mapComponent = (cmp, required) => {
  return {
    ...cmp,
    required: required && !requiredFieldExceptions.includes(cmp.apiName)
  };
};

const requiredFieldExceptions = ["Salutation", "FirstName"];
