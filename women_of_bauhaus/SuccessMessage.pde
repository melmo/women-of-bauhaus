class SuccessMessage {
  String query;
  String user;
  String status;
  String service;
  public SuccessMessage(String service, String query, String user, String status) {
    this.service = service;
    this.query = query;
    this.user = user;
    this.status = status;
  }
}
