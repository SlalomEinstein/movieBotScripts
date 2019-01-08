public class CookbookBot_createSubsciptionPlan {

    public class SubcriptionInput {
        @InvocableVariable(required=true)         public String memebershipType;
        @InvocableVariable(required=true)         public Contact contact;
    }

    @InvocableMethod(label='Create Subscription Plan')
    public static void createSubscription(List<SubcriptionInput> subInputs) {
        String memebershipType;
        Contact contact;

        if(subInputs.size() > 0) {
            memebershipType = subInputs[0].memebershipType;
            contact = subInputs[0].contact;
            System.debug(contact);

            Subscription_Plan__c[] newSubs = new List<Subscription_Plan__c>();
            Subscription_Plan__c sub = new Subscription_Plan__c(Contact__c=contact.Id,Plan_Type__c=memebershipType, Active__c='Yes');
            newSubs.add(sub);

            insert newSubs;

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); //Instantiate the instance here.

            String[] toAddresses = new String[]{contact.email}; //String array to send an email
            mail.setToAddresses(toAddresses); // declaring a variable
            mail.setReplyTo('BuddyBot@moviebuddy.com');// setting the reply from
            mail.setSubject('Important notification!');
            mail.setPlainTextBody('Hello, ' + contact.firstName + '.' + '\n' +'This email is to notify that an account has been made in your name!' + '\n' + 'Please do not reply to this message.');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});//actual method that sends the mail.
        }
    }
}
