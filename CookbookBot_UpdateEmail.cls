public class CookbookBot_UpdateEmail {

  public class Input {
        @InvocableVariable(required=true)         public String currentEmail;
        @InvocableVariable(required=true)         public String newEmail;
    }

    @InvocableMethod(label='Change Email')
    public static List<String> updateEmailAddress(List<Input> inputs) {

        Set<String> emails = new Set<String>();
        List<String> newEmailString = new List<String>();

        for (Input input : inputs) {
            emails.add(input.currentEmail);
            newEmailString.add(input.newEmail);
        }

        Map<String, Contact> mapNameStatus = new Map<String, Contact>();
        List<Contact> contacts = [SELECT Email FROM Contact where Contact.Email in :emails];


        if (contacts.size()>0) {
            for (Contact contact : contacts)
                mapNameStatus.put(String.valueOf(contact.Email), contact);
                newEmailString.add(String.valueOf(contact.Email));
        }

        List<Contact> emailsToUpdate = new List<Contact>();

        for (Input input : inputs)
        {
            Contact contact = new Contact();
            contact = mapNameStatus.get(input.currentEmail);
            contact.Email = input.newEmail;
            emailsToUpdate.add(contact);
        }

        update emailsToUpdate;
        return newEmailString;

    }
}
