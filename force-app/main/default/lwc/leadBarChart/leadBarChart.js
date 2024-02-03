import { LightningElement, wire, track } from 'lwc';
import getLeadChartData from '@salesforce/apex/LeadChartController.getLeadChartData';
import getInventoryData from '@salesforce/apex/LeadChartController.getInventoryData';
import sendData from '@salesforce/apex/LeadChartController.sendData';
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class LeadBarChart extends LightningElement {
    leadData;
    isModalOpen = false;
    showSpinner = false;
    isDisplayNoRecords = false;
    allColumnSelected = false;
    isProcessing = false;
    isEmail = true;
    selectedColumns;
    @track columnOptions = [];
    leadSource;
    channelSelected;
    searchTerm;
    message;
    templateSelected;
    channelSelected = 'Email';
    options = [{label: 'Email', value : 'Email'}, {label: 'SMS', value : 'SMS'}];
    showFreeText;
    freeText;

    @wire(getLeadChartData)
    wiredddData({ error, data }) {
        if (data != null && data.length > 0) {
            this.leadData = data;
        } else if (error) {
            console.error(error);
        }
    }

    get templateOptions() {
        return [
            { label: 'New', value: 'new' },
            { label: 'Pending', value: 'Pending' },
            { label: 'Sold', value: 'Sold' },
            { label: 'Free Text', value: 'Free Text' },
            { label: 'Transaction Update', value: 'Transaction Update' },
        ];
    }

    getInventoryData() {
        this.isProcessing = true;
        getInventoryData({})
            .then(result => {
                if (result) {
                    this.columnOptions = result;
                    this.columnOptions.forEach(col => {
                        col.isVisible = true;
                        col.isSelected = false;
                    })
                }
                //console.log('columnOptions--'+JSON.stringify(this.columnOptions));
                this.isProcessing = false;
            })
            .catch(error => {
                this.isProcessing = false;
                console.log('Error: ' + JSON.stringify(error));
            });
    }

    handleCardClick(event) {
        this.leadSource = event.currentTarget.dataset.id;
        this.isModalOpen = true;
        this.getInventoryData();
    }

    handleChange(event) {
        var value;
        if (event.target.type === 'checkbox' || event.target.type === 'checkbox-button' || event.target.type === 'toggle') {
            value = event.target.checked;
        } else {
            value = event.target.value;
        }
        if (event.target.dataset.id === 'channelSelect') {
            this.channelSelected = value;
            if (this.channelSelected == 'Email') {
                this.isEmail = true;
            } else {
                this.isEmail = false;
            }
        } else  if (event.target.dataset.id === 'message') {
                this.message = value;
                return;
        } else  if (event.target.dataset.id === 'templateSelect') {
                this.templateSelected = value;
                if (this.templateSelected == 'Free Text') {
                    this.showFreeText = true;
                } else {
                    this.showFreeText = false;
                }
            return;
        } else if (event.target.dataset.id === 'freeText') {
            this.freeText = value;
        }
    }

    handleColumnCheckboxSelectionAll(event) {

        this.allColumnSelected = event.target.checked
        this.columnOptions.forEach(column => {
            column.isSelected = this.allColumnSelected;
        })
        //this.generateQuery();
    }

    handleColumnCheckboxSelection(event) {

        let isAllSelected = true;

        this.columnOptions.forEach(column => {
            if (column.Name == event.target.name) {
                column.isSelected = event.target.checked;
            }
        })
        this.columnOptions.forEach(column => {
            if (!column.isSelected) {
                isAllSelected = false;
                return;
            }
        })

        this.allColumnSelected = isAllSelected;
    }
    
    handleSearch(event) {
        var hasResult = false;
        this.isDisplayNoRecords = false;
        this.searchTerm = event.target.value;
        for (var i = 0; i < this.columnOptions.length; i++) {
            if (this.columnOptions[i].Name.toLowerCase().includes(event.target.value.toLowerCase())) {
                this.columnOptions[i].isVisible = true;
                hasResult = true;
            } else {
                this.columnOptions[i].isVisible = false;
            }
        }

        if (!hasResult) {
            this.isDisplayNoRecords = true;
        }
    }

    closeModal() {
        this.isModalOpen = false;
        this.isDisplayNoRecords = false;
        this.allColumnSelected = false;
        this.isProcessing = false;
        this.isEmail = true;
        this.columnOptions = [];
        this.leadSource = '';
        this.channelSelected = '';
        this.searchTerm = '';
        this.message = '';
        this.templateSelected = '';
        this.channelSelected = 'Email';
        this.showFreeText = false;
        this.freeText = '';
    }

    handleSend() {
        if (this.validate()) {
            this.isProcessing = true;
                var colums = [];
                this.columnOptions.forEach(column => {
                    if(column.isSelected) {
                        colums.push(column.Id);
                    }
                })
                sendData({inventory: colums, leadSource: this.leadSource, channel: this.channelSelected, message: this.message, template: this.templateSelected, freeText: this.freeText})
                .then(result => {
                    if (result) {
                        this.showToast('SUCCESS', 'Request submitted successfully.');
                        this.isProcessing = false;
                        this.closeModal();
                    } else {
                        this.showToast('Error', 'Something went wrong.');
                        this.isProcessing = false;
                    }
                    
                })
                .catch(error => {
                    this.showToast('Error', 'Something went wrong.');
                    this.isProcessing = false;
                    console.log('Error: ' + JSON.stringify(error));
                });
        }
    }

    validate() {
        if(this.channelSelected == 'SMS' && !this.message) {
            this.showToast('ERROR', 'Please enter message.');
            return false;
        } else if (this.channelSelected == 'Email') {
            var isValid = false;
            if(this.columnOptions) {
                this.columnOptions.forEach(column => {
                    if(column.isSelected) {
                        isValid = true;
                    }
                })
            }

            if (!this.templateSelected || this.templateSelected == 'None') {
                this.showToast('ERROR', 'Please select template.');
                return false;
            }

            if (this.showFreeText && !this.freeText) {
                this.showToast('ERROR', 'Please enter text.');
                return false;
            }

            if(!isValid) {
                this.showToast('ERROR', 'Please select at least one inventory.');
                return false;
            }
        }
        return true;
    }

    showToast(title, message) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: title
        });
        this.dispatchEvent(event);
    }
}