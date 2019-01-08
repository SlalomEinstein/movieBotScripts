public class CookbookBot_createContact {

    public class ContactInput {
        @InvocableVariable(required=true)         public String firstName;
        @InvocableVariable(required=true)         public String lastName;
        @InvocableVariable(required=true)         public String contactEmail;
        @InvocableVariable(required=true)         public String subscriptionType;

    }

    @InvocableMethod(label='Create Contact')
    public static List<Contact> createContact(List<ContactInput> contactInputs) {
        String first;
        String last;
        String email;
        String subType;

        List<String> contactInfo = new List<String>();
        List<Contact> contact;

        for (ContactInput contactInput : contactInputs) {
            contactInfo.add(contactInput.firstName);
            contactInfo.add(contactInput.lastName);
            contactInfo.add(contactInput.contactEmail);
            contactInfo.add(contactInput.subscriptionType);
        }

        if (contactInfo.size() > 0) {
            first = contactInfo[0];
            last = contactInfo[1];
            email = contactInfo[2];
            subType = contactInfo[3];

            contact = [SELECT Id, Name FROM Contact where Contact.Email =: email];

            if (contact.isEmpty()) {
                Contact c = new Contact(firstname=first,lastname=last,email=email,Subscription_Type__c=subType);
                contact.add(c);
                insert contact;
            }
        }

        return contact;
    }
}
