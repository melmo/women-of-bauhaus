class InstagramListener {
  
  long lastPollTime;
  AllListener parentListener;
  String query;
  InstagramClient client;
  boolean polling = false;
 
  public InstagramListener(AllListener parentListener) {
    
    lastPollTime = System.currentTimeMillis();
    this.parentListener = parentListener;
    
    try {
      client = new DefaultInstagramClient("3cb6bf2e1c4344fdb2cd855ef20f54cc", "c3a048a9ef2348fdb5cc3e231cb3319e");
      println("insta client");
    }
    catch (Exception e) {
      println("create - Exception");
    }
  }
  
  void setQuery(String query) {
    this.query = query;
    lastPollTime = System.currentTimeMillis();
  }
  
  void pollQuery() {
    println(query);
    println("doingpoll");
    
    try {
      polling = false;
      Result<org.instagram4j.entity.Media[]> result = client.getRecentMediaForTag(query, Parameter.as("count", 1)); //problem
      //long tmpPollTime = System.currentTimeMillis();
      polling = true;
      while (result.getMeta().isSuccess() && result.getData().length > 0 && polling) {
        for (org.instagram4j.entity.Media media : result.getData()) {
          println(media.getCaption().getText());
          long mediaTime = Long.parseLong(media.getCreatedTime(), 10) * 1000;
          if (mediaTime > lastPollTime) {
            SuccessMessage sm = new SuccessMessage("instagram", query, media.getUser().getFullName(), media.getCaption().getText());
            logSuccess(sm);
          }
        }

        if (result.getPagination().getNextUrl() != null) {
          result = client.getMediaNext(result.getPagination());
        } else {
          break;
        }
  
      }
      //lastPollTime = tmpPollTime;
    } catch (InstagramException e) {
      println("poll - InstagramException");
    }
  }
  
  void logSuccess(SuccessMessage sm) {
    parentListener.logSuccess(sm);
  }
}


