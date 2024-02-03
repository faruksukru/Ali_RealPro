trigger NDATrigger on NDA__c (after update) {
	NDATriggerHandler.handleOperations(Trigger.New, Trigger.old, Trigger.newMap, Trigger.oldMap, Trigger.OperationType);
}