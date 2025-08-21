public class UpdateMessagingAction {


    @InvocableMethod(label='Update Messaging Action')
    public static void updateMessagingSession(List<UpdateMessagingInput> input) {
        Map<String, String> userIds = new Map<String, String>();
        
        for(UpdateMessagingInput i : input) {
            userIds.put(i.messagingSessionId, i.userId);
        }
        
        System.debug(userIds);
        
        Map<String, Contact> contactsByUserId = new Map<String, Contact>();
        for(Contact c : [SELECT Id, AccountId, User_Id__c FROM Contact WHERE User_Id__c IN :userIds.values()]){
            contactsByUserId.put(c.User_Id__c, c);
        }
        
        System.debug(contactsByUserId);
        
        List<MessagingSession> sessions = [SELECT Id, MessagingEndUserId FROM MessagingSession WHERE Id IN :userIds.keySet()];
        List<MessagingEndUser> messagingEUToUpdate = new List<MessagingEndUser>();
        for(MessagingSession ms : sessions) {
            Contact c = contactsByUserId.get(userIds.get(ms.Id));
            if(c != null) {
                MessagingEndUser meu = new MessagingEndUser(Id = ms.MessagingEndUserId, AccountId = c.AccountId, ContactId = c.Id);
                messagingEUToUpdate.add(meu);
            }
        }
        if(!messagingEUToUpdate.isEmpty()) {
            System.debug(Database.update(messagingEUToUpdate, false, AccessLevel.SYSTEM_MODE));
        }
    }
    
    public class UpdateMessagingInput {
        @InvocableVariable(required=true)
        public String userId;
        @InvocableVariable(required=true)
        public String messagingSessionId;
    }
    
}