class AllListener {
  
  TwitterListener tl;
  InstagramListener il;
  
  public AllListener() {
   // tl = new TwitterListener(this);
    //il = new InstagramListener(this);
  }
  
  void setQuery(String query) {
  //  tl.setQuery(query);
   // il.setQuery(query);
  }
  
  void pollQuery() {
  //  il.pollQuery();  
  }
  
  void logSuccess(SuccessMessage sm) {
    /*
    Change this to communicate with Paul's function 
    Also save tweet/status to file for record
    */

    System.out.println("@" + sm.user + " - " + sm.status);
    bs.success();
    //fill(200);
    //text( sm.service + "\n" + "#" + sm.query + "\n" + sm.status, random(width), random(height), 300, 200);
  }
  
}