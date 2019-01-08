public class CookbookBot_feedback {
        //public class OrderOutput{
        //@InvocableVariable(required=true)         public String sStatus;
    //}
    public class OrderInput{
        @InvocableVariable(required=true)         public String notes;
        @InvocableVariable(required=true)         public String email;

    }


    @InvocableMethod(label='give feedback')
    public static void getOrderStatus(List<OrderInput> orderInputs)
    {
        String newEmail;
        String newNotes;

        //String accountT;
        List<String> feedInfo = new List<String>();
        for (OrderInput orderInput : orderInputs){
            feedInfo.add(orderInput.email);
            feedInfo.add(orderInput.notes);
            //accountT = orderInput.accountType;
        }

        if (feedInfo.size() > 0) {
            newEmail= feedInfo[0];
            newNotes = feedInfo[1];

            Contact con = [SELECT Email FROM Contact where Email = :newEmail];

            Customer_Feedback__c[] newFeed = new List<Customer_Feedback__c>();
            Customer_Feedback__c feed = new Customer_Feedback__c(Contact__c=con.Id,Feedback_Notes__c=newNotes);
            newFeed.add(feed);
            insert newFeed;
        }
    }
}
