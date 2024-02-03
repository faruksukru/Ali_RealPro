trigger AWSAttachmentTrigger on Attachment__c (after delete) {
	AWSAttachmentTriggerHandler.handleOperations(Trigger.New, Trigger.old, Trigger.newMap, Trigger.oldMap, Trigger.OperationType);
}