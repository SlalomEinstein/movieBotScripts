public class CookbookBot_createCase {
    public class caseInput{
        @InvocableVariable(required=true)  public String contactEmail;
        @InvocableVariable(required=true)  public String caseSubject;
    }

    @InvocableMethod(label = 'Create new case')
    public static void createCase(List<caseInput> caseParameters){
        String cEmail;
        String cSubject;

        List<Contact> conList;

        List<String> caseInfo = new List<String>();
        if(caseParameters.size() > 0){
          for(caseInput caseparam : caseParameters){
              caseInfo.add(caseparam.contactEmail);
              caseInfo.add(caseparam.caseSubject);
          }
        }else{
            return;
        }

        if(caseInfo.size() > 0){
            cEmail = caseInfo[0];
            cSubject = caseInfo[1];

            try{
                conList = [SELECT Id, Name FROM Contact where Contact.Email = :'clarke.roche@slalom.com'];
              if (conList.isEmpty()){
                  return;
              }

              Contact c = conList[0];
        Case[] newCase = new List<Case>();
              Case singleCase = new Case(ContactId = c.Id,Subject = cSubject,Status = 'New',Origin = 'Web');
              newCase.add(singleCase);
              insert newCase;
            }catch(Exception e){
                return;
            }
        }

        else{
            return;
        }
    }
}
