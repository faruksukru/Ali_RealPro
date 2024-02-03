trigger SaleTrigger on Sale__c (before insert, before update, before delete, after insert, after update, after delete) {
    new SaleTriggerHandler().handler(Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap, Trigger.operationType);
}