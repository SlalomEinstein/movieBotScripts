public with sharing class CookbookBot_CleanChatLogForSentiment {

  @InvocableMethod(label='cleanChatLogForSentiment' description='Cleans the Live Chat Transcript for Sentiment Analysis')
  public static List<String> cleanChatLogForSentiment (List<String> inputParams) {
    //TODO: update method return type and input parameters (they do need to be List)

    List<String> results = new List<String>();

    for(String stringToConvert : inputParams){
      while(stringToConvert.contains('<p>')){
        //removes the first line with the Chat Start Time and the last line where it transfers
        String pTags = stringToConvert.substring(stringToConvert.indexOf('<p>'), stringToConvert.indexOf('</p>')+4);
        stringToConvert = stringToConvert.replace(pTags, '');
        System.debug('smeers - pTags - ' + pTags);
        System.debug('smeers - stringToConvert1 - ' + stringToConvert);
      }

      while(stringToConvert.contains('( ')){
        Integer openParenthesisStringIndex = stringToConvert.indexOf('(');
        Integer closeParenthesisStringIndex = stringToConvert.indexOf(')');
        stringToConvert = stringToConvert.replace(stringToConvert.substring(openParenthesisStringIndex, closeParenthesisStringIndex+2), '');
      }

      while(stringToConvert.contains('Movie Bot')){
        Integer movieBotStringIndex = stringToConvert.indexOf('Movie Bot');
        System.debug('smeers - movieBotStringIndex - ' + movieBotStringIndex);
        Integer brStringIndex = stringToConvert.indexOf('<br>');
        System.debug('smeers - brStringIndex - ' + brStringIndex);

        if(movieBotStringIndex > -1 && brStringIndex < movieBotStringIndex){
          stringToConvert = stringToConvert.replace(stringToConvert.substring(brStringIndex, brStringIndex+4), '');
        }
        if(brStringIndex > -1){
          stringToConvert = stringToConvert.replace(stringToConvert.substring(movieBotStringIndex, brStringIndex+4), '');
        }

        System.debug('smeers - stringToConvert - ' + stringToConvert);
      }

      /*while(stringToConvert.contains('<br>')){
        Integer brStringIndex = stringToConvert.indexOf('<br>');
        System.debug('smeers - brStringIndex - ' + brStringIndex);
        Integer movieBotStringIndex = stringToConvert.indexOf('Movie Bot:');
        System.debug('smeers - movieBotStringIndex - ' + movieBotStringIndex);

        if(movieBotStringIndex > -1 || brStringIndex > movieBotStringIndex){
          System.debug('smeers - true');
          stringToConvert = stringToConvert.replace(stringToConvert.substring(movieBotStringIndex, brStringIndex+4), '');
        }

        /if(movieBotStringIndex > -1 || brStringIndex < movieBotStringIndex){
          System.debug('smeers - false');
          stringToConvert = stringToConvert.replace(stringToConvert.substring(brStringIndex, brStringIndex+4), '');
        }/
        System.debug('smeers - stringToConvert - ' + stringToConvert);

        /*if(stringToConvert.contains('(')){

          Integer brStringIndex = stringToConvert.indexOf('<br>');
          Integer colonStringIndex = stringToConvert.indexOf(':');

          if(stringToConvert.contains('Movie Bot:')){
            System.debug('smeers - contains Movie Bot:');
            stringToConvert = stringToConvert.replace(stringToConvert.substring(stringToConvert.indexOf('Movie Bot'), brStringIndex + 4), '');
          }
          else{
            //stringToConvert = stringToConvert.replace(stringToConvert.substring(0, colonStringIndex+1), '');
            stringToConvert = stringToConvert.replace(stringToConvert.substring(brStringIndex, brStringIndex + 4), '');
          }

          */

          //System.debug('smeers - stringToConvert2 - ' + stringToConvert.substring(parenthesisStringIndex + 7, parenthesisStringIndex + 16));

          //removes any line said by Movie Bot
          /*if(stringToConvert.substring(parenthesisStringIndex + 7, parenthesisStringIndex + 16) == 'Movie Bot'){
            stringToConvert = stringToConvert.replace(stringToConvert.substring(parenthesisStringIndex, brStringIndex + 4), '');
          }
          else{
            if(brStringIndex > -1){
              stringToConvert = stringToConvert.replace(stringToConvert.substring(brStringIndex, brStringIndex + 4), '');
            }

          }

          //removes customer name and response time
          stringToConvert = stringToConvert.replace(stringToConvert.substring(parenthesisStringIndex, colonStringIndex), '');*/
        //}
      //}
      //System.debug('smeers - stringToConvert - ' + stringToConvert);
      if(stringToConvert.contains('{')){
        //remove braces
      }

      //System.debug('smeers - stringToConvert - ' + stringToConvert);
      results.add(stringToConvert);
    }

    return results;

  }
}

/*<p>Chat Started: Monday, October 15, 2018, 19:14:47 (+0000)</p>
( 1s ) Movie Bot: Hello clarkeroc, I&#39;m MovieBuddy&#39;s Virtual Assistant, how may I help you?<br>
( 9s ) clarkeroc fn: create account<br>
( 10s ) Movie Bot: I&#39;m sorry, I wasn&#39;t able to understand that. Here are some things that I can help you with though.<br>
( 20s ) clarkeroc fn: menu<br>
( 20s ) Movie Bot: Here&#39;s what I can do.<br>
( 20s ) Movie Bot: {ChatWindowMenu:Movie Show Times,Lookup order,Account Settings,Search Frequently Asked Questions,Transfer To Agent}<br>
( 25s ) clarkeroc fn: Account Settings<br>
( 26s ) Movie Bot: Would you like to make an account?<br>
( 26s ) Movie Bot: {ChatWindowButton:Yes,No}<br>
( 31s ) clarkeroc fn: null<br>
( 31s ) Movie Bot: We&#39;re excited to have you join us. Please choose a membership type. We already have your name and email.<br>
( 31s ) Movie Bot: {ChatWindowButton:Basic,Premium,Ultimate,See Plan Details}<br>
( 35s ) clarkeroc fn: null
<p>Agent Chatbot failed to transfer the chat to button Chatbot Chat Button</p>


for(LiveChatTranscript lct : [SELECT Body_Text__c FROM LiveChatTranscript WHERE Id = '5701H000000eGap' LIMIT 1]){
    CookbookBot_CleanChatLogForSentiment.cleanChatLogForSentiment(new List<String>{lct.Body_Text__c});
}
*/
