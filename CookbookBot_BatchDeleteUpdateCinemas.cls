global class CookbookBot_BatchDeleteUpdateCinemas implements Database.Batchable<sObject>, Database.AllowsCallouts {

  global Database.QueryLocator start(Database.BatchableContext BC) {
    String query = 'SELECT Id FROM Movie_Theater__c';
    return Database.getQueryLocator(query);
  }

     global void execute(Database.BatchableContext BC, List<Movie_Theater__c> scope) {
    List<Movie_Theater__c> cinemasToDelete = new List<Movie_Theater__c>();
    for(Movie_Theater__c listOfExistingCinemas : scope){
      cinemasToDelete.add(listOfExistingCinemas);
    }

    if(cinemasToDelete.size() > 0){
      delete cinemasToDelete;
    }
  }

  global void finish(Database.BatchableContext BC) {
    Http http = new Http();
    HttpRequest request = new HttpRequest();
    request.setEndpoint('https://api.internationalshowtimes.com/v4/cinemas/?countries=US');
    request.setMethod('GET');
    request.setHeader('X-API-Key', Label.InternationalShowtimeAPIKey);
    HttpResponse response = http.send(request);
    // If the request is successful, parse the JSON response.
    if (response.getStatusCode() == 200) {

      String returnedJSON = response.getBody();
      JSON2Apex convertedJSON = JSON2Apex.parse(returnedJSON);
      List<JSON2Apex.Cinemas> cinemasPulled = convertedJSON.Cinemas;

      List<Movie_Theater__c> listOfCinemasToInsert = new List<Movie_Theater__c>();
      Map<String, Movie_Theater__c> cinemasPulledMap = new Map<String, Movie_Theater__c>();
      List<String> cinemasPulledISID = new List<String>();

      for(JSON2Apex.Cinemas cinemaInfo : cinemasPulled){
        Movie_Theater__c currentCinema = new Movie_Theater__c();

        //gets the Latitude and longitude of the theater
        currentCinema.Cinema_Location__latitude__s = cinemaInfo.Location.lat;
        currentCinema.Cinema_Location__longitude__s = cinemaInfo.Location.lon;

        //gets the Address of the Cinema
        currentCinema.House_Number__c = cinemaInfo.Location.Address.house;
        currentCinema.Street__c = cinemaInfo.Location.Address.street;
        currentCinema.City__c = cinemaInfo.Location.Address.city;
        currentCinema.State__c = cinemaInfo.Location.Address.state;
        currentCinema.State_Abbreviation__c = cinemaInfo.Location.Address.state_abbr;
        currentCinema.Country__c = cinemaInfo.Location.Address.country;
        currentCinema.Country_Abbreviation__c = cinemaInfo.Location.Address.country_code;

        //null check to see if the ZIP is valid
        if(cinemaInfo.Location.Address.zipcode != null){
          //checks the substring and removes "-XXXX" if the ZIP code is not the standard 5 digits
          currentCinema.ZIP_Code__c = Decimal.valueOf(cinemaInfo.Location.Address.zipcode.substring(0,5));
        }

        //gets the Information about the Cinema
        //verifies that the telephone has no letters in it for the sake of demo purposes and because the data from the API is not sanitized
        if(cinemaInfo.telephone != null &&
          cinemaInfo.telephone.indexOf('a') < 0 &&
          cinemaInfo.telephone.indexOf('b') < 0 &&
          cinemaInfo.telephone.indexOf('c') < 0 &&
          cinemaInfo.telephone.indexOf('d') < 0 &&
          cinemaInfo.telephone.indexOf('e') < 0 &&
          cinemaInfo.telephone.indexOf('f') < 0 &&
          cinemaInfo.telephone.indexOf('g') < 0 &&
          cinemaInfo.telephone.indexOf('h') < 0 &&
          cinemaInfo.telephone.indexOf('i') < 0 &&
          cinemaInfo.telephone.indexOf('j') < 0 &&
          cinemaInfo.telephone.indexOf('k') < 0 &&
          cinemaInfo.telephone.indexOf('l') < 0 &&
          cinemaInfo.telephone.indexOf('m') < 0 &&
          cinemaInfo.telephone.indexOf('n') < 0 &&
          cinemaInfo.telephone.indexOf('o') < 0 &&
          cinemaInfo.telephone.indexOf('p') < 0 &&
          cinemaInfo.telephone.indexOf('q') < 0 &&
          cinemaInfo.telephone.indexOf('r') < 0 &&
          cinemaInfo.telephone.indexOf('s') < 0 &&
          cinemaInfo.telephone.indexOf('t') < 0 &&
          cinemaInfo.telephone.indexOf('u') < 0 &&
          cinemaInfo.telephone.indexOf('v') < 0 &&
          cinemaInfo.telephone.indexOf('w') < 0 &&
          cinemaInfo.telephone.indexOf('x') < 0 &&
          cinemaInfo.telephone.indexOf('y') < 0 &&
          cinemaInfo.telephone.indexOf('z') < 0 ){
          currentCinema.Cinema_Phone__c = cinemaInfo.telephone;
        }
        //currentCinema.Cinema_Phone__c = cinemaInfo.telephone;
        currentCinema.Cinema_Website__c = cinemaInfo.website;
        currentCinema.International_Showtimes_Cinema_ID__c = cinemaInfo.id;
        currentCinema.International_Showtimes_Cinema_Slug__c = cinemaInfo.slug;
        if(cinemaInfo.name.length() > 80){
          currentCinema.Name = cinemaInfo.name.substring(0,80);
        }
        else{
          currentCinema.Name = cinemaInfo.name;
        }

        cinemasPulledMap.put(currentCinema.International_Showtimes_Cinema_ID__c, currentCinema);
        cinemasPulledISID.add(cinemaInfo.Id);
      }

      for(String IDsToUpdate : cinemasPulledISID){
        if(!cinemasPulledMap.isEmpty() && cinemasPulledMap.containsKey(IDsToUpdate)){
          listOfCinemasToInsert.add(cinemasPulledMap.get(IDsToUpdate));
        }
      }

      if(listOfCinemasToInsert.size() > 0){
        insert listOfCinemasToInsert;
      }
    }
    else{
      System.debug('Failed with a status of ' + response.getStatusCode());
    }

    //calls the next batch for Showtimes. No need to delete because all Showtimes are deleted when all Movies are deleted/updated
    Database.executeBatch(new CookbookBot_BatchGetShowtimes(), 10);
  }

}
