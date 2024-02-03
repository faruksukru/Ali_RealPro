import { LightningElement } from 'lwc';

export default class DataHome extends LightningElement {
    activeSections = ['section1', 'section2'];
    
    handleSectionToggle(event) {
        const sectionName = event.detail.openSections[0];
        console.log('Section toggled:', sectionName);
    }
}