public class CookbookBot_cancelUpdated{

    public class EmailInput{
        @InvocableVariable(required=true)         public String email;
        //@InvocableVariable(required=true)         public String newSubscriptionType;
    }

    @InvocableMethod(label='cancel account 2')
    public static void updateSubscriptionPlan(List<EmailInput> orderInputs)
    {
        Set<String> orderNumbers = new Set<String>();

        for (EmailInput orderInput : orderInputs)
            orderNumbers.add(orderInput.email);

        Map<String, Subscription_Plan__c> mapNameStatus = new Map<String, Subscription_Plan__c>();
        List<Subscription_Plan__c> subPlans = [SELECT Name, Plan_Type__c,Contact_Email__c FROM Subscription_Plan__c where Contact__r.email in :orderNumbers];

        if (subPlans.size()>0)
        {
            for (Subscription_Plan__c subPlan : subPlans)
                mapNameStatus.put(String.valueOf(subPlan.Contact_Email__c), subPlan);
        }

        List<Subscription_Plan__c> plansToUpdate = new List<Subscription_Plan__c>();

        for (EmailInput orderInput : orderInputs)
        {
            Subscription_Plan__c plan = new Subscription_Plan__c();
            plan = mapNameStatus.get(orderInput.email);
            //plan.Plan_Type__c = orderInput.newSubscriptionType;
            plan.Active__c = 'No';
            plansToUpdate.add(plan);
        }

        update plansToUpdate;

    }
}
