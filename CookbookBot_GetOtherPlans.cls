public class CookbookBot_GetOtherPlans {

    @InvocableMethod(label='Show Other Subscription Plans')
    // Return a list of list of UpdatePlanType objects where each inner list acts as a menu option
    public static List<List<UpdatePlanType__c>> getOtherPlans(List<String> sEmails) {

        List <List<UpdatePlanType__c>> PlanList = new List<List<UpdatePlanType__c>>();
        String sEmail = sEmails[0];

        // Query the users Subscription Plan using their email
        List<Subscription_Plan__c> plans = [Select Id, Name, Plan_Type__c, Contact_Email__c from Subscription_Plan__c Where Contact__r.Email =:sEmail];

        // Query all of our dummy UpdatePlanType objects
        // There are only 3 records in SF - each of the plan types
        List<UpdatePlanType__c> upts = [Select Id, PlanType__c from UpdatePlanType__c];

        // For each of the picklist values in our dummy object, remove the values that are equal to users subscription plan type
        for(Integer i = 0; i < upts.size(); i++) {
            if (plans[0].Plan_Type__c == upts[i].PlanType__c) {
                upts.remove(i);
            }
        }

        // Add the list containing the remaining elements in upts
        PlanList.add(upts);
        return PlanList;

    }
}
