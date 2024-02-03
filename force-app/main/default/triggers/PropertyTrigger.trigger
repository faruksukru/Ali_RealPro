trigger PropertyTrigger on Property__c (before insert, before update, before delete, after insert, after update, after delete) {
	new PropertyTriggerHandler().handler(Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap, Trigger.operationType);
}