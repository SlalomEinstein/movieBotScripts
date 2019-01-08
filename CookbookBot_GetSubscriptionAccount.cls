public with sharing class CookbookBot_GetSubscriptionAccount {

    public class OrderOutput{
        @InvocableVariable(required=true)         public String sStatus;
    }
    public class OrderInput{
        @InvocableVariable(required=true)         public String accountNumber;
        @InvocableVariable(required=true)         public String firstname;
        @InvocableVariable(required=true)         public String lastname;
        @InvocableVariable(required=true)         public String email;
    }


    @InvocableMethod(label='Get account Status')
    public static List<OrderOutput> getOrderStatus(List<OrderInput> orderInputs)
    {
        Set<String> emails = new Set<String>();
        String emailString;
        String planType;

        for (OrderInput emailField : orderInputs){ // Bulk proof for multiple emails
            emails.add(emailField.email);
            emailString = emailField.email;
            }

        List<Subscription_Plan__c> subPlans = [SELECT
                                               Id,Name,Contact_Email__c,Plan_Type__c,Plan_Monthly_Cost__c,
                                               Account_Description__c
                                               FROM Subscription_Plan__c
                                               where Contact_Email__c = :emailString];


        Map<String, String> mapNameStatus = new Map<String, String>();
        if (subPlans.size()>0)
        {
            for (Subscription_Plan__c subPlan : subPlans) {
                planType = subPlan.Plan_Type__c;
                mapNameStatus.put(subPlan.Name, subPlan.Plan_Type__c);
                System.debug(subPlan.Name);
            }

        }

        System.assert(mapNameStatus.size() > 0);

        List<OrderOutput> orderOutputs = new List<OrderOutput>();

        for (OrderInput orderInput : orderInputs)
        {
            OrderOutput orderOutput = new OrderOutput();
            System.debug(orderInput.AccountNumber);
            orderOutput.sStatus = mapNameStatus.get(orderInput.AccountNumber);
            orderOutputs.add(orderOutput);
        }

        System.assert(orderOutputs.size() > 0);

        return orderOutputs;




        //List<String> orderNumbers = new List<String>();
        //String accountNumber;
        //String newFirst;
        //String newLast;
        //String newEmail;

        //for (OrderInput orderInput : orderInputs){
         //orderNumbers.add(orderInput.accountNumber);
         //orderNumbers.add(orderInput.firstname);
         //orderNumbers.add(orderInput.lastname);
         //orderNumbers.add(orderInput.email);
         //}

         //accountNumber = orderNumbers[0];
         //newFirst = orderNumbers[1];
         //newLast = orderNumbers[2];
         //newEmail = orderNumbers[3];

         //Contact con = new Contact(firstname=newfirst, lastname=newlast);

         //List<Subscription_Plan__c> query = [SELECT Contact__c FROM Subscription_Plan__c where Contact__c =: con.Id];

      //Map<String, String> mapNameStatus = new Map<String, String>();
      //List<Subscription_Plan__c> orders = [SELECT Name,Plan_Type__c FROM Subscription_Plan__c where Contact_Email__c = :newEmail];
      //if (orders.size()>0)
        //{
          //  for (Subscription_Plan__c order : orders)
            //    mapNameStatus.put(order.Name, order.Plan_Type__c);
        //}

        //List<OrderOutput> orderOutputs = new List<OrderOutput>();

        //for (OrderInput orderInput : orderInputs)
        //{
          //  OrderOutput orderOutput = new OrderOutput();
            //orderOutput.sStatus = mapNameStatus.get(orderInput.accountNumber);
            //orderOutputs.add(orderOutput);
        //}


        //return orderOutputs;
    }
}
