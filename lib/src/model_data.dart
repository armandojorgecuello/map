class DataCommit {

  int? id;
  String? commit;

  DataCommit({this.id, this.commit});

  Map<String, dynamic> toMap(){
    return {'id': id, 'commit': commit};
  }

}