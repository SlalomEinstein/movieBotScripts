public class CookbookBot_existingLead {
    public class leadInput{
        @InvocableVariable(required=true)  public String leadEmail;
    }

    @InvocableMethod(label='Check lead existence')
    public static List<String> checkLeads(List<leadInput> leadParameters){

        List<String> existingLead;
        List<String> emails;
        String lEmail;
        List<String> result;

        if (leadParameters.size() > 0){
            for (leadInput param : leadParameters){
                emails.add(param.leadEmail);
            }
            lEmail = emails[0];

            try{
                List<Lead> foundLeads = [Select Name, Email from Lead where Lead.Email=:lEmail];
                if(foundLeads.size() > 0){
                    result.add('Yes');
                        }else{
                            result.add('No');
                        }
            }catch(Exception e){
                return result;
            }

        }
        return result;
    }
}
