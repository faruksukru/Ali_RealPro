trigger AcquisitionTrigger on Acquisition__c (before insert, before update, before delete, after insert, after update, after delete) {
	new AcquisitionTriggerHandler().handler(Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap, Trigger.operationType);
}