global class CookbookBot_BatchDeleteUpdateMovies implements Database.Batchable<sObject>, Database.AllowsCallouts {

  global Database.QueryLocator start(Database.BatchableContext BC) {
    String query = 'SELECT Id FROM Movie__c';
    return Database.getQueryLocator(query);
  }

     global void execute(Database.BatchableContext BC, List<Movie__c> scope) {
    List<Movie__c> moviesToDelete = new List<Movie__c>();
    for(Movie__c listOfExistingMovies : scope){
      moviesToDelete.add(listOfExistingMovies);
    }

    if(moviesToDelete.size() > 0){
      delete moviesToDelete;
    }
  }

  global void finish(Database.BatchableContext BC) {
    Http http = new Http();
    HttpRequest request = new HttpRequest();
    request.setEndpoint('https://api.internationalshowtimes.com/v4/movies/?countries=US&fields=id,slug,title,poster_image_thumbnail,synopsis,runtime,genres');
    request.setMethod('GET');
    request.setHeader('X-API-Key', Label.InternationalShowtimeAPIKey);
    HttpResponse response = http.send(request);
    // If the request is successful, parse the JSON response.
    if (response.getStatusCode() == 200) {

      String returnedJSON = response.getBody();
      JSON2Apex convertedJSON = JSON2Apex.parse(returnedJSON);
      List<JSON2Apex.Movies> moviesPulled = convertedJSON.Movies;

      List<Movie__c> listOfMoviesToInsert = new List<Movie__c>();
      Map<String, Movie__c> moviesPulledMap = new Map<String, Movie__c>();
      List<String> moviesPulledISID = new List<String>();

      for(JSON2Apex.Movies movieInfo : moviesPulled){
        Movie__c currentMovie = new Movie__c();
        //if the movie doesn't have a name, move onto the next one
        if(movieInfo.title == null){
          continue;
        }
        else{
          currentMovie.Name = movieInfo.title;
        }
        currentMovie.International_Showtimes_ID__c = movieInfo.Id;
        currentMovie.International_Showtimes_Slug__c = movieInfo.slug;
        currentMovie.Movie_Title__c = movieInfo.title;
        currentMovie.International_Showtimes_Poster_Thumbnail__c = movieInfo.poster_image_thumbnail;
        currentMovie.Brief_Synopsis__c = movieInfo.synopsis;
        currentMovie.Runtime_in_Minutes__c = movieInfo.runtime;

        String listOfGenres = '';
        for(JSON2Apex.Genres genreInfo : movieInfo.Genres){
          if(genreInfo.Name != null){
            if(listOfGenres.length() == 0){
              listOfGenres = genreInfo.Name;
            }
            else{
              listOfGenres = listOfGenres + ';' + genreInfo.Name;
            }
          }
        }

        currentMovie.Genre__c = listOfGenres;

        moviesPulledMap.put(currentMovie.International_Showtimes_ID__c, currentMovie);
        moviesPulledISID.add(movieInfo.Id);
      }

      for(String IDsToUpdate : moviesPulledISID){
        if(!moviesPulledMap.isEmpty() && moviesPulledMap.containsKey(IDsToUpdate)){
          listOfMoviesToInsert.add(moviesPulledMap.get(IDsToUpdate));
        }
      }

      if(listOfMoviesToInsert.size() > 0){
        insert listOfMoviesToInsert;
      }
    }
    else{
      System.debug('Failed with a status of ' + response.getStatusCode());
    }

    //calls the next batch for Cinemas
    Database.executeBatch(new CookbookBot_BatchDeleteUpdateCinemas(), 50);
  }

}
