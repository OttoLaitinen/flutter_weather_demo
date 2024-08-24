class AutocompleteResponse {
  final List<Prediction> predictions;
  final String status;

  AutocompleteResponse({
    required this.predictions,
    required this.status,
  });

  factory AutocompleteResponse.fromJson(Map<String, dynamic> json) {
    return AutocompleteResponse(
      predictions: List<Prediction>.from(
        json['predictions'].map((x) => Prediction.fromJson(x)),
      ),
      status: json['status'],
    );
  }
}

class Prediction {
  final String description;
  final String placeId;

  Prediction({
    required this.description,
    required this.placeId,
  });

  factory Prediction.fromJson(Map<String, dynamic> json) {
    return Prediction(
      description: json['description'],
      placeId: json['place_id'],
    );
  }
}
