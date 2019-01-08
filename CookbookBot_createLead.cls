public class CookbookBot_createLead {
    public class caseInput{
        @InvocableVariable(required=true)  public String contactEmail;
        @InvocableVariable(required=true)  public String firstName;
        @InvocableVariable(required=true)  public String lastName;
    }

    @InvocableMethod(label = 'Create new lead')
    public static void createCase(List<caseInput> leadParameters){
        String cEmail;
        String cFirst;
        String cLast;

        List<Contact> conList;

        List<String> leadInfo = new List<String>();
        if(leadParameters.size() > 0){
          for(caseInput leadparam : leadParameters){
              leadInfo.add(leadparam.contactEmail);
                leadInfo.add(leadparam.firstName);
                leadInfo.add(leadparam.lastName);
          }
        }else{
            return;
        }

        if(leadInfo.size() > 0){
            cEmail = leadInfo[0];
            cFirst = leadInfo[1];
            cLast = leadInfo[2];

            try{
        Lead[] newLead = new List<Lead>();
              Lead singleLead = new Lead(FirstName=cFirst,LastName=cLast,Email = cEmail,Company='New user',Status='Working - Contacted');
              newLead.add(singleLead);
              insert newLead;
            }catch(Exception e){
                return;
            }
        }

        else{
            return;
        }
    }
}
